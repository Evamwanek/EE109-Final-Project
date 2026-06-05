// ============================================================================
// design_top_base_test.sv
// HW simulation test for LSTM genre classification inference.
//
// Loads float32 weights + input_seq from disk, converts to ap_fixed<32,10>
// bit-pattern, DMA's into DDR, runs the kernel, checks pred_out == 7.
// ============================================================================

`include "common_base_test.svh"
`include "design_top_defines.vh"

module design_top_base_test();
  import tb_type_defines_pkg::*;
  `include "base_test_utils.svh";

  // --------------------------------------------------------------------------
  // OCL write helper
  // --------------------------------------------------------------------------
  task automatic ocl_wr32(input logic [ADDR_WIDTH_OCL-1:0] addr,
                           input logic [WIDTH_AXI-1:0]      data);
    tb.poke_ocl(.addr(addr), .data(data));
  endtask

  // --------------------------------------------------------------------------
  // DDR base addresses (64-byte aligned, computed from buffer sizes)
  // --------------------------------------------------------------------------
  localparam logic [63:0] ADDR_INPUT_SEQ = 64'h0000_0000_0000_0000; // 25600 B
  localparam logic [63:0] ADDR_WIH0      = 64'h0000_0000_0000_6400; // 262144 B
  localparam logic [63:0] ADDR_WHH0      = 64'h0000_0000_0004_6400; // 262144 B
  localparam logic [63:0] ADDR_BIH0      = 64'h0000_0000_0008_6400; // 2048 B
  localparam logic [63:0] ADDR_BHH0      = 64'h0000_0000_0008_6C00; // 2048 B
  localparam logic [63:0] ADDR_WIH1      = 64'h0000_0000_0008_7400; // 262144 B
  localparam logic [63:0] ADDR_WHH1      = 64'h0000_0000_000C_7400; // 262144 B
  localparam logic [63:0] ADDR_BIH1      = 64'h0000_0000_0010_7400; // 2048 B
  localparam logic [63:0] ADDR_BHH1      = 64'h0000_0000_0010_7C00; // 2048 B
  localparam logic [63:0] ADDR_WFC       = 64'h0000_0000_0010_8400; // 5120 B
  localparam logic [63:0] ADDR_BFC       = 64'h0000_0000_0010_9800; // 40 B
  localparam logic [63:0] ADDR_PRED_OUT  = 64'h0000_0000_0010_9840; // 4 B

  // --------------------------------------------------------------------------
  // AXI-Lite register offsets (Vitis HLS standard layout for vadd)
  // --------------------------------------------------------------------------
  localparam logic [15:0] REG_AP_CTRL      = 16'h0000;
  localparam logic [15:0] REG_INPUT_SEQ_LO = 16'h0010;
  localparam logic [15:0] REG_INPUT_SEQ_HI = 16'h0014;
  localparam logic [15:0] REG_WIH0_LO      = 16'h001C;
  localparam logic [15:0] REG_WIH0_HI      = 16'h0020;
  localparam logic [15:0] REG_WHH0_LO      = 16'h0028;
  localparam logic [15:0] REG_WHH0_HI      = 16'h002C;
  localparam logic [15:0] REG_BIH0_LO      = 16'h0034;
  localparam logic [15:0] REG_BIH0_HI      = 16'h0038;
  localparam logic [15:0] REG_BHH0_LO      = 16'h0040;
  localparam logic [15:0] REG_BHH0_HI      = 16'h0044;
  localparam logic [15:0] REG_WIH1_LO      = 16'h004C;
  localparam logic [15:0] REG_WIH1_HI      = 16'h0050;
  localparam logic [15:0] REG_WHH1_LO      = 16'h0058;
  localparam logic [15:0] REG_WHH1_HI      = 16'h005C;
  localparam logic [15:0] REG_BIH1_LO      = 16'h0064;
  localparam logic [15:0] REG_BIH1_HI      = 16'h0068;
  localparam logic [15:0] REG_BHH1_LO      = 16'h0070;
  localparam logic [15:0] REG_BHH1_HI      = 16'h0074;
  localparam logic [15:0] REG_WFC_LO       = 16'h007C;
  localparam logic [15:0] REG_WFC_HI       = 16'h0080;
  localparam logic [15:0] REG_BFC_LO       = 16'h0088;
  localparam logic [15:0] REG_BFC_HI       = 16'h008C;
  localparam logic [15:0] REG_PRED_OUT_LO  = 16'h0094;
  localparam logic [15:0] REG_PRED_OUT_HI  = 16'h0098;

  // --------------------------------------------------------------------------
  // Buffer sizes in 32-bit words
  // --------------------------------------------------------------------------
  localparam int N_INPUT_SEQ = 50 * 128;   // 6400  words
  localparam int N_WIH0      = 4 * 128 * 128; // 65536 words
  localparam int N_WHH0      = 4 * 128 * 128;
  localparam int N_BIH0      = 4 * 128;    // 512   words
  localparam int N_BHH0      = 4 * 128;
  localparam int N_WIH1      = 4 * 128 * 128;
  localparam int N_WHH1      = 4 * 128 * 128;
  localparam int N_BIH1      = 4 * 128;
  localparam int N_BHH1      = 4 * 128;
  localparam int N_WFC       = 10 * 128;   // 1280  words
  localparam int N_BFC       = 10;

  localparam int EXPECTED_PRED = 7;

  // --------------------------------------------------------------------------
  // Convert float32 bit-pattern to ap_fixed<32,10> bit-pattern.
  // ap_fixed<32,10>: value = bits * 2^-22
  // float32:         value = sign * 2^(exp-127) * mantissa
  // We convert by: fixed_bits = round(float_value * 2^22)
  // Using $bitstoreal / integer arithmetic in SV.
  // --------------------------------------------------------------------------
  function automatic logic [31:0] float_to_fixed(input logic [31:0] f_bits);
    real    fval;
    longint scaled;
    fval   = $bitstoshortreal(f_bits);   // float32 → real
    scaled = longint'($rtoi(fval * 4194304.0 + 0.5)); // * 2^22, round
    // Clamp to signed 32-bit range
    if (scaled >  2147483647) scaled =  2147483647;
    if (scaled < -2147483648) scaled = -2147483648;
    return scaled[31:0];
  endfunction

  // --------------------------------------------------------------------------
  // DMA helper: write an array of ap_fixed words into DDR.
  // Packs 16 x 32-bit words per 512-bit DDR beat.
  // --------------------------------------------------------------------------
  task automatic dma_write_words(
    input logic [63:0]  base_addr,
    input logic [31:0]  words [],   // dynamic array of fixed-point words
    input int           n_words
  );
    logic [511:0] beat;
    int           beat_idx;
    int           word_in_beat;
    int           w;

    beat     = '0;
    beat_idx = 0;

    for (w = 0; w < n_words; w++) begin
      word_in_beat = w % 16;
      beat[word_in_beat*32 +: 32] = words[w];

      if (word_in_beat == 15 || w == n_words-1) begin
        tb.poke(.addr(base_addr + beat_idx * 64),
                .data(beat),
                .size(DataSize::UINT512));
        beat     = '0;
        beat_idx = beat_idx + 1;
      end
    end
  endtask

  // --------------------------------------------------------------------------
  // Load a binary float32 file, convert every word to ap_fixed<32,10>,
  // and DMA into DDR at base_addr.
  // --------------------------------------------------------------------------
  task automatic load_and_dma(
    input string        path,
    input logic [63:0]  base_addr,
    input int           n_words
  );
    int           fd;
    logic [31:0]  fbuf [];   // raw float32 bits
    logic [31:0]  xbuf [];   // converted fixed-point bits
    int           r, w;

    fbuf = new[n_words];
    xbuf = new[n_words];

    fd = $fopen(path, "rb");
    if (fd == 0) begin
      $fatal(1, "Cannot open file: %s", path);
    end

    // Read n_words x 4 bytes
    r = $fread(fbuf, fd);
    $fclose(fd);

    if (r != n_words) begin
      $warning("load_and_dma: expected %0d words from %s, got %0d", n_words, path, r);
    end

    // Convert float32 → ap_fixed<32,10>
    for (w = 0; w < n_words; w++) begin
      xbuf[w] = float_to_fixed(fbuf[w]);
    end

    dma_write_words(base_addr, xbuf, n_words);
    $display("[%t] Loaded %s (%0d words) → DDR 0x%016X", $realtime, path, n_words, base_addr);

    fbuf.delete();
    xbuf.delete();
  endtask

  // --------------------------------------------------------------------------
  // Main test
  // --------------------------------------------------------------------------
  logic [31:0]  error_cnt;
  logic [511:0] peek_data;
  logic [31:0]  pred_out_val;

  initial begin
    error_cnt = 0;
    tb.power_up(.clk_recipe_a(ClockRecipe::A0));
    initialize_ddr();

    // --- Load all buffers into DDR ---
    $display("[%t] Loading LSTM inputs and weights into DDR...", $realtime);
    ocl_wr32(ADDR_TRANSFER_EN, 32'h1);

    load_and_dma("/home/ubuntu/EE109-Final-Project/input_seq.bin",
                 ADDR_INPUT_SEQ, N_INPUT_SEQ);

    load_and_dma("/home/ubuntu/EE109-Final-Project/weights/weight_ih_l0.bin",
                 ADDR_WIH0, N_WIH0);
    load_and_dma("/home/ubuntu/EE109-Final-Project/weights/weight_hh_l0.bin",
                 ADDR_WHH0, N_WHH0);
    load_and_dma("/home/ubuntu/EE109-Final-Project/weights/bias_ih_l0.bin",
                 ADDR_BIH0, N_BIH0);
    load_and_dma("/home/ubuntu/EE109-Final-Project/weights/bias_hh_l0.bin",
                 ADDR_BHH0, N_BHH0);

    load_and_dma("/home/ubuntu/EE109-Final-Project/weights/weight_ih_l1.bin",
                 ADDR_WIH1, N_WIH1);
    load_and_dma("/home/ubuntu/EE109-Final-Project/weights/weight_hh_l1.bin",
                 ADDR_WHH1, N_WHH1);
    load_and_dma("/home/ubuntu/EE109-Final-Project/weights/bias_ih_l1.bin",
                 ADDR_BIH1, N_BIH1);
    load_and_dma("/home/ubuntu/EE109-Final-Project/weights/bias_hh_l1.bin",
                 ADDR_BHH1, N_BHH1);

    load_and_dma("/home/ubuntu/EE109-Final-Project/weights/fc_weight.bin",
                 ADDR_WFC, N_WFC);
    load_and_dma("/home/ubuntu/EE109-Final-Project/weights/fc_bias.bin",
                 ADDR_BFC, N_BFC);

    ocl_wr32(ADDR_TRANSFER_EN, 32'h0);

    // --- Configure kernel pointer registers ---
    $display("[%t] Writing kernel control registers...", $realtime);
    ocl_wr32(REG_INPUT_SEQ_LO, ADDR_INPUT_SEQ[31:0]);
    ocl_wr32(REG_INPUT_SEQ_HI, ADDR_INPUT_SEQ[63:32]);
    ocl_wr32(REG_WIH0_LO,      ADDR_WIH0[31:0]);
    ocl_wr32(REG_WIH0_HI,      ADDR_WIH0[63:32]);
    ocl_wr32(REG_WHH0_LO,      ADDR_WHH0[31:0]);
    ocl_wr32(REG_WHH0_HI,      ADDR_WHH0[63:32]);
    ocl_wr32(REG_BIH0_LO,      ADDR_BIH0[31:0]);
    ocl_wr32(REG_BIH0_HI,      ADDR_BIH0[63:32]);
    ocl_wr32(REG_BHH0_LO,      ADDR_BHH0[31:0]);
    ocl_wr32(REG_BHH0_HI,      ADDR_BHH0[63:32]);
    ocl_wr32(REG_WIH1_LO,      ADDR_WIH1[31:0]);
    ocl_wr32(REG_WIH1_HI,      ADDR_WIH1[63:32]);
    ocl_wr32(REG_WHH1_LO,      ADDR_WHH1[31:0]);
    ocl_wr32(REG_WHH1_HI,      ADDR_WHH1[63:32]);
    ocl_wr32(REG_BIH1_LO,      ADDR_BIH1[31:0]);
    ocl_wr32(REG_BIH1_HI,      ADDR_BIH1[63:32]);
    ocl_wr32(REG_BHH1_LO,      ADDR_BHH1[31:0]);
    ocl_wr32(REG_BHH1_HI,      ADDR_BHH1[63:32]);
    ocl_wr32(REG_WFC_LO,       ADDR_WFC[31:0]);
    ocl_wr32(REG_WFC_HI,       ADDR_WFC[63:32]);
    ocl_wr32(REG_BFC_LO,       ADDR_BFC[31:0]);
    ocl_wr32(REG_BFC_HI,       ADDR_BFC[63:32]);
    ocl_wr32(REG_PRED_OUT_LO,  ADDR_PRED_OUT[31:0]);
    ocl_wr32(REG_PRED_OUT_HI,  ADDR_PRED_OUT[63:32]);

    // --- Start kernel ---
    $display("[%t] Starting LSTM kernel (ap_start)...", $realtime);
    ocl_wr32(REG_AP_CTRL, 32'h1);

    // --- Wait for ap_done with timeout ---
    fork
      begin
        wait (tb.card.fpga.CL.ap_done_w == 1'b1);
        $display("[%t] Kernel completed (ap_done)", $realtime);
      end
      begin
        #2000us;
        $error("[%t] TIMEOUT waiting for ap_done", $realtime);
        error_cnt++;
      end
    join_any
    disable fork;

    // --- Read back pred_out ---
    $display("[%t] Reading pred_out from DDR...", $realtime);
    ocl_wr32(ADDR_TRANSFER_EN, 32'h1);
    tb.peek(.addr(ADDR_PRED_OUT), .data(peek_data), .size(DataSize::UINT512));
    ocl_wr32(ADDR_TRANSFER_EN, 32'h0);

    pred_out_val = peek_data[31:0];
    $display("[%t] pred_out = %0d (expected %0d)", $realtime, pred_out_val, EXPECTED_PRED);

    if (pred_out_val !== EXPECTED_PRED) begin
      $error("MISMATCH: got %0d, expected %0d", pred_out_val, EXPECTED_PRED);
      error_cnt++;
    end

    tb.power_down();

    if (error_cnt == 0)
      $display("---- TEST PASSED (LSTM pred_out=%0d) ----", pred_out_val);
    else begin
      $display("---- TEST FAILED (%0d errors) ----", error_cnt);
      report_pass_fail_status(0);
    end

    $finish;
  end

endmodule