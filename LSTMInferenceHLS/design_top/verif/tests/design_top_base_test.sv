// ============================================================================
// Amazon FPGA Hardware Development Kit
// ============================================================================

`include "common_base_test.svh"
`include "design_top_defines.vh"

module design_top_base_test();
  import tb_type_defines_pkg::*;
  `include "base_test_utils.svh";

  task automatic ocl_wr32(input logic [ADDR_WIDTH_OCL - 1 : 0] addr, input logic [WIDTH_AXI - 1:0] data);
    tb.poke_ocl(.addr(addr), .data(data));
  endtask

  localparam int DATA_SIZE = 16;
  localparam int N = 4;

  logic [WIDTH_AXI - 1:0] error_cnt;

  logic [63:0]  in1_ptr, in2_ptr, out_ptr;
  logic [511:0] poke_data, peek_data;

  int source_in1 [DATA_SIZE];
  int source_in2 [DATA_SIZE];
  int source_sw_results [DATA_SIZE];

  integer i, j, k, idx;

  initial begin
    error_cnt = 'b0;
    tb.power_up(.clk_recipe_a(ClockRecipe::A0));
    initialize_ddr();

    in1_ptr = 64'h0000_0000_0000_0000;
    in2_ptr = 64'h0000_0000_0000_0100;
    out_ptr = 64'h0000_0000_0000_0200;

    // Generate test data (simple deterministic values instead of random)
    for (i = 0; i < DATA_SIZE; i++) begin
      source_in1[i] = i + 1;
      source_in2[i] = (i + 1) * 2;
    end

    // Compute expected GEMM results: C = A * B (4x4 matrices, row-major)
    for (i = 0; i < N; i++) begin
      for (j = 0; j < N; j++) begin
        source_sw_results[i * N + j] = 0;
        for (k = 0; k < N; k++) begin
          source_sw_results[i * N + j] += source_in1[i * N + k] * source_in2[k * N + j];
        end
      end
    end

    // Load input matrices into DDR via PCIS
    // 16 elements x 32 bits = 512 bits = one 512-bit DDR word per matrix
    $display("[%t] Loading input matrices into DDR (%0d elements each)", $realtime, DATA_SIZE);
    ocl_wr32(ADDR_TRANSFER_EN, 32'h1);

    poke_data = '0;
    for (i = 0; i < DATA_SIZE; i++) begin
      poke_data[i*32 +: 32] = source_in1[i];
    end
    tb.poke(.addr(in1_ptr), .data(poke_data), .size(DataSize::UINT512));

    poke_data = '0;
    for (i = 0; i < DATA_SIZE; i++) begin
      poke_data[i*32 +: 32] = source_in2[i];
    end
    tb.poke(.addr(in2_ptr), .data(poke_data), .size(DataSize::UINT512));

    ocl_wr32(ADDR_TRANSFER_EN, 32'h0);

    // Configure vadd control registers (pointer addresses)
    $display("[%t] Configuring vadd control registers", $realtime);
    ocl_wr32(16'h0010, in1_ptr[31:0]);
    ocl_wr32(16'h0014, in1_ptr[63:32]);
    ocl_wr32(16'h001C, in2_ptr[31:0]);
    ocl_wr32(16'h0020, in2_ptr[63:32]);
    ocl_wr32(16'h0028, out_ptr[31:0]);
    ocl_wr32(16'h002C, out_ptr[63:32]);

    // Start kernel
    $display("[%t] Starting GEMM kernel (ap_start)", $realtime);
    ocl_wr32(16'h0000, 32'h1);

    // Wait for completion
    fork
      begin
        wait (tb.card.fpga.CL.ap_done_w == 1'b1);
        $display("[%t] GEMM kernel completed (ap_done)", $realtime);
      end
      begin
        #500us;
        $error("[%t] Timeout waiting for ap_done", $realtime);
        error_cnt++;
      end
    join_any
    disable fork;

    // Read back results and verify
    $display("[%t] Verifying GEMM output", $realtime);
    ocl_wr32(ADDR_TRANSFER_EN, 32'h1);

    tb.peek(.addr(out_ptr), .data(peek_data), .size(DataSize::UINT512));

    for (i = 0; i < DATA_SIZE; i++) begin
      automatic int got_val;
      got_val = peek_data[i*32 +: 32];

      if (got_val !== source_sw_results[i]) begin
        $error("Error: Result mismatch at i=%0d: CPU result=%0d, Device result=%0d",
               i, source_sw_results[i], got_val);
        error_cnt++;
      end
    end

    ocl_wr32(ADDR_TRANSFER_EN, 32'h0);

    $display("[%t] Compute cycles:  %0d", $realtime, tb.card.fpga.CL.compute_cycles);
    $display("[%t] Transfer cycles: %0d", $realtime, tb.card.fpga.CL.transfer_cycles);

    tb.power_down();
    if (error_cnt == 0)
      $display("---- TEST PASSED (GEMM 4x4) ----");
    else begin
      $display("---- TEST FAILED (GEMM 4x4, %0d errors) ----", error_cnt);
      report_pass_fail_status(0);
    end

    $finish;
  end
endmodule
