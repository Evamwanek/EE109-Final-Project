// ============================================================================
// Amazon FPGA Hardware Development Kit
//
// Copyright 2024 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License"). You may not use
// this file except in compliance with the License. A copy of the License is
// located at
//
//    http://aws.amaz_n.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
// implied. See the License for the specific language governing permissions and
// limitations under the License.
// ============================================================================

//====================================================================================
// Top level module file for design_top
//====================================================================================

`include "./concat_top.v"

module design_top
  #(
     parameter EN_DDR = 1,
     parameter EN_HBM = 0
   )
   (
`include "cl_ports.vh"
   );



`include "design_top_defines.vh"
`include "cl_id_defines.vh"
  
  // ---------- AXI-Lite (master side of the reg-slice) to our bridge ----------
  logic [31:0]  axil_awaddr_m;
  logic [5:0]   vadd_axil_awaddr;
  logic         axil_awvalid_m, axil_awready_m;
  logic [31:0]  axil_wdata_m;
  logic [3:0]   axil_wstrb_m;
  logic         axil_wvalid_m, axil_wready_m;
  logic [1:0]   axil_bresp_m;
  logic         axil_bvalid_m, axil_bready_m;

  logic [31:0]  axil_araddr_m;
  logic [5:0]   vadd_axil_araddr;
  logic         axil_arvalid_m, axil_arready_m;
  logic [31:0]  axil_rdata_m;
  logic [1:0]   axil_rresp_m;
  logic         axil_rvalid_m, axil_rready_m;

  // --------------------------------------------------------------------------
  // vadd AXI4 master (gmem0) <-> sh_ddr CL-side AXI connection
  // --------------------------------------------------------------------------
  logic         vadd_m_axi_awvalid, vadd_m_axi_awready;
  logic [63:0]  vadd_m_axi_awaddr;
  logic [0:0]   vadd_m_axi_awid;
  logic [7:0]   vadd_m_axi_awlen;
  logic [2:0]   vadd_m_axi_awsize;
  logic [1:0]   vadd_m_axi_awburst;
  logic [1:0]   vadd_m_axi_awlock;
  logic [3:0]   vadd_m_axi_awcache;
  logic [2:0]   vadd_m_axi_awprot;
  logic [3:0]   vadd_m_axi_awqos;
  logic [3:0]   vadd_m_axi_awregion;
  logic         vadd_m_axi_awuser;

  logic         vadd_m_axi_wvalid, vadd_m_axi_wready;
  logic [31:0]  vadd_m_axi_wdata;
  logic [3:0]   vadd_m_axi_wstrb;
  logic         vadd_m_axi_wlast;
  logic [0:0]   vadd_m_axi_wid;
  logic         vadd_m_axi_wuser;

  logic         vadd_m_axi_arvalid, vadd_m_axi_arready;
  logic [63:0]  vadd_m_axi_araddr;
  logic [0:0]   vadd_m_axi_arid;
  logic [7:0]   vadd_m_axi_arlen;
  logic [2:0]   vadd_m_axi_arsize;
  logic [1:0]   vadd_m_axi_arburst;
  logic [1:0]   vadd_m_axi_arlock;
  logic [3:0]   vadd_m_axi_arcache;
  logic [2:0]   vadd_m_axi_arprot;
  logic [3:0]   vadd_m_axi_arqos;
  logic [3:0]   vadd_m_axi_arregion;
  logic         vadd_m_axi_aruser;

  logic         vadd_m_axi_rvalid, vadd_m_axi_rready;
  logic [31:0]  vadd_m_axi_rdata;
  logic         vadd_m_axi_rlast;
  logic [0:0]   vadd_m_axi_rid;
  logic         vadd_m_axi_ruser;
  logic [1:0]   vadd_m_axi_rresp;

  logic         vadd_m_axi_bvalid, vadd_m_axi_bready;
  logic [1:0]   vadd_m_axi_bresp;
  logic [0:0]   vadd_m_axi_bid;
  logic         vadd_m_axi_buser;

  // --------------------------------------------------------------------------
  // ap_start control: snoop OCL writes to offset 0x00 (reserved in
  // vadd_control_s_axi with ap_ctrl_none).  Auto-clears on ap_done.
  // --------------------------------------------------------------------------
  logic ap_start_reg;
  logic ap_done_w;

  logic [15:0] ocl_aw_addr_q;
  always_ff @(posedge clk_main_a0)
    if (axil_awvalid_m && axil_awready_m)
      ocl_aw_addr_q <= axil_awaddr_m;

  wire ocl_addr_is_start = (axil_awvalid_m && axil_awready_m)
                             ? (axil_awaddr_m[5:0] == 6'h00)
                             : (ocl_aw_addr_q[5:0] == 6'h00);

  always_ff @(posedge clk_main_a0) begin
    if (!rst_main_n) begin  
      ap_start_reg <= 1'b0;
    end else if (ap_done_w) begin
      ap_start_reg <= 1'b0;
    end else if (axil_wvalid_m && axil_wready_m && ocl_addr_is_start) begin
      ap_start_reg <= axil_wdata_m[0];
    end
  end

  // --------------------------------------------------------------------------
  // inline cycle counters
  // --------------------------------------------------------------------------
  logic [31:0] compute_cycles;
  logic [31:0] transfer_cycles;

  wire compute_en = ap_start_reg & ~ap_done_w;

  logic transfer_en;
  wire ocl_addr_is_tx_en = (axil_awvalid_m && axil_awready_m)
                             ? (axil_awaddr_m[15:0] == ADDR_TRANSFER_EN)
                             : (ocl_aw_addr_q[15:0] == ADDR_TRANSFER_EN);

  always_ff @(posedge clk_main_a0) begin
    if (!rst_main_n)
      transfer_en <= 1'b0;
    else if (axil_wvalid_m && axil_wready_m && ocl_addr_is_tx_en)
      transfer_en <= axil_wdata_m[0];
  end

  always_ff @(posedge clk_main_a0) begin
    if (!rst_main_n) begin
      compute_cycles  <= 32'd0;
      transfer_cycles <= 32'd0;
    end else begin
      if (compute_en)  compute_cycles  <= compute_cycles + 1;
      if (transfer_en) transfer_cycles <= transfer_cycles + 1;
    end
  end

  // AXI-Lite read intercept for counter registers
  logic        vadd_s_arready;
  logic        vadd_s_rvalid;
  logic [31:0] vadd_s_rdata;
  logic [1:0]  vadd_s_rresp;

  wire is_counter_addr = (axil_araddr_m[15:0] == ADDR_COMPUTE_CYCLES) |
                         (axil_araddr_m[15:0] == ADDR_TRANSFER_CYCLES);

  logic counter_rd_active;
  logic [31:0] counter_rdata_q;

  always_ff @(posedge clk_main_a0) begin
    if (!rst_main_n) begin
      counter_rd_active <= 1'b0;
      counter_rdata_q   <= 32'd0;
    end else if (axil_arvalid_m && is_counter_addr && !counter_rd_active) begin
      counter_rd_active <= 1'b1;
      if (axil_araddr_m[15:0] == ADDR_COMPUTE_CYCLES)
        counter_rdata_q <= compute_cycles;
      else
        counter_rdata_q <= transfer_cycles;
    end else if (counter_rd_active && axil_rready_m) begin
      counter_rd_active <= 1'b0;
    end
  end

  assign axil_arready_m = is_counter_addr ? ~counter_rd_active : vadd_s_arready;
  assign axil_rvalid_m  = counter_rd_active ? 1'b1 : vadd_s_rvalid;
  assign axil_rdata_m   = counter_rd_active ? counter_rdata_q : vadd_s_rdata;
  assign axil_rresp_m   = counter_rd_active ? 2'b00 : vadd_s_rresp;

  vadd dut (
    .ap_clk(clk_main_a0),
    .ap_rst_n(rst_main_n),
    
    .ap_start(ap_start_reg),
    .ap_done(ap_done_w),
    .ap_idle(),
    .ap_ready(),

    //
    .m_axi_gmem0_AWVALID(vadd_m_axi_awvalid),
    .m_axi_gmem0_AWREADY(vadd_m_axi_awready),
    .m_axi_gmem0_AWADDR(vadd_m_axi_awaddr),
    .m_axi_gmem0_AWID(vadd_m_axi_awid),
    .m_axi_gmem0_AWLEN(vadd_m_axi_awlen),
    .m_axi_gmem0_AWSIZE(vadd_m_axi_awsize),
    .m_axi_gmem0_AWBURST(vadd_m_axi_awburst),
    .m_axi_gmem0_AWLOCK(vadd_m_axi_awlock),
    .m_axi_gmem0_AWCACHE(vadd_m_axi_awcache),
    .m_axi_gmem0_AWPROT(vadd_m_axi_awprot),
    .m_axi_gmem0_AWQOS(vadd_m_axi_awqos),
    .m_axi_gmem0_AWREGION(vadd_m_axi_awregion),
    .m_axi_gmem0_AWUSER(vadd_m_axi_awuser),
    .m_axi_gmem0_WVALID(vadd_m_axi_wvalid),
    .m_axi_gmem0_WREADY(vadd_m_axi_wready),
    .m_axi_gmem0_WDATA(vadd_m_axi_wdata),
    .m_axi_gmem0_WSTRB(vadd_m_axi_wstrb),
    .m_axi_gmem0_WLAST(vadd_m_axi_wlast),
    .m_axi_gmem0_WID(vadd_m_axi_wid),
    .m_axi_gmem0_WUSER(vadd_m_axi_wuser),
    .m_axi_gmem0_ARVALID(vadd_m_axi_arvalid),
    .m_axi_gmem0_ARREADY(vadd_m_axi_arready),
    .m_axi_gmem0_ARADDR(vadd_m_axi_araddr),
    .m_axi_gmem0_ARID(vadd_m_axi_arid),
    .m_axi_gmem0_ARLEN(vadd_m_axi_arlen),
    .m_axi_gmem0_ARSIZE(vadd_m_axi_arsize),
    .m_axi_gmem0_ARBURST(vadd_m_axi_arburst),
    .m_axi_gmem0_ARLOCK(vadd_m_axi_arlock),
    .m_axi_gmem0_ARCACHE(vadd_m_axi_arcache),
    .m_axi_gmem0_ARPROT(vadd_m_axi_arprot),
    .m_axi_gmem0_ARQOS(vadd_m_axi_arqos),
    .m_axi_gmem0_ARREGION(vadd_m_axi_arregion),
    .m_axi_gmem0_ARUSER(vadd_m_axi_aruser),
    .m_axi_gmem0_RVALID(vadd_m_axi_rvalid),
    .m_axi_gmem0_RREADY(vadd_m_axi_rready),
    .m_axi_gmem0_RDATA(vadd_m_axi_rdata),
    .m_axi_gmem0_RLAST(vadd_m_axi_rlast),
    .m_axi_gmem0_RID(vadd_m_axi_rid),
    .m_axi_gmem0_RUSER(vadd_m_axi_ruser),
    .m_axi_gmem0_RRESP(vadd_m_axi_rresp),
    .m_axi_gmem0_BVALID(vadd_m_axi_bvalid),
    .m_axi_gmem0_BREADY(vadd_m_axi_bready),
    .m_axi_gmem0_BRESP(vadd_m_axi_bresp),
    .m_axi_gmem0_BID(vadd_m_axi_bid),
    .m_axi_gmem0_BUSER(vadd_m_axi_buser),

    // 
    .s_axi_control_AWVALID(axil_awvalid_m),
    .s_axi_control_AWREADY(axil_awready_m),
    .s_axi_control_AWADDR(vadd_axil_awaddr),
    .s_axi_control_WVALID(axil_wvalid_m),
    .s_axi_control_WREADY(axil_wready_m),
    .s_axi_control_WDATA(axil_wdata_m),
    .s_axi_control_WSTRB(axil_wstrb_m),
    .s_axi_control_ARVALID(axil_arvalid_m & ~is_counter_addr),
    .s_axi_control_ARREADY(vadd_s_arready),
    .s_axi_control_ARADDR(vadd_axil_araddr),
    .s_axi_control_RVALID(vadd_s_rvalid),
    .s_axi_control_RREADY(axil_rready_m),
    .s_axi_control_RDATA(vadd_s_rdata),
    .s_axi_control_RRESP(vadd_s_rresp),
    .s_axi_control_BVALID(axil_bvalid_m),
    .s_axi_control_BREADY(axil_bready_m),
    .s_axi_control_BRESP(axil_bresp_m)
  );
  ///////// YOUR IMPLEMENTATION ENDS HERE //////////

  //=============================================================================
  // GLOBALS
  //=============================================================================
  always_comb
  begin
    cl_sh_flr_done    = 1'b1;
    cl_sh_status0     = 32'h0;
    cl_sh_status1     = 32'h0;
    cl_sh_status2     = 32'h0;
    cl_sh_id0         = `CL_SH_ID0;
    cl_sh_id1         = `CL_SH_ID1;
    cl_sh_status_vled = 16'h0;
    cl_sh_dma_wr_full = 1'b0;
    cl_sh_dma_rd_full = 1'b0;
  end

  //=============================================================================
  // OCL REGISTER SLICE INSTANCE
  //=============================================================================

  // OCL AXI-Lite Register Slice Connections
  logic [15:0] ocl_awaddr;
  logic        ocl_awvalid;
  logic        ocl_awready;
  logic [31:0] ocl_wdata;
  logic [3:0]  ocl_wstrb;
  logic        ocl_wvalid;
  logic        ocl_wready;
  logic [1:0]  ocl_bresp;
  logic        ocl_bvalid;
  logic        ocl_bready;
  logic [15:0] ocl_araddr;
  logic        ocl_arvalid;
  logic        ocl_arready;
  logic [31:0] ocl_rdata;
  logic [1:0]  ocl_rresp;
  logic        ocl_rvalid;
  logic        ocl_rready;

  // Internal master-side signals from reg-slice to our simple AXI-Lite slave
  logic [2:0]   axil_awprot_m;

  axi_register_slice_light AXIL_OCL_REG_SLC_BOT_SLR (
                             .aclk          (clk_main_a0),
                             .aresetn       (rst_main_n),

                             // Shell → CL (slave port of slice)
                             .s_axi_awaddr  (ocl_cl_awaddr),
                             .s_axi_awprot  ('0),
                             .s_axi_awvalid (ocl_cl_awvalid),
                             .s_axi_awready (cl_ocl_awready),
                             .s_axi_wdata   (ocl_cl_wdata),
                             .s_axi_wstrb   (ocl_cl_wstrb),
                             .s_axi_wvalid  (ocl_cl_wvalid),
                             .s_axi_wready  (cl_ocl_wready),
                             .s_axi_bresp   (cl_ocl_bresp),
                             .s_axi_bvalid  (cl_ocl_bvalid),
                             .s_axi_bready  (ocl_cl_bready),
                             .s_axi_araddr  (ocl_cl_araddr),
                             .s_axi_arprot  ('0),
                             .s_axi_arvalid (ocl_cl_arvalid),
                             .s_axi_arready (cl_ocl_arready),
                             .s_axi_rdata   (cl_ocl_rdata),
                             .s_axi_rresp   (cl_ocl_rresp),
                             .s_axi_rvalid  (cl_ocl_rvalid),
                             .s_axi_rready  (ocl_cl_rready),

                             // CL-internal master side (wire these!)
                             .m_axi_awaddr  (axil_awaddr_m),
                             .m_axi_awprot  (axil_awprot_m),
                             .m_axi_awvalid (axil_awvalid_m),
                             .m_axi_awready (axil_awready_m),
                             .m_axi_wdata   (axil_wdata_m),
                             .m_axi_wstrb   (axil_wstrb_m),
                             .m_axi_wvalid  (axil_wvalid_m),
                             .m_axi_wready  (axil_wready_m),
                             .m_axi_bresp   (axil_bresp_m),
                             .m_axi_bvalid  (axil_bvalid_m),
                             .m_axi_bready  (axil_bready_m),

                             .m_axi_araddr  (axil_araddr_m),
                             .m_axi_arvalid (axil_arvalid_m),
                             .m_axi_arready (axil_arready_m),
                             .m_axi_rdata   (axil_rdata_m),
                             .m_axi_rresp   (axil_rresp_m),
                             .m_axi_rvalid  (axil_rvalid_m),
                             .m_axi_rready  (axil_rready_m)
                           );

  // Bridge AXI-Lite shell-side address width (32-bit) to vadd control port (6-bit)
  assign vadd_axil_awaddr = axil_awaddr_m[5:0];
  assign vadd_axil_araddr = axil_araddr_m[5:0];

  // ==========================================================================
  // vadd 32-bit → 512-bit serializing bridge
  //
  // sh_ddr requires full-width (ARSIZE=6, 512-bit) transactions.  The HLS
  // kernel uses 32-bit AXI (ARSIZE=2).  This bridge converts each vadd
  // burst into a series of independent single-beat (ARLEN=0, ARSIZE=6)
  // DDR transactions, placing/extracting the 32-bit data in the correct
  // byte lane of the 512-bit bus.
  //
  // The bridge presents a standard 512-bit AXI master interface (brg_*)
  // to the arbiter below, so the arbiter is identical to Lab3.
  // ==========================================================================

  // Bridge → arbiter AXI master signals
  logic        brg_awvalid;
  logic        brg_awready;
  logic [63:0] brg_awaddr;

  logic        brg_wvalid;
  logic        brg_wready;
  logic [511:0] brg_wdata;
  logic [63:0]  brg_wstrb;
  logic        brg_wlast;

  logic        brg_bvalid;
  logic        brg_bready;

  logic        brg_arvalid;
  logic        brg_arready;
  logic [63:0] brg_araddr;

  logic        brg_rvalid;
  logic        brg_rready;
  logic [511:0] brg_rdata;
  logic        brg_rlast;

  // ---------- Write bridge ----------
  // State: IDLE → wait for vadd W beats → issue DDR AW+W per beat → BWAIT
  localparam WR_IDLE  = 2'd0;
  localparam WR_DATA  = 2'd1;  // consuming vadd W, issuing DDR AW+W
  localparam WR_BWAIT = 2'd2;  // all DDR writes done, waiting for last B

  logic [1:0]  wr_state;
  logic [63:0] wr_addr;
  logic [7:0]  wr_beats_rem;   // vadd beats remaining (counts down from awlen)
  logic        wr_aw_sent;     // DDR AW sent for current beat (W not yet)
  logic [8:0]  wr_b_count;     // outstanding DDR B responses

  wire [3:0] wr_lane = wr_addr[5:2];

  wire vadd_aw_fire = vadd_m_axi_awvalid & vadd_m_axi_awready;
  wire vadd_w_fire  = vadd_m_axi_wvalid  & vadd_m_axi_wready;
  wire brg_aw_fire  = brg_awvalid & brg_awready;
  wire brg_w_fire   = brg_wvalid  & brg_wready;
  wire brg_b_fire   = brg_bvalid  & brg_bready;

  always_ff @(posedge clk_main_a0) begin
    if (!rst_main_n) begin
      wr_state     <= WR_IDLE;
      wr_addr      <= 64'd0;
      wr_beats_rem <= 8'd0;
      wr_aw_sent   <= 1'b0;
      wr_b_count   <= 9'd0;
    end else begin
      case (wr_state)
        WR_IDLE: begin
          if (vadd_aw_fire) begin
            wr_state     <= WR_DATA;
            wr_addr      <= vadd_m_axi_awaddr;
            wr_beats_rem <= vadd_m_axi_awlen;
            wr_aw_sent   <= 1'b0;
            wr_b_count   <= 9'd0;
          end
        end
        WR_DATA: begin
          if (brg_aw_fire)
            wr_aw_sent <= 1'b1;

          if (brg_w_fire) begin
            wr_aw_sent <= 1'b0;
            wr_addr    <= wr_addr + 64'd4;
            if (wr_beats_rem == 8'd0)
              wr_state <= WR_BWAIT;
            else
              wr_beats_rem <= wr_beats_rem - 8'd1;
          end
        end
        WR_BWAIT: begin
          if (wr_b_count == 9'd0)
            wr_state <= WR_IDLE;
        end
        default: wr_state <= WR_IDLE;
      endcase

      // Track outstanding DDR B responses
      if (brg_w_fire && !brg_b_fire)
        wr_b_count <= wr_b_count + 9'd1;
      else if (!brg_w_fire && brg_b_fire && wr_b_count != 9'd0)
        wr_b_count <= wr_b_count - 9'd1;
    end
  end

  // vadd AW: accept only in IDLE
  assign vadd_m_axi_awready = (wr_state == WR_IDLE);

  // vadd W: accept when DDR W fires (AW already sent or fires same cycle)
  assign vadd_m_axi_wready = (wr_state == WR_DATA) & brg_wready
                             & (wr_aw_sent | brg_awready);

  // vadd B: one B per vadd burst, delivered when all DDR Bs are collected
  assign vadd_m_axi_bvalid = (wr_state == WR_BWAIT) & (wr_b_count == 9'd0);
  assign vadd_m_axi_bid    = 1'b0;
  assign vadd_m_axi_bresp  = 2'b00;
  assign vadd_m_axi_buser  = 1'b0;

  // Bridge AW to DDR: one per vadd W beat, ARLEN=0, ARSIZE=6
  assign brg_awvalid = (wr_state == WR_DATA) & vadd_m_axi_wvalid & ~wr_aw_sent;
  assign brg_awaddr  = {wr_addr[63:6], 6'd0};

  // Bridge W to DDR: one per vadd W beat, data in correct lane
  assign brg_wvalid = (wr_state == WR_DATA) & vadd_m_axi_wvalid
                      & (wr_aw_sent | brg_awready);
  assign brg_wdata  = {480'b0, vadd_m_axi_wdata} << (wr_lane * 32);
  assign brg_wstrb  = {60'b0,  vadd_m_axi_wstrb} << (wr_lane * 4);
  assign brg_wlast  = 1'b1;

  // Bridge B: always accept (just count them)
  assign brg_bready = 1'b1;

  // ---------- Read bridge ----------
  // State: IDLE → AR_ISSUE (issue ARLEN+1 DDR ARs) → R_DRAIN (collect Rs)
  localparam RD_IDLE     = 2'd0;
  localparam RD_AR_ISSUE = 2'd1;
  localparam RD_R_DRAIN  = 2'd2;

  logic [1:0]  rd_state;
  logic [63:0] rd_ar_addr;   // next DDR AR address
  logic [7:0]  rd_ar_rem;    // DDR ARs remaining to issue
  logic [63:0] rd_r_addr;    // address for current R beat (lane extraction)
  logic [7:0]  rd_r_rem;     // R responses remaining

  wire [3:0] rd_lane = rd_r_addr[5:2];

  wire vadd_ar_fire = vadd_m_axi_arvalid & vadd_m_axi_arready;
  wire brg_ar_fire  = brg_arvalid & brg_arready;
  wire vadd_r_fire  = vadd_m_axi_rvalid  & vadd_m_axi_rready;

  always_ff @(posedge clk_main_a0) begin
    if (!rst_main_n) begin
      rd_state   <= RD_IDLE;
      rd_ar_addr <= 64'd0;
      rd_ar_rem  <= 8'd0;
      rd_r_addr  <= 64'd0;
      rd_r_rem   <= 8'd0;
    end else begin
      case (rd_state)
        RD_IDLE: begin
          if (vadd_ar_fire) begin
            rd_state   <= RD_AR_ISSUE;
            rd_ar_addr <= vadd_m_axi_araddr;
            rd_ar_rem  <= vadd_m_axi_arlen;
            rd_r_addr  <= vadd_m_axi_araddr;
            rd_r_rem   <= vadd_m_axi_arlen;
          end
        end
        RD_AR_ISSUE: begin
          if (brg_ar_fire) begin
            rd_ar_addr <= rd_ar_addr + 64'd4;
            if (rd_ar_rem == 8'd0)
              rd_state <= RD_R_DRAIN;
            else
              rd_ar_rem <= rd_ar_rem - 8'd1;
          end

          // Also drain R responses while issuing ARs
          if (vadd_r_fire) begin
            rd_r_addr <= rd_r_addr + 64'd4;
            rd_r_rem  <= rd_r_rem - 8'd1;
          end
        end
        RD_R_DRAIN: begin
          if (vadd_r_fire) begin
            rd_r_addr <= rd_r_addr + 64'd4;
            if (rd_r_rem == 8'd0)
              rd_state <= RD_IDLE;
            else
              rd_r_rem <= rd_r_rem - 8'd1;
          end
        end
        default: rd_state <= RD_IDLE;
      endcase
    end
  end

  // vadd AR: accept only in IDLE
  assign vadd_m_axi_arready = (rd_state == RD_IDLE);

  // vadd R: forward DDR R with lane extraction
  assign vadd_m_axi_rvalid = (rd_state == RD_AR_ISSUE || rd_state == RD_R_DRAIN)
                             & brg_rvalid;
  assign vadd_m_axi_rdata  = brg_rdata[rd_lane*32 +: 32];
  assign vadd_m_axi_rlast  = (rd_r_rem == 8'd0);
  assign vadd_m_axi_rresp  = 2'b00;
  assign vadd_m_axi_rid    = 1'b0;
  assign vadd_m_axi_ruser  = 1'b0;

  // Bridge AR to DDR: one per beat, ARLEN=0, ARSIZE=6
  assign brg_arvalid = (rd_state == RD_AR_ISSUE);
  assign brg_araddr  = {rd_ar_addr[63:6], 6'd0};

  // Bridge R: accept when vadd accepts (backpressure passthrough)
  assign brg_rready = vadd_m_axi_rready
                      & (rd_state == RD_AR_ISSUE || rd_state == RD_R_DRAIN);

  //=============================================================================
  // PCIM
  //=============================================================================

  // Cause Protocol Violations
  always_comb
  begin
    cl_sh_pcim_awaddr  = 'b0;
    cl_sh_pcim_awsize  = 'b0;
    cl_sh_pcim_awburst = 'b0;
    cl_sh_pcim_awvalid = 'b0;

    cl_sh_pcim_wdata   = 'b0;
    cl_sh_pcim_wstrb   = 'b0;
    cl_sh_pcim_wlast   = 'b0;
    cl_sh_pcim_wvalid  = 'b0;

    cl_sh_pcim_araddr  = 'b0;
    cl_sh_pcim_arsize  = 'b0;
    cl_sh_pcim_arburst = 'b0;
    cl_sh_pcim_arvalid = 'b0;
  end

  // Remaining CL Output Ports
  always_comb
  begin
    cl_sh_pcim_awid    = 'b0;
    cl_sh_pcim_awlen   = 'b0;
    cl_sh_pcim_awcache = 'b0;
    cl_sh_pcim_awlock  = 'b0;
    cl_sh_pcim_awprot  = 'b0;
    cl_sh_pcim_awqos   = 'b0;
    cl_sh_pcim_awuser  = 'b0;

    cl_sh_pcim_wid     = 'b0;
    cl_sh_pcim_wuser   = 'b0;

    cl_sh_pcim_arid    = 'b0;
    cl_sh_pcim_arlen   = 'b0;
    cl_sh_pcim_arcache = 'b0;
    cl_sh_pcim_arlock  = 'b0;
    cl_sh_pcim_arprot  = 'b0;
    cl_sh_pcim_arqos   = 'b0;
    cl_sh_pcim_aruser  = 'b0;

    cl_sh_pcim_rready  = 'b0;
  end

  //=============================================================================
  // PCIS — response signals driven by DDR arbiter below
  //=============================================================================

  //=============================================================================
  // SDA
  //=============================================================================

  // Cause Protocol Violations
  always_comb
  begin
    cl_sda_bresp   = 'b0;
    cl_sda_rresp   = 'b0;
    cl_sda_rvalid  = 'b0;
  end

  // Remaining CL Output Ports
  always_comb
  begin
    cl_sda_awready = 'b0;
    cl_sda_wready  = 'b0;

    cl_sda_bvalid = 'b0;

    cl_sda_arready = 'b0;

    cl_sda_rdata   = 'b0;
  end

  //=============================================================================
  // DDR AXI Arbiter: PCIS (host DMA) + vadd → sh_ddr
  //   Host (PCIS) always gets priority. Write and read arbitrated independently.
  //=============================================================================

  // Arbiter output signals (to sh_ddr)
  logic [15:0]  arb_awid;
  logic [63:0]  arb_awaddr;
  logic [7:0]   arb_awlen;
  logic [2:0]   arb_awsize;
  logic [1:0]   arb_awburst;
  logic         arb_awvalid;
  logic         arb_awuser;
  logic         arb_awready;

  logic [511:0] arb_wdata;
  logic [63:0]  arb_wstrb;
  logic         arb_wlast;
  logic         arb_wvalid;
  logic         arb_wready;

  logic [15:0]  arb_bid;
  logic [1:0]   arb_bresp;
  logic         arb_bvalid;
  logic         arb_bready;

  logic [15:0]  arb_arid;
  logic [63:0]  arb_araddr;
  logic [7:0]   arb_arlen;
  logic [2:0]   arb_arsize;
  logic [1:0]   arb_arburst;
  logic         arb_arvalid;
  logic         arb_aruser;
  logic         arb_arready;

  logic [15:0]  arb_rid;
  logic [511:0] arb_rdata;
  logic [1:0]   arb_rresp;
  logic         arb_rlast;
  logic         arb_rvalid;
  logic         arb_rready;

  // Arbitration state — identical to Lab3
  logic wr_locked, rd_locked;
  logic wr_grant_pcis, rd_grant_pcis;

  // Write arbitration: lock on AW valid, unlock on B handshake
  always_ff @(posedge clk_main_a0) begin
    if (!rst_main_n) begin
      wr_locked     <= 1'b0;
      wr_grant_pcis <= 1'b0;
    end else if (!wr_locked) begin
      if (sh_cl_dma_pcis_awvalid) begin
        wr_locked     <= 1'b1;
        wr_grant_pcis <= 1'b1;
      end else if (brg_awvalid) begin
        wr_locked     <= 1'b1;
        wr_grant_pcis <= 1'b0;
      end
    end else if (arb_bvalid && arb_bready) begin
      wr_locked <= 1'b0;
    end
  end

  // Read arbitration: lock on AR valid, unlock on last R beat
  always_ff @(posedge clk_main_a0) begin
    if (!rst_main_n) begin
      rd_locked     <= 1'b0;
      rd_grant_pcis <= 1'b0;
    end else if (!rd_locked) begin
      if (sh_cl_dma_pcis_arvalid) begin
        rd_locked     <= 1'b1;
        rd_grant_pcis <= 1'b1;
      end else if (brg_arvalid) begin
        rd_locked     <= 1'b1;
        rd_grant_pcis <= 1'b0;
      end
    end else if (arb_rvalid && arb_rready && arb_rlast) begin
      rd_locked <= 1'b0;
    end
  end

  // Mux select: when locked use grant, when unlocked use PCIS priority
  wire wr_sel_pcis = wr_locked ? wr_grant_pcis : sh_cl_dma_pcis_awvalid;
  wire rd_sel_pcis = rd_locked ? rd_grant_pcis : sh_cl_dma_pcis_arvalid;

  // AW channel mux — bridge outputs ARLEN=0, ARSIZE=6
  assign arb_awid    = wr_sel_pcis ? sh_cl_dma_pcis_awid    : 16'd0;
  assign arb_awaddr  = wr_sel_pcis ? sh_cl_dma_pcis_awaddr  : brg_awaddr;
  assign arb_awlen   = wr_sel_pcis ? sh_cl_dma_pcis_awlen   : 8'd0;
  assign arb_awsize  = wr_sel_pcis ? sh_cl_dma_pcis_awsize  : 3'd6;
  assign arb_awburst = wr_sel_pcis ? sh_cl_dma_pcis_awburst : 2'b01;
  assign arb_awvalid = wr_sel_pcis ? sh_cl_dma_pcis_awvalid : brg_awvalid;
  assign arb_awuser  = 1'b0;

  // W channel mux — bridge provides 512-bit data with correct lane
  assign arb_wdata  = wr_sel_pcis ? sh_cl_dma_pcis_wdata  : brg_wdata;
  assign arb_wstrb  = wr_sel_pcis ? sh_cl_dma_pcis_wstrb  : brg_wstrb;
  assign arb_wlast  = wr_sel_pcis ? sh_cl_dma_pcis_wlast  : brg_wlast;
  assign arb_wvalid = wr_sel_pcis ? sh_cl_dma_pcis_wvalid  : brg_wvalid;

  // B channel
  assign arb_bready = wr_sel_pcis ? sh_cl_dma_pcis_bready : brg_bready;

  // AR channel mux — bridge outputs ARLEN=0, ARSIZE=6
  assign arb_arid    = rd_sel_pcis ? sh_cl_dma_pcis_arid    : 16'd0;
  assign arb_araddr  = rd_sel_pcis ? sh_cl_dma_pcis_araddr  : brg_araddr;
  assign arb_arlen   = rd_sel_pcis ? sh_cl_dma_pcis_arlen   : 8'd0;
  assign arb_arsize  = rd_sel_pcis ? sh_cl_dma_pcis_arsize  : 3'd6;
  assign arb_arburst = rd_sel_pcis ? sh_cl_dma_pcis_arburst : 2'b01;
  assign arb_arvalid = rd_sel_pcis ? sh_cl_dma_pcis_arvalid : brg_arvalid;
  assign arb_aruser  = 1'b0;

  // R channel
  assign arb_rready = rd_sel_pcis ? sh_cl_dma_pcis_rready : brg_rready;

  // --- Route responses back to PCIS ---
  assign cl_sh_dma_pcis_awready =  wr_sel_pcis & arb_awready;
  assign cl_sh_dma_pcis_wready  =  wr_sel_pcis & arb_wready;
  assign cl_sh_dma_pcis_bid     = arb_bid;
  assign cl_sh_dma_pcis_bresp   = arb_bresp;
  assign cl_sh_dma_pcis_bvalid  =  wr_sel_pcis & arb_bvalid;

  assign cl_sh_dma_pcis_arready =  rd_sel_pcis & arb_arready;
  assign cl_sh_dma_pcis_rid     = arb_rid;
  assign cl_sh_dma_pcis_rdata   = arb_rdata;
  assign cl_sh_dma_pcis_rresp   = arb_rresp;
  assign cl_sh_dma_pcis_rlast   = arb_rlast;
  assign cl_sh_dma_pcis_rvalid  =  rd_sel_pcis & arb_rvalid;
  assign cl_sh_dma_pcis_ruser   = '0;

  // --- Route DDR responses back to bridge ---
  assign brg_awready = ~wr_sel_pcis & arb_awready;
  assign brg_wready  = ~wr_sel_pcis & arb_wready;
  assign brg_bvalid  = ~wr_sel_pcis & arb_bvalid;

  assign brg_arready = ~rd_sel_pcis & arb_arready;
  assign brg_rvalid  = ~rd_sel_pcis & arb_rvalid;
  assign brg_rdata   = arb_rdata;
  assign brg_rlast   = arb_rlast;

  //=============================================================================
  // SH_DDR
  //=============================================================================

  logic ddr_ready;

  sh_ddr
    #(
      .DDR_PRESENT (EN_DDR)
    )
    SH_DDR
    (
      .clk                       (clk_main_a0 ),
      .rst_n                     (rst_main_n  ),
      .stat_clk                  (clk_main_a0 ),
      .stat_rst_n                (rst_main_n  ),

      .CLK_DIMM_DP               (CLK_DIMM_DP ),
      .CLK_DIMM_DN               (CLK_DIMM_DN ),
      .M_ACT_N                   (M_ACT_N     ),
      .M_MA                      (M_MA        ),
      .M_BA                      (M_BA        ),
      .M_BG                      (M_BG        ),
      .M_CKE                     (M_CKE       ),
      .M_ODT                     (M_ODT       ),
      .M_CS_N                    (M_CS_N      ),
      .M_CLK_DN                  (M_CLK_DN    ),
      .M_CLK_DP                  (M_CLK_DP    ),
      .M_PAR                     (M_PAR       ),
      .M_DQ                      (M_DQ        ),
      .M_ECC                     (M_ECC       ),
      .M_DQS_DP                  (M_DQS_DP    ),
      .M_DQS_DN                  (M_DQS_DN    ),
      .cl_RST_DIMM_N             (RST_DIMM_N  ),

      .cl_sh_ddr_axi_awid        (arb_awid),
      .cl_sh_ddr_axi_awaddr      (arb_awaddr),
      .cl_sh_ddr_axi_awlen       (arb_awlen),
      .cl_sh_ddr_axi_awsize      (arb_awsize),
      .cl_sh_ddr_axi_awvalid     (arb_awvalid),
      .cl_sh_ddr_axi_awburst     (arb_awburst),
      .cl_sh_ddr_axi_awuser      (arb_awuser),
      .cl_sh_ddr_axi_awready     (arb_awready),
      .cl_sh_ddr_axi_wdata       (arb_wdata),
      .cl_sh_ddr_axi_wstrb       (arb_wstrb),
      .cl_sh_ddr_axi_wlast       (arb_wlast),
      .cl_sh_ddr_axi_wvalid      (arb_wvalid),
      .cl_sh_ddr_axi_wready      (arb_wready),
      .cl_sh_ddr_axi_bid         (arb_bid),
      .cl_sh_ddr_axi_bresp       (arb_bresp),
      .cl_sh_ddr_axi_bvalid      (arb_bvalid),
      .cl_sh_ddr_axi_bready      (arb_bready),
      .cl_sh_ddr_axi_arid        (arb_arid),
      .cl_sh_ddr_axi_araddr      (arb_araddr),
      .cl_sh_ddr_axi_arlen       (arb_arlen),
      .cl_sh_ddr_axi_arsize      (arb_arsize),
      .cl_sh_ddr_axi_arvalid     (arb_arvalid),
      .cl_sh_ddr_axi_arburst     (arb_arburst),
      .cl_sh_ddr_axi_aruser      (arb_aruser),
      .cl_sh_ddr_axi_arready     (arb_arready),
      .cl_sh_ddr_axi_rid         (arb_rid),
      .cl_sh_ddr_axi_rdata       (arb_rdata),
      .cl_sh_ddr_axi_rresp       (arb_rresp),
      .cl_sh_ddr_axi_rlast       (arb_rlast),
      .cl_sh_ddr_axi_rvalid      (arb_rvalid),
      .cl_sh_ddr_axi_rready      (arb_rready),
      .sh_ddr_stat_bus_addr      (sh_cl_ddr_stat_addr),
      .sh_ddr_stat_bus_wdata     (sh_cl_ddr_stat_wdata),
      .sh_ddr_stat_bus_wr        (sh_cl_ddr_stat_wr),
      .sh_ddr_stat_bus_rd        (sh_cl_ddr_stat_rd),
      .sh_ddr_stat_bus_ack       (cl_sh_ddr_stat_ack),
      .sh_ddr_stat_bus_rdata     (cl_sh_ddr_stat_rdata),
      .ddr_sh_stat_int           (cl_sh_ddr_stat_int),
      .sh_cl_ddr_is_ready        (ddr_ready)
    );

  // always_comb
  // begin
  //   cl_sh_ddr_stat_ack   = 'b0;
  //   cl_sh_ddr_stat_rdata = 'b0;
  //   cl_sh_ddr_stat_int   = 'b0;
  // end

  //=============================================================================
  // USER-DEFIEND INTERRUPTS
  //=============================================================================

  always_comb
  begin
    cl_sh_apppf_irq_req = 'b0;
  end

  //=============================================================================
  // VIRTUAL JTAG
  //=============================================================================

  always_comb
  begin
    tdo = 'b0;
  end

  //=============================================================================
  // HBM MONITOR IO
  //=============================================================================

  always_comb
  begin
    hbm_apb_paddr_1   = 'b0;
    hbm_apb_pprot_1   = 'b0;
    hbm_apb_psel_1    = 'b0;
    hbm_apb_penable_1 = 'b0;
    hbm_apb_pwrite_1  = 'b0;
    hbm_apb_pwdata_1  = 'b0;
    hbm_apb_pstrb_1   = 'b0;
    hbm_apb_pready_1  = 'b0;
    hbm_apb_prdata_1  = 'b0;
    hbm_apb_pslverr_1 = 'b0;

    hbm_apb_paddr_0   = 'b0;
    hbm_apb_pprot_0   = 'b0;
    hbm_apb_psel_0    = 'b0;
    hbm_apb_penable_0 = 'b0;
    hbm_apb_pwrite_0  = 'b0;
    hbm_apb_pwdata_0  = 'b0;
    hbm_apb_pstrb_0   = 'b0;
    hbm_apb_pready_0  = 'b0;
    hbm_apb_prdata_0  = 'b0;
    hbm_apb_pslverr_0 = 'b0;
  end

  //=============================================================================
  //
  //=============================================================================

  always_comb
  begin
    PCIE_EP_TXP    = 'b0;
    PCIE_EP_TXN    = 'b0;

    PCIE_RP_PERSTN = 'b0;
    PCIE_RP_TXP    = 'b0;
    PCIE_RP_TXN    = 'b0;
  end

endmodule // design_top