// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.1 (64-bit)
// Tool Version Limit: 2024.05
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
`timescale 1ns/1ps
module vadd_control_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 8,
    C_S_AXI_DATA_WIDTH = 32
)(
    input  wire                          ACLK,
    input  wire                          ARESET,
    input  wire                          ACLK_EN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] AWADDR,
    input  wire                          AWVALID,
    output wire                          AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB,
    input  wire                          WVALID,
    output wire                          WREADY,
    output wire [1:0]                    BRESP,
    output wire                          BVALID,
    input  wire                          BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                          ARVALID,
    output wire                          ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1:0] RDATA,
    output wire [1:0]                    RRESP,
    output wire                          RVALID,
    input  wire                          RREADY,
    output wire [63:0]                   input_seq,
    output wire [63:0]                   wih0,
    output wire [63:0]                   whh0,
    output wire [63:0]                   bih0,
    output wire [63:0]                   bhh0,
    output wire [63:0]                   wih1,
    output wire [63:0]                   whh1,
    output wire [63:0]                   bih1,
    output wire [63:0]                   bhh1,
    output wire [63:0]                   wfc,
    output wire [63:0]                   bfc,
    output wire [63:0]                   pred_out
);
//------------------------Address Info-------------------
// Protocol Used: ap_ctrl_none
//
// 0x00 : reserved
// 0x04 : reserved
// 0x08 : reserved
// 0x0c : reserved
// 0x10 : Data signal of input_seq
//        bit 31~0 - input_seq[31:0] (Read/Write)
// 0x14 : Data signal of input_seq
//        bit 31~0 - input_seq[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of wih0
//        bit 31~0 - wih0[31:0] (Read/Write)
// 0x20 : Data signal of wih0
//        bit 31~0 - wih0[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of whh0
//        bit 31~0 - whh0[31:0] (Read/Write)
// 0x2c : Data signal of whh0
//        bit 31~0 - whh0[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of bih0
//        bit 31~0 - bih0[31:0] (Read/Write)
// 0x38 : Data signal of bih0
//        bit 31~0 - bih0[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of bhh0
//        bit 31~0 - bhh0[31:0] (Read/Write)
// 0x44 : Data signal of bhh0
//        bit 31~0 - bhh0[63:32] (Read/Write)
// 0x48 : reserved
// 0x4c : Data signal of wih1
//        bit 31~0 - wih1[31:0] (Read/Write)
// 0x50 : Data signal of wih1
//        bit 31~0 - wih1[63:32] (Read/Write)
// 0x54 : reserved
// 0x58 : Data signal of whh1
//        bit 31~0 - whh1[31:0] (Read/Write)
// 0x5c : Data signal of whh1
//        bit 31~0 - whh1[63:32] (Read/Write)
// 0x60 : reserved
// 0x64 : Data signal of bih1
//        bit 31~0 - bih1[31:0] (Read/Write)
// 0x68 : Data signal of bih1
//        bit 31~0 - bih1[63:32] (Read/Write)
// 0x6c : reserved
// 0x70 : Data signal of bhh1
//        bit 31~0 - bhh1[31:0] (Read/Write)
// 0x74 : Data signal of bhh1
//        bit 31~0 - bhh1[63:32] (Read/Write)
// 0x78 : reserved
// 0x7c : Data signal of wfc
//        bit 31~0 - wfc[31:0] (Read/Write)
// 0x80 : Data signal of wfc
//        bit 31~0 - wfc[63:32] (Read/Write)
// 0x84 : reserved
// 0x88 : Data signal of bfc
//        bit 31~0 - bfc[31:0] (Read/Write)
// 0x8c : Data signal of bfc
//        bit 31~0 - bfc[63:32] (Read/Write)
// 0x90 : reserved
// 0x94 : Data signal of pred_out
//        bit 31~0 - pred_out[31:0] (Read/Write)
// 0x98 : Data signal of pred_out
//        bit 31~0 - pred_out[63:32] (Read/Write)
// 0x9c : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
    ADDR_INPUT_SEQ_DATA_0 = 8'h10,
    ADDR_INPUT_SEQ_DATA_1 = 8'h14,
    ADDR_INPUT_SEQ_CTRL   = 8'h18,
    ADDR_WIH0_DATA_0      = 8'h1c,
    ADDR_WIH0_DATA_1      = 8'h20,
    ADDR_WIH0_CTRL        = 8'h24,
    ADDR_WHH0_DATA_0      = 8'h28,
    ADDR_WHH0_DATA_1      = 8'h2c,
    ADDR_WHH0_CTRL        = 8'h30,
    ADDR_BIH0_DATA_0      = 8'h34,
    ADDR_BIH0_DATA_1      = 8'h38,
    ADDR_BIH0_CTRL        = 8'h3c,
    ADDR_BHH0_DATA_0      = 8'h40,
    ADDR_BHH0_DATA_1      = 8'h44,
    ADDR_BHH0_CTRL        = 8'h48,
    ADDR_WIH1_DATA_0      = 8'h4c,
    ADDR_WIH1_DATA_1      = 8'h50,
    ADDR_WIH1_CTRL        = 8'h54,
    ADDR_WHH1_DATA_0      = 8'h58,
    ADDR_WHH1_DATA_1      = 8'h5c,
    ADDR_WHH1_CTRL        = 8'h60,
    ADDR_BIH1_DATA_0      = 8'h64,
    ADDR_BIH1_DATA_1      = 8'h68,
    ADDR_BIH1_CTRL        = 8'h6c,
    ADDR_BHH1_DATA_0      = 8'h70,
    ADDR_BHH1_DATA_1      = 8'h74,
    ADDR_BHH1_CTRL        = 8'h78,
    ADDR_WFC_DATA_0       = 8'h7c,
    ADDR_WFC_DATA_1       = 8'h80,
    ADDR_WFC_CTRL         = 8'h84,
    ADDR_BFC_DATA_0       = 8'h88,
    ADDR_BFC_DATA_1       = 8'h8c,
    ADDR_BFC_CTRL         = 8'h90,
    ADDR_PRED_OUT_DATA_0  = 8'h94,
    ADDR_PRED_OUT_DATA_1  = 8'h98,
    ADDR_PRED_OUT_CTRL    = 8'h9c,
    WRIDLE                = 2'd0,
    WRDATA                = 2'd1,
    WRRESP                = 2'd2,
    WRRESET               = 2'd3,
    RDIDLE                = 2'd0,
    RDDATA                = 2'd1,
    RDRESET               = 2'd2,
    ADDR_BITS                = 8;

//------------------------Local signal-------------------
    reg  [1:0]                    wstate = WRRESET;
    reg  [1:0]                    wnext;
    reg  [ADDR_BITS-1:0]          waddr;
    wire [C_S_AXI_DATA_WIDTH-1:0] wmask;
    wire                          aw_hs;
    wire                          w_hs;
    reg  [1:0]                    rstate = RDRESET;
    reg  [1:0]                    rnext;
    reg  [C_S_AXI_DATA_WIDTH-1:0] rdata;
    wire                          ar_hs;
    wire [ADDR_BITS-1:0]          raddr;
    // internal registers
    reg  [63:0]                   int_input_seq = 'b0;
    reg  [63:0]                   int_wih0 = 'b0;
    reg  [63:0]                   int_whh0 = 'b0;
    reg  [63:0]                   int_bih0 = 'b0;
    reg  [63:0]                   int_bhh0 = 'b0;
    reg  [63:0]                   int_wih1 = 'b0;
    reg  [63:0]                   int_whh1 = 'b0;
    reg  [63:0]                   int_bih1 = 'b0;
    reg  [63:0]                   int_bhh1 = 'b0;
    reg  [63:0]                   int_wfc = 'b0;
    reg  [63:0]                   int_bfc = 'b0;
    reg  [63:0]                   int_pred_out = 'b0;

//------------------------Instantiation------------------


//------------------------AXI write fsm------------------
assign AWREADY = (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA);
assign BRESP   = 2'b00;  // OKAY
assign BVALID  = (wstate == WRRESP);
assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK) begin
    if (ARESET)
        wstate <= WRRESET;
    else if (ACLK_EN)
        wstate <= wnext;
end

// wnext
always @(*) begin
    case (wstate)
        WRIDLE:
            if (AWVALID)
                wnext = WRDATA;
            else
                wnext = WRIDLE;
        WRDATA:
            if (WVALID)
                wnext = WRRESP;
            else
                wnext = WRDATA;
        WRRESP:
            if (BREADY)
                wnext = WRIDLE;
            else
                wnext = WRRESP;
        default:
            wnext = WRIDLE;
    endcase
end

// waddr
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (aw_hs)
            waddr <= {AWADDR[ADDR_BITS-1:2], {2{1'b0}}};
    end
end

//------------------------AXI read fsm-------------------
assign ARREADY = (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA);
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK) begin
    if (ARESET)
        rstate <= RDRESET;
    else if (ACLK_EN)
        rstate <= rnext;
end

// rnext
always @(*) begin
    case (rstate)
        RDIDLE:
            if (ARVALID)
                rnext = RDDATA;
            else
                rnext = RDIDLE;
        RDDATA:
            if (RREADY & RVALID)
                rnext = RDIDLE;
            else
                rnext = RDDATA;
        default:
            rnext = RDIDLE;
    endcase
end

// rdata
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (ar_hs) begin
            rdata <= 'b0;
            case (raddr)
                ADDR_INPUT_SEQ_DATA_0: begin
                    rdata <= int_input_seq[31:0];
                end
                ADDR_INPUT_SEQ_DATA_1: begin
                    rdata <= int_input_seq[63:32];
                end
                ADDR_WIH0_DATA_0: begin
                    rdata <= int_wih0[31:0];
                end
                ADDR_WIH0_DATA_1: begin
                    rdata <= int_wih0[63:32];
                end
                ADDR_WHH0_DATA_0: begin
                    rdata <= int_whh0[31:0];
                end
                ADDR_WHH0_DATA_1: begin
                    rdata <= int_whh0[63:32];
                end
                ADDR_BIH0_DATA_0: begin
                    rdata <= int_bih0[31:0];
                end
                ADDR_BIH0_DATA_1: begin
                    rdata <= int_bih0[63:32];
                end
                ADDR_BHH0_DATA_0: begin
                    rdata <= int_bhh0[31:0];
                end
                ADDR_BHH0_DATA_1: begin
                    rdata <= int_bhh0[63:32];
                end
                ADDR_WIH1_DATA_0: begin
                    rdata <= int_wih1[31:0];
                end
                ADDR_WIH1_DATA_1: begin
                    rdata <= int_wih1[63:32];
                end
                ADDR_WHH1_DATA_0: begin
                    rdata <= int_whh1[31:0];
                end
                ADDR_WHH1_DATA_1: begin
                    rdata <= int_whh1[63:32];
                end
                ADDR_BIH1_DATA_0: begin
                    rdata <= int_bih1[31:0];
                end
                ADDR_BIH1_DATA_1: begin
                    rdata <= int_bih1[63:32];
                end
                ADDR_BHH1_DATA_0: begin
                    rdata <= int_bhh1[31:0];
                end
                ADDR_BHH1_DATA_1: begin
                    rdata <= int_bhh1[63:32];
                end
                ADDR_WFC_DATA_0: begin
                    rdata <= int_wfc[31:0];
                end
                ADDR_WFC_DATA_1: begin
                    rdata <= int_wfc[63:32];
                end
                ADDR_BFC_DATA_0: begin
                    rdata <= int_bfc[31:0];
                end
                ADDR_BFC_DATA_1: begin
                    rdata <= int_bfc[63:32];
                end
                ADDR_PRED_OUT_DATA_0: begin
                    rdata <= int_pred_out[31:0];
                end
                ADDR_PRED_OUT_DATA_1: begin
                    rdata <= int_pred_out[63:32];
                end
            endcase
        end
    end
end


//------------------------Register logic-----------------
assign input_seq = int_input_seq;
assign wih0      = int_wih0;
assign whh0      = int_whh0;
assign bih0      = int_bih0;
assign bhh0      = int_bhh0;
assign wih1      = int_wih1;
assign whh1      = int_whh1;
assign bih1      = int_bih1;
assign bhh1      = int_bhh1;
assign wfc       = int_wfc;
assign bfc       = int_bfc;
assign pred_out  = int_pred_out;
// int_input_seq[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_input_seq[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_INPUT_SEQ_DATA_0)
            int_input_seq[31:0] <= (WDATA[31:0] & wmask) | (int_input_seq[31:0] & ~wmask);
    end
end

// int_input_seq[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_input_seq[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_INPUT_SEQ_DATA_1)
            int_input_seq[63:32] <= (WDATA[31:0] & wmask) | (int_input_seq[63:32] & ~wmask);
    end
end

// int_wih0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_wih0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WIH0_DATA_0)
            int_wih0[31:0] <= (WDATA[31:0] & wmask) | (int_wih0[31:0] & ~wmask);
    end
end

// int_wih0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_wih0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WIH0_DATA_1)
            int_wih0[63:32] <= (WDATA[31:0] & wmask) | (int_wih0[63:32] & ~wmask);
    end
end

// int_whh0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_whh0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WHH0_DATA_0)
            int_whh0[31:0] <= (WDATA[31:0] & wmask) | (int_whh0[31:0] & ~wmask);
    end
end

// int_whh0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_whh0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WHH0_DATA_1)
            int_whh0[63:32] <= (WDATA[31:0] & wmask) | (int_whh0[63:32] & ~wmask);
    end
end

// int_bih0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_bih0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BIH0_DATA_0)
            int_bih0[31:0] <= (WDATA[31:0] & wmask) | (int_bih0[31:0] & ~wmask);
    end
end

// int_bih0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_bih0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BIH0_DATA_1)
            int_bih0[63:32] <= (WDATA[31:0] & wmask) | (int_bih0[63:32] & ~wmask);
    end
end

// int_bhh0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_bhh0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BHH0_DATA_0)
            int_bhh0[31:0] <= (WDATA[31:0] & wmask) | (int_bhh0[31:0] & ~wmask);
    end
end

// int_bhh0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_bhh0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BHH0_DATA_1)
            int_bhh0[63:32] <= (WDATA[31:0] & wmask) | (int_bhh0[63:32] & ~wmask);
    end
end

// int_wih1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_wih1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WIH1_DATA_0)
            int_wih1[31:0] <= (WDATA[31:0] & wmask) | (int_wih1[31:0] & ~wmask);
    end
end

// int_wih1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_wih1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WIH1_DATA_1)
            int_wih1[63:32] <= (WDATA[31:0] & wmask) | (int_wih1[63:32] & ~wmask);
    end
end

// int_whh1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_whh1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WHH1_DATA_0)
            int_whh1[31:0] <= (WDATA[31:0] & wmask) | (int_whh1[31:0] & ~wmask);
    end
end

// int_whh1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_whh1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WHH1_DATA_1)
            int_whh1[63:32] <= (WDATA[31:0] & wmask) | (int_whh1[63:32] & ~wmask);
    end
end

// int_bih1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_bih1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BIH1_DATA_0)
            int_bih1[31:0] <= (WDATA[31:0] & wmask) | (int_bih1[31:0] & ~wmask);
    end
end

// int_bih1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_bih1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BIH1_DATA_1)
            int_bih1[63:32] <= (WDATA[31:0] & wmask) | (int_bih1[63:32] & ~wmask);
    end
end

// int_bhh1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_bhh1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BHH1_DATA_0)
            int_bhh1[31:0] <= (WDATA[31:0] & wmask) | (int_bhh1[31:0] & ~wmask);
    end
end

// int_bhh1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_bhh1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BHH1_DATA_1)
            int_bhh1[63:32] <= (WDATA[31:0] & wmask) | (int_bhh1[63:32] & ~wmask);
    end
end

// int_wfc[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_wfc[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WFC_DATA_0)
            int_wfc[31:0] <= (WDATA[31:0] & wmask) | (int_wfc[31:0] & ~wmask);
    end
end

// int_wfc[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_wfc[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WFC_DATA_1)
            int_wfc[63:32] <= (WDATA[31:0] & wmask) | (int_wfc[63:32] & ~wmask);
    end
end

// int_bfc[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_bfc[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BFC_DATA_0)
            int_bfc[31:0] <= (WDATA[31:0] & wmask) | (int_bfc[31:0] & ~wmask);
    end
end

// int_bfc[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_bfc[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BFC_DATA_1)
            int_bfc[63:32] <= (WDATA[31:0] & wmask) | (int_bfc[63:32] & ~wmask);
    end
end

// int_pred_out[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_pred_out[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_PRED_OUT_DATA_0)
            int_pred_out[31:0] <= (WDATA[31:0] & wmask) | (int_pred_out[31:0] & ~wmask);
    end
end

// int_pred_out[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_pred_out[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_PRED_OUT_DATA_1)
            int_pred_out[63:32] <= (WDATA[31:0] & wmask) | (int_pred_out[63:32] & ~wmask);
    end
end


//------------------------Memory logic-------------------

endmodule

// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.1 (64-bit)
// Tool Version Limit: 2024.05
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================

`timescale 1 ns / 1 ps

module vadd_flow_control_loop_pipe_sequential_init(
        ap_clk,
        ap_rst,
        ap_start,
        ap_ready,
        ap_done,
        ap_start_int,
        ap_ready_int,
        ap_done_int,
        ap_continue_int,
        ap_loop_init,
        ap_loop_exit_ready,
        ap_loop_exit_done
);

input   ap_clk;
input   ap_rst;

//Block level handshake with outside loop
input   ap_start;
output  ap_ready;
output  ap_done;

//Block level handshake with loop body
output  ap_start_int;
input   ap_ready_int;
input   ap_done_int;
output  ap_continue_int;

//Init live in variables
output   ap_loop_init;
wire     ap_loop_init;
reg ap_loop_init_int;
reg ap_done;
reg ap_done_cache;

//Exit signal from loop body
input   ap_loop_exit_ready;
input   ap_loop_exit_done;

// power-on initialization
initial begin
#0 ap_loop_init_int = 1'b1;
#0 ap_done_cache = 1'b0;
end

assign ap_start_int = ap_start;

assign ap_continue_int = 1'b1;

assign ap_ready = ap_loop_exit_ready;

//ap_loop_init is valid for the first II
//of the first loop run so as to enable
//the init block ops which are pushed into
//the first state of the pipeline region
always @ (posedge ap_clk)
begin
    if (ap_rst == 1'b1) begin
        ap_loop_init_int <= 1'b1;
    end else if(ap_loop_exit_done == 1'b1) begin
        ap_loop_init_int <= 1'b1;
    end else if(ap_ready_int == 1'b1) begin
        ap_loop_init_int <= 1'b0;
    end
end

assign ap_loop_init = ap_loop_init_int & ap_start;

// if no ap_continue port and current module is not top module, 
// ap_done handshakes with ap_start. Internally, flow control sends out 
// ap_conintue_int = 1'b1 so the ap_done_int is asserted high for 1 clock cycle.
// ap_done_cache is used to record ap_done_int, and de-assert if ap_start_int
// is asserted, so DUT can start the next run
always @(posedge ap_clk)
begin
    if (ap_rst == 1'b1) begin
        ap_done_cache <= 1'b0;
    end else if (ap_done_int == 1'b1) begin
        ap_done_cache <= 1'b1;
    end else if (ap_start_int == 1'b1) begin
        ap_done_cache <= 1'b0;
    end
end

// if no ap_continue port and current module is not top module, ap_done handshakes with ap_start
always @(*)
begin
    if ((ap_done_int == 1'b1) || ((ap_done_cache == 1'b1) && (ap_start_int == 1'b0))) begin
        ap_done = 1'b1;
    end else begin
        ap_done = 1'b0;
    end
end

endmodule
        

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================
// 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689

`timescale 1ns/1ps
`default_nettype none




module vadd_gmem0_m_axi
#(parameter
    CONSERVATIVE            = 0,
    MAX_READ_BURST_LENGTH   = 16,
    MAX_WRITE_BURST_LENGTH  = 16,
    C_M_AXI_ID_WIDTH        = 1,
    C_M_AXI_ADDR_WIDTH      = 32,
    C_M_AXI_DATA_WIDTH      = 32, // power of 2 & range: 2 to 1024
    C_M_AXI_AWUSER_WIDTH    = 1,
    C_M_AXI_ARUSER_WIDTH    = 1,
    C_M_AXI_WUSER_WIDTH     = 1,
    C_M_AXI_RUSER_WIDTH     = 1,
    C_M_AXI_BUSER_WIDTH     = 1,
    C_TARGET_ADDR           = 32'h00000000,
    C_USER_VALUE            = 1'b0,
    C_PROT_VALUE            = 3'b000,
    C_CACHE_VALUE           = 4'b0011,
    CH0_USER_DW             = 32, // multiple of 8
    CH0_USER_AW             = 32,
    NUM_READ_OUTSTANDING    = 2,
    NUM_WRITE_OUTSTANDING   = 2,
    CH0_USER_RFIFONUM_WIDTH = 6,
    USER_MAXREQS            = 16,
    MAXI_BUFFER_IMPL        = "block"
)(
    
    
    // system signal
    input  wire                               ACLK,
    input  wire                               ARESET,
    input  wire                               ACLK_EN,
    // write address channel
    output wire [C_M_AXI_ID_WIDTH-1:0]        AWID,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]      AWADDR,
    output wire [7:0]                         AWLEN,
    output wire [2:0]                         AWSIZE,
    output wire [1:0]                         AWBURST,
    output wire [1:0]                         AWLOCK,
    output wire [3:0]                         AWCACHE,
    output wire [2:0]                         AWPROT,
    output wire [3:0]                         AWQOS,
    output wire [3:0]                         AWREGION,
    output wire [C_M_AXI_AWUSER_WIDTH-1:0]    AWUSER,
    output wire                               AWVALID,
    input  wire                               AWREADY,
    // write data channel
    output wire [C_M_AXI_ID_WIDTH-1:0]        WID,
    output wire [C_M_AXI_DATA_WIDTH-1:0]      WDATA,
    output wire [C_M_AXI_DATA_WIDTH/8-1:0]    WSTRB,
    output wire                               WLAST,
    output wire [C_M_AXI_WUSER_WIDTH-1:0]     WUSER,
    output wire                               WVALID,
    input  wire                               WREADY,
    // write response channel
    input  wire [C_M_AXI_ID_WIDTH-1:0]        BID,
    input  wire [1:0]                         BRESP,
    input  wire [C_M_AXI_BUSER_WIDTH-1:0]     BUSER,
    input  wire                               BVALID,
    output wire                               BREADY,
    // read address channel
    output wire [C_M_AXI_ID_WIDTH-1:0]        ARID,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]      ARADDR,
    output wire [7:0]                         ARLEN,
    output wire [2:0]                         ARSIZE,
    output wire [1:0]                         ARBURST,
    output wire [1:0]                         ARLOCK,
    output wire [3:0]                         ARCACHE,
    output wire [2:0]                         ARPROT,
    output wire [3:0]                         ARQOS,
    output wire [3:0]                         ARREGION,
    output wire [C_M_AXI_ARUSER_WIDTH-1:0]    ARUSER,
    output wire                               ARVALID,
    input  wire                               ARREADY,
    // read data channel
    input  wire [C_M_AXI_ID_WIDTH-1:0]        RID,
    input  wire [C_M_AXI_DATA_WIDTH-1:0]      RDATA,
    input  wire [1:0]                         RRESP,
    input  wire                               RLAST,
    input  wire [C_M_AXI_RUSER_WIDTH-1:0]     RUSER,
    input  wire                               RVALID,
    output wire                               RREADY,

    // internal bus ports
    // write address
    input  wire [CH0_USER_AW-1:0]             I_CH0_AWADDR,
    input  wire [31:0]                        I_CH0_AWLEN,
    input  wire                               I_CH0_AWVALID,
    output wire                               I_CH0_AWREADY,
    // write data
    input  wire [CH0_USER_DW-1:0]             I_CH0_WDATA,
    input  wire [CH0_USER_DW/8-1:0]           I_CH0_WSTRB,
    input  wire                               I_CH0_WVALID,
    output wire                               I_CH0_WREADY,
    // write response
    output wire                               I_CH0_BVALID,
    input  wire                               I_CH0_BREADY,
    // read address
    input  wire [CH0_USER_AW-1:0]             I_CH0_ARADDR,
    input  wire [31:0]                        I_CH0_ARLEN,
    input  wire                               I_CH0_ARVALID,
    output wire                               I_CH0_ARREADY,
    // read data
    output wire [CH0_USER_DW-1:0]             I_CH0_RDATA,
    output wire                               I_CH0_RVALID,
    input  wire                               I_CH0_RREADY,
    output wire [CH0_USER_RFIFONUM_WIDTH-1:0] I_CH0_RFIFONUM);
//------------------------Local signal-------------------

    wire [C_M_AXI_ADDR_WIDTH-1:0]   AWADDR_Dummy;
    wire [31:0]                     AWLEN_Dummy;
    wire                            AWVALID_Dummy;
    wire                            AWREADY_Dummy;
    wire [C_M_AXI_DATA_WIDTH-1:0]   WDATA_Dummy;
    wire [C_M_AXI_DATA_WIDTH/8-1:0] WSTRB_Dummy;
    wire                            WVALID_Dummy;
    wire                            WREADY_Dummy;
    wire                            BVALID_Dummy;
    wire                            BREADY_Dummy;
    wire [C_M_AXI_ADDR_WIDTH-1:0]   ARADDR_Dummy;
    wire [31:0]                     ARLEN_Dummy;
    wire                            ARVALID_Dummy;
    wire                            ARREADY_Dummy;
    wire [C_M_AXI_DATA_WIDTH-1:0]   RDATA_Dummy;
    wire [1:0]                      RLAST_Dummy;
    wire                            RVALID_Dummy;
    wire                            RREADY_Dummy;
    wire                            RBURST_READY_Dummy;
    
//------------------------Instantiation------------------
    // vadd_gmem0_m_axi_store
    vadd_gmem0_m_axi_store #(
        .C_TARGET_ADDR           ( C_TARGET_ADDR ),
        .NUM_WRITE_OUTSTANDING   ( NUM_WRITE_OUTSTANDING ),
        .MAX_WRITE_BURST_LENGTH  ( MAX_WRITE_BURST_LENGTH ),
        .BUS_ADDR_WIDTH          ( C_M_AXI_ADDR_WIDTH ),
        .BUS_DATA_WIDTH          ( C_M_AXI_DATA_WIDTH ),
        .USER_DW                 ( CH0_USER_DW ),
        .USER_AW                 ( CH0_USER_AW ),
        .USER_MAXREQS            ( USER_MAXREQS ),
        .BUFFER_IMPL             ( MAXI_BUFFER_IMPL )
    ) store_unit (
        .ACLK                    ( ACLK ),
        .ARESET                  ( ARESET ),
        .ACLK_EN                 ( ACLK_EN ),
        .out_AXI_AWADDR          ( AWADDR_Dummy ),
        .out_AXI_AWLEN           ( AWLEN_Dummy ),
        .out_AXI_AWVALID         ( AWVALID_Dummy ),
        .in_AXI_AWREADY          ( AWREADY_Dummy ),
        .out_AXI_WDATA           ( WDATA_Dummy ),
        .out_AXI_WSTRB           ( WSTRB_Dummy ),
        .out_AXI_WVALID          ( WVALID_Dummy ),
        .in_AXI_WREADY           ( WREADY_Dummy ),
        .in_AXI_BVALID           ( BVALID_Dummy ),
        .out_AXI_BREADY          ( BREADY_Dummy ),
        .in_HLS_AWADDR           ( I_CH0_AWADDR ),
        .in_HLS_AWLEN            ( I_CH0_AWLEN ),
        .in_HLS_AWVALID          ( I_CH0_AWVALID ),
        .out_HLS_AWREADY         ( I_CH0_AWREADY ),
        .in_HLS_WDATA            ( I_CH0_WDATA ),
        .in_HLS_WSTRB            ( I_CH0_WSTRB ),
        .in_HLS_WVALID           ( I_CH0_WVALID ),
        .out_HLS_WREADY          ( I_CH0_WREADY ),
        .out_HLS_BVALID          ( I_CH0_BVALID ),
        .in_HLS_BREADY           ( I_CH0_BREADY ));

    vadd_gmem0_m_axi_load #(
        .C_TARGET_ADDR           ( C_TARGET_ADDR ),
        .NUM_READ_OUTSTANDING    ( NUM_READ_OUTSTANDING ),
        .MAX_READ_BURST_LENGTH   ( MAX_READ_BURST_LENGTH ),
        .BUS_ADDR_WIDTH          ( C_M_AXI_ADDR_WIDTH ),
        .BUS_DATA_WIDTH          ( C_M_AXI_DATA_WIDTH ),
        .USER_DW                 ( CH0_USER_DW ),
        .USER_AW                 ( CH0_USER_AW ),
        .USER_MAXREQS            ( USER_MAXREQS ),
        .USER_RFIFONUM_WIDTH     ( CH0_USER_RFIFONUM_WIDTH ),
        .BUFFER_IMPL             ( MAXI_BUFFER_IMPL )
    ) load_unit_0 (
        .ACLK                    ( ACLK ),
        .ARESET                  ( ARESET ),
        .ACLK_EN                 ( ACLK_EN ),
        .out_AXI_ARADDR          ( ARADDR_Dummy ),
        .out_AXI_ARLEN           ( ARLEN_Dummy ),
        .out_AXI_ARVALID         ( ARVALID_Dummy ),
        .in_AXI_ARREADY          ( ARREADY_Dummy ),
        .in_AXI_RDATA            ( RDATA_Dummy ),
        .in_AXI_RLAST            ( RLAST_Dummy ),
        .in_AXI_RVALID           ( RVALID_Dummy ),
        .out_AXI_RREADY          ( RREADY_Dummy ),
        .out_AXI_RBURST_READY    ( RBURST_READY_Dummy),
        .in_HLS_ARADDR           ( I_CH0_ARADDR ),
        .in_HLS_ARLEN            ( I_CH0_ARLEN ),
        .in_HLS_ARVALID          ( I_CH0_ARVALID ),
        .out_HLS_ARREADY         ( I_CH0_ARREADY ),
        .out_HLS_RDATA           ( I_CH0_RDATA ),
        .out_HLS_RVALID          ( I_CH0_RVALID ),
        .in_HLS_RREADY           ( I_CH0_RREADY ),
        .out_HLS_RFIFONUM        ( I_CH0_RFIFONUM ));

    // vadd_gmem0_m_axi_write
    vadd_gmem0_m_axi_write #(
        .CONSERVATIVE            ( CONSERVATIVE),
        .C_M_AXI_ID_WIDTH        ( C_M_AXI_ID_WIDTH ),
        .C_M_AXI_AWUSER_WIDTH    ( C_M_AXI_AWUSER_WIDTH ),
        .C_M_AXI_WUSER_WIDTH     ( C_M_AXI_WUSER_WIDTH ),
        .C_M_AXI_BUSER_WIDTH     ( C_M_AXI_BUSER_WIDTH ),
        .C_USER_VALUE            ( C_USER_VALUE ),
        .C_PROT_VALUE            ( C_PROT_VALUE ),
        .C_CACHE_VALUE           ( C_CACHE_VALUE ),
        .BUS_ADDR_WIDTH          ( C_M_AXI_ADDR_WIDTH ),
        .BUS_DATA_WIDTH          ( C_M_AXI_DATA_WIDTH ),
        .NUM_WRITE_OUTSTANDING   ( NUM_WRITE_OUTSTANDING ),
        .MAX_WRITE_BURST_LENGTH  ( MAX_WRITE_BURST_LENGTH )
    ) bus_write (
        .ACLK                    ( ACLK ),
        .ARESET                  ( ARESET ),
        .ACLK_EN                 ( ACLK_EN ),
        .out_BUS_AWID            ( AWID ),
        .out_BUS_AWSIZE          ( AWSIZE ),
        .out_BUS_AWBURST         ( AWBURST ),
        .out_BUS_AWLOCK          ( AWLOCK ),
        .out_BUS_AWCACHE         ( AWCACHE ),
        .out_BUS_AWPROT          ( AWPROT ),
        .out_BUS_AWQOS           ( AWQOS ),
        .out_BUS_AWREGION        ( AWREGION ),
        .out_BUS_AWUSER          ( AWUSER ),
        .out_BUS_AWADDR          ( AWADDR ),
        .out_BUS_AWLEN           ( AWLEN ),
        
        
        .out_BUS_AWVALID         ( AWVALID ),
        .in_BUS_AWREADY          ( AWREADY ),
        .out_BUS_WID             ( WID),
        .out_BUS_WUSER           ( WUSER),
        .out_BUS_WDATA           ( WDATA ),
        .out_BUS_WSTRB           ( WSTRB ),
        .out_BUS_WLAST           ( WLAST ),
        
        
        .out_BUS_WVALID          ( WVALID ),
        .in_BUS_WREADY           ( WREADY ),
        .in_BUS_BID              ( BID ),
        .in_BUS_BRESP            ( BRESP ),
        .in_BUS_BUSER            ( BUSER ),
        .in_BUS_BVALID           ( BVALID ),
        
        
        .out_BUS_BREADY          ( BREADY ),
        .in_HLS_AWVALID          ( AWVALID_Dummy ),
        .out_HLS_AWREADY         ( AWREADY_Dummy ),
        .in_HLS_AWADDR           ( AWADDR_Dummy ),
        .in_HLS_AWLEN            ( AWLEN_Dummy ),
        .in_HLS_WVALID           ( WVALID_Dummy ),
        .out_HLS_WREADY          ( WREADY_Dummy ),
        .in_HLS_WSTRB            ( WSTRB_Dummy ),
        .in_HLS_WDATA            ( WDATA_Dummy ),
        .out_HLS_BVALID          ( BVALID_Dummy ),
        .in_HLS_BREADY           ( BREADY_Dummy ));

    // vadd_gmem0_m_axi_read
    vadd_gmem0_m_axi_read #(
        .C_M_AXI_ID_WIDTH         ( C_M_AXI_ID_WIDTH ),
        .C_M_AXI_ARUSER_WIDTH     ( C_M_AXI_ARUSER_WIDTH ),
        .C_M_AXI_RUSER_WIDTH      ( C_M_AXI_RUSER_WIDTH ),
        .C_USER_VALUE             ( C_USER_VALUE ),
        .C_PROT_VALUE             ( C_PROT_VALUE ),
        .C_CACHE_VALUE            ( C_CACHE_VALUE ),
        .BUS_ADDR_WIDTH           ( C_M_AXI_ADDR_WIDTH ),
        .BUS_DATA_WIDTH           ( C_M_AXI_DATA_WIDTH ),
        .NUM_READ_OUTSTANDING     ( NUM_READ_OUTSTANDING ),
        .MAX_READ_BURST_LENGTH    ( MAX_READ_BURST_LENGTH )
    ) bus_read (
        .ACLK                     ( ACLK ),
        .ARESET                   ( ARESET ),
        .ACLK_EN                  ( ACLK_EN ),
        .out_BUS_ARID             ( ARID ),
        .out_BUS_ARADDR           ( ARADDR ),
        .out_BUS_ARLEN            ( ARLEN ),
        .out_BUS_ARSIZE           ( ARSIZE ),
        .out_BUS_ARBURST          ( ARBURST ),
        .out_BUS_ARLOCK           ( ARLOCK ),
        .out_BUS_ARCACHE          ( ARCACHE ),
        .out_BUS_ARPROT           ( ARPROT ),
        .out_BUS_ARQOS            ( ARQOS ),
        .out_BUS_ARREGION         ( ARREGION ),
        .out_BUS_ARUSER           ( ARUSER ),
        
        
        .out_BUS_ARVALID          ( ARVALID ),
        .in_BUS_ARREADY           ( ARREADY ),
        .in_BUS_RID               ( RID ),
        .in_BUS_RDATA             ( RDATA ),
        .in_BUS_RRESP             ( RRESP ),
        .in_BUS_RLAST             ( RLAST ),
        .in_BUS_RUSER             ( RUSER ),
        .in_BUS_RVALID            ( RVALID ),
        
        
        .out_BUS_RREADY           ( RREADY ),
        .in_HLS_ARVALID           ( ARVALID_Dummy ),
        .out_HLS_ARREADY          ( ARREADY_Dummy ),
        .in_HLS_ARADDR            ( ARADDR_Dummy ),
        .in_HLS_ARLEN             ( ARLEN_Dummy ),
        .out_HLS_RVALID           ( RVALID_Dummy ),
        .in_HLS_RREADY            ( RREADY_Dummy ),
        .in_HLS_RBUST_READY       ( RBURST_READY_Dummy),
        .out_HLS_RDATA            ( RDATA_Dummy ),
        .out_HLS_RLAST            ( RLAST_Dummy ));

    
endmodule
`default_nettype wire
// 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689
`timescale 1ns/1ps

module vadd_gmem0_m_axi_load
#(parameter
    C_TARGET_ADDR                         = 32'h00000000,
    NUM_READ_OUTSTANDING                  = 2,
    MAX_READ_BURST_LENGTH                 = 16,
    BUS_ADDR_WIDTH                        = 32,
    BUS_DATA_WIDTH                        = 32,
    USER_DW                               = 16,
    USER_AW                               = 32,
    USER_MAXREQS                          = 16,
    USER_RFIFONUM_WIDTH                   = 6,
    BUFFER_IMPL                           = "auto"
)(
    // system signal
    input  wire                           ACLK,
    input  wire                           ARESET,
    input  wire                           ACLK_EN,

    // read address channel
    output wire [BUS_ADDR_WIDTH-1:0]      out_AXI_ARADDR,
    output wire [31:0]                    out_AXI_ARLEN,
    output wire                           out_AXI_ARVALID,
    input  wire                           in_AXI_ARREADY,
    // read data channel
    input  wire [BUS_DATA_WIDTH-1:0]      in_AXI_RDATA,
    input  wire [1:0]                     in_AXI_RLAST,
    input  wire                           in_AXI_RVALID,
    output wire                           out_AXI_RREADY,
    output wire                           out_AXI_RBURST_READY,

    // internal bus ports
    // read address
    input  wire [USER_AW-1:0]             in_HLS_ARADDR,
    input  wire [31:0]                    in_HLS_ARLEN,
    input  wire                           in_HLS_ARVALID,
    output wire                           out_HLS_ARREADY,
    // read data
    output wire [USER_DW-1:0]             out_HLS_RDATA,
    output wire                           out_HLS_RVALID,
    input  wire                           in_HLS_RREADY,
    output wire [USER_RFIFONUM_WIDTH-1:0] out_HLS_RFIFONUM
);

//------------------------Parameter----------------------
    localparam
        USER_DATA_WIDTH = calc_data_width(USER_DW),
        USER_DATA_BYTES = USER_DATA_WIDTH / 8,
        USER_ADDR_ALIGN = log2(USER_DATA_BYTES),
        BUS_ADDR_ALIGN  = log2(BUS_DATA_WIDTH/8),
        // rdata buffer size 
        RBUFF_DEPTH     = NUM_READ_OUTSTANDING * MAX_READ_BURST_LENGTH,
        TARGET_ADDR     = C_TARGET_ADDR & (32'hffffffff << USER_ADDR_ALIGN);

//------------------------Task and function--------------
    function integer calc_data_width;
        input integer x;
        integer y;
    begin
        y = 8;
        while (y < x) y = y * 2;
        calc_data_width = y;
    end
    endfunction

    function integer log2;
        input integer x;
        integer n, m;
    begin
        n = 0;
        m = 1;
        while (m < x) begin
            n = n + 1;
            m = m * 2;
        end
        log2 = n;
    end
    endfunction

//------------------------Local signal-------------------

    wire                           next_rreq;
    wire                           ready_for_rreq;
    wire                           rreq_ready;

    wire [USER_AW-1 : 0]           rreq_addr;
    wire [31:0]                    rreq_len;
    wire                           rreq_valid;

    wire                           valid_length;

    reg  [BUS_ADDR_WIDTH-1 : 0]    tmp_addr;
    reg  [31:0]                    tmp_len;
    reg                            tmp_valid;

    wire                           burst_ready;
    wire                           beat_valid;
    wire                           next_beat;
    wire                           last_beat;
    wire [BUS_DATA_WIDTH-1 : 0]    beat_data;
    wire [log2(RBUFF_DEPTH) : 0]   beat_nvalid;

    reg                            ready_for_outstanding;
    
    // regslice io ?  no 
    
    // enable regslice on R channel  no 

//------------------------Instantiation------------------

    

    vadd_gmem0_m_axi_fifo #(
        .DATA_WIDTH        (USER_AW + 32),
        .ADDR_WIDTH        (log2(USER_MAXREQS)),
        .DEPTH             (USER_MAXREQS)
    ) fifo_rreq (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        .if_full_n         (out_HLS_ARREADY),
        .if_write          (in_HLS_ARVALID),
        .if_din            ({in_HLS_ARLEN, in_HLS_ARADDR}),
        .if_empty_n        (rreq_valid),
        .if_read           (next_rreq),
        .if_dout           ({rreq_len, rreq_addr}),
        .if_num_data_valid ());

    // ===================================================================
    // start of ARADDR PREPROCESSOR
    
    assign next_rreq       = rreq_valid && ready_for_rreq;
    assign ready_for_rreq  = ~tmp_valid || (in_AXI_ARREADY && rreq_ready);
    assign valid_length    = (rreq_len != 32'b0) && !rreq_len[31];

    assign out_AXI_ARLEN   = tmp_len;   // Byte length
    assign out_AXI_ARADDR  = tmp_addr;  // Byte address
    assign out_AXI_ARVALID = tmp_valid && rreq_ready;

    always @(posedge ACLK)
    begin
        if (ARESET) begin
            tmp_len  <= 0;
            tmp_addr <= 0;
        end
        else if (ACLK_EN) begin
            if(next_rreq) begin
                tmp_len  <= (rreq_len << USER_ADDR_ALIGN) - 1;            // byte length
                tmp_addr <= TARGET_ADDR + (rreq_addr << USER_ADDR_ALIGN); // byte address
            end
        end
    end
 
    always @(posedge ACLK) 
    begin
        if (ARESET)
            tmp_valid <= 1'b0;
        else if (ACLK_EN) begin
            if (next_rreq && valid_length)
                tmp_valid <= 1'b1;
            else if (in_AXI_ARREADY && rreq_ready)
                tmp_valid <= 1'b0;
        end
    end

    // end of ARADDR PREPROCESSOR
    // ===================================================================

    

    
    vadd_gmem0_m_axi_fifo #(
        .MEM_STYLE         (BUFFER_IMPL),
        .DATA_WIDTH        (BUS_DATA_WIDTH + 2),
        .ADDR_WIDTH        (log2(RBUFF_DEPTH)),
        .DEPTH             (RBUFF_DEPTH)
    ) buff_rdata (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        .if_full_n         (out_AXI_RREADY),
        .if_write          (in_AXI_RVALID),
        .if_din            ({in_AXI_RLAST, in_AXI_RDATA}),
        .if_empty_n        (beat_valid),
        .if_read           (next_beat),
        .if_dout           ({burst_ready, last_beat, beat_data}),
        .if_num_data_valid (beat_nvalid));

    assign out_AXI_RBURST_READY = ready_for_outstanding;

    always @(posedge ACLK) 
    begin
        if (ARESET)
            ready_for_outstanding <= 1'b0;
        else if (ACLK_EN) begin
            if (next_beat && beat_valid)
                ready_for_outstanding <= burst_ready;
            else
                ready_for_outstanding <= 1'b0;
        end
    end
    // ===================================================================
    // start of RDATA PREPROCESSOR
    generate
    if (USER_DATA_WIDTH == BUS_DATA_WIDTH) begin : bus_equal_gen

        assign rreq_ready       = 1'b1; 
        // regslice io ?  no
        assign next_beat        = in_HLS_RREADY;
        assign out_HLS_RDATA    = beat_data[USER_DW-1 : 0];
        assign out_HLS_RVALID   = beat_valid;
        assign out_HLS_RFIFONUM = beat_nvalid; // 

    end
    else if (USER_DATA_WIDTH < BUS_DATA_WIDTH) begin : bus_wide_gen
        localparam
            TOTAL_SPLIT  = BUS_DATA_WIDTH / USER_DATA_WIDTH,
            SPLIT_ALIGN  = log2(TOTAL_SPLIT);

        wire [USER_AW - 1:0]        tmp_addr_end;

        wire                        offset_full_n;
        wire                        offset_write;
        wire [SPLIT_ALIGN-1 : 0]    start_offset;
        wire [SPLIT_ALIGN-1 : 0]    end_offset;

        wire                        offset_valid;
        wire                        next_offset;
        wire [SPLIT_ALIGN-1 : 0]    head_offset;
        wire [SPLIT_ALIGN-1 : 0]    tail_offset;

        reg                         first_beat;

        wire                        first_data;
        wire                        last_data;
        wire                        ready_for_data;
    
        wire [BUS_DATA_WIDTH-1:0]   tmp_rdata;
        wire                        tmp_rlast;
        wire                        tmp_rvalid;

        reg  [BUS_DATA_WIDTH-1 : 0] data_buf;
        reg                         data_valid;

        reg  [USER_RFIFONUM_WIDTH-1:0] rdata_nvalid; 
        reg  [SPLIT_ALIGN : 0]      data_nvalid;
        wire [SPLIT_ALIGN : 0]      split_nvalid;
        
        wire [SPLIT_ALIGN-1 : 0]    split_cnt_end;
        wire [SPLIT_ALIGN-1 : 0]    split_cnt;
        reg  [SPLIT_ALIGN-1 : 0]    split_cnt_buf;

        wire                        first_split;
        wire                        next_split;
        wire                        last_split;
        wire                        ready_for_split;

        // Recording the offset of start & end address to extract the expect data from beats when USER_DW < BUS_DW.
        vadd_gmem0_m_axi_fifo #(
            .DATA_WIDTH         (2*SPLIT_ALIGN),
            .ADDR_WIDTH         (log2(NUM_READ_OUTSTANDING)),
            .DEPTH              (NUM_READ_OUTSTANDING)
        ) rreq_offset (
            .clk                (ACLK),
            .reset              (ARESET),
            .clk_en             (ACLK_EN),
            .if_full_n          (offset_full_n),
            .if_write           (offset_write),
            .if_din             ({start_offset, end_offset}),
            .if_empty_n         (offset_valid),
            .if_read            (next_offset),
            .if_dout            ({head_offset, tail_offset}),
            .if_num_data_valid  ());

        vadd_gmem0_m_axi_reg_slice #(
            .DATA_WIDTH         (BUS_DATA_WIDTH + 1)
        ) rs_tmp_rdata (
            .clk               (ACLK),
            .reset             (ARESET),
            .s_data            ({last_beat, beat_data}),
            .s_valid           (beat_valid),
            .s_ready           (next_beat),
            .m_data            ({tmp_rlast, tmp_rdata}),
            .m_valid           (tmp_rvalid),
            .m_ready           (last_split));

        assign rreq_ready       = offset_full_n | ~offset_write;
        assign tmp_addr_end     = tmp_addr + tmp_len;

        assign start_offset     = tmp_addr[BUS_ADDR_ALIGN - 1 : 0] >> USER_ADDR_ALIGN;
        assign end_offset       = tmp_addr_end[BUS_ADDR_ALIGN - 1 : 0] >> USER_ADDR_ALIGN;
        assign offset_write     = tmp_valid & in_AXI_ARREADY;

        assign next_offset      = (tmp_rlast & tmp_rvalid) & last_split;

        // regslice io ?  no
        assign out_HLS_RDATA    = data_buf[USER_DW-1 : 0];
        assign out_HLS_RVALID   = data_valid;
        assign out_HLS_RFIFONUM = rdata_nvalid + data_nvalid;
        assign ready_for_data   = ~data_valid | in_HLS_RREADY; // 

        assign first_data       = first_beat && ready_for_split;
        assign last_data        = tmp_rlast && ready_for_split;

        assign ready_for_split  = tmp_rvalid && offset_valid;
        assign next_split       = ready_for_split && ready_for_data;
        assign first_split      = (split_cnt_buf == 0) && next_split;
        assign last_split       = (split_cnt == split_cnt_end) && next_split;

        assign split_cnt        = (first_data && (split_cnt_buf == 0)) ? head_offset : split_cnt_buf;
        assign split_cnt_end    = (~last_data) ? (TOTAL_SPLIT - 1) : tail_offset;

        assign split_nvalid     = (first_data && last_data)  ? tail_offset - head_offset + 1 :
                                   first_data                ? TOTAL_SPLIT - head_offset     :
                                   last_data                 ? tail_offset + 1               :
                                   TOTAL_SPLIT;
        always @(posedge ACLK)
        begin
            if (ARESET)
                split_cnt_buf <= 0;
            else if (ACLK_EN) begin 
                if (last_split)
                    split_cnt_buf <= 0;
                else if (next_split)
                    split_cnt_buf <= split_cnt + 1;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                first_beat <= 1'b1;
            else if (ACLK_EN) begin
                if (next_offset)
                    first_beat <= 1'b1;
                else if (first_beat && last_split)
                    first_beat <= 1'b0;
            end
        end

        always @(posedge ACLK)
        begin
            if (ACLK_EN) begin
                if (first_split & first_data)
                    data_buf <= tmp_rdata >> (head_offset * USER_DATA_WIDTH);
                else if (first_split)
                    data_buf <= tmp_rdata;
                else if (next_split)
                    data_buf <= data_buf >> USER_DATA_WIDTH;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_valid <= 1'b0;
            else if (ACLK_EN) begin
                if (first_split)
                    data_valid <= 1'b1;
                else if (~ready_for_split && ready_for_data)
                    data_valid <= 1'b0;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_nvalid <= 0;
            else if (ACLK_EN) begin
                if (first_split)
                    data_nvalid <= split_nvalid;
                else if (next_split)
                    data_nvalid <= data_nvalid - 1;
                else if (~ready_for_split && ready_for_data)
                    data_nvalid <= 0;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                rdata_nvalid <= 0;
            else if (ACLK_EN) begin
                if (~tmp_rvalid)
                    rdata_nvalid <= 0;
                else if (~next_beat)
                    rdata_nvalid <= ((beat_nvalid + 1) << SPLIT_ALIGN);
                else
                    rdata_nvalid <= (beat_nvalid << SPLIT_ALIGN);
            end
        end
        
    end
    else begin : bus_narrow_gen
        localparam
            TOTAL_PADS      = USER_DATA_WIDTH / BUS_DATA_WIDTH,
            PAD_ALIGN       = log2(TOTAL_PADS);

        reg [USER_DATA_WIDTH-1 : 0] data_buf;
        reg                         data_valid;
        reg [PAD_ALIGN:0]           data_nvalid;
        wire                        ready_for_data;
        wire [USER_RFIFONUM_WIDTH-1 : 0] rdata_num_vld;

        wire [TOTAL_PADS - 1:0]     pad_oh;
        reg  [TOTAL_PADS - 1:0]     pad_oh_reg;

        reg                         first_pad;
        wire                        last_pad;
        wire                        next_pad;

        assign rreq_ready       = 1'b1; 
        assign next_beat        = next_pad;
        assign rdata_num_vld    = beat_nvalid[log2(RBUFF_DEPTH) : PAD_ALIGN] + (beat_nvalid[PAD_ALIGN-1:0] + data_nvalid) >> PAD_ALIGN;
        
        // regslice io ?  no
        assign out_HLS_RDATA    = data_buf[USER_DW-1 : 0];
        assign out_HLS_RVALID   = data_valid;
        assign out_HLS_RFIFONUM = rdata_num_vld;
        assign ready_for_data   = ~data_valid | in_HLS_RREADY;// 

        assign next_pad         = beat_valid && ready_for_data;
        assign last_pad         = pad_oh[TOTAL_PADS - 1];

        always @(posedge ACLK)
        begin
            if (ARESET)
                first_pad <= 1'b1;
            else if (ACLK_EN) begin
                if (next_pad && ~last_pad)
                    first_pad <= 1'b0;
                else if (next_pad && last_pad)
                    first_pad <= 1'b1;
            end
        end

        assign pad_oh = (beat_valid == 0)  ?  0 :
                        (first_pad)        ?  1 :
                        pad_oh_reg;
 
        always @(posedge ACLK)
        begin
            if (ARESET)
                pad_oh_reg <= 0;
            else if (ACLK_EN) begin
                if (next_pad)
                    pad_oh_reg <= {pad_oh[TOTAL_PADS - 2:0], 1'b0};
            end
        end

        genvar  i;
        for (i = 0; i < TOTAL_PADS; i = i + 1) begin : data_gen
            always @(posedge ACLK)
            begin
                if (ACLK_EN) begin
                    if (pad_oh[i] == 1'b1 && ready_for_data)
                        data_buf[i*BUS_DATA_WIDTH +: BUS_DATA_WIDTH] <= beat_data;
                end
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_valid <= 1'b0;
            else if (ACLK_EN) begin
                if (next_beat)
                    data_valid <= 1'b1;
                else if (ready_for_data)
                    data_valid <= 1'b0;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_nvalid <= 0;
            else if (ACLK_EN) begin
                if (first_pad)
                    data_nvalid <= 1;
                else if (next_pad)
                    data_nvalid <= data_nvalid + 1;
            end
        end

    end
    endgenerate
    // end of RDATA PREPROCESSOR
    // ===================================================================

endmodule


module vadd_gmem0_m_axi_store
#(parameter
    C_TARGET_ADDR           = 32'h00000000,
    NUM_WRITE_OUTSTANDING   = 2,
    MAX_WRITE_BURST_LENGTH  = 16,
    BUS_ADDR_WIDTH          = 32,
    BUS_DATA_WIDTH          = 32,
    USER_DW                 = 16,
    USER_AW                 = 32,
    USER_MAXREQS            = 16,
    BUFFER_IMPL             = "auto"
)(
    // system signal
    input  wire                        ACLK,
    input  wire                        ARESET,
    input  wire                        ACLK_EN,
    // write address channel
    output wire [BUS_ADDR_WIDTH-1:0]   out_AXI_AWADDR,
    output wire [31:0]                 out_AXI_AWLEN,
    output wire                        out_AXI_AWVALID,
    input  wire                        in_AXI_AWREADY,
    // write data channel
    output wire [BUS_DATA_WIDTH-1:0]   out_AXI_WDATA,
    output wire [BUS_DATA_WIDTH/8-1:0] out_AXI_WSTRB,
    output wire                        out_AXI_WVALID,
    input  wire                        in_AXI_WREADY,
    // write response channel
    input  wire                        in_AXI_BVALID,
    output wire                        out_AXI_BREADY,

    // internal bus ports
    // write address
    input  wire [USER_AW-1:0]          in_HLS_AWADDR,
    input  wire [31:0]                 in_HLS_AWLEN,
    input  wire                        in_HLS_AWVALID,
    output wire                        out_HLS_AWREADY,
    // write data
    input  wire [USER_DW-1:0]          in_HLS_WDATA,
    input  wire [USER_DW/8-1:0]        in_HLS_WSTRB,
    input  wire                        in_HLS_WVALID,
    output wire                        out_HLS_WREADY,
    // write response
    output wire                        out_HLS_BVALID,
    input  wire                        in_HLS_BREADY
);

//------------------------Parameter----------------------
    localparam
        USER_DATA_WIDTH = calc_data_width(USER_DW),
        USER_DATA_BYTES = USER_DATA_WIDTH / 8,
        USER_ADDR_ALIGN = log2(USER_DATA_BYTES),
        BUS_DATA_BYTES  = BUS_DATA_WIDTH / 8,
        BUS_ADDR_ALIGN  = log2(BUS_DATA_BYTES),
        // wdata buffer size 
        WBUFF_DEPTH     = max(MAX_WRITE_BURST_LENGTH * BUS_DATA_WIDTH / USER_DATA_WIDTH, 1), 
        TARGET_ADDR     = C_TARGET_ADDR & (32'hffffffff << USER_ADDR_ALIGN); 

//------------------------Task and function--------------

    function integer max;
        input integer x;
        input integer y;
    begin
        max = (x > y) ? x : y;
    end
    endfunction

    function integer calc_data_width;
        input integer x;
        integer y;
    begin
        y = 8;
        while (y < x) y = y * 2;
        calc_data_width = y;
    end
    endfunction

    function integer log2;
        input integer x;
        integer n, m;
    begin
        n = 0;
        m = 1;
        while (m < x) begin
            n = n + 1;
            m = m * 2;
        end
        log2 = n;
    end
    endfunction

//------------------------Local signal-------------------

    wire                                next_wreq;
    wire                                ready_for_wreq;
    wire                                wreq_ready;

    wire [USER_AW-1 : 0]                wreq_addr;
    wire [31:0]                         wreq_len;
    wire                                wreq_valid;

    wire                                valid_length;

    reg  [USER_AW-1 : 0]                tmp_addr;
    reg  [31:0]                         tmp_len;
    reg                                 tmp_valid;

    wire                                next_wdata;
    wire                                wdata_valid;
    wire [USER_DW-1 : 0]                tmp_wdata;
    wire [USER_DW/8-1 : 0]              tmp_wstrb;

    wire                                wrsp_ready;
    wire                                wrsp_valid;
    wire                                wrsp_read;
    wire                                wrsp_type;

    wire                                ursp_ready;
    wire                                ursp_write;

    // regslice io ?  no 

//------------------------Instantiation------------------
    

    vadd_gmem0_m_axi_fifo #(
        .DATA_WIDTH     (USER_AW + 32),
        .ADDR_WIDTH     (log2(USER_MAXREQS)),
        .DEPTH          (USER_MAXREQS)
    ) fifo_wreq (
        .clk            (ACLK),
        .reset          (ARESET),
        .clk_en         (ACLK_EN),
        .if_full_n      (out_HLS_AWREADY),
        .if_write       (in_HLS_AWVALID),
        .if_din         ({in_HLS_AWLEN, in_HLS_AWADDR}),
        .if_empty_n     (wreq_valid),
        .if_read        (next_wreq),
        .if_dout        ({wreq_len, wreq_addr}),
        .if_num_data_valid());

    assign next_wreq = wreq_valid && ready_for_wreq && wrsp_ready;
    assign ready_for_wreq  = ~tmp_valid || (in_AXI_AWREADY && wreq_ready);

    assign valid_length    = (wreq_len != 32'b0) && !wreq_len[31];

    assign out_AXI_AWLEN   = tmp_len;   // Byte length
    assign out_AXI_AWADDR  = tmp_addr;  // Byte address
    assign out_AXI_AWVALID = tmp_valid && wreq_ready;

    always @(posedge ACLK)
    begin
        if (ARESET) begin
            tmp_len  <= 0;
            tmp_addr <= 0;
        end
        else if (ACLK_EN) begin
            if(next_wreq) begin
                tmp_len  <= (wreq_len << USER_ADDR_ALIGN) - 1;
                tmp_addr <= TARGET_ADDR + (wreq_addr << USER_ADDR_ALIGN);
            end
        end
    end
 
    always @(posedge ACLK) 
    begin
        if (ARESET)
            tmp_valid <= 1'b0;
        else if (next_wreq && valid_length)
            tmp_valid <= 1'b1;
        else if (in_AXI_AWREADY && wreq_ready)
            tmp_valid <= 1'b0;
    end

    // ===================================================================

    

    
    vadd_gmem0_m_axi_fifo #(
        .MEM_STYLE         (BUFFER_IMPL),
        .DATA_WIDTH        (USER_DW + USER_DW/8),
        .ADDR_WIDTH        (log2(WBUFF_DEPTH)),
        .DEPTH             (WBUFF_DEPTH)
    ) buff_wdata (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        .if_full_n         (out_HLS_WREADY),
        .if_write          (in_HLS_WVALID),
        .if_din            ({in_HLS_WSTRB , in_HLS_WDATA}),
        .if_empty_n        (wdata_valid),
        .if_read           (next_wdata),
        .if_dout           ({tmp_wstrb, tmp_wdata}),
        .if_num_data_valid ());

    generate
    if (USER_DATA_WIDTH == BUS_DATA_WIDTH) begin : bus_equal_gen
        assign next_wdata       = in_AXI_WREADY;
        assign out_AXI_WVALID   = wdata_valid;
        assign out_AXI_WDATA    = tmp_wdata;
        assign out_AXI_WSTRB    = tmp_wstrb;

        assign wreq_ready   = 1'b1;

    end
    else if (USER_DATA_WIDTH < BUS_DATA_WIDTH) begin : bus_wide_gen
        localparam
            TOTAL_PADS      = BUS_DATA_WIDTH / USER_DATA_WIDTH,
            PAD_ALIGN       = log2(TOTAL_PADS),
            BEAT_LEN_WIDTH  = 32 - BUS_ADDR_ALIGN;

        function [TOTAL_PADS-1 : 0] decoder;
            input [PAD_ALIGN-1 : 0] din;
            reg  [TOTAL_PADS-1 : 0] dout;
            integer i;
        begin
            dout = {TOTAL_PADS{1'b0}};
            for (i = 0; i < din; i = i + 1)
                dout[i] = 1'b1;
            decoder = dout;
        end
        endfunction

        wire [USER_AW - 1:0]        tmp_addr_end;

        wire                        offset_full_n;
        wire                        offset_write;
        wire [PAD_ALIGN-1 : 0]      start_offset;
        wire [PAD_ALIGN-1 : 0]      end_offset;
        wire [BEAT_LEN_WIDTH-1 : 0] beat_total;

        wire                        offset_empty_n;
        wire                        offset_read;
        wire [2*PAD_ALIGN+BEAT_LEN_WIDTH-1 : 0] offset_pack;
        reg  [2*PAD_ALIGN+BEAT_LEN_WIDTH-1 : 0] offset_pack_reg;

        reg                         offset_valid;
        wire                        next_offset;
        wire [PAD_ALIGN-1 : 0]      head_offset;
        wire [PAD_ALIGN-1 : 0]      tail_offset;

        wire [BEAT_LEN_WIDTH-1 : 0] beat_len;
        reg  [BEAT_LEN_WIDTH-1:0]   len_cnt_buf;
        wire [BEAT_LEN_WIDTH-1:0]   len_cnt_tmp;

        wire [TOTAL_PADS - 1:0]     add_head;
        wire [TOTAL_PADS - 1:0]     add_tail;
        wire [TOTAL_PADS - 1:0]     pad_oh;
        reg  [TOTAL_PADS - 1:0]     pad_oh_reg;

        wire [TOTAL_PADS-1 : 0]     head_pad_sel;
        wire [0 : TOTAL_PADS-1]     tail_pad_sel; // reverse
        wire                        ready_for_data;
        wire                        next_pad;
        reg                         first_pad;
        wire                        last_pad;

        reg                         first_beat_set;
        reg                         last_beat_set;
        reg                         single_beat;
        wire                        first_beat;
        wire                        last_beat;
        wire                        next_beat;

        reg  [BUS_DATA_WIDTH - 1:0] data_buf;
        reg  [BUS_DATA_BYTES - 1:0] strb_buf;
        reg                         data_valid;

        // Recording the offset of start & end address to align beats from data USER_DW < BUS_DW.
        vadd_gmem0_m_axi_fifo #(
            .DATA_WIDTH             (2*PAD_ALIGN + BEAT_LEN_WIDTH),
            .ADDR_WIDTH             (log2(NUM_WRITE_OUTSTANDING)),
            .DEPTH                  (NUM_WRITE_OUTSTANDING)
        ) wreq_offset (
            .clk                    (ACLK),
            .reset                  (ARESET),
            .clk_en                 (ACLK_EN),
            .if_full_n              (offset_full_n),
            .if_write               (offset_write),
            .if_din                 ({start_offset, end_offset, beat_total}),
            .if_empty_n             (offset_empty_n),
            .if_read                (offset_read),
            .if_dout                (offset_pack),
            .if_num_data_valid      ());

        assign wreq_ready     = offset_full_n | ~offset_write;
        assign tmp_addr_end   = tmp_addr + tmp_len;

        assign start_offset   = tmp_addr[BUS_ADDR_ALIGN-1 : 0] >> USER_ADDR_ALIGN;
        assign end_offset     = ~tmp_addr_end[BUS_ADDR_ALIGN-1 : 0] >> USER_ADDR_ALIGN;
        assign beat_total     = (tmp_len + tmp_addr[BUS_ADDR_ALIGN-1 : 0]) >> BUS_ADDR_ALIGN;

        assign offset_write   = tmp_valid & in_AXI_AWREADY;
        assign offset_read    = ~offset_valid | next_offset;

        assign {head_offset, tail_offset, beat_len} = offset_pack_reg;

        assign out_AXI_WDATA  = data_buf;
        assign out_AXI_WSTRB  = strb_buf;
        assign out_AXI_WVALID = data_valid;

        assign next_wdata     = next_pad;
        assign next_offset    = last_beat && next_beat;
        assign ready_for_data = ~data_valid || in_AXI_WREADY;

        assign len_cnt_tmp    = first_beat ? beat_len : len_cnt_buf;
        assign first_beat     = first_beat_set && offset_valid;
        assign last_beat      = (single_beat || last_beat_set) && offset_valid;
        assign next_beat      = offset_valid && last_pad && ready_for_data;

        assign next_pad       = offset_valid && wdata_valid && ready_for_data;
        assign last_pad       = (last_beat) ? pad_oh[TOTAL_PADS-tail_offset-1] : pad_oh[TOTAL_PADS-1];

        assign head_pad_sel   = decoder(head_offset);
        assign tail_pad_sel   = decoder(tail_offset);

        always @(posedge ACLK)
        begin
            if (ARESET) begin
                single_beat <= 1'b0;
                offset_pack_reg <= 0;
            end
            else if (ACLK_EN) begin
                if (offset_empty_n && offset_read) begin
                    single_beat     <= (offset_pack[BEAT_LEN_WIDTH-1:0] == 0);
                    offset_pack_reg <= offset_pack;
                end
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                offset_valid <= 1'b0;
            else if (ACLK_EN) begin
                if (offset_empty_n && offset_read)
                    offset_valid <= 1'b1;
                else if (next_offset)
                    offset_valid <= 1'b0;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                len_cnt_buf <= 0;
            else if (ACLK_EN) begin
                if (next_beat)
                    len_cnt_buf <= len_cnt_tmp - 1;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET) begin
                first_beat_set <= 1'b1;
                last_beat_set  <= 1'b0;
            end
            else if (ACLK_EN) begin
                if (next_offset) begin
                    first_beat_set <= 1'b1;
                    last_beat_set  <= 1'b0;
                end
                else if (next_beat) begin
                    first_beat_set <= 1'b0;
                    last_beat_set  <= (len_cnt_tmp == 1);
                end
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                first_pad <= 1'b1;
            else if (ACLK_EN) begin
                if (next_pad && ~last_pad)
                    first_pad <= 1'b0;
                else if (next_pad && last_pad)
                    first_pad <= 1'b1;
            end
        end 
        
        assign pad_oh = (~wdata_valid)            ? 0                :
                        (first_pad && first_beat) ? 1 << head_offset :
                        (first_pad)?                1                :
                        pad_oh_reg;

        always @(posedge ACLK)
        begin
            if (ARESET)
                pad_oh_reg <= 0;
            else if (ACLK_EN) begin
                if (next_pad)
                    pad_oh_reg <= {pad_oh[TOTAL_PADS - 2:0], 1'b0};
            end
        end

        genvar  i;
        for (i = 0; i < TOTAL_PADS; i = i + 1) begin : data_gen
            assign add_head[i] = head_pad_sel[i] && first_beat;
            assign add_tail[i] = tail_pad_sel[i] && last_beat;

            always @(posedge ACLK)
            begin
                if (ARESET)
                    data_buf[i*USER_DATA_WIDTH +: USER_DATA_WIDTH] <= {USER_DATA_WIDTH{1'b0}};
                else if (ACLK_EN) begin
                    if ((add_head[i] || add_tail[i]) && ready_for_data)
                        data_buf[i*USER_DATA_WIDTH +: USER_DATA_WIDTH] <= {USER_DATA_WIDTH{1'b0}};
                    else if (pad_oh[i] == 1'b1 && ready_for_data)
                        data_buf[i*USER_DATA_WIDTH +: USER_DATA_WIDTH] <= tmp_wdata;
                end
            end

            always @(posedge ACLK)
            begin
                if (ARESET)
                    strb_buf[i*USER_DATA_BYTES +: USER_DATA_BYTES] <= {USER_DATA_BYTES{1'b0}};
                else if (ACLK_EN) begin
                    if ((add_head[i] || add_tail[i]) && ready_for_data)
                        strb_buf[i*USER_DATA_BYTES +: USER_DATA_BYTES] <= {USER_DATA_BYTES{1'b0}};
                    else if (pad_oh[i] == 1'b1 && ready_for_data)
                        strb_buf[i*USER_DATA_BYTES +: USER_DATA_BYTES] <= tmp_wstrb;
                end
            end

        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_valid <= 1'b0;
            else if (ACLK_EN) begin
                if (next_beat)
                    data_valid <= 1'b1;
                else if (ready_for_data)
                    data_valid <= 1'b0;
            end
        end

    end
    else begin : bus_narrow_gen
        localparam
            TOTAL_SPLIT       = USER_DATA_WIDTH / BUS_DATA_WIDTH,
            SPLIT_ALIGN       = log2(TOTAL_SPLIT),
            BEAT_LEN_WIDTH    = 32 - BUS_ADDR_ALIGN;


        wire [USER_AW - 1:0]        tmp_addr_end;

        wire                        offset_full_n;
        wire                        offset_write;
        wire  [BEAT_LEN_WIDTH-1 : 0] beat_total;

        wire                        offset_valid;
        wire                        next_offset;

        wire [BEAT_LEN_WIDTH-1 : 0] beat_len;
        reg  [BEAT_LEN_WIDTH-1 : 0] len_cnt;

        wire                        ready_for_data;
        reg  [BUS_DATA_WIDTH - 1:0] data_buf;
        reg  [BUS_DATA_BYTES - 1:0] strb_buf;
        reg                         data_valid;

        reg [SPLIT_ALIGN-1 : 0]     split_cnt;

        wire                        first_split;
        wire                        next_split;
        wire                        last_split;

        // Recording the offset of start & end address to align beats from data USER_DW < BUS_DW.
        vadd_gmem0_m_axi_fifo #(
            .DATA_WIDTH        (BEAT_LEN_WIDTH),
            .ADDR_WIDTH        (log2(NUM_WRITE_OUTSTANDING)),
            .DEPTH             (NUM_WRITE_OUTSTANDING)
        ) wreq_offset (
            .clk               (ACLK),
            .reset             (ARESET),
            .clk_en            (ACLK_EN),
            .if_full_n         (offset_full_n),
            .if_write          (offset_write),
            .if_din            (beat_total),
            .if_empty_n        (offset_valid),
            .if_read           (next_offset),
            .if_dout           (beat_len),
            .if_num_data_valid ());

        assign wreq_ready     = offset_full_n | ~offset_write;
        assign beat_total     = (tmp_len + tmp_addr[BUS_ADDR_ALIGN-1 : 0]) >> BUS_ADDR_ALIGN;

        assign offset_write   = tmp_valid & in_AXI_AWREADY;

        assign out_AXI_WDATA  = data_buf[BUS_DATA_WIDTH - 1:0];
        assign out_AXI_WSTRB  = strb_buf[BUS_DATA_BYTES - 1:0];
        assign out_AXI_WVALID = data_valid;

        assign next_wdata     = first_split;
        assign next_offset    = (len_cnt == beat_len) && offset_valid && last_split;
        assign ready_for_data = ~data_valid | in_AXI_WREADY;

        assign first_split    = (split_cnt == 0) && wdata_valid && offset_valid && ready_for_data;
        assign last_split     = (split_cnt == (TOTAL_SPLIT - 1)) && ready_for_data;
        assign next_split     = (split_cnt != 0) && ready_for_data;
        
        always @(posedge ACLK)
        begin
            if (ARESET)
                split_cnt <= 0;
            else if (ACLK_EN) begin
                if (last_split)
                    split_cnt <= 0;
                else if (first_split || next_split)
                    split_cnt <= split_cnt + 1;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                len_cnt <= 0;
            else if (ACLK_EN) begin
                if (next_offset)
                    len_cnt <= 0;
                else if (next_wdata || next_split)
                    len_cnt <= len_cnt + 1;
            end
        end
 
        always @(posedge ACLK)
        begin
            if (ACLK_EN) begin
                if (next_wdata)
                    data_buf <= tmp_wdata;
                else if (next_split)
                    data_buf <= data_buf >> BUS_DATA_WIDTH;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                strb_buf <= 0;
            else if (ACLK_EN) begin
                if (next_wdata)
                    strb_buf <= tmp_wstrb;
                else if (next_split)
                    strb_buf <= strb_buf >> BUS_DATA_BYTES;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_valid <= 0;
            else if (ACLK_EN) begin
                if (next_wdata)
                    data_valid <= 1;
                else if (~(first_split || next_split) && ready_for_data)
                    data_valid <= 0;
            end
        end
    end
    endgenerate

    // ===================================================================

    // generate response for all request (including request with invalid length)
    vadd_gmem0_m_axi_fifo #(
        .DATA_WIDTH        (1),
        .ADDR_WIDTH        (log2(NUM_WRITE_OUTSTANDING)),
        .DEPTH             (NUM_WRITE_OUTSTANDING)
    ) fifo_wrsp (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        .if_full_n         (wrsp_ready),
        .if_write          (next_wreq),
        .if_din            (valid_length),
        .if_empty_n        (wrsp_valid),
        .if_read           (wrsp_read),
        .if_dout           (wrsp_type), // 1 - valid length request, 0 - invalid length request
        .if_num_data_valid ());

    vadd_gmem0_m_axi_fifo #(
        .DATA_WIDTH        (1),
        .ADDR_WIDTH        (log2(USER_MAXREQS)),
        .DEPTH             (USER_MAXREQS)
    ) user_resp (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        .if_full_n         (ursp_ready),
        .if_write          (ursp_write),
        .if_din            (1'b1),
        .if_empty_n        (out_HLS_BVALID),
        .if_read           (in_HLS_BREADY),
        .if_dout           (),
        .if_num_data_valid ());

    

    assign ursp_write  = wrsp_valid && (!wrsp_type || in_AXI_BVALID);
    assign wrsp_read   = ursp_ready && ursp_write;

    assign out_AXI_BREADY = wrsp_type && ursp_ready;

endmodule
// 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689

`timescale 1ns/1ps

//


module vadd_gmem0_m_axi_read
#(parameter
    C_M_AXI_ID_WIDTH          = 1,
    C_M_AXI_ARUSER_WIDTH      = 1,
    C_M_AXI_RUSER_WIDTH       = 1,
    C_USER_VALUE              = 1'b0,
    C_PROT_VALUE              = 3'b000,
    C_CACHE_VALUE             = 4'b0011,
    BUS_ADDR_WIDTH            = 32,
    BUS_DATA_WIDTH            = 32,
    NUM_READ_OUTSTANDING      = 2,
    MAX_READ_BURST_LENGTH     = 16
)(
    // system signal
    input  wire                            ACLK,
    input  wire                            ARESET,
    input  wire                            ACLK_EN,
    // read address channel
    output wire [C_M_AXI_ID_WIDTH-1:0]     out_BUS_ARID,
    output wire [BUS_ADDR_WIDTH-1:0]       out_BUS_ARADDR,
    output wire [7:0]                      out_BUS_ARLEN,
    output wire [2:0]                      out_BUS_ARSIZE,
    output wire [1:0]                      out_BUS_ARBURST,
    output wire [1:0]                      out_BUS_ARLOCK,
    output wire [3:0]                      out_BUS_ARCACHE,
    output wire [2:0]                      out_BUS_ARPROT,
    output wire [3:0]                      out_BUS_ARQOS,
    output wire [3:0]                      out_BUS_ARREGION,
    output wire [C_M_AXI_ARUSER_WIDTH-1:0] out_BUS_ARUSER,
    output wire                            out_BUS_ARVALID,
    input  wire                            in_BUS_ARREADY,
    // read data channel
    input  wire [C_M_AXI_ID_WIDTH-1:0]     in_BUS_RID,
    input  wire [BUS_DATA_WIDTH-1:0]       in_BUS_RDATA,
    input  wire [1:0]                      in_BUS_RRESP,
    input  wire                            in_BUS_RLAST,
    input  wire [C_M_AXI_RUSER_WIDTH-1:0]  in_BUS_RUSER,
    input  wire                            in_BUS_RVALID,
    output wire                            out_BUS_RREADY,

    // HLS internal read request channel
    input  wire [BUS_ADDR_WIDTH-1:0]       in_HLS_ARADDR,
    input  wire [31:0]                     in_HLS_ARLEN,
    input  wire                            in_HLS_ARVALID,
    output wire                            out_HLS_ARREADY,
    output wire [BUS_DATA_WIDTH-1:0]       out_HLS_RDATA,
    output wire [1:0]                      out_HLS_RLAST,
    output wire                            out_HLS_RVALID,
    input  wire                            in_HLS_RREADY,
    input  wire                            in_HLS_RBUST_READY);

//------------------------Parameter----------------------
    localparam
        BUS_DATA_BYTES  = BUS_DATA_WIDTH / 8,
        BUS_ADDR_ALIGN  = log2(BUS_DATA_BYTES);

//------------------------Task and function--------------
    function integer log2;
        input integer x;
        integer n, m;
    begin
        n = 0;
        m = 1;
        while (m < x) begin
            n = n + 1;
            m = m * 2;
        end
        log2 = n;
    end
    endfunction

//------------------------Local signal-------------------
    // AR channel
    wire                          ost_ctrl_info;
    wire                          ost_ctrl_valid;
    wire                          ost_ctrl_ready;

    // R channel
    wire [BUS_DATA_WIDTH-1:0]     tmp_data;
    wire                          tmp_last;
    wire                          data_valid;
    wire                          data_ready;
    wire                          next_ctrl;
    wire                          need_rlast;
    wire                          burst_valid;
    wire                          last_burst;
    wire                          fifo_rctl_ready;
    wire                          next_burst;
    wire                          burst_end;

    // regslice io ?  no 

//------------------------AR channel begin---------------
//------------------------Instantiation------------------
    vadd_gmem0_m_axi_burst_converter #(
        .DATA_WIDTH        (BUS_DATA_WIDTH),
        .ADDR_WIDTH        (BUS_ADDR_WIDTH),
        .MAX_BURST_LEN     (MAX_READ_BURST_LENGTH)
    ) rreq_burst_conv (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),

        .in_REQ_ADDR       (in_HLS_ARADDR),
        .in_REQ_LEN        (in_HLS_ARLEN),
        .in_REQ_VALID      (in_HLS_ARVALID),
        .out_REQ_READY     (out_HLS_ARREADY),
         
        .out_BURST_ADDR    (out_BUS_ARADDR),
        .out_BURST_LEN     (out_BUS_ARLEN),
        .out_BURST_VALID   (out_BUS_ARVALID),
        .in_BURST_READY    (in_BUS_ARREADY),

        .out_CTRL_INFO     (ost_ctrl_info),
        .out_CTRL_LEN      (),
        .out_CTRL_VALID    (ost_ctrl_valid),
        .in_CTRL_READY     (ost_ctrl_ready)
    );
    
    
//------------------------Body---------------------------

    assign out_BUS_ARID     = 0;
    assign out_BUS_ARSIZE   = BUS_ADDR_ALIGN;
    assign out_BUS_ARBURST  = 2'b01;
    assign out_BUS_ARLOCK   = 2'b00;
    assign out_BUS_ARCACHE  = C_CACHE_VALUE;
    assign out_BUS_ARPROT   = C_PROT_VALUE;
    assign out_BUS_ARUSER   = C_USER_VALUE;
    assign out_BUS_ARQOS    = 4'b0000;
    assign out_BUS_ARREGION = 4'b0000;

//------------------------AR channel end-----------------

//------------------------R channel begin----------------
//------------------------Instantiation------------------
    vadd_gmem0_m_axi_reg_slice #(
        .DATA_WIDTH     (BUS_DATA_WIDTH + 1)
    ) rs_rdata (
        .clk            (ACLK),
        .reset          (ARESET),
        .s_data         ({in_BUS_RLAST, in_BUS_RDATA}),
        .s_valid        (in_BUS_RVALID),
        .s_ready        (out_BUS_RREADY),
        .m_data         ({tmp_last, tmp_data}),
        .m_valid        (data_valid),
        .m_ready        (data_ready));

    vadd_gmem0_m_axi_fifo #(
        .DATA_WIDTH     (1),
        .ADDR_WIDTH     (log2(NUM_READ_OUTSTANDING)),
        .DEPTH          (NUM_READ_OUTSTANDING)
    ) fifo_rctl (
        .clk            (ACLK),
        .reset          (ARESET),
        .clk_en         (ACLK_EN),
        .if_full_n      (ost_ctrl_ready),
        .if_write       (ost_ctrl_valid),
        .if_din         (ost_ctrl_info),
        .if_empty_n     (need_rlast),
        .if_read        (next_ctrl),
        .if_dout        (),
        .if_num_data_valid());

    vadd_gmem0_m_axi_fifo #(
        .DATA_WIDTH     (1),
        .ADDR_WIDTH     (log2(NUM_READ_OUTSTANDING)),
        .DEPTH          (NUM_READ_OUTSTANDING)
    ) fifo_burst (
        .clk            (ACLK),
        .reset          (ARESET),
        .clk_en         (ACLK_EN),
        .if_full_n      (),
        .if_write       (ost_ctrl_valid),
        .if_din         (ost_ctrl_info),
        .if_empty_n     (burst_valid),
        .if_read        (next_burst),
        .if_dout        (last_burst),
        .if_num_data_valid());

//------------------------Body---------------------------
    assign next_ctrl      = in_HLS_RBUST_READY && need_rlast;
    assign next_burst     = burst_end && data_valid && data_ready;

    assign burst_end      = tmp_last === 1'b1;
    assign out_HLS_RLAST  = {burst_end, burst_end && last_burst && burst_valid};
    assign out_HLS_RDATA  = tmp_data;
    assign out_HLS_RVALID = data_valid;
    assign data_ready     = in_HLS_RREADY;
//------------------------R channel end------------------
endmodule

module vadd_gmem0_m_axi_write
#(parameter
    CONSERVATIVE              = 0,
    C_M_AXI_ID_WIDTH          = 1,
    C_M_AXI_AWUSER_WIDTH      = 1,
    C_M_AXI_WUSER_WIDTH       = 1,
    C_M_AXI_BUSER_WIDTH       = 1,
    C_USER_VALUE              = 1'b0,
    C_PROT_VALUE              = 3'b000,
    C_CACHE_VALUE             = 4'b0011,
    BUS_ADDR_WIDTH            = 32,
    BUS_DATA_WIDTH            = 32,
    NUM_WRITE_OUTSTANDING     = 2,
    MAX_WRITE_BURST_LENGTH    = 16
)(
    // system signal
    input  wire                             ACLK,
    input  wire                             ARESET,
    input  wire                             ACLK_EN,
    // write address channel
    output wire [C_M_AXI_ID_WIDTH-1:0]      out_BUS_AWID,
    output wire [2:0]                       out_BUS_AWSIZE,
    output wire [1:0]                       out_BUS_AWBURST,
    output wire [1:0]                       out_BUS_AWLOCK,
    output wire [3:0]                       out_BUS_AWCACHE,
    output wire [2:0]                       out_BUS_AWPROT,
    output wire [3:0]                       out_BUS_AWQOS,
    output wire [3:0]                       out_BUS_AWREGION,
    output wire [C_M_AXI_AWUSER_WIDTH-1:0]  out_BUS_AWUSER,
    output wire [BUS_ADDR_WIDTH-1:0]        out_BUS_AWADDR,
    output wire [7:0]                       out_BUS_AWLEN,
    output wire                             out_BUS_AWVALID,
    input  wire                             in_BUS_AWREADY,
    // write data channel
    output wire [C_M_AXI_ID_WIDTH-1:0]      out_BUS_WID,
    output wire [C_M_AXI_WUSER_WIDTH-1:0]   out_BUS_WUSER,
    output wire [BUS_DATA_WIDTH-1:0]        out_BUS_WDATA,
    output wire [BUS_DATA_WIDTH/8-1:0]      out_BUS_WSTRB,
    output wire                             out_BUS_WLAST,
    output wire                             out_BUS_WVALID,
    input  wire                             in_BUS_WREADY,
    // write response channel
    input  wire [C_M_AXI_ID_WIDTH-1:0]      in_BUS_BID,
    input  wire [1:0]                       in_BUS_BRESP,
    input  wire [C_M_AXI_BUSER_WIDTH-1:0]   in_BUS_BUSER,
    input  wire                             in_BUS_BVALID,
    output wire                             out_BUS_BREADY,
    // write request
    input  wire [BUS_ADDR_WIDTH-1:0]        in_HLS_AWADDR,
    input  wire [31:0]                      in_HLS_AWLEN,
    input  wire                             in_HLS_AWVALID,
    output wire                             out_HLS_AWREADY,

    input  wire [BUS_DATA_WIDTH-1:0]        in_HLS_WDATA,
    input  wire [BUS_DATA_WIDTH/8-1:0]      in_HLS_WSTRB,
    input  wire                             in_HLS_WVALID,
    output wire                             out_HLS_WREADY,
    output wire                             out_HLS_BVALID,
    input  wire                             in_HLS_BREADY);

//------------------------Parameter----------------------
    localparam
        BUS_DATA_BYTES  = BUS_DATA_WIDTH / 8,
        BUS_ADDR_ALIGN  = log2(BUS_DATA_BYTES);

//------------------------Task and function--------------
    function integer log2;
        input integer x;
        integer n, m;
    begin
        n = 0;
        m = 1;
        while (m < x) begin
            n = n + 1;
            m = m * 2;
        end
        log2 = n;
    end
    endfunction

//------------------------Local signal-------------------
    // AW channel
    wire [C_M_AXI_ID_WIDTH-1:0]         AWID_Dummy;
    wire [BUS_ADDR_WIDTH - 1:0]         AWADDR_Dummy;
    wire [7:0]                          AWLEN_Dummy;
    wire                                AWVALID_Dummy;
    wire                                AWREADY_Dummy;
 
    wire                                ost_ctrl_info;
    wire [7:0]                          ost_ctrl_len;
    wire                                ost_ctrl_valid;
    wire                                ost_ctrl_ready;

    // W channel
    wire                                next_data;
    wire                                data_valid;
    wire                                data_ready;
    reg  [BUS_DATA_WIDTH - 1:0]         data_buf;
    reg  [BUS_DATA_BYTES - 1:0]         strb_buf;
    wire                                ready_for_data;

    reg  [7:0]                          len_cnt;
    wire [7:0]                          burst_len;
    wire                                fifo_burst_ready;
    wire                                next_burst;
    wire                                burst_valid;
    reg                                 WVALID_Dummy;
    wire                                WREADY_Dummy;
    reg                                 WLAST_Dummy;
    //B channel
    wire                                next_resp;
    wire                                last_resp;
    wire                                need_wrsp;
    wire                                resp_valid;
    wire                                resp_ready;

    // regslice io ?  no 

//------------------------AW channel begin---------------
//------------------------Instantiation------------------
    vadd_gmem0_m_axi_burst_converter #(
        .DATA_WIDTH        (BUS_DATA_WIDTH),
        .ADDR_WIDTH        (BUS_ADDR_WIDTH),
        .MAX_BURST_LEN     (MAX_WRITE_BURST_LENGTH)
    ) wreq_burst_conv (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        
        .in_REQ_ADDR       (in_HLS_AWADDR),
        .in_REQ_LEN        (in_HLS_AWLEN),
        .in_REQ_VALID      (in_HLS_AWVALID),
        .out_REQ_READY     (out_HLS_AWREADY),

        .out_BURST_ADDR    (AWADDR_Dummy),
        .out_BURST_LEN     (AWLEN_Dummy),
        .out_BURST_VALID   (AWVALID_Dummy),
        .in_BURST_READY    (AWREADY_Dummy),

        .out_CTRL_INFO     (ost_ctrl_info),
        .out_CTRL_LEN      (ost_ctrl_len),
        .out_CTRL_VALID    (ost_ctrl_valid),
        .in_CTRL_READY     (ost_ctrl_ready)
    );

    // burst converter
    assign out_BUS_AWID     = 0;
    assign out_BUS_AWSIZE   = BUS_ADDR_ALIGN;
    assign out_BUS_AWBURST  = 2'b01;
    assign out_BUS_AWLOCK   = 2'b00;
    assign out_BUS_AWCACHE  = C_CACHE_VALUE;
    assign out_BUS_AWPROT   = C_PROT_VALUE;
    assign out_BUS_AWUSER   = C_USER_VALUE;
    assign out_BUS_AWQOS    = 4'b0000;
    assign out_BUS_AWREGION = 4'b0000;

//------------------------AW channel end-----------------

//------------------------W channel begin----------------
//------------------------Instantiation------------------

    vadd_gmem0_m_axi_fifo #(
        .DATA_WIDTH     (8),
        .ADDR_WIDTH     (log2(NUM_WRITE_OUTSTANDING)),
        .DEPTH          (NUM_WRITE_OUTSTANDING)
    ) fifo_burst (
        .clk            (ACLK),
        .reset          (ARESET),
        .clk_en         (ACLK_EN),
        .if_full_n      (),
        .if_write       (ost_ctrl_valid),
        .if_din         (ost_ctrl_len),
        .if_empty_n     (burst_valid),
        .if_read        (next_burst),
        .if_dout        (burst_len),
        .if_num_data_valid());

//------------------------Body---------------------------

    assign out_BUS_WUSER    = C_USER_VALUE;
    assign out_BUS_WID      = 0;
    assign out_HLS_WREADY   = data_ready;

    assign data_valid       = in_HLS_WVALID;
    assign data_ready       = burst_valid && ready_for_data;
    assign next_data        = data_ready && data_valid;
    assign next_burst       = (len_cnt == burst_len) && next_data;
    assign ready_for_data   = ~WVALID_Dummy || WREADY_Dummy;

    always @(posedge ACLK)
    begin
        if (ARESET) begin
            strb_buf <= 0;
            data_buf <= 0;
        end
        if (ACLK_EN) begin
            if (next_data) begin
                data_buf <= in_HLS_WDATA;
                strb_buf <= in_HLS_WSTRB;
            end
        end
    end

    always @(posedge ACLK)
    begin
        if (ARESET)
            WVALID_Dummy <= 1'b0;
        else if (ACLK_EN) begin
            if (next_data)
                WVALID_Dummy <= 1'b1;
            else if (ready_for_data)
                WVALID_Dummy <= 1'b0;
        end
    end

    always @(posedge ACLK)
    begin
        if (ARESET)
            WLAST_Dummy <= 0;
        else if (ACLK_EN) begin
            if (next_burst)
                WLAST_Dummy <= 1;
            else if (ready_for_data)
                WLAST_Dummy <= 0;
        end
    end

    always @(posedge ACLK)
    begin
        if (ARESET)
            len_cnt <= 0;
        else if (ACLK_EN) begin
            if (next_burst)
                len_cnt <= 0;
            else if (next_data)
                len_cnt <= len_cnt + 1;
        end
    end
//------------------------W channel end------------------

    // Write throttling unit
    vadd_gmem0_m_axi_throttle #(
        .CONSERVATIVE    (CONSERVATIVE),
        .USED_FIX        (0),
        .ADDR_WIDTH      (BUS_ADDR_WIDTH),
        .DATA_WIDTH      (BUS_DATA_WIDTH),
        .DEPTH           (MAX_WRITE_BURST_LENGTH),
        .MAXREQS         (NUM_WRITE_OUTSTANDING),
        .AVERAGE_MODE    (0)
    ) wreq_throttle (
        .clk             (ACLK),
        .reset           (ARESET),
        .clk_en          (ACLK_EN),
        // internal 
        .in_TOP_AWADDR   (AWADDR_Dummy),
        .in_TOP_AWLEN    (AWLEN_Dummy),
        .in_TOP_AWVALID  (AWVALID_Dummy),
        .out_TOP_AWREADY (AWREADY_Dummy),

        .in_TOP_WDATA    (data_buf),
        .in_TOP_WSTRB    (strb_buf),
        .in_TOP_WLAST    (WLAST_Dummy),
        .in_TOP_WVALID   (WVALID_Dummy),
        .out_TOP_WREADY  (WREADY_Dummy),

        // AXI BUS 
        .out_BUS_AWADDR  (out_BUS_AWADDR),
        .out_BUS_AWLEN   (out_BUS_AWLEN),
        .out_BUS_AWVALID (out_BUS_AWVALID),
        .in_BUS_AWREADY  (in_BUS_AWREADY),

        .out_BUS_WDATA   (out_BUS_WDATA),
        .out_BUS_WSTRB   (out_BUS_WSTRB),
        .out_BUS_WLAST   (out_BUS_WLAST),
        .out_BUS_WVALID  (out_BUS_WVALID),
        .in_BUS_WREADY   (in_BUS_WREADY)
    );

    
    
//------------------------B channel begin----------------
//------------------------Instantiation------------------
    vadd_gmem0_m_axi_reg_slice #(
        .DATA_WIDTH     (1)
    ) rs_resp (
        .clk            (ACLK),
        .reset          (ARESET),
        .s_data         (1'b1),
        .s_valid        (in_BUS_BVALID),
        .s_ready        (out_BUS_BREADY),
        .m_data         (),
        .m_valid        (resp_valid),
        .m_ready        (resp_ready));

    vadd_gmem0_m_axi_fifo #(
        .DATA_WIDTH     (1),
        .ADDR_WIDTH     (log2(NUM_WRITE_OUTSTANDING)),
        .DEPTH          (NUM_WRITE_OUTSTANDING)
    ) fifo_resp (
        .clk            (ACLK),
        .reset          (ARESET),
        .clk_en         (ACLK_EN),
        .if_full_n      (ost_ctrl_ready),
        .if_write       (ost_ctrl_valid),
        .if_din         (ost_ctrl_info),
        .if_empty_n     (need_wrsp),
        .if_read        (next_resp),
        .if_dout        (last_resp),
        .if_num_data_valid());
//------------------------Body---------------------------

    assign resp_ready = need_wrsp && (in_HLS_BREADY || (last_resp === 1'b0));
    assign next_resp  = resp_ready && resp_valid;

    assign out_HLS_BVALID = resp_valid && (last_resp === 1'b1 ) ;

//------------------------B channel end------------------
endmodule


module vadd_gmem0_m_axi_burst_converter
#(parameter
    DATA_WIDTH                   = 32,
    ADDR_WIDTH                   = 32,
    MAX_BURST_LEN                = 16
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  clk_en,

    input  wire [ADDR_WIDTH-1:0] in_REQ_ADDR,
    input  wire [31:0]           in_REQ_LEN,
    input  wire                  in_REQ_VALID,
    output wire                  out_REQ_READY,

    output wire [ADDR_WIDTH-1:0] out_BURST_ADDR,
    output wire [7:0]            out_BURST_LEN,
    output wire                  out_BURST_VALID,
    input  wire                  in_BURST_READY,

    output wire                  out_CTRL_INFO,
    output wire [7:0]            out_CTRL_LEN,
    output wire                  out_CTRL_VALID,
    input  wire                  in_CTRL_READY
);
//------------------------Parameter----------------------
    localparam
        DATA_BYTES      = DATA_WIDTH / 8,
        ADDR_ALIGN      = log2(DATA_BYTES),
        BOUNDARY_BEATS  = {12-ADDR_ALIGN{1'b1}},
        NUM_BEAT_WIDTH  = log2(MAX_BURST_LEN);
//------------------------Task and function--------------
    function integer log2;
        input integer x;
        integer n, m;
        begin
            n = 0;
            m = 1;
            while (m < x) begin
                n = n + 1;
                m = m * 2;
            end
            log2 = n;
        end
    endfunction
//------------------------Local signal-------------------
    wire [ADDR_WIDTH-1:0]       tmp_addr;
    wire [31:0]                 tmp_len;

    wire                        req_valid;
    wire                        read_req;
    wire                        next_req;

    reg  [ADDR_WIDTH - 1:0]     start_addr;
    wire [ADDR_WIDTH - 1:0]     sect_addr;
    reg  [ADDR_WIDTH - 1:0]     sect_addr_buf;
    reg                         req_handling;

    reg  [11 - ADDR_ALIGN:0]    start_to_4k;
    reg  [11 - ADDR_ALIGN:0]    end_from_4k;
    wire [11 - ADDR_ALIGN:0]    sect_len;
    reg  [11 - ADDR_ALIGN:0]    sect_len_buf;
    reg  [11 - ADDR_ALIGN:0]    beat_len;
    
    reg  [ADDR_WIDTH - 13:0]    sect_cnt;
    reg  [19:0]                 sect_total;
    reg  [19:0]                 sect_total_buf;
    wire [19:0]                 sect_total_tmp;
    wire                        ready_for_sect;

    wire                        single_sect;
    reg                         first_sect;
    reg                         last_sect;
    wire                        last_sect_tmp;
    reg                         last_sect_buf;
    wire                        next_sect;

    reg                         burst_valid;

    wire                        ost_ctrl_info;
    wire [7:0]                  ost_ctrl_len;
    wire                        ost_ctrl_valid;
//------------------------Instantiation------------------
    vadd_gmem0_m_axi_reg_slice #(
        .DATA_WIDTH     (ADDR_WIDTH + 32)
    ) rs_req (
        .clk            (clk),
        .reset          (reset),
        .s_data         ({in_REQ_LEN, in_REQ_ADDR}),
        .s_valid        (in_REQ_VALID),
        .s_ready        (out_REQ_READY),
        .m_data         ({tmp_len, tmp_addr}),
        .m_valid        (req_valid),
        .m_ready        (next_req));

//------------------------Body---------------------------
    assign read_req      = last_sect_tmp & next_sect | ~req_handling;
    assign next_req      = req_valid & read_req;

    always @(posedge clk)
    begin
        if (reset) begin
            start_addr  <= 0;
            beat_len    <= 0;
            sect_total  <= 0;
            end_from_4k <= 0;
            start_to_4k <= 0;
        end
        else if (clk_en) begin
            if (next_req) begin
                start_addr  <= {tmp_addr[ADDR_WIDTH-1:ADDR_ALIGN], {ADDR_ALIGN{1'b0}}};
                beat_len    <= (tmp_len[11:0] + tmp_addr[ADDR_ALIGN-1:0]) >> ADDR_ALIGN;
                sect_total  <= (tmp_len + tmp_addr[11:0]) >> 12;
                end_from_4k <= (tmp_addr[11:0] + tmp_len[11:0]) >> ADDR_ALIGN; 
                start_to_4k <= BOUNDARY_BEATS - tmp_addr[11:ADDR_ALIGN];
            end
        end
    end

    always @(posedge clk)
    begin
        if (reset)
            req_handling <= 1'b0;
        else if (clk_en) begin
            if (next_req)
                req_handling <= 1'b1;
            else if (~req_valid && last_sect_tmp & next_sect)
                req_handling <= 1'b0;
        end
    end

    // 4k boundary
    assign last_sect_tmp  = single_sect || last_sect;

    assign sect_total_tmp = first_sect ? sect_total : sect_total_buf;
    
    assign single_sect  = (sect_total == 0);

    assign next_sect  = req_handling && ready_for_sect;

    assign sect_addr  = (first_sect)? start_addr : {sect_cnt, {12{1'b0}}};
    
    assign sect_len   = single_sect              ? beat_len :
                        ( first_sect && ~last_sect)? start_to_4k :
                        (~first_sect &&  last_sect)? end_from_4k :
                                                     BOUNDARY_BEATS;

    always @(posedge clk)
    begin
        if (reset) begin
            first_sect <= 1'b0;
            last_sect <= 1'b0;
            sect_cnt <= 0;
        end
        else if (clk_en) begin
            if (next_req) begin
                first_sect <= 1'b1;
                last_sect <= 1'b0;
                sect_cnt <= tmp_addr[ADDR_WIDTH-1:12];
            end
            else if (next_sect) begin
                first_sect <= 1'b0;
                last_sect <= (sect_total_tmp == 1);
                sect_cnt <= sect_cnt + 1;
            end
        end
    end

    always @(posedge clk)
    begin
        if (reset) begin
            sect_addr_buf  <= 0;
            sect_len_buf   <= 0;
            last_sect_buf  <= 1'b0;
            sect_total_buf <= 0;
        end
        else if (clk_en) begin
            if (next_sect) begin
                sect_addr_buf  <= sect_addr;
                sect_len_buf   <= sect_len;
                last_sect_buf  <= last_sect_tmp;
                sect_total_buf <= sect_total_tmp - 1;
            end
        end
    end

    generate
    if (DATA_BYTES >= 4096/MAX_BURST_LEN) begin : must_one_burst
        assign out_BURST_ADDR  = sect_addr_buf;
        assign out_BURST_LEN   = sect_len_buf;
        assign out_BURST_VALID = burst_valid;

        assign out_CTRL_VALID  = next_sect;
        assign out_CTRL_INFO   = last_sect_tmp;
        assign out_CTRL_LEN    = sect_len;

        assign ready_for_sect = ~(burst_valid && ~in_BURST_READY) && in_CTRL_READY;

        always @(posedge clk)
        begin
            if (reset)
                burst_valid <= 1'b0;
            else if (clk_en) begin
                if (next_sect)
                    burst_valid <= 1'b1;
                else if (in_BURST_READY)
                    burst_valid <= 1'b0;
            end
        end

    end
    else begin : could_multi_bursts
        wire [ADDR_WIDTH - 1:0]                   addr_tmp;
        reg  [ADDR_WIDTH - 1:0]                   addr_buf;
        reg  [ADDR_ALIGN + 8:0]                   addr_step;
        wire [7:0]                                len_tmp;
        reg  [7:0]                                len_buf;
        reg                                       sect_handling;
        reg  [11 - NUM_BEAT_WIDTH - ADDR_ALIGN:0] loop_cnt;
        reg                                       first_loop;
        reg                                       last_loop;
        wire                                      next_loop;
        wire                                      ready_for_loop;

        assign out_BURST_ADDR  = addr_buf;
        assign out_BURST_LEN   = len_buf;
        assign out_BURST_VALID = burst_valid;

        assign out_CTRL_VALID  = next_loop;
        assign out_CTRL_INFO   = last_loop && last_sect_buf;
        assign out_CTRL_LEN    = len_tmp;

        assign next_loop       = sect_handling && ready_for_loop;
        assign ready_for_sect  = ~sect_handling || (last_loop && next_loop);
        assign ready_for_loop  = ~(burst_valid && ~in_BURST_READY) && in_CTRL_READY;

        always @(posedge clk)
        begin
            if (reset)
                burst_valid <= 1'b0;
            else if (clk_en) begin
                if (next_loop)
                    burst_valid <= 1'b1;
                else if (in_BURST_READY)
                    burst_valid <= 1'b0;
            end
        end

        always @(posedge clk)
        begin
            if (reset)
                sect_handling <= 1'b0;
            else if (clk_en) begin
                if (req_handling && ~sect_handling)
                    sect_handling <= 1'b1;
                else if (~req_handling && last_loop && next_loop)
                    sect_handling <= 1'b0;
            end
        end

        always @(posedge clk)
        begin
            if (reset) begin
                first_loop <= 1'b0;
                last_loop <= 1'b0;
                loop_cnt <= 0;
            end
            else if (clk_en) begin
                if (next_sect) begin
                    first_loop <= 1'b1;
                    last_loop <= (sect_len[11 - ADDR_ALIGN : NUM_BEAT_WIDTH] == 0);
                    loop_cnt <= sect_len[11 - ADDR_ALIGN : NUM_BEAT_WIDTH];
                end
                else if (next_loop) begin
                    first_loop <= 1'b0;
                    last_loop <= (loop_cnt == 1);
                    loop_cnt <= loop_cnt - 1;
                end
            end
        end

        assign addr_tmp = first_loop ? sect_addr_buf : (addr_buf + addr_step);
        assign len_tmp  = (NUM_BEAT_WIDTH == 0) ? 0 :
                          last_loop ? sect_len_buf[NUM_BEAT_WIDTH - 1:0] : 
                                      { NUM_BEAT_WIDTH{1'b1} };
        always @(posedge clk)
        begin
            if (reset) begin
                addr_buf  <= 0;
                addr_step <= 0;
                len_buf   <= 0;
            end
            else if (clk_en) begin
                if (next_loop) begin
                    addr_buf  <= addr_tmp;
                    addr_step <= (len_tmp + 1) << ADDR_ALIGN;
                    len_buf   <= len_tmp;
                end
            end
        end

    end
    endgenerate

endmodule

module vadd_gmem0_m_axi_throttle
#(parameter
    CONSERVATIVE   = 0,
    USED_FIX       = 0,
    FIX_VALUE      = 4,
    ADDR_WIDTH     = 32,
    DATA_WIDTH     = 32,
    DEPTH          = 16,
    MAXREQS        = 16,
    AVERAGE_MODE   = 0 
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      clk_en,

    input  wire [ADDR_WIDTH-1:0]     in_TOP_AWADDR,
    input  wire [7:0]                in_TOP_AWLEN,
    input  wire                      in_TOP_AWVALID,
    output wire                      out_TOP_AWREADY,
    input  wire [DATA_WIDTH-1:0]     in_TOP_WDATA,
    input  wire [DATA_WIDTH/8-1:0]   in_TOP_WSTRB,
    input  wire                      in_TOP_WLAST,
    input  wire                      in_TOP_WVALID,
    output wire                      out_TOP_WREADY,

    output wire [ADDR_WIDTH-1:0]     out_BUS_AWADDR,
    output wire [7:0]                out_BUS_AWLEN,
    output wire                      out_BUS_AWVALID,
    input  wire                      in_BUS_AWREADY,
    output wire [DATA_WIDTH-1:0]     out_BUS_WDATA,
    output wire [DATA_WIDTH/8-1:0]   out_BUS_WSTRB,
    output wire                      out_BUS_WLAST,
    output wire                      out_BUS_WVALID,
    input  wire                      in_BUS_WREADY);

    function integer log2;
        input integer x;
        integer n, m;
    begin
        n = 0;
        m = 1;
        while (m < x) begin
            n = n + 1;
            m = m * 2;
        end
        log2 = n;
    end
    endfunction
// aggressive mode
    generate
    if (CONSERVATIVE == 0) begin
        localparam threshold = (USED_FIX)? FIX_VALUE-1 : 0;

        wire                req_en;
        wire                handshake;
        wire  [7:0]         load_init;
        reg   [8:0]         throttl_cnt;

        // AW Channel
        assign out_BUS_AWADDR = in_TOP_AWADDR;
        assign out_BUS_AWLEN  = in_TOP_AWLEN;

        // W Channel
        assign out_BUS_WDATA  = in_TOP_WDATA;
        assign out_BUS_WSTRB  = in_TOP_WSTRB;
        assign out_BUS_WLAST  = in_TOP_WLAST;
        assign out_BUS_WVALID = in_TOP_WVALID & (throttl_cnt > 0);
        assign out_TOP_WREADY = in_BUS_WREADY & (throttl_cnt > 0);

        if (USED_FIX) begin
            assign load_init = FIX_VALUE-1;
            assign handshake = 1'b1;
        end else if (AVERAGE_MODE) begin
            assign load_init = in_TOP_AWLEN;
            assign handshake = 1'b1;
        end else begin
            assign load_init = in_TOP_AWLEN;
            assign handshake = out_BUS_WVALID & in_BUS_WREADY;
        end

        assign out_BUS_AWVALID = in_TOP_AWVALID & req_en;
        assign out_TOP_AWREADY = in_BUS_AWREADY & req_en;
        assign req_en = (throttl_cnt == 0) | (throttl_cnt == 1 & handshake);

        always @(posedge clk)
        begin
            if (reset)
                throttl_cnt <= 0;
            else if (clk_en) begin
                if (in_TOP_AWLEN >= threshold && req_en && in_TOP_AWVALID && in_BUS_AWREADY)
                    throttl_cnt <= load_init + 1'b1; //load
                else if (throttl_cnt > 0 && handshake)
                    throttl_cnt <= throttl_cnt - 1'b1;
            end
        end

    end
// conservative mode
    else begin
        localparam CNT_WIDTH = ((DEPTH < 4)? 2 : log2(DEPTH)) + 1;

        // Instantiation for reg slice for AW channel
        wire                        rs_req_ready;
        wire                        rs_req_valid;
        wire [ADDR_WIDTH + 7 : 0]   rs_req_in;
        wire [ADDR_WIDTH + 7 : 0]   rs_req_out;

        vadd_gmem0_m_axi_reg_slice #(
            .DATA_WIDTH     (ADDR_WIDTH + 8)
        ) rs_req (
            .clk            (clk),
            .reset          (reset),
            .s_data         (rs_req_in),
            .s_valid        (rs_req_valid),
            .s_ready        (rs_req_ready),
            .m_data         (rs_req_out),
            .m_valid        (out_BUS_AWVALID),
            .m_ready        (in_BUS_AWREADY));

        wire  [DATA_WIDTH + DATA_WIDTH/8 : 0]   data_in;
        wire  [DATA_WIDTH + DATA_WIDTH/8 : 0]   data_out;
        wire  [ADDR_WIDTH + 7 : 0]              req_in;
        reg                                     req_en;
        wire                                    data_en;
        wire                                    fifo_valid;
        wire                                    read_fifo;
        wire                                    req_fifo_valid;
        wire                                    read_req;
        wire                                    data_push;
        wire                                    data_pop;
        reg                                     flying_req;
        reg   [CNT_WIDTH-1 : 0]                 last_cnt;

        //AW Channel
        assign req_in   = {in_TOP_AWLEN, in_TOP_AWADDR};
        assign out_BUS_AWADDR = rs_req_out[ADDR_WIDTH-1 : 0];
        assign out_BUS_AWLEN  = rs_req_out[ADDR_WIDTH+7 : ADDR_WIDTH];
        assign rs_req_valid = req_fifo_valid & req_en;

        assign read_req      = rs_req_ready & req_en;

        always @(*)
        begin
            if (~flying_req & data_en)
                req_en <= 1;
            else if (flying_req & (out_BUS_WLAST & data_pop) & (last_cnt[CNT_WIDTH-1:1] != 0))
                req_en <= 1;
            else
                req_en <= 0;
        end

        always @(posedge clk)
        begin
            if (reset)
                flying_req <= 0;
            else if (clk_en) begin
                if (rs_req_valid & rs_req_ready)
                    flying_req <= 1;
                else if (out_BUS_WLAST & data_pop)
                    flying_req <= 0;
            end
        end

        vadd_gmem0_m_axi_fifo #(
            .DATA_WIDTH     (ADDR_WIDTH + 8),
            .ADDR_WIDTH     (log2(MAXREQS)),
            .DEPTH          (MAXREQS)
        ) req_fifo (
            .clk            (clk),
            .reset          (reset),
            .clk_en         (clk_en),
            .if_full_n      (out_TOP_AWREADY),
            .if_write       (in_TOP_AWVALID),
            .if_din         (req_in),
            .if_empty_n     (req_fifo_valid),
            .if_read        (read_req),
            .if_dout        (rs_req_in),
            .if_num_data_valid());

        //W Channel
        assign data_in  = {in_TOP_WLAST, in_TOP_WSTRB, in_TOP_WDATA};
        assign out_BUS_WDATA = data_out[DATA_WIDTH-1 : 0];
        assign out_BUS_WSTRB = data_out[DATA_WIDTH+DATA_WIDTH/8-1 : DATA_WIDTH];
        assign out_BUS_WLAST = data_out[DATA_WIDTH+DATA_WIDTH/8];
        assign out_BUS_WVALID = fifo_valid & data_en & flying_req;

        assign data_en   = last_cnt != 0;
        assign data_push = in_TOP_WVALID & out_TOP_WREADY;
        assign data_pop  = fifo_valid & read_fifo;
        assign read_fifo = in_BUS_WREADY & data_en & flying_req;

        always @(posedge clk)
        begin
            if (reset)
                last_cnt <= 0;
            else if (clk_en) begin
                if ((in_TOP_WLAST & data_push) && ~(out_BUS_WLAST & data_pop))
                    last_cnt <= last_cnt + 1;
                else if (~(in_TOP_WLAST & data_push) && (out_BUS_WLAST & data_pop))
                    last_cnt <= last_cnt - 1;
            end
        end
            
        vadd_gmem0_m_axi_fifo #(
            .DATA_WIDTH     (DATA_WIDTH + DATA_WIDTH/8 + 1),
            .ADDR_WIDTH     (log2(DEPTH)),
            .DEPTH          (DEPTH)
        ) data_fifo (
            .clk            (clk),
            .reset          (reset),
            .clk_en         (clk_en),
            .if_full_n      (out_TOP_WREADY),
            .if_write       (in_TOP_WVALID),
            .if_din         (data_in),
            .if_empty_n     (fifo_valid),
            .if_read        (read_fifo),
            .if_dout        (data_out),
            .if_num_data_valid());

        end
    endgenerate

endmodule



module vadd_gmem0_m_axi_reg_slice
#(parameter
    DATA_WIDTH = 8
) (
    // system signals
    input  wire                  clk,
    input  wire                  reset,
    // slave side
    input  wire [DATA_WIDTH-1:0] s_data,
    input  wire                  s_valid,
    output wire                  s_ready,
    // master side
    output wire [DATA_WIDTH-1:0] m_data,
    output wire                  m_valid,
    input  wire                  m_ready);
    //------------------------Parameter----------------------
    // state
    localparam [1:0]
        ZERO = 2'b10,
        ONE  = 2'b11,
        TWO  = 2'b01;
    //------------------------Local signal-------------------
    reg  [DATA_WIDTH-1:0] data_p1;
    reg  [DATA_WIDTH-1:0] data_p2;
    wire         load_p1;
    wire         load_p2;
    wire         load_p1_from_p2;
    reg          s_ready_t;
    reg  [1:0]   state;
    reg  [1:0]   next;
    //------------------------Body---------------------------
    assign s_ready = s_ready_t;
    assign m_data  = data_p1;
    assign m_valid = state[0];

    assign load_p1 = (state == ZERO && s_valid) ||
                    (state == ONE && s_valid && m_ready) ||
                    (state == TWO && m_ready);
    assign load_p2 = s_valid & s_ready;
    assign load_p1_from_p2 = (state == TWO);

    // data_p1
    always @(posedge clk) begin
        if (load_p1) begin
            if (load_p1_from_p2)
                data_p1 <= data_p2;
            else
                data_p1 <= s_data;
        end
    end

    // data_p2
    always @(posedge clk) begin
        if (load_p2) data_p2 <= s_data;
    end

    // s_ready_t
    always @(posedge clk) begin
        if (reset)
            s_ready_t <= 1'b0;
        else if (state == ZERO)
            s_ready_t <= 1'b1;
        else if (state == ONE && next == TWO)
            s_ready_t <= 1'b0;
        else if (state == TWO && next == ONE)
            s_ready_t <= 1'b1;
    end

    // state
    always @(posedge clk) begin
        if (reset)
            state <= ZERO;
        else
            state <= next;
    end

    // next
    always @(*) begin
        case (state)
            ZERO:
                if (s_valid & s_ready)
                    next = ONE;
                else
                    next = ZERO;
            ONE:
                if (~s_valid & m_ready)
                    next = ZERO;
                else if (s_valid & ~m_ready)
                    next = TWO;
                else
                    next = ONE;
            TWO:
                if (m_ready)
                    next = ONE;
                else
                    next = TWO;
            default:
                next = ZERO;
        endcase
    end
endmodule

module vadd_gmem0_m_axi_fifo
#(parameter
    MEM_STYLE   = "shiftreg",
    DATA_WIDTH = 32,
    ADDR_WIDTH = 5,
    DEPTH      = 32
) (
    // system signal
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  clk_en,

    // write
    output wire                  if_full_n,
    input  wire                  if_write,
    input  wire [DATA_WIDTH-1:0] if_din,

    // read
    output wire                  if_empty_n,
    input  wire                  if_read,
    output wire [DATA_WIDTH-1:0] if_dout,
    output wire [ADDR_WIDTH:0]   if_num_data_valid);

//------------------------Local signal-------------------

    wire                  push;
    wire                  pop;
    reg                   full_n = 1'b1;
    reg                   empty_n = 1'b0;
    reg                   dout_vld = 1'b0;
    reg  [ADDR_WIDTH:0]   mOutPtr = 1'b0;

//------------------------Instantiation------------------
    generate 
    if ((MEM_STYLE == "shiftreg") || (DEPTH == 1)) begin
        reg  [ADDR_WIDTH-1:0] raddr = 1'b0;

        vadd_gmem0_m_axi_srl
        #(  .DATA_WIDTH     (DATA_WIDTH),
            .ADDR_WIDTH     (ADDR_WIDTH),
            .DEPTH          (DEPTH))
        U_fifo_srl(
            .clk            (clk),
            .reset          (reset),
            .clk_en         (clk_en),
            .we             (push),
            .din            (if_din),
            .raddr          (raddr),
            .re             (pop),
            .dout           (if_dout)
        );

        // raddr
        always @(posedge clk) begin
            if (reset == 1'b1)
                raddr <= 1'b0;
            else if (clk_en) begin
                if (push & ~pop & empty_n)
                    raddr <= raddr + 1'b1;
                else if (~push & pop && raddr != 0)
                    raddr <= raddr - 1'b1;
            end
        end

    end else begin
        reg  [ADDR_WIDTH-1:0] waddr = 1'b0;
        reg  [ADDR_WIDTH-1:0] raddr = 1'b0;
        wire [ADDR_WIDTH-1:0] wnext;
        wire [ADDR_WIDTH-1:0] rnext;

        vadd_gmem0_m_axi_mem
        #(  .MEM_STYLE      (MEM_STYLE),
            .DATA_WIDTH     (DATA_WIDTH),
            .ADDR_WIDTH     (ADDR_WIDTH),
            .DEPTH          (DEPTH))
        U_fifo_mem(
            .clk            (clk),
            .reset          (reset),
            .clk_en         (clk_en),
            .we             (push),
            .waddr          (waddr),
            .din            (if_din),
            .raddr          (rnext),
            .re             (pop),
            .dout           (if_dout)
        );

        assign wnext =  !push                ? waddr :
                        (waddr == DEPTH - 2) ? 1'b0  :
                        waddr + 1'b1;
        assign rnext =  !pop                 ? raddr :
                        (raddr == DEPTH - 2) ? 1'b0  :
                        raddr + 1'b1;

        // waddr
        always @(posedge clk) begin
            if (reset == 1'b1)
                waddr <= 1'b0;
            else if (clk_en)
                waddr <= wnext;
        end

        // raddr
        always @(posedge clk) begin
            if (reset == 1'b1)
                raddr <= 1'b0;
            else if (clk_en)
                raddr <= rnext;
        end
    end
    endgenerate

//------------------------Body---------------------------
    assign if_num_data_valid = dout_vld ? mOutPtr + 1'b1 : 'b0;

    generate if (DEPTH == 1) begin
        assign if_full_n  = !dout_vld;
        assign if_empty_n = dout_vld;
        assign push = !dout_vld & if_write;
        assign pop  = !dout_vld & if_write;
    
    end else begin

        assign if_full_n  = full_n;
        assign if_empty_n = dout_vld;
        assign push = full_n & if_write;
        assign pop  = empty_n & (if_read | ~dout_vld);

        // mOutPtr
        always @(posedge clk) begin
            if (reset == 1'b1)
                mOutPtr <= 'b0;
            else if (clk_en)
                if (push & ~pop)
                    mOutPtr <= mOutPtr + 1'b1;
                else if (~push & pop)
                    mOutPtr <= mOutPtr - 1'b1;
        end

        // full_n
        always @(posedge clk) begin
            if (reset == 1'b1)
                full_n <= 1'b1;
            else if (clk_en)
                if (push & ~pop)
                    full_n <= (mOutPtr != DEPTH - 2);
                else if (~push & pop)
                    full_n <= 1'b1;
        end

        // empty_n
        always @(posedge clk)
        begin
            if (reset)
                empty_n <= 1'b0;
            else if (clk_en) begin
                if (push & ~pop)
                    empty_n <= 1'b1;
                else if (~push & pop)
                    empty_n <= (mOutPtr != 1'b1);
            end
        end
    end
    endgenerate

    // dout_vld
    always @(posedge clk) begin
        if (reset == 1'b1)
            dout_vld <= 1'b0;
        else if (clk_en)
            if (pop)
                dout_vld <= 1'b1;
            else if (if_read)
                dout_vld <= 1'b0;
    end

endmodule

module vadd_gmem0_m_axi_srl
#(parameter
        DATA_WIDTH  = 32,
        ADDR_WIDTH  = 6,
        DEPTH       = 63
    )(
        input  wire                  clk,
        input  wire                  reset,
        input  wire                  clk_en,
        input  wire                  we,
        input  wire [DATA_WIDTH-1:0] din,
        input  wire [ADDR_WIDTH-1:0] raddr,
        input  wire                  re,
        output reg  [DATA_WIDTH-1:0] dout
    );

    generate
    if (DEPTH > 1) begin
        reg  [DATA_WIDTH-1:0] mem[0:DEPTH-2];

        integer i;
        always @(posedge clk)
        begin
            if (clk_en & we) begin
                for (i = 0; i < DEPTH - 2; i = i + 1) begin
                    mem[i+1] <= mem[i];
                end
                mem[0] <= din;
            end
        end

        always @(posedge clk)
        begin
            if (reset)
                dout <= 0;
            else if (clk_en & re) begin
                dout <= mem[raddr];
            end
        end
    end
    else begin
        always @(posedge clk)
        begin
            if (reset)
                dout <= 0;
            else if (clk_en & we) begin
                dout <= din;
            end
        end
    end
    endgenerate

endmodule

module vadd_gmem0_m_axi_mem
#(parameter
    MEM_STYLE   = "auto",
    DATA_WIDTH  = 32,
    ADDR_WIDTH  = 6,
    DEPTH       = 63
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  clk_en,
    input  wire                  we,
    input  wire [ADDR_WIDTH-1:0] waddr,
    input  wire [DATA_WIDTH-1:0] din,
    input  wire [ADDR_WIDTH-1:0] raddr,
    input  wire                  re,
    output reg  [DATA_WIDTH-1:0] dout);

    (* ram_style = MEM_STYLE, rw_addr_collision = "yes" *)
    reg  [DATA_WIDTH-1:0] mem[0:DEPTH-2];
    reg  [ADDR_WIDTH-1:0] raddr_reg;

    //write to ram
    always @(posedge clk) begin
        if (clk_en & we)
            mem[waddr] <= din;
    end

    //buffer the raddr
    always @(posedge clk) begin
        if (clk_en)
            raddr_reg <= raddr;
    end

    //read from ram
    always @(posedge clk) begin
        if (reset)
            dout <= 0;
        else if (clk_en & re)
            dout <= mem[raddr_reg];
    end
endmodule

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================
// 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689

`timescale 1ns/1ps
`default_nettype none




module vadd_gmem1_m_axi
#(parameter
    CONSERVATIVE            = 0,
    MAX_READ_BURST_LENGTH   = 16,
    MAX_WRITE_BURST_LENGTH  = 16,
    C_M_AXI_ID_WIDTH        = 1,
    C_M_AXI_ADDR_WIDTH      = 32,
    C_M_AXI_DATA_WIDTH      = 32, // power of 2 & range: 2 to 1024
    C_M_AXI_AWUSER_WIDTH    = 1,
    C_M_AXI_ARUSER_WIDTH    = 1,
    C_M_AXI_WUSER_WIDTH     = 1,
    C_M_AXI_RUSER_WIDTH     = 1,
    C_M_AXI_BUSER_WIDTH     = 1,
    C_TARGET_ADDR           = 32'h00000000,
    C_USER_VALUE            = 1'b0,
    C_PROT_VALUE            = 3'b000,
    C_CACHE_VALUE           = 4'b0011,
    CH0_USER_DW             = 32, // multiple of 8
    CH0_USER_AW             = 32,
    NUM_READ_OUTSTANDING    = 2,
    NUM_WRITE_OUTSTANDING   = 2,
    CH0_USER_RFIFONUM_WIDTH = 6,
    USER_MAXREQS            = 16,
    MAXI_BUFFER_IMPL        = "block"
)(
    
    
    // system signal
    input  wire                               ACLK,
    input  wire                               ARESET,
    input  wire                               ACLK_EN,
    // write address channel
    output wire [C_M_AXI_ID_WIDTH-1:0]        AWID,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]      AWADDR,
    output wire [7:0]                         AWLEN,
    output wire [2:0]                         AWSIZE,
    output wire [1:0]                         AWBURST,
    output wire [1:0]                         AWLOCK,
    output wire [3:0]                         AWCACHE,
    output wire [2:0]                         AWPROT,
    output wire [3:0]                         AWQOS,
    output wire [3:0]                         AWREGION,
    output wire [C_M_AXI_AWUSER_WIDTH-1:0]    AWUSER,
    output wire                               AWVALID,
    input  wire                               AWREADY,
    // write data channel
    output wire [C_M_AXI_ID_WIDTH-1:0]        WID,
    output wire [C_M_AXI_DATA_WIDTH-1:0]      WDATA,
    output wire [C_M_AXI_DATA_WIDTH/8-1:0]    WSTRB,
    output wire                               WLAST,
    output wire [C_M_AXI_WUSER_WIDTH-1:0]     WUSER,
    output wire                               WVALID,
    input  wire                               WREADY,
    // write response channel
    input  wire [C_M_AXI_ID_WIDTH-1:0]        BID,
    input  wire [1:0]                         BRESP,
    input  wire [C_M_AXI_BUSER_WIDTH-1:0]     BUSER,
    input  wire                               BVALID,
    output wire                               BREADY,
    // read address channel
    output wire [C_M_AXI_ID_WIDTH-1:0]        ARID,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]      ARADDR,
    output wire [7:0]                         ARLEN,
    output wire [2:0]                         ARSIZE,
    output wire [1:0]                         ARBURST,
    output wire [1:0]                         ARLOCK,
    output wire [3:0]                         ARCACHE,
    output wire [2:0]                         ARPROT,
    output wire [3:0]                         ARQOS,
    output wire [3:0]                         ARREGION,
    output wire [C_M_AXI_ARUSER_WIDTH-1:0]    ARUSER,
    output wire                               ARVALID,
    input  wire                               ARREADY,
    // read data channel
    input  wire [C_M_AXI_ID_WIDTH-1:0]        RID,
    input  wire [C_M_AXI_DATA_WIDTH-1:0]      RDATA,
    input  wire [1:0]                         RRESP,
    input  wire                               RLAST,
    input  wire [C_M_AXI_RUSER_WIDTH-1:0]     RUSER,
    input  wire                               RVALID,
    output wire                               RREADY,

    // internal bus ports
    // write address
    input  wire [CH0_USER_AW-1:0]             I_CH0_AWADDR,
    input  wire [31:0]                        I_CH0_AWLEN,
    input  wire                               I_CH0_AWVALID,
    output wire                               I_CH0_AWREADY,
    // write data
    input  wire [CH0_USER_DW-1:0]             I_CH0_WDATA,
    input  wire [CH0_USER_DW/8-1:0]           I_CH0_WSTRB,
    input  wire                               I_CH0_WVALID,
    output wire                               I_CH0_WREADY,
    // write response
    output wire                               I_CH0_BVALID,
    input  wire                               I_CH0_BREADY,
    // read address
    input  wire [CH0_USER_AW-1:0]             I_CH0_ARADDR,
    input  wire [31:0]                        I_CH0_ARLEN,
    input  wire                               I_CH0_ARVALID,
    output wire                               I_CH0_ARREADY,
    // read data
    output wire [CH0_USER_DW-1:0]             I_CH0_RDATA,
    output wire                               I_CH0_RVALID,
    input  wire                               I_CH0_RREADY,
    output wire [CH0_USER_RFIFONUM_WIDTH-1:0] I_CH0_RFIFONUM);
//------------------------Local signal-------------------

    wire [C_M_AXI_ADDR_WIDTH-1:0]   AWADDR_Dummy;
    wire [31:0]                     AWLEN_Dummy;
    wire                            AWVALID_Dummy;
    wire                            AWREADY_Dummy;
    wire [C_M_AXI_DATA_WIDTH-1:0]   WDATA_Dummy;
    wire [C_M_AXI_DATA_WIDTH/8-1:0] WSTRB_Dummy;
    wire                            WVALID_Dummy;
    wire                            WREADY_Dummy;
    wire                            BVALID_Dummy;
    wire                            BREADY_Dummy;
    wire [C_M_AXI_ADDR_WIDTH-1:0]   ARADDR_Dummy;
    wire [31:0]                     ARLEN_Dummy;
    wire                            ARVALID_Dummy;
    wire                            ARREADY_Dummy;
    wire [C_M_AXI_DATA_WIDTH-1:0]   RDATA_Dummy;
    wire [1:0]                      RLAST_Dummy;
    wire                            RVALID_Dummy;
    wire                            RREADY_Dummy;
    wire                            RBURST_READY_Dummy;
    
//------------------------Instantiation------------------
    // vadd_gmem1_m_axi_store
    vadd_gmem1_m_axi_store #(
        .C_TARGET_ADDR           ( C_TARGET_ADDR ),
        .NUM_WRITE_OUTSTANDING   ( NUM_WRITE_OUTSTANDING ),
        .MAX_WRITE_BURST_LENGTH  ( MAX_WRITE_BURST_LENGTH ),
        .BUS_ADDR_WIDTH          ( C_M_AXI_ADDR_WIDTH ),
        .BUS_DATA_WIDTH          ( C_M_AXI_DATA_WIDTH ),
        .USER_DW                 ( CH0_USER_DW ),
        .USER_AW                 ( CH0_USER_AW ),
        .USER_MAXREQS            ( USER_MAXREQS ),
        .BUFFER_IMPL             ( MAXI_BUFFER_IMPL )
    ) store_unit (
        .ACLK                    ( ACLK ),
        .ARESET                  ( ARESET ),
        .ACLK_EN                 ( ACLK_EN ),
        .out_AXI_AWADDR          ( AWADDR_Dummy ),
        .out_AXI_AWLEN           ( AWLEN_Dummy ),
        .out_AXI_AWVALID         ( AWVALID_Dummy ),
        .in_AXI_AWREADY          ( AWREADY_Dummy ),
        .out_AXI_WDATA           ( WDATA_Dummy ),
        .out_AXI_WSTRB           ( WSTRB_Dummy ),
        .out_AXI_WVALID          ( WVALID_Dummy ),
        .in_AXI_WREADY           ( WREADY_Dummy ),
        .in_AXI_BVALID           ( BVALID_Dummy ),
        .out_AXI_BREADY          ( BREADY_Dummy ),
        .in_HLS_AWADDR           ( I_CH0_AWADDR ),
        .in_HLS_AWLEN            ( I_CH0_AWLEN ),
        .in_HLS_AWVALID          ( I_CH0_AWVALID ),
        .out_HLS_AWREADY         ( I_CH0_AWREADY ),
        .in_HLS_WDATA            ( I_CH0_WDATA ),
        .in_HLS_WSTRB            ( I_CH0_WSTRB ),
        .in_HLS_WVALID           ( I_CH0_WVALID ),
        .out_HLS_WREADY          ( I_CH0_WREADY ),
        .out_HLS_BVALID          ( I_CH0_BVALID ),
        .in_HLS_BREADY           ( I_CH0_BREADY ));

    vadd_gmem1_m_axi_load #(
        .C_TARGET_ADDR           ( C_TARGET_ADDR ),
        .NUM_READ_OUTSTANDING    ( NUM_READ_OUTSTANDING ),
        .MAX_READ_BURST_LENGTH   ( MAX_READ_BURST_LENGTH ),
        .BUS_ADDR_WIDTH          ( C_M_AXI_ADDR_WIDTH ),
        .BUS_DATA_WIDTH          ( C_M_AXI_DATA_WIDTH ),
        .USER_DW                 ( CH0_USER_DW ),
        .USER_AW                 ( CH0_USER_AW ),
        .USER_MAXREQS            ( USER_MAXREQS ),
        .USER_RFIFONUM_WIDTH     ( CH0_USER_RFIFONUM_WIDTH ),
        .BUFFER_IMPL             ( MAXI_BUFFER_IMPL )
    ) load_unit_0 (
        .ACLK                    ( ACLK ),
        .ARESET                  ( ARESET ),
        .ACLK_EN                 ( ACLK_EN ),
        .out_AXI_ARADDR          ( ARADDR_Dummy ),
        .out_AXI_ARLEN           ( ARLEN_Dummy ),
        .out_AXI_ARVALID         ( ARVALID_Dummy ),
        .in_AXI_ARREADY          ( ARREADY_Dummy ),
        .in_AXI_RDATA            ( RDATA_Dummy ),
        .in_AXI_RLAST            ( RLAST_Dummy ),
        .in_AXI_RVALID           ( RVALID_Dummy ),
        .out_AXI_RREADY          ( RREADY_Dummy ),
        .out_AXI_RBURST_READY    ( RBURST_READY_Dummy),
        .in_HLS_ARADDR           ( I_CH0_ARADDR ),
        .in_HLS_ARLEN            ( I_CH0_ARLEN ),
        .in_HLS_ARVALID          ( I_CH0_ARVALID ),
        .out_HLS_ARREADY         ( I_CH0_ARREADY ),
        .out_HLS_RDATA           ( I_CH0_RDATA ),
        .out_HLS_RVALID          ( I_CH0_RVALID ),
        .in_HLS_RREADY           ( I_CH0_RREADY ),
        .out_HLS_RFIFONUM        ( I_CH0_RFIFONUM ));

    // vadd_gmem1_m_axi_write
    vadd_gmem1_m_axi_write #(
        .CONSERVATIVE            ( CONSERVATIVE),
        .C_M_AXI_ID_WIDTH        ( C_M_AXI_ID_WIDTH ),
        .C_M_AXI_AWUSER_WIDTH    ( C_M_AXI_AWUSER_WIDTH ),
        .C_M_AXI_WUSER_WIDTH     ( C_M_AXI_WUSER_WIDTH ),
        .C_M_AXI_BUSER_WIDTH     ( C_M_AXI_BUSER_WIDTH ),
        .C_USER_VALUE            ( C_USER_VALUE ),
        .C_PROT_VALUE            ( C_PROT_VALUE ),
        .C_CACHE_VALUE           ( C_CACHE_VALUE ),
        .BUS_ADDR_WIDTH          ( C_M_AXI_ADDR_WIDTH ),
        .BUS_DATA_WIDTH          ( C_M_AXI_DATA_WIDTH ),
        .NUM_WRITE_OUTSTANDING   ( NUM_WRITE_OUTSTANDING ),
        .MAX_WRITE_BURST_LENGTH  ( MAX_WRITE_BURST_LENGTH )
    ) bus_write (
        .ACLK                    ( ACLK ),
        .ARESET                  ( ARESET ),
        .ACLK_EN                 ( ACLK_EN ),
        .out_BUS_AWID            ( AWID ),
        .out_BUS_AWSIZE          ( AWSIZE ),
        .out_BUS_AWBURST         ( AWBURST ),
        .out_BUS_AWLOCK          ( AWLOCK ),
        .out_BUS_AWCACHE         ( AWCACHE ),
        .out_BUS_AWPROT          ( AWPROT ),
        .out_BUS_AWQOS           ( AWQOS ),
        .out_BUS_AWREGION        ( AWREGION ),
        .out_BUS_AWUSER          ( AWUSER ),
        .out_BUS_AWADDR          ( AWADDR ),
        .out_BUS_AWLEN           ( AWLEN ),
        
        
        .out_BUS_AWVALID         ( AWVALID ),
        .in_BUS_AWREADY          ( AWREADY ),
        .out_BUS_WID             ( WID),
        .out_BUS_WUSER           ( WUSER),
        .out_BUS_WDATA           ( WDATA ),
        .out_BUS_WSTRB           ( WSTRB ),
        .out_BUS_WLAST           ( WLAST ),
        
        
        .out_BUS_WVALID          ( WVALID ),
        .in_BUS_WREADY           ( WREADY ),
        .in_BUS_BID              ( BID ),
        .in_BUS_BRESP            ( BRESP ),
        .in_BUS_BUSER            ( BUSER ),
        .in_BUS_BVALID           ( BVALID ),
        
        
        .out_BUS_BREADY          ( BREADY ),
        .in_HLS_AWVALID          ( AWVALID_Dummy ),
        .out_HLS_AWREADY         ( AWREADY_Dummy ),
        .in_HLS_AWADDR           ( AWADDR_Dummy ),
        .in_HLS_AWLEN            ( AWLEN_Dummy ),
        .in_HLS_WVALID           ( WVALID_Dummy ),
        .out_HLS_WREADY          ( WREADY_Dummy ),
        .in_HLS_WSTRB            ( WSTRB_Dummy ),
        .in_HLS_WDATA            ( WDATA_Dummy ),
        .out_HLS_BVALID          ( BVALID_Dummy ),
        .in_HLS_BREADY           ( BREADY_Dummy ));

    // vadd_gmem1_m_axi_read
    vadd_gmem1_m_axi_read #(
        .C_M_AXI_ID_WIDTH         ( C_M_AXI_ID_WIDTH ),
        .C_M_AXI_ARUSER_WIDTH     ( C_M_AXI_ARUSER_WIDTH ),
        .C_M_AXI_RUSER_WIDTH      ( C_M_AXI_RUSER_WIDTH ),
        .C_USER_VALUE             ( C_USER_VALUE ),
        .C_PROT_VALUE             ( C_PROT_VALUE ),
        .C_CACHE_VALUE            ( C_CACHE_VALUE ),
        .BUS_ADDR_WIDTH           ( C_M_AXI_ADDR_WIDTH ),
        .BUS_DATA_WIDTH           ( C_M_AXI_DATA_WIDTH ),
        .NUM_READ_OUTSTANDING     ( NUM_READ_OUTSTANDING ),
        .MAX_READ_BURST_LENGTH    ( MAX_READ_BURST_LENGTH )
    ) bus_read (
        .ACLK                     ( ACLK ),
        .ARESET                   ( ARESET ),
        .ACLK_EN                  ( ACLK_EN ),
        .out_BUS_ARID             ( ARID ),
        .out_BUS_ARADDR           ( ARADDR ),
        .out_BUS_ARLEN            ( ARLEN ),
        .out_BUS_ARSIZE           ( ARSIZE ),
        .out_BUS_ARBURST          ( ARBURST ),
        .out_BUS_ARLOCK           ( ARLOCK ),
        .out_BUS_ARCACHE          ( ARCACHE ),
        .out_BUS_ARPROT           ( ARPROT ),
        .out_BUS_ARQOS            ( ARQOS ),
        .out_BUS_ARREGION         ( ARREGION ),
        .out_BUS_ARUSER           ( ARUSER ),
        
        
        .out_BUS_ARVALID          ( ARVALID ),
        .in_BUS_ARREADY           ( ARREADY ),
        .in_BUS_RID               ( RID ),
        .in_BUS_RDATA             ( RDATA ),
        .in_BUS_RRESP             ( RRESP ),
        .in_BUS_RLAST             ( RLAST ),
        .in_BUS_RUSER             ( RUSER ),
        .in_BUS_RVALID            ( RVALID ),
        
        
        .out_BUS_RREADY           ( RREADY ),
        .in_HLS_ARVALID           ( ARVALID_Dummy ),
        .out_HLS_ARREADY          ( ARREADY_Dummy ),
        .in_HLS_ARADDR            ( ARADDR_Dummy ),
        .in_HLS_ARLEN             ( ARLEN_Dummy ),
        .out_HLS_RVALID           ( RVALID_Dummy ),
        .in_HLS_RREADY            ( RREADY_Dummy ),
        .in_HLS_RBUST_READY       ( RBURST_READY_Dummy),
        .out_HLS_RDATA            ( RDATA_Dummy ),
        .out_HLS_RLAST            ( RLAST_Dummy ));

    
endmodule
`default_nettype wire
// 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689
`timescale 1ns/1ps

module vadd_gmem1_m_axi_load
#(parameter
    C_TARGET_ADDR                         = 32'h00000000,
    NUM_READ_OUTSTANDING                  = 2,
    MAX_READ_BURST_LENGTH                 = 16,
    BUS_ADDR_WIDTH                        = 32,
    BUS_DATA_WIDTH                        = 32,
    USER_DW                               = 16,
    USER_AW                               = 32,
    USER_MAXREQS                          = 16,
    USER_RFIFONUM_WIDTH                   = 6,
    BUFFER_IMPL                           = "auto"
)(
    // system signal
    input  wire                           ACLK,
    input  wire                           ARESET,
    input  wire                           ACLK_EN,

    // read address channel
    output wire [BUS_ADDR_WIDTH-1:0]      out_AXI_ARADDR,
    output wire [31:0]                    out_AXI_ARLEN,
    output wire                           out_AXI_ARVALID,
    input  wire                           in_AXI_ARREADY,
    // read data channel
    input  wire [BUS_DATA_WIDTH-1:0]      in_AXI_RDATA,
    input  wire [1:0]                     in_AXI_RLAST,
    input  wire                           in_AXI_RVALID,
    output wire                           out_AXI_RREADY,
    output wire                           out_AXI_RBURST_READY,

    // internal bus ports
    // read address
    input  wire [USER_AW-1:0]             in_HLS_ARADDR,
    input  wire [31:0]                    in_HLS_ARLEN,
    input  wire                           in_HLS_ARVALID,
    output wire                           out_HLS_ARREADY,
    // read data
    output wire [USER_DW-1:0]             out_HLS_RDATA,
    output wire                           out_HLS_RVALID,
    input  wire                           in_HLS_RREADY,
    output wire [USER_RFIFONUM_WIDTH-1:0] out_HLS_RFIFONUM
);

//------------------------Parameter----------------------
    localparam
        USER_DATA_WIDTH = calc_data_width(USER_DW),
        USER_DATA_BYTES = USER_DATA_WIDTH / 8,
        USER_ADDR_ALIGN = log2(USER_DATA_BYTES),
        BUS_ADDR_ALIGN  = log2(BUS_DATA_WIDTH/8),
        // rdata buffer size 
        RBUFF_DEPTH     = NUM_READ_OUTSTANDING * MAX_READ_BURST_LENGTH,
        TARGET_ADDR     = C_TARGET_ADDR & (32'hffffffff << USER_ADDR_ALIGN);

//------------------------Task and function--------------
    function integer calc_data_width;
        input integer x;
        integer y;
    begin
        y = 8;
        while (y < x) y = y * 2;
        calc_data_width = y;
    end
    endfunction

    function integer log2;
        input integer x;
        integer n, m;
    begin
        n = 0;
        m = 1;
        while (m < x) begin
            n = n + 1;
            m = m * 2;
        end
        log2 = n;
    end
    endfunction

//------------------------Local signal-------------------

    wire                           next_rreq;
    wire                           ready_for_rreq;
    wire                           rreq_ready;

    wire [USER_AW-1 : 0]           rreq_addr;
    wire [31:0]                    rreq_len;
    wire                           rreq_valid;

    wire                           valid_length;

    reg  [BUS_ADDR_WIDTH-1 : 0]    tmp_addr;
    reg  [31:0]                    tmp_len;
    reg                            tmp_valid;

    wire                           burst_ready;
    wire                           beat_valid;
    wire                           next_beat;
    wire                           last_beat;
    wire [BUS_DATA_WIDTH-1 : 0]    beat_data;
    wire [log2(RBUFF_DEPTH) : 0]   beat_nvalid;

    reg                            ready_for_outstanding;
    
    // regslice io ?  no 
    
    // enable regslice on R channel  no 

//------------------------Instantiation------------------

    

    vadd_gmem1_m_axi_fifo #(
        .DATA_WIDTH        (USER_AW + 32),
        .ADDR_WIDTH        (log2(USER_MAXREQS)),
        .DEPTH             (USER_MAXREQS)
    ) fifo_rreq (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        .if_full_n         (out_HLS_ARREADY),
        .if_write          (in_HLS_ARVALID),
        .if_din            ({in_HLS_ARLEN, in_HLS_ARADDR}),
        .if_empty_n        (rreq_valid),
        .if_read           (next_rreq),
        .if_dout           ({rreq_len, rreq_addr}),
        .if_num_data_valid ());

    // ===================================================================
    // start of ARADDR PREPROCESSOR
    
    assign next_rreq       = rreq_valid && ready_for_rreq;
    assign ready_for_rreq  = ~tmp_valid || (in_AXI_ARREADY && rreq_ready);
    assign valid_length    = (rreq_len != 32'b0) && !rreq_len[31];

    assign out_AXI_ARLEN   = tmp_len;   // Byte length
    assign out_AXI_ARADDR  = tmp_addr;  // Byte address
    assign out_AXI_ARVALID = tmp_valid && rreq_ready;

    always @(posedge ACLK)
    begin
        if (ARESET) begin
            tmp_len  <= 0;
            tmp_addr <= 0;
        end
        else if (ACLK_EN) begin
            if(next_rreq) begin
                tmp_len  <= (rreq_len << USER_ADDR_ALIGN) - 1;            // byte length
                tmp_addr <= TARGET_ADDR + (rreq_addr << USER_ADDR_ALIGN); // byte address
            end
        end
    end
 
    always @(posedge ACLK) 
    begin
        if (ARESET)
            tmp_valid <= 1'b0;
        else if (ACLK_EN) begin
            if (next_rreq && valid_length)
                tmp_valid <= 1'b1;
            else if (in_AXI_ARREADY && rreq_ready)
                tmp_valid <= 1'b0;
        end
    end

    // end of ARADDR PREPROCESSOR
    // ===================================================================

    

    
    vadd_gmem1_m_axi_fifo #(
        .MEM_STYLE         (BUFFER_IMPL),
        .DATA_WIDTH        (BUS_DATA_WIDTH + 2),
        .ADDR_WIDTH        (log2(RBUFF_DEPTH)),
        .DEPTH             (RBUFF_DEPTH)
    ) buff_rdata (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        .if_full_n         (out_AXI_RREADY),
        .if_write          (in_AXI_RVALID),
        .if_din            ({in_AXI_RLAST, in_AXI_RDATA}),
        .if_empty_n        (beat_valid),
        .if_read           (next_beat),
        .if_dout           ({burst_ready, last_beat, beat_data}),
        .if_num_data_valid (beat_nvalid));

    assign out_AXI_RBURST_READY = ready_for_outstanding;

    always @(posedge ACLK) 
    begin
        if (ARESET)
            ready_for_outstanding <= 1'b0;
        else if (ACLK_EN) begin
            if (next_beat && beat_valid)
                ready_for_outstanding <= burst_ready;
            else
                ready_for_outstanding <= 1'b0;
        end
    end
    // ===================================================================
    // start of RDATA PREPROCESSOR
    generate
    if (USER_DATA_WIDTH == BUS_DATA_WIDTH) begin : bus_equal_gen

        assign rreq_ready       = 1'b1; 
        // regslice io ?  no
        assign next_beat        = in_HLS_RREADY;
        assign out_HLS_RDATA    = beat_data[USER_DW-1 : 0];
        assign out_HLS_RVALID   = beat_valid;
        assign out_HLS_RFIFONUM = beat_nvalid; // 

    end
    else if (USER_DATA_WIDTH < BUS_DATA_WIDTH) begin : bus_wide_gen
        localparam
            TOTAL_SPLIT  = BUS_DATA_WIDTH / USER_DATA_WIDTH,
            SPLIT_ALIGN  = log2(TOTAL_SPLIT);

        wire [USER_AW - 1:0]        tmp_addr_end;

        wire                        offset_full_n;
        wire                        offset_write;
        wire [SPLIT_ALIGN-1 : 0]    start_offset;
        wire [SPLIT_ALIGN-1 : 0]    end_offset;

        wire                        offset_valid;
        wire                        next_offset;
        wire [SPLIT_ALIGN-1 : 0]    head_offset;
        wire [SPLIT_ALIGN-1 : 0]    tail_offset;

        reg                         first_beat;

        wire                        first_data;
        wire                        last_data;
        wire                        ready_for_data;
    
        wire [BUS_DATA_WIDTH-1:0]   tmp_rdata;
        wire                        tmp_rlast;
        wire                        tmp_rvalid;

        reg  [BUS_DATA_WIDTH-1 : 0] data_buf;
        reg                         data_valid;

        reg  [USER_RFIFONUM_WIDTH-1:0] rdata_nvalid; 
        reg  [SPLIT_ALIGN : 0]      data_nvalid;
        wire [SPLIT_ALIGN : 0]      split_nvalid;
        
        wire [SPLIT_ALIGN-1 : 0]    split_cnt_end;
        wire [SPLIT_ALIGN-1 : 0]    split_cnt;
        reg  [SPLIT_ALIGN-1 : 0]    split_cnt_buf;

        wire                        first_split;
        wire                        next_split;
        wire                        last_split;
        wire                        ready_for_split;

        // Recording the offset of start & end address to extract the expect data from beats when USER_DW < BUS_DW.
        vadd_gmem1_m_axi_fifo #(
            .DATA_WIDTH         (2*SPLIT_ALIGN),
            .ADDR_WIDTH         (log2(NUM_READ_OUTSTANDING)),
            .DEPTH              (NUM_READ_OUTSTANDING)
        ) rreq_offset (
            .clk                (ACLK),
            .reset              (ARESET),
            .clk_en             (ACLK_EN),
            .if_full_n          (offset_full_n),
            .if_write           (offset_write),
            .if_din             ({start_offset, end_offset}),
            .if_empty_n         (offset_valid),
            .if_read            (next_offset),
            .if_dout            ({head_offset, tail_offset}),
            .if_num_data_valid  ());

        vadd_gmem1_m_axi_reg_slice #(
            .DATA_WIDTH         (BUS_DATA_WIDTH + 1)
        ) rs_tmp_rdata (
            .clk               (ACLK),
            .reset             (ARESET),
            .s_data            ({last_beat, beat_data}),
            .s_valid           (beat_valid),
            .s_ready           (next_beat),
            .m_data            ({tmp_rlast, tmp_rdata}),
            .m_valid           (tmp_rvalid),
            .m_ready           (last_split));

        assign rreq_ready       = offset_full_n | ~offset_write;
        assign tmp_addr_end     = tmp_addr + tmp_len;

        assign start_offset     = tmp_addr[BUS_ADDR_ALIGN - 1 : 0] >> USER_ADDR_ALIGN;
        assign end_offset       = tmp_addr_end[BUS_ADDR_ALIGN - 1 : 0] >> USER_ADDR_ALIGN;
        assign offset_write     = tmp_valid & in_AXI_ARREADY;

        assign next_offset      = (tmp_rlast & tmp_rvalid) & last_split;

        // regslice io ?  no
        assign out_HLS_RDATA    = data_buf[USER_DW-1 : 0];
        assign out_HLS_RVALID   = data_valid;
        assign out_HLS_RFIFONUM = rdata_nvalid + data_nvalid;
        assign ready_for_data   = ~data_valid | in_HLS_RREADY; // 

        assign first_data       = first_beat && ready_for_split;
        assign last_data        = tmp_rlast && ready_for_split;

        assign ready_for_split  = tmp_rvalid && offset_valid;
        assign next_split       = ready_for_split && ready_for_data;
        assign first_split      = (split_cnt_buf == 0) && next_split;
        assign last_split       = (split_cnt == split_cnt_end) && next_split;

        assign split_cnt        = (first_data && (split_cnt_buf == 0)) ? head_offset : split_cnt_buf;
        assign split_cnt_end    = (~last_data) ? (TOTAL_SPLIT - 1) : tail_offset;

        assign split_nvalid     = (first_data && last_data)  ? tail_offset - head_offset + 1 :
                                   first_data                ? TOTAL_SPLIT - head_offset     :
                                   last_data                 ? tail_offset + 1               :
                                   TOTAL_SPLIT;
        always @(posedge ACLK)
        begin
            if (ARESET)
                split_cnt_buf <= 0;
            else if (ACLK_EN) begin 
                if (last_split)
                    split_cnt_buf <= 0;
                else if (next_split)
                    split_cnt_buf <= split_cnt + 1;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                first_beat <= 1'b1;
            else if (ACLK_EN) begin
                if (next_offset)
                    first_beat <= 1'b1;
                else if (first_beat && last_split)
                    first_beat <= 1'b0;
            end
        end

        always @(posedge ACLK)
        begin
            if (ACLK_EN) begin
                if (first_split & first_data)
                    data_buf <= tmp_rdata >> (head_offset * USER_DATA_WIDTH);
                else if (first_split)
                    data_buf <= tmp_rdata;
                else if (next_split)
                    data_buf <= data_buf >> USER_DATA_WIDTH;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_valid <= 1'b0;
            else if (ACLK_EN) begin
                if (first_split)
                    data_valid <= 1'b1;
                else if (~ready_for_split && ready_for_data)
                    data_valid <= 1'b0;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_nvalid <= 0;
            else if (ACLK_EN) begin
                if (first_split)
                    data_nvalid <= split_nvalid;
                else if (next_split)
                    data_nvalid <= data_nvalid - 1;
                else if (~ready_for_split && ready_for_data)
                    data_nvalid <= 0;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                rdata_nvalid <= 0;
            else if (ACLK_EN) begin
                if (~tmp_rvalid)
                    rdata_nvalid <= 0;
                else if (~next_beat)
                    rdata_nvalid <= ((beat_nvalid + 1) << SPLIT_ALIGN);
                else
                    rdata_nvalid <= (beat_nvalid << SPLIT_ALIGN);
            end
        end
        
    end
    else begin : bus_narrow_gen
        localparam
            TOTAL_PADS      = USER_DATA_WIDTH / BUS_DATA_WIDTH,
            PAD_ALIGN       = log2(TOTAL_PADS);

        reg [USER_DATA_WIDTH-1 : 0] data_buf;
        reg                         data_valid;
        reg [PAD_ALIGN:0]           data_nvalid;
        wire                        ready_for_data;
        wire [USER_RFIFONUM_WIDTH-1 : 0] rdata_num_vld;

        wire [TOTAL_PADS - 1:0]     pad_oh;
        reg  [TOTAL_PADS - 1:0]     pad_oh_reg;

        reg                         first_pad;
        wire                        last_pad;
        wire                        next_pad;

        assign rreq_ready       = 1'b1; 
        assign next_beat        = next_pad;
        assign rdata_num_vld    = beat_nvalid[log2(RBUFF_DEPTH) : PAD_ALIGN] + (beat_nvalid[PAD_ALIGN-1:0] + data_nvalid) >> PAD_ALIGN;
        
        // regslice io ?  no
        assign out_HLS_RDATA    = data_buf[USER_DW-1 : 0];
        assign out_HLS_RVALID   = data_valid;
        assign out_HLS_RFIFONUM = rdata_num_vld;
        assign ready_for_data   = ~data_valid | in_HLS_RREADY;// 

        assign next_pad         = beat_valid && ready_for_data;
        assign last_pad         = pad_oh[TOTAL_PADS - 1];

        always @(posedge ACLK)
        begin
            if (ARESET)
                first_pad <= 1'b1;
            else if (ACLK_EN) begin
                if (next_pad && ~last_pad)
                    first_pad <= 1'b0;
                else if (next_pad && last_pad)
                    first_pad <= 1'b1;
            end
        end

        assign pad_oh = (beat_valid == 0)  ?  0 :
                        (first_pad)        ?  1 :
                        pad_oh_reg;
 
        always @(posedge ACLK)
        begin
            if (ARESET)
                pad_oh_reg <= 0;
            else if (ACLK_EN) begin
                if (next_pad)
                    pad_oh_reg <= {pad_oh[TOTAL_PADS - 2:0], 1'b0};
            end
        end

        genvar  i;
        for (i = 0; i < TOTAL_PADS; i = i + 1) begin : data_gen
            always @(posedge ACLK)
            begin
                if (ACLK_EN) begin
                    if (pad_oh[i] == 1'b1 && ready_for_data)
                        data_buf[i*BUS_DATA_WIDTH +: BUS_DATA_WIDTH] <= beat_data;
                end
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_valid <= 1'b0;
            else if (ACLK_EN) begin
                if (next_beat)
                    data_valid <= 1'b1;
                else if (ready_for_data)
                    data_valid <= 1'b0;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_nvalid <= 0;
            else if (ACLK_EN) begin
                if (first_pad)
                    data_nvalid <= 1;
                else if (next_pad)
                    data_nvalid <= data_nvalid + 1;
            end
        end

    end
    endgenerate
    // end of RDATA PREPROCESSOR
    // ===================================================================

endmodule


module vadd_gmem1_m_axi_store
#(parameter
    C_TARGET_ADDR           = 32'h00000000,
    NUM_WRITE_OUTSTANDING   = 2,
    MAX_WRITE_BURST_LENGTH  = 16,
    BUS_ADDR_WIDTH          = 32,
    BUS_DATA_WIDTH          = 32,
    USER_DW                 = 16,
    USER_AW                 = 32,
    USER_MAXREQS            = 16,
    BUFFER_IMPL             = "auto"
)(
    // system signal
    input  wire                        ACLK,
    input  wire                        ARESET,
    input  wire                        ACLK_EN,
    // write address channel
    output wire [BUS_ADDR_WIDTH-1:0]   out_AXI_AWADDR,
    output wire [31:0]                 out_AXI_AWLEN,
    output wire                        out_AXI_AWVALID,
    input  wire                        in_AXI_AWREADY,
    // write data channel
    output wire [BUS_DATA_WIDTH-1:0]   out_AXI_WDATA,
    output wire [BUS_DATA_WIDTH/8-1:0] out_AXI_WSTRB,
    output wire                        out_AXI_WVALID,
    input  wire                        in_AXI_WREADY,
    // write response channel
    input  wire                        in_AXI_BVALID,
    output wire                        out_AXI_BREADY,

    // internal bus ports
    // write address
    input  wire [USER_AW-1:0]          in_HLS_AWADDR,
    input  wire [31:0]                 in_HLS_AWLEN,
    input  wire                        in_HLS_AWVALID,
    output wire                        out_HLS_AWREADY,
    // write data
    input  wire [USER_DW-1:0]          in_HLS_WDATA,
    input  wire [USER_DW/8-1:0]        in_HLS_WSTRB,
    input  wire                        in_HLS_WVALID,
    output wire                        out_HLS_WREADY,
    // write response
    output wire                        out_HLS_BVALID,
    input  wire                        in_HLS_BREADY
);

//------------------------Parameter----------------------
    localparam
        USER_DATA_WIDTH = calc_data_width(USER_DW),
        USER_DATA_BYTES = USER_DATA_WIDTH / 8,
        USER_ADDR_ALIGN = log2(USER_DATA_BYTES),
        BUS_DATA_BYTES  = BUS_DATA_WIDTH / 8,
        BUS_ADDR_ALIGN  = log2(BUS_DATA_BYTES),
        // wdata buffer size 
        WBUFF_DEPTH     = max(MAX_WRITE_BURST_LENGTH * BUS_DATA_WIDTH / USER_DATA_WIDTH, 1), 
        TARGET_ADDR     = C_TARGET_ADDR & (32'hffffffff << USER_ADDR_ALIGN); 

//------------------------Task and function--------------

    function integer max;
        input integer x;
        input integer y;
    begin
        max = (x > y) ? x : y;
    end
    endfunction

    function integer calc_data_width;
        input integer x;
        integer y;
    begin
        y = 8;
        while (y < x) y = y * 2;
        calc_data_width = y;
    end
    endfunction

    function integer log2;
        input integer x;
        integer n, m;
    begin
        n = 0;
        m = 1;
        while (m < x) begin
            n = n + 1;
            m = m * 2;
        end
        log2 = n;
    end
    endfunction

//------------------------Local signal-------------------

    wire                                next_wreq;
    wire                                ready_for_wreq;
    wire                                wreq_ready;

    wire [USER_AW-1 : 0]                wreq_addr;
    wire [31:0]                         wreq_len;
    wire                                wreq_valid;

    wire                                valid_length;

    reg  [USER_AW-1 : 0]                tmp_addr;
    reg  [31:0]                         tmp_len;
    reg                                 tmp_valid;

    wire                                next_wdata;
    wire                                wdata_valid;
    wire [USER_DW-1 : 0]                tmp_wdata;
    wire [USER_DW/8-1 : 0]              tmp_wstrb;

    wire                                wrsp_ready;
    wire                                wrsp_valid;
    wire                                wrsp_read;
    wire                                wrsp_type;

    wire                                ursp_ready;
    wire                                ursp_write;

    // regslice io ?  no 

//------------------------Instantiation------------------
    

    vadd_gmem1_m_axi_fifo #(
        .DATA_WIDTH     (USER_AW + 32),
        .ADDR_WIDTH     (log2(USER_MAXREQS)),
        .DEPTH          (USER_MAXREQS)
    ) fifo_wreq (
        .clk            (ACLK),
        .reset          (ARESET),
        .clk_en         (ACLK_EN),
        .if_full_n      (out_HLS_AWREADY),
        .if_write       (in_HLS_AWVALID),
        .if_din         ({in_HLS_AWLEN, in_HLS_AWADDR}),
        .if_empty_n     (wreq_valid),
        .if_read        (next_wreq),
        .if_dout        ({wreq_len, wreq_addr}),
        .if_num_data_valid());

    assign next_wreq = wreq_valid && ready_for_wreq && wrsp_ready;
    assign ready_for_wreq  = ~tmp_valid || (in_AXI_AWREADY && wreq_ready);

    assign valid_length    = (wreq_len != 32'b0) && !wreq_len[31];

    assign out_AXI_AWLEN   = tmp_len;   // Byte length
    assign out_AXI_AWADDR  = tmp_addr;  // Byte address
    assign out_AXI_AWVALID = tmp_valid && wreq_ready;

    always @(posedge ACLK)
    begin
        if (ARESET) begin
            tmp_len  <= 0;
            tmp_addr <= 0;
        end
        else if (ACLK_EN) begin
            if(next_wreq) begin
                tmp_len  <= (wreq_len << USER_ADDR_ALIGN) - 1;
                tmp_addr <= TARGET_ADDR + (wreq_addr << USER_ADDR_ALIGN);
            end
        end
    end
 
    always @(posedge ACLK) 
    begin
        if (ARESET)
            tmp_valid <= 1'b0;
        else if (next_wreq && valid_length)
            tmp_valid <= 1'b1;
        else if (in_AXI_AWREADY && wreq_ready)
            tmp_valid <= 1'b0;
    end

    // ===================================================================

    

    
    vadd_gmem1_m_axi_fifo #(
        .MEM_STYLE         (BUFFER_IMPL),
        .DATA_WIDTH        (USER_DW + USER_DW/8),
        .ADDR_WIDTH        (log2(WBUFF_DEPTH)),
        .DEPTH             (WBUFF_DEPTH)
    ) buff_wdata (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        .if_full_n         (out_HLS_WREADY),
        .if_write          (in_HLS_WVALID),
        .if_din            ({in_HLS_WSTRB , in_HLS_WDATA}),
        .if_empty_n        (wdata_valid),
        .if_read           (next_wdata),
        .if_dout           ({tmp_wstrb, tmp_wdata}),
        .if_num_data_valid ());

    generate
    if (USER_DATA_WIDTH == BUS_DATA_WIDTH) begin : bus_equal_gen
        assign next_wdata       = in_AXI_WREADY;
        assign out_AXI_WVALID   = wdata_valid;
        assign out_AXI_WDATA    = tmp_wdata;
        assign out_AXI_WSTRB    = tmp_wstrb;

        assign wreq_ready   = 1'b1;

    end
    else if (USER_DATA_WIDTH < BUS_DATA_WIDTH) begin : bus_wide_gen
        localparam
            TOTAL_PADS      = BUS_DATA_WIDTH / USER_DATA_WIDTH,
            PAD_ALIGN       = log2(TOTAL_PADS),
            BEAT_LEN_WIDTH  = 32 - BUS_ADDR_ALIGN;

        function [TOTAL_PADS-1 : 0] decoder;
            input [PAD_ALIGN-1 : 0] din;
            reg  [TOTAL_PADS-1 : 0] dout;
            integer i;
        begin
            dout = {TOTAL_PADS{1'b0}};
            for (i = 0; i < din; i = i + 1)
                dout[i] = 1'b1;
            decoder = dout;
        end
        endfunction

        wire [USER_AW - 1:0]        tmp_addr_end;

        wire                        offset_full_n;
        wire                        offset_write;
        wire [PAD_ALIGN-1 : 0]      start_offset;
        wire [PAD_ALIGN-1 : 0]      end_offset;
        wire [BEAT_LEN_WIDTH-1 : 0] beat_total;

        wire                        offset_empty_n;
        wire                        offset_read;
        wire [2*PAD_ALIGN+BEAT_LEN_WIDTH-1 : 0] offset_pack;
        reg  [2*PAD_ALIGN+BEAT_LEN_WIDTH-1 : 0] offset_pack_reg;

        reg                         offset_valid;
        wire                        next_offset;
        wire [PAD_ALIGN-1 : 0]      head_offset;
        wire [PAD_ALIGN-1 : 0]      tail_offset;

        wire [BEAT_LEN_WIDTH-1 : 0] beat_len;
        reg  [BEAT_LEN_WIDTH-1:0]   len_cnt_buf;
        wire [BEAT_LEN_WIDTH-1:0]   len_cnt_tmp;

        wire [TOTAL_PADS - 1:0]     add_head;
        wire [TOTAL_PADS - 1:0]     add_tail;
        wire [TOTAL_PADS - 1:0]     pad_oh;
        reg  [TOTAL_PADS - 1:0]     pad_oh_reg;

        wire [TOTAL_PADS-1 : 0]     head_pad_sel;
        wire [0 : TOTAL_PADS-1]     tail_pad_sel; // reverse
        wire                        ready_for_data;
        wire                        next_pad;
        reg                         first_pad;
        wire                        last_pad;

        reg                         first_beat_set;
        reg                         last_beat_set;
        reg                         single_beat;
        wire                        first_beat;
        wire                        last_beat;
        wire                        next_beat;

        reg  [BUS_DATA_WIDTH - 1:0] data_buf;
        reg  [BUS_DATA_BYTES - 1:0] strb_buf;
        reg                         data_valid;

        // Recording the offset of start & end address to align beats from data USER_DW < BUS_DW.
        vadd_gmem1_m_axi_fifo #(
            .DATA_WIDTH             (2*PAD_ALIGN + BEAT_LEN_WIDTH),
            .ADDR_WIDTH             (log2(NUM_WRITE_OUTSTANDING)),
            .DEPTH                  (NUM_WRITE_OUTSTANDING)
        ) wreq_offset (
            .clk                    (ACLK),
            .reset                  (ARESET),
            .clk_en                 (ACLK_EN),
            .if_full_n              (offset_full_n),
            .if_write               (offset_write),
            .if_din                 ({start_offset, end_offset, beat_total}),
            .if_empty_n             (offset_empty_n),
            .if_read                (offset_read),
            .if_dout                (offset_pack),
            .if_num_data_valid      ());

        assign wreq_ready     = offset_full_n | ~offset_write;
        assign tmp_addr_end   = tmp_addr + tmp_len;

        assign start_offset   = tmp_addr[BUS_ADDR_ALIGN-1 : 0] >> USER_ADDR_ALIGN;
        assign end_offset     = ~tmp_addr_end[BUS_ADDR_ALIGN-1 : 0] >> USER_ADDR_ALIGN;
        assign beat_total     = (tmp_len + tmp_addr[BUS_ADDR_ALIGN-1 : 0]) >> BUS_ADDR_ALIGN;

        assign offset_write   = tmp_valid & in_AXI_AWREADY;
        assign offset_read    = ~offset_valid | next_offset;

        assign {head_offset, tail_offset, beat_len} = offset_pack_reg;

        assign out_AXI_WDATA  = data_buf;
        assign out_AXI_WSTRB  = strb_buf;
        assign out_AXI_WVALID = data_valid;

        assign next_wdata     = next_pad;
        assign next_offset    = last_beat && next_beat;
        assign ready_for_data = ~data_valid || in_AXI_WREADY;

        assign len_cnt_tmp    = first_beat ? beat_len : len_cnt_buf;
        assign first_beat     = first_beat_set && offset_valid;
        assign last_beat      = (single_beat || last_beat_set) && offset_valid;
        assign next_beat      = offset_valid && last_pad && ready_for_data;

        assign next_pad       = offset_valid && wdata_valid && ready_for_data;
        assign last_pad       = (last_beat) ? pad_oh[TOTAL_PADS-tail_offset-1] : pad_oh[TOTAL_PADS-1];

        assign head_pad_sel   = decoder(head_offset);
        assign tail_pad_sel   = decoder(tail_offset);

        always @(posedge ACLK)
        begin
            if (ARESET) begin
                single_beat <= 1'b0;
                offset_pack_reg <= 0;
            end
            else if (ACLK_EN) begin
                if (offset_empty_n && offset_read) begin
                    single_beat     <= (offset_pack[BEAT_LEN_WIDTH-1:0] == 0);
                    offset_pack_reg <= offset_pack;
                end
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                offset_valid <= 1'b0;
            else if (ACLK_EN) begin
                if (offset_empty_n && offset_read)
                    offset_valid <= 1'b1;
                else if (next_offset)
                    offset_valid <= 1'b0;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                len_cnt_buf <= 0;
            else if (ACLK_EN) begin
                if (next_beat)
                    len_cnt_buf <= len_cnt_tmp - 1;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET) begin
                first_beat_set <= 1'b1;
                last_beat_set  <= 1'b0;
            end
            else if (ACLK_EN) begin
                if (next_offset) begin
                    first_beat_set <= 1'b1;
                    last_beat_set  <= 1'b0;
                end
                else if (next_beat) begin
                    first_beat_set <= 1'b0;
                    last_beat_set  <= (len_cnt_tmp == 1);
                end
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                first_pad <= 1'b1;
            else if (ACLK_EN) begin
                if (next_pad && ~last_pad)
                    first_pad <= 1'b0;
                else if (next_pad && last_pad)
                    first_pad <= 1'b1;
            end
        end 
        
        assign pad_oh = (~wdata_valid)            ? 0                :
                        (first_pad && first_beat) ? 1 << head_offset :
                        (first_pad)?                1                :
                        pad_oh_reg;

        always @(posedge ACLK)
        begin
            if (ARESET)
                pad_oh_reg <= 0;
            else if (ACLK_EN) begin
                if (next_pad)
                    pad_oh_reg <= {pad_oh[TOTAL_PADS - 2:0], 1'b0};
            end
        end

        genvar  i;
        for (i = 0; i < TOTAL_PADS; i = i + 1) begin : data_gen
            assign add_head[i] = head_pad_sel[i] && first_beat;
            assign add_tail[i] = tail_pad_sel[i] && last_beat;

            always @(posedge ACLK)
            begin
                if (ARESET)
                    data_buf[i*USER_DATA_WIDTH +: USER_DATA_WIDTH] <= {USER_DATA_WIDTH{1'b0}};
                else if (ACLK_EN) begin
                    if ((add_head[i] || add_tail[i]) && ready_for_data)
                        data_buf[i*USER_DATA_WIDTH +: USER_DATA_WIDTH] <= {USER_DATA_WIDTH{1'b0}};
                    else if (pad_oh[i] == 1'b1 && ready_for_data)
                        data_buf[i*USER_DATA_WIDTH +: USER_DATA_WIDTH] <= tmp_wdata;
                end
            end

            always @(posedge ACLK)
            begin
                if (ARESET)
                    strb_buf[i*USER_DATA_BYTES +: USER_DATA_BYTES] <= {USER_DATA_BYTES{1'b0}};
                else if (ACLK_EN) begin
                    if ((add_head[i] || add_tail[i]) && ready_for_data)
                        strb_buf[i*USER_DATA_BYTES +: USER_DATA_BYTES] <= {USER_DATA_BYTES{1'b0}};
                    else if (pad_oh[i] == 1'b1 && ready_for_data)
                        strb_buf[i*USER_DATA_BYTES +: USER_DATA_BYTES] <= tmp_wstrb;
                end
            end

        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_valid <= 1'b0;
            else if (ACLK_EN) begin
                if (next_beat)
                    data_valid <= 1'b1;
                else if (ready_for_data)
                    data_valid <= 1'b0;
            end
        end

    end
    else begin : bus_narrow_gen
        localparam
            TOTAL_SPLIT       = USER_DATA_WIDTH / BUS_DATA_WIDTH,
            SPLIT_ALIGN       = log2(TOTAL_SPLIT),
            BEAT_LEN_WIDTH    = 32 - BUS_ADDR_ALIGN;


        wire [USER_AW - 1:0]        tmp_addr_end;

        wire                        offset_full_n;
        wire                        offset_write;
        wire  [BEAT_LEN_WIDTH-1 : 0] beat_total;

        wire                        offset_valid;
        wire                        next_offset;

        wire [BEAT_LEN_WIDTH-1 : 0] beat_len;
        reg  [BEAT_LEN_WIDTH-1 : 0] len_cnt;

        wire                        ready_for_data;
        reg  [BUS_DATA_WIDTH - 1:0] data_buf;
        reg  [BUS_DATA_BYTES - 1:0] strb_buf;
        reg                         data_valid;

        reg [SPLIT_ALIGN-1 : 0]     split_cnt;

        wire                        first_split;
        wire                        next_split;
        wire                        last_split;

        // Recording the offset of start & end address to align beats from data USER_DW < BUS_DW.
        vadd_gmem1_m_axi_fifo #(
            .DATA_WIDTH        (BEAT_LEN_WIDTH),
            .ADDR_WIDTH        (log2(NUM_WRITE_OUTSTANDING)),
            .DEPTH             (NUM_WRITE_OUTSTANDING)
        ) wreq_offset (
            .clk               (ACLK),
            .reset             (ARESET),
            .clk_en            (ACLK_EN),
            .if_full_n         (offset_full_n),
            .if_write          (offset_write),
            .if_din            (beat_total),
            .if_empty_n        (offset_valid),
            .if_read           (next_offset),
            .if_dout           (beat_len),
            .if_num_data_valid ());

        assign wreq_ready     = offset_full_n | ~offset_write;
        assign beat_total     = (tmp_len + tmp_addr[BUS_ADDR_ALIGN-1 : 0]) >> BUS_ADDR_ALIGN;

        assign offset_write   = tmp_valid & in_AXI_AWREADY;

        assign out_AXI_WDATA  = data_buf[BUS_DATA_WIDTH - 1:0];
        assign out_AXI_WSTRB  = strb_buf[BUS_DATA_BYTES - 1:0];
        assign out_AXI_WVALID = data_valid;

        assign next_wdata     = first_split;
        assign next_offset    = (len_cnt == beat_len) && offset_valid && last_split;
        assign ready_for_data = ~data_valid | in_AXI_WREADY;

        assign first_split    = (split_cnt == 0) && wdata_valid && offset_valid && ready_for_data;
        assign last_split     = (split_cnt == (TOTAL_SPLIT - 1)) && ready_for_data;
        assign next_split     = (split_cnt != 0) && ready_for_data;
        
        always @(posedge ACLK)
        begin
            if (ARESET)
                split_cnt <= 0;
            else if (ACLK_EN) begin
                if (last_split)
                    split_cnt <= 0;
                else if (first_split || next_split)
                    split_cnt <= split_cnt + 1;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                len_cnt <= 0;
            else if (ACLK_EN) begin
                if (next_offset)
                    len_cnt <= 0;
                else if (next_wdata || next_split)
                    len_cnt <= len_cnt + 1;
            end
        end
 
        always @(posedge ACLK)
        begin
            if (ACLK_EN) begin
                if (next_wdata)
                    data_buf <= tmp_wdata;
                else if (next_split)
                    data_buf <= data_buf >> BUS_DATA_WIDTH;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                strb_buf <= 0;
            else if (ACLK_EN) begin
                if (next_wdata)
                    strb_buf <= tmp_wstrb;
                else if (next_split)
                    strb_buf <= strb_buf >> BUS_DATA_BYTES;
            end
        end

        always @(posedge ACLK)
        begin
            if (ARESET)
                data_valid <= 0;
            else if (ACLK_EN) begin
                if (next_wdata)
                    data_valid <= 1;
                else if (~(first_split || next_split) && ready_for_data)
                    data_valid <= 0;
            end
        end
    end
    endgenerate

    // ===================================================================

    // generate response for all request (including request with invalid length)
    vadd_gmem1_m_axi_fifo #(
        .DATA_WIDTH        (1),
        .ADDR_WIDTH        (log2(NUM_WRITE_OUTSTANDING)),
        .DEPTH             (NUM_WRITE_OUTSTANDING)
    ) fifo_wrsp (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        .if_full_n         (wrsp_ready),
        .if_write          (next_wreq),
        .if_din            (valid_length),
        .if_empty_n        (wrsp_valid),
        .if_read           (wrsp_read),
        .if_dout           (wrsp_type), // 1 - valid length request, 0 - invalid length request
        .if_num_data_valid ());

    vadd_gmem1_m_axi_fifo #(
        .DATA_WIDTH        (1),
        .ADDR_WIDTH        (log2(USER_MAXREQS)),
        .DEPTH             (USER_MAXREQS)
    ) user_resp (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        .if_full_n         (ursp_ready),
        .if_write          (ursp_write),
        .if_din            (1'b1),
        .if_empty_n        (out_HLS_BVALID),
        .if_read           (in_HLS_BREADY),
        .if_dout           (),
        .if_num_data_valid ());

    

    assign ursp_write  = wrsp_valid && (!wrsp_type || in_AXI_BVALID);
    assign wrsp_read   = ursp_ready && ursp_write;

    assign out_AXI_BREADY = wrsp_type && ursp_ready;

endmodule
// 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689

`timescale 1ns/1ps

//


module vadd_gmem1_m_axi_read
#(parameter
    C_M_AXI_ID_WIDTH          = 1,
    C_M_AXI_ARUSER_WIDTH      = 1,
    C_M_AXI_RUSER_WIDTH       = 1,
    C_USER_VALUE              = 1'b0,
    C_PROT_VALUE              = 3'b000,
    C_CACHE_VALUE             = 4'b0011,
    BUS_ADDR_WIDTH            = 32,
    BUS_DATA_WIDTH            = 32,
    NUM_READ_OUTSTANDING      = 2,
    MAX_READ_BURST_LENGTH     = 16
)(
    // system signal
    input  wire                            ACLK,
    input  wire                            ARESET,
    input  wire                            ACLK_EN,
    // read address channel
    output wire [C_M_AXI_ID_WIDTH-1:0]     out_BUS_ARID,
    output wire [BUS_ADDR_WIDTH-1:0]       out_BUS_ARADDR,
    output wire [7:0]                      out_BUS_ARLEN,
    output wire [2:0]                      out_BUS_ARSIZE,
    output wire [1:0]                      out_BUS_ARBURST,
    output wire [1:0]                      out_BUS_ARLOCK,
    output wire [3:0]                      out_BUS_ARCACHE,
    output wire [2:0]                      out_BUS_ARPROT,
    output wire [3:0]                      out_BUS_ARQOS,
    output wire [3:0]                      out_BUS_ARREGION,
    output wire [C_M_AXI_ARUSER_WIDTH-1:0] out_BUS_ARUSER,
    output wire                            out_BUS_ARVALID,
    input  wire                            in_BUS_ARREADY,
    // read data channel
    input  wire [C_M_AXI_ID_WIDTH-1:0]     in_BUS_RID,
    input  wire [BUS_DATA_WIDTH-1:0]       in_BUS_RDATA,
    input  wire [1:0]                      in_BUS_RRESP,
    input  wire                            in_BUS_RLAST,
    input  wire [C_M_AXI_RUSER_WIDTH-1:0]  in_BUS_RUSER,
    input  wire                            in_BUS_RVALID,
    output wire                            out_BUS_RREADY,

    // HLS internal read request channel
    input  wire [BUS_ADDR_WIDTH-1:0]       in_HLS_ARADDR,
    input  wire [31:0]                     in_HLS_ARLEN,
    input  wire                            in_HLS_ARVALID,
    output wire                            out_HLS_ARREADY,
    output wire [BUS_DATA_WIDTH-1:0]       out_HLS_RDATA,
    output wire [1:0]                      out_HLS_RLAST,
    output wire                            out_HLS_RVALID,
    input  wire                            in_HLS_RREADY,
    input  wire                            in_HLS_RBUST_READY);

//------------------------Parameter----------------------
    localparam
        BUS_DATA_BYTES  = BUS_DATA_WIDTH / 8,
        BUS_ADDR_ALIGN  = log2(BUS_DATA_BYTES);

//------------------------Task and function--------------
    function integer log2;
        input integer x;
        integer n, m;
    begin
        n = 0;
        m = 1;
        while (m < x) begin
            n = n + 1;
            m = m * 2;
        end
        log2 = n;
    end
    endfunction

//------------------------Local signal-------------------
    // AR channel
    wire                          ost_ctrl_info;
    wire                          ost_ctrl_valid;
    wire                          ost_ctrl_ready;

    // R channel
    wire [BUS_DATA_WIDTH-1:0]     tmp_data;
    wire                          tmp_last;
    wire                          data_valid;
    wire                          data_ready;
    wire                          next_ctrl;
    wire                          need_rlast;
    wire                          burst_valid;
    wire                          last_burst;
    wire                          fifo_rctl_ready;
    wire                          next_burst;
    wire                          burst_end;

    // regslice io ?  no 

//------------------------AR channel begin---------------
//------------------------Instantiation------------------
    vadd_gmem1_m_axi_burst_converter #(
        .DATA_WIDTH        (BUS_DATA_WIDTH),
        .ADDR_WIDTH        (BUS_ADDR_WIDTH),
        .MAX_BURST_LEN     (MAX_READ_BURST_LENGTH)
    ) rreq_burst_conv (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),

        .in_REQ_ADDR       (in_HLS_ARADDR),
        .in_REQ_LEN        (in_HLS_ARLEN),
        .in_REQ_VALID      (in_HLS_ARVALID),
        .out_REQ_READY     (out_HLS_ARREADY),
         
        .out_BURST_ADDR    (out_BUS_ARADDR),
        .out_BURST_LEN     (out_BUS_ARLEN),
        .out_BURST_VALID   (out_BUS_ARVALID),
        .in_BURST_READY    (in_BUS_ARREADY),

        .out_CTRL_INFO     (ost_ctrl_info),
        .out_CTRL_LEN      (),
        .out_CTRL_VALID    (ost_ctrl_valid),
        .in_CTRL_READY     (ost_ctrl_ready)
    );
    
    
//------------------------Body---------------------------

    assign out_BUS_ARID     = 0;
    assign out_BUS_ARSIZE   = BUS_ADDR_ALIGN;
    assign out_BUS_ARBURST  = 2'b01;
    assign out_BUS_ARLOCK   = 2'b00;
    assign out_BUS_ARCACHE  = C_CACHE_VALUE;
    assign out_BUS_ARPROT   = C_PROT_VALUE;
    assign out_BUS_ARUSER   = C_USER_VALUE;
    assign out_BUS_ARQOS    = 4'b0000;
    assign out_BUS_ARREGION = 4'b0000;

//------------------------AR channel end-----------------

//------------------------R channel begin----------------
//------------------------Instantiation------------------
    vadd_gmem1_m_axi_reg_slice #(
        .DATA_WIDTH     (BUS_DATA_WIDTH + 1)
    ) rs_rdata (
        .clk            (ACLK),
        .reset          (ARESET),
        .s_data         ({in_BUS_RLAST, in_BUS_RDATA}),
        .s_valid        (in_BUS_RVALID),
        .s_ready        (out_BUS_RREADY),
        .m_data         ({tmp_last, tmp_data}),
        .m_valid        (data_valid),
        .m_ready        (data_ready));

    vadd_gmem1_m_axi_fifo #(
        .DATA_WIDTH     (1),
        .ADDR_WIDTH     (log2(NUM_READ_OUTSTANDING)),
        .DEPTH          (NUM_READ_OUTSTANDING)
    ) fifo_rctl (
        .clk            (ACLK),
        .reset          (ARESET),
        .clk_en         (ACLK_EN),
        .if_full_n      (ost_ctrl_ready),
        .if_write       (ost_ctrl_valid),
        .if_din         (ost_ctrl_info),
        .if_empty_n     (need_rlast),
        .if_read        (next_ctrl),
        .if_dout        (),
        .if_num_data_valid());

    vadd_gmem1_m_axi_fifo #(
        .DATA_WIDTH     (1),
        .ADDR_WIDTH     (log2(NUM_READ_OUTSTANDING)),
        .DEPTH          (NUM_READ_OUTSTANDING)
    ) fifo_burst (
        .clk            (ACLK),
        .reset          (ARESET),
        .clk_en         (ACLK_EN),
        .if_full_n      (),
        .if_write       (ost_ctrl_valid),
        .if_din         (ost_ctrl_info),
        .if_empty_n     (burst_valid),
        .if_read        (next_burst),
        .if_dout        (last_burst),
        .if_num_data_valid());

//------------------------Body---------------------------
    assign next_ctrl      = in_HLS_RBUST_READY && need_rlast;
    assign next_burst     = burst_end && data_valid && data_ready;

    assign burst_end      = tmp_last === 1'b1;
    assign out_HLS_RLAST  = {burst_end, burst_end && last_burst && burst_valid};
    assign out_HLS_RDATA  = tmp_data;
    assign out_HLS_RVALID = data_valid;
    assign data_ready     = in_HLS_RREADY;
//------------------------R channel end------------------
endmodule

module vadd_gmem1_m_axi_write
#(parameter
    CONSERVATIVE              = 0,
    C_M_AXI_ID_WIDTH          = 1,
    C_M_AXI_AWUSER_WIDTH      = 1,
    C_M_AXI_WUSER_WIDTH       = 1,
    C_M_AXI_BUSER_WIDTH       = 1,
    C_USER_VALUE              = 1'b0,
    C_PROT_VALUE              = 3'b000,
    C_CACHE_VALUE             = 4'b0011,
    BUS_ADDR_WIDTH            = 32,
    BUS_DATA_WIDTH            = 32,
    NUM_WRITE_OUTSTANDING     = 2,
    MAX_WRITE_BURST_LENGTH    = 16
)(
    // system signal
    input  wire                             ACLK,
    input  wire                             ARESET,
    input  wire                             ACLK_EN,
    // write address channel
    output wire [C_M_AXI_ID_WIDTH-1:0]      out_BUS_AWID,
    output wire [2:0]                       out_BUS_AWSIZE,
    output wire [1:0]                       out_BUS_AWBURST,
    output wire [1:0]                       out_BUS_AWLOCK,
    output wire [3:0]                       out_BUS_AWCACHE,
    output wire [2:0]                       out_BUS_AWPROT,
    output wire [3:0]                       out_BUS_AWQOS,
    output wire [3:0]                       out_BUS_AWREGION,
    output wire [C_M_AXI_AWUSER_WIDTH-1:0]  out_BUS_AWUSER,
    output wire [BUS_ADDR_WIDTH-1:0]        out_BUS_AWADDR,
    output wire [7:0]                       out_BUS_AWLEN,
    output wire                             out_BUS_AWVALID,
    input  wire                             in_BUS_AWREADY,
    // write data channel
    output wire [C_M_AXI_ID_WIDTH-1:0]      out_BUS_WID,
    output wire [C_M_AXI_WUSER_WIDTH-1:0]   out_BUS_WUSER,
    output wire [BUS_DATA_WIDTH-1:0]        out_BUS_WDATA,
    output wire [BUS_DATA_WIDTH/8-1:0]      out_BUS_WSTRB,
    output wire                             out_BUS_WLAST,
    output wire                             out_BUS_WVALID,
    input  wire                             in_BUS_WREADY,
    // write response channel
    input  wire [C_M_AXI_ID_WIDTH-1:0]      in_BUS_BID,
    input  wire [1:0]                       in_BUS_BRESP,
    input  wire [C_M_AXI_BUSER_WIDTH-1:0]   in_BUS_BUSER,
    input  wire                             in_BUS_BVALID,
    output wire                             out_BUS_BREADY,
    // write request
    input  wire [BUS_ADDR_WIDTH-1:0]        in_HLS_AWADDR,
    input  wire [31:0]                      in_HLS_AWLEN,
    input  wire                             in_HLS_AWVALID,
    output wire                             out_HLS_AWREADY,

    input  wire [BUS_DATA_WIDTH-1:0]        in_HLS_WDATA,
    input  wire [BUS_DATA_WIDTH/8-1:0]      in_HLS_WSTRB,
    input  wire                             in_HLS_WVALID,
    output wire                             out_HLS_WREADY,
    output wire                             out_HLS_BVALID,
    input  wire                             in_HLS_BREADY);

//------------------------Parameter----------------------
    localparam
        BUS_DATA_BYTES  = BUS_DATA_WIDTH / 8,
        BUS_ADDR_ALIGN  = log2(BUS_DATA_BYTES);

//------------------------Task and function--------------
    function integer log2;
        input integer x;
        integer n, m;
    begin
        n = 0;
        m = 1;
        while (m < x) begin
            n = n + 1;
            m = m * 2;
        end
        log2 = n;
    end
    endfunction

//------------------------Local signal-------------------
    // AW channel
    wire [C_M_AXI_ID_WIDTH-1:0]         AWID_Dummy;
    wire [BUS_ADDR_WIDTH - 1:0]         AWADDR_Dummy;
    wire [7:0]                          AWLEN_Dummy;
    wire                                AWVALID_Dummy;
    wire                                AWREADY_Dummy;
 
    wire                                ost_ctrl_info;
    wire [7:0]                          ost_ctrl_len;
    wire                                ost_ctrl_valid;
    wire                                ost_ctrl_ready;

    // W channel
    wire                                next_data;
    wire                                data_valid;
    wire                                data_ready;
    reg  [BUS_DATA_WIDTH - 1:0]         data_buf;
    reg  [BUS_DATA_BYTES - 1:0]         strb_buf;
    wire                                ready_for_data;

    reg  [7:0]                          len_cnt;
    wire [7:0]                          burst_len;
    wire                                fifo_burst_ready;
    wire                                next_burst;
    wire                                burst_valid;
    reg                                 WVALID_Dummy;
    wire                                WREADY_Dummy;
    reg                                 WLAST_Dummy;
    //B channel
    wire                                next_resp;
    wire                                last_resp;
    wire                                need_wrsp;
    wire                                resp_valid;
    wire                                resp_ready;

    // regslice io ?  no 

//------------------------AW channel begin---------------
//------------------------Instantiation------------------
    vadd_gmem1_m_axi_burst_converter #(
        .DATA_WIDTH        (BUS_DATA_WIDTH),
        .ADDR_WIDTH        (BUS_ADDR_WIDTH),
        .MAX_BURST_LEN     (MAX_WRITE_BURST_LENGTH)
    ) wreq_burst_conv (
        .clk               (ACLK),
        .reset             (ARESET),
        .clk_en            (ACLK_EN),
        
        .in_REQ_ADDR       (in_HLS_AWADDR),
        .in_REQ_LEN        (in_HLS_AWLEN),
        .in_REQ_VALID      (in_HLS_AWVALID),
        .out_REQ_READY     (out_HLS_AWREADY),

        .out_BURST_ADDR    (AWADDR_Dummy),
        .out_BURST_LEN     (AWLEN_Dummy),
        .out_BURST_VALID   (AWVALID_Dummy),
        .in_BURST_READY    (AWREADY_Dummy),

        .out_CTRL_INFO     (ost_ctrl_info),
        .out_CTRL_LEN      (ost_ctrl_len),
        .out_CTRL_VALID    (ost_ctrl_valid),
        .in_CTRL_READY     (ost_ctrl_ready)
    );

    // burst converter
    assign out_BUS_AWID     = 0;
    assign out_BUS_AWSIZE   = BUS_ADDR_ALIGN;
    assign out_BUS_AWBURST  = 2'b01;
    assign out_BUS_AWLOCK   = 2'b00;
    assign out_BUS_AWCACHE  = C_CACHE_VALUE;
    assign out_BUS_AWPROT   = C_PROT_VALUE;
    assign out_BUS_AWUSER   = C_USER_VALUE;
    assign out_BUS_AWQOS    = 4'b0000;
    assign out_BUS_AWREGION = 4'b0000;

//------------------------AW channel end-----------------

//------------------------W channel begin----------------
//------------------------Instantiation------------------

    vadd_gmem1_m_axi_fifo #(
        .DATA_WIDTH     (8),
        .ADDR_WIDTH     (log2(NUM_WRITE_OUTSTANDING)),
        .DEPTH          (NUM_WRITE_OUTSTANDING)
    ) fifo_burst (
        .clk            (ACLK),
        .reset          (ARESET),
        .clk_en         (ACLK_EN),
        .if_full_n      (),
        .if_write       (ost_ctrl_valid),
        .if_din         (ost_ctrl_len),
        .if_empty_n     (burst_valid),
        .if_read        (next_burst),
        .if_dout        (burst_len),
        .if_num_data_valid());

//------------------------Body---------------------------

    assign out_BUS_WUSER    = C_USER_VALUE;
    assign out_BUS_WID      = 0;
    assign out_HLS_WREADY   = data_ready;

    assign data_valid       = in_HLS_WVALID;
    assign data_ready       = burst_valid && ready_for_data;
    assign next_data        = data_ready && data_valid;
    assign next_burst       = (len_cnt == burst_len) && next_data;
    assign ready_for_data   = ~WVALID_Dummy || WREADY_Dummy;

    always @(posedge ACLK)
    begin
        if (ARESET) begin
            strb_buf <= 0;
            data_buf <= 0;
        end
        if (ACLK_EN) begin
            if (next_data) begin
                data_buf <= in_HLS_WDATA;
                strb_buf <= in_HLS_WSTRB;
            end
        end
    end

    always @(posedge ACLK)
    begin
        if (ARESET)
            WVALID_Dummy <= 1'b0;
        else if (ACLK_EN) begin
            if (next_data)
                WVALID_Dummy <= 1'b1;
            else if (ready_for_data)
                WVALID_Dummy <= 1'b0;
        end
    end

    always @(posedge ACLK)
    begin
        if (ARESET)
            WLAST_Dummy <= 0;
        else if (ACLK_EN) begin
            if (next_burst)
                WLAST_Dummy <= 1;
            else if (ready_for_data)
                WLAST_Dummy <= 0;
        end
    end

    always @(posedge ACLK)
    begin
        if (ARESET)
            len_cnt <= 0;
        else if (ACLK_EN) begin
            if (next_burst)
                len_cnt <= 0;
            else if (next_data)
                len_cnt <= len_cnt + 1;
        end
    end
//------------------------W channel end------------------

    // Write throttling unit
    vadd_gmem1_m_axi_throttle #(
        .CONSERVATIVE    (CONSERVATIVE),
        .USED_FIX        (0),
        .ADDR_WIDTH      (BUS_ADDR_WIDTH),
        .DATA_WIDTH      (BUS_DATA_WIDTH),
        .DEPTH           (MAX_WRITE_BURST_LENGTH),
        .MAXREQS         (NUM_WRITE_OUTSTANDING),
        .AVERAGE_MODE    (0)
    ) wreq_throttle (
        .clk             (ACLK),
        .reset           (ARESET),
        .clk_en          (ACLK_EN),
        // internal 
        .in_TOP_AWADDR   (AWADDR_Dummy),
        .in_TOP_AWLEN    (AWLEN_Dummy),
        .in_TOP_AWVALID  (AWVALID_Dummy),
        .out_TOP_AWREADY (AWREADY_Dummy),

        .in_TOP_WDATA    (data_buf),
        .in_TOP_WSTRB    (strb_buf),
        .in_TOP_WLAST    (WLAST_Dummy),
        .in_TOP_WVALID   (WVALID_Dummy),
        .out_TOP_WREADY  (WREADY_Dummy),

        // AXI BUS 
        .out_BUS_AWADDR  (out_BUS_AWADDR),
        .out_BUS_AWLEN   (out_BUS_AWLEN),
        .out_BUS_AWVALID (out_BUS_AWVALID),
        .in_BUS_AWREADY  (in_BUS_AWREADY),

        .out_BUS_WDATA   (out_BUS_WDATA),
        .out_BUS_WSTRB   (out_BUS_WSTRB),
        .out_BUS_WLAST   (out_BUS_WLAST),
        .out_BUS_WVALID  (out_BUS_WVALID),
        .in_BUS_WREADY   (in_BUS_WREADY)
    );

    
    
//------------------------B channel begin----------------
//------------------------Instantiation------------------
    vadd_gmem1_m_axi_reg_slice #(
        .DATA_WIDTH     (1)
    ) rs_resp (
        .clk            (ACLK),
        .reset          (ARESET),
        .s_data         (1'b1),
        .s_valid        (in_BUS_BVALID),
        .s_ready        (out_BUS_BREADY),
        .m_data         (),
        .m_valid        (resp_valid),
        .m_ready        (resp_ready));

    vadd_gmem1_m_axi_fifo #(
        .DATA_WIDTH     (1),
        .ADDR_WIDTH     (log2(NUM_WRITE_OUTSTANDING)),
        .DEPTH          (NUM_WRITE_OUTSTANDING)
    ) fifo_resp (
        .clk            (ACLK),
        .reset          (ARESET),
        .clk_en         (ACLK_EN),
        .if_full_n      (ost_ctrl_ready),
        .if_write       (ost_ctrl_valid),
        .if_din         (ost_ctrl_info),
        .if_empty_n     (need_wrsp),
        .if_read        (next_resp),
        .if_dout        (last_resp),
        .if_num_data_valid());
//------------------------Body---------------------------

    assign resp_ready = need_wrsp && (in_HLS_BREADY || (last_resp === 1'b0));
    assign next_resp  = resp_ready && resp_valid;

    assign out_HLS_BVALID = resp_valid && (last_resp === 1'b1 ) ;

//------------------------B channel end------------------
endmodule


module vadd_gmem1_m_axi_burst_converter
#(parameter
    DATA_WIDTH                   = 32,
    ADDR_WIDTH                   = 32,
    MAX_BURST_LEN                = 16
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  clk_en,

    input  wire [ADDR_WIDTH-1:0] in_REQ_ADDR,
    input  wire [31:0]           in_REQ_LEN,
    input  wire                  in_REQ_VALID,
    output wire                  out_REQ_READY,

    output wire [ADDR_WIDTH-1:0] out_BURST_ADDR,
    output wire [7:0]            out_BURST_LEN,
    output wire                  out_BURST_VALID,
    input  wire                  in_BURST_READY,

    output wire                  out_CTRL_INFO,
    output wire [7:0]            out_CTRL_LEN,
    output wire                  out_CTRL_VALID,
    input  wire                  in_CTRL_READY
);
//------------------------Parameter----------------------
    localparam
        DATA_BYTES      = DATA_WIDTH / 8,
        ADDR_ALIGN      = log2(DATA_BYTES),
        BOUNDARY_BEATS  = {12-ADDR_ALIGN{1'b1}},
        NUM_BEAT_WIDTH  = log2(MAX_BURST_LEN);
//------------------------Task and function--------------
    function integer log2;
        input integer x;
        integer n, m;
        begin
            n = 0;
            m = 1;
            while (m < x) begin
                n = n + 1;
                m = m * 2;
            end
            log2 = n;
        end
    endfunction
//------------------------Local signal-------------------
    wire [ADDR_WIDTH-1:0]       tmp_addr;
    wire [31:0]                 tmp_len;

    wire                        req_valid;
    wire                        read_req;
    wire                        next_req;

    reg  [ADDR_WIDTH - 1:0]     start_addr;
    wire [ADDR_WIDTH - 1:0]     sect_addr;
    reg  [ADDR_WIDTH - 1:0]     sect_addr_buf;
    reg                         req_handling;

    reg  [11 - ADDR_ALIGN:0]    start_to_4k;
    reg  [11 - ADDR_ALIGN:0]    end_from_4k;
    wire [11 - ADDR_ALIGN:0]    sect_len;
    reg  [11 - ADDR_ALIGN:0]    sect_len_buf;
    reg  [11 - ADDR_ALIGN:0]    beat_len;
    
    reg  [ADDR_WIDTH - 13:0]    sect_cnt;
    reg  [19:0]                 sect_total;
    reg  [19:0]                 sect_total_buf;
    wire [19:0]                 sect_total_tmp;
    wire                        ready_for_sect;

    wire                        single_sect;
    reg                         first_sect;
    reg                         last_sect;
    wire                        last_sect_tmp;
    reg                         last_sect_buf;
    wire                        next_sect;

    reg                         burst_valid;

    wire                        ost_ctrl_info;
    wire [7:0]                  ost_ctrl_len;
    wire                        ost_ctrl_valid;
//------------------------Instantiation------------------
    vadd_gmem1_m_axi_reg_slice #(
        .DATA_WIDTH     (ADDR_WIDTH + 32)
    ) rs_req (
        .clk            (clk),
        .reset          (reset),
        .s_data         ({in_REQ_LEN, in_REQ_ADDR}),
        .s_valid        (in_REQ_VALID),
        .s_ready        (out_REQ_READY),
        .m_data         ({tmp_len, tmp_addr}),
        .m_valid        (req_valid),
        .m_ready        (next_req));

//------------------------Body---------------------------
    assign read_req      = last_sect_tmp & next_sect | ~req_handling;
    assign next_req      = req_valid & read_req;

    always @(posedge clk)
    begin
        if (reset) begin
            start_addr  <= 0;
            beat_len    <= 0;
            sect_total  <= 0;
            end_from_4k <= 0;
            start_to_4k <= 0;
        end
        else if (clk_en) begin
            if (next_req) begin
                start_addr  <= {tmp_addr[ADDR_WIDTH-1:ADDR_ALIGN], {ADDR_ALIGN{1'b0}}};
                beat_len    <= (tmp_len[11:0] + tmp_addr[ADDR_ALIGN-1:0]) >> ADDR_ALIGN;
                sect_total  <= (tmp_len + tmp_addr[11:0]) >> 12;
                end_from_4k <= (tmp_addr[11:0] + tmp_len[11:0]) >> ADDR_ALIGN; 
                start_to_4k <= BOUNDARY_BEATS - tmp_addr[11:ADDR_ALIGN];
            end
        end
    end

    always @(posedge clk)
    begin
        if (reset)
            req_handling <= 1'b0;
        else if (clk_en) begin
            if (next_req)
                req_handling <= 1'b1;
            else if (~req_valid && last_sect_tmp & next_sect)
                req_handling <= 1'b0;
        end
    end

    // 4k boundary
    assign last_sect_tmp  = single_sect || last_sect;

    assign sect_total_tmp = first_sect ? sect_total : sect_total_buf;
    
    assign single_sect  = (sect_total == 0);

    assign next_sect  = req_handling && ready_for_sect;

    assign sect_addr  = (first_sect)? start_addr : {sect_cnt, {12{1'b0}}};
    
    assign sect_len   = single_sect              ? beat_len :
                        ( first_sect && ~last_sect)? start_to_4k :
                        (~first_sect &&  last_sect)? end_from_4k :
                                                     BOUNDARY_BEATS;

    always @(posedge clk)
    begin
        if (reset) begin
            first_sect <= 1'b0;
            last_sect <= 1'b0;
            sect_cnt <= 0;
        end
        else if (clk_en) begin
            if (next_req) begin
                first_sect <= 1'b1;
                last_sect <= 1'b0;
                sect_cnt <= tmp_addr[ADDR_WIDTH-1:12];
            end
            else if (next_sect) begin
                first_sect <= 1'b0;
                last_sect <= (sect_total_tmp == 1);
                sect_cnt <= sect_cnt + 1;
            end
        end
    end

    always @(posedge clk)
    begin
        if (reset) begin
            sect_addr_buf  <= 0;
            sect_len_buf   <= 0;
            last_sect_buf  <= 1'b0;
            sect_total_buf <= 0;
        end
        else if (clk_en) begin
            if (next_sect) begin
                sect_addr_buf  <= sect_addr;
                sect_len_buf   <= sect_len;
                last_sect_buf  <= last_sect_tmp;
                sect_total_buf <= sect_total_tmp - 1;
            end
        end
    end

    generate
    if (DATA_BYTES >= 4096/MAX_BURST_LEN) begin : must_one_burst
        assign out_BURST_ADDR  = sect_addr_buf;
        assign out_BURST_LEN   = sect_len_buf;
        assign out_BURST_VALID = burst_valid;

        assign out_CTRL_VALID  = next_sect;
        assign out_CTRL_INFO   = last_sect_tmp;
        assign out_CTRL_LEN    = sect_len;

        assign ready_for_sect = ~(burst_valid && ~in_BURST_READY) && in_CTRL_READY;

        always @(posedge clk)
        begin
            if (reset)
                burst_valid <= 1'b0;
            else if (clk_en) begin
                if (next_sect)
                    burst_valid <= 1'b1;
                else if (in_BURST_READY)
                    burst_valid <= 1'b0;
            end
        end

    end
    else begin : could_multi_bursts
        wire [ADDR_WIDTH - 1:0]                   addr_tmp;
        reg  [ADDR_WIDTH - 1:0]                   addr_buf;
        reg  [ADDR_ALIGN + 8:0]                   addr_step;
        wire [7:0]                                len_tmp;
        reg  [7:0]                                len_buf;
        reg                                       sect_handling;
        reg  [11 - NUM_BEAT_WIDTH - ADDR_ALIGN:0] loop_cnt;
        reg                                       first_loop;
        reg                                       last_loop;
        wire                                      next_loop;
        wire                                      ready_for_loop;

        assign out_BURST_ADDR  = addr_buf;
        assign out_BURST_LEN   = len_buf;
        assign out_BURST_VALID = burst_valid;

        assign out_CTRL_VALID  = next_loop;
        assign out_CTRL_INFO   = last_loop && last_sect_buf;
        assign out_CTRL_LEN    = len_tmp;

        assign next_loop       = sect_handling && ready_for_loop;
        assign ready_for_sect  = ~sect_handling || (last_loop && next_loop);
        assign ready_for_loop  = ~(burst_valid && ~in_BURST_READY) && in_CTRL_READY;

        always @(posedge clk)
        begin
            if (reset)
                burst_valid <= 1'b0;
            else if (clk_en) begin
                if (next_loop)
                    burst_valid <= 1'b1;
                else if (in_BURST_READY)
                    burst_valid <= 1'b0;
            end
        end

        always @(posedge clk)
        begin
            if (reset)
                sect_handling <= 1'b0;
            else if (clk_en) begin
                if (req_handling && ~sect_handling)
                    sect_handling <= 1'b1;
                else if (~req_handling && last_loop && next_loop)
                    sect_handling <= 1'b0;
            end
        end

        always @(posedge clk)
        begin
            if (reset) begin
                first_loop <= 1'b0;
                last_loop <= 1'b0;
                loop_cnt <= 0;
            end
            else if (clk_en) begin
                if (next_sect) begin
                    first_loop <= 1'b1;
                    last_loop <= (sect_len[11 - ADDR_ALIGN : NUM_BEAT_WIDTH] == 0);
                    loop_cnt <= sect_len[11 - ADDR_ALIGN : NUM_BEAT_WIDTH];
                end
                else if (next_loop) begin
                    first_loop <= 1'b0;
                    last_loop <= (loop_cnt == 1);
                    loop_cnt <= loop_cnt - 1;
                end
            end
        end

        assign addr_tmp = first_loop ? sect_addr_buf : (addr_buf + addr_step);
        assign len_tmp  = (NUM_BEAT_WIDTH == 0) ? 0 :
                          last_loop ? sect_len_buf[NUM_BEAT_WIDTH - 1:0] : 
                                      { NUM_BEAT_WIDTH{1'b1} };
        always @(posedge clk)
        begin
            if (reset) begin
                addr_buf  <= 0;
                addr_step <= 0;
                len_buf   <= 0;
            end
            else if (clk_en) begin
                if (next_loop) begin
                    addr_buf  <= addr_tmp;
                    addr_step <= (len_tmp + 1) << ADDR_ALIGN;
                    len_buf   <= len_tmp;
                end
            end
        end

    end
    endgenerate

endmodule

module vadd_gmem1_m_axi_throttle
#(parameter
    CONSERVATIVE   = 0,
    USED_FIX       = 0,
    FIX_VALUE      = 4,
    ADDR_WIDTH     = 32,
    DATA_WIDTH     = 32,
    DEPTH          = 16,
    MAXREQS        = 16,
    AVERAGE_MODE   = 0 
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      clk_en,

    input  wire [ADDR_WIDTH-1:0]     in_TOP_AWADDR,
    input  wire [7:0]                in_TOP_AWLEN,
    input  wire                      in_TOP_AWVALID,
    output wire                      out_TOP_AWREADY,
    input  wire [DATA_WIDTH-1:0]     in_TOP_WDATA,
    input  wire [DATA_WIDTH/8-1:0]   in_TOP_WSTRB,
    input  wire                      in_TOP_WLAST,
    input  wire                      in_TOP_WVALID,
    output wire                      out_TOP_WREADY,

    output wire [ADDR_WIDTH-1:0]     out_BUS_AWADDR,
    output wire [7:0]                out_BUS_AWLEN,
    output wire                      out_BUS_AWVALID,
    input  wire                      in_BUS_AWREADY,
    output wire [DATA_WIDTH-1:0]     out_BUS_WDATA,
    output wire [DATA_WIDTH/8-1:0]   out_BUS_WSTRB,
    output wire                      out_BUS_WLAST,
    output wire                      out_BUS_WVALID,
    input  wire                      in_BUS_WREADY);

    function integer log2;
        input integer x;
        integer n, m;
    begin
        n = 0;
        m = 1;
        while (m < x) begin
            n = n + 1;
            m = m * 2;
        end
        log2 = n;
    end
    endfunction
// aggressive mode
    generate
    if (CONSERVATIVE == 0) begin
        localparam threshold = (USED_FIX)? FIX_VALUE-1 : 0;

        wire                req_en;
        wire                handshake;
        wire  [7:0]         load_init;
        reg   [8:0]         throttl_cnt;

        // AW Channel
        assign out_BUS_AWADDR = in_TOP_AWADDR;
        assign out_BUS_AWLEN  = in_TOP_AWLEN;

        // W Channel
        assign out_BUS_WDATA  = in_TOP_WDATA;
        assign out_BUS_WSTRB  = in_TOP_WSTRB;
        assign out_BUS_WLAST  = in_TOP_WLAST;
        assign out_BUS_WVALID = in_TOP_WVALID & (throttl_cnt > 0);
        assign out_TOP_WREADY = in_BUS_WREADY & (throttl_cnt > 0);

        if (USED_FIX) begin
            assign load_init = FIX_VALUE-1;
            assign handshake = 1'b1;
        end else if (AVERAGE_MODE) begin
            assign load_init = in_TOP_AWLEN;
            assign handshake = 1'b1;
        end else begin
            assign load_init = in_TOP_AWLEN;
            assign handshake = out_BUS_WVALID & in_BUS_WREADY;
        end

        assign out_BUS_AWVALID = in_TOP_AWVALID & req_en;
        assign out_TOP_AWREADY = in_BUS_AWREADY & req_en;
        assign req_en = (throttl_cnt == 0) | (throttl_cnt == 1 & handshake);

        always @(posedge clk)
        begin
            if (reset)
                throttl_cnt <= 0;
            else if (clk_en) begin
                if (in_TOP_AWLEN >= threshold && req_en && in_TOP_AWVALID && in_BUS_AWREADY)
                    throttl_cnt <= load_init + 1'b1; //load
                else if (throttl_cnt > 0 && handshake)
                    throttl_cnt <= throttl_cnt - 1'b1;
            end
        end

    end
// conservative mode
    else begin
        localparam CNT_WIDTH = ((DEPTH < 4)? 2 : log2(DEPTH)) + 1;

        // Instantiation for reg slice for AW channel
        wire                        rs_req_ready;
        wire                        rs_req_valid;
        wire [ADDR_WIDTH + 7 : 0]   rs_req_in;
        wire [ADDR_WIDTH + 7 : 0]   rs_req_out;

        vadd_gmem1_m_axi_reg_slice #(
            .DATA_WIDTH     (ADDR_WIDTH + 8)
        ) rs_req (
            .clk            (clk),
            .reset          (reset),
            .s_data         (rs_req_in),
            .s_valid        (rs_req_valid),
            .s_ready        (rs_req_ready),
            .m_data         (rs_req_out),
            .m_valid        (out_BUS_AWVALID),
            .m_ready        (in_BUS_AWREADY));

        wire  [DATA_WIDTH + DATA_WIDTH/8 : 0]   data_in;
        wire  [DATA_WIDTH + DATA_WIDTH/8 : 0]   data_out;
        wire  [ADDR_WIDTH + 7 : 0]              req_in;
        reg                                     req_en;
        wire                                    data_en;
        wire                                    fifo_valid;
        wire                                    read_fifo;
        wire                                    req_fifo_valid;
        wire                                    read_req;
        wire                                    data_push;
        wire                                    data_pop;
        reg                                     flying_req;
        reg   [CNT_WIDTH-1 : 0]                 last_cnt;

        //AW Channel
        assign req_in   = {in_TOP_AWLEN, in_TOP_AWADDR};
        assign out_BUS_AWADDR = rs_req_out[ADDR_WIDTH-1 : 0];
        assign out_BUS_AWLEN  = rs_req_out[ADDR_WIDTH+7 : ADDR_WIDTH];
        assign rs_req_valid = req_fifo_valid & req_en;

        assign read_req      = rs_req_ready & req_en;

        always @(*)
        begin
            if (~flying_req & data_en)
                req_en <= 1;
            else if (flying_req & (out_BUS_WLAST & data_pop) & (last_cnt[CNT_WIDTH-1:1] != 0))
                req_en <= 1;
            else
                req_en <= 0;
        end

        always @(posedge clk)
        begin
            if (reset)
                flying_req <= 0;
            else if (clk_en) begin
                if (rs_req_valid & rs_req_ready)
                    flying_req <= 1;
                else if (out_BUS_WLAST & data_pop)
                    flying_req <= 0;
            end
        end

        vadd_gmem1_m_axi_fifo #(
            .DATA_WIDTH     (ADDR_WIDTH + 8),
            .ADDR_WIDTH     (log2(MAXREQS)),
            .DEPTH          (MAXREQS)
        ) req_fifo (
            .clk            (clk),
            .reset          (reset),
            .clk_en         (clk_en),
            .if_full_n      (out_TOP_AWREADY),
            .if_write       (in_TOP_AWVALID),
            .if_din         (req_in),
            .if_empty_n     (req_fifo_valid),
            .if_read        (read_req),
            .if_dout        (rs_req_in),
            .if_num_data_valid());

        //W Channel
        assign data_in  = {in_TOP_WLAST, in_TOP_WSTRB, in_TOP_WDATA};
        assign out_BUS_WDATA = data_out[DATA_WIDTH-1 : 0];
        assign out_BUS_WSTRB = data_out[DATA_WIDTH+DATA_WIDTH/8-1 : DATA_WIDTH];
        assign out_BUS_WLAST = data_out[DATA_WIDTH+DATA_WIDTH/8];
        assign out_BUS_WVALID = fifo_valid & data_en & flying_req;

        assign data_en   = last_cnt != 0;
        assign data_push = in_TOP_WVALID & out_TOP_WREADY;
        assign data_pop  = fifo_valid & read_fifo;
        assign read_fifo = in_BUS_WREADY & data_en & flying_req;

        always @(posedge clk)
        begin
            if (reset)
                last_cnt <= 0;
            else if (clk_en) begin
                if ((in_TOP_WLAST & data_push) && ~(out_BUS_WLAST & data_pop))
                    last_cnt <= last_cnt + 1;
                else if (~(in_TOP_WLAST & data_push) && (out_BUS_WLAST & data_pop))
                    last_cnt <= last_cnt - 1;
            end
        end
            
        vadd_gmem1_m_axi_fifo #(
            .DATA_WIDTH     (DATA_WIDTH + DATA_WIDTH/8 + 1),
            .ADDR_WIDTH     (log2(DEPTH)),
            .DEPTH          (DEPTH)
        ) data_fifo (
            .clk            (clk),
            .reset          (reset),
            .clk_en         (clk_en),
            .if_full_n      (out_TOP_WREADY),
            .if_write       (in_TOP_WVALID),
            .if_din         (data_in),
            .if_empty_n     (fifo_valid),
            .if_read        (read_fifo),
            .if_dout        (data_out),
            .if_num_data_valid());

        end
    endgenerate

endmodule



module vadd_gmem1_m_axi_reg_slice
#(parameter
    DATA_WIDTH = 8
) (
    // system signals
    input  wire                  clk,
    input  wire                  reset,
    // slave side
    input  wire [DATA_WIDTH-1:0] s_data,
    input  wire                  s_valid,
    output wire                  s_ready,
    // master side
    output wire [DATA_WIDTH-1:0] m_data,
    output wire                  m_valid,
    input  wire                  m_ready);
    //------------------------Parameter----------------------
    // state
    localparam [1:0]
        ZERO = 2'b10,
        ONE  = 2'b11,
        TWO  = 2'b01;
    //------------------------Local signal-------------------
    reg  [DATA_WIDTH-1:0] data_p1;
    reg  [DATA_WIDTH-1:0] data_p2;
    wire         load_p1;
    wire         load_p2;
    wire         load_p1_from_p2;
    reg          s_ready_t;
    reg  [1:0]   state;
    reg  [1:0]   next;
    //------------------------Body---------------------------
    assign s_ready = s_ready_t;
    assign m_data  = data_p1;
    assign m_valid = state[0];

    assign load_p1 = (state == ZERO && s_valid) ||
                    (state == ONE && s_valid && m_ready) ||
                    (state == TWO && m_ready);
    assign load_p2 = s_valid & s_ready;
    assign load_p1_from_p2 = (state == TWO);

    // data_p1
    always @(posedge clk) begin
        if (load_p1) begin
            if (load_p1_from_p2)
                data_p1 <= data_p2;
            else
                data_p1 <= s_data;
        end
    end

    // data_p2
    always @(posedge clk) begin
        if (load_p2) data_p2 <= s_data;
    end

    // s_ready_t
    always @(posedge clk) begin
        if (reset)
            s_ready_t <= 1'b0;
        else if (state == ZERO)
            s_ready_t <= 1'b1;
        else if (state == ONE && next == TWO)
            s_ready_t <= 1'b0;
        else if (state == TWO && next == ONE)
            s_ready_t <= 1'b1;
    end

    // state
    always @(posedge clk) begin
        if (reset)
            state <= ZERO;
        else
            state <= next;
    end

    // next
    always @(*) begin
        case (state)
            ZERO:
                if (s_valid & s_ready)
                    next = ONE;
                else
                    next = ZERO;
            ONE:
                if (~s_valid & m_ready)
                    next = ZERO;
                else if (s_valid & ~m_ready)
                    next = TWO;
                else
                    next = ONE;
            TWO:
                if (m_ready)
                    next = ONE;
                else
                    next = TWO;
            default:
                next = ZERO;
        endcase
    end
endmodule

module vadd_gmem1_m_axi_fifo
#(parameter
    MEM_STYLE   = "shiftreg",
    DATA_WIDTH = 32,
    ADDR_WIDTH = 5,
    DEPTH      = 32
) (
    // system signal
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  clk_en,

    // write
    output wire                  if_full_n,
    input  wire                  if_write,
    input  wire [DATA_WIDTH-1:0] if_din,

    // read
    output wire                  if_empty_n,
    input  wire                  if_read,
    output wire [DATA_WIDTH-1:0] if_dout,
    output wire [ADDR_WIDTH:0]   if_num_data_valid);

//------------------------Local signal-------------------

    wire                  push;
    wire                  pop;
    reg                   full_n = 1'b1;
    reg                   empty_n = 1'b0;
    reg                   dout_vld = 1'b0;
    reg  [ADDR_WIDTH:0]   mOutPtr = 1'b0;

//------------------------Instantiation------------------
    generate 
    if ((MEM_STYLE == "shiftreg") || (DEPTH == 1)) begin
        reg  [ADDR_WIDTH-1:0] raddr = 1'b0;

        vadd_gmem1_m_axi_srl
        #(  .DATA_WIDTH     (DATA_WIDTH),
            .ADDR_WIDTH     (ADDR_WIDTH),
            .DEPTH          (DEPTH))
        U_fifo_srl(
            .clk            (clk),
            .reset          (reset),
            .clk_en         (clk_en),
            .we             (push),
            .din            (if_din),
            .raddr          (raddr),
            .re             (pop),
            .dout           (if_dout)
        );

        // raddr
        always @(posedge clk) begin
            if (reset == 1'b1)
                raddr <= 1'b0;
            else if (clk_en) begin
                if (push & ~pop & empty_n)
                    raddr <= raddr + 1'b1;
                else if (~push & pop && raddr != 0)
                    raddr <= raddr - 1'b1;
            end
        end

    end else begin
        reg  [ADDR_WIDTH-1:0] waddr = 1'b0;
        reg  [ADDR_WIDTH-1:0] raddr = 1'b0;
        wire [ADDR_WIDTH-1:0] wnext;
        wire [ADDR_WIDTH-1:0] rnext;

        vadd_gmem1_m_axi_mem
        #(  .MEM_STYLE      (MEM_STYLE),
            .DATA_WIDTH     (DATA_WIDTH),
            .ADDR_WIDTH     (ADDR_WIDTH),
            .DEPTH          (DEPTH))
        U_fifo_mem(
            .clk            (clk),
            .reset          (reset),
            .clk_en         (clk_en),
            .we             (push),
            .waddr          (waddr),
            .din            (if_din),
            .raddr          (rnext),
            .re             (pop),
            .dout           (if_dout)
        );

        assign wnext =  !push                ? waddr :
                        (waddr == DEPTH - 2) ? 1'b0  :
                        waddr + 1'b1;
        assign rnext =  !pop                 ? raddr :
                        (raddr == DEPTH - 2) ? 1'b0  :
                        raddr + 1'b1;

        // waddr
        always @(posedge clk) begin
            if (reset == 1'b1)
                waddr <= 1'b0;
            else if (clk_en)
                waddr <= wnext;
        end

        // raddr
        always @(posedge clk) begin
            if (reset == 1'b1)
                raddr <= 1'b0;
            else if (clk_en)
                raddr <= rnext;
        end
    end
    endgenerate

//------------------------Body---------------------------
    assign if_num_data_valid = dout_vld ? mOutPtr + 1'b1 : 'b0;

    generate if (DEPTH == 1) begin
        assign if_full_n  = !dout_vld;
        assign if_empty_n = dout_vld;
        assign push = !dout_vld & if_write;
        assign pop  = !dout_vld & if_write;
    
    end else begin

        assign if_full_n  = full_n;
        assign if_empty_n = dout_vld;
        assign push = full_n & if_write;
        assign pop  = empty_n & (if_read | ~dout_vld);

        // mOutPtr
        always @(posedge clk) begin
            if (reset == 1'b1)
                mOutPtr <= 'b0;
            else if (clk_en)
                if (push & ~pop)
                    mOutPtr <= mOutPtr + 1'b1;
                else if (~push & pop)
                    mOutPtr <= mOutPtr - 1'b1;
        end

        // full_n
        always @(posedge clk) begin
            if (reset == 1'b1)
                full_n <= 1'b1;
            else if (clk_en)
                if (push & ~pop)
                    full_n <= (mOutPtr != DEPTH - 2);
                else if (~push & pop)
                    full_n <= 1'b1;
        end

        // empty_n
        always @(posedge clk)
        begin
            if (reset)
                empty_n <= 1'b0;
            else if (clk_en) begin
                if (push & ~pop)
                    empty_n <= 1'b1;
                else if (~push & pop)
                    empty_n <= (mOutPtr != 1'b1);
            end
        end
    end
    endgenerate

    // dout_vld
    always @(posedge clk) begin
        if (reset == 1'b1)
            dout_vld <= 1'b0;
        else if (clk_en)
            if (pop)
                dout_vld <= 1'b1;
            else if (if_read)
                dout_vld <= 1'b0;
    end

endmodule

module vadd_gmem1_m_axi_srl
#(parameter
        DATA_WIDTH  = 32,
        ADDR_WIDTH  = 6,
        DEPTH       = 63
    )(
        input  wire                  clk,
        input  wire                  reset,
        input  wire                  clk_en,
        input  wire                  we,
        input  wire [DATA_WIDTH-1:0] din,
        input  wire [ADDR_WIDTH-1:0] raddr,
        input  wire                  re,
        output reg  [DATA_WIDTH-1:0] dout
    );

    generate
    if (DEPTH > 1) begin
        reg  [DATA_WIDTH-1:0] mem[0:DEPTH-2];

        integer i;
        always @(posedge clk)
        begin
            if (clk_en & we) begin
                for (i = 0; i < DEPTH - 2; i = i + 1) begin
                    mem[i+1] <= mem[i];
                end
                mem[0] <= din;
            end
        end

        always @(posedge clk)
        begin
            if (reset)
                dout <= 0;
            else if (clk_en & re) begin
                dout <= mem[raddr];
            end
        end
    end
    else begin
        always @(posedge clk)
        begin
            if (reset)
                dout <= 0;
            else if (clk_en & we) begin
                dout <= din;
            end
        end
    end
    endgenerate

endmodule

module vadd_gmem1_m_axi_mem
#(parameter
    MEM_STYLE   = "auto",
    DATA_WIDTH  = 32,
    ADDR_WIDTH  = 6,
    DEPTH       = 63
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  clk_en,
    input  wire                  we,
    input  wire [ADDR_WIDTH-1:0] waddr,
    input  wire [DATA_WIDTH-1:0] din,
    input  wire [ADDR_WIDTH-1:0] raddr,
    input  wire                  re,
    output reg  [DATA_WIDTH-1:0] dout);

    (* ram_style = MEM_STYLE, rw_addr_collision = "yes" *)
    reg  [DATA_WIDTH-1:0] mem[0:DEPTH-2];
    reg  [ADDR_WIDTH-1:0] raddr_reg;

    //write to ram
    always @(posedge clk) begin
        if (clk_en & we)
            mem[waddr] <= din;
    end

    //buffer the raddr
    always @(posedge clk) begin
        if (clk_en)
            raddr_reg <= raddr;
    end

    //read from ram
    always @(posedge clk) begin
        if (reset)
            dout <= 0;
        else if (clk_en & re)
            dout <= mem[raddr_reg];
    end
endmodule

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        m_axi_gmem0_AWVALID,
        m_axi_gmem0_AWREADY,
        m_axi_gmem0_AWADDR,
        m_axi_gmem0_AWID,
        m_axi_gmem0_AWLEN,
        m_axi_gmem0_AWSIZE,
        m_axi_gmem0_AWBURST,
        m_axi_gmem0_AWLOCK,
        m_axi_gmem0_AWCACHE,
        m_axi_gmem0_AWPROT,
        m_axi_gmem0_AWQOS,
        m_axi_gmem0_AWREGION,
        m_axi_gmem0_AWUSER,
        m_axi_gmem0_WVALID,
        m_axi_gmem0_WREADY,
        m_axi_gmem0_WDATA,
        m_axi_gmem0_WSTRB,
        m_axi_gmem0_WLAST,
        m_axi_gmem0_WID,
        m_axi_gmem0_WUSER,
        m_axi_gmem0_ARVALID,
        m_axi_gmem0_ARREADY,
        m_axi_gmem0_ARADDR,
        m_axi_gmem0_ARID,
        m_axi_gmem0_ARLEN,
        m_axi_gmem0_ARSIZE,
        m_axi_gmem0_ARBURST,
        m_axi_gmem0_ARLOCK,
        m_axi_gmem0_ARCACHE,
        m_axi_gmem0_ARPROT,
        m_axi_gmem0_ARQOS,
        m_axi_gmem0_ARREGION,
        m_axi_gmem0_ARUSER,
        m_axi_gmem0_RVALID,
        m_axi_gmem0_RREADY,
        m_axi_gmem0_RDATA,
        m_axi_gmem0_RLAST,
        m_axi_gmem0_RID,
        m_axi_gmem0_RFIFONUM,
        m_axi_gmem0_RUSER,
        m_axi_gmem0_RRESP,
        m_axi_gmem0_BVALID,
        m_axi_gmem0_BREADY,
        m_axi_gmem0_BRESP,
        m_axi_gmem0_BID,
        m_axi_gmem0_BUSER,
        input_seq,
        wih0,
        whh0,
        bih0,
        bhh0,
        m_axi_gmem1_AWVALID,
        m_axi_gmem1_AWREADY,
        m_axi_gmem1_AWADDR,
        m_axi_gmem1_AWID,
        m_axi_gmem1_AWLEN,
        m_axi_gmem1_AWSIZE,
        m_axi_gmem1_AWBURST,
        m_axi_gmem1_AWLOCK,
        m_axi_gmem1_AWCACHE,
        m_axi_gmem1_AWPROT,
        m_axi_gmem1_AWQOS,
        m_axi_gmem1_AWREGION,
        m_axi_gmem1_AWUSER,
        m_axi_gmem1_WVALID,
        m_axi_gmem1_WREADY,
        m_axi_gmem1_WDATA,
        m_axi_gmem1_WSTRB,
        m_axi_gmem1_WLAST,
        m_axi_gmem1_WID,
        m_axi_gmem1_WUSER,
        m_axi_gmem1_ARVALID,
        m_axi_gmem1_ARREADY,
        m_axi_gmem1_ARADDR,
        m_axi_gmem1_ARID,
        m_axi_gmem1_ARLEN,
        m_axi_gmem1_ARSIZE,
        m_axi_gmem1_ARBURST,
        m_axi_gmem1_ARLOCK,
        m_axi_gmem1_ARCACHE,
        m_axi_gmem1_ARPROT,
        m_axi_gmem1_ARQOS,
        m_axi_gmem1_ARREGION,
        m_axi_gmem1_ARUSER,
        m_axi_gmem1_RVALID,
        m_axi_gmem1_RREADY,
        m_axi_gmem1_RDATA,
        m_axi_gmem1_RLAST,
        m_axi_gmem1_RID,
        m_axi_gmem1_RFIFONUM,
        m_axi_gmem1_RUSER,
        m_axi_gmem1_RRESP,
        m_axi_gmem1_BVALID,
        m_axi_gmem1_BREADY,
        m_axi_gmem1_BRESP,
        m_axi_gmem1_BID,
        m_axi_gmem1_BUSER,
        wih1,
        whh1,
        bih1,
        bhh1,
        wfc,
        bfc,
        pred_out
);

parameter    ap_ST_fsm_state1 = 134'd1;
parameter    ap_ST_fsm_state2 = 134'd2;
parameter    ap_ST_fsm_state3 = 134'd4;
parameter    ap_ST_fsm_state4 = 134'd8;
parameter    ap_ST_fsm_state5 = 134'd16;
parameter    ap_ST_fsm_state6 = 134'd32;
parameter    ap_ST_fsm_state7 = 134'd64;
parameter    ap_ST_fsm_state8 = 134'd128;
parameter    ap_ST_fsm_state9 = 134'd256;
parameter    ap_ST_fsm_state10 = 134'd512;
parameter    ap_ST_fsm_state11 = 134'd1024;
parameter    ap_ST_fsm_state12 = 134'd2048;
parameter    ap_ST_fsm_state13 = 134'd4096;
parameter    ap_ST_fsm_state14 = 134'd8192;
parameter    ap_ST_fsm_state15 = 134'd16384;
parameter    ap_ST_fsm_state16 = 134'd32768;
parameter    ap_ST_fsm_state17 = 134'd65536;
parameter    ap_ST_fsm_state18 = 134'd131072;
parameter    ap_ST_fsm_state19 = 134'd262144;
parameter    ap_ST_fsm_state20 = 134'd524288;
parameter    ap_ST_fsm_state21 = 134'd1048576;
parameter    ap_ST_fsm_state22 = 134'd2097152;
parameter    ap_ST_fsm_state23 = 134'd4194304;
parameter    ap_ST_fsm_state24 = 134'd8388608;
parameter    ap_ST_fsm_state25 = 134'd16777216;
parameter    ap_ST_fsm_state26 = 134'd33554432;
parameter    ap_ST_fsm_state27 = 134'd67108864;
parameter    ap_ST_fsm_state28 = 134'd134217728;
parameter    ap_ST_fsm_state29 = 134'd268435456;
parameter    ap_ST_fsm_state30 = 134'd536870912;
parameter    ap_ST_fsm_state31 = 134'd1073741824;
parameter    ap_ST_fsm_state32 = 134'd2147483648;
parameter    ap_ST_fsm_state33 = 134'd4294967296;
parameter    ap_ST_fsm_state34 = 134'd8589934592;
parameter    ap_ST_fsm_state35 = 134'd17179869184;
parameter    ap_ST_fsm_state36 = 134'd34359738368;
parameter    ap_ST_fsm_state37 = 134'd68719476736;
parameter    ap_ST_fsm_state38 = 134'd137438953472;
parameter    ap_ST_fsm_state39 = 134'd274877906944;
parameter    ap_ST_fsm_state40 = 134'd549755813888;
parameter    ap_ST_fsm_state41 = 134'd1099511627776;
parameter    ap_ST_fsm_state42 = 134'd2199023255552;
parameter    ap_ST_fsm_state43 = 134'd4398046511104;
parameter    ap_ST_fsm_state44 = 134'd8796093022208;
parameter    ap_ST_fsm_state45 = 134'd17592186044416;
parameter    ap_ST_fsm_state46 = 134'd35184372088832;
parameter    ap_ST_fsm_state47 = 134'd70368744177664;
parameter    ap_ST_fsm_state48 = 134'd140737488355328;
parameter    ap_ST_fsm_state49 = 134'd281474976710656;
parameter    ap_ST_fsm_state50 = 134'd562949953421312;
parameter    ap_ST_fsm_state51 = 134'd1125899906842624;
parameter    ap_ST_fsm_state52 = 134'd2251799813685248;
parameter    ap_ST_fsm_state53 = 134'd4503599627370496;
parameter    ap_ST_fsm_state54 = 134'd9007199254740992;
parameter    ap_ST_fsm_state55 = 134'd18014398509481984;
parameter    ap_ST_fsm_state56 = 134'd36028797018963968;
parameter    ap_ST_fsm_state57 = 134'd72057594037927936;
parameter    ap_ST_fsm_state58 = 134'd144115188075855872;
parameter    ap_ST_fsm_state59 = 134'd288230376151711744;
parameter    ap_ST_fsm_state60 = 134'd576460752303423488;
parameter    ap_ST_fsm_state61 = 134'd1152921504606846976;
parameter    ap_ST_fsm_state62 = 134'd2305843009213693952;
parameter    ap_ST_fsm_state63 = 134'd4611686018427387904;
parameter    ap_ST_fsm_state64 = 134'd9223372036854775808;
parameter    ap_ST_fsm_state65 = 134'd18446744073709551616;
parameter    ap_ST_fsm_state66 = 134'd36893488147419103232;
parameter    ap_ST_fsm_state67 = 134'd73786976294838206464;
parameter    ap_ST_fsm_state68 = 134'd147573952589676412928;
parameter    ap_ST_fsm_state69 = 134'd295147905179352825856;
parameter    ap_ST_fsm_state70 = 134'd590295810358705651712;
parameter    ap_ST_fsm_state71 = 134'd1180591620717411303424;
parameter    ap_ST_fsm_state72 = 134'd2361183241434822606848;
parameter    ap_ST_fsm_state73 = 134'd4722366482869645213696;
parameter    ap_ST_fsm_state74 = 134'd9444732965739290427392;
parameter    ap_ST_fsm_state75 = 134'd18889465931478580854784;
parameter    ap_ST_fsm_state76 = 134'd37778931862957161709568;
parameter    ap_ST_fsm_state77 = 134'd75557863725914323419136;
parameter    ap_ST_fsm_state78 = 134'd151115727451828646838272;
parameter    ap_ST_fsm_state79 = 134'd302231454903657293676544;
parameter    ap_ST_fsm_state80 = 134'd604462909807314587353088;
parameter    ap_ST_fsm_state81 = 134'd1208925819614629174706176;
parameter    ap_ST_fsm_state82 = 134'd2417851639229258349412352;
parameter    ap_ST_fsm_state83 = 134'd4835703278458516698824704;
parameter    ap_ST_fsm_state84 = 134'd9671406556917033397649408;
parameter    ap_ST_fsm_state85 = 134'd19342813113834066795298816;
parameter    ap_ST_fsm_state86 = 134'd38685626227668133590597632;
parameter    ap_ST_fsm_state87 = 134'd77371252455336267181195264;
parameter    ap_ST_fsm_state88 = 134'd154742504910672534362390528;
parameter    ap_ST_fsm_state89 = 134'd309485009821345068724781056;
parameter    ap_ST_fsm_state90 = 134'd618970019642690137449562112;
parameter    ap_ST_fsm_state91 = 134'd1237940039285380274899124224;
parameter    ap_ST_fsm_state92 = 134'd2475880078570760549798248448;
parameter    ap_ST_fsm_state93 = 134'd4951760157141521099596496896;
parameter    ap_ST_fsm_state94 = 134'd9903520314283042199192993792;
parameter    ap_ST_fsm_state95 = 134'd19807040628566084398385987584;
parameter    ap_ST_fsm_state96 = 134'd39614081257132168796771975168;
parameter    ap_ST_fsm_state97 = 134'd79228162514264337593543950336;
parameter    ap_ST_fsm_state98 = 134'd158456325028528675187087900672;
parameter    ap_ST_fsm_state99 = 134'd316912650057057350374175801344;
parameter    ap_ST_fsm_state100 = 134'd633825300114114700748351602688;
parameter    ap_ST_fsm_state101 = 134'd1267650600228229401496703205376;
parameter    ap_ST_fsm_state102 = 134'd2535301200456458802993406410752;
parameter    ap_ST_fsm_state103 = 134'd5070602400912917605986812821504;
parameter    ap_ST_fsm_state104 = 134'd10141204801825835211973625643008;
parameter    ap_ST_fsm_state105 = 134'd20282409603651670423947251286016;
parameter    ap_ST_fsm_state106 = 134'd40564819207303340847894502572032;
parameter    ap_ST_fsm_state107 = 134'd81129638414606681695789005144064;
parameter    ap_ST_fsm_state108 = 134'd162259276829213363391578010288128;
parameter    ap_ST_fsm_state109 = 134'd324518553658426726783156020576256;
parameter    ap_ST_fsm_state110 = 134'd649037107316853453566312041152512;
parameter    ap_ST_fsm_state111 = 134'd1298074214633706907132624082305024;
parameter    ap_ST_fsm_state112 = 134'd2596148429267413814265248164610048;
parameter    ap_ST_fsm_state113 = 134'd5192296858534827628530496329220096;
parameter    ap_ST_fsm_state114 = 134'd10384593717069655257060992658440192;
parameter    ap_ST_fsm_state115 = 134'd20769187434139310514121985316880384;
parameter    ap_ST_fsm_state116 = 134'd41538374868278621028243970633760768;
parameter    ap_ST_fsm_state117 = 134'd83076749736557242056487941267521536;
parameter    ap_ST_fsm_state118 = 134'd166153499473114484112975882535043072;
parameter    ap_ST_fsm_state119 = 134'd332306998946228968225951765070086144;
parameter    ap_ST_fsm_state120 = 134'd664613997892457936451903530140172288;
parameter    ap_ST_fsm_state121 = 134'd1329227995784915872903807060280344576;
parameter    ap_ST_fsm_state122 = 134'd2658455991569831745807614120560689152;
parameter    ap_ST_fsm_state123 = 134'd5316911983139663491615228241121378304;
parameter    ap_ST_fsm_state124 = 134'd10633823966279326983230456482242756608;
parameter    ap_ST_fsm_state125 = 134'd21267647932558653966460912964485513216;
parameter    ap_ST_fsm_state126 = 134'd42535295865117307932921825928971026432;
parameter    ap_ST_fsm_state127 = 134'd85070591730234615865843651857942052864;
parameter    ap_ST_fsm_state128 = 134'd170141183460469231731687303715884105728;
parameter    ap_ST_fsm_state129 = 134'd340282366920938463463374607431768211456;
parameter    ap_ST_fsm_state130 = 134'd680564733841876926926749214863536422912;
parameter    ap_ST_fsm_state131 = 134'd1361129467683753853853498429727072845824;
parameter    ap_ST_fsm_state132 = 134'd2722258935367507707706996859454145691648;
parameter    ap_ST_fsm_state133 = 134'd5444517870735015415413993718908291383296;
parameter    ap_ST_fsm_state134 = 134'd10889035741470030830827987437816582766592;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output   m_axi_gmem0_AWVALID;
input   m_axi_gmem0_AWREADY;
output  [63:0] m_axi_gmem0_AWADDR;
output  [0:0] m_axi_gmem0_AWID;
output  [31:0] m_axi_gmem0_AWLEN;
output  [2:0] m_axi_gmem0_AWSIZE;
output  [1:0] m_axi_gmem0_AWBURST;
output  [1:0] m_axi_gmem0_AWLOCK;
output  [3:0] m_axi_gmem0_AWCACHE;
output  [2:0] m_axi_gmem0_AWPROT;
output  [3:0] m_axi_gmem0_AWQOS;
output  [3:0] m_axi_gmem0_AWREGION;
output  [0:0] m_axi_gmem0_AWUSER;
output   m_axi_gmem0_WVALID;
input   m_axi_gmem0_WREADY;
output  [31:0] m_axi_gmem0_WDATA;
output  [3:0] m_axi_gmem0_WSTRB;
output   m_axi_gmem0_WLAST;
output  [0:0] m_axi_gmem0_WID;
output  [0:0] m_axi_gmem0_WUSER;
output   m_axi_gmem0_ARVALID;
input   m_axi_gmem0_ARREADY;
output  [63:0] m_axi_gmem0_ARADDR;
output  [0:0] m_axi_gmem0_ARID;
output  [31:0] m_axi_gmem0_ARLEN;
output  [2:0] m_axi_gmem0_ARSIZE;
output  [1:0] m_axi_gmem0_ARBURST;
output  [1:0] m_axi_gmem0_ARLOCK;
output  [3:0] m_axi_gmem0_ARCACHE;
output  [2:0] m_axi_gmem0_ARPROT;
output  [3:0] m_axi_gmem0_ARQOS;
output  [3:0] m_axi_gmem0_ARREGION;
output  [0:0] m_axi_gmem0_ARUSER;
input   m_axi_gmem0_RVALID;
output   m_axi_gmem0_RREADY;
input  [31:0] m_axi_gmem0_RDATA;
input   m_axi_gmem0_RLAST;
input  [0:0] m_axi_gmem0_RID;
input  [8:0] m_axi_gmem0_RFIFONUM;
input  [0:0] m_axi_gmem0_RUSER;
input  [1:0] m_axi_gmem0_RRESP;
input   m_axi_gmem0_BVALID;
output   m_axi_gmem0_BREADY;
input  [1:0] m_axi_gmem0_BRESP;
input  [0:0] m_axi_gmem0_BID;
input  [0:0] m_axi_gmem0_BUSER;
input  [63:0] input_seq;
input  [63:0] wih0;
input  [63:0] whh0;
input  [63:0] bih0;
input  [63:0] bhh0;
output   m_axi_gmem1_AWVALID;
input   m_axi_gmem1_AWREADY;
output  [63:0] m_axi_gmem1_AWADDR;
output  [0:0] m_axi_gmem1_AWID;
output  [31:0] m_axi_gmem1_AWLEN;
output  [2:0] m_axi_gmem1_AWSIZE;
output  [1:0] m_axi_gmem1_AWBURST;
output  [1:0] m_axi_gmem1_AWLOCK;
output  [3:0] m_axi_gmem1_AWCACHE;
output  [2:0] m_axi_gmem1_AWPROT;
output  [3:0] m_axi_gmem1_AWQOS;
output  [3:0] m_axi_gmem1_AWREGION;
output  [0:0] m_axi_gmem1_AWUSER;
output   m_axi_gmem1_WVALID;
input   m_axi_gmem1_WREADY;
output  [31:0] m_axi_gmem1_WDATA;
output  [3:0] m_axi_gmem1_WSTRB;
output   m_axi_gmem1_WLAST;
output  [0:0] m_axi_gmem1_WID;
output  [0:0] m_axi_gmem1_WUSER;
output   m_axi_gmem1_ARVALID;
input   m_axi_gmem1_ARREADY;
output  [63:0] m_axi_gmem1_ARADDR;
output  [0:0] m_axi_gmem1_ARID;
output  [31:0] m_axi_gmem1_ARLEN;
output  [2:0] m_axi_gmem1_ARSIZE;
output  [1:0] m_axi_gmem1_ARBURST;
output  [1:0] m_axi_gmem1_ARLOCK;
output  [3:0] m_axi_gmem1_ARCACHE;
output  [2:0] m_axi_gmem1_ARPROT;
output  [3:0] m_axi_gmem1_ARQOS;
output  [3:0] m_axi_gmem1_ARREGION;
output  [0:0] m_axi_gmem1_ARUSER;
input   m_axi_gmem1_RVALID;
output   m_axi_gmem1_RREADY;
input  [31:0] m_axi_gmem1_RDATA;
input   m_axi_gmem1_RLAST;
input  [0:0] m_axi_gmem1_RID;
input  [8:0] m_axi_gmem1_RFIFONUM;
input  [0:0] m_axi_gmem1_RUSER;
input  [1:0] m_axi_gmem1_RRESP;
input   m_axi_gmem1_BVALID;
output   m_axi_gmem1_BREADY;
input  [1:0] m_axi_gmem1_BRESP;
input  [0:0] m_axi_gmem1_BID;
input  [0:0] m_axi_gmem1_BUSER;
input  [63:0] wih1;
input  [63:0] whh1;
input  [63:0] bih1;
input  [63:0] bhh1;
input  [63:0] wfc;
input  [63:0] bfc;
input  [63:0] pred_out;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg m_axi_gmem0_ARVALID;
reg[63:0] m_axi_gmem0_ARADDR;
reg[0:0] m_axi_gmem0_ARID;
reg[31:0] m_axi_gmem0_ARLEN;
reg[2:0] m_axi_gmem0_ARSIZE;
reg[1:0] m_axi_gmem0_ARBURST;
reg[1:0] m_axi_gmem0_ARLOCK;
reg[3:0] m_axi_gmem0_ARCACHE;
reg[2:0] m_axi_gmem0_ARPROT;
reg[3:0] m_axi_gmem0_ARQOS;
reg[3:0] m_axi_gmem0_ARREGION;
reg[0:0] m_axi_gmem0_ARUSER;
reg m_axi_gmem0_RREADY;
reg m_axi_gmem1_AWVALID;
reg m_axi_gmem1_WVALID;
reg m_axi_gmem1_ARVALID;
reg[63:0] m_axi_gmem1_ARADDR;
reg[0:0] m_axi_gmem1_ARID;
reg[31:0] m_axi_gmem1_ARLEN;
reg[2:0] m_axi_gmem1_ARSIZE;
reg[1:0] m_axi_gmem1_ARBURST;
reg[1:0] m_axi_gmem1_ARLOCK;
reg[3:0] m_axi_gmem1_ARCACHE;
reg[2:0] m_axi_gmem1_ARPROT;
reg[3:0] m_axi_gmem1_ARQOS;
reg[3:0] m_axi_gmem1_ARREGION;
reg[0:0] m_axi_gmem1_ARUSER;
reg m_axi_gmem1_RREADY;
reg m_axi_gmem1_BREADY;

(* fsm_encoding = "none" *) reg   [133:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    gmem0_blk_n_AR;
wire    ap_CS_fsm_state8;
wire    ap_CS_fsm_state18;
reg    gmem0_blk_n_R;
wire    ap_CS_fsm_state27;
wire    ap_CS_fsm_state19;
wire    ap_CS_fsm_state37;
reg    gmem1_blk_n_AR;
wire    ap_CS_fsm_state52;
wire    ap_CS_fsm_state62;
wire    ap_CS_fsm_state72;
reg    gmem1_blk_n_R;
wire    ap_CS_fsm_state81;
wire    ap_CS_fsm_state73;
wire    ap_CS_fsm_state91;
wire    ap_CS_fsm_state106;
wire    ap_CS_fsm_state114;
reg    gmem1_blk_n_AW;
wire    ap_CS_fsm_state126;
reg    gmem1_blk_n_W;
wire    ap_CS_fsm_state129;
reg    gmem1_blk_n_B;
wire    ap_CS_fsm_state134;
wire   [31:0] grp_fu_726_p2;
reg   [31:0] reg_730;
wire    ap_CS_fsm_state47;
wire    ap_CS_fsm_state101;
wire    ap_CS_fsm_state124;
wire    ap_CS_fsm_state2;
wire   [5:0] add_ln68_fu_760_p2;
reg   [5:0] add_ln68_reg_1453;
wire    ap_CS_fsm_state3;
reg   [61:0] p_cast_reg_1458;
reg   [61:0] trunc_ln_reg_1470;
wire  signed [62:0] sext_ln140_fu_811_p1;
reg  signed [62:0] sext_ln140_reg_1475;
wire   [2:0] add_ln75_fu_826_p2;
reg   [2:0] add_ln75_reg_1483;
wire    ap_CS_fsm_state4;
wire   [1:0] empty_fu_832_p1;
reg   [1:0] empty_reg_1488;
wire   [8:0] tmp_2_fu_836_p3;
reg   [8:0] tmp_2_reg_1493;
wire   [7:0] add_ln76_fu_850_p2;
reg   [7:0] add_ln76_reg_1501;
wire    ap_CS_fsm_state5;
reg   [61:0] trunc_ln7_reg_1506;
reg   [61:0] trunc_ln8_reg_1511;
wire   [8:0] add_ln77_2_fu_907_p2;
reg   [8:0] add_ln77_2_reg_1517;
reg   [63:0] gmem0_addr_2_reg_1523;
reg   [63:0] gmem0_addr_3_reg_1529;
reg   [31:0] gmem0_addr_2_read_reg_1546;
wire   [31:0] bitcast_ln89_fu_992_p1;
wire    ap_CS_fsm_state28;
reg   [6:0] tmp_reg_1556;
wire    ap_CS_fsm_state35;
reg   [31:0] gmem0_addr_3_read_reg_1561;
wire   [31:0] bitcast_ln89_1_fu_1020_p1;
wire    ap_CS_fsm_state38;
wire   [2:0] grp_fu_1015_p2;
reg   [2:0] urem_ln89_reg_1571;
wire   [2:0] add_ln107_fu_1041_p2;
reg   [2:0] add_ln107_reg_1582;
wire    ap_CS_fsm_state50;
wire   [1:0] empty_57_fu_1047_p1;
reg   [1:0] empty_57_reg_1587;
wire   [8:0] tmp_3_fu_1051_p3;
reg   [8:0] tmp_3_reg_1592;
wire   [7:0] add_ln108_fu_1069_p2;
reg   [7:0] add_ln108_reg_1600;
wire    ap_CS_fsm_state51;
reg   [61:0] trunc_ln2_reg_1605;
reg   [61:0] trunc_ln3_reg_1611;
wire   [8:0] add_ln109_2_fu_1126_p2;
reg   [8:0] add_ln109_2_reg_1617;
reg   [63:0] gmem1_addr_4_reg_1623;
reg   [63:0] gmem1_addr_5_reg_1629;
reg   [31:0] gmem1_addr_4_read_reg_1651;
wire   [31:0] bitcast_ln121_fu_1221_p1;
wire    ap_CS_fsm_state82;
reg   [6:0] tmp_19_reg_1661;
wire    ap_CS_fsm_state89;
reg   [31:0] gmem1_addr_5_read_reg_1666;
wire   [31:0] bitcast_ln121_1_fu_1249_p1;
wire    ap_CS_fsm_state92;
wire   [2:0] grp_fu_1244_p2;
reg   [2:0] urem_ln121_reg_1676;
reg   [3:0] i_1_reg_1684;
wire    ap_CS_fsm_state104;
wire   [10:0] tmp_s_fu_1283_p3;
reg   [10:0] tmp_s_reg_1692;
reg   [63:0] gmem1_addr_1_reg_1697;
reg   [63:0] gmem1_addr_reg_1708;
reg   [31:0] gmem1_addr_1_read_reg_1714;
wire   [31:0] bitcast_ln146_fu_1335_p1;
wire    ap_CS_fsm_state115;
reg   [31:0] max_val_reg_1727;
reg   [6:0] h0_address0;
reg    h0_ce0;
reg    h0_we0;
reg   [31:0] h0_d0;
wire   [31:0] h0_q0;
reg   [6:0] c0_address0;
reg    c0_ce0;
reg    c0_we0;
reg   [31:0] c0_d0;
reg    c0_ce1;
wire   [31:0] c0_q1;
reg   [6:0] h1_address0;
reg    h1_ce0;
reg    h1_we0;
reg   [31:0] h1_d0;
wire   [31:0] h1_q0;
reg   [6:0] c1_address0;
reg    c1_ce0;
reg    c1_we0;
reg   [31:0] c1_d0;
reg    c1_ce1;
wire   [31:0] c1_q1;
reg   [6:0] gates0_address0;
reg    gates0_ce0;
wire   [31:0] gates0_q0;
reg   [6:0] gates0_1_address0;
reg    gates0_1_ce0;
wire   [31:0] gates0_1_q0;
reg   [6:0] gates0_2_address0;
reg    gates0_2_ce0;
wire   [31:0] gates0_2_q0;
reg   [6:0] gates0_3_address0;
reg    gates0_3_ce0;
wire   [31:0] gates0_3_q0;
reg   [6:0] gates0_4_address0;
reg    gates0_4_ce0;
wire   [31:0] gates0_4_q0;
reg   [6:0] gates1_address0;
reg    gates1_ce0;
wire   [31:0] gates1_q0;
reg   [6:0] gates1_1_address0;
reg    gates1_1_ce0;
wire   [31:0] gates1_1_q0;
reg   [6:0] gates1_2_address0;
reg    gates1_2_ce0;
wire   [31:0] gates1_2_q0;
reg   [6:0] gates1_3_address0;
reg    gates1_3_ce0;
wire   [31:0] gates1_3_q0;
reg   [6:0] gates1_4_address0;
reg    gates1_4_ce0;
wire   [31:0] gates1_4_q0;
reg   [3:0] logits_address0;
reg    logits_ce0;
wire   [31:0] logits_q0;
wire    grp_lstm_inference_Pipeline_1_fu_623_ap_start;
wire    grp_lstm_inference_Pipeline_1_fu_623_ap_done;
wire    grp_lstm_inference_Pipeline_1_fu_623_ap_idle;
wire    grp_lstm_inference_Pipeline_1_fu_623_ap_ready;
wire   [6:0] grp_lstm_inference_Pipeline_1_fu_623_h0_address0;
wire    grp_lstm_inference_Pipeline_1_fu_623_h0_ce0;
wire    grp_lstm_inference_Pipeline_1_fu_623_h0_we0;
wire   [31:0] grp_lstm_inference_Pipeline_1_fu_623_h0_d0;
wire    grp_lstm_inference_Pipeline_2_fu_629_ap_start;
wire    grp_lstm_inference_Pipeline_2_fu_629_ap_done;
wire    grp_lstm_inference_Pipeline_2_fu_629_ap_idle;
wire    grp_lstm_inference_Pipeline_2_fu_629_ap_ready;
wire   [6:0] grp_lstm_inference_Pipeline_2_fu_629_c0_address0;
wire    grp_lstm_inference_Pipeline_2_fu_629_c0_ce0;
wire    grp_lstm_inference_Pipeline_2_fu_629_c0_we0;
wire   [31:0] grp_lstm_inference_Pipeline_2_fu_629_c0_d0;
wire    grp_lstm_inference_Pipeline_3_fu_635_ap_start;
wire    grp_lstm_inference_Pipeline_3_fu_635_ap_done;
wire    grp_lstm_inference_Pipeline_3_fu_635_ap_idle;
wire    grp_lstm_inference_Pipeline_3_fu_635_ap_ready;
wire   [6:0] grp_lstm_inference_Pipeline_3_fu_635_h1_address0;
wire    grp_lstm_inference_Pipeline_3_fu_635_h1_ce0;
wire    grp_lstm_inference_Pipeline_3_fu_635_h1_we0;
wire   [31:0] grp_lstm_inference_Pipeline_3_fu_635_h1_d0;
wire    grp_lstm_inference_Pipeline_4_fu_641_ap_start;
wire    grp_lstm_inference_Pipeline_4_fu_641_ap_done;
wire    grp_lstm_inference_Pipeline_4_fu_641_ap_idle;
wire    grp_lstm_inference_Pipeline_4_fu_641_ap_ready;
wire   [6:0] grp_lstm_inference_Pipeline_4_fu_641_c1_address0;
wire    grp_lstm_inference_Pipeline_4_fu_641_c1_ce0;
wire    grp_lstm_inference_Pipeline_4_fu_641_c1_we0;
wire   [31:0] grp_lstm_inference_Pipeline_4_fu_641_c1_d0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_start;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_done;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_idle;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_ready;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_ce0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_1_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_1_ce0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_2_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_2_ce0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_3_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_3_ce0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_4_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_4_ce0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_ce0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_we0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_d0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_address1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_ce1;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_ce0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_we0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_d0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_din1;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_opcode;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1732_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1732_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1732_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1736_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1736_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1736_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1740_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1740_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1740_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_sigmoid_fu_1744_p_din1;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_sigmoid_fu_1749_p_din1;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_sigmoid_fu_1754_p_din1;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_tanh_approx_fu_1759_p_din1;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_tanh_approx_fu_1764_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_start;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_done;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_idle;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_ready;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWVALID;
wire   [63:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWADDR;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWLEN;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWSIZE;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWBURST;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWLOCK;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWCACHE;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWPROT;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWQOS;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWREGION;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WVALID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WDATA;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WSTRB;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WLAST;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WID;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARVALID;
wire   [63:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARADDR;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARLEN;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARSIZE;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARBURST;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARLOCK;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARCACHE;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARPROT;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARQOS;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARREGION;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_RREADY;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_BREADY;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_xC_out;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_xC_out_ap_vld;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_din1;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_opcode;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_1732_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_1732_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_1732_p_ce;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_start;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_done;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_idle;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_ready;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWVALID;
wire   [63:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWADDR;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWLEN;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWSIZE;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWBURST;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWLOCK;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWCACHE;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWPROT;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWQOS;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWREGION;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WVALID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WDATA;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WSTRB;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WLAST;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WID;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARVALID;
wire   [63:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARADDR;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARLEN;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARSIZE;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARBURST;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARLOCK;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARCACHE;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARPROT;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARQOS;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARREGION;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_RREADY;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_BREADY;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_h0_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_h0_ce0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_hC_out;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_hC_out_ap_vld;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_din1;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_opcode;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_1732_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_1732_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_1732_p_ce;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_start;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_done;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_idle;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_ready;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_ce0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_1_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_1_ce0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_2_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_2_ce0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_3_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_3_ce0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_4_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_4_ce0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_ce0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_we0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_d0;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_address1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_ce1;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_ce0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_we0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_d0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_din1;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_opcode;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1732_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1732_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1732_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1736_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1736_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1736_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1740_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1740_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1740_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_sigmoid_fu_1744_p_din1;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_sigmoid_fu_1749_p_din1;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_sigmoid_fu_1754_p_din1;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_tanh_approx_fu_1759_p_din1;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_tanh_approx_fu_1764_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_start;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_done;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_idle;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_ready;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWVALID;
wire   [63:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWADDR;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWLEN;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWSIZE;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWBURST;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWLOCK;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWCACHE;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWPROT;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWQOS;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWREGION;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WVALID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WDATA;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WSTRB;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WLAST;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WID;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARVALID;
wire   [63:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARADDR;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARLEN;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARSIZE;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARBURST;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARLOCK;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARCACHE;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARPROT;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARQOS;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARREGION;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_RREADY;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_BREADY;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_h0_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_h0_ce0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_xC_2_out;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_xC_2_out_ap_vld;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_din1;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_opcode;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_1732_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_1732_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_1732_p_ce;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_start;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_done;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_idle;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_ready;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWVALID;
wire   [63:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWADDR;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWLEN;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWSIZE;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWBURST;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWLOCK;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWCACHE;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWPROT;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWQOS;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWREGION;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WVALID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WDATA;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WSTRB;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WLAST;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WID;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARVALID;
wire   [63:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARADDR;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARLEN;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARSIZE;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARBURST;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARLOCK;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARCACHE;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARPROT;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARQOS;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARREGION;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_RREADY;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_BREADY;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_h1_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_h1_ce0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_hC_2_out;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_hC_2_out_ap_vld;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_din1;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_opcode;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_1732_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_1732_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_1732_p_ce;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_start;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_done;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_idle;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_ready;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWVALID;
wire   [63:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWADDR;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWLEN;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWSIZE;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWBURST;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWLOCK;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWCACHE;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWPROT;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWQOS;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWREGION;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WVALID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WDATA;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WSTRB;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WLAST;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WID;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARVALID;
wire   [63:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARADDR;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARID;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARLEN;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARSIZE;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARBURST;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARLOCK;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARCACHE;
wire   [2:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARPROT;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARQOS;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARREGION;
wire   [0:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARUSER;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_RREADY;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_BREADY;
wire   [6:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_h1_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_h1_ce0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_dot_out;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_dot_out_ap_vld;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_din1;
wire   [1:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_opcode;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_ce;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_1732_p_din0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_1732_p_din1;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_1732_p_ce;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_start;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_done;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_idle;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_ready;
wire   [3:0] grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_logits_address0;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_logits_ce0;
wire   [31:0] grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_max_idx_out;
wire    grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_max_idx_out_ap_vld;
reg   [31:0] grp_sigmoid_fu_1744_x;
wire   [31:0] grp_sigmoid_fu_1744_ap_return;
reg   [31:0] grp_sigmoid_fu_1749_x;
wire   [31:0] grp_sigmoid_fu_1749_ap_return;
reg   [31:0] grp_sigmoid_fu_1754_x;
wire   [31:0] grp_sigmoid_fu_1754_ap_return;
reg   [31:0] grp_tanh_approx_fu_1759_x;
wire   [31:0] grp_tanh_approx_fu_1759_ap_return;
reg   [31:0] grp_tanh_approx_fu_1764_x;
wire   [31:0] grp_tanh_approx_fu_1764_ap_return;
reg   [2:0] g_reg_579;
wire   [0:0] icmp_ln68_fu_754_p2;
wire   [0:0] icmp_ln76_fu_844_p2;
reg   [7:0] j_2_reg_590;
wire   [0:0] icmp_ln75_fu_820_p2;
wire    ap_CS_fsm_state48;
reg   [2:0] g_1_reg_601;
wire   [0:0] icmp_ln108_fu_1063_p2;
wire    ap_CS_fsm_state49;
reg   [7:0] j_reg_612;
wire   [0:0] icmp_ln107_fu_1035_p2;
wire    ap_CS_fsm_state102;
reg    grp_lstm_inference_Pipeline_1_fu_623_ap_start_reg;
reg    grp_lstm_inference_Pipeline_2_fu_629_ap_start_reg;
reg    grp_lstm_inference_Pipeline_3_fu_635_ap_start_reg;
reg    grp_lstm_inference_Pipeline_4_fu_641_ap_start_reg;
reg    grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_start_reg;
reg    grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_start_reg;
wire    ap_CS_fsm_state6;
wire    ap_CS_fsm_state7;
reg    grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_start_reg;
wire    ap_CS_fsm_state16;
wire    ap_CS_fsm_state17;
reg    grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_start_reg;
wire    ap_CS_fsm_state103;
reg    grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_start_reg;
wire    ap_CS_fsm_state60;
wire    ap_CS_fsm_state61;
reg    grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_start_reg;
wire    ap_CS_fsm_state70;
wire    ap_CS_fsm_state71;
reg    grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_start_reg;
wire   [0:0] icmp_ln140_fu_1267_p2;
wire    ap_CS_fsm_state105;
reg    grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_start_reg;
wire    ap_CS_fsm_state127;
wire    ap_CS_fsm_state128;
wire   [63:0] zext_ln89_1_fu_1024_p1;
wire   [63:0] zext_ln121_1_fu_1253_p1;
wire   [63:0] zext_ln140_fu_1339_p1;
wire    ap_CS_fsm_state125;
wire  signed [63:0] sext_ln89_fu_939_p1;
wire  signed [63:0] sext_ln89_1_fu_964_p1;
wire  signed [63:0] sext_ln85_fu_974_p1;
wire  signed [63:0] sext_ln121_fu_1158_p1;
wire  signed [63:0] sext_ln121_1_fu_1183_p1;
wire  signed [63:0] sext_ln113_fu_1193_p1;
wire  signed [63:0] sext_ln117_fu_1203_p1;
wire  signed [63:0] sext_ln146_fu_1297_p1;
wire  signed [63:0] sext_ln158_fu_1321_p1;
reg   [5:0] t_fu_178;
reg   [3:0] i_fu_266;
wire   [3:0] add_ln140_fu_1273_p2;
reg    ap_block_state2_on_subcall_done;
reg    gates0_3_we0_local;
wire   [2:0] trunc_ln89_fu_1032_p1;
reg    gates0_3_ce0_local;
reg    gates0_2_we0_local;
reg    gates0_2_ce0_local;
reg    gates0_1_we0_local;
reg    gates0_1_ce0_local;
reg    gates0_we0_local;
reg    gates0_ce0_local;
reg    gates0_4_we0_local;
reg    gates0_4_ce0_local;
reg    gates1_3_we0_local;
wire   [2:0] trunc_ln121_fu_1261_p1;
reg    gates1_3_ce0_local;
reg    gates1_2_we0_local;
reg    gates1_2_ce0_local;
reg    gates1_1_we0_local;
reg    gates1_1_ce0_local;
reg    gates1_we0_local;
reg    gates1_ce0_local;
reg    gates1_4_we0_local;
reg    gates1_4_ce0_local;
reg    logits_ce0_local;
reg   [3:0] logits_address0_local;
reg    logits_we0_local;
reg   [31:0] grp_fu_726_p0;
reg   [31:0] grp_fu_726_p1;
wire   [14:0] shl_ln_fu_766_p3;
wire   [63:0] zext_ln71_fu_774_p1;
wire   [63:0] add_ln71_fu_778_p2;
wire   [61:0] trunc_ln140_1_fu_802_p4;
wire   [6:0] trunc_ln77_fu_860_p1;
wire   [17:0] shl_ln1_fu_864_p4;
wire   [63:0] zext_ln77_fu_873_p1;
wire   [63:0] add_ln77_fu_877_p2;
wire   [63:0] add_ln77_1_fu_892_p2;
wire   [8:0] zext_ln76_fu_856_p1;
wire   [10:0] shl_ln3_fu_912_p3;
wire   [63:0] zext_ln89_2_fu_920_p1;
wire   [63:0] add_ln89_fu_924_p2;
wire   [61:0] trunc_ln1_fu_929_p4;
wire   [63:0] add_ln89_1_fu_949_p2;
wire   [61:0] trunc_ln89_1_fu_954_p4;
wire   [8:0] mul_ln89_fu_999_p0;
wire   [10:0] mul_ln89_fu_999_p1;
wire   [18:0] mul_ln89_fu_999_p2;
wire   [3:0] grp_fu_1015_p1;
wire   [6:0] trunc_ln109_fu_1079_p1;
wire   [17:0] shl_ln2_fu_1083_p4;
wire   [63:0] zext_ln109_fu_1092_p1;
wire   [63:0] add_ln109_fu_1096_p2;
wire   [63:0] add_ln109_1_fu_1111_p2;
wire   [8:0] zext_ln108_fu_1075_p1;
wire   [10:0] shl_ln4_fu_1131_p3;
wire   [63:0] zext_ln121_2_fu_1139_p1;
wire   [63:0] add_ln121_fu_1143_p2;
wire   [61:0] trunc_ln4_fu_1148_p4;
wire   [63:0] add_ln121_1_fu_1168_p2;
wire   [61:0] trunc_ln121_1_fu_1173_p4;
wire   [8:0] mul_ln121_fu_1228_p0;
wire   [10:0] mul_ln121_fu_1228_p1;
wire   [18:0] mul_ln121_fu_1228_p2;
wire   [3:0] grp_fu_1244_p1;
wire   [62:0] zext_ln140_1_fu_1279_p1;
wire   [62:0] add_ln146_fu_1292_p2;
wire   [61:0] trunc_ln5_fu_1312_p4;
reg    grp_fu_726_ce;
wire    ap_CS_fsm_state20;
wire    ap_CS_fsm_state21;
wire    ap_CS_fsm_state22;
wire    ap_CS_fsm_state23;
wire    ap_CS_fsm_state24;
wire    ap_CS_fsm_state25;
wire    ap_CS_fsm_state26;
wire    ap_CS_fsm_state29;
wire    ap_CS_fsm_state30;
wire    ap_CS_fsm_state31;
wire    ap_CS_fsm_state32;
wire    ap_CS_fsm_state33;
wire    ap_CS_fsm_state34;
wire    ap_CS_fsm_state36;
wire    ap_CS_fsm_state39;
wire    ap_CS_fsm_state40;
wire    ap_CS_fsm_state41;
wire    ap_CS_fsm_state42;
wire    ap_CS_fsm_state43;
wire    ap_CS_fsm_state44;
wire    ap_CS_fsm_state45;
wire    ap_CS_fsm_state46;
wire    ap_CS_fsm_state74;
wire    ap_CS_fsm_state75;
wire    ap_CS_fsm_state76;
wire    ap_CS_fsm_state77;
wire    ap_CS_fsm_state78;
wire    ap_CS_fsm_state79;
wire    ap_CS_fsm_state80;
wire    ap_CS_fsm_state83;
wire    ap_CS_fsm_state84;
wire    ap_CS_fsm_state85;
wire    ap_CS_fsm_state86;
wire    ap_CS_fsm_state87;
wire    ap_CS_fsm_state88;
wire    ap_CS_fsm_state90;
wire    ap_CS_fsm_state93;
wire    ap_CS_fsm_state94;
wire    ap_CS_fsm_state95;
wire    ap_CS_fsm_state96;
wire    ap_CS_fsm_state97;
wire    ap_CS_fsm_state98;
wire    ap_CS_fsm_state99;
wire    ap_CS_fsm_state100;
wire    ap_CS_fsm_state116;
wire    ap_CS_fsm_state117;
wire    ap_CS_fsm_state118;
wire    ap_CS_fsm_state119;
wire    ap_CS_fsm_state120;
wire    ap_CS_fsm_state121;
wire    ap_CS_fsm_state122;
wire    ap_CS_fsm_state123;
reg    grp_fu_1015_ap_start;
wire    grp_fu_1015_ap_done;
reg    grp_fu_1015_ce;
reg    grp_fu_1244_ap_start;
wire    grp_fu_1244_ap_done;
reg    grp_fu_1244_ce;
wire   [31:0] grp_fu_1732_p2;
reg   [31:0] grp_fu_1732_p0;
reg   [31:0] grp_fu_1732_p1;
reg    grp_fu_1732_ce;
wire   [31:0] grp_fu_1736_p2;
reg   [31:0] grp_fu_1736_p0;
reg   [31:0] grp_fu_1736_p1;
reg    grp_fu_1736_ce;
wire   [31:0] grp_fu_1740_p2;
reg   [31:0] grp_fu_1740_p0;
reg   [31:0] grp_fu_1740_p1;
reg    grp_fu_1740_ce;
reg   [133:0] ap_NS_fsm;
reg    ap_ST_fsm_state1_blk;
reg    ap_ST_fsm_state2_blk;
wire    ap_ST_fsm_state3_blk;
wire    ap_ST_fsm_state4_blk;
wire    ap_ST_fsm_state5_blk;
wire    ap_ST_fsm_state6_blk;
reg    ap_ST_fsm_state7_blk;
reg    ap_ST_fsm_state8_blk;
wire    ap_ST_fsm_state9_blk;
wire    ap_ST_fsm_state10_blk;
wire    ap_ST_fsm_state11_blk;
wire    ap_ST_fsm_state12_blk;
wire    ap_ST_fsm_state13_blk;
wire    ap_ST_fsm_state14_blk;
wire    ap_ST_fsm_state15_blk;
wire    ap_ST_fsm_state16_blk;
reg    ap_ST_fsm_state17_blk;
reg    ap_ST_fsm_state18_blk;
reg    ap_ST_fsm_state19_blk;
wire    ap_ST_fsm_state20_blk;
wire    ap_ST_fsm_state21_blk;
wire    ap_ST_fsm_state22_blk;
wire    ap_ST_fsm_state23_blk;
wire    ap_ST_fsm_state24_blk;
wire    ap_ST_fsm_state25_blk;
wire    ap_ST_fsm_state26_blk;
reg    ap_ST_fsm_state27_blk;
wire    ap_ST_fsm_state28_blk;
wire    ap_ST_fsm_state29_blk;
wire    ap_ST_fsm_state30_blk;
wire    ap_ST_fsm_state31_blk;
wire    ap_ST_fsm_state32_blk;
wire    ap_ST_fsm_state33_blk;
wire    ap_ST_fsm_state34_blk;
wire    ap_ST_fsm_state35_blk;
wire    ap_ST_fsm_state36_blk;
reg    ap_ST_fsm_state37_blk;
wire    ap_ST_fsm_state38_blk;
wire    ap_ST_fsm_state39_blk;
wire    ap_ST_fsm_state40_blk;
wire    ap_ST_fsm_state41_blk;
wire    ap_ST_fsm_state42_blk;
wire    ap_ST_fsm_state43_blk;
wire    ap_ST_fsm_state44_blk;
wire    ap_ST_fsm_state45_blk;
wire    ap_ST_fsm_state46_blk;
wire    ap_ST_fsm_state47_blk;
wire    ap_ST_fsm_state48_blk;
reg    ap_ST_fsm_state49_blk;
wire    ap_ST_fsm_state50_blk;
wire    ap_ST_fsm_state51_blk;
reg    ap_ST_fsm_state52_blk;
wire    ap_ST_fsm_state53_blk;
wire    ap_ST_fsm_state54_blk;
wire    ap_ST_fsm_state55_blk;
wire    ap_ST_fsm_state56_blk;
wire    ap_ST_fsm_state57_blk;
wire    ap_ST_fsm_state58_blk;
wire    ap_ST_fsm_state59_blk;
wire    ap_ST_fsm_state60_blk;
reg    ap_ST_fsm_state61_blk;
reg    ap_ST_fsm_state62_blk;
wire    ap_ST_fsm_state63_blk;
wire    ap_ST_fsm_state64_blk;
wire    ap_ST_fsm_state65_blk;
wire    ap_ST_fsm_state66_blk;
wire    ap_ST_fsm_state67_blk;
wire    ap_ST_fsm_state68_blk;
wire    ap_ST_fsm_state69_blk;
wire    ap_ST_fsm_state70_blk;
reg    ap_ST_fsm_state71_blk;
reg    ap_ST_fsm_state72_blk;
reg    ap_ST_fsm_state73_blk;
wire    ap_ST_fsm_state74_blk;
wire    ap_ST_fsm_state75_blk;
wire    ap_ST_fsm_state76_blk;
wire    ap_ST_fsm_state77_blk;
wire    ap_ST_fsm_state78_blk;
wire    ap_ST_fsm_state79_blk;
wire    ap_ST_fsm_state80_blk;
reg    ap_ST_fsm_state81_blk;
wire    ap_ST_fsm_state82_blk;
wire    ap_ST_fsm_state83_blk;
wire    ap_ST_fsm_state84_blk;
wire    ap_ST_fsm_state85_blk;
wire    ap_ST_fsm_state86_blk;
wire    ap_ST_fsm_state87_blk;
wire    ap_ST_fsm_state88_blk;
wire    ap_ST_fsm_state89_blk;
wire    ap_ST_fsm_state90_blk;
reg    ap_ST_fsm_state91_blk;
wire    ap_ST_fsm_state92_blk;
wire    ap_ST_fsm_state93_blk;
wire    ap_ST_fsm_state94_blk;
wire    ap_ST_fsm_state95_blk;
wire    ap_ST_fsm_state96_blk;
wire    ap_ST_fsm_state97_blk;
wire    ap_ST_fsm_state98_blk;
wire    ap_ST_fsm_state99_blk;
wire    ap_ST_fsm_state100_blk;
wire    ap_ST_fsm_state101_blk;
wire    ap_ST_fsm_state102_blk;
reg    ap_ST_fsm_state103_blk;
wire    ap_ST_fsm_state104_blk;
reg    ap_ST_fsm_state105_blk;
reg    ap_ST_fsm_state106_blk;
wire    ap_ST_fsm_state107_blk;
wire    ap_ST_fsm_state108_blk;
wire    ap_ST_fsm_state109_blk;
wire    ap_ST_fsm_state110_blk;
wire    ap_ST_fsm_state111_blk;
wire    ap_ST_fsm_state112_blk;
wire    ap_ST_fsm_state113_blk;
reg    ap_ST_fsm_state114_blk;
wire    ap_ST_fsm_state115_blk;
wire    ap_ST_fsm_state116_blk;
wire    ap_ST_fsm_state117_blk;
wire    ap_ST_fsm_state118_blk;
wire    ap_ST_fsm_state119_blk;
wire    ap_ST_fsm_state120_blk;
wire    ap_ST_fsm_state121_blk;
wire    ap_ST_fsm_state122_blk;
wire    ap_ST_fsm_state123_blk;
wire    ap_ST_fsm_state124_blk;
wire    ap_ST_fsm_state125_blk;
reg    ap_ST_fsm_state126_blk;
wire    ap_ST_fsm_state127_blk;
reg    ap_ST_fsm_state128_blk;
reg    ap_ST_fsm_state129_blk;
wire    ap_ST_fsm_state130_blk;
wire    ap_ST_fsm_state131_blk;
wire    ap_ST_fsm_state132_blk;
wire    ap_ST_fsm_state133_blk;
reg    ap_ST_fsm_state134_blk;
wire   [18:0] mul_ln121_fu_1228_p00;
wire   [18:0] mul_ln89_fu_999_p00;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 134'd1;
#0 grp_lstm_inference_Pipeline_1_fu_623_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_2_fu_629_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_3_fu_635_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_4_fu_641_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_start_reg = 1'b0;
#0 grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_start_reg = 1'b0;
#0 t_fu_178 = 6'd0;
#0 i_fu_266 = 4'd0;
end

vadd_lstm_inference_h0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 128 ),
    .AddressWidth( 7 ))
h0_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(h0_address0),
    .ce0(h0_ce0),
    .we0(h0_we0),
    .d0(h0_d0),
    .q0(h0_q0)
);

vadd_lstm_inference_c0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 128 ),
    .AddressWidth( 7 ))
c0_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(c0_address0),
    .ce0(c0_ce0),
    .we0(c0_we0),
    .d0(c0_d0),
    .address1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_address1),
    .ce1(c0_ce1),
    .q1(c0_q1)
);

vadd_lstm_inference_h0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 128 ),
    .AddressWidth( 7 ))
h1_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(h1_address0),
    .ce0(h1_ce0),
    .we0(h1_we0),
    .d0(h1_d0),
    .q0(h1_q0)
);

vadd_lstm_inference_c0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 128 ),
    .AddressWidth( 7 ))
c1_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(c1_address0),
    .ce0(c1_ce0),
    .we0(c1_we0),
    .d0(c1_d0),
    .address1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_address1),
    .ce1(c1_ce1),
    .q1(c1_q1)
);

vadd_lstm_inference_gates0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 103 ),
    .AddressWidth( 7 ))
gates0_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(gates0_address0),
    .ce0(gates0_ce0),
    .we0(gates0_we0_local),
    .d0(reg_730),
    .q0(gates0_q0)
);

vadd_lstm_inference_gates0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 103 ),
    .AddressWidth( 7 ))
gates0_1_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(gates0_1_address0),
    .ce0(gates0_1_ce0),
    .we0(gates0_1_we0_local),
    .d0(reg_730),
    .q0(gates0_1_q0)
);

vadd_lstm_inference_gates0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 103 ),
    .AddressWidth( 7 ))
gates0_2_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(gates0_2_address0),
    .ce0(gates0_2_ce0),
    .we0(gates0_2_we0_local),
    .d0(reg_730),
    .q0(gates0_2_q0)
);

vadd_lstm_inference_gates0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 103 ),
    .AddressWidth( 7 ))
gates0_3_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(gates0_3_address0),
    .ce0(gates0_3_ce0),
    .we0(gates0_3_we0_local),
    .d0(reg_730),
    .q0(gates0_3_q0)
);

vadd_lstm_inference_gates0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 103 ),
    .AddressWidth( 7 ))
gates0_4_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(gates0_4_address0),
    .ce0(gates0_4_ce0),
    .we0(gates0_4_we0_local),
    .d0(reg_730),
    .q0(gates0_4_q0)
);

vadd_lstm_inference_gates0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 103 ),
    .AddressWidth( 7 ))
gates1_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(gates1_address0),
    .ce0(gates1_ce0),
    .we0(gates1_we0_local),
    .d0(reg_730),
    .q0(gates1_q0)
);

vadd_lstm_inference_gates0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 103 ),
    .AddressWidth( 7 ))
gates1_1_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(gates1_1_address0),
    .ce0(gates1_1_ce0),
    .we0(gates1_1_we0_local),
    .d0(reg_730),
    .q0(gates1_1_q0)
);

vadd_lstm_inference_gates0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 103 ),
    .AddressWidth( 7 ))
gates1_2_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(gates1_2_address0),
    .ce0(gates1_2_ce0),
    .we0(gates1_2_we0_local),
    .d0(reg_730),
    .q0(gates1_2_q0)
);

vadd_lstm_inference_gates0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 103 ),
    .AddressWidth( 7 ))
gates1_3_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(gates1_3_address0),
    .ce0(gates1_3_ce0),
    .we0(gates1_3_we0_local),
    .d0(reg_730),
    .q0(gates1_3_q0)
);

vadd_lstm_inference_gates0_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 103 ),
    .AddressWidth( 7 ))
gates1_4_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(gates1_4_address0),
    .ce0(gates1_4_ce0),
    .we0(gates1_4_we0_local),
    .d0(reg_730),
    .q0(gates1_4_q0)
);

vadd_lstm_inference_logits_RAM_AUTO_1R1W #(
    .DataWidth( 32 ),
    .AddressRange( 10 ),
    .AddressWidth( 4 ))
logits_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(logits_address0),
    .ce0(logits_ce0),
    .we0(logits_we0_local),
    .d0(reg_730),
    .q0(logits_q0)
);

vadd_lstm_inference_Pipeline_1 grp_lstm_inference_Pipeline_1_fu_623(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_1_fu_623_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_1_fu_623_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_1_fu_623_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_1_fu_623_ap_ready),
    .h0_address0(grp_lstm_inference_Pipeline_1_fu_623_h0_address0),
    .h0_ce0(grp_lstm_inference_Pipeline_1_fu_623_h0_ce0),
    .h0_we0(grp_lstm_inference_Pipeline_1_fu_623_h0_we0),
    .h0_d0(grp_lstm_inference_Pipeline_1_fu_623_h0_d0)
);

vadd_lstm_inference_Pipeline_2 grp_lstm_inference_Pipeline_2_fu_629(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_2_fu_629_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_2_fu_629_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_2_fu_629_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_2_fu_629_ap_ready),
    .c0_address0(grp_lstm_inference_Pipeline_2_fu_629_c0_address0),
    .c0_ce0(grp_lstm_inference_Pipeline_2_fu_629_c0_ce0),
    .c0_we0(grp_lstm_inference_Pipeline_2_fu_629_c0_we0),
    .c0_d0(grp_lstm_inference_Pipeline_2_fu_629_c0_d0)
);

vadd_lstm_inference_Pipeline_3 grp_lstm_inference_Pipeline_3_fu_635(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_3_fu_635_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_3_fu_635_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_3_fu_635_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_3_fu_635_ap_ready),
    .h1_address0(grp_lstm_inference_Pipeline_3_fu_635_h1_address0),
    .h1_ce0(grp_lstm_inference_Pipeline_3_fu_635_h1_ce0),
    .h1_we0(grp_lstm_inference_Pipeline_3_fu_635_h1_we0),
    .h1_d0(grp_lstm_inference_Pipeline_3_fu_635_h1_d0)
);

vadd_lstm_inference_Pipeline_4 grp_lstm_inference_Pipeline_4_fu_641(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_4_fu_641_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_4_fu_641_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_4_fu_641_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_4_fu_641_ap_ready),
    .c1_address0(grp_lstm_inference_Pipeline_4_fu_641_c1_address0),
    .c1_ce0(grp_lstm_inference_Pipeline_4_fu_641_c1_ce0),
    .c1_we0(grp_lstm_inference_Pipeline_4_fu_641_c1_we0),
    .c1_d0(grp_lstm_inference_Pipeline_4_fu_641_c1_d0)
);

vadd_lstm_inference_Pipeline_VITIS_LOOP_94_6 grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_ready),
    .gates0_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_address0),
    .gates0_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_ce0),
    .gates0_q0(gates0_q0),
    .gates0_1_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_1_address0),
    .gates0_1_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_1_ce0),
    .gates0_1_q0(gates0_1_q0),
    .gates0_2_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_2_address0),
    .gates0_2_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_2_ce0),
    .gates0_2_q0(gates0_2_q0),
    .gates0_3_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_3_address0),
    .gates0_3_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_3_ce0),
    .gates0_3_q0(gates0_3_q0),
    .gates0_4_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_4_address0),
    .gates0_4_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_4_ce0),
    .gates0_4_q0(gates0_4_q0),
    .c0_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_address0),
    .c0_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_ce0),
    .c0_we0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_we0),
    .c0_d0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_d0),
    .c0_address1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_address1),
    .c0_ce1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_ce1),
    .c0_q1(c0_q1),
    .h0_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_address0),
    .h0_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_ce0),
    .h0_we0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_we0),
    .h0_d0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_d0),
    .grp_fu_726_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_din0),
    .grp_fu_726_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_din1),
    .grp_fu_726_p_opcode(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_opcode),
    .grp_fu_726_p_dout0(grp_fu_726_p2),
    .grp_fu_726_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_ce),
    .grp_fu_1732_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1732_p_din0),
    .grp_fu_1732_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1732_p_din1),
    .grp_fu_1732_p_dout0(grp_fu_1732_p2),
    .grp_fu_1732_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1732_p_ce),
    .grp_fu_1736_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1736_p_din0),
    .grp_fu_1736_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1736_p_din1),
    .grp_fu_1736_p_dout0(grp_fu_1736_p2),
    .grp_fu_1736_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1736_p_ce),
    .grp_fu_1740_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1740_p_din0),
    .grp_fu_1740_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1740_p_din1),
    .grp_fu_1740_p_dout0(grp_fu_1740_p2),
    .grp_fu_1740_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1740_p_ce),
    .grp_sigmoid_fu_1744_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_sigmoid_fu_1744_p_din1),
    .grp_sigmoid_fu_1744_p_dout0(grp_sigmoid_fu_1744_ap_return),
    .grp_sigmoid_fu_1749_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_sigmoid_fu_1749_p_din1),
    .grp_sigmoid_fu_1749_p_dout0(grp_sigmoid_fu_1749_ap_return),
    .grp_sigmoid_fu_1754_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_sigmoid_fu_1754_p_din1),
    .grp_sigmoid_fu_1754_p_dout0(grp_sigmoid_fu_1754_ap_return),
    .grp_tanh_approx_fu_1759_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_tanh_approx_fu_1759_p_din1),
    .grp_tanh_approx_fu_1759_p_dout0(grp_tanh_approx_fu_1759_ap_return),
    .grp_tanh_approx_fu_1764_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_tanh_approx_fu_1764_p_din1),
    .grp_tanh_approx_fu_1764_p_dout0(grp_tanh_approx_fu_1764_ap_return)
);

vadd_lstm_inference_Pipeline_VITIS_LOOP_81_4 grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_ready),
    .sext_ln81(trunc_ln7_reg_1506),
    .m_axi_gmem0_AWVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWVALID),
    .m_axi_gmem0_AWREADY(1'b0),
    .m_axi_gmem0_AWADDR(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWADDR),
    .m_axi_gmem0_AWID(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWID),
    .m_axi_gmem0_AWLEN(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWLEN),
    .m_axi_gmem0_AWSIZE(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWSIZE),
    .m_axi_gmem0_AWBURST(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWBURST),
    .m_axi_gmem0_AWLOCK(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWLOCK),
    .m_axi_gmem0_AWCACHE(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWCACHE),
    .m_axi_gmem0_AWPROT(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWPROT),
    .m_axi_gmem0_AWQOS(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWQOS),
    .m_axi_gmem0_AWREGION(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWREGION),
    .m_axi_gmem0_AWUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_AWUSER),
    .m_axi_gmem0_WVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WVALID),
    .m_axi_gmem0_WREADY(1'b0),
    .m_axi_gmem0_WDATA(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WDATA),
    .m_axi_gmem0_WSTRB(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WSTRB),
    .m_axi_gmem0_WLAST(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WLAST),
    .m_axi_gmem0_WID(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WID),
    .m_axi_gmem0_WUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_WUSER),
    .m_axi_gmem0_ARVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARVALID),
    .m_axi_gmem0_ARREADY(m_axi_gmem0_ARREADY),
    .m_axi_gmem0_ARADDR(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARADDR),
    .m_axi_gmem0_ARID(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARID),
    .m_axi_gmem0_ARLEN(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARLEN),
    .m_axi_gmem0_ARSIZE(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARSIZE),
    .m_axi_gmem0_ARBURST(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARBURST),
    .m_axi_gmem0_ARLOCK(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARLOCK),
    .m_axi_gmem0_ARCACHE(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARCACHE),
    .m_axi_gmem0_ARPROT(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARPROT),
    .m_axi_gmem0_ARQOS(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARQOS),
    .m_axi_gmem0_ARREGION(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARREGION),
    .m_axi_gmem0_ARUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARUSER),
    .m_axi_gmem0_RVALID(m_axi_gmem0_RVALID),
    .m_axi_gmem0_RREADY(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_RREADY),
    .m_axi_gmem0_RDATA(m_axi_gmem0_RDATA),
    .m_axi_gmem0_RLAST(m_axi_gmem0_RLAST),
    .m_axi_gmem0_RID(m_axi_gmem0_RID),
    .m_axi_gmem0_RFIFONUM(m_axi_gmem0_RFIFONUM),
    .m_axi_gmem0_RUSER(m_axi_gmem0_RUSER),
    .m_axi_gmem0_RRESP(m_axi_gmem0_RRESP),
    .m_axi_gmem0_BVALID(1'b0),
    .m_axi_gmem0_BREADY(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_BREADY),
    .m_axi_gmem0_BRESP(2'd0),
    .m_axi_gmem0_BID(1'd0),
    .m_axi_gmem0_BUSER(1'd0),
    .sext_ln75(p_cast_reg_1458),
    .xC_out(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_xC_out),
    .xC_out_ap_vld(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_xC_out_ap_vld),
    .grp_fu_726_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_din0),
    .grp_fu_726_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_din1),
    .grp_fu_726_p_opcode(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_opcode),
    .grp_fu_726_p_dout0(grp_fu_726_p2),
    .grp_fu_726_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_ce),
    .grp_fu_1732_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_1732_p_din0),
    .grp_fu_1732_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_1732_p_din1),
    .grp_fu_1732_p_dout0(grp_fu_1732_p2),
    .grp_fu_1732_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_1732_p_ce)
);

vadd_lstm_inference_Pipeline_VITIS_LOOP_85_5 grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_ready),
    .m_axi_gmem0_AWVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWVALID),
    .m_axi_gmem0_AWREADY(1'b0),
    .m_axi_gmem0_AWADDR(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWADDR),
    .m_axi_gmem0_AWID(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWID),
    .m_axi_gmem0_AWLEN(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWLEN),
    .m_axi_gmem0_AWSIZE(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWSIZE),
    .m_axi_gmem0_AWBURST(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWBURST),
    .m_axi_gmem0_AWLOCK(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWLOCK),
    .m_axi_gmem0_AWCACHE(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWCACHE),
    .m_axi_gmem0_AWPROT(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWPROT),
    .m_axi_gmem0_AWQOS(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWQOS),
    .m_axi_gmem0_AWREGION(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWREGION),
    .m_axi_gmem0_AWUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_AWUSER),
    .m_axi_gmem0_WVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WVALID),
    .m_axi_gmem0_WREADY(1'b0),
    .m_axi_gmem0_WDATA(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WDATA),
    .m_axi_gmem0_WSTRB(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WSTRB),
    .m_axi_gmem0_WLAST(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WLAST),
    .m_axi_gmem0_WID(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WID),
    .m_axi_gmem0_WUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_WUSER),
    .m_axi_gmem0_ARVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARVALID),
    .m_axi_gmem0_ARREADY(m_axi_gmem0_ARREADY),
    .m_axi_gmem0_ARADDR(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARADDR),
    .m_axi_gmem0_ARID(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARID),
    .m_axi_gmem0_ARLEN(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARLEN),
    .m_axi_gmem0_ARSIZE(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARSIZE),
    .m_axi_gmem0_ARBURST(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARBURST),
    .m_axi_gmem0_ARLOCK(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARLOCK),
    .m_axi_gmem0_ARCACHE(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARCACHE),
    .m_axi_gmem0_ARPROT(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARPROT),
    .m_axi_gmem0_ARQOS(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARQOS),
    .m_axi_gmem0_ARREGION(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARREGION),
    .m_axi_gmem0_ARUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARUSER),
    .m_axi_gmem0_RVALID(m_axi_gmem0_RVALID),
    .m_axi_gmem0_RREADY(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_RREADY),
    .m_axi_gmem0_RDATA(m_axi_gmem0_RDATA),
    .m_axi_gmem0_RLAST(m_axi_gmem0_RLAST),
    .m_axi_gmem0_RID(m_axi_gmem0_RID),
    .m_axi_gmem0_RFIFONUM(m_axi_gmem0_RFIFONUM),
    .m_axi_gmem0_RUSER(m_axi_gmem0_RUSER),
    .m_axi_gmem0_RRESP(m_axi_gmem0_RRESP),
    .m_axi_gmem0_BVALID(1'b0),
    .m_axi_gmem0_BREADY(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_BREADY),
    .m_axi_gmem0_BRESP(2'd0),
    .m_axi_gmem0_BID(1'd0),
    .m_axi_gmem0_BUSER(1'd0),
    .sext_ln85(trunc_ln8_reg_1511),
    .h0_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_h0_address0),
    .h0_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_h0_ce0),
    .h0_q0(h0_q0),
    .hC_out(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_hC_out),
    .hC_out_ap_vld(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_hC_out_ap_vld),
    .grp_fu_726_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_din0),
    .grp_fu_726_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_din1),
    .grp_fu_726_p_opcode(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_opcode),
    .grp_fu_726_p_dout0(grp_fu_726_p2),
    .grp_fu_726_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_ce),
    .grp_fu_1732_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_1732_p_din0),
    .grp_fu_1732_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_1732_p_din1),
    .grp_fu_1732_p_dout0(grp_fu_1732_p2),
    .grp_fu_1732_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_1732_p_ce)
);

vadd_lstm_inference_Pipeline_VITIS_LOOP_126_11 grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_ready),
    .gates1_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_address0),
    .gates1_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_ce0),
    .gates1_q0(gates1_q0),
    .gates1_1_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_1_address0),
    .gates1_1_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_1_ce0),
    .gates1_1_q0(gates1_1_q0),
    .gates1_2_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_2_address0),
    .gates1_2_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_2_ce0),
    .gates1_2_q0(gates1_2_q0),
    .gates1_3_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_3_address0),
    .gates1_3_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_3_ce0),
    .gates1_3_q0(gates1_3_q0),
    .gates1_4_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_4_address0),
    .gates1_4_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_4_ce0),
    .gates1_4_q0(gates1_4_q0),
    .c1_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_address0),
    .c1_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_ce0),
    .c1_we0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_we0),
    .c1_d0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_d0),
    .c1_address1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_address1),
    .c1_ce1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_ce1),
    .c1_q1(c1_q1),
    .h1_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_address0),
    .h1_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_ce0),
    .h1_we0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_we0),
    .h1_d0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_d0),
    .grp_fu_726_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_din0),
    .grp_fu_726_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_din1),
    .grp_fu_726_p_opcode(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_opcode),
    .grp_fu_726_p_dout0(grp_fu_726_p2),
    .grp_fu_726_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_ce),
    .grp_fu_1732_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1732_p_din0),
    .grp_fu_1732_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1732_p_din1),
    .grp_fu_1732_p_dout0(grp_fu_1732_p2),
    .grp_fu_1732_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1732_p_ce),
    .grp_fu_1736_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1736_p_din0),
    .grp_fu_1736_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1736_p_din1),
    .grp_fu_1736_p_dout0(grp_fu_1736_p2),
    .grp_fu_1736_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1736_p_ce),
    .grp_fu_1740_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1740_p_din0),
    .grp_fu_1740_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1740_p_din1),
    .grp_fu_1740_p_dout0(grp_fu_1740_p2),
    .grp_fu_1740_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1740_p_ce),
    .grp_sigmoid_fu_1744_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_sigmoid_fu_1744_p_din1),
    .grp_sigmoid_fu_1744_p_dout0(grp_sigmoid_fu_1744_ap_return),
    .grp_sigmoid_fu_1749_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_sigmoid_fu_1749_p_din1),
    .grp_sigmoid_fu_1749_p_dout0(grp_sigmoid_fu_1749_ap_return),
    .grp_sigmoid_fu_1754_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_sigmoid_fu_1754_p_din1),
    .grp_sigmoid_fu_1754_p_dout0(grp_sigmoid_fu_1754_ap_return),
    .grp_tanh_approx_fu_1759_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_tanh_approx_fu_1759_p_din1),
    .grp_tanh_approx_fu_1759_p_dout0(grp_tanh_approx_fu_1759_ap_return),
    .grp_tanh_approx_fu_1764_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_tanh_approx_fu_1764_p_din1),
    .grp_tanh_approx_fu_1764_p_dout0(grp_tanh_approx_fu_1764_ap_return)
);

vadd_lstm_inference_Pipeline_VITIS_LOOP_113_9 grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_ready),
    .m_axi_gmem1_AWVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWVALID),
    .m_axi_gmem1_AWREADY(1'b0),
    .m_axi_gmem1_AWADDR(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWADDR),
    .m_axi_gmem1_AWID(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWID),
    .m_axi_gmem1_AWLEN(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWLEN),
    .m_axi_gmem1_AWSIZE(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWSIZE),
    .m_axi_gmem1_AWBURST(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWBURST),
    .m_axi_gmem1_AWLOCK(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWLOCK),
    .m_axi_gmem1_AWCACHE(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWCACHE),
    .m_axi_gmem1_AWPROT(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWPROT),
    .m_axi_gmem1_AWQOS(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWQOS),
    .m_axi_gmem1_AWREGION(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWREGION),
    .m_axi_gmem1_AWUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_AWUSER),
    .m_axi_gmem1_WVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WVALID),
    .m_axi_gmem1_WREADY(1'b0),
    .m_axi_gmem1_WDATA(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WDATA),
    .m_axi_gmem1_WSTRB(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WSTRB),
    .m_axi_gmem1_WLAST(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WLAST),
    .m_axi_gmem1_WID(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WID),
    .m_axi_gmem1_WUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_WUSER),
    .m_axi_gmem1_ARVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARVALID),
    .m_axi_gmem1_ARREADY(m_axi_gmem1_ARREADY),
    .m_axi_gmem1_ARADDR(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARADDR),
    .m_axi_gmem1_ARID(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARID),
    .m_axi_gmem1_ARLEN(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARLEN),
    .m_axi_gmem1_ARSIZE(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARSIZE),
    .m_axi_gmem1_ARBURST(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARBURST),
    .m_axi_gmem1_ARLOCK(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARLOCK),
    .m_axi_gmem1_ARCACHE(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARCACHE),
    .m_axi_gmem1_ARPROT(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARPROT),
    .m_axi_gmem1_ARQOS(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARQOS),
    .m_axi_gmem1_ARREGION(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARREGION),
    .m_axi_gmem1_ARUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARUSER),
    .m_axi_gmem1_RVALID(m_axi_gmem1_RVALID),
    .m_axi_gmem1_RREADY(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_RREADY),
    .m_axi_gmem1_RDATA(m_axi_gmem1_RDATA),
    .m_axi_gmem1_RLAST(m_axi_gmem1_RLAST),
    .m_axi_gmem1_RID(m_axi_gmem1_RID),
    .m_axi_gmem1_RFIFONUM(m_axi_gmem1_RFIFONUM),
    .m_axi_gmem1_RUSER(m_axi_gmem1_RUSER),
    .m_axi_gmem1_RRESP(m_axi_gmem1_RRESP),
    .m_axi_gmem1_BVALID(1'b0),
    .m_axi_gmem1_BREADY(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_BREADY),
    .m_axi_gmem1_BRESP(2'd0),
    .m_axi_gmem1_BID(1'd0),
    .m_axi_gmem1_BUSER(1'd0),
    .sext_ln113(trunc_ln2_reg_1605),
    .h0_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_h0_address0),
    .h0_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_h0_ce0),
    .h0_q0(h0_q0),
    .xC_2_out(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_xC_2_out),
    .xC_2_out_ap_vld(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_xC_2_out_ap_vld),
    .grp_fu_726_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_din0),
    .grp_fu_726_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_din1),
    .grp_fu_726_p_opcode(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_opcode),
    .grp_fu_726_p_dout0(grp_fu_726_p2),
    .grp_fu_726_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_ce),
    .grp_fu_1732_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_1732_p_din0),
    .grp_fu_1732_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_1732_p_din1),
    .grp_fu_1732_p_dout0(grp_fu_1732_p2),
    .grp_fu_1732_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_1732_p_ce)
);

vadd_lstm_inference_Pipeline_VITIS_LOOP_117_10 grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_ready),
    .m_axi_gmem1_AWVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWVALID),
    .m_axi_gmem1_AWREADY(1'b0),
    .m_axi_gmem1_AWADDR(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWADDR),
    .m_axi_gmem1_AWID(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWID),
    .m_axi_gmem1_AWLEN(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWLEN),
    .m_axi_gmem1_AWSIZE(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWSIZE),
    .m_axi_gmem1_AWBURST(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWBURST),
    .m_axi_gmem1_AWLOCK(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWLOCK),
    .m_axi_gmem1_AWCACHE(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWCACHE),
    .m_axi_gmem1_AWPROT(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWPROT),
    .m_axi_gmem1_AWQOS(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWQOS),
    .m_axi_gmem1_AWREGION(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWREGION),
    .m_axi_gmem1_AWUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_AWUSER),
    .m_axi_gmem1_WVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WVALID),
    .m_axi_gmem1_WREADY(1'b0),
    .m_axi_gmem1_WDATA(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WDATA),
    .m_axi_gmem1_WSTRB(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WSTRB),
    .m_axi_gmem1_WLAST(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WLAST),
    .m_axi_gmem1_WID(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WID),
    .m_axi_gmem1_WUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_WUSER),
    .m_axi_gmem1_ARVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARVALID),
    .m_axi_gmem1_ARREADY(m_axi_gmem1_ARREADY),
    .m_axi_gmem1_ARADDR(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARADDR),
    .m_axi_gmem1_ARID(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARID),
    .m_axi_gmem1_ARLEN(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARLEN),
    .m_axi_gmem1_ARSIZE(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARSIZE),
    .m_axi_gmem1_ARBURST(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARBURST),
    .m_axi_gmem1_ARLOCK(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARLOCK),
    .m_axi_gmem1_ARCACHE(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARCACHE),
    .m_axi_gmem1_ARPROT(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARPROT),
    .m_axi_gmem1_ARQOS(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARQOS),
    .m_axi_gmem1_ARREGION(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARREGION),
    .m_axi_gmem1_ARUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARUSER),
    .m_axi_gmem1_RVALID(m_axi_gmem1_RVALID),
    .m_axi_gmem1_RREADY(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_RREADY),
    .m_axi_gmem1_RDATA(m_axi_gmem1_RDATA),
    .m_axi_gmem1_RLAST(m_axi_gmem1_RLAST),
    .m_axi_gmem1_RID(m_axi_gmem1_RID),
    .m_axi_gmem1_RFIFONUM(m_axi_gmem1_RFIFONUM),
    .m_axi_gmem1_RUSER(m_axi_gmem1_RUSER),
    .m_axi_gmem1_RRESP(m_axi_gmem1_RRESP),
    .m_axi_gmem1_BVALID(1'b0),
    .m_axi_gmem1_BREADY(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_BREADY),
    .m_axi_gmem1_BRESP(2'd0),
    .m_axi_gmem1_BID(1'd0),
    .m_axi_gmem1_BUSER(1'd0),
    .sext_ln117(trunc_ln3_reg_1611),
    .h1_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_h1_address0),
    .h1_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_h1_ce0),
    .h1_q0(h1_q0),
    .hC_2_out(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_hC_2_out),
    .hC_2_out_ap_vld(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_hC_2_out_ap_vld),
    .grp_fu_726_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_din0),
    .grp_fu_726_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_din1),
    .grp_fu_726_p_opcode(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_opcode),
    .grp_fu_726_p_dout0(grp_fu_726_p2),
    .grp_fu_726_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_ce),
    .grp_fu_1732_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_1732_p_din0),
    .grp_fu_1732_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_1732_p_din1),
    .grp_fu_1732_p_dout0(grp_fu_1732_p2),
    .grp_fu_1732_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_1732_p_ce)
);

vadd_lstm_inference_Pipeline_VITIS_LOOP_142_13 grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_ready),
    .sext_ln140(trunc_ln_reg_1470),
    .zext_ln142(tmp_s_reg_1692),
    .m_axi_gmem1_AWVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWVALID),
    .m_axi_gmem1_AWREADY(1'b0),
    .m_axi_gmem1_AWADDR(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWADDR),
    .m_axi_gmem1_AWID(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWID),
    .m_axi_gmem1_AWLEN(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWLEN),
    .m_axi_gmem1_AWSIZE(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWSIZE),
    .m_axi_gmem1_AWBURST(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWBURST),
    .m_axi_gmem1_AWLOCK(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWLOCK),
    .m_axi_gmem1_AWCACHE(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWCACHE),
    .m_axi_gmem1_AWPROT(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWPROT),
    .m_axi_gmem1_AWQOS(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWQOS),
    .m_axi_gmem1_AWREGION(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWREGION),
    .m_axi_gmem1_AWUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_AWUSER),
    .m_axi_gmem1_WVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WVALID),
    .m_axi_gmem1_WREADY(1'b0),
    .m_axi_gmem1_WDATA(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WDATA),
    .m_axi_gmem1_WSTRB(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WSTRB),
    .m_axi_gmem1_WLAST(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WLAST),
    .m_axi_gmem1_WID(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WID),
    .m_axi_gmem1_WUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_WUSER),
    .m_axi_gmem1_ARVALID(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARVALID),
    .m_axi_gmem1_ARREADY(m_axi_gmem1_ARREADY),
    .m_axi_gmem1_ARADDR(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARADDR),
    .m_axi_gmem1_ARID(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARID),
    .m_axi_gmem1_ARLEN(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARLEN),
    .m_axi_gmem1_ARSIZE(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARSIZE),
    .m_axi_gmem1_ARBURST(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARBURST),
    .m_axi_gmem1_ARLOCK(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARLOCK),
    .m_axi_gmem1_ARCACHE(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARCACHE),
    .m_axi_gmem1_ARPROT(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARPROT),
    .m_axi_gmem1_ARQOS(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARQOS),
    .m_axi_gmem1_ARREGION(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARREGION),
    .m_axi_gmem1_ARUSER(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARUSER),
    .m_axi_gmem1_RVALID(m_axi_gmem1_RVALID),
    .m_axi_gmem1_RREADY(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_RREADY),
    .m_axi_gmem1_RDATA(m_axi_gmem1_RDATA),
    .m_axi_gmem1_RLAST(m_axi_gmem1_RLAST),
    .m_axi_gmem1_RID(m_axi_gmem1_RID),
    .m_axi_gmem1_RFIFONUM(m_axi_gmem1_RFIFONUM),
    .m_axi_gmem1_RUSER(m_axi_gmem1_RUSER),
    .m_axi_gmem1_RRESP(m_axi_gmem1_RRESP),
    .m_axi_gmem1_BVALID(1'b0),
    .m_axi_gmem1_BREADY(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_BREADY),
    .m_axi_gmem1_BRESP(2'd0),
    .m_axi_gmem1_BID(1'd0),
    .m_axi_gmem1_BUSER(1'd0),
    .h1_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_h1_address0),
    .h1_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_h1_ce0),
    .h1_q0(h1_q0),
    .dot_out(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_dot_out),
    .dot_out_ap_vld(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_dot_out_ap_vld),
    .grp_fu_726_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_din0),
    .grp_fu_726_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_din1),
    .grp_fu_726_p_opcode(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_opcode),
    .grp_fu_726_p_dout0(grp_fu_726_p2),
    .grp_fu_726_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_ce),
    .grp_fu_1732_p_din0(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_1732_p_din0),
    .grp_fu_1732_p_din1(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_1732_p_din1),
    .grp_fu_1732_p_dout0(grp_fu_1732_p2),
    .grp_fu_1732_p_ce(grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_1732_p_ce)
);

vadd_lstm_inference_Pipeline_VITIS_LOOP_152_14 grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_start),
    .ap_done(grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_done),
    .ap_idle(grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_idle),
    .ap_ready(grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_ready),
    .max_val(max_val_reg_1727),
    .logits_address0(grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_logits_address0),
    .logits_ce0(grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_logits_ce0),
    .logits_q0(logits_q0),
    .max_idx_out(grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_max_idx_out),
    .max_idx_out_ap_vld(grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_max_idx_out_ap_vld)
);

vadd_sigmoid grp_sigmoid_fu_1744(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .x(grp_sigmoid_fu_1744_x),
    .ap_return(grp_sigmoid_fu_1744_ap_return)
);

vadd_sigmoid grp_sigmoid_fu_1749(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .x(grp_sigmoid_fu_1749_x),
    .ap_return(grp_sigmoid_fu_1749_ap_return)
);

vadd_sigmoid grp_sigmoid_fu_1754(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .x(grp_sigmoid_fu_1754_x),
    .ap_return(grp_sigmoid_fu_1754_ap_return)
);

vadd_tanh_approx grp_tanh_approx_fu_1759(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .x(grp_tanh_approx_fu_1759_x),
    .ap_return(grp_tanh_approx_fu_1759_ap_return)
);

vadd_tanh_approx grp_tanh_approx_fu_1764(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .x(grp_tanh_approx_fu_1764_x),
    .ap_return(grp_tanh_approx_fu_1764_ap_return)
);

vadd_fadd_32ns_32ns_32_10_full_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 10 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fadd_32ns_32ns_32_10_full_dsp_1_U100(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(grp_fu_726_p0),
    .din1(grp_fu_726_p1),
    .ce(grp_fu_726_ce),
    .dout(grp_fu_726_p2)
);

vadd_mul_9ns_11ns_19_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 9 ),
    .din1_WIDTH( 11 ),
    .dout_WIDTH( 19 ))
mul_9ns_11ns_19_1_1_U101(
    .din0(mul_ln89_fu_999_p0),
    .din1(mul_ln89_fu_999_p1),
    .dout(mul_ln89_fu_999_p2)
);

vadd_urem_9ns_4ns_3_13_seq_1 #(
    .ID( 1 ),
    .NUM_STAGE( 13 ),
    .din0_WIDTH( 9 ),
    .din1_WIDTH( 4 ),
    .dout_WIDTH( 3 ))
urem_9ns_4ns_3_13_seq_1_U102(
    .clk(ap_clk),
    .reset(ap_rst),
    .start(grp_fu_1015_ap_start),
    .done(grp_fu_1015_ap_done),
    .din0(add_ln77_2_reg_1517),
    .din1(grp_fu_1015_p1),
    .ce(grp_fu_1015_ce),
    .dout(grp_fu_1015_p2)
);

vadd_mul_9ns_11ns_19_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 9 ),
    .din1_WIDTH( 11 ),
    .dout_WIDTH( 19 ))
mul_9ns_11ns_19_1_1_U103(
    .din0(mul_ln121_fu_1228_p0),
    .din1(mul_ln121_fu_1228_p1),
    .dout(mul_ln121_fu_1228_p2)
);

vadd_urem_9ns_4ns_3_13_seq_1 #(
    .ID( 1 ),
    .NUM_STAGE( 13 ),
    .din0_WIDTH( 9 ),
    .din1_WIDTH( 4 ),
    .dout_WIDTH( 3 ))
urem_9ns_4ns_3_13_seq_1_U104(
    .clk(ap_clk),
    .reset(ap_rst),
    .start(grp_fu_1244_ap_start),
    .done(grp_fu_1244_ap_done),
    .din0(add_ln109_2_reg_1617),
    .din1(grp_fu_1244_p1),
    .ce(grp_fu_1244_ce),
    .dout(grp_fu_1244_p2)
);

vadd_fmul_32ns_32ns_32_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fmul_32ns_32ns_32_5_max_dsp_1_U105(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(grp_fu_1732_p0),
    .din1(grp_fu_1732_p1),
    .ce(grp_fu_1732_ce),
    .dout(grp_fu_1732_p2)
);

vadd_fmul_32ns_32ns_32_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fmul_32ns_32ns_32_5_max_dsp_1_U106(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(grp_fu_1736_p0),
    .din1(grp_fu_1736_p1),
    .ce(grp_fu_1736_ce),
    .dout(grp_fu_1736_p2)
);

vadd_fmul_32ns_32ns_32_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fmul_32ns_32ns_32_5_max_dsp_1_U107(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(grp_fu_1740_p0),
    .din1(grp_fu_1740_p1),
    .ce(grp_fu_1740_ce),
    .dout(grp_fu_1740_p2)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_1_fu_623_ap_start_reg <= 1'b0;
    end else begin
        if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
            grp_lstm_inference_Pipeline_1_fu_623_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_1_fu_623_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_1_fu_623_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_2_fu_629_ap_start_reg <= 1'b0;
    end else begin
        if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
            grp_lstm_inference_Pipeline_2_fu_629_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_2_fu_629_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_2_fu_629_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_3_fu_635_ap_start_reg <= 1'b0;
    end else begin
        if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
            grp_lstm_inference_Pipeline_3_fu_635_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_3_fu_635_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_3_fu_635_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_4_fu_641_ap_start_reg <= 1'b0;
    end else begin
        if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
            grp_lstm_inference_Pipeline_4_fu_641_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_4_fu_641_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_4_fu_641_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_start_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_CS_fsm_state60)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_start_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_CS_fsm_state70)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_start_reg <= 1'b0;
    end else begin
        if (((1'b1 == ap_CS_fsm_state50) & (icmp_ln107_fu_1035_p2 == 1'd1))) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_start_reg <= 1'b0;
    end else begin
        if (((1'b1 == ap_CS_fsm_state104) & (icmp_ln140_fu_1267_p2 == 1'd0))) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_start_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_CS_fsm_state127)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_start_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_CS_fsm_state6)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_start_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_CS_fsm_state16)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_start_reg <= 1'b0;
    end else begin
        if (((1'b1 == ap_CS_fsm_state4) & (icmp_ln75_fu_820_p2 == 1'd1))) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_ready == 1'b1)) begin
            grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state49))) begin
        g_1_reg_601 <= 3'd0;
    end else if (((1'b1 == ap_CS_fsm_state51) & (icmp_ln108_fu_1063_p2 == 1'd1))) begin
        g_1_reg_601 <= add_ln107_reg_1582;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state5) & (icmp_ln76_fu_844_p2 == 1'd1))) begin
        g_reg_579 <= add_ln75_reg_1483;
    end else if (((1'b1 == ap_CS_fsm_state3) & (icmp_ln68_fu_754_p2 == 1'd0))) begin
        g_reg_579 <= 3'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state3) & (icmp_ln68_fu_754_p2 == 1'd1))) begin
        i_fu_266 <= 4'd0;
    end else if (((1'b1 == ap_CS_fsm_state104) & (icmp_ln140_fu_1267_p2 == 1'd0))) begin
        i_fu_266 <= add_ln140_fu_1273_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state48)) begin
        j_2_reg_590 <= add_ln76_reg_1501;
    end else if (((1'b1 == ap_CS_fsm_state4) & (icmp_ln75_fu_820_p2 == 1'd0))) begin
        j_2_reg_590 <= 8'd0;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state102)) begin
        j_reg_612 <= add_ln108_reg_1600;
    end else if (((1'b1 == ap_CS_fsm_state50) & (icmp_ln107_fu_1035_p2 == 1'd0))) begin
        j_reg_612 <= 8'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
        t_fu_178 <= 6'd0;
    end else if (((1'b1 == ap_CS_fsm_state50) & (icmp_ln107_fu_1035_p2 == 1'd1))) begin
        t_fu_178 <= add_ln68_reg_1453;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state50)) begin
        add_ln107_reg_1582 <= add_ln107_fu_1041_p2;
        empty_57_reg_1587 <= empty_57_fu_1047_p1;
        tmp_3_reg_1592[8 : 7] <= tmp_3_fu_1051_p3[8 : 7];
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state51)) begin
        add_ln108_reg_1600 <= add_ln108_fu_1069_p2;
        add_ln109_2_reg_1617 <= add_ln109_2_fu_1126_p2;
        gmem1_addr_4_reg_1623 <= sext_ln121_fu_1158_p1;
        gmem1_addr_5_reg_1629 <= sext_ln121_1_fu_1183_p1;
        trunc_ln2_reg_1605 <= {{add_ln109_fu_1096_p2[63:2]}};
        trunc_ln3_reg_1611 <= {{add_ln109_1_fu_1111_p2[63:2]}};
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state3)) begin
        add_ln68_reg_1453 <= add_ln68_fu_760_p2;
        p_cast_reg_1458 <= {{add_ln71_fu_778_p2[63:2]}};
        sext_ln140_reg_1475 <= sext_ln140_fu_811_p1;
        trunc_ln_reg_1470 <= {{wfc[63:2]}};
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state4)) begin
        add_ln75_reg_1483 <= add_ln75_fu_826_p2;
        empty_reg_1488 <= empty_fu_832_p1;
        tmp_2_reg_1493[8 : 7] <= tmp_2_fu_836_p3[8 : 7];
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state5)) begin
        add_ln76_reg_1501 <= add_ln76_fu_850_p2;
        add_ln77_2_reg_1517 <= add_ln77_2_fu_907_p2;
        gmem0_addr_2_reg_1523 <= sext_ln89_fu_939_p1;
        gmem0_addr_3_reg_1529 <= sext_ln89_1_fu_964_p1;
        trunc_ln7_reg_1506 <= {{add_ln77_fu_877_p2[63:2]}};
        trunc_ln8_reg_1511 <= {{add_ln77_1_fu_892_p2[63:2]}};
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state27)) begin
        gmem0_addr_2_read_reg_1546 <= m_axi_gmem0_RDATA;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state37)) begin
        gmem0_addr_3_read_reg_1561 <= m_axi_gmem0_RDATA;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state114)) begin
        gmem1_addr_1_read_reg_1714 <= m_axi_gmem1_RDATA;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state104)) begin
        gmem1_addr_1_reg_1697 <= sext_ln146_fu_1297_p1;
        gmem1_addr_reg_1708 <= sext_ln158_fu_1321_p1;
        i_1_reg_1684 <= i_fu_266;
        tmp_s_reg_1692[10 : 7] <= tmp_s_fu_1283_p3[10 : 7];
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state81)) begin
        gmem1_addr_4_read_reg_1651 <= m_axi_gmem1_RDATA;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state91)) begin
        gmem1_addr_5_read_reg_1666 <= m_axi_gmem1_RDATA;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state126)) begin
        max_val_reg_1727 <= logits_q0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state124) | (1'b1 == ap_CS_fsm_state101) | (1'b1 == ap_CS_fsm_state47) | ((m_axi_gmem1_RVALID == 1'b1) & (1'b1 == ap_CS_fsm_state91)) | ((m_axi_gmem1_RVALID == 1'b1) & (1'b1 == ap_CS_fsm_state81)) | ((1'b1 == ap_CS_fsm_state37) & (m_axi_gmem0_RVALID == 1'b1)) | ((1'b1 == ap_CS_fsm_state27) & (m_axi_gmem0_RVALID == 1'b1)))) begin
        reg_730 <= grp_fu_726_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state89)) begin
        tmp_19_reg_1661 <= {{mul_ln121_fu_1228_p2[18:12]}};
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state35)) begin
        tmp_reg_1556 <= {{mul_ln89_fu_999_p2[18:12]}};
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state101)) begin
        urem_ln121_reg_1676 <= grp_fu_1244_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state47)) begin
        urem_ln89_reg_1571 <= grp_fu_1015_p2;
    end
end

assign ap_ST_fsm_state100_blk = 1'b0;

assign ap_ST_fsm_state101_blk = 1'b0;

assign ap_ST_fsm_state102_blk = 1'b0;

always @ (*) begin
    if ((grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_done == 1'b0)) begin
        ap_ST_fsm_state103_blk = 1'b1;
    end else begin
        ap_ST_fsm_state103_blk = 1'b0;
    end
end

assign ap_ST_fsm_state104_blk = 1'b0;

always @ (*) begin
    if ((grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_done == 1'b0)) begin
        ap_ST_fsm_state105_blk = 1'b1;
    end else begin
        ap_ST_fsm_state105_blk = 1'b0;
    end
end

always @ (*) begin
    if ((m_axi_gmem1_ARREADY == 1'b0)) begin
        ap_ST_fsm_state106_blk = 1'b1;
    end else begin
        ap_ST_fsm_state106_blk = 1'b0;
    end
end

assign ap_ST_fsm_state107_blk = 1'b0;

assign ap_ST_fsm_state108_blk = 1'b0;

assign ap_ST_fsm_state109_blk = 1'b0;

assign ap_ST_fsm_state10_blk = 1'b0;

assign ap_ST_fsm_state110_blk = 1'b0;

assign ap_ST_fsm_state111_blk = 1'b0;

assign ap_ST_fsm_state112_blk = 1'b0;

assign ap_ST_fsm_state113_blk = 1'b0;

always @ (*) begin
    if ((m_axi_gmem1_RVALID == 1'b0)) begin
        ap_ST_fsm_state114_blk = 1'b1;
    end else begin
        ap_ST_fsm_state114_blk = 1'b0;
    end
end

assign ap_ST_fsm_state115_blk = 1'b0;

assign ap_ST_fsm_state116_blk = 1'b0;

assign ap_ST_fsm_state117_blk = 1'b0;

assign ap_ST_fsm_state118_blk = 1'b0;

assign ap_ST_fsm_state119_blk = 1'b0;

assign ap_ST_fsm_state11_blk = 1'b0;

assign ap_ST_fsm_state120_blk = 1'b0;

assign ap_ST_fsm_state121_blk = 1'b0;

assign ap_ST_fsm_state122_blk = 1'b0;

assign ap_ST_fsm_state123_blk = 1'b0;

assign ap_ST_fsm_state124_blk = 1'b0;

assign ap_ST_fsm_state125_blk = 1'b0;

always @ (*) begin
    if ((m_axi_gmem1_AWREADY == 1'b0)) begin
        ap_ST_fsm_state126_blk = 1'b1;
    end else begin
        ap_ST_fsm_state126_blk = 1'b0;
    end
end

assign ap_ST_fsm_state127_blk = 1'b0;

always @ (*) begin
    if ((grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_done == 1'b0)) begin
        ap_ST_fsm_state128_blk = 1'b1;
    end else begin
        ap_ST_fsm_state128_blk = 1'b0;
    end
end

always @ (*) begin
    if ((m_axi_gmem1_WREADY == 1'b0)) begin
        ap_ST_fsm_state129_blk = 1'b1;
    end else begin
        ap_ST_fsm_state129_blk = 1'b0;
    end
end

assign ap_ST_fsm_state12_blk = 1'b0;

assign ap_ST_fsm_state130_blk = 1'b0;

assign ap_ST_fsm_state131_blk = 1'b0;

assign ap_ST_fsm_state132_blk = 1'b0;

assign ap_ST_fsm_state133_blk = 1'b0;

always @ (*) begin
    if ((m_axi_gmem1_BVALID == 1'b0)) begin
        ap_ST_fsm_state134_blk = 1'b1;
    end else begin
        ap_ST_fsm_state134_blk = 1'b0;
    end
end

assign ap_ST_fsm_state13_blk = 1'b0;

assign ap_ST_fsm_state14_blk = 1'b0;

assign ap_ST_fsm_state15_blk = 1'b0;

assign ap_ST_fsm_state16_blk = 1'b0;

always @ (*) begin
    if ((grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_done == 1'b0)) begin
        ap_ST_fsm_state17_blk = 1'b1;
    end else begin
        ap_ST_fsm_state17_blk = 1'b0;
    end
end

always @ (*) begin
    if ((m_axi_gmem0_ARREADY == 1'b0)) begin
        ap_ST_fsm_state18_blk = 1'b1;
    end else begin
        ap_ST_fsm_state18_blk = 1'b0;
    end
end

always @ (*) begin
    if ((m_axi_gmem0_ARREADY == 1'b0)) begin
        ap_ST_fsm_state19_blk = 1'b1;
    end else begin
        ap_ST_fsm_state19_blk = 1'b0;
    end
end

always @ (*) begin
    if ((ap_start == 1'b0)) begin
        ap_ST_fsm_state1_blk = 1'b1;
    end else begin
        ap_ST_fsm_state1_blk = 1'b0;
    end
end

assign ap_ST_fsm_state20_blk = 1'b0;

assign ap_ST_fsm_state21_blk = 1'b0;

assign ap_ST_fsm_state22_blk = 1'b0;

assign ap_ST_fsm_state23_blk = 1'b0;

assign ap_ST_fsm_state24_blk = 1'b0;

assign ap_ST_fsm_state25_blk = 1'b0;

assign ap_ST_fsm_state26_blk = 1'b0;

always @ (*) begin
    if ((m_axi_gmem0_RVALID == 1'b0)) begin
        ap_ST_fsm_state27_blk = 1'b1;
    end else begin
        ap_ST_fsm_state27_blk = 1'b0;
    end
end

assign ap_ST_fsm_state28_blk = 1'b0;

assign ap_ST_fsm_state29_blk = 1'b0;

always @ (*) begin
    if ((1'b1 == ap_block_state2_on_subcall_done)) begin
        ap_ST_fsm_state2_blk = 1'b1;
    end else begin
        ap_ST_fsm_state2_blk = 1'b0;
    end
end

assign ap_ST_fsm_state30_blk = 1'b0;

assign ap_ST_fsm_state31_blk = 1'b0;

assign ap_ST_fsm_state32_blk = 1'b0;

assign ap_ST_fsm_state33_blk = 1'b0;

assign ap_ST_fsm_state34_blk = 1'b0;

assign ap_ST_fsm_state35_blk = 1'b0;

assign ap_ST_fsm_state36_blk = 1'b0;

always @ (*) begin
    if ((m_axi_gmem0_RVALID == 1'b0)) begin
        ap_ST_fsm_state37_blk = 1'b1;
    end else begin
        ap_ST_fsm_state37_blk = 1'b0;
    end
end

assign ap_ST_fsm_state38_blk = 1'b0;

assign ap_ST_fsm_state39_blk = 1'b0;

assign ap_ST_fsm_state3_blk = 1'b0;

assign ap_ST_fsm_state40_blk = 1'b0;

assign ap_ST_fsm_state41_blk = 1'b0;

assign ap_ST_fsm_state42_blk = 1'b0;

assign ap_ST_fsm_state43_blk = 1'b0;

assign ap_ST_fsm_state44_blk = 1'b0;

assign ap_ST_fsm_state45_blk = 1'b0;

assign ap_ST_fsm_state46_blk = 1'b0;

assign ap_ST_fsm_state47_blk = 1'b0;

assign ap_ST_fsm_state48_blk = 1'b0;

always @ (*) begin
    if ((grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_done == 1'b0)) begin
        ap_ST_fsm_state49_blk = 1'b1;
    end else begin
        ap_ST_fsm_state49_blk = 1'b0;
    end
end

assign ap_ST_fsm_state4_blk = 1'b0;

assign ap_ST_fsm_state50_blk = 1'b0;

assign ap_ST_fsm_state51_blk = 1'b0;

always @ (*) begin
    if ((m_axi_gmem1_ARREADY == 1'b0)) begin
        ap_ST_fsm_state52_blk = 1'b1;
    end else begin
        ap_ST_fsm_state52_blk = 1'b0;
    end
end

assign ap_ST_fsm_state53_blk = 1'b0;

assign ap_ST_fsm_state54_blk = 1'b0;

assign ap_ST_fsm_state55_blk = 1'b0;

assign ap_ST_fsm_state56_blk = 1'b0;

assign ap_ST_fsm_state57_blk = 1'b0;

assign ap_ST_fsm_state58_blk = 1'b0;

assign ap_ST_fsm_state59_blk = 1'b0;

assign ap_ST_fsm_state5_blk = 1'b0;

assign ap_ST_fsm_state60_blk = 1'b0;

always @ (*) begin
    if ((grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_done == 1'b0)) begin
        ap_ST_fsm_state61_blk = 1'b1;
    end else begin
        ap_ST_fsm_state61_blk = 1'b0;
    end
end

always @ (*) begin
    if ((m_axi_gmem1_ARREADY == 1'b0)) begin
        ap_ST_fsm_state62_blk = 1'b1;
    end else begin
        ap_ST_fsm_state62_blk = 1'b0;
    end
end

assign ap_ST_fsm_state63_blk = 1'b0;

assign ap_ST_fsm_state64_blk = 1'b0;

assign ap_ST_fsm_state65_blk = 1'b0;

assign ap_ST_fsm_state66_blk = 1'b0;

assign ap_ST_fsm_state67_blk = 1'b0;

assign ap_ST_fsm_state68_blk = 1'b0;

assign ap_ST_fsm_state69_blk = 1'b0;

assign ap_ST_fsm_state6_blk = 1'b0;

assign ap_ST_fsm_state70_blk = 1'b0;

always @ (*) begin
    if ((grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_done == 1'b0)) begin
        ap_ST_fsm_state71_blk = 1'b1;
    end else begin
        ap_ST_fsm_state71_blk = 1'b0;
    end
end

always @ (*) begin
    if ((m_axi_gmem1_ARREADY == 1'b0)) begin
        ap_ST_fsm_state72_blk = 1'b1;
    end else begin
        ap_ST_fsm_state72_blk = 1'b0;
    end
end

always @ (*) begin
    if ((m_axi_gmem1_ARREADY == 1'b0)) begin
        ap_ST_fsm_state73_blk = 1'b1;
    end else begin
        ap_ST_fsm_state73_blk = 1'b0;
    end
end

assign ap_ST_fsm_state74_blk = 1'b0;

assign ap_ST_fsm_state75_blk = 1'b0;

assign ap_ST_fsm_state76_blk = 1'b0;

assign ap_ST_fsm_state77_blk = 1'b0;

assign ap_ST_fsm_state78_blk = 1'b0;

assign ap_ST_fsm_state79_blk = 1'b0;

always @ (*) begin
    if ((grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_done == 1'b0)) begin
        ap_ST_fsm_state7_blk = 1'b1;
    end else begin
        ap_ST_fsm_state7_blk = 1'b0;
    end
end

assign ap_ST_fsm_state80_blk = 1'b0;

always @ (*) begin
    if ((m_axi_gmem1_RVALID == 1'b0)) begin
        ap_ST_fsm_state81_blk = 1'b1;
    end else begin
        ap_ST_fsm_state81_blk = 1'b0;
    end
end

assign ap_ST_fsm_state82_blk = 1'b0;

assign ap_ST_fsm_state83_blk = 1'b0;

assign ap_ST_fsm_state84_blk = 1'b0;

assign ap_ST_fsm_state85_blk = 1'b0;

assign ap_ST_fsm_state86_blk = 1'b0;

assign ap_ST_fsm_state87_blk = 1'b0;

assign ap_ST_fsm_state88_blk = 1'b0;

assign ap_ST_fsm_state89_blk = 1'b0;

always @ (*) begin
    if ((m_axi_gmem0_ARREADY == 1'b0)) begin
        ap_ST_fsm_state8_blk = 1'b1;
    end else begin
        ap_ST_fsm_state8_blk = 1'b0;
    end
end

assign ap_ST_fsm_state90_blk = 1'b0;

always @ (*) begin
    if ((m_axi_gmem1_RVALID == 1'b0)) begin
        ap_ST_fsm_state91_blk = 1'b1;
    end else begin
        ap_ST_fsm_state91_blk = 1'b0;
    end
end

assign ap_ST_fsm_state92_blk = 1'b0;

assign ap_ST_fsm_state93_blk = 1'b0;

assign ap_ST_fsm_state94_blk = 1'b0;

assign ap_ST_fsm_state95_blk = 1'b0;

assign ap_ST_fsm_state96_blk = 1'b0;

assign ap_ST_fsm_state97_blk = 1'b0;

assign ap_ST_fsm_state98_blk = 1'b0;

assign ap_ST_fsm_state99_blk = 1'b0;

assign ap_ST_fsm_state9_blk = 1'b0;

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b0)) | ((m_axi_gmem1_BVALID == 1'b1) & (1'b1 == ap_CS_fsm_state134)))) begin
        ap_done = 1'b1;
    end else begin
        ap_done = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((m_axi_gmem1_BVALID == 1'b1) & (1'b1 == ap_CS_fsm_state134))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        c0_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_address0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        c0_address0 = grp_lstm_inference_Pipeline_2_fu_629_c0_address0;
    end else begin
        c0_address0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        c0_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_ce0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        c0_ce0 = grp_lstm_inference_Pipeline_2_fu_629_c0_ce0;
    end else begin
        c0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        c0_ce1 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_ce1;
    end else begin
        c0_ce1 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        c0_d0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_d0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        c0_d0 = grp_lstm_inference_Pipeline_2_fu_629_c0_d0;
    end else begin
        c0_d0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        c0_we0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_c0_we0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        c0_we0 = grp_lstm_inference_Pipeline_2_fu_629_c0_we0;
    end else begin
        c0_we0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        c1_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_address0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        c1_address0 = grp_lstm_inference_Pipeline_4_fu_641_c1_address0;
    end else begin
        c1_address0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        c1_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_ce0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        c1_ce0 = grp_lstm_inference_Pipeline_4_fu_641_c1_ce0;
    end else begin
        c1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        c1_ce1 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_ce1;
    end else begin
        c1_ce1 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        c1_d0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_d0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        c1_d0 = grp_lstm_inference_Pipeline_4_fu_641_c1_d0;
    end else begin
        c1_d0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        c1_we0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_c1_we0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        c1_we0 = grp_lstm_inference_Pipeline_4_fu_641_c1_we0;
    end else begin
        c1_we0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        gates0_1_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_1_address0;
    end else begin
        gates0_1_address0 = zext_ln89_1_fu_1024_p1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        gates0_1_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_1_ce0;
    end else begin
        gates0_1_ce0 = gates0_1_ce0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state48)) begin
        gates0_1_ce0_local = 1'b1;
    end else begin
        gates0_1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state48) & (trunc_ln89_fu_1032_p1 == 3'd1))) begin
        gates0_1_we0_local = 1'b1;
    end else begin
        gates0_1_we0_local = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        gates0_2_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_2_address0;
    end else begin
        gates0_2_address0 = zext_ln89_1_fu_1024_p1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        gates0_2_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_2_ce0;
    end else begin
        gates0_2_ce0 = gates0_2_ce0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state48)) begin
        gates0_2_ce0_local = 1'b1;
    end else begin
        gates0_2_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state48) & (trunc_ln89_fu_1032_p1 == 3'd2))) begin
        gates0_2_we0_local = 1'b1;
    end else begin
        gates0_2_we0_local = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        gates0_3_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_3_address0;
    end else begin
        gates0_3_address0 = zext_ln89_1_fu_1024_p1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        gates0_3_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_3_ce0;
    end else begin
        gates0_3_ce0 = gates0_3_ce0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state48)) begin
        gates0_3_ce0_local = 1'b1;
    end else begin
        gates0_3_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state48) & (trunc_ln89_fu_1032_p1 == 3'd3))) begin
        gates0_3_we0_local = 1'b1;
    end else begin
        gates0_3_we0_local = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        gates0_4_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_4_address0;
    end else begin
        gates0_4_address0 = zext_ln89_1_fu_1024_p1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        gates0_4_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_4_ce0;
    end else begin
        gates0_4_ce0 = gates0_4_ce0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state48)) begin
        gates0_4_ce0_local = 1'b1;
    end else begin
        gates0_4_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if ((~(trunc_ln89_fu_1032_p1 == 3'd0) & ~(trunc_ln89_fu_1032_p1 == 3'd1) & ~(trunc_ln89_fu_1032_p1 == 3'd2) & ~(trunc_ln89_fu_1032_p1 == 3'd3) & (1'b1 == ap_CS_fsm_state48))) begin
        gates0_4_we0_local = 1'b1;
    end else begin
        gates0_4_we0_local = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        gates0_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_address0;
    end else begin
        gates0_address0 = zext_ln89_1_fu_1024_p1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        gates0_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_gates0_ce0;
    end else begin
        gates0_ce0 = gates0_ce0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state48)) begin
        gates0_ce0_local = 1'b1;
    end else begin
        gates0_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state48) & (trunc_ln89_fu_1032_p1 == 3'd0))) begin
        gates0_we0_local = 1'b1;
    end else begin
        gates0_we0_local = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        gates1_1_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_1_address0;
    end else begin
        gates1_1_address0 = zext_ln121_1_fu_1253_p1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        gates1_1_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_1_ce0;
    end else begin
        gates1_1_ce0 = gates1_1_ce0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state102)) begin
        gates1_1_ce0_local = 1'b1;
    end else begin
        gates1_1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state102) & (trunc_ln121_fu_1261_p1 == 3'd1))) begin
        gates1_1_we0_local = 1'b1;
    end else begin
        gates1_1_we0_local = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        gates1_2_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_2_address0;
    end else begin
        gates1_2_address0 = zext_ln121_1_fu_1253_p1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        gates1_2_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_2_ce0;
    end else begin
        gates1_2_ce0 = gates1_2_ce0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state102)) begin
        gates1_2_ce0_local = 1'b1;
    end else begin
        gates1_2_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state102) & (trunc_ln121_fu_1261_p1 == 3'd2))) begin
        gates1_2_we0_local = 1'b1;
    end else begin
        gates1_2_we0_local = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        gates1_3_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_3_address0;
    end else begin
        gates1_3_address0 = zext_ln121_1_fu_1253_p1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        gates1_3_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_3_ce0;
    end else begin
        gates1_3_ce0 = gates1_3_ce0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state102)) begin
        gates1_3_ce0_local = 1'b1;
    end else begin
        gates1_3_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state102) & (trunc_ln121_fu_1261_p1 == 3'd3))) begin
        gates1_3_we0_local = 1'b1;
    end else begin
        gates1_3_we0_local = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        gates1_4_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_4_address0;
    end else begin
        gates1_4_address0 = zext_ln121_1_fu_1253_p1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        gates1_4_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_4_ce0;
    end else begin
        gates1_4_ce0 = gates1_4_ce0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state102)) begin
        gates1_4_ce0_local = 1'b1;
    end else begin
        gates1_4_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if ((~(trunc_ln121_fu_1261_p1 == 3'd0) & ~(trunc_ln121_fu_1261_p1 == 3'd1) & ~(trunc_ln121_fu_1261_p1 == 3'd2) & ~(trunc_ln121_fu_1261_p1 == 3'd3) & (1'b1 == ap_CS_fsm_state102))) begin
        gates1_4_we0_local = 1'b1;
    end else begin
        gates1_4_we0_local = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        gates1_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_address0;
    end else begin
        gates1_address0 = zext_ln121_1_fu_1253_p1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        gates1_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_gates1_ce0;
    end else begin
        gates1_ce0 = gates1_ce0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state102)) begin
        gates1_ce0_local = 1'b1;
    end else begin
        gates1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state102) & (trunc_ln121_fu_1261_p1 == 3'd0))) begin
        gates1_we0_local = 1'b1;
    end else begin
        gates1_we0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state19) | (1'b1 == ap_CS_fsm_state18) | (1'b1 == ap_CS_fsm_state8))) begin
        gmem0_blk_n_AR = m_axi_gmem0_ARREADY;
    end else begin
        gmem0_blk_n_AR = 1'b1;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state37) | (1'b1 == ap_CS_fsm_state27))) begin
        gmem0_blk_n_R = m_axi_gmem0_RVALID;
    end else begin
        gmem0_blk_n_R = 1'b1;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state106) | (1'b1 == ap_CS_fsm_state73) | (1'b1 == ap_CS_fsm_state72) | (1'b1 == ap_CS_fsm_state62) | (1'b1 == ap_CS_fsm_state52))) begin
        gmem1_blk_n_AR = m_axi_gmem1_ARREADY;
    end else begin
        gmem1_blk_n_AR = 1'b1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state126)) begin
        gmem1_blk_n_AW = m_axi_gmem1_AWREADY;
    end else begin
        gmem1_blk_n_AW = 1'b1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state134)) begin
        gmem1_blk_n_B = m_axi_gmem1_BVALID;
    end else begin
        gmem1_blk_n_B = 1'b1;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state114) | (1'b1 == ap_CS_fsm_state91) | (1'b1 == ap_CS_fsm_state81))) begin
        gmem1_blk_n_R = m_axi_gmem1_RVALID;
    end else begin
        gmem1_blk_n_R = 1'b1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state129)) begin
        gmem1_blk_n_W = m_axi_gmem1_WREADY;
    end else begin
        gmem1_blk_n_W = 1'b1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state35)) begin
        grp_fu_1015_ap_start = 1'b1;
    end else begin
        grp_fu_1015_ap_start = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state38) | (1'b1 == ap_CS_fsm_state35) | (1'b1 == ap_CS_fsm_state47) | (1'b1 == ap_CS_fsm_state37) | (1'b1 == ap_CS_fsm_state46) | (1'b1 == ap_CS_fsm_state45) | (1'b1 == ap_CS_fsm_state44) | (1'b1 == ap_CS_fsm_state43) | (1'b1 == ap_CS_fsm_state42) | (1'b1 == ap_CS_fsm_state41) | (1'b1 == ap_CS_fsm_state40) | (1'b1 == ap_CS_fsm_state39) | (1'b1 == ap_CS_fsm_state36))) begin
        grp_fu_1015_ce = 1'b1;
    end else begin
        grp_fu_1015_ce = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state89)) begin
        grp_fu_1244_ap_start = 1'b1;
    end else begin
        grp_fu_1244_ap_start = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state92) | (1'b1 == ap_CS_fsm_state89) | (1'b1 == ap_CS_fsm_state101) | (1'b1 == ap_CS_fsm_state91) | (1'b1 == ap_CS_fsm_state100) | (1'b1 == ap_CS_fsm_state99) | (1'b1 == ap_CS_fsm_state98) | (1'b1 == ap_CS_fsm_state97) | (1'b1 == ap_CS_fsm_state96) | (1'b1 == ap_CS_fsm_state95) | (1'b1 == ap_CS_fsm_state94) | (1'b1 == ap_CS_fsm_state93) | (1'b1 == ap_CS_fsm_state90))) begin
        grp_fu_1244_ce = 1'b1;
    end else begin
        grp_fu_1244_ce = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state105)) begin
        grp_fu_1732_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_1732_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state71)) begin
        grp_fu_1732_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_1732_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state61)) begin
        grp_fu_1732_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_1732_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_1732_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1732_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state17)) begin
        grp_fu_1732_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_1732_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state7)) begin
        grp_fu_1732_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_1732_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_1732_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1732_p_ce;
    end else begin
        grp_fu_1732_ce = 1'b1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state105)) begin
        grp_fu_1732_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_1732_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state71)) begin
        grp_fu_1732_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_1732_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state61)) begin
        grp_fu_1732_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_1732_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_1732_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1732_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state17)) begin
        grp_fu_1732_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_1732_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state7)) begin
        grp_fu_1732_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_1732_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_1732_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1732_p_din0;
    end else begin
        grp_fu_1732_p0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state105)) begin
        grp_fu_1732_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_1732_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state71)) begin
        grp_fu_1732_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_1732_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state61)) begin
        grp_fu_1732_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_1732_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_1732_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1732_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state17)) begin
        grp_fu_1732_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_1732_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state7)) begin
        grp_fu_1732_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_1732_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_1732_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1732_p_din1;
    end else begin
        grp_fu_1732_p1 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_1736_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1736_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_1736_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1736_p_ce;
    end else begin
        grp_fu_1736_ce = 1'b1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_1736_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1736_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_1736_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1736_p_din0;
    end else begin
        grp_fu_1736_p0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_1736_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1736_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_1736_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1736_p_din1;
    end else begin
        grp_fu_1736_p1 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_1740_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1740_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_1740_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1740_p_ce;
    end else begin
        grp_fu_1740_ce = 1'b1;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_1740_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1740_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_1740_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1740_p_din0;
    end else begin
        grp_fu_1740_p0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_1740_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_1740_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_1740_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_1740_p_din1;
    end else begin
        grp_fu_1740_p1 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state105)) begin
        grp_fu_726_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state71)) begin
        grp_fu_726_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state61)) begin
        grp_fu_726_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_726_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state17)) begin
        grp_fu_726_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state7)) begin
        grp_fu_726_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_ce;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_726_ce = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_ce;
    end else if (((1'b1 == ap_CS_fsm_state115) | (1'b1 == ap_CS_fsm_state92) | (1'b1 == ap_CS_fsm_state89) | (1'b1 == ap_CS_fsm_state82) | (1'b1 == ap_CS_fsm_state38) | (1'b1 == ap_CS_fsm_state35) | (1'b1 == ap_CS_fsm_state28) | (1'b1 == ap_CS_fsm_state124) | (1'b1 == ap_CS_fsm_state101) | (1'b1 == ap_CS_fsm_state47) | (1'b1 == ap_CS_fsm_state123) | (1'b1 == ap_CS_fsm_state122) | (1'b1 == ap_CS_fsm_state121) | (1'b1 == ap_CS_fsm_state120) | (1'b1 == ap_CS_fsm_state119) | (1'b1 == ap_CS_fsm_state118) | (1'b1 == ap_CS_fsm_state117) | (1'b1 == ap_CS_fsm_state116) | (1'b1 == ap_CS_fsm_state100) | (1'b1 == ap_CS_fsm_state99) | (1'b1 == ap_CS_fsm_state98) | (1'b1 == ap_CS_fsm_state97) | (1'b1 == ap_CS_fsm_state96) | (1'b1 == ap_CS_fsm_state95) | (1'b1 == ap_CS_fsm_state94) | (1'b1 == ap_CS_fsm_state93) | (1'b1 == ap_CS_fsm_state90) | (1'b1 == ap_CS_fsm_state88) | (1'b1 == ap_CS_fsm_state87) | (1'b1 == ap_CS_fsm_state86) | (1'b1 == ap_CS_fsm_state85) | (1'b1 == ap_CS_fsm_state84) | (1'b1 == ap_CS_fsm_state83) | (1'b1 == ap_CS_fsm_state80) 
    | (1'b1 == ap_CS_fsm_state79) | (1'b1 == ap_CS_fsm_state78) | (1'b1 == ap_CS_fsm_state77) | (1'b1 == ap_CS_fsm_state76) | (1'b1 == ap_CS_fsm_state75) | (1'b1 == ap_CS_fsm_state74) | (1'b1 == ap_CS_fsm_state46) | (1'b1 == ap_CS_fsm_state45) | (1'b1 == ap_CS_fsm_state44) | (1'b1 == ap_CS_fsm_state43) | (1'b1 == ap_CS_fsm_state42) | (1'b1 == ap_CS_fsm_state41) | (1'b1 == ap_CS_fsm_state40) | (1'b1 == ap_CS_fsm_state39) | (1'b1 == ap_CS_fsm_state36) | (1'b1 == ap_CS_fsm_state34) | (1'b1 == ap_CS_fsm_state33) | (1'b1 == ap_CS_fsm_state32) | (1'b1 == ap_CS_fsm_state31) | (1'b1 == ap_CS_fsm_state30) | (1'b1 == ap_CS_fsm_state29) | (1'b1 == ap_CS_fsm_state26) | (1'b1 == ap_CS_fsm_state25) | (1'b1 == ap_CS_fsm_state24) | (1'b1 == ap_CS_fsm_state23) | (1'b1 == ap_CS_fsm_state22) | (1'b1 == ap_CS_fsm_state21) | (1'b1 == ap_CS_fsm_state20) | ((m_axi_gmem1_RVALID == 1'b1) & (1'b1 == ap_CS_fsm_state91)) | ((m_axi_gmem1_RVALID == 1'b1) & (1'b1 == ap_CS_fsm_state81)) | ((1'b1 == ap_CS_fsm_state37) & (m_axi_gmem0_RVALID == 1'b1)) 
    | ((1'b1 == ap_CS_fsm_state19) & (m_axi_gmem0_ARREADY == 1'b1)) | ((1'b1 == ap_CS_fsm_state27) & (m_axi_gmem0_RVALID == 1'b1)) | ((1'b1 == ap_CS_fsm_state18) & (m_axi_gmem0_ARREADY == 1'b1)) | ((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state73)) | ((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state72)))) begin
        grp_fu_726_ce = 1'b1;
    end else begin
        grp_fu_726_ce = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state105)) begin
        grp_fu_726_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state71)) begin
        grp_fu_726_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state61)) begin
        grp_fu_726_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_726_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state17)) begin
        grp_fu_726_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state7)) begin
        grp_fu_726_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_726_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_din0;
    end else if ((1'b1 == ap_CS_fsm_state115)) begin
        grp_fu_726_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_dot_out;
    end else if ((1'b1 == ap_CS_fsm_state72)) begin
        grp_fu_726_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_xC_2_out;
    end else if (((1'b1 == ap_CS_fsm_state92) | (1'b1 == ap_CS_fsm_state82) | (1'b1 == ap_CS_fsm_state38) | (1'b1 == ap_CS_fsm_state28))) begin
        grp_fu_726_p0 = reg_730;
    end else if ((1'b1 == ap_CS_fsm_state18)) begin
        grp_fu_726_p0 = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_xC_out;
    end else begin
        grp_fu_726_p0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state105)) begin
        grp_fu_726_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_grp_fu_726_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state71)) begin
        grp_fu_726_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_grp_fu_726_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state61)) begin
        grp_fu_726_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_grp_fu_726_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_fu_726_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_fu_726_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state17)) begin
        grp_fu_726_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_grp_fu_726_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state7)) begin
        grp_fu_726_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_grp_fu_726_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_fu_726_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_fu_726_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state115)) begin
        grp_fu_726_p1 = bitcast_ln146_fu_1335_p1;
    end else if ((1'b1 == ap_CS_fsm_state92)) begin
        grp_fu_726_p1 = bitcast_ln121_1_fu_1249_p1;
    end else if ((1'b1 == ap_CS_fsm_state82)) begin
        grp_fu_726_p1 = bitcast_ln121_fu_1221_p1;
    end else if ((1'b1 == ap_CS_fsm_state72)) begin
        grp_fu_726_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_hC_2_out;
    end else if ((1'b1 == ap_CS_fsm_state38)) begin
        grp_fu_726_p1 = bitcast_ln89_1_fu_1020_p1;
    end else if ((1'b1 == ap_CS_fsm_state28)) begin
        grp_fu_726_p1 = bitcast_ln89_fu_992_p1;
    end else if ((1'b1 == ap_CS_fsm_state18)) begin
        grp_fu_726_p1 = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_hC_out;
    end else begin
        grp_fu_726_p1 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_sigmoid_fu_1744_x = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_sigmoid_fu_1744_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_sigmoid_fu_1744_x = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_sigmoid_fu_1744_p_din1;
    end else begin
        grp_sigmoid_fu_1744_x = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_sigmoid_fu_1749_x = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_sigmoid_fu_1749_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_sigmoid_fu_1749_x = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_sigmoid_fu_1749_p_din1;
    end else begin
        grp_sigmoid_fu_1749_x = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_sigmoid_fu_1754_x = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_sigmoid_fu_1754_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_sigmoid_fu_1754_x = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_sigmoid_fu_1754_p_din1;
    end else begin
        grp_sigmoid_fu_1754_x = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_tanh_approx_fu_1759_x = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_tanh_approx_fu_1759_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_tanh_approx_fu_1759_x = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_tanh_approx_fu_1759_p_din1;
    end else begin
        grp_tanh_approx_fu_1759_x = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        grp_tanh_approx_fu_1764_x = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_grp_tanh_approx_fu_1764_p_din1;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        grp_tanh_approx_fu_1764_x = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_grp_tanh_approx_fu_1764_p_din1;
    end else begin
        grp_tanh_approx_fu_1764_x = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state61)) begin
        h0_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_h0_address0;
    end else if ((1'b1 == ap_CS_fsm_state17)) begin
        h0_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_h0_address0;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        h0_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_address0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        h0_address0 = grp_lstm_inference_Pipeline_1_fu_623_h0_address0;
    end else begin
        h0_address0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state61)) begin
        h0_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_h0_ce0;
    end else if ((1'b1 == ap_CS_fsm_state17)) begin
        h0_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_h0_ce0;
    end else if ((1'b1 == ap_CS_fsm_state49)) begin
        h0_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_ce0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        h0_ce0 = grp_lstm_inference_Pipeline_1_fu_623_h0_ce0;
    end else begin
        h0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        h0_d0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_d0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        h0_d0 = grp_lstm_inference_Pipeline_1_fu_623_h0_d0;
    end else begin
        h0_d0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state49)) begin
        h0_we0 = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_h0_we0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        h0_we0 = grp_lstm_inference_Pipeline_1_fu_623_h0_we0;
    end else begin
        h0_we0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state105)) begin
        h1_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_h1_address0;
    end else if ((1'b1 == ap_CS_fsm_state71)) begin
        h1_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_h1_address0;
    end else if ((1'b1 == ap_CS_fsm_state103)) begin
        h1_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_address0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        h1_address0 = grp_lstm_inference_Pipeline_3_fu_635_h1_address0;
    end else begin
        h1_address0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state105)) begin
        h1_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_h1_ce0;
    end else if ((1'b1 == ap_CS_fsm_state71)) begin
        h1_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_h1_ce0;
    end else if ((1'b1 == ap_CS_fsm_state103)) begin
        h1_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_ce0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        h1_ce0 = grp_lstm_inference_Pipeline_3_fu_635_h1_ce0;
    end else begin
        h1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        h1_d0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_d0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        h1_d0 = grp_lstm_inference_Pipeline_3_fu_635_h1_d0;
    end else begin
        h1_d0 = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state103)) begin
        h1_we0 = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_h1_we0;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        h1_we0 = grp_lstm_inference_Pipeline_3_fu_635_h1_we0;
    end else begin
        h1_we0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state128)) begin
        logits_address0 = grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_logits_address0;
    end else begin
        logits_address0 = logits_address0_local;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state125)) begin
        logits_address0_local = zext_ln140_fu_1339_p1;
    end else if ((1'b1 == ap_CS_fsm_state104)) begin
        logits_address0_local = 64'd0;
    end else begin
        logits_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state128)) begin
        logits_ce0 = grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_logits_ce0;
    end else begin
        logits_ce0 = logits_ce0_local;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state125))) begin
        logits_ce0_local = 1'b1;
    end else begin
        logits_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state125)) begin
        logits_we0_local = 1'b1;
    end else begin
        logits_we0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state19) & (m_axi_gmem0_ARREADY == 1'b1))) begin
        m_axi_gmem0_ARADDR = gmem0_addr_3_reg_1529;
    end else if (((1'b1 == ap_CS_fsm_state18) & (m_axi_gmem0_ARREADY == 1'b1))) begin
        m_axi_gmem0_ARADDR = gmem0_addr_2_reg_1523;
    end else if (((1'b1 == ap_CS_fsm_state8) & (m_axi_gmem0_ARREADY == 1'b1))) begin
        m_axi_gmem0_ARADDR = sext_ln85_fu_974_p1;
    end else if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARADDR = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARADDR;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARADDR = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARADDR;
    end else begin
        m_axi_gmem0_ARADDR = 'bx;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARBURST = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARBURST;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARBURST = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARBURST;
    end else begin
        m_axi_gmem0_ARBURST = 2'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARCACHE = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARCACHE;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARCACHE = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARCACHE;
    end else begin
        m_axi_gmem0_ARCACHE = 4'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARID = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARID;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARID = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARID;
    end else begin
        m_axi_gmem0_ARID = 1'd0;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_state19) & (m_axi_gmem0_ARREADY == 1'b1)) | ((1'b1 == ap_CS_fsm_state18) & (m_axi_gmem0_ARREADY == 1'b1)))) begin
        m_axi_gmem0_ARLEN = 64'd1;
    end else if (((1'b1 == ap_CS_fsm_state8) & (m_axi_gmem0_ARREADY == 1'b1))) begin
        m_axi_gmem0_ARLEN = 64'd128;
    end else if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARLEN = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARLEN;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARLEN = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARLEN;
    end else begin
        m_axi_gmem0_ARLEN = 'bx;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARLOCK = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARLOCK;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARLOCK = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARLOCK;
    end else begin
        m_axi_gmem0_ARLOCK = 2'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARPROT = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARPROT;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARPROT = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARPROT;
    end else begin
        m_axi_gmem0_ARPROT = 3'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARQOS = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARQOS;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARQOS = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARQOS;
    end else begin
        m_axi_gmem0_ARQOS = 4'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARREGION = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARREGION;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARREGION = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARREGION;
    end else begin
        m_axi_gmem0_ARREGION = 4'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARSIZE = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARSIZE;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARSIZE = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARSIZE;
    end else begin
        m_axi_gmem0_ARSIZE = 3'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARUSER = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARUSER;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARUSER = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARUSER;
    end else begin
        m_axi_gmem0_ARUSER = 1'd0;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_state19) & (m_axi_gmem0_ARREADY == 1'b1)) | ((1'b1 == ap_CS_fsm_state18) & (m_axi_gmem0_ARREADY == 1'b1)) | ((1'b1 == ap_CS_fsm_state8) & (m_axi_gmem0_ARREADY == 1'b1)))) begin
        m_axi_gmem0_ARVALID = 1'b1;
    end else if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_ARVALID = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_ARVALID;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_ARVALID = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_ARVALID;
    end else begin
        m_axi_gmem0_ARVALID = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_state37) & (m_axi_gmem0_RVALID == 1'b1)) | ((1'b1 == ap_CS_fsm_state27) & (m_axi_gmem0_RVALID == 1'b1)))) begin
        m_axi_gmem0_RREADY = 1'b1;
    end else if (((1'b1 == ap_CS_fsm_state17) | (1'b1 == ap_CS_fsm_state16))) begin
        m_axi_gmem0_RREADY = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_m_axi_gmem0_RREADY;
    end else if (((1'b1 == ap_CS_fsm_state7) | (1'b1 == ap_CS_fsm_state6))) begin
        m_axi_gmem0_RREADY = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_m_axi_gmem0_RREADY;
    end else begin
        m_axi_gmem0_RREADY = 1'b0;
    end
end

always @ (*) begin
    if (((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state106))) begin
        m_axi_gmem1_ARADDR = gmem1_addr_1_reg_1697;
    end else if (((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state73))) begin
        m_axi_gmem1_ARADDR = gmem1_addr_5_reg_1629;
    end else if (((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state72))) begin
        m_axi_gmem1_ARADDR = gmem1_addr_4_reg_1623;
    end else if (((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state62))) begin
        m_axi_gmem1_ARADDR = sext_ln117_fu_1203_p1;
    end else if (((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state52))) begin
        m_axi_gmem1_ARADDR = sext_ln113_fu_1193_p1;
    end else if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARADDR = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARADDR;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARADDR = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARADDR;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARADDR = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARADDR;
    end else begin
        m_axi_gmem1_ARADDR = 'bx;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARBURST = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARBURST;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARBURST = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARBURST;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARBURST = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARBURST;
    end else begin
        m_axi_gmem1_ARBURST = 2'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARCACHE = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARCACHE;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARCACHE = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARCACHE;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARCACHE = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARCACHE;
    end else begin
        m_axi_gmem1_ARCACHE = 4'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARID = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARID;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARID = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARID;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARID = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARID;
    end else begin
        m_axi_gmem1_ARID = 1'd0;
    end
end

always @ (*) begin
    if ((((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state106)) | ((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state73)) | ((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state72)))) begin
        m_axi_gmem1_ARLEN = 64'd1;
    end else if ((((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state62)) | ((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state52)))) begin
        m_axi_gmem1_ARLEN = 64'd128;
    end else if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARLEN = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARLEN;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARLEN = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARLEN;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARLEN = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARLEN;
    end else begin
        m_axi_gmem1_ARLEN = 'bx;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARLOCK = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARLOCK;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARLOCK = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARLOCK;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARLOCK = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARLOCK;
    end else begin
        m_axi_gmem1_ARLOCK = 2'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARPROT = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARPROT;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARPROT = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARPROT;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARPROT = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARPROT;
    end else begin
        m_axi_gmem1_ARPROT = 3'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARQOS = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARQOS;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARQOS = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARQOS;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARQOS = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARQOS;
    end else begin
        m_axi_gmem1_ARQOS = 4'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARREGION = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARREGION;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARREGION = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARREGION;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARREGION = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARREGION;
    end else begin
        m_axi_gmem1_ARREGION = 4'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARSIZE = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARSIZE;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARSIZE = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARSIZE;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARSIZE = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARSIZE;
    end else begin
        m_axi_gmem1_ARSIZE = 3'd0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARUSER = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARUSER;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARUSER = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARUSER;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARUSER = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARUSER;
    end else begin
        m_axi_gmem1_ARUSER = 1'd0;
    end
end

always @ (*) begin
    if ((((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state106)) | ((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state73)) | ((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state72)) | ((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state62)) | ((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state52)))) begin
        m_axi_gmem1_ARVALID = 1'b1;
    end else if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_ARVALID = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_ARVALID;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_ARVALID = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_ARVALID;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_ARVALID = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_ARVALID;
    end else begin
        m_axi_gmem1_ARVALID = 1'b0;
    end
end

always @ (*) begin
    if (((m_axi_gmem1_AWREADY == 1'b1) & (1'b1 == ap_CS_fsm_state126))) begin
        m_axi_gmem1_AWVALID = 1'b1;
    end else begin
        m_axi_gmem1_AWVALID = 1'b0;
    end
end

always @ (*) begin
    if (((m_axi_gmem1_BVALID == 1'b1) & (1'b1 == ap_CS_fsm_state134))) begin
        m_axi_gmem1_BREADY = 1'b1;
    end else begin
        m_axi_gmem1_BREADY = 1'b0;
    end
end

always @ (*) begin
    if ((((m_axi_gmem1_RVALID == 1'b1) & (1'b1 == ap_CS_fsm_state114)) | ((m_axi_gmem1_RVALID == 1'b1) & (1'b1 == ap_CS_fsm_state91)) | ((m_axi_gmem1_RVALID == 1'b1) & (1'b1 == ap_CS_fsm_state81)))) begin
        m_axi_gmem1_RREADY = 1'b1;
    end else if (((1'b1 == ap_CS_fsm_state104) | (1'b1 == ap_CS_fsm_state105))) begin
        m_axi_gmem1_RREADY = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_m_axi_gmem1_RREADY;
    end else if (((1'b1 == ap_CS_fsm_state71) | (1'b1 == ap_CS_fsm_state70))) begin
        m_axi_gmem1_RREADY = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_m_axi_gmem1_RREADY;
    end else if (((1'b1 == ap_CS_fsm_state61) | (1'b1 == ap_CS_fsm_state60))) begin
        m_axi_gmem1_RREADY = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_m_axi_gmem1_RREADY;
    end else begin
        m_axi_gmem1_RREADY = 1'b0;
    end
end

always @ (*) begin
    if (((m_axi_gmem1_WREADY == 1'b1) & (1'b1 == ap_CS_fsm_state129))) begin
        m_axi_gmem1_WVALID = 1'b1;
    end else begin
        m_axi_gmem1_WVALID = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            if (((1'b1 == ap_CS_fsm_state2) & (1'b0 == ap_block_state2_on_subcall_done))) begin
                ap_NS_fsm = ap_ST_fsm_state3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end
        end
        ap_ST_fsm_state3 : begin
            if (((1'b1 == ap_CS_fsm_state3) & (icmp_ln68_fu_754_p2 == 1'd1))) begin
                ap_NS_fsm = ap_ST_fsm_state104;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state4;
            end
        end
        ap_ST_fsm_state4 : begin
            if (((1'b1 == ap_CS_fsm_state4) & (icmp_ln75_fu_820_p2 == 1'd0))) begin
                ap_NS_fsm = ap_ST_fsm_state5;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state49;
            end
        end
        ap_ST_fsm_state5 : begin
            if (((1'b1 == ap_CS_fsm_state5) & (icmp_ln76_fu_844_p2 == 1'd1))) begin
                ap_NS_fsm = ap_ST_fsm_state4;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state6;
            end
        end
        ap_ST_fsm_state6 : begin
            ap_NS_fsm = ap_ST_fsm_state7;
        end
        ap_ST_fsm_state7 : begin
            if (((grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state7))) begin
                ap_NS_fsm = ap_ST_fsm_state8;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state7;
            end
        end
        ap_ST_fsm_state8 : begin
            if (((1'b1 == ap_CS_fsm_state8) & (m_axi_gmem0_ARREADY == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state9;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state8;
            end
        end
        ap_ST_fsm_state9 : begin
            ap_NS_fsm = ap_ST_fsm_state10;
        end
        ap_ST_fsm_state10 : begin
            ap_NS_fsm = ap_ST_fsm_state11;
        end
        ap_ST_fsm_state11 : begin
            ap_NS_fsm = ap_ST_fsm_state12;
        end
        ap_ST_fsm_state12 : begin
            ap_NS_fsm = ap_ST_fsm_state13;
        end
        ap_ST_fsm_state13 : begin
            ap_NS_fsm = ap_ST_fsm_state14;
        end
        ap_ST_fsm_state14 : begin
            ap_NS_fsm = ap_ST_fsm_state15;
        end
        ap_ST_fsm_state15 : begin
            ap_NS_fsm = ap_ST_fsm_state16;
        end
        ap_ST_fsm_state16 : begin
            ap_NS_fsm = ap_ST_fsm_state17;
        end
        ap_ST_fsm_state17 : begin
            if (((grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state17))) begin
                ap_NS_fsm = ap_ST_fsm_state18;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state17;
            end
        end
        ap_ST_fsm_state18 : begin
            if (((1'b1 == ap_CS_fsm_state18) & (m_axi_gmem0_ARREADY == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state19;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state18;
            end
        end
        ap_ST_fsm_state19 : begin
            if (((1'b1 == ap_CS_fsm_state19) & (m_axi_gmem0_ARREADY == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state20;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state19;
            end
        end
        ap_ST_fsm_state20 : begin
            ap_NS_fsm = ap_ST_fsm_state21;
        end
        ap_ST_fsm_state21 : begin
            ap_NS_fsm = ap_ST_fsm_state22;
        end
        ap_ST_fsm_state22 : begin
            ap_NS_fsm = ap_ST_fsm_state23;
        end
        ap_ST_fsm_state23 : begin
            ap_NS_fsm = ap_ST_fsm_state24;
        end
        ap_ST_fsm_state24 : begin
            ap_NS_fsm = ap_ST_fsm_state25;
        end
        ap_ST_fsm_state25 : begin
            ap_NS_fsm = ap_ST_fsm_state26;
        end
        ap_ST_fsm_state26 : begin
            ap_NS_fsm = ap_ST_fsm_state27;
        end
        ap_ST_fsm_state27 : begin
            if (((1'b1 == ap_CS_fsm_state27) & (m_axi_gmem0_RVALID == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state28;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state27;
            end
        end
        ap_ST_fsm_state28 : begin
            ap_NS_fsm = ap_ST_fsm_state29;
        end
        ap_ST_fsm_state29 : begin
            ap_NS_fsm = ap_ST_fsm_state30;
        end
        ap_ST_fsm_state30 : begin
            ap_NS_fsm = ap_ST_fsm_state31;
        end
        ap_ST_fsm_state31 : begin
            ap_NS_fsm = ap_ST_fsm_state32;
        end
        ap_ST_fsm_state32 : begin
            ap_NS_fsm = ap_ST_fsm_state33;
        end
        ap_ST_fsm_state33 : begin
            ap_NS_fsm = ap_ST_fsm_state34;
        end
        ap_ST_fsm_state34 : begin
            ap_NS_fsm = ap_ST_fsm_state35;
        end
        ap_ST_fsm_state35 : begin
            ap_NS_fsm = ap_ST_fsm_state36;
        end
        ap_ST_fsm_state36 : begin
            ap_NS_fsm = ap_ST_fsm_state37;
        end
        ap_ST_fsm_state37 : begin
            if (((1'b1 == ap_CS_fsm_state37) & (m_axi_gmem0_RVALID == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state38;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state37;
            end
        end
        ap_ST_fsm_state38 : begin
            ap_NS_fsm = ap_ST_fsm_state39;
        end
        ap_ST_fsm_state39 : begin
            ap_NS_fsm = ap_ST_fsm_state40;
        end
        ap_ST_fsm_state40 : begin
            ap_NS_fsm = ap_ST_fsm_state41;
        end
        ap_ST_fsm_state41 : begin
            ap_NS_fsm = ap_ST_fsm_state42;
        end
        ap_ST_fsm_state42 : begin
            ap_NS_fsm = ap_ST_fsm_state43;
        end
        ap_ST_fsm_state43 : begin
            ap_NS_fsm = ap_ST_fsm_state44;
        end
        ap_ST_fsm_state44 : begin
            ap_NS_fsm = ap_ST_fsm_state45;
        end
        ap_ST_fsm_state45 : begin
            ap_NS_fsm = ap_ST_fsm_state46;
        end
        ap_ST_fsm_state46 : begin
            ap_NS_fsm = ap_ST_fsm_state47;
        end
        ap_ST_fsm_state47 : begin
            ap_NS_fsm = ap_ST_fsm_state48;
        end
        ap_ST_fsm_state48 : begin
            ap_NS_fsm = ap_ST_fsm_state5;
        end
        ap_ST_fsm_state49 : begin
            if (((grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state49))) begin
                ap_NS_fsm = ap_ST_fsm_state50;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state49;
            end
        end
        ap_ST_fsm_state50 : begin
            if (((1'b1 == ap_CS_fsm_state50) & (icmp_ln107_fu_1035_p2 == 1'd0))) begin
                ap_NS_fsm = ap_ST_fsm_state51;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state103;
            end
        end
        ap_ST_fsm_state51 : begin
            if (((1'b1 == ap_CS_fsm_state51) & (icmp_ln108_fu_1063_p2 == 1'd1))) begin
                ap_NS_fsm = ap_ST_fsm_state50;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state52;
            end
        end
        ap_ST_fsm_state52 : begin
            if (((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state52))) begin
                ap_NS_fsm = ap_ST_fsm_state53;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state52;
            end
        end
        ap_ST_fsm_state53 : begin
            ap_NS_fsm = ap_ST_fsm_state54;
        end
        ap_ST_fsm_state54 : begin
            ap_NS_fsm = ap_ST_fsm_state55;
        end
        ap_ST_fsm_state55 : begin
            ap_NS_fsm = ap_ST_fsm_state56;
        end
        ap_ST_fsm_state56 : begin
            ap_NS_fsm = ap_ST_fsm_state57;
        end
        ap_ST_fsm_state57 : begin
            ap_NS_fsm = ap_ST_fsm_state58;
        end
        ap_ST_fsm_state58 : begin
            ap_NS_fsm = ap_ST_fsm_state59;
        end
        ap_ST_fsm_state59 : begin
            ap_NS_fsm = ap_ST_fsm_state60;
        end
        ap_ST_fsm_state60 : begin
            ap_NS_fsm = ap_ST_fsm_state61;
        end
        ap_ST_fsm_state61 : begin
            if (((1'b1 == ap_CS_fsm_state61) & (grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_done == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state62;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state61;
            end
        end
        ap_ST_fsm_state62 : begin
            if (((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state62))) begin
                ap_NS_fsm = ap_ST_fsm_state63;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state62;
            end
        end
        ap_ST_fsm_state63 : begin
            ap_NS_fsm = ap_ST_fsm_state64;
        end
        ap_ST_fsm_state64 : begin
            ap_NS_fsm = ap_ST_fsm_state65;
        end
        ap_ST_fsm_state65 : begin
            ap_NS_fsm = ap_ST_fsm_state66;
        end
        ap_ST_fsm_state66 : begin
            ap_NS_fsm = ap_ST_fsm_state67;
        end
        ap_ST_fsm_state67 : begin
            ap_NS_fsm = ap_ST_fsm_state68;
        end
        ap_ST_fsm_state68 : begin
            ap_NS_fsm = ap_ST_fsm_state69;
        end
        ap_ST_fsm_state69 : begin
            ap_NS_fsm = ap_ST_fsm_state70;
        end
        ap_ST_fsm_state70 : begin
            ap_NS_fsm = ap_ST_fsm_state71;
        end
        ap_ST_fsm_state71 : begin
            if (((1'b1 == ap_CS_fsm_state71) & (grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_done == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state72;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state71;
            end
        end
        ap_ST_fsm_state72 : begin
            if (((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state72))) begin
                ap_NS_fsm = ap_ST_fsm_state73;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state72;
            end
        end
        ap_ST_fsm_state73 : begin
            if (((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state73))) begin
                ap_NS_fsm = ap_ST_fsm_state74;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state73;
            end
        end
        ap_ST_fsm_state74 : begin
            ap_NS_fsm = ap_ST_fsm_state75;
        end
        ap_ST_fsm_state75 : begin
            ap_NS_fsm = ap_ST_fsm_state76;
        end
        ap_ST_fsm_state76 : begin
            ap_NS_fsm = ap_ST_fsm_state77;
        end
        ap_ST_fsm_state77 : begin
            ap_NS_fsm = ap_ST_fsm_state78;
        end
        ap_ST_fsm_state78 : begin
            ap_NS_fsm = ap_ST_fsm_state79;
        end
        ap_ST_fsm_state79 : begin
            ap_NS_fsm = ap_ST_fsm_state80;
        end
        ap_ST_fsm_state80 : begin
            ap_NS_fsm = ap_ST_fsm_state81;
        end
        ap_ST_fsm_state81 : begin
            if (((m_axi_gmem1_RVALID == 1'b1) & (1'b1 == ap_CS_fsm_state81))) begin
                ap_NS_fsm = ap_ST_fsm_state82;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state81;
            end
        end
        ap_ST_fsm_state82 : begin
            ap_NS_fsm = ap_ST_fsm_state83;
        end
        ap_ST_fsm_state83 : begin
            ap_NS_fsm = ap_ST_fsm_state84;
        end
        ap_ST_fsm_state84 : begin
            ap_NS_fsm = ap_ST_fsm_state85;
        end
        ap_ST_fsm_state85 : begin
            ap_NS_fsm = ap_ST_fsm_state86;
        end
        ap_ST_fsm_state86 : begin
            ap_NS_fsm = ap_ST_fsm_state87;
        end
        ap_ST_fsm_state87 : begin
            ap_NS_fsm = ap_ST_fsm_state88;
        end
        ap_ST_fsm_state88 : begin
            ap_NS_fsm = ap_ST_fsm_state89;
        end
        ap_ST_fsm_state89 : begin
            ap_NS_fsm = ap_ST_fsm_state90;
        end
        ap_ST_fsm_state90 : begin
            ap_NS_fsm = ap_ST_fsm_state91;
        end
        ap_ST_fsm_state91 : begin
            if (((m_axi_gmem1_RVALID == 1'b1) & (1'b1 == ap_CS_fsm_state91))) begin
                ap_NS_fsm = ap_ST_fsm_state92;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state91;
            end
        end
        ap_ST_fsm_state92 : begin
            ap_NS_fsm = ap_ST_fsm_state93;
        end
        ap_ST_fsm_state93 : begin
            ap_NS_fsm = ap_ST_fsm_state94;
        end
        ap_ST_fsm_state94 : begin
            ap_NS_fsm = ap_ST_fsm_state95;
        end
        ap_ST_fsm_state95 : begin
            ap_NS_fsm = ap_ST_fsm_state96;
        end
        ap_ST_fsm_state96 : begin
            ap_NS_fsm = ap_ST_fsm_state97;
        end
        ap_ST_fsm_state97 : begin
            ap_NS_fsm = ap_ST_fsm_state98;
        end
        ap_ST_fsm_state98 : begin
            ap_NS_fsm = ap_ST_fsm_state99;
        end
        ap_ST_fsm_state99 : begin
            ap_NS_fsm = ap_ST_fsm_state100;
        end
        ap_ST_fsm_state100 : begin
            ap_NS_fsm = ap_ST_fsm_state101;
        end
        ap_ST_fsm_state101 : begin
            ap_NS_fsm = ap_ST_fsm_state102;
        end
        ap_ST_fsm_state102 : begin
            ap_NS_fsm = ap_ST_fsm_state51;
        end
        ap_ST_fsm_state103 : begin
            if (((grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_done == 1'b1) & (1'b1 == ap_CS_fsm_state103))) begin
                ap_NS_fsm = ap_ST_fsm_state3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state103;
            end
        end
        ap_ST_fsm_state104 : begin
            if (((1'b1 == ap_CS_fsm_state104) & (icmp_ln140_fu_1267_p2 == 1'd1))) begin
                ap_NS_fsm = ap_ST_fsm_state126;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state105;
            end
        end
        ap_ST_fsm_state105 : begin
            if (((1'b1 == ap_CS_fsm_state105) & (grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_done == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state106;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state105;
            end
        end
        ap_ST_fsm_state106 : begin
            if (((m_axi_gmem1_ARREADY == 1'b1) & (1'b1 == ap_CS_fsm_state106))) begin
                ap_NS_fsm = ap_ST_fsm_state107;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state106;
            end
        end
        ap_ST_fsm_state107 : begin
            ap_NS_fsm = ap_ST_fsm_state108;
        end
        ap_ST_fsm_state108 : begin
            ap_NS_fsm = ap_ST_fsm_state109;
        end
        ap_ST_fsm_state109 : begin
            ap_NS_fsm = ap_ST_fsm_state110;
        end
        ap_ST_fsm_state110 : begin
            ap_NS_fsm = ap_ST_fsm_state111;
        end
        ap_ST_fsm_state111 : begin
            ap_NS_fsm = ap_ST_fsm_state112;
        end
        ap_ST_fsm_state112 : begin
            ap_NS_fsm = ap_ST_fsm_state113;
        end
        ap_ST_fsm_state113 : begin
            ap_NS_fsm = ap_ST_fsm_state114;
        end
        ap_ST_fsm_state114 : begin
            if (((m_axi_gmem1_RVALID == 1'b1) & (1'b1 == ap_CS_fsm_state114))) begin
                ap_NS_fsm = ap_ST_fsm_state115;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state114;
            end
        end
        ap_ST_fsm_state115 : begin
            ap_NS_fsm = ap_ST_fsm_state116;
        end
        ap_ST_fsm_state116 : begin
            ap_NS_fsm = ap_ST_fsm_state117;
        end
        ap_ST_fsm_state117 : begin
            ap_NS_fsm = ap_ST_fsm_state118;
        end
        ap_ST_fsm_state118 : begin
            ap_NS_fsm = ap_ST_fsm_state119;
        end
        ap_ST_fsm_state119 : begin
            ap_NS_fsm = ap_ST_fsm_state120;
        end
        ap_ST_fsm_state120 : begin
            ap_NS_fsm = ap_ST_fsm_state121;
        end
        ap_ST_fsm_state121 : begin
            ap_NS_fsm = ap_ST_fsm_state122;
        end
        ap_ST_fsm_state122 : begin
            ap_NS_fsm = ap_ST_fsm_state123;
        end
        ap_ST_fsm_state123 : begin
            ap_NS_fsm = ap_ST_fsm_state124;
        end
        ap_ST_fsm_state124 : begin
            ap_NS_fsm = ap_ST_fsm_state125;
        end
        ap_ST_fsm_state125 : begin
            ap_NS_fsm = ap_ST_fsm_state104;
        end
        ap_ST_fsm_state126 : begin
            if (((m_axi_gmem1_AWREADY == 1'b1) & (1'b1 == ap_CS_fsm_state126))) begin
                ap_NS_fsm = ap_ST_fsm_state127;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state126;
            end
        end
        ap_ST_fsm_state127 : begin
            ap_NS_fsm = ap_ST_fsm_state128;
        end
        ap_ST_fsm_state128 : begin
            if (((1'b1 == ap_CS_fsm_state128) & (grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_done == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state129;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state128;
            end
        end
        ap_ST_fsm_state129 : begin
            if (((m_axi_gmem1_WREADY == 1'b1) & (1'b1 == ap_CS_fsm_state129))) begin
                ap_NS_fsm = ap_ST_fsm_state130;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state129;
            end
        end
        ap_ST_fsm_state130 : begin
            ap_NS_fsm = ap_ST_fsm_state131;
        end
        ap_ST_fsm_state131 : begin
            ap_NS_fsm = ap_ST_fsm_state132;
        end
        ap_ST_fsm_state132 : begin
            ap_NS_fsm = ap_ST_fsm_state133;
        end
        ap_ST_fsm_state133 : begin
            ap_NS_fsm = ap_ST_fsm_state134;
        end
        ap_ST_fsm_state134 : begin
            if (((m_axi_gmem1_BVALID == 1'b1) & (1'b1 == ap_CS_fsm_state134))) begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state134;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln107_fu_1041_p2 = (g_1_reg_601 + 3'd1);

assign add_ln108_fu_1069_p2 = (j_reg_612 + 8'd1);

assign add_ln109_1_fu_1111_p2 = (zext_ln109_fu_1092_p1 + whh1);

assign add_ln109_2_fu_1126_p2 = (zext_ln108_fu_1075_p1 + tmp_3_reg_1592);

assign add_ln109_fu_1096_p2 = (zext_ln109_fu_1092_p1 + wih1);

assign add_ln121_1_fu_1168_p2 = (zext_ln121_2_fu_1139_p1 + bhh1);

assign add_ln121_fu_1143_p2 = (zext_ln121_2_fu_1139_p1 + bih1);

assign add_ln140_fu_1273_p2 = (i_fu_266 + 4'd1);

assign add_ln146_fu_1292_p2 = ($signed(zext_ln140_1_fu_1279_p1) + $signed(sext_ln140_reg_1475));

assign add_ln68_fu_760_p2 = (t_fu_178 + 6'd1);

assign add_ln71_fu_778_p2 = (zext_ln71_fu_774_p1 + input_seq);

assign add_ln75_fu_826_p2 = (g_reg_579 + 3'd1);

assign add_ln76_fu_850_p2 = (j_2_reg_590 + 8'd1);

assign add_ln77_1_fu_892_p2 = (zext_ln77_fu_873_p1 + whh0);

assign add_ln77_2_fu_907_p2 = (zext_ln76_fu_856_p1 + tmp_2_reg_1493);

assign add_ln77_fu_877_p2 = (zext_ln77_fu_873_p1 + wih0);

assign add_ln89_1_fu_949_p2 = (zext_ln89_2_fu_920_p1 + bhh0);

assign add_ln89_fu_924_p2 = (zext_ln89_2_fu_920_p1 + bih0);

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state100 = ap_CS_fsm[32'd99];

assign ap_CS_fsm_state101 = ap_CS_fsm[32'd100];

assign ap_CS_fsm_state102 = ap_CS_fsm[32'd101];

assign ap_CS_fsm_state103 = ap_CS_fsm[32'd102];

assign ap_CS_fsm_state104 = ap_CS_fsm[32'd103];

assign ap_CS_fsm_state105 = ap_CS_fsm[32'd104];

assign ap_CS_fsm_state106 = ap_CS_fsm[32'd105];

assign ap_CS_fsm_state114 = ap_CS_fsm[32'd113];

assign ap_CS_fsm_state115 = ap_CS_fsm[32'd114];

assign ap_CS_fsm_state116 = ap_CS_fsm[32'd115];

assign ap_CS_fsm_state117 = ap_CS_fsm[32'd116];

assign ap_CS_fsm_state118 = ap_CS_fsm[32'd117];

assign ap_CS_fsm_state119 = ap_CS_fsm[32'd118];

assign ap_CS_fsm_state120 = ap_CS_fsm[32'd119];

assign ap_CS_fsm_state121 = ap_CS_fsm[32'd120];

assign ap_CS_fsm_state122 = ap_CS_fsm[32'd121];

assign ap_CS_fsm_state123 = ap_CS_fsm[32'd122];

assign ap_CS_fsm_state124 = ap_CS_fsm[32'd123];

assign ap_CS_fsm_state125 = ap_CS_fsm[32'd124];

assign ap_CS_fsm_state126 = ap_CS_fsm[32'd125];

assign ap_CS_fsm_state127 = ap_CS_fsm[32'd126];

assign ap_CS_fsm_state128 = ap_CS_fsm[32'd127];

assign ap_CS_fsm_state129 = ap_CS_fsm[32'd128];

assign ap_CS_fsm_state134 = ap_CS_fsm[32'd133];

assign ap_CS_fsm_state16 = ap_CS_fsm[32'd15];

assign ap_CS_fsm_state17 = ap_CS_fsm[32'd16];

assign ap_CS_fsm_state18 = ap_CS_fsm[32'd17];

assign ap_CS_fsm_state19 = ap_CS_fsm[32'd18];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state20 = ap_CS_fsm[32'd19];

assign ap_CS_fsm_state21 = ap_CS_fsm[32'd20];

assign ap_CS_fsm_state22 = ap_CS_fsm[32'd21];

assign ap_CS_fsm_state23 = ap_CS_fsm[32'd22];

assign ap_CS_fsm_state24 = ap_CS_fsm[32'd23];

assign ap_CS_fsm_state25 = ap_CS_fsm[32'd24];

assign ap_CS_fsm_state26 = ap_CS_fsm[32'd25];

assign ap_CS_fsm_state27 = ap_CS_fsm[32'd26];

assign ap_CS_fsm_state28 = ap_CS_fsm[32'd27];

assign ap_CS_fsm_state29 = ap_CS_fsm[32'd28];

assign ap_CS_fsm_state3 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_state30 = ap_CS_fsm[32'd29];

assign ap_CS_fsm_state31 = ap_CS_fsm[32'd30];

assign ap_CS_fsm_state32 = ap_CS_fsm[32'd31];

assign ap_CS_fsm_state33 = ap_CS_fsm[32'd32];

assign ap_CS_fsm_state34 = ap_CS_fsm[32'd33];

assign ap_CS_fsm_state35 = ap_CS_fsm[32'd34];

assign ap_CS_fsm_state36 = ap_CS_fsm[32'd35];

assign ap_CS_fsm_state37 = ap_CS_fsm[32'd36];

assign ap_CS_fsm_state38 = ap_CS_fsm[32'd37];

assign ap_CS_fsm_state39 = ap_CS_fsm[32'd38];

assign ap_CS_fsm_state4 = ap_CS_fsm[32'd3];

assign ap_CS_fsm_state40 = ap_CS_fsm[32'd39];

assign ap_CS_fsm_state41 = ap_CS_fsm[32'd40];

assign ap_CS_fsm_state42 = ap_CS_fsm[32'd41];

assign ap_CS_fsm_state43 = ap_CS_fsm[32'd42];

assign ap_CS_fsm_state44 = ap_CS_fsm[32'd43];

assign ap_CS_fsm_state45 = ap_CS_fsm[32'd44];

assign ap_CS_fsm_state46 = ap_CS_fsm[32'd45];

assign ap_CS_fsm_state47 = ap_CS_fsm[32'd46];

assign ap_CS_fsm_state48 = ap_CS_fsm[32'd47];

assign ap_CS_fsm_state49 = ap_CS_fsm[32'd48];

assign ap_CS_fsm_state5 = ap_CS_fsm[32'd4];

assign ap_CS_fsm_state50 = ap_CS_fsm[32'd49];

assign ap_CS_fsm_state51 = ap_CS_fsm[32'd50];

assign ap_CS_fsm_state52 = ap_CS_fsm[32'd51];

assign ap_CS_fsm_state6 = ap_CS_fsm[32'd5];

assign ap_CS_fsm_state60 = ap_CS_fsm[32'd59];

assign ap_CS_fsm_state61 = ap_CS_fsm[32'd60];

assign ap_CS_fsm_state62 = ap_CS_fsm[32'd61];

assign ap_CS_fsm_state7 = ap_CS_fsm[32'd6];

assign ap_CS_fsm_state70 = ap_CS_fsm[32'd69];

assign ap_CS_fsm_state71 = ap_CS_fsm[32'd70];

assign ap_CS_fsm_state72 = ap_CS_fsm[32'd71];

assign ap_CS_fsm_state73 = ap_CS_fsm[32'd72];

assign ap_CS_fsm_state74 = ap_CS_fsm[32'd73];

assign ap_CS_fsm_state75 = ap_CS_fsm[32'd74];

assign ap_CS_fsm_state76 = ap_CS_fsm[32'd75];

assign ap_CS_fsm_state77 = ap_CS_fsm[32'd76];

assign ap_CS_fsm_state78 = ap_CS_fsm[32'd77];

assign ap_CS_fsm_state79 = ap_CS_fsm[32'd78];

assign ap_CS_fsm_state8 = ap_CS_fsm[32'd7];

assign ap_CS_fsm_state80 = ap_CS_fsm[32'd79];

assign ap_CS_fsm_state81 = ap_CS_fsm[32'd80];

assign ap_CS_fsm_state82 = ap_CS_fsm[32'd81];

assign ap_CS_fsm_state83 = ap_CS_fsm[32'd82];

assign ap_CS_fsm_state84 = ap_CS_fsm[32'd83];

assign ap_CS_fsm_state85 = ap_CS_fsm[32'd84];

assign ap_CS_fsm_state86 = ap_CS_fsm[32'd85];

assign ap_CS_fsm_state87 = ap_CS_fsm[32'd86];

assign ap_CS_fsm_state88 = ap_CS_fsm[32'd87];

assign ap_CS_fsm_state89 = ap_CS_fsm[32'd88];

assign ap_CS_fsm_state90 = ap_CS_fsm[32'd89];

assign ap_CS_fsm_state91 = ap_CS_fsm[32'd90];

assign ap_CS_fsm_state92 = ap_CS_fsm[32'd91];

assign ap_CS_fsm_state93 = ap_CS_fsm[32'd92];

assign ap_CS_fsm_state94 = ap_CS_fsm[32'd93];

assign ap_CS_fsm_state95 = ap_CS_fsm[32'd94];

assign ap_CS_fsm_state96 = ap_CS_fsm[32'd95];

assign ap_CS_fsm_state97 = ap_CS_fsm[32'd96];

assign ap_CS_fsm_state98 = ap_CS_fsm[32'd97];

assign ap_CS_fsm_state99 = ap_CS_fsm[32'd98];

always @ (*) begin
    ap_block_state2_on_subcall_done = ((grp_lstm_inference_Pipeline_4_fu_641_ap_done == 1'b0) | (grp_lstm_inference_Pipeline_3_fu_635_ap_done == 1'b0) | (grp_lstm_inference_Pipeline_2_fu_629_ap_done == 1'b0) | (grp_lstm_inference_Pipeline_1_fu_623_ap_done == 1'b0));
end

assign bitcast_ln121_1_fu_1249_p1 = gmem1_addr_5_read_reg_1666;

assign bitcast_ln121_fu_1221_p1 = gmem1_addr_4_read_reg_1651;

assign bitcast_ln146_fu_1335_p1 = gmem1_addr_1_read_reg_1714;

assign bitcast_ln89_1_fu_1020_p1 = gmem0_addr_3_read_reg_1561;

assign bitcast_ln89_fu_992_p1 = gmem0_addr_2_read_reg_1546;

assign empty_57_fu_1047_p1 = g_1_reg_601[1:0];

assign empty_fu_832_p1 = g_reg_579[1:0];

assign grp_fu_1015_p1 = 9'd5;

assign grp_fu_1244_p1 = 9'd5;

assign grp_lstm_inference_Pipeline_1_fu_623_ap_start = grp_lstm_inference_Pipeline_1_fu_623_ap_start_reg;

assign grp_lstm_inference_Pipeline_2_fu_629_ap_start = grp_lstm_inference_Pipeline_2_fu_629_ap_start_reg;

assign grp_lstm_inference_Pipeline_3_fu_635_ap_start = grp_lstm_inference_Pipeline_3_fu_635_ap_start_reg;

assign grp_lstm_inference_Pipeline_4_fu_641_ap_start = grp_lstm_inference_Pipeline_4_fu_641_ap_start_reg;

assign grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_start = grp_lstm_inference_Pipeline_VITIS_LOOP_113_9_fu_691_ap_start_reg;

assign grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_start = grp_lstm_inference_Pipeline_VITIS_LOOP_117_10_fu_700_ap_start_reg;

assign grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_start = grp_lstm_inference_Pipeline_VITIS_LOOP_126_11_fu_678_ap_start_reg;

assign grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_start = grp_lstm_inference_Pipeline_VITIS_LOOP_142_13_fu_709_ap_start_reg;

assign grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_start = grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_ap_start_reg;

assign grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_start = grp_lstm_inference_Pipeline_VITIS_LOOP_81_4_fu_660_ap_start_reg;

assign grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_start = grp_lstm_inference_Pipeline_VITIS_LOOP_85_5_fu_669_ap_start_reg;

assign grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_start = grp_lstm_inference_Pipeline_VITIS_LOOP_94_6_fu_647_ap_start_reg;

assign icmp_ln107_fu_1035_p2 = ((g_1_reg_601 == 3'd4) ? 1'b1 : 1'b0);

assign icmp_ln108_fu_1063_p2 = ((j_reg_612 == 8'd128) ? 1'b1 : 1'b0);

assign icmp_ln140_fu_1267_p2 = ((i_fu_266 == 4'd10) ? 1'b1 : 1'b0);

assign icmp_ln68_fu_754_p2 = ((t_fu_178 == 6'd50) ? 1'b1 : 1'b0);

assign icmp_ln75_fu_820_p2 = ((g_reg_579 == 3'd4) ? 1'b1 : 1'b0);

assign icmp_ln76_fu_844_p2 = ((j_2_reg_590 == 8'd128) ? 1'b1 : 1'b0);

assign m_axi_gmem0_AWADDR = 64'd0;

assign m_axi_gmem0_AWBURST = 2'd0;

assign m_axi_gmem0_AWCACHE = 4'd0;

assign m_axi_gmem0_AWID = 1'd0;

assign m_axi_gmem0_AWLEN = 32'd0;

assign m_axi_gmem0_AWLOCK = 2'd0;

assign m_axi_gmem0_AWPROT = 3'd0;

assign m_axi_gmem0_AWQOS = 4'd0;

assign m_axi_gmem0_AWREGION = 4'd0;

assign m_axi_gmem0_AWSIZE = 3'd0;

assign m_axi_gmem0_AWUSER = 1'd0;

assign m_axi_gmem0_AWVALID = 1'b0;

assign m_axi_gmem0_BREADY = 1'b0;

assign m_axi_gmem0_WDATA = 32'd0;

assign m_axi_gmem0_WID = 1'd0;

assign m_axi_gmem0_WLAST = 1'b0;

assign m_axi_gmem0_WSTRB = 4'd0;

assign m_axi_gmem0_WUSER = 1'd0;

assign m_axi_gmem0_WVALID = 1'b0;

assign m_axi_gmem1_AWADDR = gmem1_addr_reg_1708;

assign m_axi_gmem1_AWBURST = 2'd0;

assign m_axi_gmem1_AWCACHE = 4'd0;

assign m_axi_gmem1_AWID = 1'd0;

assign m_axi_gmem1_AWLEN = 64'd1;

assign m_axi_gmem1_AWLOCK = 2'd0;

assign m_axi_gmem1_AWPROT = 3'd0;

assign m_axi_gmem1_AWQOS = 4'd0;

assign m_axi_gmem1_AWREGION = 4'd0;

assign m_axi_gmem1_AWSIZE = 3'd0;

assign m_axi_gmem1_AWUSER = 1'd0;

assign m_axi_gmem1_WDATA = grp_lstm_inference_Pipeline_VITIS_LOOP_152_14_fu_719_max_idx_out;

assign m_axi_gmem1_WID = 1'd0;

assign m_axi_gmem1_WLAST = 1'b0;

assign m_axi_gmem1_WSTRB = 4'd15;

assign m_axi_gmem1_WUSER = 1'd0;

assign mul_ln121_fu_1228_p0 = mul_ln121_fu_1228_p00;

assign mul_ln121_fu_1228_p00 = add_ln109_2_reg_1617;

assign mul_ln121_fu_1228_p1 = 19'd820;

assign mul_ln89_fu_999_p0 = mul_ln89_fu_999_p00;

assign mul_ln89_fu_999_p00 = add_ln77_2_reg_1517;

assign mul_ln89_fu_999_p1 = 19'd820;

assign sext_ln113_fu_1193_p1 = $signed(trunc_ln2_reg_1605);

assign sext_ln117_fu_1203_p1 = $signed(trunc_ln3_reg_1611);

assign sext_ln121_1_fu_1183_p1 = $signed(trunc_ln121_1_fu_1173_p4);

assign sext_ln121_fu_1158_p1 = $signed(trunc_ln4_fu_1148_p4);

assign sext_ln140_fu_811_p1 = $signed(trunc_ln140_1_fu_802_p4);

assign sext_ln146_fu_1297_p1 = $signed(add_ln146_fu_1292_p2);

assign sext_ln158_fu_1321_p1 = $signed(trunc_ln5_fu_1312_p4);

assign sext_ln85_fu_974_p1 = $signed(trunc_ln8_reg_1511);

assign sext_ln89_1_fu_964_p1 = $signed(trunc_ln89_1_fu_954_p4);

assign sext_ln89_fu_939_p1 = $signed(trunc_ln1_fu_929_p4);

assign shl_ln1_fu_864_p4 = {{{empty_reg_1488}, {trunc_ln77_fu_860_p1}}, {9'd0}};

assign shl_ln2_fu_1083_p4 = {{{empty_57_reg_1587}, {trunc_ln109_fu_1079_p1}}, {9'd0}};

assign shl_ln3_fu_912_p3 = {{add_ln77_2_fu_907_p2}, {2'd0}};

assign shl_ln4_fu_1131_p3 = {{add_ln109_2_fu_1126_p2}, {2'd0}};

assign shl_ln_fu_766_p3 = {{t_fu_178}, {9'd0}};

assign tmp_2_fu_836_p3 = {{empty_fu_832_p1}, {7'd0}};

assign tmp_3_fu_1051_p3 = {{empty_57_fu_1047_p1}, {7'd0}};

assign tmp_s_fu_1283_p3 = {{i_fu_266}, {7'd0}};

assign trunc_ln109_fu_1079_p1 = j_reg_612[6:0];

assign trunc_ln121_1_fu_1173_p4 = {{add_ln121_1_fu_1168_p2[63:2]}};

assign trunc_ln121_fu_1261_p1 = urem_ln121_reg_1676[2:0];

assign trunc_ln140_1_fu_802_p4 = {{bfc[63:2]}};

assign trunc_ln1_fu_929_p4 = {{add_ln89_fu_924_p2[63:2]}};

assign trunc_ln4_fu_1148_p4 = {{add_ln121_fu_1143_p2[63:2]}};

assign trunc_ln5_fu_1312_p4 = {{pred_out[63:2]}};

assign trunc_ln77_fu_860_p1 = j_2_reg_590[6:0];

assign trunc_ln89_1_fu_954_p4 = {{add_ln89_1_fu_949_p2[63:2]}};

assign trunc_ln89_fu_1032_p1 = urem_ln89_reg_1571[2:0];

assign zext_ln108_fu_1075_p1 = j_reg_612;

assign zext_ln109_fu_1092_p1 = shl_ln2_fu_1083_p4;

assign zext_ln121_1_fu_1253_p1 = tmp_19_reg_1661;

assign zext_ln121_2_fu_1139_p1 = shl_ln4_fu_1131_p3;

assign zext_ln140_1_fu_1279_p1 = i_fu_266;

assign zext_ln140_fu_1339_p1 = i_1_reg_1684;

assign zext_ln71_fu_774_p1 = shl_ln_fu_766_p3;

assign zext_ln76_fu_856_p1 = j_2_reg_590;

assign zext_ln77_fu_873_p1 = shl_ln1_fu_864_p4;

assign zext_ln89_1_fu_1024_p1 = tmp_reg_1556;

assign zext_ln89_2_fu_920_p1 = shl_ln3_fu_912_p3;

always @ (posedge ap_clk) begin
    tmp_2_reg_1493[6:0] <= 7'b0000000;
    tmp_3_reg_1592[6:0] <= 7'b0000000;
    tmp_s_reg_1692[6:0] <= 7'b0000000;
end

endmodule //vadd_lstm_inference

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_1 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        h0_address0,
        h0_ce0,
        h0_we0,
        h0_d0
);

parameter    ap_ST_fsm_state1 = 1'd1;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output  [6:0] h0_address0;
output   h0_ce0;
output   h0_we0;
output  [31:0] h0_d0;

reg ap_idle;

(* fsm_encoding = "none" *) reg   [0:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    ap_block_state1_pp0_stage0_iter0;
wire   [0:0] exitcond9024_fu_52_p2;
reg    ap_condition_exit_pp0_iter0_stage0;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
wire   [63:0] p_cast6_fu_64_p1;
reg   [7:0] empty_fu_26;
wire   [7:0] empty_55_fu_58_p2;
wire    ap_loop_init;
reg   [7:0] ap_sig_allocacmp_p_load;
reg    h0_we0_local;
reg    h0_ce0_local;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg   [0:0] ap_NS_fsm;
reg    ap_ST_fsm_state1_blk;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 1'd1;
#0 empty_fu_26 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage0),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        if ((exitcond9024_fu_52_p2 == 1'd0)) begin
            empty_fu_26 <= empty_55_fu_58_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            empty_fu_26 <= 8'd0;
        end
    end
end

always @ (*) begin
    if ((1'b1 == ap_block_state1_pp0_stage0_iter0)) begin
        ap_ST_fsm_state1_blk = 1'b1;
    end else begin
        ap_ST_fsm_state1_blk = 1'b0;
    end
end

always @ (*) begin
    if (((exitcond9024_fu_52_p2 == 1'd1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if (((ap_start_int == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_sig_allocacmp_p_load = 8'd0;
    end else begin
        ap_sig_allocacmp_p_load = empty_fu_26;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        h0_ce0_local = 1'b1;
    end else begin
        h0_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((exitcond9024_fu_52_p2 == 1'd0) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        h0_we0_local = 1'b1;
    end else begin
        h0_we0_local = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            ap_NS_fsm = ap_ST_fsm_state1;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

always @ (*) begin
    ap_block_state1_pp0_stage0_iter0 = (ap_start_int == 1'b0);
end

assign ap_done = ap_done_sig;

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage0;

assign ap_ready = ap_ready_sig;

assign empty_55_fu_58_p2 = (ap_sig_allocacmp_p_load + 8'd1);

assign exitcond9024_fu_52_p2 = ((ap_sig_allocacmp_p_load == 8'd128) ? 1'b1 : 1'b0);

assign h0_address0 = p_cast6_fu_64_p1;

assign h0_ce0 = h0_ce0_local;

assign h0_d0 = 32'd0;

assign h0_we0 = h0_we0_local;

assign p_cast6_fu_64_p1 = ap_sig_allocacmp_p_load;

endmodule //vadd_lstm_inference_Pipeline_1

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_2 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        c0_address0,
        c0_ce0,
        c0_we0,
        c0_d0
);

parameter    ap_ST_fsm_state1 = 1'd1;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output  [6:0] c0_address0;
output   c0_ce0;
output   c0_we0;
output  [31:0] c0_d0;

reg ap_idle;

(* fsm_encoding = "none" *) reg   [0:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    ap_block_state1_pp0_stage0_iter0;
wire   [0:0] exitcond8923_fu_52_p2;
reg    ap_condition_exit_pp0_iter0_stage0;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
wire   [63:0] p_cast7_fu_64_p1;
reg   [7:0] empty_fu_26;
wire   [7:0] empty_54_fu_58_p2;
wire    ap_loop_init;
reg   [7:0] ap_sig_allocacmp_p_load;
reg    c0_we0_local;
reg    c0_ce0_local;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg   [0:0] ap_NS_fsm;
reg    ap_ST_fsm_state1_blk;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 1'd1;
#0 empty_fu_26 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage0),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        if ((exitcond8923_fu_52_p2 == 1'd0)) begin
            empty_fu_26 <= empty_54_fu_58_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            empty_fu_26 <= 8'd0;
        end
    end
end

always @ (*) begin
    if ((1'b1 == ap_block_state1_pp0_stage0_iter0)) begin
        ap_ST_fsm_state1_blk = 1'b1;
    end else begin
        ap_ST_fsm_state1_blk = 1'b0;
    end
end

always @ (*) begin
    if (((exitcond8923_fu_52_p2 == 1'd1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if (((ap_start_int == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_sig_allocacmp_p_load = 8'd0;
    end else begin
        ap_sig_allocacmp_p_load = empty_fu_26;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        c0_ce0_local = 1'b1;
    end else begin
        c0_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((exitcond8923_fu_52_p2 == 1'd0) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        c0_we0_local = 1'b1;
    end else begin
        c0_we0_local = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            ap_NS_fsm = ap_ST_fsm_state1;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

always @ (*) begin
    ap_block_state1_pp0_stage0_iter0 = (ap_start_int == 1'b0);
end

assign ap_done = ap_done_sig;

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage0;

assign ap_ready = ap_ready_sig;

assign c0_address0 = p_cast7_fu_64_p1;

assign c0_ce0 = c0_ce0_local;

assign c0_d0 = 32'd0;

assign c0_we0 = c0_we0_local;

assign empty_54_fu_58_p2 = (ap_sig_allocacmp_p_load + 8'd1);

assign exitcond8923_fu_52_p2 = ((ap_sig_allocacmp_p_load == 8'd128) ? 1'b1 : 1'b0);

assign p_cast7_fu_64_p1 = ap_sig_allocacmp_p_load;

endmodule //vadd_lstm_inference_Pipeline_2

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_3 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        h1_address0,
        h1_ce0,
        h1_we0,
        h1_d0
);

parameter    ap_ST_fsm_state1 = 1'd1;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output  [6:0] h1_address0;
output   h1_ce0;
output   h1_we0;
output  [31:0] h1_d0;

reg ap_idle;

(* fsm_encoding = "none" *) reg   [0:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    ap_block_state1_pp0_stage0_iter0;
wire   [0:0] exitcond8822_fu_52_p2;
reg    ap_condition_exit_pp0_iter0_stage0;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
wire   [63:0] p_cast8_fu_64_p1;
reg   [7:0] empty_fu_26;
wire   [7:0] empty_53_fu_58_p2;
wire    ap_loop_init;
reg   [7:0] ap_sig_allocacmp_p_load;
reg    h1_we0_local;
reg    h1_ce0_local;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg   [0:0] ap_NS_fsm;
reg    ap_ST_fsm_state1_blk;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 1'd1;
#0 empty_fu_26 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage0),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        if ((exitcond8822_fu_52_p2 == 1'd0)) begin
            empty_fu_26 <= empty_53_fu_58_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            empty_fu_26 <= 8'd0;
        end
    end
end

always @ (*) begin
    if ((1'b1 == ap_block_state1_pp0_stage0_iter0)) begin
        ap_ST_fsm_state1_blk = 1'b1;
    end else begin
        ap_ST_fsm_state1_blk = 1'b0;
    end
end

always @ (*) begin
    if (((exitcond8822_fu_52_p2 == 1'd1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if (((ap_start_int == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_sig_allocacmp_p_load = 8'd0;
    end else begin
        ap_sig_allocacmp_p_load = empty_fu_26;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        h1_ce0_local = 1'b1;
    end else begin
        h1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((exitcond8822_fu_52_p2 == 1'd0) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        h1_we0_local = 1'b1;
    end else begin
        h1_we0_local = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            ap_NS_fsm = ap_ST_fsm_state1;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

always @ (*) begin
    ap_block_state1_pp0_stage0_iter0 = (ap_start_int == 1'b0);
end

assign ap_done = ap_done_sig;

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage0;

assign ap_ready = ap_ready_sig;

assign empty_53_fu_58_p2 = (ap_sig_allocacmp_p_load + 8'd1);

assign exitcond8822_fu_52_p2 = ((ap_sig_allocacmp_p_load == 8'd128) ? 1'b1 : 1'b0);

assign h1_address0 = p_cast8_fu_64_p1;

assign h1_ce0 = h1_ce0_local;

assign h1_d0 = 32'd0;

assign h1_we0 = h1_we0_local;

assign p_cast8_fu_64_p1 = ap_sig_allocacmp_p_load;

endmodule //vadd_lstm_inference_Pipeline_3

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_4 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        c1_address0,
        c1_ce0,
        c1_we0,
        c1_d0
);

parameter    ap_ST_fsm_state1 = 1'd1;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output  [6:0] c1_address0;
output   c1_ce0;
output   c1_we0;
output  [31:0] c1_d0;

reg ap_idle;

(* fsm_encoding = "none" *) reg   [0:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    ap_block_state1_pp0_stage0_iter0;
wire   [0:0] exitcond8721_fu_52_p2;
reg    ap_condition_exit_pp0_iter0_stage0;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
wire   [63:0] p_cast9_fu_64_p1;
reg   [7:0] empty_fu_26;
wire   [7:0] empty_52_fu_58_p2;
wire    ap_loop_init;
reg   [7:0] ap_sig_allocacmp_p_load;
reg    c1_we0_local;
reg    c1_ce0_local;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg   [0:0] ap_NS_fsm;
reg    ap_ST_fsm_state1_blk;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 1'd1;
#0 empty_fu_26 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage0),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        if ((exitcond8721_fu_52_p2 == 1'd0)) begin
            empty_fu_26 <= empty_52_fu_58_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            empty_fu_26 <= 8'd0;
        end
    end
end

always @ (*) begin
    if ((1'b1 == ap_block_state1_pp0_stage0_iter0)) begin
        ap_ST_fsm_state1_blk = 1'b1;
    end else begin
        ap_ST_fsm_state1_blk = 1'b0;
    end
end

always @ (*) begin
    if (((exitcond8721_fu_52_p2 == 1'd1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if (((ap_start_int == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_sig_allocacmp_p_load = 8'd0;
    end else begin
        ap_sig_allocacmp_p_load = empty_fu_26;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        c1_ce0_local = 1'b1;
    end else begin
        c1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((exitcond8721_fu_52_p2 == 1'd0) & (1'b0 == ap_block_state1_pp0_stage0_iter0) & (1'b1 == ap_CS_fsm_state1))) begin
        c1_we0_local = 1'b1;
    end else begin
        c1_we0_local = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            ap_NS_fsm = ap_ST_fsm_state1;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

always @ (*) begin
    ap_block_state1_pp0_stage0_iter0 = (ap_start_int == 1'b0);
end

assign ap_done = ap_done_sig;

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage0;

assign ap_ready = ap_ready_sig;

assign c1_address0 = p_cast9_fu_64_p1;

assign c1_ce0 = c1_ce0_local;

assign c1_d0 = 32'd0;

assign c1_we0 = c1_we0_local;

assign empty_52_fu_58_p2 = (ap_sig_allocacmp_p_load + 8'd1);

assign exitcond8721_fu_52_p2 = ((ap_sig_allocacmp_p_load == 8'd128) ? 1'b1 : 1'b0);

assign p_cast9_fu_64_p1 = ap_sig_allocacmp_p_load;

endmodule //vadd_lstm_inference_Pipeline_4

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_VITIS_LOOP_113_9 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        m_axi_gmem1_AWVALID,
        m_axi_gmem1_AWREADY,
        m_axi_gmem1_AWADDR,
        m_axi_gmem1_AWID,
        m_axi_gmem1_AWLEN,
        m_axi_gmem1_AWSIZE,
        m_axi_gmem1_AWBURST,
        m_axi_gmem1_AWLOCK,
        m_axi_gmem1_AWCACHE,
        m_axi_gmem1_AWPROT,
        m_axi_gmem1_AWQOS,
        m_axi_gmem1_AWREGION,
        m_axi_gmem1_AWUSER,
        m_axi_gmem1_WVALID,
        m_axi_gmem1_WREADY,
        m_axi_gmem1_WDATA,
        m_axi_gmem1_WSTRB,
        m_axi_gmem1_WLAST,
        m_axi_gmem1_WID,
        m_axi_gmem1_WUSER,
        m_axi_gmem1_ARVALID,
        m_axi_gmem1_ARREADY,
        m_axi_gmem1_ARADDR,
        m_axi_gmem1_ARID,
        m_axi_gmem1_ARLEN,
        m_axi_gmem1_ARSIZE,
        m_axi_gmem1_ARBURST,
        m_axi_gmem1_ARLOCK,
        m_axi_gmem1_ARCACHE,
        m_axi_gmem1_ARPROT,
        m_axi_gmem1_ARQOS,
        m_axi_gmem1_ARREGION,
        m_axi_gmem1_ARUSER,
        m_axi_gmem1_RVALID,
        m_axi_gmem1_RREADY,
        m_axi_gmem1_RDATA,
        m_axi_gmem1_RLAST,
        m_axi_gmem1_RID,
        m_axi_gmem1_RFIFONUM,
        m_axi_gmem1_RUSER,
        m_axi_gmem1_RRESP,
        m_axi_gmem1_BVALID,
        m_axi_gmem1_BREADY,
        m_axi_gmem1_BRESP,
        m_axi_gmem1_BID,
        m_axi_gmem1_BUSER,
        sext_ln113,
        h0_address0,
        h0_ce0,
        h0_q0,
        xC_2_out,
        xC_2_out_ap_vld,
        grp_fu_726_p_din0,
        grp_fu_726_p_din1,
        grp_fu_726_p_opcode,
        grp_fu_726_p_dout0,
        grp_fu_726_p_ce,
        grp_fu_1732_p_din0,
        grp_fu_1732_p_din1,
        grp_fu_1732_p_dout0,
        grp_fu_1732_p_ce
);

parameter    ap_ST_fsm_pp0_stage0 = 9'd1;
parameter    ap_ST_fsm_pp0_stage1 = 9'd2;
parameter    ap_ST_fsm_pp0_stage2 = 9'd4;
parameter    ap_ST_fsm_pp0_stage3 = 9'd8;
parameter    ap_ST_fsm_pp0_stage4 = 9'd16;
parameter    ap_ST_fsm_pp0_stage5 = 9'd32;
parameter    ap_ST_fsm_pp0_stage6 = 9'd64;
parameter    ap_ST_fsm_pp0_stage7 = 9'd128;
parameter    ap_ST_fsm_pp0_stage8 = 9'd256;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output   m_axi_gmem1_AWVALID;
input   m_axi_gmem1_AWREADY;
output  [63:0] m_axi_gmem1_AWADDR;
output  [0:0] m_axi_gmem1_AWID;
output  [31:0] m_axi_gmem1_AWLEN;
output  [2:0] m_axi_gmem1_AWSIZE;
output  [1:0] m_axi_gmem1_AWBURST;
output  [1:0] m_axi_gmem1_AWLOCK;
output  [3:0] m_axi_gmem1_AWCACHE;
output  [2:0] m_axi_gmem1_AWPROT;
output  [3:0] m_axi_gmem1_AWQOS;
output  [3:0] m_axi_gmem1_AWREGION;
output  [0:0] m_axi_gmem1_AWUSER;
output   m_axi_gmem1_WVALID;
input   m_axi_gmem1_WREADY;
output  [31:0] m_axi_gmem1_WDATA;
output  [3:0] m_axi_gmem1_WSTRB;
output   m_axi_gmem1_WLAST;
output  [0:0] m_axi_gmem1_WID;
output  [0:0] m_axi_gmem1_WUSER;
output   m_axi_gmem1_ARVALID;
input   m_axi_gmem1_ARREADY;
output  [63:0] m_axi_gmem1_ARADDR;
output  [0:0] m_axi_gmem1_ARID;
output  [31:0] m_axi_gmem1_ARLEN;
output  [2:0] m_axi_gmem1_ARSIZE;
output  [1:0] m_axi_gmem1_ARBURST;
output  [1:0] m_axi_gmem1_ARLOCK;
output  [3:0] m_axi_gmem1_ARCACHE;
output  [2:0] m_axi_gmem1_ARPROT;
output  [3:0] m_axi_gmem1_ARQOS;
output  [3:0] m_axi_gmem1_ARREGION;
output  [0:0] m_axi_gmem1_ARUSER;
input   m_axi_gmem1_RVALID;
output   m_axi_gmem1_RREADY;
input  [31:0] m_axi_gmem1_RDATA;
input   m_axi_gmem1_RLAST;
input  [0:0] m_axi_gmem1_RID;
input  [8:0] m_axi_gmem1_RFIFONUM;
input  [0:0] m_axi_gmem1_RUSER;
input  [1:0] m_axi_gmem1_RRESP;
input   m_axi_gmem1_BVALID;
output   m_axi_gmem1_BREADY;
input  [1:0] m_axi_gmem1_BRESP;
input  [0:0] m_axi_gmem1_BID;
input  [0:0] m_axi_gmem1_BUSER;
input  [61:0] sext_ln113;
output  [6:0] h0_address0;
output   h0_ce0;
input  [31:0] h0_q0;
output  [31:0] xC_2_out;
output   xC_2_out_ap_vld;
output  [31:0] grp_fu_726_p_din0;
output  [31:0] grp_fu_726_p_din1;
output  [1:0] grp_fu_726_p_opcode;
input  [31:0] grp_fu_726_p_dout0;
output   grp_fu_726_p_ce;
output  [31:0] grp_fu_1732_p_din0;
output  [31:0] grp_fu_1732_p_din1;
input  [31:0] grp_fu_1732_p_dout0;
output   grp_fu_1732_p_ce;

reg ap_idle;
reg m_axi_gmem1_RREADY;
reg xC_2_out_ap_vld;

(* fsm_encoding = "none" *) reg   [8:0] ap_CS_fsm;
wire    ap_CS_fsm_pp0_stage0;
reg    ap_enable_reg_pp0_iter0;
reg    ap_enable_reg_pp0_iter1;
reg    ap_idle_pp0;
wire    ap_CS_fsm_pp0_stage7;
wire    ap_block_pp0_stage7_subdone;
reg   [0:0] icmp_ln113_reg_181;
reg    ap_condition_exit_pp0_iter0_stage7;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
wire    ap_CS_fsm_pp0_stage8;
wire    ap_block_pp0_stage8_subdone;
reg    gmem1_blk_n_R;
wire    ap_CS_fsm_pp0_stage1;
wire    ap_block_pp0_stage1;
wire    ap_block_pp0_stage0_11001;
wire   [0:0] icmp_ln113_fu_116_p2;
reg   [31:0] gmem1_addr_read_reg_190;
reg    ap_block_state2_pp0_stage1_iter0;
reg    ap_block_pp0_stage1_11001;
reg   [31:0] h0_load_reg_195;
wire   [31:0] bitcast_ln115_fu_144_p1;
wire    ap_CS_fsm_pp0_stage2;
wire    ap_block_pp0_stage2_11001;
reg   [31:0] mul9_reg_205;
wire    ap_CS_fsm_pp0_stage6;
wire    ap_block_pp0_stage6_11001;
wire    ap_block_pp0_stage7_11001;
reg    ap_enable_reg_pp0_iter0_reg;
wire   [63:0] zext_ln113_fu_128_p1;
wire    ap_block_pp0_stage0;
reg   [31:0] xC_fu_52;
reg   [31:0] ap_sig_allocacmp_xC_load_2;
wire    ap_block_pp0_stage7;
wire    ap_loop_init;
reg   [7:0] k_2_fu_56;
wire   [7:0] add_ln113_fu_122_p2;
reg   [7:0] ap_sig_allocacmp_k;
wire    ap_block_pp0_stage7_01001;
reg    h0_ce0_local;
wire    ap_block_pp0_stage2;
reg    grp_fu_91_ce;
wire    ap_block_pp0_stage3_11001;
wire    ap_block_pp0_stage4_11001;
wire    ap_block_pp0_stage5_11001;
wire    ap_block_pp0_stage8_11001;
wire    ap_CS_fsm_pp0_stage3;
wire    ap_CS_fsm_pp0_stage4;
wire    ap_CS_fsm_pp0_stage5;
reg    grp_fu_95_ce;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg   [8:0] ap_NS_fsm;
wire    ap_block_pp0_stage0_subdone;
reg    ap_idle_pp0_1to1;
reg    ap_block_pp0_stage1_subdone;
wire    ap_block_pp0_stage2_subdone;
wire    ap_block_pp0_stage3_subdone;
wire    ap_block_pp0_stage4_subdone;
wire    ap_block_pp0_stage5_subdone;
wire    ap_block_pp0_stage6_subdone;
wire    ap_enable_pp0;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_block_pp0_stage7_00001;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 9'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter0_reg = 1'b0;
#0 xC_fu_52 = 32'd0;
#0 k_2_fu_56 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage7),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_pp0_stage0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_pp0_stage7_subdone) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_condition_exit_pp0_iter0_stage7)) begin
            ap_enable_reg_pp0_iter0_reg <= 1'b0;
        end else if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
            ap_enable_reg_pp0_iter0_reg <= ap_start_int;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if (((1'b0 == ap_block_pp0_stage7_subdone) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage8_subdone) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if (((ap_enable_reg_pp0_iter0 == 1'b1) & (icmp_ln113_fu_116_p2 == 1'd0))) begin
            k_2_fu_56 <= add_ln113_fu_122_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            k_2_fu_56 <= 8'd0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        xC_fu_52 <= 32'd0;
    end else if (((1'b0 == ap_block_pp0_stage7_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        xC_fu_52 <= grp_fu_726_p_dout0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        gmem1_addr_read_reg_190 <= m_axi_gmem1_RDATA;
        h0_load_reg_195 <= h0_q0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        icmp_ln113_reg_181 <= icmp_ln113_fu_116_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6))) begin
        mul9_reg_205 <= grp_fu_1732_p_dout0;
    end
end

always @ (*) begin
    if (((icmp_ln113_reg_181 == 1'd1) & (1'b0 == ap_block_pp0_stage7_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_condition_exit_pp0_iter0_stage7 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage7 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_pp0_stage7_subdone) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
        ap_enable_reg_pp0_iter0 = ap_start_int;
    end else begin
        ap_enable_reg_pp0_iter0 = ap_enable_reg_pp0_iter0_reg;
    end
end

always @ (*) begin
    if (((ap_start_int == 1'b0) & (ap_idle_pp0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter1 == 1'b0)) begin
        ap_idle_pp0_1to1 = 1'b1;
    end else begin
        ap_idle_pp0_1to1 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage8_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_sig_allocacmp_k = 8'd0;
    end else begin
        ap_sig_allocacmp_k = k_2_fu_56;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage7) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_sig_allocacmp_xC_load_2 = grp_fu_726_p_dout0;
    end else begin
        ap_sig_allocacmp_xC_load_2 = xC_fu_52;
    end
end

always @ (*) begin
    if (((icmp_ln113_reg_181 == 1'd0) & (1'b0 == ap_block_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        gmem1_blk_n_R = m_axi_gmem1_RVALID;
    end else begin
        gmem1_blk_n_R = 1'b1;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage4_11001) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage8_11001) & (1'b1 == ap_CS_fsm_pp0_stage8)) | ((1'b0 == ap_block_pp0_stage7_11001) & (1'b1 == ap_CS_fsm_pp0_stage7)) | ((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6)) | ((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2)) | ((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1)) | ((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0)))) begin
        grp_fu_91_ce = 1'b1;
    end else begin
        grp_fu_91_ce = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage4_11001) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6)) | ((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2)))) begin
        grp_fu_95_ce = 1'b1;
    end else begin
        grp_fu_95_ce = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        h0_ce0_local = 1'b1;
    end else begin
        h0_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln113_reg_181 == 1'd0) & (1'b0 == ap_block_pp0_stage1_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        m_axi_gmem1_RREADY = 1'b1;
    end else begin
        m_axi_gmem1_RREADY = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_exit_ready == 1'b1) & (icmp_ln113_reg_181 == 1'd1) & (1'b0 == ap_block_pp0_stage7_11001) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        xC_2_out_ap_vld = 1'b1;
    end else begin
        xC_2_out_ap_vld = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_pp0_stage0 : begin
            if ((~((ap_start_int == 1'b0) & (ap_idle_pp0_1to1 == 1'b1)) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_pp0_stage1 : begin
            if ((1'b0 == ap_block_pp0_stage1_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end
        end
        ap_ST_fsm_pp0_stage2 : begin
            if ((1'b0 == ap_block_pp0_stage2_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end
        end
        ap_ST_fsm_pp0_stage3 : begin
            if ((1'b0 == ap_block_pp0_stage3_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end
        end
        ap_ST_fsm_pp0_stage4 : begin
            if ((1'b0 == ap_block_pp0_stage4_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end
        end
        ap_ST_fsm_pp0_stage5 : begin
            if ((1'b0 == ap_block_pp0_stage5_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end
        end
        ap_ST_fsm_pp0_stage6 : begin
            if ((1'b0 == ap_block_pp0_stage6_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage7;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end
        end
        ap_ST_fsm_pp0_stage7 : begin
            if ((1'b1 == ap_condition_exit_pp0_iter0_stage7)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else if ((1'b0 == ap_block_pp0_stage7_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage8;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage7;
            end
        end
        ap_ST_fsm_pp0_stage8 : begin
            if ((1'b0 == ap_block_pp0_stage8_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage8;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln113_fu_122_p2 = (ap_sig_allocacmp_k + 8'd1);

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_pp0_stage1 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_pp0_stage2 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_pp0_stage3 = ap_CS_fsm[32'd3];

assign ap_CS_fsm_pp0_stage4 = ap_CS_fsm[32'd4];

assign ap_CS_fsm_pp0_stage5 = ap_CS_fsm[32'd5];

assign ap_CS_fsm_pp0_stage6 = ap_CS_fsm[32'd6];

assign ap_CS_fsm_pp0_stage7 = ap_CS_fsm[32'd7];

assign ap_CS_fsm_pp0_stage8 = ap_CS_fsm[32'd8];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage1_11001 = ((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state2_pp0_stage1_iter0));
end

always @ (*) begin
    ap_block_pp0_stage1_subdone = ((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state2_pp0_stage1_iter0));
end

assign ap_block_pp0_stage2 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_00001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_01001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage8_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage8_subdone = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_state2_pp0_stage1_iter0 = ((icmp_ln113_reg_181 == 1'd0) & (m_axi_gmem1_RVALID == 1'b0));
end

assign ap_done = ap_done_sig;

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage7;

assign ap_ready = ap_ready_sig;

assign bitcast_ln115_fu_144_p1 = gmem1_addr_read_reg_190;

assign grp_fu_1732_p_ce = grp_fu_95_ce;

assign grp_fu_1732_p_din0 = bitcast_ln115_fu_144_p1;

assign grp_fu_1732_p_din1 = h0_load_reg_195;

assign grp_fu_726_p_ce = grp_fu_91_ce;

assign grp_fu_726_p_din0 = ap_sig_allocacmp_xC_load_2;

assign grp_fu_726_p_din1 = mul9_reg_205;

assign grp_fu_726_p_opcode = 2'd0;

assign h0_address0 = zext_ln113_fu_128_p1;

assign h0_ce0 = h0_ce0_local;

assign icmp_ln113_fu_116_p2 = ((ap_sig_allocacmp_k == 8'd128) ? 1'b1 : 1'b0);

assign m_axi_gmem1_ARADDR = 64'd0;

assign m_axi_gmem1_ARBURST = 2'd0;

assign m_axi_gmem1_ARCACHE = 4'd0;

assign m_axi_gmem1_ARID = 1'd0;

assign m_axi_gmem1_ARLEN = 32'd0;

assign m_axi_gmem1_ARLOCK = 2'd0;

assign m_axi_gmem1_ARPROT = 3'd0;

assign m_axi_gmem1_ARQOS = 4'd0;

assign m_axi_gmem1_ARREGION = 4'd0;

assign m_axi_gmem1_ARSIZE = 3'd0;

assign m_axi_gmem1_ARUSER = 1'd0;

assign m_axi_gmem1_ARVALID = 1'b0;

assign m_axi_gmem1_AWADDR = 64'd0;

assign m_axi_gmem1_AWBURST = 2'd0;

assign m_axi_gmem1_AWCACHE = 4'd0;

assign m_axi_gmem1_AWID = 1'd0;

assign m_axi_gmem1_AWLEN = 32'd0;

assign m_axi_gmem1_AWLOCK = 2'd0;

assign m_axi_gmem1_AWPROT = 3'd0;

assign m_axi_gmem1_AWQOS = 4'd0;

assign m_axi_gmem1_AWREGION = 4'd0;

assign m_axi_gmem1_AWSIZE = 3'd0;

assign m_axi_gmem1_AWUSER = 1'd0;

assign m_axi_gmem1_AWVALID = 1'b0;

assign m_axi_gmem1_BREADY = 1'b0;

assign m_axi_gmem1_WDATA = 32'd0;

assign m_axi_gmem1_WID = 1'd0;

assign m_axi_gmem1_WLAST = 1'b0;

assign m_axi_gmem1_WSTRB = 4'd0;

assign m_axi_gmem1_WUSER = 1'd0;

assign m_axi_gmem1_WVALID = 1'b0;

assign xC_2_out = xC_fu_52;

assign zext_ln113_fu_128_p1 = ap_sig_allocacmp_k;

endmodule //vadd_lstm_inference_Pipeline_VITIS_LOOP_113_9

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_VITIS_LOOP_117_10 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        m_axi_gmem1_AWVALID,
        m_axi_gmem1_AWREADY,
        m_axi_gmem1_AWADDR,
        m_axi_gmem1_AWID,
        m_axi_gmem1_AWLEN,
        m_axi_gmem1_AWSIZE,
        m_axi_gmem1_AWBURST,
        m_axi_gmem1_AWLOCK,
        m_axi_gmem1_AWCACHE,
        m_axi_gmem1_AWPROT,
        m_axi_gmem1_AWQOS,
        m_axi_gmem1_AWREGION,
        m_axi_gmem1_AWUSER,
        m_axi_gmem1_WVALID,
        m_axi_gmem1_WREADY,
        m_axi_gmem1_WDATA,
        m_axi_gmem1_WSTRB,
        m_axi_gmem1_WLAST,
        m_axi_gmem1_WID,
        m_axi_gmem1_WUSER,
        m_axi_gmem1_ARVALID,
        m_axi_gmem1_ARREADY,
        m_axi_gmem1_ARADDR,
        m_axi_gmem1_ARID,
        m_axi_gmem1_ARLEN,
        m_axi_gmem1_ARSIZE,
        m_axi_gmem1_ARBURST,
        m_axi_gmem1_ARLOCK,
        m_axi_gmem1_ARCACHE,
        m_axi_gmem1_ARPROT,
        m_axi_gmem1_ARQOS,
        m_axi_gmem1_ARREGION,
        m_axi_gmem1_ARUSER,
        m_axi_gmem1_RVALID,
        m_axi_gmem1_RREADY,
        m_axi_gmem1_RDATA,
        m_axi_gmem1_RLAST,
        m_axi_gmem1_RID,
        m_axi_gmem1_RFIFONUM,
        m_axi_gmem1_RUSER,
        m_axi_gmem1_RRESP,
        m_axi_gmem1_BVALID,
        m_axi_gmem1_BREADY,
        m_axi_gmem1_BRESP,
        m_axi_gmem1_BID,
        m_axi_gmem1_BUSER,
        sext_ln117,
        h1_address0,
        h1_ce0,
        h1_q0,
        hC_2_out,
        hC_2_out_ap_vld,
        grp_fu_726_p_din0,
        grp_fu_726_p_din1,
        grp_fu_726_p_opcode,
        grp_fu_726_p_dout0,
        grp_fu_726_p_ce,
        grp_fu_1732_p_din0,
        grp_fu_1732_p_din1,
        grp_fu_1732_p_dout0,
        grp_fu_1732_p_ce
);

parameter    ap_ST_fsm_pp0_stage0 = 9'd1;
parameter    ap_ST_fsm_pp0_stage1 = 9'd2;
parameter    ap_ST_fsm_pp0_stage2 = 9'd4;
parameter    ap_ST_fsm_pp0_stage3 = 9'd8;
parameter    ap_ST_fsm_pp0_stage4 = 9'd16;
parameter    ap_ST_fsm_pp0_stage5 = 9'd32;
parameter    ap_ST_fsm_pp0_stage6 = 9'd64;
parameter    ap_ST_fsm_pp0_stage7 = 9'd128;
parameter    ap_ST_fsm_pp0_stage8 = 9'd256;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output   m_axi_gmem1_AWVALID;
input   m_axi_gmem1_AWREADY;
output  [63:0] m_axi_gmem1_AWADDR;
output  [0:0] m_axi_gmem1_AWID;
output  [31:0] m_axi_gmem1_AWLEN;
output  [2:0] m_axi_gmem1_AWSIZE;
output  [1:0] m_axi_gmem1_AWBURST;
output  [1:0] m_axi_gmem1_AWLOCK;
output  [3:0] m_axi_gmem1_AWCACHE;
output  [2:0] m_axi_gmem1_AWPROT;
output  [3:0] m_axi_gmem1_AWQOS;
output  [3:0] m_axi_gmem1_AWREGION;
output  [0:0] m_axi_gmem1_AWUSER;
output   m_axi_gmem1_WVALID;
input   m_axi_gmem1_WREADY;
output  [31:0] m_axi_gmem1_WDATA;
output  [3:0] m_axi_gmem1_WSTRB;
output   m_axi_gmem1_WLAST;
output  [0:0] m_axi_gmem1_WID;
output  [0:0] m_axi_gmem1_WUSER;
output   m_axi_gmem1_ARVALID;
input   m_axi_gmem1_ARREADY;
output  [63:0] m_axi_gmem1_ARADDR;
output  [0:0] m_axi_gmem1_ARID;
output  [31:0] m_axi_gmem1_ARLEN;
output  [2:0] m_axi_gmem1_ARSIZE;
output  [1:0] m_axi_gmem1_ARBURST;
output  [1:0] m_axi_gmem1_ARLOCK;
output  [3:0] m_axi_gmem1_ARCACHE;
output  [2:0] m_axi_gmem1_ARPROT;
output  [3:0] m_axi_gmem1_ARQOS;
output  [3:0] m_axi_gmem1_ARREGION;
output  [0:0] m_axi_gmem1_ARUSER;
input   m_axi_gmem1_RVALID;
output   m_axi_gmem1_RREADY;
input  [31:0] m_axi_gmem1_RDATA;
input   m_axi_gmem1_RLAST;
input  [0:0] m_axi_gmem1_RID;
input  [8:0] m_axi_gmem1_RFIFONUM;
input  [0:0] m_axi_gmem1_RUSER;
input  [1:0] m_axi_gmem1_RRESP;
input   m_axi_gmem1_BVALID;
output   m_axi_gmem1_BREADY;
input  [1:0] m_axi_gmem1_BRESP;
input  [0:0] m_axi_gmem1_BID;
input  [0:0] m_axi_gmem1_BUSER;
input  [61:0] sext_ln117;
output  [6:0] h1_address0;
output   h1_ce0;
input  [31:0] h1_q0;
output  [31:0] hC_2_out;
output   hC_2_out_ap_vld;
output  [31:0] grp_fu_726_p_din0;
output  [31:0] grp_fu_726_p_din1;
output  [1:0] grp_fu_726_p_opcode;
input  [31:0] grp_fu_726_p_dout0;
output   grp_fu_726_p_ce;
output  [31:0] grp_fu_1732_p_din0;
output  [31:0] grp_fu_1732_p_din1;
input  [31:0] grp_fu_1732_p_dout0;
output   grp_fu_1732_p_ce;

reg ap_idle;
reg m_axi_gmem1_RREADY;
reg hC_2_out_ap_vld;

(* fsm_encoding = "none" *) reg   [8:0] ap_CS_fsm;
wire    ap_CS_fsm_pp0_stage0;
reg    ap_enable_reg_pp0_iter0;
reg    ap_enable_reg_pp0_iter1;
reg    ap_idle_pp0;
wire    ap_CS_fsm_pp0_stage7;
wire    ap_block_pp0_stage7_subdone;
reg   [0:0] icmp_ln117_reg_181;
reg    ap_condition_exit_pp0_iter0_stage7;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
wire    ap_CS_fsm_pp0_stage8;
wire    ap_block_pp0_stage8_subdone;
reg    gmem1_blk_n_R;
wire    ap_CS_fsm_pp0_stage1;
wire    ap_block_pp0_stage1;
wire    ap_block_pp0_stage0_11001;
wire   [0:0] icmp_ln117_fu_116_p2;
reg   [31:0] gmem1_addr_read_reg_190;
reg    ap_block_state2_pp0_stage1_iter0;
reg    ap_block_pp0_stage1_11001;
reg   [31:0] h1_load_reg_195;
wire   [31:0] bitcast_ln119_fu_144_p1;
wire    ap_CS_fsm_pp0_stage2;
wire    ap_block_pp0_stage2_11001;
reg   [31:0] mul_reg_205;
wire    ap_CS_fsm_pp0_stage6;
wire    ap_block_pp0_stage6_11001;
wire    ap_block_pp0_stage7_11001;
reg    ap_enable_reg_pp0_iter0_reg;
wire   [63:0] zext_ln117_fu_128_p1;
wire    ap_block_pp0_stage0;
reg   [31:0] hC_fu_52;
reg   [31:0] ap_sig_allocacmp_hC_load_2;
wire    ap_block_pp0_stage7;
wire    ap_loop_init;
reg   [7:0] k_fu_56;
wire   [7:0] add_ln117_fu_122_p2;
reg   [7:0] ap_sig_allocacmp_k_3;
wire    ap_block_pp0_stage7_01001;
reg    h1_ce0_local;
wire    ap_block_pp0_stage2;
reg    grp_fu_91_ce;
wire    ap_block_pp0_stage3_11001;
wire    ap_block_pp0_stage4_11001;
wire    ap_block_pp0_stage5_11001;
wire    ap_block_pp0_stage8_11001;
wire    ap_CS_fsm_pp0_stage3;
wire    ap_CS_fsm_pp0_stage4;
wire    ap_CS_fsm_pp0_stage5;
reg    grp_fu_95_ce;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg   [8:0] ap_NS_fsm;
wire    ap_block_pp0_stage0_subdone;
reg    ap_idle_pp0_1to1;
reg    ap_block_pp0_stage1_subdone;
wire    ap_block_pp0_stage2_subdone;
wire    ap_block_pp0_stage3_subdone;
wire    ap_block_pp0_stage4_subdone;
wire    ap_block_pp0_stage5_subdone;
wire    ap_block_pp0_stage6_subdone;
wire    ap_enable_pp0;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_block_pp0_stage7_00001;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 9'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter0_reg = 1'b0;
#0 hC_fu_52 = 32'd0;
#0 k_fu_56 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage7),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_pp0_stage0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_pp0_stage7_subdone) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_condition_exit_pp0_iter0_stage7)) begin
            ap_enable_reg_pp0_iter0_reg <= 1'b0;
        end else if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
            ap_enable_reg_pp0_iter0_reg <= ap_start_int;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if (((1'b0 == ap_block_pp0_stage7_subdone) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage8_subdone) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        hC_fu_52 <= 32'd0;
    end else if (((1'b0 == ap_block_pp0_stage7_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        hC_fu_52 <= grp_fu_726_p_dout0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if (((ap_enable_reg_pp0_iter0 == 1'b1) & (icmp_ln117_fu_116_p2 == 1'd0))) begin
            k_fu_56 <= add_ln117_fu_122_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            k_fu_56 <= 8'd0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        gmem1_addr_read_reg_190 <= m_axi_gmem1_RDATA;
        h1_load_reg_195 <= h1_q0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        icmp_ln117_reg_181 <= icmp_ln117_fu_116_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6))) begin
        mul_reg_205 <= grp_fu_1732_p_dout0;
    end
end

always @ (*) begin
    if (((icmp_ln117_reg_181 == 1'd1) & (1'b0 == ap_block_pp0_stage7_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_condition_exit_pp0_iter0_stage7 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage7 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_pp0_stage7_subdone) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
        ap_enable_reg_pp0_iter0 = ap_start_int;
    end else begin
        ap_enable_reg_pp0_iter0 = ap_enable_reg_pp0_iter0_reg;
    end
end

always @ (*) begin
    if (((ap_start_int == 1'b0) & (ap_idle_pp0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter1 == 1'b0)) begin
        ap_idle_pp0_1to1 = 1'b1;
    end else begin
        ap_idle_pp0_1to1 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage8_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage7) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_sig_allocacmp_hC_load_2 = grp_fu_726_p_dout0;
    end else begin
        ap_sig_allocacmp_hC_load_2 = hC_fu_52;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_sig_allocacmp_k_3 = 8'd0;
    end else begin
        ap_sig_allocacmp_k_3 = k_fu_56;
    end
end

always @ (*) begin
    if (((icmp_ln117_reg_181 == 1'd0) & (1'b0 == ap_block_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        gmem1_blk_n_R = m_axi_gmem1_RVALID;
    end else begin
        gmem1_blk_n_R = 1'b1;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage4_11001) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage8_11001) & (1'b1 == ap_CS_fsm_pp0_stage8)) | ((1'b0 == ap_block_pp0_stage7_11001) & (1'b1 == ap_CS_fsm_pp0_stage7)) | ((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6)) | ((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2)) | ((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1)) | ((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0)))) begin
        grp_fu_91_ce = 1'b1;
    end else begin
        grp_fu_91_ce = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage4_11001) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6)) | ((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2)))) begin
        grp_fu_95_ce = 1'b1;
    end else begin
        grp_fu_95_ce = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        h1_ce0_local = 1'b1;
    end else begin
        h1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_exit_ready == 1'b1) & (icmp_ln117_reg_181 == 1'd1) & (1'b0 == ap_block_pp0_stage7_11001) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        hC_2_out_ap_vld = 1'b1;
    end else begin
        hC_2_out_ap_vld = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln117_reg_181 == 1'd0) & (1'b0 == ap_block_pp0_stage1_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        m_axi_gmem1_RREADY = 1'b1;
    end else begin
        m_axi_gmem1_RREADY = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_pp0_stage0 : begin
            if ((~((ap_start_int == 1'b0) & (ap_idle_pp0_1to1 == 1'b1)) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_pp0_stage1 : begin
            if ((1'b0 == ap_block_pp0_stage1_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end
        end
        ap_ST_fsm_pp0_stage2 : begin
            if ((1'b0 == ap_block_pp0_stage2_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end
        end
        ap_ST_fsm_pp0_stage3 : begin
            if ((1'b0 == ap_block_pp0_stage3_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end
        end
        ap_ST_fsm_pp0_stage4 : begin
            if ((1'b0 == ap_block_pp0_stage4_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end
        end
        ap_ST_fsm_pp0_stage5 : begin
            if ((1'b0 == ap_block_pp0_stage5_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end
        end
        ap_ST_fsm_pp0_stage6 : begin
            if ((1'b0 == ap_block_pp0_stage6_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage7;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end
        end
        ap_ST_fsm_pp0_stage7 : begin
            if ((1'b1 == ap_condition_exit_pp0_iter0_stage7)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else if ((1'b0 == ap_block_pp0_stage7_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage8;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage7;
            end
        end
        ap_ST_fsm_pp0_stage8 : begin
            if ((1'b0 == ap_block_pp0_stage8_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage8;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln117_fu_122_p2 = (ap_sig_allocacmp_k_3 + 8'd1);

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_pp0_stage1 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_pp0_stage2 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_pp0_stage3 = ap_CS_fsm[32'd3];

assign ap_CS_fsm_pp0_stage4 = ap_CS_fsm[32'd4];

assign ap_CS_fsm_pp0_stage5 = ap_CS_fsm[32'd5];

assign ap_CS_fsm_pp0_stage6 = ap_CS_fsm[32'd6];

assign ap_CS_fsm_pp0_stage7 = ap_CS_fsm[32'd7];

assign ap_CS_fsm_pp0_stage8 = ap_CS_fsm[32'd8];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage1_11001 = ((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state2_pp0_stage1_iter0));
end

always @ (*) begin
    ap_block_pp0_stage1_subdone = ((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state2_pp0_stage1_iter0));
end

assign ap_block_pp0_stage2 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_00001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_01001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage8_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage8_subdone = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_state2_pp0_stage1_iter0 = ((icmp_ln117_reg_181 == 1'd0) & (m_axi_gmem1_RVALID == 1'b0));
end

assign ap_done = ap_done_sig;

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage7;

assign ap_ready = ap_ready_sig;

assign bitcast_ln119_fu_144_p1 = gmem1_addr_read_reg_190;

assign grp_fu_1732_p_ce = grp_fu_95_ce;

assign grp_fu_1732_p_din0 = bitcast_ln119_fu_144_p1;

assign grp_fu_1732_p_din1 = h1_load_reg_195;

assign grp_fu_726_p_ce = grp_fu_91_ce;

assign grp_fu_726_p_din0 = ap_sig_allocacmp_hC_load_2;

assign grp_fu_726_p_din1 = mul_reg_205;

assign grp_fu_726_p_opcode = 2'd0;

assign h1_address0 = zext_ln117_fu_128_p1;

assign h1_ce0 = h1_ce0_local;

assign hC_2_out = hC_fu_52;

assign icmp_ln117_fu_116_p2 = ((ap_sig_allocacmp_k_3 == 8'd128) ? 1'b1 : 1'b0);

assign m_axi_gmem1_ARADDR = 64'd0;

assign m_axi_gmem1_ARBURST = 2'd0;

assign m_axi_gmem1_ARCACHE = 4'd0;

assign m_axi_gmem1_ARID = 1'd0;

assign m_axi_gmem1_ARLEN = 32'd0;

assign m_axi_gmem1_ARLOCK = 2'd0;

assign m_axi_gmem1_ARPROT = 3'd0;

assign m_axi_gmem1_ARQOS = 4'd0;

assign m_axi_gmem1_ARREGION = 4'd0;

assign m_axi_gmem1_ARSIZE = 3'd0;

assign m_axi_gmem1_ARUSER = 1'd0;

assign m_axi_gmem1_ARVALID = 1'b0;

assign m_axi_gmem1_AWADDR = 64'd0;

assign m_axi_gmem1_AWBURST = 2'd0;

assign m_axi_gmem1_AWCACHE = 4'd0;

assign m_axi_gmem1_AWID = 1'd0;

assign m_axi_gmem1_AWLEN = 32'd0;

assign m_axi_gmem1_AWLOCK = 2'd0;

assign m_axi_gmem1_AWPROT = 3'd0;

assign m_axi_gmem1_AWQOS = 4'd0;

assign m_axi_gmem1_AWREGION = 4'd0;

assign m_axi_gmem1_AWSIZE = 3'd0;

assign m_axi_gmem1_AWUSER = 1'd0;

assign m_axi_gmem1_AWVALID = 1'b0;

assign m_axi_gmem1_BREADY = 1'b0;

assign m_axi_gmem1_WDATA = 32'd0;

assign m_axi_gmem1_WID = 1'd0;

assign m_axi_gmem1_WLAST = 1'b0;

assign m_axi_gmem1_WSTRB = 4'd0;

assign m_axi_gmem1_WUSER = 1'd0;

assign m_axi_gmem1_WVALID = 1'b0;

assign zext_ln117_fu_128_p1 = ap_sig_allocacmp_k_3;

endmodule //vadd_lstm_inference_Pipeline_VITIS_LOOP_117_10

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_VITIS_LOOP_126_11 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        gates1_address0,
        gates1_ce0,
        gates1_q0,
        gates1_1_address0,
        gates1_1_ce0,
        gates1_1_q0,
        gates1_2_address0,
        gates1_2_ce0,
        gates1_2_q0,
        gates1_3_address0,
        gates1_3_ce0,
        gates1_3_q0,
        gates1_4_address0,
        gates1_4_ce0,
        gates1_4_q0,
        c1_address0,
        c1_ce0,
        c1_we0,
        c1_d0,
        c1_address1,
        c1_ce1,
        c1_q1,
        h1_address0,
        h1_ce0,
        h1_we0,
        h1_d0,
        grp_fu_726_p_din0,
        grp_fu_726_p_din1,
        grp_fu_726_p_opcode,
        grp_fu_726_p_dout0,
        grp_fu_726_p_ce,
        grp_fu_1732_p_din0,
        grp_fu_1732_p_din1,
        grp_fu_1732_p_dout0,
        grp_fu_1732_p_ce,
        grp_fu_1736_p_din0,
        grp_fu_1736_p_din1,
        grp_fu_1736_p_dout0,
        grp_fu_1736_p_ce,
        grp_fu_1740_p_din0,
        grp_fu_1740_p_din1,
        grp_fu_1740_p_dout0,
        grp_fu_1740_p_ce,
        grp_sigmoid_fu_1744_p_din1,
        grp_sigmoid_fu_1744_p_dout0,
        grp_sigmoid_fu_1749_p_din1,
        grp_sigmoid_fu_1749_p_dout0,
        grp_sigmoid_fu_1754_p_din1,
        grp_sigmoid_fu_1754_p_dout0,
        grp_tanh_approx_fu_1759_p_din1,
        grp_tanh_approx_fu_1759_p_dout0,
        grp_tanh_approx_fu_1764_p_din1,
        grp_tanh_approx_fu_1764_p_dout0
);

parameter    ap_ST_fsm_pp0_stage0 = 1'd1;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output  [6:0] gates1_address0;
output   gates1_ce0;
input  [31:0] gates1_q0;
output  [6:0] gates1_1_address0;
output   gates1_1_ce0;
input  [31:0] gates1_1_q0;
output  [6:0] gates1_2_address0;
output   gates1_2_ce0;
input  [31:0] gates1_2_q0;
output  [6:0] gates1_3_address0;
output   gates1_3_ce0;
input  [31:0] gates1_3_q0;
output  [6:0] gates1_4_address0;
output   gates1_4_ce0;
input  [31:0] gates1_4_q0;
output  [6:0] c1_address0;
output   c1_ce0;
output   c1_we0;
output  [31:0] c1_d0;
output  [6:0] c1_address1;
output   c1_ce1;
input  [31:0] c1_q1;
output  [6:0] h1_address0;
output   h1_ce0;
output   h1_we0;
output  [31:0] h1_d0;
output  [31:0] grp_fu_726_p_din0;
output  [31:0] grp_fu_726_p_din1;
output  [1:0] grp_fu_726_p_opcode;
input  [31:0] grp_fu_726_p_dout0;
output   grp_fu_726_p_ce;
output  [31:0] grp_fu_1732_p_din0;
output  [31:0] grp_fu_1732_p_din1;
input  [31:0] grp_fu_1732_p_dout0;
output   grp_fu_1732_p_ce;
output  [31:0] grp_fu_1736_p_din0;
output  [31:0] grp_fu_1736_p_din1;
input  [31:0] grp_fu_1736_p_dout0;
output   grp_fu_1736_p_ce;
output  [31:0] grp_fu_1740_p_din0;
output  [31:0] grp_fu_1740_p_din1;
input  [31:0] grp_fu_1740_p_dout0;
output   grp_fu_1740_p_ce;
output  [31:0] grp_sigmoid_fu_1744_p_din1;
input  [31:0] grp_sigmoid_fu_1744_p_dout0;
output  [31:0] grp_sigmoid_fu_1749_p_din1;
input  [31:0] grp_sigmoid_fu_1749_p_dout0;
output  [31:0] grp_sigmoid_fu_1754_p_din1;
input  [31:0] grp_sigmoid_fu_1754_p_dout0;
output  [31:0] grp_tanh_approx_fu_1759_p_din1;
input  [31:0] grp_tanh_approx_fu_1759_p_dout0;
output  [31:0] grp_tanh_approx_fu_1764_p_din1;
input  [31:0] grp_tanh_approx_fu_1764_p_dout0;

reg ap_idle;

(* fsm_encoding = "none" *) reg   [0:0] ap_CS_fsm;
wire    ap_CS_fsm_pp0_stage0;
wire    ap_enable_reg_pp0_iter0;
reg    ap_enable_reg_pp0_iter1;
reg    ap_enable_reg_pp0_iter2;
reg    ap_enable_reg_pp0_iter3;
reg    ap_enable_reg_pp0_iter4;
reg    ap_enable_reg_pp0_iter5;
reg    ap_enable_reg_pp0_iter6;
reg    ap_enable_reg_pp0_iter7;
reg    ap_enable_reg_pp0_iter8;
reg    ap_enable_reg_pp0_iter9;
reg    ap_enable_reg_pp0_iter10;
reg    ap_enable_reg_pp0_iter11;
reg    ap_enable_reg_pp0_iter12;
reg    ap_enable_reg_pp0_iter13;
reg    ap_enable_reg_pp0_iter14;
reg    ap_enable_reg_pp0_iter15;
reg    ap_enable_reg_pp0_iter16;
reg    ap_enable_reg_pp0_iter17;
reg    ap_enable_reg_pp0_iter18;
reg    ap_enable_reg_pp0_iter19;
reg    ap_enable_reg_pp0_iter20;
reg    ap_enable_reg_pp0_iter21;
reg    ap_enable_reg_pp0_iter22;
reg    ap_enable_reg_pp0_iter23;
reg    ap_enable_reg_pp0_iter24;
reg    ap_enable_reg_pp0_iter25;
reg    ap_enable_reg_pp0_iter26;
reg    ap_enable_reg_pp0_iter27;
reg    ap_enable_reg_pp0_iter28;
reg    ap_enable_reg_pp0_iter29;
reg    ap_enable_reg_pp0_iter30;
reg    ap_enable_reg_pp0_iter31;
reg    ap_enable_reg_pp0_iter32;
reg    ap_enable_reg_pp0_iter33;
reg    ap_enable_reg_pp0_iter34;
reg    ap_enable_reg_pp0_iter35;
reg    ap_enable_reg_pp0_iter36;
reg    ap_enable_reg_pp0_iter37;
reg    ap_enable_reg_pp0_iter38;
reg    ap_enable_reg_pp0_iter39;
reg    ap_enable_reg_pp0_iter40;
reg    ap_enable_reg_pp0_iter41;
reg    ap_enable_reg_pp0_iter42;
reg    ap_enable_reg_pp0_iter43;
reg    ap_enable_reg_pp0_iter44;
reg    ap_enable_reg_pp0_iter45;
reg    ap_enable_reg_pp0_iter46;
reg    ap_enable_reg_pp0_iter47;
reg    ap_enable_reg_pp0_iter48;
reg    ap_enable_reg_pp0_iter49;
reg    ap_enable_reg_pp0_iter50;
reg    ap_enable_reg_pp0_iter51;
reg    ap_enable_reg_pp0_iter52;
reg    ap_enable_reg_pp0_iter53;
reg    ap_enable_reg_pp0_iter54;
reg    ap_enable_reg_pp0_iter55;
reg    ap_enable_reg_pp0_iter56;
reg    ap_enable_reg_pp0_iter57;
reg    ap_enable_reg_pp0_iter58;
reg    ap_enable_reg_pp0_iter59;
reg    ap_enable_reg_pp0_iter60;
reg    ap_enable_reg_pp0_iter61;
reg    ap_enable_reg_pp0_iter62;
reg    ap_enable_reg_pp0_iter63;
reg    ap_enable_reg_pp0_iter64;
reg    ap_enable_reg_pp0_iter65;
reg    ap_enable_reg_pp0_iter66;
reg    ap_enable_reg_pp0_iter67;
reg    ap_enable_reg_pp0_iter68;
reg    ap_enable_reg_pp0_iter69;
reg    ap_enable_reg_pp0_iter70;
reg    ap_enable_reg_pp0_iter71;
reg    ap_enable_reg_pp0_iter72;
reg    ap_enable_reg_pp0_iter73;
reg    ap_enable_reg_pp0_iter74;
reg    ap_enable_reg_pp0_iter75;
reg    ap_enable_reg_pp0_iter76;
reg    ap_enable_reg_pp0_iter77;
reg    ap_enable_reg_pp0_iter78;
reg    ap_enable_reg_pp0_iter79;
reg    ap_enable_reg_pp0_iter80;
reg    ap_enable_reg_pp0_iter81;
reg    ap_enable_reg_pp0_iter82;
reg    ap_enable_reg_pp0_iter83;
reg    ap_enable_reg_pp0_iter84;
reg    ap_enable_reg_pp0_iter85;
reg    ap_enable_reg_pp0_iter86;
reg    ap_enable_reg_pp0_iter87;
reg    ap_enable_reg_pp0_iter88;
reg    ap_enable_reg_pp0_iter89;
reg    ap_enable_reg_pp0_iter90;
reg    ap_enable_reg_pp0_iter91;
reg    ap_enable_reg_pp0_iter92;
reg    ap_enable_reg_pp0_iter93;
reg    ap_enable_reg_pp0_iter94;
reg    ap_enable_reg_pp0_iter95;
reg    ap_enable_reg_pp0_iter96;
reg    ap_enable_reg_pp0_iter97;
reg    ap_enable_reg_pp0_iter98;
reg    ap_enable_reg_pp0_iter99;
reg    ap_enable_reg_pp0_iter100;
reg    ap_enable_reg_pp0_iter101;
reg    ap_enable_reg_pp0_iter102;
reg    ap_enable_reg_pp0_iter103;
reg    ap_enable_reg_pp0_iter104;
reg    ap_enable_reg_pp0_iter105;
reg    ap_enable_reg_pp0_iter106;
reg    ap_idle_pp0;
wire    ap_block_pp0_stage0_subdone;
wire   [0:0] icmp_ln126_fu_388_p2;
reg    ap_condition_exit_pp0_iter0_stage0;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
wire    ap_block_pp0_stage0_11001;
reg   [7:0] j_3_reg_710;
wire   [63:0] zext_ln126_fu_400_p1;
reg   [63:0] zext_ln126_reg_720;
reg   [63:0] zext_ln126_reg_720_pp0_iter1_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter2_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter3_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter4_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter5_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter6_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter7_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter8_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter9_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter10_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter11_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter12_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter13_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter14_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter15_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter16_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter17_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter18_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter19_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter20_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter21_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter22_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter23_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter24_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter25_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter26_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter27_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter28_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter29_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter30_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter31_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter32_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter33_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter34_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter35_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter36_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter37_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter38_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter39_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter40_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter41_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter42_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter43_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter44_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter45_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter46_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter47_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter48_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter49_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter50_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter51_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter52_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter53_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter54_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter55_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter56_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter57_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter58_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter59_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter60_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter61_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter62_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter63_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter64_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter65_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter66_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter67_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter68_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter69_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter70_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter71_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter72_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter73_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter74_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter75_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter76_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter77_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter78_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter79_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter80_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter81_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter82_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter83_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter84_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter85_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter86_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter87_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter88_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter89_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter90_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter91_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter92_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter93_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter94_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter95_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter96_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter97_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter98_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter99_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter100_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter101_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter102_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter103_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter104_reg;
reg   [63:0] zext_ln126_reg_720_pp0_iter105_reg;
reg   [6:0] c1_addr_reg_725;
reg   [6:0] c1_addr_reg_725_pp0_iter1_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter2_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter3_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter4_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter5_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter6_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter7_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter8_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter9_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter10_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter11_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter12_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter13_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter14_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter15_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter16_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter17_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter18_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter19_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter20_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter21_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter22_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter23_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter24_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter25_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter26_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter27_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter28_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter29_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter30_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter31_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter32_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter33_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter34_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter35_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter36_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter37_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter38_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter39_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter40_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter41_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter42_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter43_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter44_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter45_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter46_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter47_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter48_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter49_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter50_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter51_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter52_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter53_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter54_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter55_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter56_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter57_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter58_reg;
reg   [6:0] c1_addr_reg_725_pp0_iter59_reg;
wire   [2:0] trunc_ln126_fu_433_p1;
reg   [2:0] trunc_ln126_reg_731;
reg   [2:0] trunc_ln126_reg_731_pp0_iter2_reg;
reg   [5:0] tmp_16_reg_739;
reg   [6:0] tmp_17_reg_744;
reg   [6:0] tmp_18_reg_749;
reg   [31:0] c1_load_reg_754;
reg   [31:0] c1_load_reg_754_pp0_iter2_reg;
reg   [31:0] c1_load_reg_754_pp0_iter3_reg;
reg   [31:0] c1_load_reg_754_pp0_iter4_reg;
reg   [31:0] c1_load_reg_754_pp0_iter5_reg;
reg   [31:0] c1_load_reg_754_pp0_iter6_reg;
reg   [31:0] c1_load_reg_754_pp0_iter7_reg;
reg   [31:0] c1_load_reg_754_pp0_iter8_reg;
reg   [31:0] c1_load_reg_754_pp0_iter9_reg;
reg   [31:0] c1_load_reg_754_pp0_iter10_reg;
reg   [31:0] c1_load_reg_754_pp0_iter11_reg;
reg   [31:0] c1_load_reg_754_pp0_iter12_reg;
reg   [31:0] c1_load_reg_754_pp0_iter13_reg;
reg   [31:0] c1_load_reg_754_pp0_iter14_reg;
reg   [31:0] c1_load_reg_754_pp0_iter15_reg;
reg   [31:0] c1_load_reg_754_pp0_iter16_reg;
reg   [31:0] c1_load_reg_754_pp0_iter17_reg;
reg   [31:0] c1_load_reg_754_pp0_iter18_reg;
reg   [31:0] c1_load_reg_754_pp0_iter19_reg;
reg   [31:0] c1_load_reg_754_pp0_iter20_reg;
reg   [31:0] c1_load_reg_754_pp0_iter21_reg;
reg   [31:0] c1_load_reg_754_pp0_iter22_reg;
reg   [31:0] c1_load_reg_754_pp0_iter23_reg;
reg   [31:0] c1_load_reg_754_pp0_iter24_reg;
wire   [31:0] tmp_2_fu_581_p13;
reg   [31:0] tmp_2_reg_859;
wire   [31:0] tmp_3_fu_608_p13;
reg   [31:0] tmp_3_reg_864;
wire   [31:0] tmp_4_fu_635_p13;
reg   [31:0] tmp_4_reg_869;
wire   [31:0] tmp_5_fu_662_p13;
reg   [31:0] tmp_5_reg_874;
reg   [31:0] i_gate_reg_879;
reg   [31:0] i_gate_reg_879_pp0_iter25_reg;
reg   [31:0] i_gate_reg_879_pp0_iter26_reg;
reg   [31:0] i_gate_reg_879_pp0_iter27_reg;
reg   [31:0] i_gate_reg_879_pp0_iter28_reg;
reg   [31:0] i_gate_reg_879_pp0_iter29_reg;
reg   [31:0] i_gate_reg_879_pp0_iter30_reg;
reg   [31:0] i_gate_reg_879_pp0_iter31_reg;
reg   [31:0] i_gate_reg_879_pp0_iter32_reg;
reg   [31:0] i_gate_reg_879_pp0_iter33_reg;
reg   [31:0] i_gate_reg_879_pp0_iter34_reg;
reg   [31:0] i_gate_reg_879_pp0_iter35_reg;
reg   [31:0] i_gate_reg_879_pp0_iter36_reg;
reg   [31:0] i_gate_reg_879_pp0_iter37_reg;
reg   [31:0] i_gate_reg_879_pp0_iter38_reg;
reg   [31:0] i_gate_reg_879_pp0_iter39_reg;
reg   [31:0] i_gate_reg_879_pp0_iter40_reg;
reg   [31:0] i_gate_reg_879_pp0_iter41_reg;
reg   [31:0] i_gate_reg_879_pp0_iter42_reg;
reg   [31:0] i_gate_reg_879_pp0_iter43_reg;
reg   [31:0] i_gate_reg_879_pp0_iter44_reg;
reg   [31:0] f_gate_reg_884;
reg   [31:0] o_gate_reg_889;
reg   [31:0] o_gate_reg_889_pp0_iter25_reg;
reg   [31:0] o_gate_reg_889_pp0_iter26_reg;
reg   [31:0] o_gate_reg_889_pp0_iter27_reg;
reg   [31:0] o_gate_reg_889_pp0_iter28_reg;
reg   [31:0] o_gate_reg_889_pp0_iter29_reg;
reg   [31:0] o_gate_reg_889_pp0_iter30_reg;
reg   [31:0] o_gate_reg_889_pp0_iter31_reg;
reg   [31:0] o_gate_reg_889_pp0_iter32_reg;
reg   [31:0] o_gate_reg_889_pp0_iter33_reg;
reg   [31:0] o_gate_reg_889_pp0_iter34_reg;
reg   [31:0] o_gate_reg_889_pp0_iter35_reg;
reg   [31:0] o_gate_reg_889_pp0_iter36_reg;
reg   [31:0] o_gate_reg_889_pp0_iter37_reg;
reg   [31:0] o_gate_reg_889_pp0_iter38_reg;
reg   [31:0] o_gate_reg_889_pp0_iter39_reg;
reg   [31:0] o_gate_reg_889_pp0_iter40_reg;
reg   [31:0] o_gate_reg_889_pp0_iter41_reg;
reg   [31:0] o_gate_reg_889_pp0_iter42_reg;
reg   [31:0] o_gate_reg_889_pp0_iter43_reg;
reg   [31:0] o_gate_reg_889_pp0_iter44_reg;
reg   [31:0] o_gate_reg_889_pp0_iter45_reg;
reg   [31:0] o_gate_reg_889_pp0_iter46_reg;
reg   [31:0] o_gate_reg_889_pp0_iter47_reg;
reg   [31:0] o_gate_reg_889_pp0_iter48_reg;
reg   [31:0] o_gate_reg_889_pp0_iter49_reg;
reg   [31:0] o_gate_reg_889_pp0_iter50_reg;
reg   [31:0] o_gate_reg_889_pp0_iter51_reg;
reg   [31:0] o_gate_reg_889_pp0_iter52_reg;
reg   [31:0] o_gate_reg_889_pp0_iter53_reg;
reg   [31:0] o_gate_reg_889_pp0_iter54_reg;
reg   [31:0] o_gate_reg_889_pp0_iter55_reg;
reg   [31:0] o_gate_reg_889_pp0_iter56_reg;
reg   [31:0] o_gate_reg_889_pp0_iter57_reg;
reg   [31:0] o_gate_reg_889_pp0_iter58_reg;
reg   [31:0] o_gate_reg_889_pp0_iter59_reg;
reg   [31:0] o_gate_reg_889_pp0_iter60_reg;
reg   [31:0] o_gate_reg_889_pp0_iter61_reg;
reg   [31:0] o_gate_reg_889_pp0_iter62_reg;
reg   [31:0] o_gate_reg_889_pp0_iter63_reg;
reg   [31:0] o_gate_reg_889_pp0_iter64_reg;
reg   [31:0] o_gate_reg_889_pp0_iter65_reg;
reg   [31:0] o_gate_reg_889_pp0_iter66_reg;
reg   [31:0] o_gate_reg_889_pp0_iter67_reg;
reg   [31:0] o_gate_reg_889_pp0_iter68_reg;
reg   [31:0] o_gate_reg_889_pp0_iter69_reg;
reg   [31:0] o_gate_reg_889_pp0_iter70_reg;
reg   [31:0] o_gate_reg_889_pp0_iter71_reg;
reg   [31:0] o_gate_reg_889_pp0_iter72_reg;
reg   [31:0] o_gate_reg_889_pp0_iter73_reg;
reg   [31:0] o_gate_reg_889_pp0_iter74_reg;
reg   [31:0] o_gate_reg_889_pp0_iter75_reg;
reg   [31:0] o_gate_reg_889_pp0_iter76_reg;
reg   [31:0] o_gate_reg_889_pp0_iter77_reg;
reg   [31:0] o_gate_reg_889_pp0_iter78_reg;
reg   [31:0] o_gate_reg_889_pp0_iter79_reg;
reg   [31:0] o_gate_reg_889_pp0_iter80_reg;
reg   [31:0] o_gate_reg_889_pp0_iter81_reg;
reg   [31:0] o_gate_reg_889_pp0_iter82_reg;
reg   [31:0] o_gate_reg_889_pp0_iter83_reg;
reg   [31:0] o_gate_reg_889_pp0_iter84_reg;
reg   [31:0] o_gate_reg_889_pp0_iter85_reg;
reg   [31:0] o_gate_reg_889_pp0_iter86_reg;
reg   [31:0] o_gate_reg_889_pp0_iter87_reg;
reg   [31:0] o_gate_reg_889_pp0_iter88_reg;
reg   [31:0] o_gate_reg_889_pp0_iter89_reg;
reg   [31:0] o_gate_reg_889_pp0_iter90_reg;
reg   [31:0] o_gate_reg_889_pp0_iter91_reg;
reg   [31:0] o_gate_reg_889_pp0_iter92_reg;
reg   [31:0] o_gate_reg_889_pp0_iter93_reg;
reg   [31:0] o_gate_reg_889_pp0_iter94_reg;
reg   [31:0] o_gate_reg_889_pp0_iter95_reg;
reg   [31:0] o_gate_reg_889_pp0_iter96_reg;
reg   [31:0] o_gate_reg_889_pp0_iter97_reg;
reg   [31:0] o_gate_reg_889_pp0_iter98_reg;
reg   [31:0] o_gate_reg_889_pp0_iter99_reg;
reg   [31:0] o_gate_reg_889_pp0_iter100_reg;
reg   [31:0] mul5_reg_894;
reg   [31:0] mul5_reg_894_pp0_iter30_reg;
reg   [31:0] mul5_reg_894_pp0_iter31_reg;
reg   [31:0] mul5_reg_894_pp0_iter32_reg;
reg   [31:0] mul5_reg_894_pp0_iter33_reg;
reg   [31:0] mul5_reg_894_pp0_iter34_reg;
reg   [31:0] mul5_reg_894_pp0_iter35_reg;
reg   [31:0] mul5_reg_894_pp0_iter36_reg;
reg   [31:0] mul5_reg_894_pp0_iter37_reg;
reg   [31:0] mul5_reg_894_pp0_iter38_reg;
reg   [31:0] mul5_reg_894_pp0_iter39_reg;
reg   [31:0] mul5_reg_894_pp0_iter40_reg;
reg   [31:0] mul5_reg_894_pp0_iter41_reg;
reg   [31:0] mul5_reg_894_pp0_iter42_reg;
reg   [31:0] mul5_reg_894_pp0_iter43_reg;
reg   [31:0] mul5_reg_894_pp0_iter44_reg;
reg   [31:0] mul5_reg_894_pp0_iter45_reg;
reg   [31:0] mul5_reg_894_pp0_iter46_reg;
reg   [31:0] mul5_reg_894_pp0_iter47_reg;
reg   [31:0] mul5_reg_894_pp0_iter48_reg;
reg   [31:0] mul5_reg_894_pp0_iter49_reg;
reg   [31:0] g_gate_reg_899;
reg   [31:0] mul6_reg_904;
reg   [31:0] c1_new_reg_909;
reg   [31:0] tmp_7_reg_915;
reg   [31:0] mul7_reg_920;
wire    ap_block_pp0_stage0_ignoreCallOp217;
wire    ap_block_pp0_stage0_ignoreCallOp218;
wire    ap_block_pp0_stage0_ignoreCallOp220;
wire    ap_block_pp0_stage0_ignoreCallOp219;
wire    ap_block_pp0_stage0_ignoreCallOp342;
wire    ap_block_pp0_stage0;
wire   [63:0] zext_ln126_1_fu_543_p1;
wire   [63:0] zext_ln128_fu_552_p1;
wire   [63:0] zext_ln129_fu_560_p1;
wire   [63:0] zext_ln130_fu_568_p1;
reg   [7:0] phi_urem461_fu_92;
wire   [7:0] select_ln126_fu_425_p3;
wire    ap_loop_init;
reg   [15:0] phi_mul459_fu_96;
wire   [15:0] add_ln126_2_fu_527_p2;
reg   [7:0] j_fu_100;
wire   [7:0] add_ln126_fu_394_p2;
reg   [7:0] ap_sig_allocacmp_j_3;
reg    c1_ce1_local;
reg    c1_we0_local;
reg    c1_ce0_local;
reg    gates1_ce0_local;
reg   [6:0] gates1_address0_local;
reg    gates1_1_ce0_local;
reg   [6:0] gates1_1_address0_local;
reg    gates1_2_ce0_local;
reg   [6:0] gates1_2_address0_local;
reg    gates1_3_ce0_local;
reg   [6:0] gates1_3_address0_local;
reg    gates1_4_ce0_local;
reg   [6:0] gates1_4_address0_local;
reg    h1_we0_local;
reg    h1_ce0_local;
wire   [7:0] add_ln126_1_fu_413_p2;
wire   [0:0] icmp_ln126_1_fu_419_p2;
wire   [6:0] trunc_ln128_fu_437_p1;
wire  signed [7:0] zext_ln128_1_cast_fu_440_p3;
wire   [7:0] mul_ln128_fu_452_p0;
wire   [9:0] mul_ln128_fu_452_p1;
wire   [16:0] mul_ln128_fu_452_p2;
wire   [8:0] zext_ln129_1_cast_fu_468_p3;
wire   [8:0] mul_ln129_fu_479_p0;
wire   [10:0] mul_ln129_fu_479_p1;
wire   [18:0] mul_ln129_fu_479_p2;
wire  signed [8:0] sext_ln130_fu_495_p1;
wire   [8:0] mul_ln130_fu_503_p0;
wire   [10:0] mul_ln130_fu_503_p1;
wire   [18:0] mul_ln130_fu_503_p2;
wire   [4:0] tmp_fu_533_p4;
wire   [31:0] tmp_2_fu_581_p11;
wire   [31:0] tmp_3_fu_608_p11;
wire   [31:0] tmp_4_fu_635_p11;
wire   [31:0] tmp_5_fu_662_p11;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg    ap_loop_exit_ready_pp0_iter1_reg;
reg    ap_loop_exit_ready_pp0_iter2_reg;
reg    ap_loop_exit_ready_pp0_iter3_reg;
reg    ap_loop_exit_ready_pp0_iter4_reg;
reg    ap_loop_exit_ready_pp0_iter5_reg;
reg    ap_loop_exit_ready_pp0_iter6_reg;
reg    ap_loop_exit_ready_pp0_iter7_reg;
reg    ap_loop_exit_ready_pp0_iter8_reg;
reg    ap_loop_exit_ready_pp0_iter9_reg;
reg    ap_loop_exit_ready_pp0_iter10_reg;
reg    ap_loop_exit_ready_pp0_iter11_reg;
reg    ap_loop_exit_ready_pp0_iter12_reg;
reg    ap_loop_exit_ready_pp0_iter13_reg;
reg    ap_loop_exit_ready_pp0_iter14_reg;
reg    ap_loop_exit_ready_pp0_iter15_reg;
reg    ap_loop_exit_ready_pp0_iter16_reg;
reg    ap_loop_exit_ready_pp0_iter17_reg;
reg    ap_loop_exit_ready_pp0_iter18_reg;
reg    ap_loop_exit_ready_pp0_iter19_reg;
reg    ap_loop_exit_ready_pp0_iter20_reg;
reg    ap_loop_exit_ready_pp0_iter21_reg;
reg    ap_loop_exit_ready_pp0_iter22_reg;
reg    ap_loop_exit_ready_pp0_iter23_reg;
reg    ap_loop_exit_ready_pp0_iter24_reg;
reg    ap_loop_exit_ready_pp0_iter25_reg;
reg    ap_loop_exit_ready_pp0_iter26_reg;
reg    ap_loop_exit_ready_pp0_iter27_reg;
reg    ap_loop_exit_ready_pp0_iter28_reg;
reg    ap_loop_exit_ready_pp0_iter29_reg;
reg    ap_loop_exit_ready_pp0_iter30_reg;
reg    ap_loop_exit_ready_pp0_iter31_reg;
reg    ap_loop_exit_ready_pp0_iter32_reg;
reg    ap_loop_exit_ready_pp0_iter33_reg;
reg    ap_loop_exit_ready_pp0_iter34_reg;
reg    ap_loop_exit_ready_pp0_iter35_reg;
reg    ap_loop_exit_ready_pp0_iter36_reg;
reg    ap_loop_exit_ready_pp0_iter37_reg;
reg    ap_loop_exit_ready_pp0_iter38_reg;
reg    ap_loop_exit_ready_pp0_iter39_reg;
reg    ap_loop_exit_ready_pp0_iter40_reg;
reg    ap_loop_exit_ready_pp0_iter41_reg;
reg    ap_loop_exit_ready_pp0_iter42_reg;
reg    ap_loop_exit_ready_pp0_iter43_reg;
reg    ap_loop_exit_ready_pp0_iter44_reg;
reg    ap_loop_exit_ready_pp0_iter45_reg;
reg    ap_loop_exit_ready_pp0_iter46_reg;
reg    ap_loop_exit_ready_pp0_iter47_reg;
reg    ap_loop_exit_ready_pp0_iter48_reg;
reg    ap_loop_exit_ready_pp0_iter49_reg;
reg    ap_loop_exit_ready_pp0_iter50_reg;
reg    ap_loop_exit_ready_pp0_iter51_reg;
reg    ap_loop_exit_ready_pp0_iter52_reg;
reg    ap_loop_exit_ready_pp0_iter53_reg;
reg    ap_loop_exit_ready_pp0_iter54_reg;
reg    ap_loop_exit_ready_pp0_iter55_reg;
reg    ap_loop_exit_ready_pp0_iter56_reg;
reg    ap_loop_exit_ready_pp0_iter57_reg;
reg    ap_loop_exit_ready_pp0_iter58_reg;
reg    ap_loop_exit_ready_pp0_iter59_reg;
reg    ap_loop_exit_ready_pp0_iter60_reg;
reg    ap_loop_exit_ready_pp0_iter61_reg;
reg    ap_loop_exit_ready_pp0_iter62_reg;
reg    ap_loop_exit_ready_pp0_iter63_reg;
reg    ap_loop_exit_ready_pp0_iter64_reg;
reg    ap_loop_exit_ready_pp0_iter65_reg;
reg    ap_loop_exit_ready_pp0_iter66_reg;
reg    ap_loop_exit_ready_pp0_iter67_reg;
reg    ap_loop_exit_ready_pp0_iter68_reg;
reg    ap_loop_exit_ready_pp0_iter69_reg;
reg    ap_loop_exit_ready_pp0_iter70_reg;
reg    ap_loop_exit_ready_pp0_iter71_reg;
reg    ap_loop_exit_ready_pp0_iter72_reg;
reg    ap_loop_exit_ready_pp0_iter73_reg;
reg    ap_loop_exit_ready_pp0_iter74_reg;
reg    ap_loop_exit_ready_pp0_iter75_reg;
reg    ap_loop_exit_ready_pp0_iter76_reg;
reg    ap_loop_exit_ready_pp0_iter77_reg;
reg    ap_loop_exit_ready_pp0_iter78_reg;
reg    ap_loop_exit_ready_pp0_iter79_reg;
reg    ap_loop_exit_ready_pp0_iter80_reg;
reg    ap_loop_exit_ready_pp0_iter81_reg;
reg    ap_loop_exit_ready_pp0_iter82_reg;
reg    ap_loop_exit_ready_pp0_iter83_reg;
reg    ap_loop_exit_ready_pp0_iter84_reg;
reg    ap_loop_exit_ready_pp0_iter85_reg;
reg    ap_loop_exit_ready_pp0_iter86_reg;
reg    ap_loop_exit_ready_pp0_iter87_reg;
reg    ap_loop_exit_ready_pp0_iter88_reg;
reg    ap_loop_exit_ready_pp0_iter89_reg;
reg    ap_loop_exit_ready_pp0_iter90_reg;
reg    ap_loop_exit_ready_pp0_iter91_reg;
reg    ap_loop_exit_ready_pp0_iter92_reg;
reg    ap_loop_exit_ready_pp0_iter93_reg;
reg    ap_loop_exit_ready_pp0_iter94_reg;
reg    ap_loop_exit_ready_pp0_iter95_reg;
reg    ap_loop_exit_ready_pp0_iter96_reg;
reg    ap_loop_exit_ready_pp0_iter97_reg;
reg    ap_loop_exit_ready_pp0_iter98_reg;
reg    ap_loop_exit_ready_pp0_iter99_reg;
reg    ap_loop_exit_ready_pp0_iter100_reg;
reg    ap_loop_exit_ready_pp0_iter101_reg;
reg    ap_loop_exit_ready_pp0_iter102_reg;
reg    ap_loop_exit_ready_pp0_iter103_reg;
reg    ap_loop_exit_ready_pp0_iter104_reg;
reg    ap_loop_exit_ready_pp0_iter105_reg;
reg   [0:0] ap_NS_fsm;
wire    ap_enable_pp0;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_block_pp0_stage0_00001;
wire   [16:0] mul_ln128_fu_452_p00;
wire   [18:0] mul_ln129_fu_479_p00;
wire   [18:0] mul_ln130_fu_503_p00;
wire   [2:0] tmp_2_fu_581_p1;
wire   [2:0] tmp_2_fu_581_p3;
wire   [2:0] tmp_2_fu_581_p5;
wire   [2:0] tmp_2_fu_581_p7;
wire  signed [2:0] tmp_2_fu_581_p9;
wire   [2:0] tmp_3_fu_608_p1;
wire   [2:0] tmp_3_fu_608_p3;
wire  signed [2:0] tmp_3_fu_608_p5;
wire   [2:0] tmp_3_fu_608_p7;
wire   [2:0] tmp_3_fu_608_p9;
wire  signed [2:0] tmp_4_fu_635_p1;
wire   [2:0] tmp_4_fu_635_p3;
wire   [2:0] tmp_4_fu_635_p5;
wire   [2:0] tmp_4_fu_635_p7;
wire   [2:0] tmp_4_fu_635_p9;
wire   [2:0] tmp_5_fu_662_p1;
wire   [2:0] tmp_5_fu_662_p3;
wire   [2:0] tmp_5_fu_662_p5;
wire  signed [2:0] tmp_5_fu_662_p7;
wire   [2:0] tmp_5_fu_662_p9;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 1'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter2 = 1'b0;
#0 ap_enable_reg_pp0_iter3 = 1'b0;
#0 ap_enable_reg_pp0_iter4 = 1'b0;
#0 ap_enable_reg_pp0_iter5 = 1'b0;
#0 ap_enable_reg_pp0_iter6 = 1'b0;
#0 ap_enable_reg_pp0_iter7 = 1'b0;
#0 ap_enable_reg_pp0_iter8 = 1'b0;
#0 ap_enable_reg_pp0_iter9 = 1'b0;
#0 ap_enable_reg_pp0_iter10 = 1'b0;
#0 ap_enable_reg_pp0_iter11 = 1'b0;
#0 ap_enable_reg_pp0_iter12 = 1'b0;
#0 ap_enable_reg_pp0_iter13 = 1'b0;
#0 ap_enable_reg_pp0_iter14 = 1'b0;
#0 ap_enable_reg_pp0_iter15 = 1'b0;
#0 ap_enable_reg_pp0_iter16 = 1'b0;
#0 ap_enable_reg_pp0_iter17 = 1'b0;
#0 ap_enable_reg_pp0_iter18 = 1'b0;
#0 ap_enable_reg_pp0_iter19 = 1'b0;
#0 ap_enable_reg_pp0_iter20 = 1'b0;
#0 ap_enable_reg_pp0_iter21 = 1'b0;
#0 ap_enable_reg_pp0_iter22 = 1'b0;
#0 ap_enable_reg_pp0_iter23 = 1'b0;
#0 ap_enable_reg_pp0_iter24 = 1'b0;
#0 ap_enable_reg_pp0_iter25 = 1'b0;
#0 ap_enable_reg_pp0_iter26 = 1'b0;
#0 ap_enable_reg_pp0_iter27 = 1'b0;
#0 ap_enable_reg_pp0_iter28 = 1'b0;
#0 ap_enable_reg_pp0_iter29 = 1'b0;
#0 ap_enable_reg_pp0_iter30 = 1'b0;
#0 ap_enable_reg_pp0_iter31 = 1'b0;
#0 ap_enable_reg_pp0_iter32 = 1'b0;
#0 ap_enable_reg_pp0_iter33 = 1'b0;
#0 ap_enable_reg_pp0_iter34 = 1'b0;
#0 ap_enable_reg_pp0_iter35 = 1'b0;
#0 ap_enable_reg_pp0_iter36 = 1'b0;
#0 ap_enable_reg_pp0_iter37 = 1'b0;
#0 ap_enable_reg_pp0_iter38 = 1'b0;
#0 ap_enable_reg_pp0_iter39 = 1'b0;
#0 ap_enable_reg_pp0_iter40 = 1'b0;
#0 ap_enable_reg_pp0_iter41 = 1'b0;
#0 ap_enable_reg_pp0_iter42 = 1'b0;
#0 ap_enable_reg_pp0_iter43 = 1'b0;
#0 ap_enable_reg_pp0_iter44 = 1'b0;
#0 ap_enable_reg_pp0_iter45 = 1'b0;
#0 ap_enable_reg_pp0_iter46 = 1'b0;
#0 ap_enable_reg_pp0_iter47 = 1'b0;
#0 ap_enable_reg_pp0_iter48 = 1'b0;
#0 ap_enable_reg_pp0_iter49 = 1'b0;
#0 ap_enable_reg_pp0_iter50 = 1'b0;
#0 ap_enable_reg_pp0_iter51 = 1'b0;
#0 ap_enable_reg_pp0_iter52 = 1'b0;
#0 ap_enable_reg_pp0_iter53 = 1'b0;
#0 ap_enable_reg_pp0_iter54 = 1'b0;
#0 ap_enable_reg_pp0_iter55 = 1'b0;
#0 ap_enable_reg_pp0_iter56 = 1'b0;
#0 ap_enable_reg_pp0_iter57 = 1'b0;
#0 ap_enable_reg_pp0_iter58 = 1'b0;
#0 ap_enable_reg_pp0_iter59 = 1'b0;
#0 ap_enable_reg_pp0_iter60 = 1'b0;
#0 ap_enable_reg_pp0_iter61 = 1'b0;
#0 ap_enable_reg_pp0_iter62 = 1'b0;
#0 ap_enable_reg_pp0_iter63 = 1'b0;
#0 ap_enable_reg_pp0_iter64 = 1'b0;
#0 ap_enable_reg_pp0_iter65 = 1'b0;
#0 ap_enable_reg_pp0_iter66 = 1'b0;
#0 ap_enable_reg_pp0_iter67 = 1'b0;
#0 ap_enable_reg_pp0_iter68 = 1'b0;
#0 ap_enable_reg_pp0_iter69 = 1'b0;
#0 ap_enable_reg_pp0_iter70 = 1'b0;
#0 ap_enable_reg_pp0_iter71 = 1'b0;
#0 ap_enable_reg_pp0_iter72 = 1'b0;
#0 ap_enable_reg_pp0_iter73 = 1'b0;
#0 ap_enable_reg_pp0_iter74 = 1'b0;
#0 ap_enable_reg_pp0_iter75 = 1'b0;
#0 ap_enable_reg_pp0_iter76 = 1'b0;
#0 ap_enable_reg_pp0_iter77 = 1'b0;
#0 ap_enable_reg_pp0_iter78 = 1'b0;
#0 ap_enable_reg_pp0_iter79 = 1'b0;
#0 ap_enable_reg_pp0_iter80 = 1'b0;
#0 ap_enable_reg_pp0_iter81 = 1'b0;
#0 ap_enable_reg_pp0_iter82 = 1'b0;
#0 ap_enable_reg_pp0_iter83 = 1'b0;
#0 ap_enable_reg_pp0_iter84 = 1'b0;
#0 ap_enable_reg_pp0_iter85 = 1'b0;
#0 ap_enable_reg_pp0_iter86 = 1'b0;
#0 ap_enable_reg_pp0_iter87 = 1'b0;
#0 ap_enable_reg_pp0_iter88 = 1'b0;
#0 ap_enable_reg_pp0_iter89 = 1'b0;
#0 ap_enable_reg_pp0_iter90 = 1'b0;
#0 ap_enable_reg_pp0_iter91 = 1'b0;
#0 ap_enable_reg_pp0_iter92 = 1'b0;
#0 ap_enable_reg_pp0_iter93 = 1'b0;
#0 ap_enable_reg_pp0_iter94 = 1'b0;
#0 ap_enable_reg_pp0_iter95 = 1'b0;
#0 ap_enable_reg_pp0_iter96 = 1'b0;
#0 ap_enable_reg_pp0_iter97 = 1'b0;
#0 ap_enable_reg_pp0_iter98 = 1'b0;
#0 ap_enable_reg_pp0_iter99 = 1'b0;
#0 ap_enable_reg_pp0_iter100 = 1'b0;
#0 ap_enable_reg_pp0_iter101 = 1'b0;
#0 ap_enable_reg_pp0_iter102 = 1'b0;
#0 ap_enable_reg_pp0_iter103 = 1'b0;
#0 ap_enable_reg_pp0_iter104 = 1'b0;
#0 ap_enable_reg_pp0_iter105 = 1'b0;
#0 ap_enable_reg_pp0_iter106 = 1'b0;
#0 phi_urem461_fu_92 = 8'd0;
#0 phi_mul459_fu_96 = 16'd0;
#0 j_fu_100 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_mul_8ns_10ns_17_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 8 ),
    .din1_WIDTH( 10 ),
    .dout_WIDTH( 17 ))
mul_8ns_10ns_17_1_1_U75(
    .din0(mul_ln128_fu_452_p0),
    .din1(mul_ln128_fu_452_p1),
    .dout(mul_ln128_fu_452_p2)
);

vadd_mul_9ns_11ns_19_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 9 ),
    .din1_WIDTH( 11 ),
    .dout_WIDTH( 19 ))
mul_9ns_11ns_19_1_1_U76(
    .din0(mul_ln129_fu_479_p0),
    .din1(mul_ln129_fu_479_p1),
    .dout(mul_ln129_fu_479_p2)
);

vadd_mul_9ns_11ns_19_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 9 ),
    .din1_WIDTH( 11 ),
    .dout_WIDTH( 19 ))
mul_9ns_11ns_19_1_1_U77(
    .din0(mul_ln130_fu_503_p0),
    .din1(mul_ln130_fu_503_p1),
    .dout(mul_ln130_fu_503_p2)
);

(* dissolve_hierarchy = "yes" *) vadd_sparsemux_11_3_32_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .CASE0( 3'h0 ),
    .din0_WIDTH( 32 ),
    .CASE1( 3'h1 ),
    .din1_WIDTH( 32 ),
    .CASE2( 3'h2 ),
    .din2_WIDTH( 32 ),
    .CASE3( 3'h3 ),
    .din3_WIDTH( 32 ),
    .CASE4( 3'h4 ),
    .din4_WIDTH( 32 ),
    .def_WIDTH( 32 ),
    .sel_WIDTH( 3 ),
    .dout_WIDTH( 32 ))
sparsemux_11_3_32_1_1_U78(
    .din0(gates1_q0),
    .din1(gates1_1_q0),
    .din2(gates1_2_q0),
    .din3(gates1_3_q0),
    .din4(gates1_4_q0),
    .def(tmp_2_fu_581_p11),
    .sel(trunc_ln126_reg_731_pp0_iter2_reg),
    .dout(tmp_2_fu_581_p13)
);

(* dissolve_hierarchy = "yes" *) vadd_sparsemux_11_3_32_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .CASE0( 3'h2 ),
    .din0_WIDTH( 32 ),
    .CASE1( 3'h3 ),
    .din1_WIDTH( 32 ),
    .CASE2( 3'h4 ),
    .din2_WIDTH( 32 ),
    .CASE3( 3'h0 ),
    .din3_WIDTH( 32 ),
    .CASE4( 3'h1 ),
    .din4_WIDTH( 32 ),
    .def_WIDTH( 32 ),
    .sel_WIDTH( 3 ),
    .dout_WIDTH( 32 ))
sparsemux_11_3_32_1_1_U79(
    .din0(gates1_q0),
    .din1(gates1_1_q0),
    .din2(gates1_2_q0),
    .din3(gates1_3_q0),
    .din4(gates1_4_q0),
    .def(tmp_3_fu_608_p11),
    .sel(trunc_ln126_reg_731_pp0_iter2_reg),
    .dout(tmp_3_fu_608_p13)
);

(* dissolve_hierarchy = "yes" *) vadd_sparsemux_11_3_32_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .CASE0( 3'h4 ),
    .din0_WIDTH( 32 ),
    .CASE1( 3'h0 ),
    .din1_WIDTH( 32 ),
    .CASE2( 3'h1 ),
    .din2_WIDTH( 32 ),
    .CASE3( 3'h2 ),
    .din3_WIDTH( 32 ),
    .CASE4( 3'h3 ),
    .din4_WIDTH( 32 ),
    .def_WIDTH( 32 ),
    .sel_WIDTH( 3 ),
    .dout_WIDTH( 32 ))
sparsemux_11_3_32_1_1_U80(
    .din0(gates1_q0),
    .din1(gates1_1_q0),
    .din2(gates1_2_q0),
    .din3(gates1_3_q0),
    .din4(gates1_4_q0),
    .def(tmp_4_fu_635_p11),
    .sel(trunc_ln126_reg_731_pp0_iter2_reg),
    .dout(tmp_4_fu_635_p13)
);

(* dissolve_hierarchy = "yes" *) vadd_sparsemux_11_3_32_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .CASE0( 3'h1 ),
    .din0_WIDTH( 32 ),
    .CASE1( 3'h2 ),
    .din1_WIDTH( 32 ),
    .CASE2( 3'h3 ),
    .din2_WIDTH( 32 ),
    .CASE3( 3'h4 ),
    .din3_WIDTH( 32 ),
    .CASE4( 3'h0 ),
    .din4_WIDTH( 32 ),
    .def_WIDTH( 32 ),
    .sel_WIDTH( 3 ),
    .dout_WIDTH( 32 ))
sparsemux_11_3_32_1_1_U81(
    .din0(gates1_q0),
    .din1(gates1_1_q0),
    .din2(gates1_2_q0),
    .din3(gates1_3_q0),
    .din4(gates1_4_q0),
    .def(tmp_5_fu_662_p11),
    .sel(trunc_ln126_reg_731_pp0_iter2_reg),
    .dout(tmp_5_fu_662_p13)
);

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage0),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_pp0_stage0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage0_subdone) & (ap_loop_exit_ready_pp0_iter105_reg == 1'b1))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if ((1'b1 == ap_condition_exit_pp0_iter0_stage0)) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage0_subdone) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
            ap_enable_reg_pp0_iter1 <= ap_start_int;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter10 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter10 <= ap_enable_reg_pp0_iter9;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter100 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter100 <= ap_enable_reg_pp0_iter99;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter101 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter101 <= ap_enable_reg_pp0_iter100;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter102 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter102 <= ap_enable_reg_pp0_iter101;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter103 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter103 <= ap_enable_reg_pp0_iter102;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter104 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter104 <= ap_enable_reg_pp0_iter103;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter105 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter105 <= ap_enable_reg_pp0_iter104;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter106 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter106 <= ap_enable_reg_pp0_iter105;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter11 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter11 <= ap_enable_reg_pp0_iter10;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter12 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter12 <= ap_enable_reg_pp0_iter11;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter13 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter13 <= ap_enable_reg_pp0_iter12;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter14 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter14 <= ap_enable_reg_pp0_iter13;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter15 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter15 <= ap_enable_reg_pp0_iter14;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter16 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter16 <= ap_enable_reg_pp0_iter15;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter17 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter17 <= ap_enable_reg_pp0_iter16;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter18 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter18 <= ap_enable_reg_pp0_iter17;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter19 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter19 <= ap_enable_reg_pp0_iter18;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter2 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter2 <= ap_enable_reg_pp0_iter1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter20 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter20 <= ap_enable_reg_pp0_iter19;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter21 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter21 <= ap_enable_reg_pp0_iter20;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter22 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter22 <= ap_enable_reg_pp0_iter21;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter23 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter23 <= ap_enable_reg_pp0_iter22;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter24 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter24 <= ap_enable_reg_pp0_iter23;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter25 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter25 <= ap_enable_reg_pp0_iter24;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter26 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter26 <= ap_enable_reg_pp0_iter25;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter27 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter27 <= ap_enable_reg_pp0_iter26;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter28 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter28 <= ap_enable_reg_pp0_iter27;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter29 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter29 <= ap_enable_reg_pp0_iter28;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter3 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter3 <= ap_enable_reg_pp0_iter2;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter30 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter30 <= ap_enable_reg_pp0_iter29;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter31 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter31 <= ap_enable_reg_pp0_iter30;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter32 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter32 <= ap_enable_reg_pp0_iter31;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter33 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter33 <= ap_enable_reg_pp0_iter32;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter34 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter34 <= ap_enable_reg_pp0_iter33;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter35 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter35 <= ap_enable_reg_pp0_iter34;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter36 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter36 <= ap_enable_reg_pp0_iter35;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter37 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter37 <= ap_enable_reg_pp0_iter36;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter38 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter38 <= ap_enable_reg_pp0_iter37;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter39 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter39 <= ap_enable_reg_pp0_iter38;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter4 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter4 <= ap_enable_reg_pp0_iter3;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter40 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter40 <= ap_enable_reg_pp0_iter39;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter41 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter41 <= ap_enable_reg_pp0_iter40;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter42 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter42 <= ap_enable_reg_pp0_iter41;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter43 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter43 <= ap_enable_reg_pp0_iter42;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter44 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter44 <= ap_enable_reg_pp0_iter43;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter45 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter45 <= ap_enable_reg_pp0_iter44;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter46 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter46 <= ap_enable_reg_pp0_iter45;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter47 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter47 <= ap_enable_reg_pp0_iter46;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter48 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter48 <= ap_enable_reg_pp0_iter47;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter49 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter49 <= ap_enable_reg_pp0_iter48;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter5 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter5 <= ap_enable_reg_pp0_iter4;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter50 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter50 <= ap_enable_reg_pp0_iter49;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter51 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter51 <= ap_enable_reg_pp0_iter50;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter52 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter52 <= ap_enable_reg_pp0_iter51;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter53 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter53 <= ap_enable_reg_pp0_iter52;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter54 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter54 <= ap_enable_reg_pp0_iter53;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter55 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter55 <= ap_enable_reg_pp0_iter54;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter56 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter56 <= ap_enable_reg_pp0_iter55;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter57 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter57 <= ap_enable_reg_pp0_iter56;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter58 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter58 <= ap_enable_reg_pp0_iter57;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter59 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter59 <= ap_enable_reg_pp0_iter58;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter6 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter6 <= ap_enable_reg_pp0_iter5;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter60 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter60 <= ap_enable_reg_pp0_iter59;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter61 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter61 <= ap_enable_reg_pp0_iter60;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter62 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter62 <= ap_enable_reg_pp0_iter61;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter63 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter63 <= ap_enable_reg_pp0_iter62;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter64 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter64 <= ap_enable_reg_pp0_iter63;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter65 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter65 <= ap_enable_reg_pp0_iter64;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter66 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter66 <= ap_enable_reg_pp0_iter65;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter67 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter67 <= ap_enable_reg_pp0_iter66;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter68 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter68 <= ap_enable_reg_pp0_iter67;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter69 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter69 <= ap_enable_reg_pp0_iter68;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter7 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter7 <= ap_enable_reg_pp0_iter6;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter70 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter70 <= ap_enable_reg_pp0_iter69;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter71 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter71 <= ap_enable_reg_pp0_iter70;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter72 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter72 <= ap_enable_reg_pp0_iter71;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter73 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter73 <= ap_enable_reg_pp0_iter72;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter74 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter74 <= ap_enable_reg_pp0_iter73;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter75 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter75 <= ap_enable_reg_pp0_iter74;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter76 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter76 <= ap_enable_reg_pp0_iter75;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter77 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter77 <= ap_enable_reg_pp0_iter76;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter78 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter78 <= ap_enable_reg_pp0_iter77;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter79 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter79 <= ap_enable_reg_pp0_iter78;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter8 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter8 <= ap_enable_reg_pp0_iter7;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter80 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter80 <= ap_enable_reg_pp0_iter79;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter81 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter81 <= ap_enable_reg_pp0_iter80;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter82 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter82 <= ap_enable_reg_pp0_iter81;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter83 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter83 <= ap_enable_reg_pp0_iter82;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter84 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter84 <= ap_enable_reg_pp0_iter83;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter85 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter85 <= ap_enable_reg_pp0_iter84;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter86 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter86 <= ap_enable_reg_pp0_iter85;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter87 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter87 <= ap_enable_reg_pp0_iter86;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter88 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter88 <= ap_enable_reg_pp0_iter87;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter89 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter89 <= ap_enable_reg_pp0_iter88;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter9 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter9 <= ap_enable_reg_pp0_iter8;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter90 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter90 <= ap_enable_reg_pp0_iter89;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter91 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter91 <= ap_enable_reg_pp0_iter90;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter92 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter92 <= ap_enable_reg_pp0_iter91;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter93 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter93 <= ap_enable_reg_pp0_iter92;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter94 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter94 <= ap_enable_reg_pp0_iter93;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter95 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter95 <= ap_enable_reg_pp0_iter94;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter96 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter96 <= ap_enable_reg_pp0_iter95;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter97 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter97 <= ap_enable_reg_pp0_iter96;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter98 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter98 <= ap_enable_reg_pp0_iter97;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter99 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter99 <= ap_enable_reg_pp0_iter98;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if (((icmp_ln126_fu_388_p2 == 1'd0) & (ap_enable_reg_pp0_iter0 == 1'b1))) begin
            j_fu_100 <= add_ln126_fu_394_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            j_fu_100 <= 8'd0;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((1'b0 == ap_block_pp0_stage0_11001)) begin
        if (((1'b1 == ap_CS_fsm_pp0_stage0) & (ap_loop_init == 1'b1))) begin
            phi_mul459_fu_96 <= 16'd0;
        end else if ((ap_enable_reg_pp0_iter2 == 1'b1)) begin
            phi_mul459_fu_96 <= add_ln126_2_fu_527_p2;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if ((ap_loop_init == 1'b1)) begin
            phi_urem461_fu_92 <= 8'd0;
        end else if ((ap_enable_reg_pp0_iter1 == 1'b1)) begin
            phi_urem461_fu_92 <= select_ln126_fu_425_p3;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((1'b0 == ap_block_pp0_stage0_11001)) begin
        ap_loop_exit_ready_pp0_iter100_reg <= ap_loop_exit_ready_pp0_iter99_reg;
        ap_loop_exit_ready_pp0_iter101_reg <= ap_loop_exit_ready_pp0_iter100_reg;
        ap_loop_exit_ready_pp0_iter102_reg <= ap_loop_exit_ready_pp0_iter101_reg;
        ap_loop_exit_ready_pp0_iter103_reg <= ap_loop_exit_ready_pp0_iter102_reg;
        ap_loop_exit_ready_pp0_iter104_reg <= ap_loop_exit_ready_pp0_iter103_reg;
        ap_loop_exit_ready_pp0_iter105_reg <= ap_loop_exit_ready_pp0_iter104_reg;
        ap_loop_exit_ready_pp0_iter10_reg <= ap_loop_exit_ready_pp0_iter9_reg;
        ap_loop_exit_ready_pp0_iter11_reg <= ap_loop_exit_ready_pp0_iter10_reg;
        ap_loop_exit_ready_pp0_iter12_reg <= ap_loop_exit_ready_pp0_iter11_reg;
        ap_loop_exit_ready_pp0_iter13_reg <= ap_loop_exit_ready_pp0_iter12_reg;
        ap_loop_exit_ready_pp0_iter14_reg <= ap_loop_exit_ready_pp0_iter13_reg;
        ap_loop_exit_ready_pp0_iter15_reg <= ap_loop_exit_ready_pp0_iter14_reg;
        ap_loop_exit_ready_pp0_iter16_reg <= ap_loop_exit_ready_pp0_iter15_reg;
        ap_loop_exit_ready_pp0_iter17_reg <= ap_loop_exit_ready_pp0_iter16_reg;
        ap_loop_exit_ready_pp0_iter18_reg <= ap_loop_exit_ready_pp0_iter17_reg;
        ap_loop_exit_ready_pp0_iter19_reg <= ap_loop_exit_ready_pp0_iter18_reg;
        ap_loop_exit_ready_pp0_iter20_reg <= ap_loop_exit_ready_pp0_iter19_reg;
        ap_loop_exit_ready_pp0_iter21_reg <= ap_loop_exit_ready_pp0_iter20_reg;
        ap_loop_exit_ready_pp0_iter22_reg <= ap_loop_exit_ready_pp0_iter21_reg;
        ap_loop_exit_ready_pp0_iter23_reg <= ap_loop_exit_ready_pp0_iter22_reg;
        ap_loop_exit_ready_pp0_iter24_reg <= ap_loop_exit_ready_pp0_iter23_reg;
        ap_loop_exit_ready_pp0_iter25_reg <= ap_loop_exit_ready_pp0_iter24_reg;
        ap_loop_exit_ready_pp0_iter26_reg <= ap_loop_exit_ready_pp0_iter25_reg;
        ap_loop_exit_ready_pp0_iter27_reg <= ap_loop_exit_ready_pp0_iter26_reg;
        ap_loop_exit_ready_pp0_iter28_reg <= ap_loop_exit_ready_pp0_iter27_reg;
        ap_loop_exit_ready_pp0_iter29_reg <= ap_loop_exit_ready_pp0_iter28_reg;
        ap_loop_exit_ready_pp0_iter30_reg <= ap_loop_exit_ready_pp0_iter29_reg;
        ap_loop_exit_ready_pp0_iter31_reg <= ap_loop_exit_ready_pp0_iter30_reg;
        ap_loop_exit_ready_pp0_iter32_reg <= ap_loop_exit_ready_pp0_iter31_reg;
        ap_loop_exit_ready_pp0_iter33_reg <= ap_loop_exit_ready_pp0_iter32_reg;
        ap_loop_exit_ready_pp0_iter34_reg <= ap_loop_exit_ready_pp0_iter33_reg;
        ap_loop_exit_ready_pp0_iter35_reg <= ap_loop_exit_ready_pp0_iter34_reg;
        ap_loop_exit_ready_pp0_iter36_reg <= ap_loop_exit_ready_pp0_iter35_reg;
        ap_loop_exit_ready_pp0_iter37_reg <= ap_loop_exit_ready_pp0_iter36_reg;
        ap_loop_exit_ready_pp0_iter38_reg <= ap_loop_exit_ready_pp0_iter37_reg;
        ap_loop_exit_ready_pp0_iter39_reg <= ap_loop_exit_ready_pp0_iter38_reg;
        ap_loop_exit_ready_pp0_iter3_reg <= ap_loop_exit_ready_pp0_iter2_reg;
        ap_loop_exit_ready_pp0_iter40_reg <= ap_loop_exit_ready_pp0_iter39_reg;
        ap_loop_exit_ready_pp0_iter41_reg <= ap_loop_exit_ready_pp0_iter40_reg;
        ap_loop_exit_ready_pp0_iter42_reg <= ap_loop_exit_ready_pp0_iter41_reg;
        ap_loop_exit_ready_pp0_iter43_reg <= ap_loop_exit_ready_pp0_iter42_reg;
        ap_loop_exit_ready_pp0_iter44_reg <= ap_loop_exit_ready_pp0_iter43_reg;
        ap_loop_exit_ready_pp0_iter45_reg <= ap_loop_exit_ready_pp0_iter44_reg;
        ap_loop_exit_ready_pp0_iter46_reg <= ap_loop_exit_ready_pp0_iter45_reg;
        ap_loop_exit_ready_pp0_iter47_reg <= ap_loop_exit_ready_pp0_iter46_reg;
        ap_loop_exit_ready_pp0_iter48_reg <= ap_loop_exit_ready_pp0_iter47_reg;
        ap_loop_exit_ready_pp0_iter49_reg <= ap_loop_exit_ready_pp0_iter48_reg;
        ap_loop_exit_ready_pp0_iter4_reg <= ap_loop_exit_ready_pp0_iter3_reg;
        ap_loop_exit_ready_pp0_iter50_reg <= ap_loop_exit_ready_pp0_iter49_reg;
        ap_loop_exit_ready_pp0_iter51_reg <= ap_loop_exit_ready_pp0_iter50_reg;
        ap_loop_exit_ready_pp0_iter52_reg <= ap_loop_exit_ready_pp0_iter51_reg;
        ap_loop_exit_ready_pp0_iter53_reg <= ap_loop_exit_ready_pp0_iter52_reg;
        ap_loop_exit_ready_pp0_iter54_reg <= ap_loop_exit_ready_pp0_iter53_reg;
        ap_loop_exit_ready_pp0_iter55_reg <= ap_loop_exit_ready_pp0_iter54_reg;
        ap_loop_exit_ready_pp0_iter56_reg <= ap_loop_exit_ready_pp0_iter55_reg;
        ap_loop_exit_ready_pp0_iter57_reg <= ap_loop_exit_ready_pp0_iter56_reg;
        ap_loop_exit_ready_pp0_iter58_reg <= ap_loop_exit_ready_pp0_iter57_reg;
        ap_loop_exit_ready_pp0_iter59_reg <= ap_loop_exit_ready_pp0_iter58_reg;
        ap_loop_exit_ready_pp0_iter5_reg <= ap_loop_exit_ready_pp0_iter4_reg;
        ap_loop_exit_ready_pp0_iter60_reg <= ap_loop_exit_ready_pp0_iter59_reg;
        ap_loop_exit_ready_pp0_iter61_reg <= ap_loop_exit_ready_pp0_iter60_reg;
        ap_loop_exit_ready_pp0_iter62_reg <= ap_loop_exit_ready_pp0_iter61_reg;
        ap_loop_exit_ready_pp0_iter63_reg <= ap_loop_exit_ready_pp0_iter62_reg;
        ap_loop_exit_ready_pp0_iter64_reg <= ap_loop_exit_ready_pp0_iter63_reg;
        ap_loop_exit_ready_pp0_iter65_reg <= ap_loop_exit_ready_pp0_iter64_reg;
        ap_loop_exit_ready_pp0_iter66_reg <= ap_loop_exit_ready_pp0_iter65_reg;
        ap_loop_exit_ready_pp0_iter67_reg <= ap_loop_exit_ready_pp0_iter66_reg;
        ap_loop_exit_ready_pp0_iter68_reg <= ap_loop_exit_ready_pp0_iter67_reg;
        ap_loop_exit_ready_pp0_iter69_reg <= ap_loop_exit_ready_pp0_iter68_reg;
        ap_loop_exit_ready_pp0_iter6_reg <= ap_loop_exit_ready_pp0_iter5_reg;
        ap_loop_exit_ready_pp0_iter70_reg <= ap_loop_exit_ready_pp0_iter69_reg;
        ap_loop_exit_ready_pp0_iter71_reg <= ap_loop_exit_ready_pp0_iter70_reg;
        ap_loop_exit_ready_pp0_iter72_reg <= ap_loop_exit_ready_pp0_iter71_reg;
        ap_loop_exit_ready_pp0_iter73_reg <= ap_loop_exit_ready_pp0_iter72_reg;
        ap_loop_exit_ready_pp0_iter74_reg <= ap_loop_exit_ready_pp0_iter73_reg;
        ap_loop_exit_ready_pp0_iter75_reg <= ap_loop_exit_ready_pp0_iter74_reg;
        ap_loop_exit_ready_pp0_iter76_reg <= ap_loop_exit_ready_pp0_iter75_reg;
        ap_loop_exit_ready_pp0_iter77_reg <= ap_loop_exit_ready_pp0_iter76_reg;
        ap_loop_exit_ready_pp0_iter78_reg <= ap_loop_exit_ready_pp0_iter77_reg;
        ap_loop_exit_ready_pp0_iter79_reg <= ap_loop_exit_ready_pp0_iter78_reg;
        ap_loop_exit_ready_pp0_iter7_reg <= ap_loop_exit_ready_pp0_iter6_reg;
        ap_loop_exit_ready_pp0_iter80_reg <= ap_loop_exit_ready_pp0_iter79_reg;
        ap_loop_exit_ready_pp0_iter81_reg <= ap_loop_exit_ready_pp0_iter80_reg;
        ap_loop_exit_ready_pp0_iter82_reg <= ap_loop_exit_ready_pp0_iter81_reg;
        ap_loop_exit_ready_pp0_iter83_reg <= ap_loop_exit_ready_pp0_iter82_reg;
        ap_loop_exit_ready_pp0_iter84_reg <= ap_loop_exit_ready_pp0_iter83_reg;
        ap_loop_exit_ready_pp0_iter85_reg <= ap_loop_exit_ready_pp0_iter84_reg;
        ap_loop_exit_ready_pp0_iter86_reg <= ap_loop_exit_ready_pp0_iter85_reg;
        ap_loop_exit_ready_pp0_iter87_reg <= ap_loop_exit_ready_pp0_iter86_reg;
        ap_loop_exit_ready_pp0_iter88_reg <= ap_loop_exit_ready_pp0_iter87_reg;
        ap_loop_exit_ready_pp0_iter89_reg <= ap_loop_exit_ready_pp0_iter88_reg;
        ap_loop_exit_ready_pp0_iter8_reg <= ap_loop_exit_ready_pp0_iter7_reg;
        ap_loop_exit_ready_pp0_iter90_reg <= ap_loop_exit_ready_pp0_iter89_reg;
        ap_loop_exit_ready_pp0_iter91_reg <= ap_loop_exit_ready_pp0_iter90_reg;
        ap_loop_exit_ready_pp0_iter92_reg <= ap_loop_exit_ready_pp0_iter91_reg;
        ap_loop_exit_ready_pp0_iter93_reg <= ap_loop_exit_ready_pp0_iter92_reg;
        ap_loop_exit_ready_pp0_iter94_reg <= ap_loop_exit_ready_pp0_iter93_reg;
        ap_loop_exit_ready_pp0_iter95_reg <= ap_loop_exit_ready_pp0_iter94_reg;
        ap_loop_exit_ready_pp0_iter96_reg <= ap_loop_exit_ready_pp0_iter95_reg;
        ap_loop_exit_ready_pp0_iter97_reg <= ap_loop_exit_ready_pp0_iter96_reg;
        ap_loop_exit_ready_pp0_iter98_reg <= ap_loop_exit_ready_pp0_iter97_reg;
        ap_loop_exit_ready_pp0_iter99_reg <= ap_loop_exit_ready_pp0_iter98_reg;
        ap_loop_exit_ready_pp0_iter9_reg <= ap_loop_exit_ready_pp0_iter8_reg;
        c1_addr_reg_725_pp0_iter10_reg <= c1_addr_reg_725_pp0_iter9_reg;
        c1_addr_reg_725_pp0_iter11_reg <= c1_addr_reg_725_pp0_iter10_reg;
        c1_addr_reg_725_pp0_iter12_reg <= c1_addr_reg_725_pp0_iter11_reg;
        c1_addr_reg_725_pp0_iter13_reg <= c1_addr_reg_725_pp0_iter12_reg;
        c1_addr_reg_725_pp0_iter14_reg <= c1_addr_reg_725_pp0_iter13_reg;
        c1_addr_reg_725_pp0_iter15_reg <= c1_addr_reg_725_pp0_iter14_reg;
        c1_addr_reg_725_pp0_iter16_reg <= c1_addr_reg_725_pp0_iter15_reg;
        c1_addr_reg_725_pp0_iter17_reg <= c1_addr_reg_725_pp0_iter16_reg;
        c1_addr_reg_725_pp0_iter18_reg <= c1_addr_reg_725_pp0_iter17_reg;
        c1_addr_reg_725_pp0_iter19_reg <= c1_addr_reg_725_pp0_iter18_reg;
        c1_addr_reg_725_pp0_iter20_reg <= c1_addr_reg_725_pp0_iter19_reg;
        c1_addr_reg_725_pp0_iter21_reg <= c1_addr_reg_725_pp0_iter20_reg;
        c1_addr_reg_725_pp0_iter22_reg <= c1_addr_reg_725_pp0_iter21_reg;
        c1_addr_reg_725_pp0_iter23_reg <= c1_addr_reg_725_pp0_iter22_reg;
        c1_addr_reg_725_pp0_iter24_reg <= c1_addr_reg_725_pp0_iter23_reg;
        c1_addr_reg_725_pp0_iter25_reg <= c1_addr_reg_725_pp0_iter24_reg;
        c1_addr_reg_725_pp0_iter26_reg <= c1_addr_reg_725_pp0_iter25_reg;
        c1_addr_reg_725_pp0_iter27_reg <= c1_addr_reg_725_pp0_iter26_reg;
        c1_addr_reg_725_pp0_iter28_reg <= c1_addr_reg_725_pp0_iter27_reg;
        c1_addr_reg_725_pp0_iter29_reg <= c1_addr_reg_725_pp0_iter28_reg;
        c1_addr_reg_725_pp0_iter2_reg <= c1_addr_reg_725_pp0_iter1_reg;
        c1_addr_reg_725_pp0_iter30_reg <= c1_addr_reg_725_pp0_iter29_reg;
        c1_addr_reg_725_pp0_iter31_reg <= c1_addr_reg_725_pp0_iter30_reg;
        c1_addr_reg_725_pp0_iter32_reg <= c1_addr_reg_725_pp0_iter31_reg;
        c1_addr_reg_725_pp0_iter33_reg <= c1_addr_reg_725_pp0_iter32_reg;
        c1_addr_reg_725_pp0_iter34_reg <= c1_addr_reg_725_pp0_iter33_reg;
        c1_addr_reg_725_pp0_iter35_reg <= c1_addr_reg_725_pp0_iter34_reg;
        c1_addr_reg_725_pp0_iter36_reg <= c1_addr_reg_725_pp0_iter35_reg;
        c1_addr_reg_725_pp0_iter37_reg <= c1_addr_reg_725_pp0_iter36_reg;
        c1_addr_reg_725_pp0_iter38_reg <= c1_addr_reg_725_pp0_iter37_reg;
        c1_addr_reg_725_pp0_iter39_reg <= c1_addr_reg_725_pp0_iter38_reg;
        c1_addr_reg_725_pp0_iter3_reg <= c1_addr_reg_725_pp0_iter2_reg;
        c1_addr_reg_725_pp0_iter40_reg <= c1_addr_reg_725_pp0_iter39_reg;
        c1_addr_reg_725_pp0_iter41_reg <= c1_addr_reg_725_pp0_iter40_reg;
        c1_addr_reg_725_pp0_iter42_reg <= c1_addr_reg_725_pp0_iter41_reg;
        c1_addr_reg_725_pp0_iter43_reg <= c1_addr_reg_725_pp0_iter42_reg;
        c1_addr_reg_725_pp0_iter44_reg <= c1_addr_reg_725_pp0_iter43_reg;
        c1_addr_reg_725_pp0_iter45_reg <= c1_addr_reg_725_pp0_iter44_reg;
        c1_addr_reg_725_pp0_iter46_reg <= c1_addr_reg_725_pp0_iter45_reg;
        c1_addr_reg_725_pp0_iter47_reg <= c1_addr_reg_725_pp0_iter46_reg;
        c1_addr_reg_725_pp0_iter48_reg <= c1_addr_reg_725_pp0_iter47_reg;
        c1_addr_reg_725_pp0_iter49_reg <= c1_addr_reg_725_pp0_iter48_reg;
        c1_addr_reg_725_pp0_iter4_reg <= c1_addr_reg_725_pp0_iter3_reg;
        c1_addr_reg_725_pp0_iter50_reg <= c1_addr_reg_725_pp0_iter49_reg;
        c1_addr_reg_725_pp0_iter51_reg <= c1_addr_reg_725_pp0_iter50_reg;
        c1_addr_reg_725_pp0_iter52_reg <= c1_addr_reg_725_pp0_iter51_reg;
        c1_addr_reg_725_pp0_iter53_reg <= c1_addr_reg_725_pp0_iter52_reg;
        c1_addr_reg_725_pp0_iter54_reg <= c1_addr_reg_725_pp0_iter53_reg;
        c1_addr_reg_725_pp0_iter55_reg <= c1_addr_reg_725_pp0_iter54_reg;
        c1_addr_reg_725_pp0_iter56_reg <= c1_addr_reg_725_pp0_iter55_reg;
        c1_addr_reg_725_pp0_iter57_reg <= c1_addr_reg_725_pp0_iter56_reg;
        c1_addr_reg_725_pp0_iter58_reg <= c1_addr_reg_725_pp0_iter57_reg;
        c1_addr_reg_725_pp0_iter59_reg <= c1_addr_reg_725_pp0_iter58_reg;
        c1_addr_reg_725_pp0_iter5_reg <= c1_addr_reg_725_pp0_iter4_reg;
        c1_addr_reg_725_pp0_iter6_reg <= c1_addr_reg_725_pp0_iter5_reg;
        c1_addr_reg_725_pp0_iter7_reg <= c1_addr_reg_725_pp0_iter6_reg;
        c1_addr_reg_725_pp0_iter8_reg <= c1_addr_reg_725_pp0_iter7_reg;
        c1_addr_reg_725_pp0_iter9_reg <= c1_addr_reg_725_pp0_iter8_reg;
        c1_load_reg_754_pp0_iter10_reg <= c1_load_reg_754_pp0_iter9_reg;
        c1_load_reg_754_pp0_iter11_reg <= c1_load_reg_754_pp0_iter10_reg;
        c1_load_reg_754_pp0_iter12_reg <= c1_load_reg_754_pp0_iter11_reg;
        c1_load_reg_754_pp0_iter13_reg <= c1_load_reg_754_pp0_iter12_reg;
        c1_load_reg_754_pp0_iter14_reg <= c1_load_reg_754_pp0_iter13_reg;
        c1_load_reg_754_pp0_iter15_reg <= c1_load_reg_754_pp0_iter14_reg;
        c1_load_reg_754_pp0_iter16_reg <= c1_load_reg_754_pp0_iter15_reg;
        c1_load_reg_754_pp0_iter17_reg <= c1_load_reg_754_pp0_iter16_reg;
        c1_load_reg_754_pp0_iter18_reg <= c1_load_reg_754_pp0_iter17_reg;
        c1_load_reg_754_pp0_iter19_reg <= c1_load_reg_754_pp0_iter18_reg;
        c1_load_reg_754_pp0_iter20_reg <= c1_load_reg_754_pp0_iter19_reg;
        c1_load_reg_754_pp0_iter21_reg <= c1_load_reg_754_pp0_iter20_reg;
        c1_load_reg_754_pp0_iter22_reg <= c1_load_reg_754_pp0_iter21_reg;
        c1_load_reg_754_pp0_iter23_reg <= c1_load_reg_754_pp0_iter22_reg;
        c1_load_reg_754_pp0_iter24_reg <= c1_load_reg_754_pp0_iter23_reg;
        c1_load_reg_754_pp0_iter2_reg <= c1_load_reg_754;
        c1_load_reg_754_pp0_iter3_reg <= c1_load_reg_754_pp0_iter2_reg;
        c1_load_reg_754_pp0_iter4_reg <= c1_load_reg_754_pp0_iter3_reg;
        c1_load_reg_754_pp0_iter5_reg <= c1_load_reg_754_pp0_iter4_reg;
        c1_load_reg_754_pp0_iter6_reg <= c1_load_reg_754_pp0_iter5_reg;
        c1_load_reg_754_pp0_iter7_reg <= c1_load_reg_754_pp0_iter6_reg;
        c1_load_reg_754_pp0_iter8_reg <= c1_load_reg_754_pp0_iter7_reg;
        c1_load_reg_754_pp0_iter9_reg <= c1_load_reg_754_pp0_iter8_reg;
        c1_new_reg_909 <= grp_fu_726_p_dout0;
        f_gate_reg_884 <= grp_sigmoid_fu_1749_p_dout0;
        g_gate_reg_899 <= grp_tanh_approx_fu_1759_p_dout0;
        i_gate_reg_879 <= grp_sigmoid_fu_1744_p_dout0;
        i_gate_reg_879_pp0_iter25_reg <= i_gate_reg_879;
        i_gate_reg_879_pp0_iter26_reg <= i_gate_reg_879_pp0_iter25_reg;
        i_gate_reg_879_pp0_iter27_reg <= i_gate_reg_879_pp0_iter26_reg;
        i_gate_reg_879_pp0_iter28_reg <= i_gate_reg_879_pp0_iter27_reg;
        i_gate_reg_879_pp0_iter29_reg <= i_gate_reg_879_pp0_iter28_reg;
        i_gate_reg_879_pp0_iter30_reg <= i_gate_reg_879_pp0_iter29_reg;
        i_gate_reg_879_pp0_iter31_reg <= i_gate_reg_879_pp0_iter30_reg;
        i_gate_reg_879_pp0_iter32_reg <= i_gate_reg_879_pp0_iter31_reg;
        i_gate_reg_879_pp0_iter33_reg <= i_gate_reg_879_pp0_iter32_reg;
        i_gate_reg_879_pp0_iter34_reg <= i_gate_reg_879_pp0_iter33_reg;
        i_gate_reg_879_pp0_iter35_reg <= i_gate_reg_879_pp0_iter34_reg;
        i_gate_reg_879_pp0_iter36_reg <= i_gate_reg_879_pp0_iter35_reg;
        i_gate_reg_879_pp0_iter37_reg <= i_gate_reg_879_pp0_iter36_reg;
        i_gate_reg_879_pp0_iter38_reg <= i_gate_reg_879_pp0_iter37_reg;
        i_gate_reg_879_pp0_iter39_reg <= i_gate_reg_879_pp0_iter38_reg;
        i_gate_reg_879_pp0_iter40_reg <= i_gate_reg_879_pp0_iter39_reg;
        i_gate_reg_879_pp0_iter41_reg <= i_gate_reg_879_pp0_iter40_reg;
        i_gate_reg_879_pp0_iter42_reg <= i_gate_reg_879_pp0_iter41_reg;
        i_gate_reg_879_pp0_iter43_reg <= i_gate_reg_879_pp0_iter42_reg;
        i_gate_reg_879_pp0_iter44_reg <= i_gate_reg_879_pp0_iter43_reg;
        mul5_reg_894 <= grp_fu_1732_p_dout0;
        mul5_reg_894_pp0_iter30_reg <= mul5_reg_894;
        mul5_reg_894_pp0_iter31_reg <= mul5_reg_894_pp0_iter30_reg;
        mul5_reg_894_pp0_iter32_reg <= mul5_reg_894_pp0_iter31_reg;
        mul5_reg_894_pp0_iter33_reg <= mul5_reg_894_pp0_iter32_reg;
        mul5_reg_894_pp0_iter34_reg <= mul5_reg_894_pp0_iter33_reg;
        mul5_reg_894_pp0_iter35_reg <= mul5_reg_894_pp0_iter34_reg;
        mul5_reg_894_pp0_iter36_reg <= mul5_reg_894_pp0_iter35_reg;
        mul5_reg_894_pp0_iter37_reg <= mul5_reg_894_pp0_iter36_reg;
        mul5_reg_894_pp0_iter38_reg <= mul5_reg_894_pp0_iter37_reg;
        mul5_reg_894_pp0_iter39_reg <= mul5_reg_894_pp0_iter38_reg;
        mul5_reg_894_pp0_iter40_reg <= mul5_reg_894_pp0_iter39_reg;
        mul5_reg_894_pp0_iter41_reg <= mul5_reg_894_pp0_iter40_reg;
        mul5_reg_894_pp0_iter42_reg <= mul5_reg_894_pp0_iter41_reg;
        mul5_reg_894_pp0_iter43_reg <= mul5_reg_894_pp0_iter42_reg;
        mul5_reg_894_pp0_iter44_reg <= mul5_reg_894_pp0_iter43_reg;
        mul5_reg_894_pp0_iter45_reg <= mul5_reg_894_pp0_iter44_reg;
        mul5_reg_894_pp0_iter46_reg <= mul5_reg_894_pp0_iter45_reg;
        mul5_reg_894_pp0_iter47_reg <= mul5_reg_894_pp0_iter46_reg;
        mul5_reg_894_pp0_iter48_reg <= mul5_reg_894_pp0_iter47_reg;
        mul5_reg_894_pp0_iter49_reg <= mul5_reg_894_pp0_iter48_reg;
        mul6_reg_904 <= grp_fu_1736_p_dout0;
        mul7_reg_920 <= grp_fu_1740_p_dout0;
        o_gate_reg_889 <= grp_sigmoid_fu_1754_p_dout0;
        o_gate_reg_889_pp0_iter100_reg <= o_gate_reg_889_pp0_iter99_reg;
        o_gate_reg_889_pp0_iter25_reg <= o_gate_reg_889;
        o_gate_reg_889_pp0_iter26_reg <= o_gate_reg_889_pp0_iter25_reg;
        o_gate_reg_889_pp0_iter27_reg <= o_gate_reg_889_pp0_iter26_reg;
        o_gate_reg_889_pp0_iter28_reg <= o_gate_reg_889_pp0_iter27_reg;
        o_gate_reg_889_pp0_iter29_reg <= o_gate_reg_889_pp0_iter28_reg;
        o_gate_reg_889_pp0_iter30_reg <= o_gate_reg_889_pp0_iter29_reg;
        o_gate_reg_889_pp0_iter31_reg <= o_gate_reg_889_pp0_iter30_reg;
        o_gate_reg_889_pp0_iter32_reg <= o_gate_reg_889_pp0_iter31_reg;
        o_gate_reg_889_pp0_iter33_reg <= o_gate_reg_889_pp0_iter32_reg;
        o_gate_reg_889_pp0_iter34_reg <= o_gate_reg_889_pp0_iter33_reg;
        o_gate_reg_889_pp0_iter35_reg <= o_gate_reg_889_pp0_iter34_reg;
        o_gate_reg_889_pp0_iter36_reg <= o_gate_reg_889_pp0_iter35_reg;
        o_gate_reg_889_pp0_iter37_reg <= o_gate_reg_889_pp0_iter36_reg;
        o_gate_reg_889_pp0_iter38_reg <= o_gate_reg_889_pp0_iter37_reg;
        o_gate_reg_889_pp0_iter39_reg <= o_gate_reg_889_pp0_iter38_reg;
        o_gate_reg_889_pp0_iter40_reg <= o_gate_reg_889_pp0_iter39_reg;
        o_gate_reg_889_pp0_iter41_reg <= o_gate_reg_889_pp0_iter40_reg;
        o_gate_reg_889_pp0_iter42_reg <= o_gate_reg_889_pp0_iter41_reg;
        o_gate_reg_889_pp0_iter43_reg <= o_gate_reg_889_pp0_iter42_reg;
        o_gate_reg_889_pp0_iter44_reg <= o_gate_reg_889_pp0_iter43_reg;
        o_gate_reg_889_pp0_iter45_reg <= o_gate_reg_889_pp0_iter44_reg;
        o_gate_reg_889_pp0_iter46_reg <= o_gate_reg_889_pp0_iter45_reg;
        o_gate_reg_889_pp0_iter47_reg <= o_gate_reg_889_pp0_iter46_reg;
        o_gate_reg_889_pp0_iter48_reg <= o_gate_reg_889_pp0_iter47_reg;
        o_gate_reg_889_pp0_iter49_reg <= o_gate_reg_889_pp0_iter48_reg;
        o_gate_reg_889_pp0_iter50_reg <= o_gate_reg_889_pp0_iter49_reg;
        o_gate_reg_889_pp0_iter51_reg <= o_gate_reg_889_pp0_iter50_reg;
        o_gate_reg_889_pp0_iter52_reg <= o_gate_reg_889_pp0_iter51_reg;
        o_gate_reg_889_pp0_iter53_reg <= o_gate_reg_889_pp0_iter52_reg;
        o_gate_reg_889_pp0_iter54_reg <= o_gate_reg_889_pp0_iter53_reg;
        o_gate_reg_889_pp0_iter55_reg <= o_gate_reg_889_pp0_iter54_reg;
        o_gate_reg_889_pp0_iter56_reg <= o_gate_reg_889_pp0_iter55_reg;
        o_gate_reg_889_pp0_iter57_reg <= o_gate_reg_889_pp0_iter56_reg;
        o_gate_reg_889_pp0_iter58_reg <= o_gate_reg_889_pp0_iter57_reg;
        o_gate_reg_889_pp0_iter59_reg <= o_gate_reg_889_pp0_iter58_reg;
        o_gate_reg_889_pp0_iter60_reg <= o_gate_reg_889_pp0_iter59_reg;
        o_gate_reg_889_pp0_iter61_reg <= o_gate_reg_889_pp0_iter60_reg;
        o_gate_reg_889_pp0_iter62_reg <= o_gate_reg_889_pp0_iter61_reg;
        o_gate_reg_889_pp0_iter63_reg <= o_gate_reg_889_pp0_iter62_reg;
        o_gate_reg_889_pp0_iter64_reg <= o_gate_reg_889_pp0_iter63_reg;
        o_gate_reg_889_pp0_iter65_reg <= o_gate_reg_889_pp0_iter64_reg;
        o_gate_reg_889_pp0_iter66_reg <= o_gate_reg_889_pp0_iter65_reg;
        o_gate_reg_889_pp0_iter67_reg <= o_gate_reg_889_pp0_iter66_reg;
        o_gate_reg_889_pp0_iter68_reg <= o_gate_reg_889_pp0_iter67_reg;
        o_gate_reg_889_pp0_iter69_reg <= o_gate_reg_889_pp0_iter68_reg;
        o_gate_reg_889_pp0_iter70_reg <= o_gate_reg_889_pp0_iter69_reg;
        o_gate_reg_889_pp0_iter71_reg <= o_gate_reg_889_pp0_iter70_reg;
        o_gate_reg_889_pp0_iter72_reg <= o_gate_reg_889_pp0_iter71_reg;
        o_gate_reg_889_pp0_iter73_reg <= o_gate_reg_889_pp0_iter72_reg;
        o_gate_reg_889_pp0_iter74_reg <= o_gate_reg_889_pp0_iter73_reg;
        o_gate_reg_889_pp0_iter75_reg <= o_gate_reg_889_pp0_iter74_reg;
        o_gate_reg_889_pp0_iter76_reg <= o_gate_reg_889_pp0_iter75_reg;
        o_gate_reg_889_pp0_iter77_reg <= o_gate_reg_889_pp0_iter76_reg;
        o_gate_reg_889_pp0_iter78_reg <= o_gate_reg_889_pp0_iter77_reg;
        o_gate_reg_889_pp0_iter79_reg <= o_gate_reg_889_pp0_iter78_reg;
        o_gate_reg_889_pp0_iter80_reg <= o_gate_reg_889_pp0_iter79_reg;
        o_gate_reg_889_pp0_iter81_reg <= o_gate_reg_889_pp0_iter80_reg;
        o_gate_reg_889_pp0_iter82_reg <= o_gate_reg_889_pp0_iter81_reg;
        o_gate_reg_889_pp0_iter83_reg <= o_gate_reg_889_pp0_iter82_reg;
        o_gate_reg_889_pp0_iter84_reg <= o_gate_reg_889_pp0_iter83_reg;
        o_gate_reg_889_pp0_iter85_reg <= o_gate_reg_889_pp0_iter84_reg;
        o_gate_reg_889_pp0_iter86_reg <= o_gate_reg_889_pp0_iter85_reg;
        o_gate_reg_889_pp0_iter87_reg <= o_gate_reg_889_pp0_iter86_reg;
        o_gate_reg_889_pp0_iter88_reg <= o_gate_reg_889_pp0_iter87_reg;
        o_gate_reg_889_pp0_iter89_reg <= o_gate_reg_889_pp0_iter88_reg;
        o_gate_reg_889_pp0_iter90_reg <= o_gate_reg_889_pp0_iter89_reg;
        o_gate_reg_889_pp0_iter91_reg <= o_gate_reg_889_pp0_iter90_reg;
        o_gate_reg_889_pp0_iter92_reg <= o_gate_reg_889_pp0_iter91_reg;
        o_gate_reg_889_pp0_iter93_reg <= o_gate_reg_889_pp0_iter92_reg;
        o_gate_reg_889_pp0_iter94_reg <= o_gate_reg_889_pp0_iter93_reg;
        o_gate_reg_889_pp0_iter95_reg <= o_gate_reg_889_pp0_iter94_reg;
        o_gate_reg_889_pp0_iter96_reg <= o_gate_reg_889_pp0_iter95_reg;
        o_gate_reg_889_pp0_iter97_reg <= o_gate_reg_889_pp0_iter96_reg;
        o_gate_reg_889_pp0_iter98_reg <= o_gate_reg_889_pp0_iter97_reg;
        o_gate_reg_889_pp0_iter99_reg <= o_gate_reg_889_pp0_iter98_reg;
        tmp_2_reg_859 <= tmp_2_fu_581_p13;
        tmp_3_reg_864 <= tmp_3_fu_608_p13;
        tmp_4_reg_869 <= tmp_4_fu_635_p13;
        tmp_5_reg_874 <= tmp_5_fu_662_p13;
        tmp_7_reg_915 <= grp_tanh_approx_fu_1764_p_dout0;
        trunc_ln126_reg_731_pp0_iter2_reg <= trunc_ln126_reg_731;
        zext_ln126_reg_720_pp0_iter100_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter99_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter101_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter100_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter102_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter101_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter103_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter102_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter104_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter103_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter105_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter104_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter10_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter9_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter11_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter10_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter12_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter11_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter13_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter12_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter14_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter13_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter15_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter14_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter16_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter15_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter17_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter16_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter18_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter17_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter19_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter18_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter20_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter19_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter21_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter20_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter22_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter21_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter23_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter22_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter24_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter23_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter25_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter24_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter26_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter25_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter27_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter26_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter28_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter27_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter29_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter28_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter2_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter1_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter30_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter29_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter31_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter30_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter32_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter31_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter33_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter32_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter34_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter33_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter35_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter34_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter36_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter35_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter37_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter36_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter38_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter37_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter39_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter38_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter3_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter2_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter40_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter39_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter41_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter40_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter42_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter41_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter43_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter42_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter44_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter43_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter45_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter44_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter46_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter45_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter47_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter46_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter48_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter47_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter49_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter48_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter4_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter3_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter50_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter49_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter51_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter50_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter52_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter51_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter53_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter52_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter54_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter53_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter55_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter54_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter56_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter55_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter57_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter56_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter58_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter57_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter59_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter58_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter5_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter4_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter60_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter59_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter61_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter60_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter62_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter61_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter63_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter62_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter64_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter63_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter65_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter64_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter66_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter65_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter67_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter66_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter68_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter67_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter69_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter68_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter6_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter5_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter70_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter69_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter71_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter70_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter72_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter71_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter73_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter72_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter74_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter73_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter75_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter74_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter76_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter75_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter77_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter76_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter78_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter77_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter79_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter78_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter7_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter6_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter80_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter79_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter81_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter80_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter82_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter81_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter83_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter82_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter84_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter83_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter85_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter84_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter86_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter85_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter87_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter86_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter88_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter87_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter89_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter88_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter8_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter7_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter90_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter89_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter91_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter90_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter92_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter91_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter93_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter92_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter94_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter93_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter95_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter94_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter96_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter95_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter97_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter96_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter98_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter97_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter99_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter98_reg[7 : 0];
        zext_ln126_reg_720_pp0_iter9_reg[7 : 0] <= zext_ln126_reg_720_pp0_iter8_reg[7 : 0];
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_loop_exit_ready_pp0_iter1_reg <= ap_loop_exit_ready;
        ap_loop_exit_ready_pp0_iter2_reg <= ap_loop_exit_ready_pp0_iter1_reg;
        c1_addr_reg_725 <= zext_ln126_fu_400_p1;
        c1_addr_reg_725_pp0_iter1_reg <= c1_addr_reg_725;
        j_3_reg_710 <= ap_sig_allocacmp_j_3;
        tmp_16_reg_739 <= {{mul_ln128_fu_452_p2[16:11]}};
        tmp_17_reg_744 <= {{mul_ln129_fu_479_p2[18:12]}};
        tmp_18_reg_749 <= {{mul_ln130_fu_503_p2[18:12]}};
        trunc_ln126_reg_731 <= trunc_ln126_fu_433_p1;
        zext_ln126_reg_720[7 : 0] <= zext_ln126_fu_400_p1[7 : 0];
        zext_ln126_reg_720_pp0_iter1_reg[7 : 0] <= zext_ln126_reg_720[7 : 0];
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        c1_load_reg_754 <= c1_q1;
    end
end

always @ (*) begin
    if (((icmp_ln126_fu_388_p2 == 1'd1) & (1'b0 == ap_block_pp0_stage0_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_subdone) & (ap_loop_exit_ready_pp0_iter105_reg == 1'b1))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if (((ap_idle_pp0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (ap_start_int == 1'b0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter26 == 1'b0) & (ap_enable_reg_pp0_iter25 == 1'b0) & (ap_enable_reg_pp0_iter24 == 1'b0) & (ap_enable_reg_pp0_iter23 == 1'b0) & (ap_enable_reg_pp0_iter22 == 1'b0) & (ap_enable_reg_pp0_iter21 == 1'b0) & (ap_enable_reg_pp0_iter20 == 1'b0) & (ap_enable_reg_pp0_iter19 == 1'b0) & (ap_enable_reg_pp0_iter18 == 1'b0) & (ap_enable_reg_pp0_iter17 == 1'b0) & (ap_enable_reg_pp0_iter16 == 1'b0) & (ap_enable_reg_pp0_iter15 == 1'b0) & (ap_enable_reg_pp0_iter14 == 1'b0) & (ap_enable_reg_pp0_iter13 == 1'b0) & (ap_enable_reg_pp0_iter12 == 1'b0) & (ap_enable_reg_pp0_iter11 == 1'b0) & (ap_enable_reg_pp0_iter10 == 1'b0) & (ap_enable_reg_pp0_iter9 == 1'b0) & (ap_enable_reg_pp0_iter8 == 1'b0) & (ap_enable_reg_pp0_iter7 == 1'b0) & (ap_enable_reg_pp0_iter6 == 1'b0) & (ap_enable_reg_pp0_iter5 == 1'b0) & (ap_enable_reg_pp0_iter106 == 1'b0) & (ap_enable_reg_pp0_iter105 == 1'b0) & (ap_enable_reg_pp0_iter104 == 1'b0) & (ap_enable_reg_pp0_iter103 == 1'b0) & (ap_enable_reg_pp0_iter102 == 1'b0) & (ap_enable_reg_pp0_iter101 
    == 1'b0) & (ap_enable_reg_pp0_iter4 == 1'b0) & (ap_enable_reg_pp0_iter100 == 1'b0) & (ap_enable_reg_pp0_iter99 == 1'b0) & (ap_enable_reg_pp0_iter98 == 1'b0) & (ap_enable_reg_pp0_iter97 == 1'b0) & (ap_enable_reg_pp0_iter96 == 1'b0) & (ap_enable_reg_pp0_iter95 == 1'b0) & (ap_enable_reg_pp0_iter94 == 1'b0) & (ap_enable_reg_pp0_iter93 == 1'b0) & (ap_enable_reg_pp0_iter92 == 1'b0) & (ap_enable_reg_pp0_iter91 == 1'b0) & (ap_enable_reg_pp0_iter3 == 1'b0) & (ap_enable_reg_pp0_iter90 == 1'b0) & (ap_enable_reg_pp0_iter89 == 1'b0) & (ap_enable_reg_pp0_iter88 == 1'b0) & (ap_enable_reg_pp0_iter87 == 1'b0) & (ap_enable_reg_pp0_iter86 == 1'b0) & (ap_enable_reg_pp0_iter85 == 1'b0) & (ap_enable_reg_pp0_iter84 == 1'b0) & (ap_enable_reg_pp0_iter83 == 1'b0) & (ap_enable_reg_pp0_iter82 == 1'b0) & (ap_enable_reg_pp0_iter81 == 1'b0) & (ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter80 == 1'b0) & (ap_enable_reg_pp0_iter79 == 1'b0) & (ap_enable_reg_pp0_iter78 == 1'b0) & (ap_enable_reg_pp0_iter77 == 1'b0) & (ap_enable_reg_pp0_iter76 
    == 1'b0) & (ap_enable_reg_pp0_iter75 == 1'b0) & (ap_enable_reg_pp0_iter74 == 1'b0) & (ap_enable_reg_pp0_iter73 == 1'b0) & (ap_enable_reg_pp0_iter72 == 1'b0) & (ap_enable_reg_pp0_iter71 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter70 == 1'b0) & (ap_enable_reg_pp0_iter69 == 1'b0) & (ap_enable_reg_pp0_iter68 == 1'b0) & (ap_enable_reg_pp0_iter67 == 1'b0) & (ap_enable_reg_pp0_iter66 == 1'b0) & (ap_enable_reg_pp0_iter65 == 1'b0) & (ap_enable_reg_pp0_iter64 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0) & (ap_enable_reg_pp0_iter63 == 1'b0) & (ap_enable_reg_pp0_iter62 == 1'b0) & (ap_enable_reg_pp0_iter61 == 1'b0) & (ap_enable_reg_pp0_iter60 == 1'b0) & (ap_enable_reg_pp0_iter59 == 1'b0) & (ap_enable_reg_pp0_iter58 == 1'b0) & (ap_enable_reg_pp0_iter57 == 1'b0) & (ap_enable_reg_pp0_iter56 == 1'b0) & (ap_enable_reg_pp0_iter55 == 1'b0) & (ap_enable_reg_pp0_iter54 == 1'b0) & (ap_enable_reg_pp0_iter53 == 1'b0) & (ap_enable_reg_pp0_iter52 == 1'b0) & (ap_enable_reg_pp0_iter51 == 1'b0) & (ap_enable_reg_pp0_iter50 
    == 1'b0) & (ap_enable_reg_pp0_iter49 == 1'b0) & (ap_enable_reg_pp0_iter48 == 1'b0) & (ap_enable_reg_pp0_iter47 == 1'b0) & (ap_enable_reg_pp0_iter46 == 1'b0) & (ap_enable_reg_pp0_iter45 == 1'b0) & (ap_enable_reg_pp0_iter44 == 1'b0) & (ap_enable_reg_pp0_iter43 == 1'b0) & (ap_enable_reg_pp0_iter42 == 1'b0) & (ap_enable_reg_pp0_iter41 == 1'b0) & (ap_enable_reg_pp0_iter40 == 1'b0) & (ap_enable_reg_pp0_iter39 == 1'b0) & (ap_enable_reg_pp0_iter38 == 1'b0) & (ap_enable_reg_pp0_iter37 == 1'b0) & (ap_enable_reg_pp0_iter36 == 1'b0) & (ap_enable_reg_pp0_iter35 == 1'b0) & (ap_enable_reg_pp0_iter34 == 1'b0) & (ap_enable_reg_pp0_iter33 == 1'b0) & (ap_enable_reg_pp0_iter32 == 1'b0) & (ap_enable_reg_pp0_iter31 == 1'b0) & (ap_enable_reg_pp0_iter30 == 1'b0) & (ap_enable_reg_pp0_iter29 == 1'b0) & (ap_enable_reg_pp0_iter28 == 1'b0) & (ap_enable_reg_pp0_iter27 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (1'b1 == ap_CS_fsm_pp0_stage0) & (ap_loop_init == 1'b1))) begin
        ap_sig_allocacmp_j_3 = 8'd0;
    end else begin
        ap_sig_allocacmp_j_3 = j_fu_100;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter60 == 1'b1))) begin
        c1_ce0_local = 1'b1;
    end else begin
        c1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        c1_ce1_local = 1'b1;
    end else begin
        c1_ce1_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter60 == 1'b1))) begin
        c1_we0_local = 1'b1;
    end else begin
        c1_we0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1))) begin
        if ((trunc_ln126_reg_731 == 3'd2)) begin
            gates1_1_address0_local = zext_ln130_fu_568_p1;
        end else if ((trunc_ln126_reg_731 == 3'd0)) begin
            gates1_1_address0_local = zext_ln129_fu_560_p1;
        end else if ((trunc_ln126_reg_731 == 3'd3)) begin
            gates1_1_address0_local = zext_ln128_fu_552_p1;
        end else if ((trunc_ln126_reg_731 == 3'd1)) begin
            gates1_1_address0_local = zext_ln126_1_fu_543_p1;
        end else begin
            gates1_1_address0_local = 'bx;
        end
    end else begin
        gates1_1_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((((trunc_ln126_reg_731 == 3'd3) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd2) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd1) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)))) begin
        gates1_1_ce0_local = 1'b1;
    end else begin
        gates1_1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1))) begin
        if ((trunc_ln126_reg_731 == 3'd3)) begin
            gates1_2_address0_local = zext_ln130_fu_568_p1;
        end else if ((trunc_ln126_reg_731 == 3'd1)) begin
            gates1_2_address0_local = zext_ln129_fu_560_p1;
        end else if ((trunc_ln126_reg_731 == 3'd4)) begin
            gates1_2_address0_local = zext_ln128_fu_552_p1;
        end else if ((trunc_ln126_reg_731 == 3'd2)) begin
            gates1_2_address0_local = zext_ln126_1_fu_543_p1;
        end else begin
            gates1_2_address0_local = 'bx;
        end
    end else begin
        gates1_2_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((((trunc_ln126_reg_731 == 3'd4) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd3) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd2) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd1) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)))) begin
        gates1_2_ce0_local = 1'b1;
    end else begin
        gates1_2_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1))) begin
        if ((trunc_ln126_reg_731 == 3'd4)) begin
            gates1_3_address0_local = zext_ln130_fu_568_p1;
        end else if ((trunc_ln126_reg_731 == 3'd2)) begin
            gates1_3_address0_local = zext_ln129_fu_560_p1;
        end else if ((trunc_ln126_reg_731 == 3'd0)) begin
            gates1_3_address0_local = zext_ln128_fu_552_p1;
        end else if ((trunc_ln126_reg_731 == 3'd3)) begin
            gates1_3_address0_local = zext_ln126_1_fu_543_p1;
        end else begin
            gates1_3_address0_local = 'bx;
        end
    end else begin
        gates1_3_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((((trunc_ln126_reg_731 == 3'd4) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd3) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd2) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)))) begin
        gates1_3_ce0_local = 1'b1;
    end else begin
        gates1_3_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1))) begin
        if ((trunc_ln126_reg_731 == 3'd0)) begin
            gates1_4_address0_local = zext_ln130_fu_568_p1;
        end else if ((trunc_ln126_reg_731 == 3'd3)) begin
            gates1_4_address0_local = zext_ln129_fu_560_p1;
        end else if ((trunc_ln126_reg_731 == 3'd1)) begin
            gates1_4_address0_local = zext_ln128_fu_552_p1;
        end else if ((trunc_ln126_reg_731 == 3'd4)) begin
            gates1_4_address0_local = zext_ln126_1_fu_543_p1;
        end else begin
            gates1_4_address0_local = 'bx;
        end
    end else begin
        gates1_4_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((((trunc_ln126_reg_731 == 3'd4) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd3) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd1) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)))) begin
        gates1_4_ce0_local = 1'b1;
    end else begin
        gates1_4_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1))) begin
        if ((trunc_ln126_reg_731 == 3'd1)) begin
            gates1_address0_local = zext_ln130_fu_568_p1;
        end else if ((trunc_ln126_reg_731 == 3'd4)) begin
            gates1_address0_local = zext_ln129_fu_560_p1;
        end else if ((trunc_ln126_reg_731 == 3'd2)) begin
            gates1_address0_local = zext_ln128_fu_552_p1;
        end else if ((trunc_ln126_reg_731 == 3'd0)) begin
            gates1_address0_local = zext_ln126_1_fu_543_p1;
        end else begin
            gates1_address0_local = 'bx;
        end
    end else begin
        gates1_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((((trunc_ln126_reg_731 == 3'd4) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd2) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd1) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln126_reg_731 == 3'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)))) begin
        gates1_ce0_local = 1'b1;
    end else begin
        gates1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter106 == 1'b1))) begin
        h1_ce0_local = 1'b1;
    end else begin
        h1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter106 == 1'b1))) begin
        h1_we0_local = 1'b1;
    end else begin
        h1_we0_local = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_pp0_stage0 : begin
            ap_NS_fsm = ap_ST_fsm_pp0_stage0;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln126_1_fu_413_p2 = (phi_urem461_fu_92 + 8'd1);

assign add_ln126_2_fu_527_p2 = (phi_mul459_fu_96 + 16'd410);

assign add_ln126_fu_394_p2 = (ap_sig_allocacmp_j_3 + 8'd1);

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd0];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_00001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_ignoreCallOp217 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_ignoreCallOp218 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_ignoreCallOp219 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_ignoreCallOp220 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_ignoreCallOp342 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_subdone = ~(1'b1 == 1'b1);

assign ap_done = ap_done_sig;

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_enable_reg_pp0_iter0 = ap_start_int;

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage0;

assign ap_ready = ap_ready_sig;

assign c1_address0 = c1_addr_reg_725_pp0_iter59_reg;

assign c1_address1 = zext_ln126_fu_400_p1;

assign c1_ce0 = c1_ce0_local;

assign c1_ce1 = c1_ce1_local;

assign c1_d0 = c1_new_reg_909;

assign c1_we0 = c1_we0_local;

assign gates1_1_address0 = gates1_1_address0_local;

assign gates1_1_ce0 = gates1_1_ce0_local;

assign gates1_2_address0 = gates1_2_address0_local;

assign gates1_2_ce0 = gates1_2_ce0_local;

assign gates1_3_address0 = gates1_3_address0_local;

assign gates1_3_ce0 = gates1_3_ce0_local;

assign gates1_4_address0 = gates1_4_address0_local;

assign gates1_4_ce0 = gates1_4_ce0_local;

assign gates1_address0 = gates1_address0_local;

assign gates1_ce0 = gates1_ce0_local;

assign grp_fu_1732_p_ce = 1'b1;

assign grp_fu_1732_p_din0 = f_gate_reg_884;

assign grp_fu_1732_p_din1 = c1_load_reg_754_pp0_iter24_reg;

assign grp_fu_1736_p_ce = 1'b1;

assign grp_fu_1736_p_din0 = i_gate_reg_879_pp0_iter44_reg;

assign grp_fu_1736_p_din1 = g_gate_reg_899;

assign grp_fu_1740_p_ce = 1'b1;

assign grp_fu_1740_p_din0 = o_gate_reg_889_pp0_iter100_reg;

assign grp_fu_1740_p_din1 = tmp_7_reg_915;

assign grp_fu_726_p_ce = 1'b1;

assign grp_fu_726_p_din0 = mul5_reg_894_pp0_iter49_reg;

assign grp_fu_726_p_din1 = mul6_reg_904;

assign grp_fu_726_p_opcode = 2'd0;

assign grp_sigmoid_fu_1744_p_din1 = tmp_2_reg_859;

assign grp_sigmoid_fu_1749_p_din1 = tmp_3_reg_864;

assign grp_sigmoid_fu_1754_p_din1 = tmp_5_reg_874;

assign grp_tanh_approx_fu_1759_p_din1 = tmp_4_reg_869;

assign grp_tanh_approx_fu_1764_p_din1 = c1_new_reg_909;

assign h1_address0 = zext_ln126_reg_720_pp0_iter105_reg;

assign h1_ce0 = h1_ce0_local;

assign h1_d0 = mul7_reg_920;

assign h1_we0 = h1_we0_local;

assign icmp_ln126_1_fu_419_p2 = ((add_ln126_1_fu_413_p2 < 8'd5) ? 1'b1 : 1'b0);

assign icmp_ln126_fu_388_p2 = ((ap_sig_allocacmp_j_3 == 8'd128) ? 1'b1 : 1'b0);

assign mul_ln128_fu_452_p0 = mul_ln128_fu_452_p00;

assign mul_ln128_fu_452_p00 = $unsigned(zext_ln128_1_cast_fu_440_p3);

assign mul_ln128_fu_452_p1 = 17'd410;

assign mul_ln129_fu_479_p0 = mul_ln129_fu_479_p00;

assign mul_ln129_fu_479_p00 = zext_ln129_1_cast_fu_468_p3;

assign mul_ln129_fu_479_p1 = 19'd820;

assign mul_ln130_fu_503_p0 = mul_ln130_fu_503_p00;

assign mul_ln130_fu_503_p00 = $unsigned(sext_ln130_fu_495_p1);

assign mul_ln130_fu_503_p1 = 19'd820;

assign select_ln126_fu_425_p3 = ((icmp_ln126_1_fu_419_p2[0:0] == 1'b1) ? add_ln126_1_fu_413_p2 : 8'd0);

assign sext_ln130_fu_495_p1 = zext_ln128_1_cast_fu_440_p3;

assign tmp_2_fu_581_p11 = 'bx;

assign tmp_3_fu_608_p11 = 'bx;

assign tmp_4_fu_635_p11 = 'bx;

assign tmp_5_fu_662_p11 = 'bx;

assign tmp_fu_533_p4 = {{phi_mul459_fu_96[15:11]}};

assign trunc_ln126_fu_433_p1 = phi_urem461_fu_92[2:0];

assign trunc_ln128_fu_437_p1 = j_3_reg_710[6:0];

assign zext_ln126_1_fu_543_p1 = tmp_fu_533_p4;

assign zext_ln126_fu_400_p1 = ap_sig_allocacmp_j_3;

assign zext_ln128_1_cast_fu_440_p3 = {{1'd1}, {trunc_ln128_fu_437_p1}};

assign zext_ln128_fu_552_p1 = tmp_16_reg_739;

assign zext_ln129_1_cast_fu_468_p3 = {{1'd1}, {j_3_reg_710}};

assign zext_ln129_fu_560_p1 = tmp_17_reg_744;

assign zext_ln130_fu_568_p1 = tmp_18_reg_749;

always @ (posedge ap_clk) begin
    zext_ln126_reg_720[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter1_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter2_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter3_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter4_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter5_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter6_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter7_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter8_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter9_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter10_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter11_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter12_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter13_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter14_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter15_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter16_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter17_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter18_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter19_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter20_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter21_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter22_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter23_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter24_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter25_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter26_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter27_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter28_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter29_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter30_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter31_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter32_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter33_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter34_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter35_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter36_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter37_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter38_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter39_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter40_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter41_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter42_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter43_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter44_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter45_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter46_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter47_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter48_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter49_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter50_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter51_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter52_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter53_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter54_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter55_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter56_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter57_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter58_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter59_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter60_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter61_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter62_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter63_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter64_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter65_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter66_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter67_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter68_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter69_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter70_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter71_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter72_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter73_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter74_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter75_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter76_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter77_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter78_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter79_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter80_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter81_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter82_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter83_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter84_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter85_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter86_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter87_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter88_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter89_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter90_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter91_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter92_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter93_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter94_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter95_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter96_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter97_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter98_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter99_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter100_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter101_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter102_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter103_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter104_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln126_reg_720_pp0_iter105_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
end

endmodule //vadd_lstm_inference_Pipeline_VITIS_LOOP_126_11

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_VITIS_LOOP_142_13 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        sext_ln140,
        zext_ln142,
        m_axi_gmem1_AWVALID,
        m_axi_gmem1_AWREADY,
        m_axi_gmem1_AWADDR,
        m_axi_gmem1_AWID,
        m_axi_gmem1_AWLEN,
        m_axi_gmem1_AWSIZE,
        m_axi_gmem1_AWBURST,
        m_axi_gmem1_AWLOCK,
        m_axi_gmem1_AWCACHE,
        m_axi_gmem1_AWPROT,
        m_axi_gmem1_AWQOS,
        m_axi_gmem1_AWREGION,
        m_axi_gmem1_AWUSER,
        m_axi_gmem1_WVALID,
        m_axi_gmem1_WREADY,
        m_axi_gmem1_WDATA,
        m_axi_gmem1_WSTRB,
        m_axi_gmem1_WLAST,
        m_axi_gmem1_WID,
        m_axi_gmem1_WUSER,
        m_axi_gmem1_ARVALID,
        m_axi_gmem1_ARREADY,
        m_axi_gmem1_ARADDR,
        m_axi_gmem1_ARID,
        m_axi_gmem1_ARLEN,
        m_axi_gmem1_ARSIZE,
        m_axi_gmem1_ARBURST,
        m_axi_gmem1_ARLOCK,
        m_axi_gmem1_ARCACHE,
        m_axi_gmem1_ARPROT,
        m_axi_gmem1_ARQOS,
        m_axi_gmem1_ARREGION,
        m_axi_gmem1_ARUSER,
        m_axi_gmem1_RVALID,
        m_axi_gmem1_RREADY,
        m_axi_gmem1_RDATA,
        m_axi_gmem1_RLAST,
        m_axi_gmem1_RID,
        m_axi_gmem1_RFIFONUM,
        m_axi_gmem1_RUSER,
        m_axi_gmem1_RRESP,
        m_axi_gmem1_BVALID,
        m_axi_gmem1_BREADY,
        m_axi_gmem1_BRESP,
        m_axi_gmem1_BID,
        m_axi_gmem1_BUSER,
        h1_address0,
        h1_ce0,
        h1_q0,
        dot_out,
        dot_out_ap_vld,
        grp_fu_726_p_din0,
        grp_fu_726_p_din1,
        grp_fu_726_p_opcode,
        grp_fu_726_p_dout0,
        grp_fu_726_p_ce,
        grp_fu_1732_p_din0,
        grp_fu_1732_p_din1,
        grp_fu_1732_p_dout0,
        grp_fu_1732_p_ce
);

parameter    ap_ST_fsm_pp0_stage0 = 9'd1;
parameter    ap_ST_fsm_pp0_stage1 = 9'd2;
parameter    ap_ST_fsm_pp0_stage2 = 9'd4;
parameter    ap_ST_fsm_pp0_stage3 = 9'd8;
parameter    ap_ST_fsm_pp0_stage4 = 9'd16;
parameter    ap_ST_fsm_pp0_stage5 = 9'd32;
parameter    ap_ST_fsm_pp0_stage6 = 9'd64;
parameter    ap_ST_fsm_pp0_stage7 = 9'd128;
parameter    ap_ST_fsm_pp0_stage8 = 9'd256;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
input  [61:0] sext_ln140;
input  [10:0] zext_ln142;
output   m_axi_gmem1_AWVALID;
input   m_axi_gmem1_AWREADY;
output  [63:0] m_axi_gmem1_AWADDR;
output  [0:0] m_axi_gmem1_AWID;
output  [31:0] m_axi_gmem1_AWLEN;
output  [2:0] m_axi_gmem1_AWSIZE;
output  [1:0] m_axi_gmem1_AWBURST;
output  [1:0] m_axi_gmem1_AWLOCK;
output  [3:0] m_axi_gmem1_AWCACHE;
output  [2:0] m_axi_gmem1_AWPROT;
output  [3:0] m_axi_gmem1_AWQOS;
output  [3:0] m_axi_gmem1_AWREGION;
output  [0:0] m_axi_gmem1_AWUSER;
output   m_axi_gmem1_WVALID;
input   m_axi_gmem1_WREADY;
output  [31:0] m_axi_gmem1_WDATA;
output  [3:0] m_axi_gmem1_WSTRB;
output   m_axi_gmem1_WLAST;
output  [0:0] m_axi_gmem1_WID;
output  [0:0] m_axi_gmem1_WUSER;
output   m_axi_gmem1_ARVALID;
input   m_axi_gmem1_ARREADY;
output  [63:0] m_axi_gmem1_ARADDR;
output  [0:0] m_axi_gmem1_ARID;
output  [31:0] m_axi_gmem1_ARLEN;
output  [2:0] m_axi_gmem1_ARSIZE;
output  [1:0] m_axi_gmem1_ARBURST;
output  [1:0] m_axi_gmem1_ARLOCK;
output  [3:0] m_axi_gmem1_ARCACHE;
output  [2:0] m_axi_gmem1_ARPROT;
output  [3:0] m_axi_gmem1_ARQOS;
output  [3:0] m_axi_gmem1_ARREGION;
output  [0:0] m_axi_gmem1_ARUSER;
input   m_axi_gmem1_RVALID;
output   m_axi_gmem1_RREADY;
input  [31:0] m_axi_gmem1_RDATA;
input   m_axi_gmem1_RLAST;
input  [0:0] m_axi_gmem1_RID;
input  [8:0] m_axi_gmem1_RFIFONUM;
input  [0:0] m_axi_gmem1_RUSER;
input  [1:0] m_axi_gmem1_RRESP;
input   m_axi_gmem1_BVALID;
output   m_axi_gmem1_BREADY;
input  [1:0] m_axi_gmem1_BRESP;
input  [0:0] m_axi_gmem1_BID;
input  [0:0] m_axi_gmem1_BUSER;
output  [6:0] h1_address0;
output   h1_ce0;
input  [31:0] h1_q0;
output  [31:0] dot_out;
output   dot_out_ap_vld;
output  [31:0] grp_fu_726_p_din0;
output  [31:0] grp_fu_726_p_din1;
output  [1:0] grp_fu_726_p_opcode;
input  [31:0] grp_fu_726_p_dout0;
output   grp_fu_726_p_ce;
output  [31:0] grp_fu_1732_p_din0;
output  [31:0] grp_fu_1732_p_din1;
input  [31:0] grp_fu_1732_p_dout0;
output   grp_fu_1732_p_ce;

reg ap_idle;
reg m_axi_gmem1_ARVALID;
reg m_axi_gmem1_RREADY;
reg dot_out_ap_vld;

(* fsm_encoding = "none" *) reg   [8:0] ap_CS_fsm;
wire    ap_CS_fsm_pp0_stage0;
reg    ap_enable_reg_pp0_iter0;
reg    ap_enable_reg_pp0_iter1;
reg    ap_enable_reg_pp0_iter2;
reg    ap_idle_pp0;
wire    ap_CS_fsm_pp0_stage8;
wire    ap_block_pp0_stage8_subdone;
reg   [0:0] icmp_ln142_reg_221;
reg    ap_condition_exit_pp0_iter0_stage8;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
reg    gmem1_blk_n_AR;
wire    ap_CS_fsm_pp0_stage1;
wire    ap_block_pp0_stage1;
reg    gmem1_blk_n_R;
wire    ap_block_pp0_stage0;
reg    ap_block_state10_pp0_stage0_iter1;
reg    ap_block_pp0_stage0_11001;
wire   [0:0] icmp_ln142_fu_141_p2;
reg   [0:0] icmp_ln142_reg_221_pp0_iter1_reg;
reg   [63:0] gmem1_addr_reg_225;
reg   [31:0] h1_load_reg_236;
reg    ap_block_state2_io;
reg    ap_block_pp0_stage1_11001;
reg   [31:0] gmem1_addr_read_reg_241;
wire   [31:0] bitcast_ln144_fu_189_p1;
reg   [31:0] mul_reg_251;
wire    ap_CS_fsm_pp0_stage5;
wire    ap_block_pp0_stage5_11001;
wire    ap_CS_fsm_pp0_stage6;
wire    ap_block_pp0_stage6_11001;
reg    ap_enable_reg_pp0_iter0_reg;
wire    ap_block_pp0_stage6_subdone;
wire   [63:0] zext_ln142_1_fu_153_p1;
wire  signed [63:0] sext_ln144_fu_174_p1;
reg   [31:0] dot_fu_60;
reg   [31:0] ap_sig_allocacmp_dot_load;
wire    ap_block_pp0_stage6;
wire    ap_loop_init;
reg    ap_loop_exit_ready_pp0_iter1_reg;
wire    ap_block_pp0_stage8_11001;
reg    ap_condition_exit_pp0_iter1_stage6;
reg    ap_idle_pp0_0to0;
reg   [7:0] j_fu_64;
wire   [7:0] add_ln142_fu_147_p2;
reg   [7:0] ap_sig_allocacmp_j_2;
wire    ap_block_pp0_stage6_01001;
reg    h1_ce0_local;
wire   [62:0] zext_ln142_2_fu_158_p1;
wire  signed [62:0] sext_ln140_cast_fu_124_p1;
wire   [62:0] add_ln144_fu_162_p2;
wire   [62:0] zext_ln142_cast_fu_120_p1;
wire   [62:0] add_ln144_1_fu_168_p2;
reg    grp_fu_112_ce;
wire    ap_block_pp0_stage7_11001;
wire    ap_block_pp0_stage2_11001;
wire    ap_block_pp0_stage3_11001;
wire    ap_block_pp0_stage4_11001;
wire    ap_CS_fsm_pp0_stage7;
wire    ap_CS_fsm_pp0_stage2;
wire    ap_CS_fsm_pp0_stage3;
wire    ap_CS_fsm_pp0_stage4;
reg    grp_fu_116_ce;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg   [8:0] ap_NS_fsm;
reg    ap_block_pp0_stage0_subdone;
reg    ap_idle_pp0_1to2;
reg    ap_block_pp0_stage1_subdone;
wire    ap_block_pp0_stage2_subdone;
wire    ap_block_pp0_stage3_subdone;
wire    ap_block_pp0_stage4_subdone;
wire    ap_block_pp0_stage5_subdone;
wire    ap_block_pp0_stage7_subdone;
wire    ap_enable_pp0;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_block_pp0_stage6_00001;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 9'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter2 = 1'b0;
#0 ap_enable_reg_pp0_iter0_reg = 1'b0;
#0 dot_fu_60 = 32'd0;
#0 j_fu_64 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage8),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_pp0_stage0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage6_subdone) & (ap_loop_exit_ready_pp0_iter1_reg == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage6))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
            ap_enable_reg_pp0_iter0_reg <= ap_start_int;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if ((1'b1 == ap_condition_exit_pp0_iter0_stage8)) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage8_subdone) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter2 <= 1'b0;
    end else begin
        if (((1'b0 == ap_block_pp0_stage6_subdone) & (ap_enable_reg_pp0_iter2 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage6))) begin
            ap_enable_reg_pp0_iter2 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage8_subdone) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
            ap_enable_reg_pp0_iter2 <= ap_enable_reg_pp0_iter1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((ap_idle_pp0_0to0 == 1'b1) & (1'b1 == ap_condition_exit_pp0_iter1_stage6))) begin
        ap_loop_exit_ready_pp0_iter1_reg <= 1'b0;
    end else if (((1'b0 == ap_block_pp0_stage8_11001) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
        ap_loop_exit_ready_pp0_iter1_reg <= ap_loop_exit_ready;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        dot_fu_60 <= 32'd0;
    end else if (((1'b0 == ap_block_pp0_stage6_11001) & (ap_enable_reg_pp0_iter2 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage6))) begin
        dot_fu_60 <= grp_fu_726_p_dout0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if (((ap_enable_reg_pp0_iter0 == 1'b1) & (icmp_ln142_fu_141_p2 == 1'd0))) begin
            j_fu_64 <= add_ln142_fu_147_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            j_fu_64 <= 8'd0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        gmem1_addr_read_reg_241 <= m_axi_gmem1_RDATA;
        gmem1_addr_reg_225 <= sext_ln144_fu_174_p1;
        icmp_ln142_reg_221 <= icmp_ln142_fu_141_p2;
        icmp_ln142_reg_221_pp0_iter1_reg <= icmp_ln142_reg_221;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        h1_load_reg_236 <= h1_q0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5))) begin
        mul_reg_251 <= grp_fu_1732_p_dout0;
    end
end

always @ (*) begin
    if (((icmp_ln142_reg_221 == 1'd1) & (1'b0 == ap_block_pp0_stage8_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
        ap_condition_exit_pp0_iter0_stage8 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage8 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage6_subdone) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage6) & (icmp_ln142_reg_221_pp0_iter1_reg == 1'd1))) begin
        ap_condition_exit_pp0_iter1_stage6 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter1_stage6 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage6_subdone) & (ap_loop_exit_ready_pp0_iter1_reg == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage6))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
        ap_enable_reg_pp0_iter0 = ap_start_int;
    end else begin
        ap_enable_reg_pp0_iter0 = ap_enable_reg_pp0_iter0_reg;
    end
end

always @ (*) begin
    if (((ap_start_int == 1'b0) & (ap_idle_pp0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b0)) begin
        ap_idle_pp0_0to0 = 1'b1;
    end else begin
        ap_idle_pp0_0to0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0))) begin
        ap_idle_pp0_1to2 = 1'b1;
    end else begin
        ap_idle_pp0_1to2 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage8_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage6) & (ap_enable_reg_pp0_iter2 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage6))) begin
        ap_sig_allocacmp_dot_load = grp_fu_726_p_dout0;
    end else begin
        ap_sig_allocacmp_dot_load = dot_fu_60;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_sig_allocacmp_j_2 = 8'd0;
    end else begin
        ap_sig_allocacmp_j_2 = j_fu_64;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage6_11001) & (ap_loop_exit_ready_pp0_iter1_reg == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage6) & (icmp_ln142_reg_221_pp0_iter1_reg == 1'd1))) begin
        dot_out_ap_vld = 1'b1;
    end else begin
        dot_out_ap_vld = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln142_reg_221 == 1'd0) & (1'b0 == ap_block_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        gmem1_blk_n_AR = m_axi_gmem1_ARREADY;
    end else begin
        gmem1_blk_n_AR = 1'b1;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        gmem1_blk_n_R = m_axi_gmem1_RVALID;
    end else begin
        gmem1_blk_n_R = 1'b1;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage4_11001) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2)) | ((1'b0 == ap_block_pp0_stage7_11001) & (1'b1 == ap_CS_fsm_pp0_stage7)) | ((1'b0 == ap_block_pp0_stage8_11001) & (1'b1 == ap_CS_fsm_pp0_stage8)) | ((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6)) | ((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1)) | ((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0)))) begin
        grp_fu_112_ce = 1'b1;
    end else begin
        grp_fu_112_ce = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage4_11001) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2)) | ((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1)))) begin
        grp_fu_116_ce = 1'b1;
    end else begin
        grp_fu_116_ce = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        h1_ce0_local = 1'b1;
    end else begin
        h1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln142_reg_221 == 1'd0) & (1'b0 == ap_block_pp0_stage1_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        m_axi_gmem1_ARVALID = 1'b1;
    end else begin
        m_axi_gmem1_ARVALID = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        m_axi_gmem1_RREADY = 1'b1;
    end else begin
        m_axi_gmem1_RREADY = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_pp0_stage0 : begin
            if ((~((ap_start_int == 1'b0) & (ap_idle_pp0_1to2 == 1'b1)) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_pp0_stage1 : begin
            if ((1'b0 == ap_block_pp0_stage1_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end
        end
        ap_ST_fsm_pp0_stage2 : begin
            if ((1'b0 == ap_block_pp0_stage2_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end
        end
        ap_ST_fsm_pp0_stage3 : begin
            if ((1'b0 == ap_block_pp0_stage3_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end
        end
        ap_ST_fsm_pp0_stage4 : begin
            if ((1'b0 == ap_block_pp0_stage4_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end
        end
        ap_ST_fsm_pp0_stage5 : begin
            if ((1'b0 == ap_block_pp0_stage5_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end
        end
        ap_ST_fsm_pp0_stage6 : begin
            if (((ap_idle_pp0_0to0 == 1'b1) & (1'b1 == ap_condition_exit_pp0_iter1_stage6))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else if ((1'b0 == ap_block_pp0_stage6_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage7;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end
        end
        ap_ST_fsm_pp0_stage7 : begin
            if ((1'b0 == ap_block_pp0_stage7_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage8;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage7;
            end
        end
        ap_ST_fsm_pp0_stage8 : begin
            if ((1'b0 == ap_block_pp0_stage8_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage8;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln142_fu_147_p2 = (ap_sig_allocacmp_j_2 + 8'd1);

assign add_ln144_1_fu_168_p2 = (add_ln144_fu_162_p2 + zext_ln142_cast_fu_120_p1);

assign add_ln144_fu_162_p2 = ($signed(zext_ln142_2_fu_158_p1) + $signed(sext_ln140_cast_fu_124_p1));

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_pp0_stage1 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_pp0_stage2 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_pp0_stage3 = ap_CS_fsm[32'd3];

assign ap_CS_fsm_pp0_stage4 = ap_CS_fsm[32'd4];

assign ap_CS_fsm_pp0_stage5 = ap_CS_fsm[32'd5];

assign ap_CS_fsm_pp0_stage6 = ap_CS_fsm[32'd6];

assign ap_CS_fsm_pp0_stage7 = ap_CS_fsm[32'd7];

assign ap_CS_fsm_pp0_stage8 = ap_CS_fsm[32'd8];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage0_11001 = ((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_block_state10_pp0_stage0_iter1));
end

always @ (*) begin
    ap_block_pp0_stage0_subdone = ((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_block_state10_pp0_stage0_iter1));
end

assign ap_block_pp0_stage1 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage1_11001 = ((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state2_io));
end

always @ (*) begin
    ap_block_pp0_stage1_subdone = ((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state2_io));
end

assign ap_block_pp0_stage2_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_00001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_01001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage8_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage8_subdone = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_state10_pp0_stage0_iter1 = (m_axi_gmem1_RVALID == 1'b0);
end

always @ (*) begin
    ap_block_state2_io = ((m_axi_gmem1_ARREADY == 1'b0) & (icmp_ln142_reg_221 == 1'd0));
end

assign ap_done = ap_done_sig;

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage8;

assign ap_ready = ap_ready_sig;

assign bitcast_ln144_fu_189_p1 = gmem1_addr_read_reg_241;

assign dot_out = dot_fu_60;

assign grp_fu_1732_p_ce = grp_fu_116_ce;

assign grp_fu_1732_p_din0 = bitcast_ln144_fu_189_p1;

assign grp_fu_1732_p_din1 = h1_load_reg_236;

assign grp_fu_726_p_ce = grp_fu_112_ce;

assign grp_fu_726_p_din0 = ap_sig_allocacmp_dot_load;

assign grp_fu_726_p_din1 = mul_reg_251;

assign grp_fu_726_p_opcode = 2'd0;

assign h1_address0 = zext_ln142_1_fu_153_p1;

assign h1_ce0 = h1_ce0_local;

assign icmp_ln142_fu_141_p2 = ((ap_sig_allocacmp_j_2 == 8'd128) ? 1'b1 : 1'b0);

assign m_axi_gmem1_ARADDR = gmem1_addr_reg_225;

assign m_axi_gmem1_ARBURST = 2'd0;

assign m_axi_gmem1_ARCACHE = 4'd0;

assign m_axi_gmem1_ARID = 1'd0;

assign m_axi_gmem1_ARLEN = 64'd1;

assign m_axi_gmem1_ARLOCK = 2'd0;

assign m_axi_gmem1_ARPROT = 3'd0;

assign m_axi_gmem1_ARQOS = 4'd0;

assign m_axi_gmem1_ARREGION = 4'd0;

assign m_axi_gmem1_ARSIZE = 3'd0;

assign m_axi_gmem1_ARUSER = 1'd0;

assign m_axi_gmem1_AWADDR = 64'd0;

assign m_axi_gmem1_AWBURST = 2'd0;

assign m_axi_gmem1_AWCACHE = 4'd0;

assign m_axi_gmem1_AWID = 1'd0;

assign m_axi_gmem1_AWLEN = 32'd0;

assign m_axi_gmem1_AWLOCK = 2'd0;

assign m_axi_gmem1_AWPROT = 3'd0;

assign m_axi_gmem1_AWQOS = 4'd0;

assign m_axi_gmem1_AWREGION = 4'd0;

assign m_axi_gmem1_AWSIZE = 3'd0;

assign m_axi_gmem1_AWUSER = 1'd0;

assign m_axi_gmem1_AWVALID = 1'b0;

assign m_axi_gmem1_BREADY = 1'b0;

assign m_axi_gmem1_WDATA = 32'd0;

assign m_axi_gmem1_WID = 1'd0;

assign m_axi_gmem1_WLAST = 1'b0;

assign m_axi_gmem1_WSTRB = 4'd0;

assign m_axi_gmem1_WUSER = 1'd0;

assign m_axi_gmem1_WVALID = 1'b0;

assign sext_ln140_cast_fu_124_p1 = $signed(sext_ln140);

assign sext_ln144_fu_174_p1 = $signed(add_ln144_1_fu_168_p2);

assign zext_ln142_1_fu_153_p1 = ap_sig_allocacmp_j_2;

assign zext_ln142_2_fu_158_p1 = ap_sig_allocacmp_j_2;

assign zext_ln142_cast_fu_120_p1 = zext_ln142;

endmodule //vadd_lstm_inference_Pipeline_VITIS_LOOP_142_13

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_VITIS_LOOP_152_14 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        max_val,
        logits_address0,
        logits_ce0,
        logits_q0,
        max_idx_out,
        max_idx_out_ap_vld
);

parameter    ap_ST_fsm_pp0_stage0 = 2'd1;
parameter    ap_ST_fsm_pp0_stage1 = 2'd2;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
input  [31:0] max_val;
output  [3:0] logits_address0;
output   logits_ce0;
input  [31:0] logits_q0;
output  [31:0] max_idx_out;
output   max_idx_out_ap_vld;

reg ap_idle;
reg max_idx_out_ap_vld;

(* fsm_encoding = "none" *) reg   [1:0] ap_CS_fsm;
wire    ap_CS_fsm_pp0_stage0;
reg    ap_enable_reg_pp0_iter0;
reg    ap_enable_reg_pp0_iter1;
reg    ap_enable_reg_pp0_iter2;
reg    ap_idle_pp0;
wire    ap_CS_fsm_pp0_stage1;
wire    ap_block_pp0_stage1_subdone;
reg   [0:0] icmp_ln152_reg_270;
reg    ap_condition_exit_pp0_iter0_stage1;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
wire    ap_block_pp0_stage0_11001;
reg   [3:0] i_reg_265;
reg   [3:0] i_reg_265_pp0_iter1_reg;
wire   [0:0] icmp_ln152_fu_104_p2;
reg   [31:0] max_val_2_reg_279;
wire    ap_block_pp0_stage1_11001;
reg   [31:0] max_val_1_load_reg_286;
wire   [0:0] icmp_ln153_2_fu_148_p2;
reg   [0:0] icmp_ln153_2_reg_292;
wire   [0:0] icmp_ln153_3_fu_154_p2;
reg   [0:0] icmp_ln153_3_reg_297;
wire   [0:0] and_ln153_1_fu_205_p2;
reg   [0:0] and_ln153_1_reg_302;
wire   [31:0] max_val_3_fu_211_p3;
reg   [31:0] max_val_3_reg_307;
reg    ap_enable_reg_pp0_iter0_reg;
wire    ap_block_pp0_stage0_subdone;
wire   [63:0] zext_ln152_fu_110_p1;
wire    ap_block_pp0_stage0;
reg   [31:0] max_idx_fu_44;
wire   [31:0] max_idx_4_fu_223_p3;
wire    ap_loop_init;
reg    ap_loop_exit_ready_pp0_iter1_reg;
reg    ap_condition_exit_pp0_iter1_stage0;
reg    ap_idle_pp0_0to0;
reg   [31:0] max_val_1_fu_48;
reg   [31:0] ap_sig_allocacmp_max_val_1_load;
reg   [3:0] max_idx_1_fu_52;
wire   [3:0] add_ln152_fu_115_p2;
reg   [3:0] ap_sig_allocacmp_i;
wire    ap_block_pp0_stage0_01001;
reg    logits_ce0_local;
wire   [31:0] bitcast_ln153_1_fu_130_p1;
wire   [7:0] tmp_s_fu_134_p4;
wire   [22:0] trunc_ln153_1_fu_144_p1;
wire    ap_block_pp0_stage1;
wire   [31:0] bitcast_ln153_fu_160_p1;
wire   [7:0] tmp_9_fu_163_p4;
wire   [22:0] trunc_ln153_fu_173_p1;
wire   [0:0] icmp_ln153_1_fu_183_p2;
wire   [0:0] icmp_ln153_fu_177_p2;
wire   [0:0] grp_fu_82_p2;
wire   [0:0] or_ln153_fu_189_p2;
wire   [0:0] and_ln153_fu_199_p2;
wire   [0:0] or_ln153_1_fu_195_p2;
wire   [31:0] zext_ln153_fu_220_p1;
wire    ap_block_pp0_stage0_00001;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg   [1:0] ap_NS_fsm;
reg    ap_idle_pp0_1to2;
wire    ap_enable_pp0;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 2'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter2 = 1'b0;
#0 ap_enable_reg_pp0_iter0_reg = 1'b0;
#0 max_idx_fu_44 = 32'd0;
#0 max_val_1_fu_48 = 32'd0;
#0 max_idx_1_fu_52 = 4'd0;
#0 ap_done_reg = 1'b0;
end

vadd_fcmp_32ns_32ns_1_2_no_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 2 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 1 ))
fcmp_32ns_32ns_1_2_no_dsp_1_U96(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(max_val_2_reg_279),
    .din1(ap_sig_allocacmp_max_val_1_load),
    .ce(1'b1),
    .opcode(5'd2),
    .dout(grp_fu_82_p2)
);

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage1),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_pp0_stage0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage0_subdone) & (1'b1 == ap_CS_fsm_pp0_stage0) & (ap_loop_exit_ready_pp0_iter1_reg == 1'b1))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
            ap_enable_reg_pp0_iter0_reg <= ap_start_int;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if ((1'b1 == ap_condition_exit_pp0_iter0_stage1)) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage1_subdone) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter2 <= 1'b0;
    end else begin
        if (((1'b0 == ap_block_pp0_stage0_subdone) & (ap_enable_reg_pp0_iter2 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
            ap_enable_reg_pp0_iter2 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage1_subdone) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
            ap_enable_reg_pp0_iter2 <= ap_enable_reg_pp0_iter1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_condition_exit_pp0_iter1_stage0) & (ap_idle_pp0_0to0 == 1'b1))) begin
        ap_loop_exit_ready_pp0_iter1_reg <= 1'b0;
    end else if (((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        ap_loop_exit_ready_pp0_iter1_reg <= ap_loop_exit_ready;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if (((icmp_ln152_fu_104_p2 == 1'd0) & (ap_enable_reg_pp0_iter0 == 1'b1))) begin
            max_idx_1_fu_52 <= add_ln152_fu_115_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            max_idx_1_fu_52 <= 4'd1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if ((ap_loop_init == 1'b1)) begin
            max_idx_fu_44 <= 32'd0;
        end else if ((ap_enable_reg_pp0_iter2 == 1'b1)) begin
            max_idx_fu_44 <= max_idx_4_fu_223_p3;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if ((ap_loop_init == 1'b1)) begin
            max_val_1_fu_48 <= max_val;
        end else if ((ap_enable_reg_pp0_iter2 == 1'b1)) begin
            max_val_1_fu_48 <= max_val_3_reg_307;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        and_ln153_1_reg_302 <= and_ln153_1_fu_205_p2;
        max_val_2_reg_279 <= logits_q0;
        max_val_3_reg_307 <= max_val_3_fu_211_p3;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        i_reg_265 <= ap_sig_allocacmp_i;
        i_reg_265_pp0_iter1_reg <= i_reg_265;
        icmp_ln152_reg_270 <= icmp_ln152_fu_104_p2;
        icmp_ln153_2_reg_292 <= icmp_ln153_2_fu_148_p2;
        icmp_ln153_3_reg_297 <= icmp_ln153_3_fu_154_p2;
        max_val_1_load_reg_286 <= ap_sig_allocacmp_max_val_1_load;
    end
end

always @ (*) begin
    if (((icmp_ln152_reg_270 == 1'd1) & (1'b0 == ap_block_pp0_stage1_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        ap_condition_exit_pp0_iter0_stage1 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage1 = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln152_reg_270 == 1'd1) & (1'b0 == ap_block_pp0_stage0_subdone) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_condition_exit_pp0_iter1_stage0 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter1_stage0 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_subdone) & (1'b1 == ap_CS_fsm_pp0_stage0) & (ap_loop_exit_ready_pp0_iter1_reg == 1'b1))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
        ap_enable_reg_pp0_iter0 = ap_start_int;
    end else begin
        ap_enable_reg_pp0_iter0 = ap_enable_reg_pp0_iter0_reg;
    end
end

always @ (*) begin
    if (((ap_idle_pp0 == 1'b1) & (ap_start_int == 1'b0) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b0)) begin
        ap_idle_pp0_0to0 = 1'b1;
    end else begin
        ap_idle_pp0_0to0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0))) begin
        ap_idle_pp0_1to2 = 1'b1;
    end else begin
        ap_idle_pp0_1to2 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage1_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (1'b1 == ap_CS_fsm_pp0_stage0) & (ap_loop_init == 1'b1))) begin
        ap_sig_allocacmp_i = 4'd1;
    end else begin
        ap_sig_allocacmp_i = max_idx_1_fu_52;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_sig_allocacmp_max_val_1_load = max_val_3_reg_307;
    end else begin
        ap_sig_allocacmp_max_val_1_load = max_val_1_fu_48;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        logits_ce0_local = 1'b1;
    end else begin
        logits_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln152_reg_270 == 1'd1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0) & (ap_loop_exit_ready_pp0_iter1_reg == 1'b1))) begin
        max_idx_out_ap_vld = 1'b1;
    end else begin
        max_idx_out_ap_vld = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_pp0_stage0 : begin
            if (((1'b1 == ap_condition_exit_pp0_iter1_stage0) & (ap_idle_pp0_0to0 == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else if ((~((ap_start_int == 1'b0) & (ap_idle_pp0_1to2 == 1'b1)) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_pp0_stage1 : begin
            if ((1'b0 == ap_block_pp0_stage1_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln152_fu_115_p2 = (ap_sig_allocacmp_i + 4'd1);

assign and_ln153_1_fu_205_p2 = (or_ln153_1_fu_195_p2 & and_ln153_fu_199_p2);

assign and_ln153_fu_199_p2 = (or_ln153_fu_189_p2 & grp_fu_82_p2);

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_pp0_stage1 = ap_CS_fsm[32'd1];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_00001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_01001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1_subdone = ~(1'b1 == 1'b1);

assign ap_done = ap_done_sig;

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage1;

assign ap_ready = ap_ready_sig;

assign bitcast_ln153_1_fu_130_p1 = ap_sig_allocacmp_max_val_1_load;

assign bitcast_ln153_fu_160_p1 = max_val_2_reg_279;

assign icmp_ln152_fu_104_p2 = ((ap_sig_allocacmp_i == 4'd10) ? 1'b1 : 1'b0);

assign icmp_ln153_1_fu_183_p2 = ((trunc_ln153_fu_173_p1 == 23'd0) ? 1'b1 : 1'b0);

assign icmp_ln153_2_fu_148_p2 = ((tmp_s_fu_134_p4 != 8'd255) ? 1'b1 : 1'b0);

assign icmp_ln153_3_fu_154_p2 = ((trunc_ln153_1_fu_144_p1 == 23'd0) ? 1'b1 : 1'b0);

assign icmp_ln153_fu_177_p2 = ((tmp_9_fu_163_p4 != 8'd255) ? 1'b1 : 1'b0);

assign logits_address0 = zext_ln152_fu_110_p1;

assign logits_ce0 = logits_ce0_local;

assign max_idx_4_fu_223_p3 = ((and_ln153_1_reg_302[0:0] == 1'b1) ? zext_ln153_fu_220_p1 : max_idx_fu_44);

assign max_idx_out = max_idx_fu_44;

assign max_val_3_fu_211_p3 = ((and_ln153_1_fu_205_p2[0:0] == 1'b1) ? max_val_2_reg_279 : max_val_1_load_reg_286);

assign or_ln153_1_fu_195_p2 = (icmp_ln153_3_reg_297 | icmp_ln153_2_reg_292);

assign or_ln153_fu_189_p2 = (icmp_ln153_fu_177_p2 | icmp_ln153_1_fu_183_p2);

assign tmp_9_fu_163_p4 = {{bitcast_ln153_fu_160_p1[30:23]}};

assign tmp_s_fu_134_p4 = {{bitcast_ln153_1_fu_130_p1[30:23]}};

assign trunc_ln153_1_fu_144_p1 = bitcast_ln153_1_fu_130_p1[22:0];

assign trunc_ln153_fu_173_p1 = bitcast_ln153_fu_160_p1[22:0];

assign zext_ln152_fu_110_p1 = ap_sig_allocacmp_i;

assign zext_ln153_fu_220_p1 = i_reg_265_pp0_iter1_reg;

endmodule //vadd_lstm_inference_Pipeline_VITIS_LOOP_152_14

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_VITIS_LOOP_81_4 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        sext_ln81,
        m_axi_gmem0_AWVALID,
        m_axi_gmem0_AWREADY,
        m_axi_gmem0_AWADDR,
        m_axi_gmem0_AWID,
        m_axi_gmem0_AWLEN,
        m_axi_gmem0_AWSIZE,
        m_axi_gmem0_AWBURST,
        m_axi_gmem0_AWLOCK,
        m_axi_gmem0_AWCACHE,
        m_axi_gmem0_AWPROT,
        m_axi_gmem0_AWQOS,
        m_axi_gmem0_AWREGION,
        m_axi_gmem0_AWUSER,
        m_axi_gmem0_WVALID,
        m_axi_gmem0_WREADY,
        m_axi_gmem0_WDATA,
        m_axi_gmem0_WSTRB,
        m_axi_gmem0_WLAST,
        m_axi_gmem0_WID,
        m_axi_gmem0_WUSER,
        m_axi_gmem0_ARVALID,
        m_axi_gmem0_ARREADY,
        m_axi_gmem0_ARADDR,
        m_axi_gmem0_ARID,
        m_axi_gmem0_ARLEN,
        m_axi_gmem0_ARSIZE,
        m_axi_gmem0_ARBURST,
        m_axi_gmem0_ARLOCK,
        m_axi_gmem0_ARCACHE,
        m_axi_gmem0_ARPROT,
        m_axi_gmem0_ARQOS,
        m_axi_gmem0_ARREGION,
        m_axi_gmem0_ARUSER,
        m_axi_gmem0_RVALID,
        m_axi_gmem0_RREADY,
        m_axi_gmem0_RDATA,
        m_axi_gmem0_RLAST,
        m_axi_gmem0_RID,
        m_axi_gmem0_RFIFONUM,
        m_axi_gmem0_RUSER,
        m_axi_gmem0_RRESP,
        m_axi_gmem0_BVALID,
        m_axi_gmem0_BREADY,
        m_axi_gmem0_BRESP,
        m_axi_gmem0_BID,
        m_axi_gmem0_BUSER,
        sext_ln75,
        xC_out,
        xC_out_ap_vld,
        grp_fu_726_p_din0,
        grp_fu_726_p_din1,
        grp_fu_726_p_opcode,
        grp_fu_726_p_dout0,
        grp_fu_726_p_ce,
        grp_fu_1732_p_din0,
        grp_fu_1732_p_din1,
        grp_fu_1732_p_dout0,
        grp_fu_1732_p_ce
);

parameter    ap_ST_fsm_pp0_stage0 = 9'd1;
parameter    ap_ST_fsm_pp0_stage1 = 9'd2;
parameter    ap_ST_fsm_pp0_stage2 = 9'd4;
parameter    ap_ST_fsm_pp0_stage3 = 9'd8;
parameter    ap_ST_fsm_pp0_stage4 = 9'd16;
parameter    ap_ST_fsm_pp0_stage5 = 9'd32;
parameter    ap_ST_fsm_pp0_stage6 = 9'd64;
parameter    ap_ST_fsm_pp0_stage7 = 9'd128;
parameter    ap_ST_fsm_pp0_stage8 = 9'd256;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
input  [61:0] sext_ln81;
output   m_axi_gmem0_AWVALID;
input   m_axi_gmem0_AWREADY;
output  [63:0] m_axi_gmem0_AWADDR;
output  [0:0] m_axi_gmem0_AWID;
output  [31:0] m_axi_gmem0_AWLEN;
output  [2:0] m_axi_gmem0_AWSIZE;
output  [1:0] m_axi_gmem0_AWBURST;
output  [1:0] m_axi_gmem0_AWLOCK;
output  [3:0] m_axi_gmem0_AWCACHE;
output  [2:0] m_axi_gmem0_AWPROT;
output  [3:0] m_axi_gmem0_AWQOS;
output  [3:0] m_axi_gmem0_AWREGION;
output  [0:0] m_axi_gmem0_AWUSER;
output   m_axi_gmem0_WVALID;
input   m_axi_gmem0_WREADY;
output  [31:0] m_axi_gmem0_WDATA;
output  [3:0] m_axi_gmem0_WSTRB;
output   m_axi_gmem0_WLAST;
output  [0:0] m_axi_gmem0_WID;
output  [0:0] m_axi_gmem0_WUSER;
output   m_axi_gmem0_ARVALID;
input   m_axi_gmem0_ARREADY;
output  [63:0] m_axi_gmem0_ARADDR;
output  [0:0] m_axi_gmem0_ARID;
output  [31:0] m_axi_gmem0_ARLEN;
output  [2:0] m_axi_gmem0_ARSIZE;
output  [1:0] m_axi_gmem0_ARBURST;
output  [1:0] m_axi_gmem0_ARLOCK;
output  [3:0] m_axi_gmem0_ARCACHE;
output  [2:0] m_axi_gmem0_ARPROT;
output  [3:0] m_axi_gmem0_ARQOS;
output  [3:0] m_axi_gmem0_ARREGION;
output  [0:0] m_axi_gmem0_ARUSER;
input   m_axi_gmem0_RVALID;
output   m_axi_gmem0_RREADY;
input  [31:0] m_axi_gmem0_RDATA;
input   m_axi_gmem0_RLAST;
input  [0:0] m_axi_gmem0_RID;
input  [8:0] m_axi_gmem0_RFIFONUM;
input  [0:0] m_axi_gmem0_RUSER;
input  [1:0] m_axi_gmem0_RRESP;
input   m_axi_gmem0_BVALID;
output   m_axi_gmem0_BREADY;
input  [1:0] m_axi_gmem0_BRESP;
input  [0:0] m_axi_gmem0_BID;
input  [0:0] m_axi_gmem0_BUSER;
input  [61:0] sext_ln75;
output  [31:0] xC_out;
output   xC_out_ap_vld;
output  [31:0] grp_fu_726_p_din0;
output  [31:0] grp_fu_726_p_din1;
output  [1:0] grp_fu_726_p_opcode;
input  [31:0] grp_fu_726_p_dout0;
output   grp_fu_726_p_ce;
output  [31:0] grp_fu_1732_p_din0;
output  [31:0] grp_fu_1732_p_din1;
input  [31:0] grp_fu_1732_p_dout0;
output   grp_fu_1732_p_ce;

reg ap_idle;
reg m_axi_gmem0_ARVALID;
reg[63:0] m_axi_gmem0_ARADDR;
reg m_axi_gmem0_RREADY;
reg xC_out_ap_vld;

(* fsm_encoding = "none" *) reg   [8:0] ap_CS_fsm;
wire    ap_CS_fsm_pp0_stage0;
reg    ap_enable_reg_pp0_iter0;
reg    ap_enable_reg_pp0_iter1;
reg    ap_enable_reg_pp0_iter2;
reg    ap_idle_pp0;
wire    ap_CS_fsm_pp0_stage8;
wire    ap_block_pp0_stage8_subdone;
reg   [0:0] icmp_ln81_reg_223;
reg    ap_condition_exit_pp0_iter0_stage8;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
reg    gmem0_blk_n_AR;
wire    ap_CS_fsm_pp0_stage1;
wire    ap_block_pp0_stage1;
reg    gmem0_blk_n_R;
wire    ap_block_pp0_stage0;
wire    ap_CS_fsm_pp0_stage2;
wire    ap_block_pp0_stage2;
reg    ap_block_state10_pp0_stage0_iter1;
reg    ap_block_pp0_stage0_11001;
wire   [0:0] icmp_ln81_fu_134_p2;
reg   [0:0] icmp_ln81_reg_223_pp0_iter1_reg;
reg   [63:0] gmem0_addr_reg_227;
reg   [63:0] gmem0_addr_1_reg_233;
reg   [31:0] gmem0_addr_read_reg_239;
reg   [31:0] gmem0_addr_1_read_reg_244;
reg    ap_block_state2_io;
reg    ap_block_state11_pp0_stage1_iter1;
reg    ap_block_pp0_stage1_11001;
wire   [31:0] bitcast_ln83_fu_187_p1;
reg    ap_block_state3_io;
reg    ap_block_pp0_stage2_11001;
wire   [31:0] bitcast_ln83_1_fu_191_p1;
reg   [31:0] mul4_reg_259;
wire    ap_CS_fsm_pp0_stage6;
wire    ap_block_pp0_stage6_11001;
wire    ap_CS_fsm_pp0_stage7;
wire    ap_block_pp0_stage7_11001;
reg    ap_enable_reg_pp0_iter0_reg;
wire    ap_block_pp0_stage7_subdone;
wire  signed [63:0] sext_ln83_fu_156_p1;
wire  signed [63:0] sext_ln83_1_fu_172_p1;
reg   [31:0] xC_fu_54;
reg   [31:0] ap_sig_allocacmp_xC_load;
wire    ap_block_pp0_stage7;
wire    ap_loop_init;
reg    ap_loop_exit_ready_pp0_iter1_reg;
wire    ap_block_pp0_stage8_11001;
reg    ap_condition_exit_pp0_iter1_stage7;
reg    ap_idle_pp0_0to0;
reg   [7:0] k_fu_58;
wire   [7:0] add_ln81_fu_140_p2;
reg   [7:0] ap_sig_allocacmp_k_2;
wire    ap_block_pp0_stage7_01001;
wire   [62:0] zext_ln81_fu_146_p1;
wire  signed [62:0] sext_ln81_cast_fu_117_p1;
wire   [62:0] add_ln83_fu_150_p2;
wire  signed [62:0] sext_ln75_cast_fu_113_p1;
wire   [62:0] add_ln83_1_fu_166_p2;
reg    grp_fu_105_ce;
wire    ap_block_pp0_stage3_11001;
wire    ap_block_pp0_stage4_11001;
wire    ap_block_pp0_stage5_11001;
wire    ap_CS_fsm_pp0_stage3;
wire    ap_CS_fsm_pp0_stage4;
wire    ap_CS_fsm_pp0_stage5;
reg    grp_fu_109_ce;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg   [8:0] ap_NS_fsm;
reg    ap_block_pp0_stage0_subdone;
reg    ap_idle_pp0_1to2;
reg    ap_block_pp0_stage1_subdone;
reg    ap_block_pp0_stage2_subdone;
wire    ap_block_pp0_stage3_subdone;
wire    ap_block_pp0_stage4_subdone;
wire    ap_block_pp0_stage5_subdone;
wire    ap_block_pp0_stage6_subdone;
wire    ap_enable_pp0;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_block_pp0_stage7_00001;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 9'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter2 = 1'b0;
#0 ap_enable_reg_pp0_iter0_reg = 1'b0;
#0 xC_fu_54 = 32'd0;
#0 k_fu_58 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage8),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_pp0_stage0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage7_subdone) & (ap_loop_exit_ready_pp0_iter1_reg == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
            ap_enable_reg_pp0_iter0_reg <= ap_start_int;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if ((1'b1 == ap_condition_exit_pp0_iter0_stage8)) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage8_subdone) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter2 <= 1'b0;
    end else begin
        if (((1'b0 == ap_block_pp0_stage7_subdone) & (ap_enable_reg_pp0_iter2 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
            ap_enable_reg_pp0_iter2 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage8_subdone) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
            ap_enable_reg_pp0_iter2 <= ap_enable_reg_pp0_iter1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((ap_idle_pp0_0to0 == 1'b1) & (1'b1 == ap_condition_exit_pp0_iter1_stage7))) begin
        ap_loop_exit_ready_pp0_iter1_reg <= 1'b0;
    end else if (((1'b0 == ap_block_pp0_stage8_11001) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
        ap_loop_exit_ready_pp0_iter1_reg <= ap_loop_exit_ready;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if (((ap_enable_reg_pp0_iter0 == 1'b1) & (icmp_ln81_fu_134_p2 == 1'd0))) begin
            k_fu_58 <= add_ln81_fu_140_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            k_fu_58 <= 8'd0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        xC_fu_54 <= 32'd0;
    end else if (((1'b0 == ap_block_pp0_stage7_11001) & (ap_enable_reg_pp0_iter2 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        xC_fu_54 <= grp_fu_726_p_dout0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        gmem0_addr_1_read_reg_244 <= m_axi_gmem0_RDATA;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        gmem0_addr_1_reg_233 <= sext_ln83_1_fu_172_p1;
        gmem0_addr_read_reg_239 <= m_axi_gmem0_RDATA;
        gmem0_addr_reg_227 <= sext_ln83_fu_156_p1;
        icmp_ln81_reg_223 <= icmp_ln81_fu_134_p2;
        icmp_ln81_reg_223_pp0_iter1_reg <= icmp_ln81_reg_223;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6))) begin
        mul4_reg_259 <= grp_fu_1732_p_dout0;
    end
end

always @ (*) begin
    if (((icmp_ln81_reg_223 == 1'd1) & (1'b0 == ap_block_pp0_stage8_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
        ap_condition_exit_pp0_iter0_stage8 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage8 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage7_subdone) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7) & (icmp_ln81_reg_223_pp0_iter1_reg == 1'd1))) begin
        ap_condition_exit_pp0_iter1_stage7 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter1_stage7 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage7_subdone) & (ap_loop_exit_ready_pp0_iter1_reg == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
        ap_enable_reg_pp0_iter0 = ap_start_int;
    end else begin
        ap_enable_reg_pp0_iter0 = ap_enable_reg_pp0_iter0_reg;
    end
end

always @ (*) begin
    if (((ap_start_int == 1'b0) & (ap_idle_pp0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b0)) begin
        ap_idle_pp0_0to0 = 1'b1;
    end else begin
        ap_idle_pp0_0to0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0))) begin
        ap_idle_pp0_1to2 = 1'b1;
    end else begin
        ap_idle_pp0_1to2 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage8_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_sig_allocacmp_k_2 = 8'd0;
    end else begin
        ap_sig_allocacmp_k_2 = k_fu_58;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage7) & (ap_enable_reg_pp0_iter2 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_sig_allocacmp_xC_load = grp_fu_726_p_dout0;
    end else begin
        ap_sig_allocacmp_xC_load = xC_fu_54;
    end
end

always @ (*) begin
    if ((((icmp_ln81_reg_223 == 1'd0) & (1'b0 == ap_block_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage2)) | ((icmp_ln81_reg_223 == 1'd0) & (1'b0 == ap_block_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1)))) begin
        gmem0_blk_n_AR = m_axi_gmem0_ARREADY;
    end else begin
        gmem0_blk_n_AR = 1'b1;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0)) | ((1'b0 == ap_block_pp0_stage1) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1)))) begin
        gmem0_blk_n_R = m_axi_gmem0_RVALID;
    end else begin
        gmem0_blk_n_R = 1'b1;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage4_11001) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage8_11001) & (1'b1 == ap_CS_fsm_pp0_stage8)) | ((1'b0 == ap_block_pp0_stage7_11001) & (1'b1 == ap_CS_fsm_pp0_stage7)) | ((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6)) | ((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2)) | ((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1)) | ((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0)))) begin
        grp_fu_105_ce = 1'b1;
    end else begin
        grp_fu_105_ce = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage4_11001) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6)) | ((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2)))) begin
        grp_fu_109_ce = 1'b1;
    end else begin
        grp_fu_109_ce = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln81_reg_223 == 1'd0) & (ap_enable_reg_pp0_iter0 == 1'b1))) begin
        if (((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2))) begin
            m_axi_gmem0_ARADDR = gmem0_addr_1_reg_233;
        end else if (((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
            m_axi_gmem0_ARADDR = gmem0_addr_reg_227;
        end else begin
            m_axi_gmem0_ARADDR = 'bx;
        end
    end else begin
        m_axi_gmem0_ARADDR = 'bx;
    end
end

always @ (*) begin
    if ((((icmp_ln81_reg_223 == 1'd0) & (1'b0 == ap_block_pp0_stage2_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage2)) | ((icmp_ln81_reg_223 == 1'd0) & (1'b0 == ap_block_pp0_stage1_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1)))) begin
        m_axi_gmem0_ARVALID = 1'b1;
    end else begin
        m_axi_gmem0_ARVALID = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage1_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1)) | ((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0)))) begin
        m_axi_gmem0_RREADY = 1'b1;
    end else begin
        m_axi_gmem0_RREADY = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage7_11001) & (ap_loop_exit_ready_pp0_iter1_reg == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7) & (icmp_ln81_reg_223_pp0_iter1_reg == 1'd1))) begin
        xC_out_ap_vld = 1'b1;
    end else begin
        xC_out_ap_vld = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_pp0_stage0 : begin
            if ((~((ap_start_int == 1'b0) & (ap_idle_pp0_1to2 == 1'b1)) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_pp0_stage1 : begin
            if ((1'b0 == ap_block_pp0_stage1_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end
        end
        ap_ST_fsm_pp0_stage2 : begin
            if ((1'b0 == ap_block_pp0_stage2_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end
        end
        ap_ST_fsm_pp0_stage3 : begin
            if ((1'b0 == ap_block_pp0_stage3_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end
        end
        ap_ST_fsm_pp0_stage4 : begin
            if ((1'b0 == ap_block_pp0_stage4_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end
        end
        ap_ST_fsm_pp0_stage5 : begin
            if ((1'b0 == ap_block_pp0_stage5_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end
        end
        ap_ST_fsm_pp0_stage6 : begin
            if ((1'b0 == ap_block_pp0_stage6_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage7;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end
        end
        ap_ST_fsm_pp0_stage7 : begin
            if (((ap_idle_pp0_0to0 == 1'b1) & (1'b1 == ap_condition_exit_pp0_iter1_stage7))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else if ((1'b0 == ap_block_pp0_stage7_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage8;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage7;
            end
        end
        ap_ST_fsm_pp0_stage8 : begin
            if ((1'b0 == ap_block_pp0_stage8_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage8;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln81_fu_140_p2 = (ap_sig_allocacmp_k_2 + 8'd1);

assign add_ln83_1_fu_166_p2 = ($signed(zext_ln81_fu_146_p1) + $signed(sext_ln75_cast_fu_113_p1));

assign add_ln83_fu_150_p2 = ($signed(zext_ln81_fu_146_p1) + $signed(sext_ln81_cast_fu_117_p1));

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_pp0_stage1 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_pp0_stage2 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_pp0_stage3 = ap_CS_fsm[32'd3];

assign ap_CS_fsm_pp0_stage4 = ap_CS_fsm[32'd4];

assign ap_CS_fsm_pp0_stage5 = ap_CS_fsm[32'd5];

assign ap_CS_fsm_pp0_stage6 = ap_CS_fsm[32'd6];

assign ap_CS_fsm_pp0_stage7 = ap_CS_fsm[32'd7];

assign ap_CS_fsm_pp0_stage8 = ap_CS_fsm[32'd8];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage0_11001 = ((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_block_state10_pp0_stage0_iter1));
end

always @ (*) begin
    ap_block_pp0_stage0_subdone = ((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_block_state10_pp0_stage0_iter1));
end

assign ap_block_pp0_stage1 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage1_11001 = (((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state2_io)) | ((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_block_state11_pp0_stage1_iter1)));
end

always @ (*) begin
    ap_block_pp0_stage1_subdone = (((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state2_io)) | ((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_block_state11_pp0_stage1_iter1)));
end

assign ap_block_pp0_stage2 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage2_11001 = ((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state3_io));
end

always @ (*) begin
    ap_block_pp0_stage2_subdone = ((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state3_io));
end

assign ap_block_pp0_stage3_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_00001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_01001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage8_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage8_subdone = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_state10_pp0_stage0_iter1 = (m_axi_gmem0_RVALID == 1'b0);
end

always @ (*) begin
    ap_block_state11_pp0_stage1_iter1 = (m_axi_gmem0_RVALID == 1'b0);
end

always @ (*) begin
    ap_block_state2_io = ((m_axi_gmem0_ARREADY == 1'b0) & (icmp_ln81_reg_223 == 1'd0));
end

always @ (*) begin
    ap_block_state3_io = ((m_axi_gmem0_ARREADY == 1'b0) & (icmp_ln81_reg_223 == 1'd0));
end

assign ap_done = ap_done_sig;

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage8;

assign ap_ready = ap_ready_sig;

assign bitcast_ln83_1_fu_191_p1 = gmem0_addr_1_read_reg_244;

assign bitcast_ln83_fu_187_p1 = gmem0_addr_read_reg_239;

assign grp_fu_1732_p_ce = grp_fu_109_ce;

assign grp_fu_1732_p_din0 = bitcast_ln83_fu_187_p1;

assign grp_fu_1732_p_din1 = bitcast_ln83_1_fu_191_p1;

assign grp_fu_726_p_ce = grp_fu_105_ce;

assign grp_fu_726_p_din0 = ap_sig_allocacmp_xC_load;

assign grp_fu_726_p_din1 = mul4_reg_259;

assign grp_fu_726_p_opcode = 2'd0;

assign icmp_ln81_fu_134_p2 = ((ap_sig_allocacmp_k_2 == 8'd128) ? 1'b1 : 1'b0);

assign m_axi_gmem0_ARBURST = 2'd0;

assign m_axi_gmem0_ARCACHE = 4'd0;

assign m_axi_gmem0_ARID = 1'd0;

assign m_axi_gmem0_ARLEN = 64'd1;

assign m_axi_gmem0_ARLOCK = 2'd0;

assign m_axi_gmem0_ARPROT = 3'd0;

assign m_axi_gmem0_ARQOS = 4'd0;

assign m_axi_gmem0_ARREGION = 4'd0;

assign m_axi_gmem0_ARSIZE = 3'd0;

assign m_axi_gmem0_ARUSER = 1'd0;

assign m_axi_gmem0_AWADDR = 64'd0;

assign m_axi_gmem0_AWBURST = 2'd0;

assign m_axi_gmem0_AWCACHE = 4'd0;

assign m_axi_gmem0_AWID = 1'd0;

assign m_axi_gmem0_AWLEN = 32'd0;

assign m_axi_gmem0_AWLOCK = 2'd0;

assign m_axi_gmem0_AWPROT = 3'd0;

assign m_axi_gmem0_AWQOS = 4'd0;

assign m_axi_gmem0_AWREGION = 4'd0;

assign m_axi_gmem0_AWSIZE = 3'd0;

assign m_axi_gmem0_AWUSER = 1'd0;

assign m_axi_gmem0_AWVALID = 1'b0;

assign m_axi_gmem0_BREADY = 1'b0;

assign m_axi_gmem0_WDATA = 32'd0;

assign m_axi_gmem0_WID = 1'd0;

assign m_axi_gmem0_WLAST = 1'b0;

assign m_axi_gmem0_WSTRB = 4'd0;

assign m_axi_gmem0_WUSER = 1'd0;

assign m_axi_gmem0_WVALID = 1'b0;

assign sext_ln75_cast_fu_113_p1 = $signed(sext_ln75);

assign sext_ln81_cast_fu_117_p1 = $signed(sext_ln81);

assign sext_ln83_1_fu_172_p1 = $signed(add_ln83_1_fu_166_p2);

assign sext_ln83_fu_156_p1 = $signed(add_ln83_fu_150_p2);

assign xC_out = xC_fu_54;

assign zext_ln81_fu_146_p1 = ap_sig_allocacmp_k_2;

endmodule //vadd_lstm_inference_Pipeline_VITIS_LOOP_81_4

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_VITIS_LOOP_85_5 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        m_axi_gmem0_AWVALID,
        m_axi_gmem0_AWREADY,
        m_axi_gmem0_AWADDR,
        m_axi_gmem0_AWID,
        m_axi_gmem0_AWLEN,
        m_axi_gmem0_AWSIZE,
        m_axi_gmem0_AWBURST,
        m_axi_gmem0_AWLOCK,
        m_axi_gmem0_AWCACHE,
        m_axi_gmem0_AWPROT,
        m_axi_gmem0_AWQOS,
        m_axi_gmem0_AWREGION,
        m_axi_gmem0_AWUSER,
        m_axi_gmem0_WVALID,
        m_axi_gmem0_WREADY,
        m_axi_gmem0_WDATA,
        m_axi_gmem0_WSTRB,
        m_axi_gmem0_WLAST,
        m_axi_gmem0_WID,
        m_axi_gmem0_WUSER,
        m_axi_gmem0_ARVALID,
        m_axi_gmem0_ARREADY,
        m_axi_gmem0_ARADDR,
        m_axi_gmem0_ARID,
        m_axi_gmem0_ARLEN,
        m_axi_gmem0_ARSIZE,
        m_axi_gmem0_ARBURST,
        m_axi_gmem0_ARLOCK,
        m_axi_gmem0_ARCACHE,
        m_axi_gmem0_ARPROT,
        m_axi_gmem0_ARQOS,
        m_axi_gmem0_ARREGION,
        m_axi_gmem0_ARUSER,
        m_axi_gmem0_RVALID,
        m_axi_gmem0_RREADY,
        m_axi_gmem0_RDATA,
        m_axi_gmem0_RLAST,
        m_axi_gmem0_RID,
        m_axi_gmem0_RFIFONUM,
        m_axi_gmem0_RUSER,
        m_axi_gmem0_RRESP,
        m_axi_gmem0_BVALID,
        m_axi_gmem0_BREADY,
        m_axi_gmem0_BRESP,
        m_axi_gmem0_BID,
        m_axi_gmem0_BUSER,
        sext_ln85,
        h0_address0,
        h0_ce0,
        h0_q0,
        hC_out,
        hC_out_ap_vld,
        grp_fu_726_p_din0,
        grp_fu_726_p_din1,
        grp_fu_726_p_opcode,
        grp_fu_726_p_dout0,
        grp_fu_726_p_ce,
        grp_fu_1732_p_din0,
        grp_fu_1732_p_din1,
        grp_fu_1732_p_dout0,
        grp_fu_1732_p_ce
);

parameter    ap_ST_fsm_pp0_stage0 = 9'd1;
parameter    ap_ST_fsm_pp0_stage1 = 9'd2;
parameter    ap_ST_fsm_pp0_stage2 = 9'd4;
parameter    ap_ST_fsm_pp0_stage3 = 9'd8;
parameter    ap_ST_fsm_pp0_stage4 = 9'd16;
parameter    ap_ST_fsm_pp0_stage5 = 9'd32;
parameter    ap_ST_fsm_pp0_stage6 = 9'd64;
parameter    ap_ST_fsm_pp0_stage7 = 9'd128;
parameter    ap_ST_fsm_pp0_stage8 = 9'd256;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output   m_axi_gmem0_AWVALID;
input   m_axi_gmem0_AWREADY;
output  [63:0] m_axi_gmem0_AWADDR;
output  [0:0] m_axi_gmem0_AWID;
output  [31:0] m_axi_gmem0_AWLEN;
output  [2:0] m_axi_gmem0_AWSIZE;
output  [1:0] m_axi_gmem0_AWBURST;
output  [1:0] m_axi_gmem0_AWLOCK;
output  [3:0] m_axi_gmem0_AWCACHE;
output  [2:0] m_axi_gmem0_AWPROT;
output  [3:0] m_axi_gmem0_AWQOS;
output  [3:0] m_axi_gmem0_AWREGION;
output  [0:0] m_axi_gmem0_AWUSER;
output   m_axi_gmem0_WVALID;
input   m_axi_gmem0_WREADY;
output  [31:0] m_axi_gmem0_WDATA;
output  [3:0] m_axi_gmem0_WSTRB;
output   m_axi_gmem0_WLAST;
output  [0:0] m_axi_gmem0_WID;
output  [0:0] m_axi_gmem0_WUSER;
output   m_axi_gmem0_ARVALID;
input   m_axi_gmem0_ARREADY;
output  [63:0] m_axi_gmem0_ARADDR;
output  [0:0] m_axi_gmem0_ARID;
output  [31:0] m_axi_gmem0_ARLEN;
output  [2:0] m_axi_gmem0_ARSIZE;
output  [1:0] m_axi_gmem0_ARBURST;
output  [1:0] m_axi_gmem0_ARLOCK;
output  [3:0] m_axi_gmem0_ARCACHE;
output  [2:0] m_axi_gmem0_ARPROT;
output  [3:0] m_axi_gmem0_ARQOS;
output  [3:0] m_axi_gmem0_ARREGION;
output  [0:0] m_axi_gmem0_ARUSER;
input   m_axi_gmem0_RVALID;
output   m_axi_gmem0_RREADY;
input  [31:0] m_axi_gmem0_RDATA;
input   m_axi_gmem0_RLAST;
input  [0:0] m_axi_gmem0_RID;
input  [8:0] m_axi_gmem0_RFIFONUM;
input  [0:0] m_axi_gmem0_RUSER;
input  [1:0] m_axi_gmem0_RRESP;
input   m_axi_gmem0_BVALID;
output   m_axi_gmem0_BREADY;
input  [1:0] m_axi_gmem0_BRESP;
input  [0:0] m_axi_gmem0_BID;
input  [0:0] m_axi_gmem0_BUSER;
input  [61:0] sext_ln85;
output  [6:0] h0_address0;
output   h0_ce0;
input  [31:0] h0_q0;
output  [31:0] hC_out;
output   hC_out_ap_vld;
output  [31:0] grp_fu_726_p_din0;
output  [31:0] grp_fu_726_p_din1;
output  [1:0] grp_fu_726_p_opcode;
input  [31:0] grp_fu_726_p_dout0;
output   grp_fu_726_p_ce;
output  [31:0] grp_fu_1732_p_din0;
output  [31:0] grp_fu_1732_p_din1;
input  [31:0] grp_fu_1732_p_dout0;
output   grp_fu_1732_p_ce;

reg ap_idle;
reg m_axi_gmem0_RREADY;
reg hC_out_ap_vld;

(* fsm_encoding = "none" *) reg   [8:0] ap_CS_fsm;
wire    ap_CS_fsm_pp0_stage0;
reg    ap_enable_reg_pp0_iter0;
reg    ap_enable_reg_pp0_iter1;
reg    ap_idle_pp0;
wire    ap_CS_fsm_pp0_stage7;
wire    ap_block_pp0_stage7_subdone;
reg   [0:0] icmp_ln85_reg_181;
reg    ap_condition_exit_pp0_iter0_stage7;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
wire    ap_CS_fsm_pp0_stage8;
wire    ap_block_pp0_stage8_subdone;
reg    gmem0_blk_n_R;
wire    ap_CS_fsm_pp0_stage1;
wire    ap_block_pp0_stage1;
wire    ap_block_pp0_stage0_11001;
wire   [0:0] icmp_ln85_fu_116_p2;
reg   [31:0] gmem0_addr_read_reg_190;
reg    ap_block_state2_pp0_stage1_iter0;
reg    ap_block_pp0_stage1_11001;
reg   [31:0] h0_load_reg_195;
wire   [31:0] bitcast_ln87_fu_144_p1;
wire    ap_CS_fsm_pp0_stage2;
wire    ap_block_pp0_stage2_11001;
reg   [31:0] mul8_reg_205;
wire    ap_CS_fsm_pp0_stage6;
wire    ap_block_pp0_stage6_11001;
wire    ap_block_pp0_stage7_11001;
reg    ap_enable_reg_pp0_iter0_reg;
wire   [63:0] zext_ln85_fu_128_p1;
wire    ap_block_pp0_stage0;
reg   [31:0] hC_fu_52;
reg   [31:0] ap_sig_allocacmp_hC_load;
wire    ap_block_pp0_stage7;
wire    ap_loop_init;
reg   [7:0] k_fu_56;
wire   [7:0] add_ln85_fu_122_p2;
reg   [7:0] ap_sig_allocacmp_k_1;
wire    ap_block_pp0_stage7_01001;
reg    h0_ce0_local;
wire    ap_block_pp0_stage2;
reg    grp_fu_91_ce;
wire    ap_block_pp0_stage3_11001;
wire    ap_block_pp0_stage4_11001;
wire    ap_block_pp0_stage5_11001;
wire    ap_block_pp0_stage8_11001;
wire    ap_CS_fsm_pp0_stage3;
wire    ap_CS_fsm_pp0_stage4;
wire    ap_CS_fsm_pp0_stage5;
reg    grp_fu_95_ce;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg   [8:0] ap_NS_fsm;
wire    ap_block_pp0_stage0_subdone;
reg    ap_idle_pp0_1to1;
reg    ap_block_pp0_stage1_subdone;
wire    ap_block_pp0_stage2_subdone;
wire    ap_block_pp0_stage3_subdone;
wire    ap_block_pp0_stage4_subdone;
wire    ap_block_pp0_stage5_subdone;
wire    ap_block_pp0_stage6_subdone;
wire    ap_enable_pp0;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_block_pp0_stage7_00001;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 9'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter0_reg = 1'b0;
#0 hC_fu_52 = 32'd0;
#0 k_fu_56 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage7),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_pp0_stage0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_pp0_stage7_subdone) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_condition_exit_pp0_iter0_stage7)) begin
            ap_enable_reg_pp0_iter0_reg <= 1'b0;
        end else if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
            ap_enable_reg_pp0_iter0_reg <= ap_start_int;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if (((1'b0 == ap_block_pp0_stage7_subdone) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage8_subdone) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        hC_fu_52 <= 32'd0;
    end else if (((1'b0 == ap_block_pp0_stage7_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        hC_fu_52 <= grp_fu_726_p_dout0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if (((ap_enable_reg_pp0_iter0 == 1'b1) & (icmp_ln85_fu_116_p2 == 1'd0))) begin
            k_fu_56 <= add_ln85_fu_122_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            k_fu_56 <= 8'd0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        gmem0_addr_read_reg_190 <= m_axi_gmem0_RDATA;
        h0_load_reg_195 <= h0_q0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        icmp_ln85_reg_181 <= icmp_ln85_fu_116_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6))) begin
        mul8_reg_205 <= grp_fu_1732_p_dout0;
    end
end

always @ (*) begin
    if (((icmp_ln85_reg_181 == 1'd1) & (1'b0 == ap_block_pp0_stage7_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_condition_exit_pp0_iter0_stage7 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage7 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_exit_ready == 1'b1) & (1'b0 == ap_block_pp0_stage7_subdone) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_pp0_stage0)) begin
        ap_enable_reg_pp0_iter0 = ap_start_int;
    end else begin
        ap_enable_reg_pp0_iter0 = ap_enable_reg_pp0_iter0_reg;
    end
end

always @ (*) begin
    if (((ap_start_int == 1'b0) & (ap_idle_pp0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter1 == 1'b0)) begin
        ap_idle_pp0_1to1 = 1'b1;
    end else begin
        ap_idle_pp0_1to1 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage8_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage8))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage7) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        ap_sig_allocacmp_hC_load = grp_fu_726_p_dout0;
    end else begin
        ap_sig_allocacmp_hC_load = hC_fu_52;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_loop_init == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_sig_allocacmp_k_1 = 8'd0;
    end else begin
        ap_sig_allocacmp_k_1 = k_fu_56;
    end
end

always @ (*) begin
    if (((icmp_ln85_reg_181 == 1'd0) & (1'b0 == ap_block_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        gmem0_blk_n_R = m_axi_gmem0_RVALID;
    end else begin
        gmem0_blk_n_R = 1'b1;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage4_11001) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage8_11001) & (1'b1 == ap_CS_fsm_pp0_stage8)) | ((1'b0 == ap_block_pp0_stage7_11001) & (1'b1 == ap_CS_fsm_pp0_stage7)) | ((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6)) | ((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2)) | ((1'b0 == ap_block_pp0_stage1_11001) & (1'b1 == ap_CS_fsm_pp0_stage1)) | ((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0)))) begin
        grp_fu_91_ce = 1'b1;
    end else begin
        grp_fu_91_ce = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage5_11001) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage4_11001) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage6_11001) & (1'b1 == ap_CS_fsm_pp0_stage6)) | ((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2)))) begin
        grp_fu_95_ce = 1'b1;
    end else begin
        grp_fu_95_ce = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        h0_ce0_local = 1'b1;
    end else begin
        h0_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((ap_loop_exit_ready == 1'b1) & (icmp_ln85_reg_181 == 1'd1) & (1'b0 == ap_block_pp0_stage7_11001) & (1'b1 == ap_CS_fsm_pp0_stage7))) begin
        hC_out_ap_vld = 1'b1;
    end else begin
        hC_out_ap_vld = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln85_reg_181 == 1'd0) & (1'b0 == ap_block_pp0_stage1_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1))) begin
        m_axi_gmem0_RREADY = 1'b1;
    end else begin
        m_axi_gmem0_RREADY = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_pp0_stage0 : begin
            if ((~((ap_start_int == 1'b0) & (ap_idle_pp0_1to1 == 1'b1)) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_pp0_stage1 : begin
            if ((1'b0 == ap_block_pp0_stage1_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end
        end
        ap_ST_fsm_pp0_stage2 : begin
            if ((1'b0 == ap_block_pp0_stage2_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end
        end
        ap_ST_fsm_pp0_stage3 : begin
            if ((1'b0 == ap_block_pp0_stage3_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end
        end
        ap_ST_fsm_pp0_stage4 : begin
            if ((1'b0 == ap_block_pp0_stage4_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end
        end
        ap_ST_fsm_pp0_stage5 : begin
            if ((1'b0 == ap_block_pp0_stage5_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end
        end
        ap_ST_fsm_pp0_stage6 : begin
            if ((1'b0 == ap_block_pp0_stage6_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage7;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end
        end
        ap_ST_fsm_pp0_stage7 : begin
            if ((1'b1 == ap_condition_exit_pp0_iter0_stage7)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else if ((1'b0 == ap_block_pp0_stage7_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage8;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage7;
            end
        end
        ap_ST_fsm_pp0_stage8 : begin
            if ((1'b0 == ap_block_pp0_stage8_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage8;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln85_fu_122_p2 = (ap_sig_allocacmp_k_1 + 8'd1);

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_pp0_stage1 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_pp0_stage2 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_pp0_stage3 = ap_CS_fsm[32'd3];

assign ap_CS_fsm_pp0_stage4 = ap_CS_fsm[32'd4];

assign ap_CS_fsm_pp0_stage5 = ap_CS_fsm[32'd5];

assign ap_CS_fsm_pp0_stage6 = ap_CS_fsm[32'd6];

assign ap_CS_fsm_pp0_stage7 = ap_CS_fsm[32'd7];

assign ap_CS_fsm_pp0_stage8 = ap_CS_fsm[32'd8];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage1_11001 = ((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state2_pp0_stage1_iter0));
end

always @ (*) begin
    ap_block_pp0_stage1_subdone = ((ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_block_state2_pp0_stage1_iter0));
end

assign ap_block_pp0_stage2 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_00001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_01001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage7_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage8_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage8_subdone = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_state2_pp0_stage1_iter0 = ((icmp_ln85_reg_181 == 1'd0) & (m_axi_gmem0_RVALID == 1'b0));
end

assign ap_done = ap_done_sig;

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage7;

assign ap_ready = ap_ready_sig;

assign bitcast_ln87_fu_144_p1 = gmem0_addr_read_reg_190;

assign grp_fu_1732_p_ce = grp_fu_95_ce;

assign grp_fu_1732_p_din0 = bitcast_ln87_fu_144_p1;

assign grp_fu_1732_p_din1 = h0_load_reg_195;

assign grp_fu_726_p_ce = grp_fu_91_ce;

assign grp_fu_726_p_din0 = ap_sig_allocacmp_hC_load;

assign grp_fu_726_p_din1 = mul8_reg_205;

assign grp_fu_726_p_opcode = 2'd0;

assign h0_address0 = zext_ln85_fu_128_p1;

assign h0_ce0 = h0_ce0_local;

assign hC_out = hC_fu_52;

assign icmp_ln85_fu_116_p2 = ((ap_sig_allocacmp_k_1 == 8'd128) ? 1'b1 : 1'b0);

assign m_axi_gmem0_ARADDR = 64'd0;

assign m_axi_gmem0_ARBURST = 2'd0;

assign m_axi_gmem0_ARCACHE = 4'd0;

assign m_axi_gmem0_ARID = 1'd0;

assign m_axi_gmem0_ARLEN = 32'd0;

assign m_axi_gmem0_ARLOCK = 2'd0;

assign m_axi_gmem0_ARPROT = 3'd0;

assign m_axi_gmem0_ARQOS = 4'd0;

assign m_axi_gmem0_ARREGION = 4'd0;

assign m_axi_gmem0_ARSIZE = 3'd0;

assign m_axi_gmem0_ARUSER = 1'd0;

assign m_axi_gmem0_ARVALID = 1'b0;

assign m_axi_gmem0_AWADDR = 64'd0;

assign m_axi_gmem0_AWBURST = 2'd0;

assign m_axi_gmem0_AWCACHE = 4'd0;

assign m_axi_gmem0_AWID = 1'd0;

assign m_axi_gmem0_AWLEN = 32'd0;

assign m_axi_gmem0_AWLOCK = 2'd0;

assign m_axi_gmem0_AWPROT = 3'd0;

assign m_axi_gmem0_AWQOS = 4'd0;

assign m_axi_gmem0_AWREGION = 4'd0;

assign m_axi_gmem0_AWSIZE = 3'd0;

assign m_axi_gmem0_AWUSER = 1'd0;

assign m_axi_gmem0_AWVALID = 1'b0;

assign m_axi_gmem0_BREADY = 1'b0;

assign m_axi_gmem0_WDATA = 32'd0;

assign m_axi_gmem0_WID = 1'd0;

assign m_axi_gmem0_WLAST = 1'b0;

assign m_axi_gmem0_WSTRB = 4'd0;

assign m_axi_gmem0_WUSER = 1'd0;

assign m_axi_gmem0_WVALID = 1'b0;

assign zext_ln85_fu_128_p1 = ap_sig_allocacmp_k_1;

endmodule //vadd_lstm_inference_Pipeline_VITIS_LOOP_85_5

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_lstm_inference_Pipeline_VITIS_LOOP_94_6 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        gates0_address0,
        gates0_ce0,
        gates0_q0,
        gates0_1_address0,
        gates0_1_ce0,
        gates0_1_q0,
        gates0_2_address0,
        gates0_2_ce0,
        gates0_2_q0,
        gates0_3_address0,
        gates0_3_ce0,
        gates0_3_q0,
        gates0_4_address0,
        gates0_4_ce0,
        gates0_4_q0,
        c0_address0,
        c0_ce0,
        c0_we0,
        c0_d0,
        c0_address1,
        c0_ce1,
        c0_q1,
        h0_address0,
        h0_ce0,
        h0_we0,
        h0_d0,
        grp_fu_726_p_din0,
        grp_fu_726_p_din1,
        grp_fu_726_p_opcode,
        grp_fu_726_p_dout0,
        grp_fu_726_p_ce,
        grp_fu_1732_p_din0,
        grp_fu_1732_p_din1,
        grp_fu_1732_p_dout0,
        grp_fu_1732_p_ce,
        grp_fu_1736_p_din0,
        grp_fu_1736_p_din1,
        grp_fu_1736_p_dout0,
        grp_fu_1736_p_ce,
        grp_fu_1740_p_din0,
        grp_fu_1740_p_din1,
        grp_fu_1740_p_dout0,
        grp_fu_1740_p_ce,
        grp_sigmoid_fu_1744_p_din1,
        grp_sigmoid_fu_1744_p_dout0,
        grp_sigmoid_fu_1749_p_din1,
        grp_sigmoid_fu_1749_p_dout0,
        grp_sigmoid_fu_1754_p_din1,
        grp_sigmoid_fu_1754_p_dout0,
        grp_tanh_approx_fu_1759_p_din1,
        grp_tanh_approx_fu_1759_p_dout0,
        grp_tanh_approx_fu_1764_p_din1,
        grp_tanh_approx_fu_1764_p_dout0
);

parameter    ap_ST_fsm_pp0_stage0 = 1'd1;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output  [6:0] gates0_address0;
output   gates0_ce0;
input  [31:0] gates0_q0;
output  [6:0] gates0_1_address0;
output   gates0_1_ce0;
input  [31:0] gates0_1_q0;
output  [6:0] gates0_2_address0;
output   gates0_2_ce0;
input  [31:0] gates0_2_q0;
output  [6:0] gates0_3_address0;
output   gates0_3_ce0;
input  [31:0] gates0_3_q0;
output  [6:0] gates0_4_address0;
output   gates0_4_ce0;
input  [31:0] gates0_4_q0;
output  [6:0] c0_address0;
output   c0_ce0;
output   c0_we0;
output  [31:0] c0_d0;
output  [6:0] c0_address1;
output   c0_ce1;
input  [31:0] c0_q1;
output  [6:0] h0_address0;
output   h0_ce0;
output   h0_we0;
output  [31:0] h0_d0;
output  [31:0] grp_fu_726_p_din0;
output  [31:0] grp_fu_726_p_din1;
output  [1:0] grp_fu_726_p_opcode;
input  [31:0] grp_fu_726_p_dout0;
output   grp_fu_726_p_ce;
output  [31:0] grp_fu_1732_p_din0;
output  [31:0] grp_fu_1732_p_din1;
input  [31:0] grp_fu_1732_p_dout0;
output   grp_fu_1732_p_ce;
output  [31:0] grp_fu_1736_p_din0;
output  [31:0] grp_fu_1736_p_din1;
input  [31:0] grp_fu_1736_p_dout0;
output   grp_fu_1736_p_ce;
output  [31:0] grp_fu_1740_p_din0;
output  [31:0] grp_fu_1740_p_din1;
input  [31:0] grp_fu_1740_p_dout0;
output   grp_fu_1740_p_ce;
output  [31:0] grp_sigmoid_fu_1744_p_din1;
input  [31:0] grp_sigmoid_fu_1744_p_dout0;
output  [31:0] grp_sigmoid_fu_1749_p_din1;
input  [31:0] grp_sigmoid_fu_1749_p_dout0;
output  [31:0] grp_sigmoid_fu_1754_p_din1;
input  [31:0] grp_sigmoid_fu_1754_p_dout0;
output  [31:0] grp_tanh_approx_fu_1759_p_din1;
input  [31:0] grp_tanh_approx_fu_1759_p_dout0;
output  [31:0] grp_tanh_approx_fu_1764_p_din1;
input  [31:0] grp_tanh_approx_fu_1764_p_dout0;

reg ap_idle;

(* fsm_encoding = "none" *) reg   [0:0] ap_CS_fsm;
wire    ap_CS_fsm_pp0_stage0;
wire    ap_enable_reg_pp0_iter0;
reg    ap_enable_reg_pp0_iter1;
reg    ap_enable_reg_pp0_iter2;
reg    ap_enable_reg_pp0_iter3;
reg    ap_enable_reg_pp0_iter4;
reg    ap_enable_reg_pp0_iter5;
reg    ap_enable_reg_pp0_iter6;
reg    ap_enable_reg_pp0_iter7;
reg    ap_enable_reg_pp0_iter8;
reg    ap_enable_reg_pp0_iter9;
reg    ap_enable_reg_pp0_iter10;
reg    ap_enable_reg_pp0_iter11;
reg    ap_enable_reg_pp0_iter12;
reg    ap_enable_reg_pp0_iter13;
reg    ap_enable_reg_pp0_iter14;
reg    ap_enable_reg_pp0_iter15;
reg    ap_enable_reg_pp0_iter16;
reg    ap_enable_reg_pp0_iter17;
reg    ap_enable_reg_pp0_iter18;
reg    ap_enable_reg_pp0_iter19;
reg    ap_enable_reg_pp0_iter20;
reg    ap_enable_reg_pp0_iter21;
reg    ap_enable_reg_pp0_iter22;
reg    ap_enable_reg_pp0_iter23;
reg    ap_enable_reg_pp0_iter24;
reg    ap_enable_reg_pp0_iter25;
reg    ap_enable_reg_pp0_iter26;
reg    ap_enable_reg_pp0_iter27;
reg    ap_enable_reg_pp0_iter28;
reg    ap_enable_reg_pp0_iter29;
reg    ap_enable_reg_pp0_iter30;
reg    ap_enable_reg_pp0_iter31;
reg    ap_enable_reg_pp0_iter32;
reg    ap_enable_reg_pp0_iter33;
reg    ap_enable_reg_pp0_iter34;
reg    ap_enable_reg_pp0_iter35;
reg    ap_enable_reg_pp0_iter36;
reg    ap_enable_reg_pp0_iter37;
reg    ap_enable_reg_pp0_iter38;
reg    ap_enable_reg_pp0_iter39;
reg    ap_enable_reg_pp0_iter40;
reg    ap_enable_reg_pp0_iter41;
reg    ap_enable_reg_pp0_iter42;
reg    ap_enable_reg_pp0_iter43;
reg    ap_enable_reg_pp0_iter44;
reg    ap_enable_reg_pp0_iter45;
reg    ap_enable_reg_pp0_iter46;
reg    ap_enable_reg_pp0_iter47;
reg    ap_enable_reg_pp0_iter48;
reg    ap_enable_reg_pp0_iter49;
reg    ap_enable_reg_pp0_iter50;
reg    ap_enable_reg_pp0_iter51;
reg    ap_enable_reg_pp0_iter52;
reg    ap_enable_reg_pp0_iter53;
reg    ap_enable_reg_pp0_iter54;
reg    ap_enable_reg_pp0_iter55;
reg    ap_enable_reg_pp0_iter56;
reg    ap_enable_reg_pp0_iter57;
reg    ap_enable_reg_pp0_iter58;
reg    ap_enable_reg_pp0_iter59;
reg    ap_enable_reg_pp0_iter60;
reg    ap_enable_reg_pp0_iter61;
reg    ap_enable_reg_pp0_iter62;
reg    ap_enable_reg_pp0_iter63;
reg    ap_enable_reg_pp0_iter64;
reg    ap_enable_reg_pp0_iter65;
reg    ap_enable_reg_pp0_iter66;
reg    ap_enable_reg_pp0_iter67;
reg    ap_enable_reg_pp0_iter68;
reg    ap_enable_reg_pp0_iter69;
reg    ap_enable_reg_pp0_iter70;
reg    ap_enable_reg_pp0_iter71;
reg    ap_enable_reg_pp0_iter72;
reg    ap_enable_reg_pp0_iter73;
reg    ap_enable_reg_pp0_iter74;
reg    ap_enable_reg_pp0_iter75;
reg    ap_enable_reg_pp0_iter76;
reg    ap_enable_reg_pp0_iter77;
reg    ap_enable_reg_pp0_iter78;
reg    ap_enable_reg_pp0_iter79;
reg    ap_enable_reg_pp0_iter80;
reg    ap_enable_reg_pp0_iter81;
reg    ap_enable_reg_pp0_iter82;
reg    ap_enable_reg_pp0_iter83;
reg    ap_enable_reg_pp0_iter84;
reg    ap_enable_reg_pp0_iter85;
reg    ap_enable_reg_pp0_iter86;
reg    ap_enable_reg_pp0_iter87;
reg    ap_enable_reg_pp0_iter88;
reg    ap_enable_reg_pp0_iter89;
reg    ap_enable_reg_pp0_iter90;
reg    ap_enable_reg_pp0_iter91;
reg    ap_enable_reg_pp0_iter92;
reg    ap_enable_reg_pp0_iter93;
reg    ap_enable_reg_pp0_iter94;
reg    ap_enable_reg_pp0_iter95;
reg    ap_enable_reg_pp0_iter96;
reg    ap_enable_reg_pp0_iter97;
reg    ap_enable_reg_pp0_iter98;
reg    ap_enable_reg_pp0_iter99;
reg    ap_enable_reg_pp0_iter100;
reg    ap_enable_reg_pp0_iter101;
reg    ap_enable_reg_pp0_iter102;
reg    ap_enable_reg_pp0_iter103;
reg    ap_enable_reg_pp0_iter104;
reg    ap_enable_reg_pp0_iter105;
reg    ap_enable_reg_pp0_iter106;
reg    ap_idle_pp0;
wire    ap_block_pp0_stage0_subdone;
wire   [0:0] icmp_ln94_fu_388_p2;
reg    ap_condition_exit_pp0_iter0_stage0;
wire    ap_loop_exit_ready;
reg    ap_ready_int;
wire    ap_block_pp0_stage0_11001;
reg   [7:0] j_1_reg_710;
wire   [63:0] zext_ln94_fu_400_p1;
reg   [63:0] zext_ln94_reg_720;
reg   [63:0] zext_ln94_reg_720_pp0_iter1_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter2_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter3_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter4_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter5_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter6_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter7_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter8_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter9_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter10_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter11_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter12_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter13_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter14_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter15_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter16_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter17_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter18_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter19_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter20_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter21_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter22_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter23_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter24_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter25_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter26_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter27_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter28_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter29_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter30_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter31_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter32_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter33_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter34_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter35_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter36_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter37_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter38_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter39_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter40_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter41_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter42_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter43_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter44_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter45_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter46_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter47_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter48_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter49_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter50_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter51_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter52_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter53_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter54_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter55_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter56_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter57_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter58_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter59_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter60_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter61_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter62_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter63_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter64_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter65_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter66_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter67_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter68_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter69_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter70_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter71_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter72_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter73_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter74_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter75_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter76_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter77_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter78_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter79_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter80_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter81_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter82_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter83_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter84_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter85_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter86_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter87_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter88_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter89_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter90_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter91_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter92_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter93_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter94_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter95_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter96_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter97_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter98_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter99_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter100_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter101_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter102_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter103_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter104_reg;
reg   [63:0] zext_ln94_reg_720_pp0_iter105_reg;
reg   [6:0] c0_addr_reg_725;
reg   [6:0] c0_addr_reg_725_pp0_iter1_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter2_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter3_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter4_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter5_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter6_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter7_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter8_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter9_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter10_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter11_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter12_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter13_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter14_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter15_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter16_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter17_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter18_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter19_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter20_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter21_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter22_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter23_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter24_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter25_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter26_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter27_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter28_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter29_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter30_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter31_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter32_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter33_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter34_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter35_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter36_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter37_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter38_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter39_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter40_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter41_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter42_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter43_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter44_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter45_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter46_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter47_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter48_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter49_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter50_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter51_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter52_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter53_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter54_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter55_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter56_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter57_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter58_reg;
reg   [6:0] c0_addr_reg_725_pp0_iter59_reg;
wire   [2:0] trunc_ln94_fu_433_p1;
reg   [2:0] trunc_ln94_reg_731;
reg   [2:0] trunc_ln94_reg_731_pp0_iter2_reg;
reg   [5:0] tmp_13_reg_739;
reg   [6:0] tmp_14_reg_744;
reg   [6:0] tmp_15_reg_749;
reg   [31:0] c0_load_reg_754;
reg   [31:0] c0_load_reg_754_pp0_iter2_reg;
reg   [31:0] c0_load_reg_754_pp0_iter3_reg;
reg   [31:0] c0_load_reg_754_pp0_iter4_reg;
reg   [31:0] c0_load_reg_754_pp0_iter5_reg;
reg   [31:0] c0_load_reg_754_pp0_iter6_reg;
reg   [31:0] c0_load_reg_754_pp0_iter7_reg;
reg   [31:0] c0_load_reg_754_pp0_iter8_reg;
reg   [31:0] c0_load_reg_754_pp0_iter9_reg;
reg   [31:0] c0_load_reg_754_pp0_iter10_reg;
reg   [31:0] c0_load_reg_754_pp0_iter11_reg;
reg   [31:0] c0_load_reg_754_pp0_iter12_reg;
reg   [31:0] c0_load_reg_754_pp0_iter13_reg;
reg   [31:0] c0_load_reg_754_pp0_iter14_reg;
reg   [31:0] c0_load_reg_754_pp0_iter15_reg;
reg   [31:0] c0_load_reg_754_pp0_iter16_reg;
reg   [31:0] c0_load_reg_754_pp0_iter17_reg;
reg   [31:0] c0_load_reg_754_pp0_iter18_reg;
reg   [31:0] c0_load_reg_754_pp0_iter19_reg;
reg   [31:0] c0_load_reg_754_pp0_iter20_reg;
reg   [31:0] c0_load_reg_754_pp0_iter21_reg;
reg   [31:0] c0_load_reg_754_pp0_iter22_reg;
reg   [31:0] c0_load_reg_754_pp0_iter23_reg;
reg   [31:0] c0_load_reg_754_pp0_iter24_reg;
wire   [31:0] tmp_fu_581_p13;
reg   [31:0] tmp_reg_859;
wire   [31:0] tmp_6_fu_608_p13;
reg   [31:0] tmp_6_reg_864;
wire   [31:0] tmp_8_fu_635_p13;
reg   [31:0] tmp_8_reg_869;
wire   [31:0] tmp_s_fu_662_p13;
reg   [31:0] tmp_s_reg_874;
reg   [31:0] i_gate_reg_879;
reg   [31:0] i_gate_reg_879_pp0_iter25_reg;
reg   [31:0] i_gate_reg_879_pp0_iter26_reg;
reg   [31:0] i_gate_reg_879_pp0_iter27_reg;
reg   [31:0] i_gate_reg_879_pp0_iter28_reg;
reg   [31:0] i_gate_reg_879_pp0_iter29_reg;
reg   [31:0] i_gate_reg_879_pp0_iter30_reg;
reg   [31:0] i_gate_reg_879_pp0_iter31_reg;
reg   [31:0] i_gate_reg_879_pp0_iter32_reg;
reg   [31:0] i_gate_reg_879_pp0_iter33_reg;
reg   [31:0] i_gate_reg_879_pp0_iter34_reg;
reg   [31:0] i_gate_reg_879_pp0_iter35_reg;
reg   [31:0] i_gate_reg_879_pp0_iter36_reg;
reg   [31:0] i_gate_reg_879_pp0_iter37_reg;
reg   [31:0] i_gate_reg_879_pp0_iter38_reg;
reg   [31:0] i_gate_reg_879_pp0_iter39_reg;
reg   [31:0] i_gate_reg_879_pp0_iter40_reg;
reg   [31:0] i_gate_reg_879_pp0_iter41_reg;
reg   [31:0] i_gate_reg_879_pp0_iter42_reg;
reg   [31:0] i_gate_reg_879_pp0_iter43_reg;
reg   [31:0] i_gate_reg_879_pp0_iter44_reg;
reg   [31:0] f_gate_reg_884;
reg   [31:0] o_gate_reg_889;
reg   [31:0] o_gate_reg_889_pp0_iter25_reg;
reg   [31:0] o_gate_reg_889_pp0_iter26_reg;
reg   [31:0] o_gate_reg_889_pp0_iter27_reg;
reg   [31:0] o_gate_reg_889_pp0_iter28_reg;
reg   [31:0] o_gate_reg_889_pp0_iter29_reg;
reg   [31:0] o_gate_reg_889_pp0_iter30_reg;
reg   [31:0] o_gate_reg_889_pp0_iter31_reg;
reg   [31:0] o_gate_reg_889_pp0_iter32_reg;
reg   [31:0] o_gate_reg_889_pp0_iter33_reg;
reg   [31:0] o_gate_reg_889_pp0_iter34_reg;
reg   [31:0] o_gate_reg_889_pp0_iter35_reg;
reg   [31:0] o_gate_reg_889_pp0_iter36_reg;
reg   [31:0] o_gate_reg_889_pp0_iter37_reg;
reg   [31:0] o_gate_reg_889_pp0_iter38_reg;
reg   [31:0] o_gate_reg_889_pp0_iter39_reg;
reg   [31:0] o_gate_reg_889_pp0_iter40_reg;
reg   [31:0] o_gate_reg_889_pp0_iter41_reg;
reg   [31:0] o_gate_reg_889_pp0_iter42_reg;
reg   [31:0] o_gate_reg_889_pp0_iter43_reg;
reg   [31:0] o_gate_reg_889_pp0_iter44_reg;
reg   [31:0] o_gate_reg_889_pp0_iter45_reg;
reg   [31:0] o_gate_reg_889_pp0_iter46_reg;
reg   [31:0] o_gate_reg_889_pp0_iter47_reg;
reg   [31:0] o_gate_reg_889_pp0_iter48_reg;
reg   [31:0] o_gate_reg_889_pp0_iter49_reg;
reg   [31:0] o_gate_reg_889_pp0_iter50_reg;
reg   [31:0] o_gate_reg_889_pp0_iter51_reg;
reg   [31:0] o_gate_reg_889_pp0_iter52_reg;
reg   [31:0] o_gate_reg_889_pp0_iter53_reg;
reg   [31:0] o_gate_reg_889_pp0_iter54_reg;
reg   [31:0] o_gate_reg_889_pp0_iter55_reg;
reg   [31:0] o_gate_reg_889_pp0_iter56_reg;
reg   [31:0] o_gate_reg_889_pp0_iter57_reg;
reg   [31:0] o_gate_reg_889_pp0_iter58_reg;
reg   [31:0] o_gate_reg_889_pp0_iter59_reg;
reg   [31:0] o_gate_reg_889_pp0_iter60_reg;
reg   [31:0] o_gate_reg_889_pp0_iter61_reg;
reg   [31:0] o_gate_reg_889_pp0_iter62_reg;
reg   [31:0] o_gate_reg_889_pp0_iter63_reg;
reg   [31:0] o_gate_reg_889_pp0_iter64_reg;
reg   [31:0] o_gate_reg_889_pp0_iter65_reg;
reg   [31:0] o_gate_reg_889_pp0_iter66_reg;
reg   [31:0] o_gate_reg_889_pp0_iter67_reg;
reg   [31:0] o_gate_reg_889_pp0_iter68_reg;
reg   [31:0] o_gate_reg_889_pp0_iter69_reg;
reg   [31:0] o_gate_reg_889_pp0_iter70_reg;
reg   [31:0] o_gate_reg_889_pp0_iter71_reg;
reg   [31:0] o_gate_reg_889_pp0_iter72_reg;
reg   [31:0] o_gate_reg_889_pp0_iter73_reg;
reg   [31:0] o_gate_reg_889_pp0_iter74_reg;
reg   [31:0] o_gate_reg_889_pp0_iter75_reg;
reg   [31:0] o_gate_reg_889_pp0_iter76_reg;
reg   [31:0] o_gate_reg_889_pp0_iter77_reg;
reg   [31:0] o_gate_reg_889_pp0_iter78_reg;
reg   [31:0] o_gate_reg_889_pp0_iter79_reg;
reg   [31:0] o_gate_reg_889_pp0_iter80_reg;
reg   [31:0] o_gate_reg_889_pp0_iter81_reg;
reg   [31:0] o_gate_reg_889_pp0_iter82_reg;
reg   [31:0] o_gate_reg_889_pp0_iter83_reg;
reg   [31:0] o_gate_reg_889_pp0_iter84_reg;
reg   [31:0] o_gate_reg_889_pp0_iter85_reg;
reg   [31:0] o_gate_reg_889_pp0_iter86_reg;
reg   [31:0] o_gate_reg_889_pp0_iter87_reg;
reg   [31:0] o_gate_reg_889_pp0_iter88_reg;
reg   [31:0] o_gate_reg_889_pp0_iter89_reg;
reg   [31:0] o_gate_reg_889_pp0_iter90_reg;
reg   [31:0] o_gate_reg_889_pp0_iter91_reg;
reg   [31:0] o_gate_reg_889_pp0_iter92_reg;
reg   [31:0] o_gate_reg_889_pp0_iter93_reg;
reg   [31:0] o_gate_reg_889_pp0_iter94_reg;
reg   [31:0] o_gate_reg_889_pp0_iter95_reg;
reg   [31:0] o_gate_reg_889_pp0_iter96_reg;
reg   [31:0] o_gate_reg_889_pp0_iter97_reg;
reg   [31:0] o_gate_reg_889_pp0_iter98_reg;
reg   [31:0] o_gate_reg_889_pp0_iter99_reg;
reg   [31:0] o_gate_reg_889_pp0_iter100_reg;
reg   [31:0] mul1_reg_894;
reg   [31:0] mul1_reg_894_pp0_iter30_reg;
reg   [31:0] mul1_reg_894_pp0_iter31_reg;
reg   [31:0] mul1_reg_894_pp0_iter32_reg;
reg   [31:0] mul1_reg_894_pp0_iter33_reg;
reg   [31:0] mul1_reg_894_pp0_iter34_reg;
reg   [31:0] mul1_reg_894_pp0_iter35_reg;
reg   [31:0] mul1_reg_894_pp0_iter36_reg;
reg   [31:0] mul1_reg_894_pp0_iter37_reg;
reg   [31:0] mul1_reg_894_pp0_iter38_reg;
reg   [31:0] mul1_reg_894_pp0_iter39_reg;
reg   [31:0] mul1_reg_894_pp0_iter40_reg;
reg   [31:0] mul1_reg_894_pp0_iter41_reg;
reg   [31:0] mul1_reg_894_pp0_iter42_reg;
reg   [31:0] mul1_reg_894_pp0_iter43_reg;
reg   [31:0] mul1_reg_894_pp0_iter44_reg;
reg   [31:0] mul1_reg_894_pp0_iter45_reg;
reg   [31:0] mul1_reg_894_pp0_iter46_reg;
reg   [31:0] mul1_reg_894_pp0_iter47_reg;
reg   [31:0] mul1_reg_894_pp0_iter48_reg;
reg   [31:0] mul1_reg_894_pp0_iter49_reg;
reg   [31:0] g_gate_reg_899;
reg   [31:0] mul2_reg_904;
reg   [31:0] c0_new_reg_909;
reg   [31:0] tmp_1_reg_915;
reg   [31:0] mul3_reg_920;
wire    ap_block_pp0_stage0_ignoreCallOp217;
wire    ap_block_pp0_stage0_ignoreCallOp218;
wire    ap_block_pp0_stage0_ignoreCallOp220;
wire    ap_block_pp0_stage0_ignoreCallOp219;
wire    ap_block_pp0_stage0_ignoreCallOp342;
wire    ap_block_pp0_stage0;
wire   [63:0] zext_ln94_1_fu_543_p1;
wire   [63:0] zext_ln96_fu_552_p1;
wire   [63:0] zext_ln97_fu_560_p1;
wire   [63:0] zext_ln98_fu_568_p1;
reg   [7:0] phi_urem_fu_92;
wire   [7:0] select_ln94_fu_425_p3;
wire    ap_loop_init;
reg   [15:0] phi_mul_fu_96;
wire   [15:0] add_ln94_2_fu_527_p2;
reg   [7:0] j_fu_100;
wire   [7:0] add_ln94_fu_394_p2;
reg   [7:0] ap_sig_allocacmp_j_1;
reg    c0_ce1_local;
reg    c0_we0_local;
reg    c0_ce0_local;
reg    gates0_ce0_local;
reg   [6:0] gates0_address0_local;
reg    gates0_1_ce0_local;
reg   [6:0] gates0_1_address0_local;
reg    gates0_2_ce0_local;
reg   [6:0] gates0_2_address0_local;
reg    gates0_3_ce0_local;
reg   [6:0] gates0_3_address0_local;
reg    gates0_4_ce0_local;
reg   [6:0] gates0_4_address0_local;
reg    h0_we0_local;
reg    h0_ce0_local;
wire   [7:0] add_ln94_1_fu_413_p2;
wire   [0:0] icmp_ln94_1_fu_419_p2;
wire   [6:0] trunc_ln96_fu_437_p1;
wire  signed [7:0] zext_ln96_1_cast_fu_440_p3;
wire   [7:0] mul_ln96_fu_452_p0;
wire   [9:0] mul_ln96_fu_452_p1;
wire   [16:0] mul_ln96_fu_452_p2;
wire   [8:0] zext_ln97_1_cast_fu_468_p3;
wire   [8:0] mul_ln97_fu_479_p0;
wire   [10:0] mul_ln97_fu_479_p1;
wire   [18:0] mul_ln97_fu_479_p2;
wire  signed [8:0] sext_ln98_fu_495_p1;
wire   [8:0] mul_ln98_fu_503_p0;
wire   [10:0] mul_ln98_fu_503_p1;
wire   [18:0] mul_ln98_fu_503_p2;
wire   [4:0] tmp_12_fu_533_p4;
wire   [31:0] tmp_fu_581_p11;
wire   [31:0] tmp_6_fu_608_p11;
wire   [31:0] tmp_8_fu_635_p11;
wire   [31:0] tmp_s_fu_662_p11;
reg    ap_done_reg;
wire    ap_continue_int;
reg    ap_done_int;
reg    ap_loop_exit_ready_pp0_iter1_reg;
reg    ap_loop_exit_ready_pp0_iter2_reg;
reg    ap_loop_exit_ready_pp0_iter3_reg;
reg    ap_loop_exit_ready_pp0_iter4_reg;
reg    ap_loop_exit_ready_pp0_iter5_reg;
reg    ap_loop_exit_ready_pp0_iter6_reg;
reg    ap_loop_exit_ready_pp0_iter7_reg;
reg    ap_loop_exit_ready_pp0_iter8_reg;
reg    ap_loop_exit_ready_pp0_iter9_reg;
reg    ap_loop_exit_ready_pp0_iter10_reg;
reg    ap_loop_exit_ready_pp0_iter11_reg;
reg    ap_loop_exit_ready_pp0_iter12_reg;
reg    ap_loop_exit_ready_pp0_iter13_reg;
reg    ap_loop_exit_ready_pp0_iter14_reg;
reg    ap_loop_exit_ready_pp0_iter15_reg;
reg    ap_loop_exit_ready_pp0_iter16_reg;
reg    ap_loop_exit_ready_pp0_iter17_reg;
reg    ap_loop_exit_ready_pp0_iter18_reg;
reg    ap_loop_exit_ready_pp0_iter19_reg;
reg    ap_loop_exit_ready_pp0_iter20_reg;
reg    ap_loop_exit_ready_pp0_iter21_reg;
reg    ap_loop_exit_ready_pp0_iter22_reg;
reg    ap_loop_exit_ready_pp0_iter23_reg;
reg    ap_loop_exit_ready_pp0_iter24_reg;
reg    ap_loop_exit_ready_pp0_iter25_reg;
reg    ap_loop_exit_ready_pp0_iter26_reg;
reg    ap_loop_exit_ready_pp0_iter27_reg;
reg    ap_loop_exit_ready_pp0_iter28_reg;
reg    ap_loop_exit_ready_pp0_iter29_reg;
reg    ap_loop_exit_ready_pp0_iter30_reg;
reg    ap_loop_exit_ready_pp0_iter31_reg;
reg    ap_loop_exit_ready_pp0_iter32_reg;
reg    ap_loop_exit_ready_pp0_iter33_reg;
reg    ap_loop_exit_ready_pp0_iter34_reg;
reg    ap_loop_exit_ready_pp0_iter35_reg;
reg    ap_loop_exit_ready_pp0_iter36_reg;
reg    ap_loop_exit_ready_pp0_iter37_reg;
reg    ap_loop_exit_ready_pp0_iter38_reg;
reg    ap_loop_exit_ready_pp0_iter39_reg;
reg    ap_loop_exit_ready_pp0_iter40_reg;
reg    ap_loop_exit_ready_pp0_iter41_reg;
reg    ap_loop_exit_ready_pp0_iter42_reg;
reg    ap_loop_exit_ready_pp0_iter43_reg;
reg    ap_loop_exit_ready_pp0_iter44_reg;
reg    ap_loop_exit_ready_pp0_iter45_reg;
reg    ap_loop_exit_ready_pp0_iter46_reg;
reg    ap_loop_exit_ready_pp0_iter47_reg;
reg    ap_loop_exit_ready_pp0_iter48_reg;
reg    ap_loop_exit_ready_pp0_iter49_reg;
reg    ap_loop_exit_ready_pp0_iter50_reg;
reg    ap_loop_exit_ready_pp0_iter51_reg;
reg    ap_loop_exit_ready_pp0_iter52_reg;
reg    ap_loop_exit_ready_pp0_iter53_reg;
reg    ap_loop_exit_ready_pp0_iter54_reg;
reg    ap_loop_exit_ready_pp0_iter55_reg;
reg    ap_loop_exit_ready_pp0_iter56_reg;
reg    ap_loop_exit_ready_pp0_iter57_reg;
reg    ap_loop_exit_ready_pp0_iter58_reg;
reg    ap_loop_exit_ready_pp0_iter59_reg;
reg    ap_loop_exit_ready_pp0_iter60_reg;
reg    ap_loop_exit_ready_pp0_iter61_reg;
reg    ap_loop_exit_ready_pp0_iter62_reg;
reg    ap_loop_exit_ready_pp0_iter63_reg;
reg    ap_loop_exit_ready_pp0_iter64_reg;
reg    ap_loop_exit_ready_pp0_iter65_reg;
reg    ap_loop_exit_ready_pp0_iter66_reg;
reg    ap_loop_exit_ready_pp0_iter67_reg;
reg    ap_loop_exit_ready_pp0_iter68_reg;
reg    ap_loop_exit_ready_pp0_iter69_reg;
reg    ap_loop_exit_ready_pp0_iter70_reg;
reg    ap_loop_exit_ready_pp0_iter71_reg;
reg    ap_loop_exit_ready_pp0_iter72_reg;
reg    ap_loop_exit_ready_pp0_iter73_reg;
reg    ap_loop_exit_ready_pp0_iter74_reg;
reg    ap_loop_exit_ready_pp0_iter75_reg;
reg    ap_loop_exit_ready_pp0_iter76_reg;
reg    ap_loop_exit_ready_pp0_iter77_reg;
reg    ap_loop_exit_ready_pp0_iter78_reg;
reg    ap_loop_exit_ready_pp0_iter79_reg;
reg    ap_loop_exit_ready_pp0_iter80_reg;
reg    ap_loop_exit_ready_pp0_iter81_reg;
reg    ap_loop_exit_ready_pp0_iter82_reg;
reg    ap_loop_exit_ready_pp0_iter83_reg;
reg    ap_loop_exit_ready_pp0_iter84_reg;
reg    ap_loop_exit_ready_pp0_iter85_reg;
reg    ap_loop_exit_ready_pp0_iter86_reg;
reg    ap_loop_exit_ready_pp0_iter87_reg;
reg    ap_loop_exit_ready_pp0_iter88_reg;
reg    ap_loop_exit_ready_pp0_iter89_reg;
reg    ap_loop_exit_ready_pp0_iter90_reg;
reg    ap_loop_exit_ready_pp0_iter91_reg;
reg    ap_loop_exit_ready_pp0_iter92_reg;
reg    ap_loop_exit_ready_pp0_iter93_reg;
reg    ap_loop_exit_ready_pp0_iter94_reg;
reg    ap_loop_exit_ready_pp0_iter95_reg;
reg    ap_loop_exit_ready_pp0_iter96_reg;
reg    ap_loop_exit_ready_pp0_iter97_reg;
reg    ap_loop_exit_ready_pp0_iter98_reg;
reg    ap_loop_exit_ready_pp0_iter99_reg;
reg    ap_loop_exit_ready_pp0_iter100_reg;
reg    ap_loop_exit_ready_pp0_iter101_reg;
reg    ap_loop_exit_ready_pp0_iter102_reg;
reg    ap_loop_exit_ready_pp0_iter103_reg;
reg    ap_loop_exit_ready_pp0_iter104_reg;
reg    ap_loop_exit_ready_pp0_iter105_reg;
reg   [0:0] ap_NS_fsm;
wire    ap_enable_pp0;
wire    ap_start_int;
wire    ap_ready_sig;
wire    ap_done_sig;
wire    ap_block_pp0_stage0_00001;
wire   [16:0] mul_ln96_fu_452_p00;
wire   [18:0] mul_ln97_fu_479_p00;
wire   [18:0] mul_ln98_fu_503_p00;
wire   [2:0] tmp_fu_581_p1;
wire   [2:0] tmp_fu_581_p3;
wire   [2:0] tmp_fu_581_p5;
wire   [2:0] tmp_fu_581_p7;
wire  signed [2:0] tmp_fu_581_p9;
wire   [2:0] tmp_6_fu_608_p1;
wire   [2:0] tmp_6_fu_608_p3;
wire  signed [2:0] tmp_6_fu_608_p5;
wire   [2:0] tmp_6_fu_608_p7;
wire   [2:0] tmp_6_fu_608_p9;
wire  signed [2:0] tmp_8_fu_635_p1;
wire   [2:0] tmp_8_fu_635_p3;
wire   [2:0] tmp_8_fu_635_p5;
wire   [2:0] tmp_8_fu_635_p7;
wire   [2:0] tmp_8_fu_635_p9;
wire   [2:0] tmp_s_fu_662_p1;
wire   [2:0] tmp_s_fu_662_p3;
wire   [2:0] tmp_s_fu_662_p5;
wire  signed [2:0] tmp_s_fu_662_p7;
wire   [2:0] tmp_s_fu_662_p9;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 1'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter2 = 1'b0;
#0 ap_enable_reg_pp0_iter3 = 1'b0;
#0 ap_enable_reg_pp0_iter4 = 1'b0;
#0 ap_enable_reg_pp0_iter5 = 1'b0;
#0 ap_enable_reg_pp0_iter6 = 1'b0;
#0 ap_enable_reg_pp0_iter7 = 1'b0;
#0 ap_enable_reg_pp0_iter8 = 1'b0;
#0 ap_enable_reg_pp0_iter9 = 1'b0;
#0 ap_enable_reg_pp0_iter10 = 1'b0;
#0 ap_enable_reg_pp0_iter11 = 1'b0;
#0 ap_enable_reg_pp0_iter12 = 1'b0;
#0 ap_enable_reg_pp0_iter13 = 1'b0;
#0 ap_enable_reg_pp0_iter14 = 1'b0;
#0 ap_enable_reg_pp0_iter15 = 1'b0;
#0 ap_enable_reg_pp0_iter16 = 1'b0;
#0 ap_enable_reg_pp0_iter17 = 1'b0;
#0 ap_enable_reg_pp0_iter18 = 1'b0;
#0 ap_enable_reg_pp0_iter19 = 1'b0;
#0 ap_enable_reg_pp0_iter20 = 1'b0;
#0 ap_enable_reg_pp0_iter21 = 1'b0;
#0 ap_enable_reg_pp0_iter22 = 1'b0;
#0 ap_enable_reg_pp0_iter23 = 1'b0;
#0 ap_enable_reg_pp0_iter24 = 1'b0;
#0 ap_enable_reg_pp0_iter25 = 1'b0;
#0 ap_enable_reg_pp0_iter26 = 1'b0;
#0 ap_enable_reg_pp0_iter27 = 1'b0;
#0 ap_enable_reg_pp0_iter28 = 1'b0;
#0 ap_enable_reg_pp0_iter29 = 1'b0;
#0 ap_enable_reg_pp0_iter30 = 1'b0;
#0 ap_enable_reg_pp0_iter31 = 1'b0;
#0 ap_enable_reg_pp0_iter32 = 1'b0;
#0 ap_enable_reg_pp0_iter33 = 1'b0;
#0 ap_enable_reg_pp0_iter34 = 1'b0;
#0 ap_enable_reg_pp0_iter35 = 1'b0;
#0 ap_enable_reg_pp0_iter36 = 1'b0;
#0 ap_enable_reg_pp0_iter37 = 1'b0;
#0 ap_enable_reg_pp0_iter38 = 1'b0;
#0 ap_enable_reg_pp0_iter39 = 1'b0;
#0 ap_enable_reg_pp0_iter40 = 1'b0;
#0 ap_enable_reg_pp0_iter41 = 1'b0;
#0 ap_enable_reg_pp0_iter42 = 1'b0;
#0 ap_enable_reg_pp0_iter43 = 1'b0;
#0 ap_enable_reg_pp0_iter44 = 1'b0;
#0 ap_enable_reg_pp0_iter45 = 1'b0;
#0 ap_enable_reg_pp0_iter46 = 1'b0;
#0 ap_enable_reg_pp0_iter47 = 1'b0;
#0 ap_enable_reg_pp0_iter48 = 1'b0;
#0 ap_enable_reg_pp0_iter49 = 1'b0;
#0 ap_enable_reg_pp0_iter50 = 1'b0;
#0 ap_enable_reg_pp0_iter51 = 1'b0;
#0 ap_enable_reg_pp0_iter52 = 1'b0;
#0 ap_enable_reg_pp0_iter53 = 1'b0;
#0 ap_enable_reg_pp0_iter54 = 1'b0;
#0 ap_enable_reg_pp0_iter55 = 1'b0;
#0 ap_enable_reg_pp0_iter56 = 1'b0;
#0 ap_enable_reg_pp0_iter57 = 1'b0;
#0 ap_enable_reg_pp0_iter58 = 1'b0;
#0 ap_enable_reg_pp0_iter59 = 1'b0;
#0 ap_enable_reg_pp0_iter60 = 1'b0;
#0 ap_enable_reg_pp0_iter61 = 1'b0;
#0 ap_enable_reg_pp0_iter62 = 1'b0;
#0 ap_enable_reg_pp0_iter63 = 1'b0;
#0 ap_enable_reg_pp0_iter64 = 1'b0;
#0 ap_enable_reg_pp0_iter65 = 1'b0;
#0 ap_enable_reg_pp0_iter66 = 1'b0;
#0 ap_enable_reg_pp0_iter67 = 1'b0;
#0 ap_enable_reg_pp0_iter68 = 1'b0;
#0 ap_enable_reg_pp0_iter69 = 1'b0;
#0 ap_enable_reg_pp0_iter70 = 1'b0;
#0 ap_enable_reg_pp0_iter71 = 1'b0;
#0 ap_enable_reg_pp0_iter72 = 1'b0;
#0 ap_enable_reg_pp0_iter73 = 1'b0;
#0 ap_enable_reg_pp0_iter74 = 1'b0;
#0 ap_enable_reg_pp0_iter75 = 1'b0;
#0 ap_enable_reg_pp0_iter76 = 1'b0;
#0 ap_enable_reg_pp0_iter77 = 1'b0;
#0 ap_enable_reg_pp0_iter78 = 1'b0;
#0 ap_enable_reg_pp0_iter79 = 1'b0;
#0 ap_enable_reg_pp0_iter80 = 1'b0;
#0 ap_enable_reg_pp0_iter81 = 1'b0;
#0 ap_enable_reg_pp0_iter82 = 1'b0;
#0 ap_enable_reg_pp0_iter83 = 1'b0;
#0 ap_enable_reg_pp0_iter84 = 1'b0;
#0 ap_enable_reg_pp0_iter85 = 1'b0;
#0 ap_enable_reg_pp0_iter86 = 1'b0;
#0 ap_enable_reg_pp0_iter87 = 1'b0;
#0 ap_enable_reg_pp0_iter88 = 1'b0;
#0 ap_enable_reg_pp0_iter89 = 1'b0;
#0 ap_enable_reg_pp0_iter90 = 1'b0;
#0 ap_enable_reg_pp0_iter91 = 1'b0;
#0 ap_enable_reg_pp0_iter92 = 1'b0;
#0 ap_enable_reg_pp0_iter93 = 1'b0;
#0 ap_enable_reg_pp0_iter94 = 1'b0;
#0 ap_enable_reg_pp0_iter95 = 1'b0;
#0 ap_enable_reg_pp0_iter96 = 1'b0;
#0 ap_enable_reg_pp0_iter97 = 1'b0;
#0 ap_enable_reg_pp0_iter98 = 1'b0;
#0 ap_enable_reg_pp0_iter99 = 1'b0;
#0 ap_enable_reg_pp0_iter100 = 1'b0;
#0 ap_enable_reg_pp0_iter101 = 1'b0;
#0 ap_enable_reg_pp0_iter102 = 1'b0;
#0 ap_enable_reg_pp0_iter103 = 1'b0;
#0 ap_enable_reg_pp0_iter104 = 1'b0;
#0 ap_enable_reg_pp0_iter105 = 1'b0;
#0 ap_enable_reg_pp0_iter106 = 1'b0;
#0 phi_urem_fu_92 = 8'd0;
#0 phi_mul_fu_96 = 16'd0;
#0 j_fu_100 = 8'd0;
#0 ap_done_reg = 1'b0;
end

vadd_mul_8ns_10ns_17_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 8 ),
    .din1_WIDTH( 10 ),
    .dout_WIDTH( 17 ))
mul_8ns_10ns_17_1_1_U39(
    .din0(mul_ln96_fu_452_p0),
    .din1(mul_ln96_fu_452_p1),
    .dout(mul_ln96_fu_452_p2)
);

vadd_mul_9ns_11ns_19_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 9 ),
    .din1_WIDTH( 11 ),
    .dout_WIDTH( 19 ))
mul_9ns_11ns_19_1_1_U40(
    .din0(mul_ln97_fu_479_p0),
    .din1(mul_ln97_fu_479_p1),
    .dout(mul_ln97_fu_479_p2)
);

vadd_mul_9ns_11ns_19_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .din0_WIDTH( 9 ),
    .din1_WIDTH( 11 ),
    .dout_WIDTH( 19 ))
mul_9ns_11ns_19_1_1_U41(
    .din0(mul_ln98_fu_503_p0),
    .din1(mul_ln98_fu_503_p1),
    .dout(mul_ln98_fu_503_p2)
);

(* dissolve_hierarchy = "yes" *) vadd_sparsemux_11_3_32_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .CASE0( 3'h0 ),
    .din0_WIDTH( 32 ),
    .CASE1( 3'h1 ),
    .din1_WIDTH( 32 ),
    .CASE2( 3'h2 ),
    .din2_WIDTH( 32 ),
    .CASE3( 3'h3 ),
    .din3_WIDTH( 32 ),
    .CASE4( 3'h4 ),
    .din4_WIDTH( 32 ),
    .def_WIDTH( 32 ),
    .sel_WIDTH( 3 ),
    .dout_WIDTH( 32 ))
sparsemux_11_3_32_1_1_U42(
    .din0(gates0_q0),
    .din1(gates0_1_q0),
    .din2(gates0_2_q0),
    .din3(gates0_3_q0),
    .din4(gates0_4_q0),
    .def(tmp_fu_581_p11),
    .sel(trunc_ln94_reg_731_pp0_iter2_reg),
    .dout(tmp_fu_581_p13)
);

(* dissolve_hierarchy = "yes" *) vadd_sparsemux_11_3_32_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .CASE0( 3'h2 ),
    .din0_WIDTH( 32 ),
    .CASE1( 3'h3 ),
    .din1_WIDTH( 32 ),
    .CASE2( 3'h4 ),
    .din2_WIDTH( 32 ),
    .CASE3( 3'h0 ),
    .din3_WIDTH( 32 ),
    .CASE4( 3'h1 ),
    .din4_WIDTH( 32 ),
    .def_WIDTH( 32 ),
    .sel_WIDTH( 3 ),
    .dout_WIDTH( 32 ))
sparsemux_11_3_32_1_1_U43(
    .din0(gates0_q0),
    .din1(gates0_1_q0),
    .din2(gates0_2_q0),
    .din3(gates0_3_q0),
    .din4(gates0_4_q0),
    .def(tmp_6_fu_608_p11),
    .sel(trunc_ln94_reg_731_pp0_iter2_reg),
    .dout(tmp_6_fu_608_p13)
);

(* dissolve_hierarchy = "yes" *) vadd_sparsemux_11_3_32_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .CASE0( 3'h4 ),
    .din0_WIDTH( 32 ),
    .CASE1( 3'h0 ),
    .din1_WIDTH( 32 ),
    .CASE2( 3'h1 ),
    .din2_WIDTH( 32 ),
    .CASE3( 3'h2 ),
    .din3_WIDTH( 32 ),
    .CASE4( 3'h3 ),
    .din4_WIDTH( 32 ),
    .def_WIDTH( 32 ),
    .sel_WIDTH( 3 ),
    .dout_WIDTH( 32 ))
sparsemux_11_3_32_1_1_U44(
    .din0(gates0_q0),
    .din1(gates0_1_q0),
    .din2(gates0_2_q0),
    .din3(gates0_3_q0),
    .din4(gates0_4_q0),
    .def(tmp_8_fu_635_p11),
    .sel(trunc_ln94_reg_731_pp0_iter2_reg),
    .dout(tmp_8_fu_635_p13)
);

(* dissolve_hierarchy = "yes" *) vadd_sparsemux_11_3_32_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .CASE0( 3'h1 ),
    .din0_WIDTH( 32 ),
    .CASE1( 3'h2 ),
    .din1_WIDTH( 32 ),
    .CASE2( 3'h3 ),
    .din2_WIDTH( 32 ),
    .CASE3( 3'h4 ),
    .din3_WIDTH( 32 ),
    .CASE4( 3'h0 ),
    .din4_WIDTH( 32 ),
    .def_WIDTH( 32 ),
    .sel_WIDTH( 3 ),
    .dout_WIDTH( 32 ))
sparsemux_11_3_32_1_1_U45(
    .din0(gates0_q0),
    .din1(gates0_1_q0),
    .din2(gates0_2_q0),
    .din3(gates0_3_q0),
    .din4(gates0_4_q0),
    .def(tmp_s_fu_662_p11),
    .sel(trunc_ln94_reg_731_pp0_iter2_reg),
    .dout(tmp_s_fu_662_p13)
);

vadd_flow_control_loop_pipe_sequential_init flow_control_loop_pipe_sequential_init_U(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready_sig),
    .ap_done(ap_done_sig),
    .ap_start_int(ap_start_int),
    .ap_loop_init(ap_loop_init),
    .ap_ready_int(ap_ready_int),
    .ap_loop_exit_ready(ap_condition_exit_pp0_iter0_stage0),
    .ap_loop_exit_done(ap_done_int),
    .ap_continue_int(ap_continue_int),
    .ap_done_int(ap_done_int)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_pp0_stage0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue_int == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage0_subdone) & (ap_loop_exit_ready_pp0_iter105_reg == 1'b1))) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if ((1'b1 == ap_condition_exit_pp0_iter0_stage0)) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end else if (((1'b0 == ap_block_pp0_stage0_subdone) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
            ap_enable_reg_pp0_iter1 <= ap_start_int;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter10 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter10 <= ap_enable_reg_pp0_iter9;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter100 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter100 <= ap_enable_reg_pp0_iter99;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter101 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter101 <= ap_enable_reg_pp0_iter100;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter102 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter102 <= ap_enable_reg_pp0_iter101;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter103 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter103 <= ap_enable_reg_pp0_iter102;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter104 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter104 <= ap_enable_reg_pp0_iter103;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter105 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter105 <= ap_enable_reg_pp0_iter104;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter106 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter106 <= ap_enable_reg_pp0_iter105;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter11 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter11 <= ap_enable_reg_pp0_iter10;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter12 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter12 <= ap_enable_reg_pp0_iter11;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter13 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter13 <= ap_enable_reg_pp0_iter12;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter14 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter14 <= ap_enable_reg_pp0_iter13;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter15 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter15 <= ap_enable_reg_pp0_iter14;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter16 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter16 <= ap_enable_reg_pp0_iter15;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter17 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter17 <= ap_enable_reg_pp0_iter16;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter18 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter18 <= ap_enable_reg_pp0_iter17;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter19 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter19 <= ap_enable_reg_pp0_iter18;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter2 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter2 <= ap_enable_reg_pp0_iter1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter20 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter20 <= ap_enable_reg_pp0_iter19;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter21 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter21 <= ap_enable_reg_pp0_iter20;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter22 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter22 <= ap_enable_reg_pp0_iter21;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter23 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter23 <= ap_enable_reg_pp0_iter22;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter24 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter24 <= ap_enable_reg_pp0_iter23;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter25 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter25 <= ap_enable_reg_pp0_iter24;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter26 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter26 <= ap_enable_reg_pp0_iter25;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter27 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter27 <= ap_enable_reg_pp0_iter26;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter28 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter28 <= ap_enable_reg_pp0_iter27;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter29 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter29 <= ap_enable_reg_pp0_iter28;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter3 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter3 <= ap_enable_reg_pp0_iter2;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter30 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter30 <= ap_enable_reg_pp0_iter29;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter31 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter31 <= ap_enable_reg_pp0_iter30;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter32 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter32 <= ap_enable_reg_pp0_iter31;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter33 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter33 <= ap_enable_reg_pp0_iter32;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter34 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter34 <= ap_enable_reg_pp0_iter33;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter35 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter35 <= ap_enable_reg_pp0_iter34;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter36 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter36 <= ap_enable_reg_pp0_iter35;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter37 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter37 <= ap_enable_reg_pp0_iter36;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter38 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter38 <= ap_enable_reg_pp0_iter37;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter39 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter39 <= ap_enable_reg_pp0_iter38;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter4 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter4 <= ap_enable_reg_pp0_iter3;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter40 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter40 <= ap_enable_reg_pp0_iter39;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter41 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter41 <= ap_enable_reg_pp0_iter40;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter42 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter42 <= ap_enable_reg_pp0_iter41;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter43 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter43 <= ap_enable_reg_pp0_iter42;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter44 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter44 <= ap_enable_reg_pp0_iter43;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter45 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter45 <= ap_enable_reg_pp0_iter44;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter46 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter46 <= ap_enable_reg_pp0_iter45;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter47 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter47 <= ap_enable_reg_pp0_iter46;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter48 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter48 <= ap_enable_reg_pp0_iter47;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter49 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter49 <= ap_enable_reg_pp0_iter48;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter5 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter5 <= ap_enable_reg_pp0_iter4;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter50 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter50 <= ap_enable_reg_pp0_iter49;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter51 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter51 <= ap_enable_reg_pp0_iter50;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter52 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter52 <= ap_enable_reg_pp0_iter51;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter53 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter53 <= ap_enable_reg_pp0_iter52;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter54 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter54 <= ap_enable_reg_pp0_iter53;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter55 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter55 <= ap_enable_reg_pp0_iter54;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter56 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter56 <= ap_enable_reg_pp0_iter55;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter57 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter57 <= ap_enable_reg_pp0_iter56;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter58 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter58 <= ap_enable_reg_pp0_iter57;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter59 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter59 <= ap_enable_reg_pp0_iter58;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter6 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter6 <= ap_enable_reg_pp0_iter5;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter60 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter60 <= ap_enable_reg_pp0_iter59;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter61 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter61 <= ap_enable_reg_pp0_iter60;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter62 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter62 <= ap_enable_reg_pp0_iter61;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter63 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter63 <= ap_enable_reg_pp0_iter62;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter64 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter64 <= ap_enable_reg_pp0_iter63;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter65 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter65 <= ap_enable_reg_pp0_iter64;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter66 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter66 <= ap_enable_reg_pp0_iter65;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter67 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter67 <= ap_enable_reg_pp0_iter66;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter68 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter68 <= ap_enable_reg_pp0_iter67;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter69 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter69 <= ap_enable_reg_pp0_iter68;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter7 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter7 <= ap_enable_reg_pp0_iter6;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter70 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter70 <= ap_enable_reg_pp0_iter69;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter71 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter71 <= ap_enable_reg_pp0_iter70;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter72 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter72 <= ap_enable_reg_pp0_iter71;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter73 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter73 <= ap_enable_reg_pp0_iter72;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter74 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter74 <= ap_enable_reg_pp0_iter73;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter75 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter75 <= ap_enable_reg_pp0_iter74;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter76 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter76 <= ap_enable_reg_pp0_iter75;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter77 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter77 <= ap_enable_reg_pp0_iter76;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter78 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter78 <= ap_enable_reg_pp0_iter77;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter79 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter79 <= ap_enable_reg_pp0_iter78;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter8 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter8 <= ap_enable_reg_pp0_iter7;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter80 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter80 <= ap_enable_reg_pp0_iter79;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter81 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter81 <= ap_enable_reg_pp0_iter80;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter82 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter82 <= ap_enable_reg_pp0_iter81;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter83 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter83 <= ap_enable_reg_pp0_iter82;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter84 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter84 <= ap_enable_reg_pp0_iter83;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter85 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter85 <= ap_enable_reg_pp0_iter84;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter86 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter86 <= ap_enable_reg_pp0_iter85;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter87 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter87 <= ap_enable_reg_pp0_iter86;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter88 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter88 <= ap_enable_reg_pp0_iter87;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter89 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter89 <= ap_enable_reg_pp0_iter88;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter9 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter9 <= ap_enable_reg_pp0_iter8;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter90 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter90 <= ap_enable_reg_pp0_iter89;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter91 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter91 <= ap_enable_reg_pp0_iter90;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter92 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter92 <= ap_enable_reg_pp0_iter91;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter93 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter93 <= ap_enable_reg_pp0_iter92;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter94 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter94 <= ap_enable_reg_pp0_iter93;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter95 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter95 <= ap_enable_reg_pp0_iter94;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter96 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter96 <= ap_enable_reg_pp0_iter95;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter97 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter97 <= ap_enable_reg_pp0_iter96;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter98 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter98 <= ap_enable_reg_pp0_iter97;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter99 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter99 <= ap_enable_reg_pp0_iter98;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if (((icmp_ln94_fu_388_p2 == 1'd0) & (ap_enable_reg_pp0_iter0 == 1'b1))) begin
            j_fu_100 <= add_ln94_fu_394_p2;
        end else if ((ap_loop_init == 1'b1)) begin
            j_fu_100 <= 8'd0;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((1'b0 == ap_block_pp0_stage0_11001)) begin
        if (((1'b1 == ap_CS_fsm_pp0_stage0) & (ap_loop_init == 1'b1))) begin
            phi_mul_fu_96 <= 16'd0;
        end else if ((ap_enable_reg_pp0_iter2 == 1'b1)) begin
            phi_mul_fu_96 <= add_ln94_2_fu_527_p2;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        if ((ap_loop_init == 1'b1)) begin
            phi_urem_fu_92 <= 8'd0;
        end else if ((ap_enable_reg_pp0_iter1 == 1'b1)) begin
            phi_urem_fu_92 <= select_ln94_fu_425_p3;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((1'b0 == ap_block_pp0_stage0_11001)) begin
        ap_loop_exit_ready_pp0_iter100_reg <= ap_loop_exit_ready_pp0_iter99_reg;
        ap_loop_exit_ready_pp0_iter101_reg <= ap_loop_exit_ready_pp0_iter100_reg;
        ap_loop_exit_ready_pp0_iter102_reg <= ap_loop_exit_ready_pp0_iter101_reg;
        ap_loop_exit_ready_pp0_iter103_reg <= ap_loop_exit_ready_pp0_iter102_reg;
        ap_loop_exit_ready_pp0_iter104_reg <= ap_loop_exit_ready_pp0_iter103_reg;
        ap_loop_exit_ready_pp0_iter105_reg <= ap_loop_exit_ready_pp0_iter104_reg;
        ap_loop_exit_ready_pp0_iter10_reg <= ap_loop_exit_ready_pp0_iter9_reg;
        ap_loop_exit_ready_pp0_iter11_reg <= ap_loop_exit_ready_pp0_iter10_reg;
        ap_loop_exit_ready_pp0_iter12_reg <= ap_loop_exit_ready_pp0_iter11_reg;
        ap_loop_exit_ready_pp0_iter13_reg <= ap_loop_exit_ready_pp0_iter12_reg;
        ap_loop_exit_ready_pp0_iter14_reg <= ap_loop_exit_ready_pp0_iter13_reg;
        ap_loop_exit_ready_pp0_iter15_reg <= ap_loop_exit_ready_pp0_iter14_reg;
        ap_loop_exit_ready_pp0_iter16_reg <= ap_loop_exit_ready_pp0_iter15_reg;
        ap_loop_exit_ready_pp0_iter17_reg <= ap_loop_exit_ready_pp0_iter16_reg;
        ap_loop_exit_ready_pp0_iter18_reg <= ap_loop_exit_ready_pp0_iter17_reg;
        ap_loop_exit_ready_pp0_iter19_reg <= ap_loop_exit_ready_pp0_iter18_reg;
        ap_loop_exit_ready_pp0_iter20_reg <= ap_loop_exit_ready_pp0_iter19_reg;
        ap_loop_exit_ready_pp0_iter21_reg <= ap_loop_exit_ready_pp0_iter20_reg;
        ap_loop_exit_ready_pp0_iter22_reg <= ap_loop_exit_ready_pp0_iter21_reg;
        ap_loop_exit_ready_pp0_iter23_reg <= ap_loop_exit_ready_pp0_iter22_reg;
        ap_loop_exit_ready_pp0_iter24_reg <= ap_loop_exit_ready_pp0_iter23_reg;
        ap_loop_exit_ready_pp0_iter25_reg <= ap_loop_exit_ready_pp0_iter24_reg;
        ap_loop_exit_ready_pp0_iter26_reg <= ap_loop_exit_ready_pp0_iter25_reg;
        ap_loop_exit_ready_pp0_iter27_reg <= ap_loop_exit_ready_pp0_iter26_reg;
        ap_loop_exit_ready_pp0_iter28_reg <= ap_loop_exit_ready_pp0_iter27_reg;
        ap_loop_exit_ready_pp0_iter29_reg <= ap_loop_exit_ready_pp0_iter28_reg;
        ap_loop_exit_ready_pp0_iter30_reg <= ap_loop_exit_ready_pp0_iter29_reg;
        ap_loop_exit_ready_pp0_iter31_reg <= ap_loop_exit_ready_pp0_iter30_reg;
        ap_loop_exit_ready_pp0_iter32_reg <= ap_loop_exit_ready_pp0_iter31_reg;
        ap_loop_exit_ready_pp0_iter33_reg <= ap_loop_exit_ready_pp0_iter32_reg;
        ap_loop_exit_ready_pp0_iter34_reg <= ap_loop_exit_ready_pp0_iter33_reg;
        ap_loop_exit_ready_pp0_iter35_reg <= ap_loop_exit_ready_pp0_iter34_reg;
        ap_loop_exit_ready_pp0_iter36_reg <= ap_loop_exit_ready_pp0_iter35_reg;
        ap_loop_exit_ready_pp0_iter37_reg <= ap_loop_exit_ready_pp0_iter36_reg;
        ap_loop_exit_ready_pp0_iter38_reg <= ap_loop_exit_ready_pp0_iter37_reg;
        ap_loop_exit_ready_pp0_iter39_reg <= ap_loop_exit_ready_pp0_iter38_reg;
        ap_loop_exit_ready_pp0_iter3_reg <= ap_loop_exit_ready_pp0_iter2_reg;
        ap_loop_exit_ready_pp0_iter40_reg <= ap_loop_exit_ready_pp0_iter39_reg;
        ap_loop_exit_ready_pp0_iter41_reg <= ap_loop_exit_ready_pp0_iter40_reg;
        ap_loop_exit_ready_pp0_iter42_reg <= ap_loop_exit_ready_pp0_iter41_reg;
        ap_loop_exit_ready_pp0_iter43_reg <= ap_loop_exit_ready_pp0_iter42_reg;
        ap_loop_exit_ready_pp0_iter44_reg <= ap_loop_exit_ready_pp0_iter43_reg;
        ap_loop_exit_ready_pp0_iter45_reg <= ap_loop_exit_ready_pp0_iter44_reg;
        ap_loop_exit_ready_pp0_iter46_reg <= ap_loop_exit_ready_pp0_iter45_reg;
        ap_loop_exit_ready_pp0_iter47_reg <= ap_loop_exit_ready_pp0_iter46_reg;
        ap_loop_exit_ready_pp0_iter48_reg <= ap_loop_exit_ready_pp0_iter47_reg;
        ap_loop_exit_ready_pp0_iter49_reg <= ap_loop_exit_ready_pp0_iter48_reg;
        ap_loop_exit_ready_pp0_iter4_reg <= ap_loop_exit_ready_pp0_iter3_reg;
        ap_loop_exit_ready_pp0_iter50_reg <= ap_loop_exit_ready_pp0_iter49_reg;
        ap_loop_exit_ready_pp0_iter51_reg <= ap_loop_exit_ready_pp0_iter50_reg;
        ap_loop_exit_ready_pp0_iter52_reg <= ap_loop_exit_ready_pp0_iter51_reg;
        ap_loop_exit_ready_pp0_iter53_reg <= ap_loop_exit_ready_pp0_iter52_reg;
        ap_loop_exit_ready_pp0_iter54_reg <= ap_loop_exit_ready_pp0_iter53_reg;
        ap_loop_exit_ready_pp0_iter55_reg <= ap_loop_exit_ready_pp0_iter54_reg;
        ap_loop_exit_ready_pp0_iter56_reg <= ap_loop_exit_ready_pp0_iter55_reg;
        ap_loop_exit_ready_pp0_iter57_reg <= ap_loop_exit_ready_pp0_iter56_reg;
        ap_loop_exit_ready_pp0_iter58_reg <= ap_loop_exit_ready_pp0_iter57_reg;
        ap_loop_exit_ready_pp0_iter59_reg <= ap_loop_exit_ready_pp0_iter58_reg;
        ap_loop_exit_ready_pp0_iter5_reg <= ap_loop_exit_ready_pp0_iter4_reg;
        ap_loop_exit_ready_pp0_iter60_reg <= ap_loop_exit_ready_pp0_iter59_reg;
        ap_loop_exit_ready_pp0_iter61_reg <= ap_loop_exit_ready_pp0_iter60_reg;
        ap_loop_exit_ready_pp0_iter62_reg <= ap_loop_exit_ready_pp0_iter61_reg;
        ap_loop_exit_ready_pp0_iter63_reg <= ap_loop_exit_ready_pp0_iter62_reg;
        ap_loop_exit_ready_pp0_iter64_reg <= ap_loop_exit_ready_pp0_iter63_reg;
        ap_loop_exit_ready_pp0_iter65_reg <= ap_loop_exit_ready_pp0_iter64_reg;
        ap_loop_exit_ready_pp0_iter66_reg <= ap_loop_exit_ready_pp0_iter65_reg;
        ap_loop_exit_ready_pp0_iter67_reg <= ap_loop_exit_ready_pp0_iter66_reg;
        ap_loop_exit_ready_pp0_iter68_reg <= ap_loop_exit_ready_pp0_iter67_reg;
        ap_loop_exit_ready_pp0_iter69_reg <= ap_loop_exit_ready_pp0_iter68_reg;
        ap_loop_exit_ready_pp0_iter6_reg <= ap_loop_exit_ready_pp0_iter5_reg;
        ap_loop_exit_ready_pp0_iter70_reg <= ap_loop_exit_ready_pp0_iter69_reg;
        ap_loop_exit_ready_pp0_iter71_reg <= ap_loop_exit_ready_pp0_iter70_reg;
        ap_loop_exit_ready_pp0_iter72_reg <= ap_loop_exit_ready_pp0_iter71_reg;
        ap_loop_exit_ready_pp0_iter73_reg <= ap_loop_exit_ready_pp0_iter72_reg;
        ap_loop_exit_ready_pp0_iter74_reg <= ap_loop_exit_ready_pp0_iter73_reg;
        ap_loop_exit_ready_pp0_iter75_reg <= ap_loop_exit_ready_pp0_iter74_reg;
        ap_loop_exit_ready_pp0_iter76_reg <= ap_loop_exit_ready_pp0_iter75_reg;
        ap_loop_exit_ready_pp0_iter77_reg <= ap_loop_exit_ready_pp0_iter76_reg;
        ap_loop_exit_ready_pp0_iter78_reg <= ap_loop_exit_ready_pp0_iter77_reg;
        ap_loop_exit_ready_pp0_iter79_reg <= ap_loop_exit_ready_pp0_iter78_reg;
        ap_loop_exit_ready_pp0_iter7_reg <= ap_loop_exit_ready_pp0_iter6_reg;
        ap_loop_exit_ready_pp0_iter80_reg <= ap_loop_exit_ready_pp0_iter79_reg;
        ap_loop_exit_ready_pp0_iter81_reg <= ap_loop_exit_ready_pp0_iter80_reg;
        ap_loop_exit_ready_pp0_iter82_reg <= ap_loop_exit_ready_pp0_iter81_reg;
        ap_loop_exit_ready_pp0_iter83_reg <= ap_loop_exit_ready_pp0_iter82_reg;
        ap_loop_exit_ready_pp0_iter84_reg <= ap_loop_exit_ready_pp0_iter83_reg;
        ap_loop_exit_ready_pp0_iter85_reg <= ap_loop_exit_ready_pp0_iter84_reg;
        ap_loop_exit_ready_pp0_iter86_reg <= ap_loop_exit_ready_pp0_iter85_reg;
        ap_loop_exit_ready_pp0_iter87_reg <= ap_loop_exit_ready_pp0_iter86_reg;
        ap_loop_exit_ready_pp0_iter88_reg <= ap_loop_exit_ready_pp0_iter87_reg;
        ap_loop_exit_ready_pp0_iter89_reg <= ap_loop_exit_ready_pp0_iter88_reg;
        ap_loop_exit_ready_pp0_iter8_reg <= ap_loop_exit_ready_pp0_iter7_reg;
        ap_loop_exit_ready_pp0_iter90_reg <= ap_loop_exit_ready_pp0_iter89_reg;
        ap_loop_exit_ready_pp0_iter91_reg <= ap_loop_exit_ready_pp0_iter90_reg;
        ap_loop_exit_ready_pp0_iter92_reg <= ap_loop_exit_ready_pp0_iter91_reg;
        ap_loop_exit_ready_pp0_iter93_reg <= ap_loop_exit_ready_pp0_iter92_reg;
        ap_loop_exit_ready_pp0_iter94_reg <= ap_loop_exit_ready_pp0_iter93_reg;
        ap_loop_exit_ready_pp0_iter95_reg <= ap_loop_exit_ready_pp0_iter94_reg;
        ap_loop_exit_ready_pp0_iter96_reg <= ap_loop_exit_ready_pp0_iter95_reg;
        ap_loop_exit_ready_pp0_iter97_reg <= ap_loop_exit_ready_pp0_iter96_reg;
        ap_loop_exit_ready_pp0_iter98_reg <= ap_loop_exit_ready_pp0_iter97_reg;
        ap_loop_exit_ready_pp0_iter99_reg <= ap_loop_exit_ready_pp0_iter98_reg;
        ap_loop_exit_ready_pp0_iter9_reg <= ap_loop_exit_ready_pp0_iter8_reg;
        c0_addr_reg_725_pp0_iter10_reg <= c0_addr_reg_725_pp0_iter9_reg;
        c0_addr_reg_725_pp0_iter11_reg <= c0_addr_reg_725_pp0_iter10_reg;
        c0_addr_reg_725_pp0_iter12_reg <= c0_addr_reg_725_pp0_iter11_reg;
        c0_addr_reg_725_pp0_iter13_reg <= c0_addr_reg_725_pp0_iter12_reg;
        c0_addr_reg_725_pp0_iter14_reg <= c0_addr_reg_725_pp0_iter13_reg;
        c0_addr_reg_725_pp0_iter15_reg <= c0_addr_reg_725_pp0_iter14_reg;
        c0_addr_reg_725_pp0_iter16_reg <= c0_addr_reg_725_pp0_iter15_reg;
        c0_addr_reg_725_pp0_iter17_reg <= c0_addr_reg_725_pp0_iter16_reg;
        c0_addr_reg_725_pp0_iter18_reg <= c0_addr_reg_725_pp0_iter17_reg;
        c0_addr_reg_725_pp0_iter19_reg <= c0_addr_reg_725_pp0_iter18_reg;
        c0_addr_reg_725_pp0_iter20_reg <= c0_addr_reg_725_pp0_iter19_reg;
        c0_addr_reg_725_pp0_iter21_reg <= c0_addr_reg_725_pp0_iter20_reg;
        c0_addr_reg_725_pp0_iter22_reg <= c0_addr_reg_725_pp0_iter21_reg;
        c0_addr_reg_725_pp0_iter23_reg <= c0_addr_reg_725_pp0_iter22_reg;
        c0_addr_reg_725_pp0_iter24_reg <= c0_addr_reg_725_pp0_iter23_reg;
        c0_addr_reg_725_pp0_iter25_reg <= c0_addr_reg_725_pp0_iter24_reg;
        c0_addr_reg_725_pp0_iter26_reg <= c0_addr_reg_725_pp0_iter25_reg;
        c0_addr_reg_725_pp0_iter27_reg <= c0_addr_reg_725_pp0_iter26_reg;
        c0_addr_reg_725_pp0_iter28_reg <= c0_addr_reg_725_pp0_iter27_reg;
        c0_addr_reg_725_pp0_iter29_reg <= c0_addr_reg_725_pp0_iter28_reg;
        c0_addr_reg_725_pp0_iter2_reg <= c0_addr_reg_725_pp0_iter1_reg;
        c0_addr_reg_725_pp0_iter30_reg <= c0_addr_reg_725_pp0_iter29_reg;
        c0_addr_reg_725_pp0_iter31_reg <= c0_addr_reg_725_pp0_iter30_reg;
        c0_addr_reg_725_pp0_iter32_reg <= c0_addr_reg_725_pp0_iter31_reg;
        c0_addr_reg_725_pp0_iter33_reg <= c0_addr_reg_725_pp0_iter32_reg;
        c0_addr_reg_725_pp0_iter34_reg <= c0_addr_reg_725_pp0_iter33_reg;
        c0_addr_reg_725_pp0_iter35_reg <= c0_addr_reg_725_pp0_iter34_reg;
        c0_addr_reg_725_pp0_iter36_reg <= c0_addr_reg_725_pp0_iter35_reg;
        c0_addr_reg_725_pp0_iter37_reg <= c0_addr_reg_725_pp0_iter36_reg;
        c0_addr_reg_725_pp0_iter38_reg <= c0_addr_reg_725_pp0_iter37_reg;
        c0_addr_reg_725_pp0_iter39_reg <= c0_addr_reg_725_pp0_iter38_reg;
        c0_addr_reg_725_pp0_iter3_reg <= c0_addr_reg_725_pp0_iter2_reg;
        c0_addr_reg_725_pp0_iter40_reg <= c0_addr_reg_725_pp0_iter39_reg;
        c0_addr_reg_725_pp0_iter41_reg <= c0_addr_reg_725_pp0_iter40_reg;
        c0_addr_reg_725_pp0_iter42_reg <= c0_addr_reg_725_pp0_iter41_reg;
        c0_addr_reg_725_pp0_iter43_reg <= c0_addr_reg_725_pp0_iter42_reg;
        c0_addr_reg_725_pp0_iter44_reg <= c0_addr_reg_725_pp0_iter43_reg;
        c0_addr_reg_725_pp0_iter45_reg <= c0_addr_reg_725_pp0_iter44_reg;
        c0_addr_reg_725_pp0_iter46_reg <= c0_addr_reg_725_pp0_iter45_reg;
        c0_addr_reg_725_pp0_iter47_reg <= c0_addr_reg_725_pp0_iter46_reg;
        c0_addr_reg_725_pp0_iter48_reg <= c0_addr_reg_725_pp0_iter47_reg;
        c0_addr_reg_725_pp0_iter49_reg <= c0_addr_reg_725_pp0_iter48_reg;
        c0_addr_reg_725_pp0_iter4_reg <= c0_addr_reg_725_pp0_iter3_reg;
        c0_addr_reg_725_pp0_iter50_reg <= c0_addr_reg_725_pp0_iter49_reg;
        c0_addr_reg_725_pp0_iter51_reg <= c0_addr_reg_725_pp0_iter50_reg;
        c0_addr_reg_725_pp0_iter52_reg <= c0_addr_reg_725_pp0_iter51_reg;
        c0_addr_reg_725_pp0_iter53_reg <= c0_addr_reg_725_pp0_iter52_reg;
        c0_addr_reg_725_pp0_iter54_reg <= c0_addr_reg_725_pp0_iter53_reg;
        c0_addr_reg_725_pp0_iter55_reg <= c0_addr_reg_725_pp0_iter54_reg;
        c0_addr_reg_725_pp0_iter56_reg <= c0_addr_reg_725_pp0_iter55_reg;
        c0_addr_reg_725_pp0_iter57_reg <= c0_addr_reg_725_pp0_iter56_reg;
        c0_addr_reg_725_pp0_iter58_reg <= c0_addr_reg_725_pp0_iter57_reg;
        c0_addr_reg_725_pp0_iter59_reg <= c0_addr_reg_725_pp0_iter58_reg;
        c0_addr_reg_725_pp0_iter5_reg <= c0_addr_reg_725_pp0_iter4_reg;
        c0_addr_reg_725_pp0_iter6_reg <= c0_addr_reg_725_pp0_iter5_reg;
        c0_addr_reg_725_pp0_iter7_reg <= c0_addr_reg_725_pp0_iter6_reg;
        c0_addr_reg_725_pp0_iter8_reg <= c0_addr_reg_725_pp0_iter7_reg;
        c0_addr_reg_725_pp0_iter9_reg <= c0_addr_reg_725_pp0_iter8_reg;
        c0_load_reg_754_pp0_iter10_reg <= c0_load_reg_754_pp0_iter9_reg;
        c0_load_reg_754_pp0_iter11_reg <= c0_load_reg_754_pp0_iter10_reg;
        c0_load_reg_754_pp0_iter12_reg <= c0_load_reg_754_pp0_iter11_reg;
        c0_load_reg_754_pp0_iter13_reg <= c0_load_reg_754_pp0_iter12_reg;
        c0_load_reg_754_pp0_iter14_reg <= c0_load_reg_754_pp0_iter13_reg;
        c0_load_reg_754_pp0_iter15_reg <= c0_load_reg_754_pp0_iter14_reg;
        c0_load_reg_754_pp0_iter16_reg <= c0_load_reg_754_pp0_iter15_reg;
        c0_load_reg_754_pp0_iter17_reg <= c0_load_reg_754_pp0_iter16_reg;
        c0_load_reg_754_pp0_iter18_reg <= c0_load_reg_754_pp0_iter17_reg;
        c0_load_reg_754_pp0_iter19_reg <= c0_load_reg_754_pp0_iter18_reg;
        c0_load_reg_754_pp0_iter20_reg <= c0_load_reg_754_pp0_iter19_reg;
        c0_load_reg_754_pp0_iter21_reg <= c0_load_reg_754_pp0_iter20_reg;
        c0_load_reg_754_pp0_iter22_reg <= c0_load_reg_754_pp0_iter21_reg;
        c0_load_reg_754_pp0_iter23_reg <= c0_load_reg_754_pp0_iter22_reg;
        c0_load_reg_754_pp0_iter24_reg <= c0_load_reg_754_pp0_iter23_reg;
        c0_load_reg_754_pp0_iter2_reg <= c0_load_reg_754;
        c0_load_reg_754_pp0_iter3_reg <= c0_load_reg_754_pp0_iter2_reg;
        c0_load_reg_754_pp0_iter4_reg <= c0_load_reg_754_pp0_iter3_reg;
        c0_load_reg_754_pp0_iter5_reg <= c0_load_reg_754_pp0_iter4_reg;
        c0_load_reg_754_pp0_iter6_reg <= c0_load_reg_754_pp0_iter5_reg;
        c0_load_reg_754_pp0_iter7_reg <= c0_load_reg_754_pp0_iter6_reg;
        c0_load_reg_754_pp0_iter8_reg <= c0_load_reg_754_pp0_iter7_reg;
        c0_load_reg_754_pp0_iter9_reg <= c0_load_reg_754_pp0_iter8_reg;
        c0_new_reg_909 <= grp_fu_726_p_dout0;
        f_gate_reg_884 <= grp_sigmoid_fu_1749_p_dout0;
        g_gate_reg_899 <= grp_tanh_approx_fu_1759_p_dout0;
        i_gate_reg_879 <= grp_sigmoid_fu_1744_p_dout0;
        i_gate_reg_879_pp0_iter25_reg <= i_gate_reg_879;
        i_gate_reg_879_pp0_iter26_reg <= i_gate_reg_879_pp0_iter25_reg;
        i_gate_reg_879_pp0_iter27_reg <= i_gate_reg_879_pp0_iter26_reg;
        i_gate_reg_879_pp0_iter28_reg <= i_gate_reg_879_pp0_iter27_reg;
        i_gate_reg_879_pp0_iter29_reg <= i_gate_reg_879_pp0_iter28_reg;
        i_gate_reg_879_pp0_iter30_reg <= i_gate_reg_879_pp0_iter29_reg;
        i_gate_reg_879_pp0_iter31_reg <= i_gate_reg_879_pp0_iter30_reg;
        i_gate_reg_879_pp0_iter32_reg <= i_gate_reg_879_pp0_iter31_reg;
        i_gate_reg_879_pp0_iter33_reg <= i_gate_reg_879_pp0_iter32_reg;
        i_gate_reg_879_pp0_iter34_reg <= i_gate_reg_879_pp0_iter33_reg;
        i_gate_reg_879_pp0_iter35_reg <= i_gate_reg_879_pp0_iter34_reg;
        i_gate_reg_879_pp0_iter36_reg <= i_gate_reg_879_pp0_iter35_reg;
        i_gate_reg_879_pp0_iter37_reg <= i_gate_reg_879_pp0_iter36_reg;
        i_gate_reg_879_pp0_iter38_reg <= i_gate_reg_879_pp0_iter37_reg;
        i_gate_reg_879_pp0_iter39_reg <= i_gate_reg_879_pp0_iter38_reg;
        i_gate_reg_879_pp0_iter40_reg <= i_gate_reg_879_pp0_iter39_reg;
        i_gate_reg_879_pp0_iter41_reg <= i_gate_reg_879_pp0_iter40_reg;
        i_gate_reg_879_pp0_iter42_reg <= i_gate_reg_879_pp0_iter41_reg;
        i_gate_reg_879_pp0_iter43_reg <= i_gate_reg_879_pp0_iter42_reg;
        i_gate_reg_879_pp0_iter44_reg <= i_gate_reg_879_pp0_iter43_reg;
        mul1_reg_894 <= grp_fu_1732_p_dout0;
        mul1_reg_894_pp0_iter30_reg <= mul1_reg_894;
        mul1_reg_894_pp0_iter31_reg <= mul1_reg_894_pp0_iter30_reg;
        mul1_reg_894_pp0_iter32_reg <= mul1_reg_894_pp0_iter31_reg;
        mul1_reg_894_pp0_iter33_reg <= mul1_reg_894_pp0_iter32_reg;
        mul1_reg_894_pp0_iter34_reg <= mul1_reg_894_pp0_iter33_reg;
        mul1_reg_894_pp0_iter35_reg <= mul1_reg_894_pp0_iter34_reg;
        mul1_reg_894_pp0_iter36_reg <= mul1_reg_894_pp0_iter35_reg;
        mul1_reg_894_pp0_iter37_reg <= mul1_reg_894_pp0_iter36_reg;
        mul1_reg_894_pp0_iter38_reg <= mul1_reg_894_pp0_iter37_reg;
        mul1_reg_894_pp0_iter39_reg <= mul1_reg_894_pp0_iter38_reg;
        mul1_reg_894_pp0_iter40_reg <= mul1_reg_894_pp0_iter39_reg;
        mul1_reg_894_pp0_iter41_reg <= mul1_reg_894_pp0_iter40_reg;
        mul1_reg_894_pp0_iter42_reg <= mul1_reg_894_pp0_iter41_reg;
        mul1_reg_894_pp0_iter43_reg <= mul1_reg_894_pp0_iter42_reg;
        mul1_reg_894_pp0_iter44_reg <= mul1_reg_894_pp0_iter43_reg;
        mul1_reg_894_pp0_iter45_reg <= mul1_reg_894_pp0_iter44_reg;
        mul1_reg_894_pp0_iter46_reg <= mul1_reg_894_pp0_iter45_reg;
        mul1_reg_894_pp0_iter47_reg <= mul1_reg_894_pp0_iter46_reg;
        mul1_reg_894_pp0_iter48_reg <= mul1_reg_894_pp0_iter47_reg;
        mul1_reg_894_pp0_iter49_reg <= mul1_reg_894_pp0_iter48_reg;
        mul2_reg_904 <= grp_fu_1736_p_dout0;
        mul3_reg_920 <= grp_fu_1740_p_dout0;
        o_gate_reg_889 <= grp_sigmoid_fu_1754_p_dout0;
        o_gate_reg_889_pp0_iter100_reg <= o_gate_reg_889_pp0_iter99_reg;
        o_gate_reg_889_pp0_iter25_reg <= o_gate_reg_889;
        o_gate_reg_889_pp0_iter26_reg <= o_gate_reg_889_pp0_iter25_reg;
        o_gate_reg_889_pp0_iter27_reg <= o_gate_reg_889_pp0_iter26_reg;
        o_gate_reg_889_pp0_iter28_reg <= o_gate_reg_889_pp0_iter27_reg;
        o_gate_reg_889_pp0_iter29_reg <= o_gate_reg_889_pp0_iter28_reg;
        o_gate_reg_889_pp0_iter30_reg <= o_gate_reg_889_pp0_iter29_reg;
        o_gate_reg_889_pp0_iter31_reg <= o_gate_reg_889_pp0_iter30_reg;
        o_gate_reg_889_pp0_iter32_reg <= o_gate_reg_889_pp0_iter31_reg;
        o_gate_reg_889_pp0_iter33_reg <= o_gate_reg_889_pp0_iter32_reg;
        o_gate_reg_889_pp0_iter34_reg <= o_gate_reg_889_pp0_iter33_reg;
        o_gate_reg_889_pp0_iter35_reg <= o_gate_reg_889_pp0_iter34_reg;
        o_gate_reg_889_pp0_iter36_reg <= o_gate_reg_889_pp0_iter35_reg;
        o_gate_reg_889_pp0_iter37_reg <= o_gate_reg_889_pp0_iter36_reg;
        o_gate_reg_889_pp0_iter38_reg <= o_gate_reg_889_pp0_iter37_reg;
        o_gate_reg_889_pp0_iter39_reg <= o_gate_reg_889_pp0_iter38_reg;
        o_gate_reg_889_pp0_iter40_reg <= o_gate_reg_889_pp0_iter39_reg;
        o_gate_reg_889_pp0_iter41_reg <= o_gate_reg_889_pp0_iter40_reg;
        o_gate_reg_889_pp0_iter42_reg <= o_gate_reg_889_pp0_iter41_reg;
        o_gate_reg_889_pp0_iter43_reg <= o_gate_reg_889_pp0_iter42_reg;
        o_gate_reg_889_pp0_iter44_reg <= o_gate_reg_889_pp0_iter43_reg;
        o_gate_reg_889_pp0_iter45_reg <= o_gate_reg_889_pp0_iter44_reg;
        o_gate_reg_889_pp0_iter46_reg <= o_gate_reg_889_pp0_iter45_reg;
        o_gate_reg_889_pp0_iter47_reg <= o_gate_reg_889_pp0_iter46_reg;
        o_gate_reg_889_pp0_iter48_reg <= o_gate_reg_889_pp0_iter47_reg;
        o_gate_reg_889_pp0_iter49_reg <= o_gate_reg_889_pp0_iter48_reg;
        o_gate_reg_889_pp0_iter50_reg <= o_gate_reg_889_pp0_iter49_reg;
        o_gate_reg_889_pp0_iter51_reg <= o_gate_reg_889_pp0_iter50_reg;
        o_gate_reg_889_pp0_iter52_reg <= o_gate_reg_889_pp0_iter51_reg;
        o_gate_reg_889_pp0_iter53_reg <= o_gate_reg_889_pp0_iter52_reg;
        o_gate_reg_889_pp0_iter54_reg <= o_gate_reg_889_pp0_iter53_reg;
        o_gate_reg_889_pp0_iter55_reg <= o_gate_reg_889_pp0_iter54_reg;
        o_gate_reg_889_pp0_iter56_reg <= o_gate_reg_889_pp0_iter55_reg;
        o_gate_reg_889_pp0_iter57_reg <= o_gate_reg_889_pp0_iter56_reg;
        o_gate_reg_889_pp0_iter58_reg <= o_gate_reg_889_pp0_iter57_reg;
        o_gate_reg_889_pp0_iter59_reg <= o_gate_reg_889_pp0_iter58_reg;
        o_gate_reg_889_pp0_iter60_reg <= o_gate_reg_889_pp0_iter59_reg;
        o_gate_reg_889_pp0_iter61_reg <= o_gate_reg_889_pp0_iter60_reg;
        o_gate_reg_889_pp0_iter62_reg <= o_gate_reg_889_pp0_iter61_reg;
        o_gate_reg_889_pp0_iter63_reg <= o_gate_reg_889_pp0_iter62_reg;
        o_gate_reg_889_pp0_iter64_reg <= o_gate_reg_889_pp0_iter63_reg;
        o_gate_reg_889_pp0_iter65_reg <= o_gate_reg_889_pp0_iter64_reg;
        o_gate_reg_889_pp0_iter66_reg <= o_gate_reg_889_pp0_iter65_reg;
        o_gate_reg_889_pp0_iter67_reg <= o_gate_reg_889_pp0_iter66_reg;
        o_gate_reg_889_pp0_iter68_reg <= o_gate_reg_889_pp0_iter67_reg;
        o_gate_reg_889_pp0_iter69_reg <= o_gate_reg_889_pp0_iter68_reg;
        o_gate_reg_889_pp0_iter70_reg <= o_gate_reg_889_pp0_iter69_reg;
        o_gate_reg_889_pp0_iter71_reg <= o_gate_reg_889_pp0_iter70_reg;
        o_gate_reg_889_pp0_iter72_reg <= o_gate_reg_889_pp0_iter71_reg;
        o_gate_reg_889_pp0_iter73_reg <= o_gate_reg_889_pp0_iter72_reg;
        o_gate_reg_889_pp0_iter74_reg <= o_gate_reg_889_pp0_iter73_reg;
        o_gate_reg_889_pp0_iter75_reg <= o_gate_reg_889_pp0_iter74_reg;
        o_gate_reg_889_pp0_iter76_reg <= o_gate_reg_889_pp0_iter75_reg;
        o_gate_reg_889_pp0_iter77_reg <= o_gate_reg_889_pp0_iter76_reg;
        o_gate_reg_889_pp0_iter78_reg <= o_gate_reg_889_pp0_iter77_reg;
        o_gate_reg_889_pp0_iter79_reg <= o_gate_reg_889_pp0_iter78_reg;
        o_gate_reg_889_pp0_iter80_reg <= o_gate_reg_889_pp0_iter79_reg;
        o_gate_reg_889_pp0_iter81_reg <= o_gate_reg_889_pp0_iter80_reg;
        o_gate_reg_889_pp0_iter82_reg <= o_gate_reg_889_pp0_iter81_reg;
        o_gate_reg_889_pp0_iter83_reg <= o_gate_reg_889_pp0_iter82_reg;
        o_gate_reg_889_pp0_iter84_reg <= o_gate_reg_889_pp0_iter83_reg;
        o_gate_reg_889_pp0_iter85_reg <= o_gate_reg_889_pp0_iter84_reg;
        o_gate_reg_889_pp0_iter86_reg <= o_gate_reg_889_pp0_iter85_reg;
        o_gate_reg_889_pp0_iter87_reg <= o_gate_reg_889_pp0_iter86_reg;
        o_gate_reg_889_pp0_iter88_reg <= o_gate_reg_889_pp0_iter87_reg;
        o_gate_reg_889_pp0_iter89_reg <= o_gate_reg_889_pp0_iter88_reg;
        o_gate_reg_889_pp0_iter90_reg <= o_gate_reg_889_pp0_iter89_reg;
        o_gate_reg_889_pp0_iter91_reg <= o_gate_reg_889_pp0_iter90_reg;
        o_gate_reg_889_pp0_iter92_reg <= o_gate_reg_889_pp0_iter91_reg;
        o_gate_reg_889_pp0_iter93_reg <= o_gate_reg_889_pp0_iter92_reg;
        o_gate_reg_889_pp0_iter94_reg <= o_gate_reg_889_pp0_iter93_reg;
        o_gate_reg_889_pp0_iter95_reg <= o_gate_reg_889_pp0_iter94_reg;
        o_gate_reg_889_pp0_iter96_reg <= o_gate_reg_889_pp0_iter95_reg;
        o_gate_reg_889_pp0_iter97_reg <= o_gate_reg_889_pp0_iter96_reg;
        o_gate_reg_889_pp0_iter98_reg <= o_gate_reg_889_pp0_iter97_reg;
        o_gate_reg_889_pp0_iter99_reg <= o_gate_reg_889_pp0_iter98_reg;
        tmp_1_reg_915 <= grp_tanh_approx_fu_1764_p_dout0;
        tmp_6_reg_864 <= tmp_6_fu_608_p13;
        tmp_8_reg_869 <= tmp_8_fu_635_p13;
        tmp_reg_859 <= tmp_fu_581_p13;
        tmp_s_reg_874 <= tmp_s_fu_662_p13;
        trunc_ln94_reg_731_pp0_iter2_reg <= trunc_ln94_reg_731;
        zext_ln94_reg_720_pp0_iter100_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter99_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter101_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter100_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter102_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter101_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter103_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter102_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter104_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter103_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter105_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter104_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter10_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter9_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter11_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter10_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter12_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter11_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter13_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter12_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter14_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter13_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter15_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter14_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter16_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter15_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter17_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter16_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter18_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter17_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter19_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter18_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter20_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter19_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter21_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter20_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter22_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter21_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter23_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter22_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter24_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter23_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter25_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter24_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter26_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter25_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter27_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter26_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter28_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter27_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter29_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter28_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter2_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter1_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter30_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter29_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter31_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter30_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter32_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter31_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter33_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter32_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter34_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter33_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter35_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter34_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter36_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter35_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter37_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter36_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter38_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter37_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter39_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter38_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter3_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter2_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter40_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter39_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter41_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter40_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter42_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter41_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter43_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter42_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter44_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter43_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter45_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter44_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter46_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter45_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter47_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter46_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter48_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter47_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter49_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter48_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter4_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter3_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter50_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter49_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter51_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter50_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter52_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter51_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter53_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter52_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter54_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter53_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter55_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter54_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter56_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter55_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter57_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter56_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter58_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter57_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter59_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter58_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter5_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter4_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter60_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter59_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter61_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter60_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter62_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter61_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter63_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter62_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter64_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter63_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter65_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter64_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter66_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter65_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter67_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter66_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter68_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter67_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter69_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter68_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter6_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter5_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter70_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter69_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter71_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter70_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter72_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter71_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter73_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter72_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter74_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter73_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter75_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter74_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter76_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter75_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter77_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter76_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter78_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter77_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter79_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter78_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter7_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter6_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter80_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter79_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter81_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter80_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter82_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter81_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter83_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter82_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter84_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter83_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter85_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter84_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter86_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter85_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter87_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter86_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter88_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter87_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter89_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter88_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter8_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter7_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter90_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter89_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter91_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter90_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter92_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter91_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter93_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter92_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter94_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter93_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter95_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter94_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter96_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter95_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter97_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter96_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter98_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter97_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter99_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter98_reg[7 : 0];
        zext_ln94_reg_720_pp0_iter9_reg[7 : 0] <= zext_ln94_reg_720_pp0_iter8_reg[7 : 0];
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_loop_exit_ready_pp0_iter1_reg <= ap_loop_exit_ready;
        ap_loop_exit_ready_pp0_iter2_reg <= ap_loop_exit_ready_pp0_iter1_reg;
        c0_addr_reg_725 <= zext_ln94_fu_400_p1;
        c0_addr_reg_725_pp0_iter1_reg <= c0_addr_reg_725;
        j_1_reg_710 <= ap_sig_allocacmp_j_1;
        tmp_13_reg_739 <= {{mul_ln96_fu_452_p2[16:11]}};
        tmp_14_reg_744 <= {{mul_ln97_fu_479_p2[18:12]}};
        tmp_15_reg_749 <= {{mul_ln98_fu_503_p2[18:12]}};
        trunc_ln94_reg_731 <= trunc_ln94_fu_433_p1;
        zext_ln94_reg_720[7 : 0] <= zext_ln94_fu_400_p1[7 : 0];
        zext_ln94_reg_720_pp0_iter1_reg[7 : 0] <= zext_ln94_reg_720[7 : 0];
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        c0_load_reg_754 <= c0_q1;
    end
end

always @ (*) begin
    if (((icmp_ln94_fu_388_p2 == 1'd1) & (1'b0 == ap_block_pp0_stage0_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b1;
    end else begin
        ap_condition_exit_pp0_iter0_stage0 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_subdone) & (ap_loop_exit_ready_pp0_iter105_reg == 1'b1))) begin
        ap_done_int = 1'b1;
    end else begin
        ap_done_int = ap_done_reg;
    end
end

always @ (*) begin
    if (((ap_idle_pp0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (ap_start_int == 1'b0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter26 == 1'b0) & (ap_enable_reg_pp0_iter25 == 1'b0) & (ap_enable_reg_pp0_iter24 == 1'b0) & (ap_enable_reg_pp0_iter23 == 1'b0) & (ap_enable_reg_pp0_iter22 == 1'b0) & (ap_enable_reg_pp0_iter21 == 1'b0) & (ap_enable_reg_pp0_iter20 == 1'b0) & (ap_enable_reg_pp0_iter19 == 1'b0) & (ap_enable_reg_pp0_iter18 == 1'b0) & (ap_enable_reg_pp0_iter17 == 1'b0) & (ap_enable_reg_pp0_iter16 == 1'b0) & (ap_enable_reg_pp0_iter15 == 1'b0) & (ap_enable_reg_pp0_iter14 == 1'b0) & (ap_enable_reg_pp0_iter13 == 1'b0) & (ap_enable_reg_pp0_iter12 == 1'b0) & (ap_enable_reg_pp0_iter11 == 1'b0) & (ap_enable_reg_pp0_iter10 == 1'b0) & (ap_enable_reg_pp0_iter9 == 1'b0) & (ap_enable_reg_pp0_iter8 == 1'b0) & (ap_enable_reg_pp0_iter7 == 1'b0) & (ap_enable_reg_pp0_iter6 == 1'b0) & (ap_enable_reg_pp0_iter5 == 1'b0) & (ap_enable_reg_pp0_iter106 == 1'b0) & (ap_enable_reg_pp0_iter105 == 1'b0) & (ap_enable_reg_pp0_iter104 == 1'b0) & (ap_enable_reg_pp0_iter103 == 1'b0) & (ap_enable_reg_pp0_iter102 == 1'b0) & (ap_enable_reg_pp0_iter101 
    == 1'b0) & (ap_enable_reg_pp0_iter4 == 1'b0) & (ap_enable_reg_pp0_iter100 == 1'b0) & (ap_enable_reg_pp0_iter99 == 1'b0) & (ap_enable_reg_pp0_iter98 == 1'b0) & (ap_enable_reg_pp0_iter97 == 1'b0) & (ap_enable_reg_pp0_iter96 == 1'b0) & (ap_enable_reg_pp0_iter95 == 1'b0) & (ap_enable_reg_pp0_iter94 == 1'b0) & (ap_enable_reg_pp0_iter93 == 1'b0) & (ap_enable_reg_pp0_iter92 == 1'b0) & (ap_enable_reg_pp0_iter91 == 1'b0) & (ap_enable_reg_pp0_iter3 == 1'b0) & (ap_enable_reg_pp0_iter90 == 1'b0) & (ap_enable_reg_pp0_iter89 == 1'b0) & (ap_enable_reg_pp0_iter88 == 1'b0) & (ap_enable_reg_pp0_iter87 == 1'b0) & (ap_enable_reg_pp0_iter86 == 1'b0) & (ap_enable_reg_pp0_iter85 == 1'b0) & (ap_enable_reg_pp0_iter84 == 1'b0) & (ap_enable_reg_pp0_iter83 == 1'b0) & (ap_enable_reg_pp0_iter82 == 1'b0) & (ap_enable_reg_pp0_iter81 == 1'b0) & (ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter80 == 1'b0) & (ap_enable_reg_pp0_iter79 == 1'b0) & (ap_enable_reg_pp0_iter78 == 1'b0) & (ap_enable_reg_pp0_iter77 == 1'b0) & (ap_enable_reg_pp0_iter76 
    == 1'b0) & (ap_enable_reg_pp0_iter75 == 1'b0) & (ap_enable_reg_pp0_iter74 == 1'b0) & (ap_enable_reg_pp0_iter73 == 1'b0) & (ap_enable_reg_pp0_iter72 == 1'b0) & (ap_enable_reg_pp0_iter71 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter70 == 1'b0) & (ap_enable_reg_pp0_iter69 == 1'b0) & (ap_enable_reg_pp0_iter68 == 1'b0) & (ap_enable_reg_pp0_iter67 == 1'b0) & (ap_enable_reg_pp0_iter66 == 1'b0) & (ap_enable_reg_pp0_iter65 == 1'b0) & (ap_enable_reg_pp0_iter64 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0) & (ap_enable_reg_pp0_iter63 == 1'b0) & (ap_enable_reg_pp0_iter62 == 1'b0) & (ap_enable_reg_pp0_iter61 == 1'b0) & (ap_enable_reg_pp0_iter60 == 1'b0) & (ap_enable_reg_pp0_iter59 == 1'b0) & (ap_enable_reg_pp0_iter58 == 1'b0) & (ap_enable_reg_pp0_iter57 == 1'b0) & (ap_enable_reg_pp0_iter56 == 1'b0) & (ap_enable_reg_pp0_iter55 == 1'b0) & (ap_enable_reg_pp0_iter54 == 1'b0) & (ap_enable_reg_pp0_iter53 == 1'b0) & (ap_enable_reg_pp0_iter52 == 1'b0) & (ap_enable_reg_pp0_iter51 == 1'b0) & (ap_enable_reg_pp0_iter50 
    == 1'b0) & (ap_enable_reg_pp0_iter49 == 1'b0) & (ap_enable_reg_pp0_iter48 == 1'b0) & (ap_enable_reg_pp0_iter47 == 1'b0) & (ap_enable_reg_pp0_iter46 == 1'b0) & (ap_enable_reg_pp0_iter45 == 1'b0) & (ap_enable_reg_pp0_iter44 == 1'b0) & (ap_enable_reg_pp0_iter43 == 1'b0) & (ap_enable_reg_pp0_iter42 == 1'b0) & (ap_enable_reg_pp0_iter41 == 1'b0) & (ap_enable_reg_pp0_iter40 == 1'b0) & (ap_enable_reg_pp0_iter39 == 1'b0) & (ap_enable_reg_pp0_iter38 == 1'b0) & (ap_enable_reg_pp0_iter37 == 1'b0) & (ap_enable_reg_pp0_iter36 == 1'b0) & (ap_enable_reg_pp0_iter35 == 1'b0) & (ap_enable_reg_pp0_iter34 == 1'b0) & (ap_enable_reg_pp0_iter33 == 1'b0) & (ap_enable_reg_pp0_iter32 == 1'b0) & (ap_enable_reg_pp0_iter31 == 1'b0) & (ap_enable_reg_pp0_iter30 == 1'b0) & (ap_enable_reg_pp0_iter29 == 1'b0) & (ap_enable_reg_pp0_iter28 == 1'b0) & (ap_enable_reg_pp0_iter27 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_subdone) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_ready_int = 1'b1;
    end else begin
        ap_ready_int = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (1'b1 == ap_CS_fsm_pp0_stage0) & (ap_loop_init == 1'b1))) begin
        ap_sig_allocacmp_j_1 = 8'd0;
    end else begin
        ap_sig_allocacmp_j_1 = j_fu_100;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter60 == 1'b1))) begin
        c0_ce0_local = 1'b1;
    end else begin
        c0_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        c0_ce1_local = 1'b1;
    end else begin
        c0_ce1_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter60 == 1'b1))) begin
        c0_we0_local = 1'b1;
    end else begin
        c0_we0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1))) begin
        if ((trunc_ln94_reg_731 == 3'd2)) begin
            gates0_1_address0_local = zext_ln98_fu_568_p1;
        end else if ((trunc_ln94_reg_731 == 3'd0)) begin
            gates0_1_address0_local = zext_ln97_fu_560_p1;
        end else if ((trunc_ln94_reg_731 == 3'd3)) begin
            gates0_1_address0_local = zext_ln96_fu_552_p1;
        end else if ((trunc_ln94_reg_731 == 3'd1)) begin
            gates0_1_address0_local = zext_ln94_1_fu_543_p1;
        end else begin
            gates0_1_address0_local = 'bx;
        end
    end else begin
        gates0_1_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((((trunc_ln94_reg_731 == 3'd3) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd2) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd1) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)))) begin
        gates0_1_ce0_local = 1'b1;
    end else begin
        gates0_1_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1))) begin
        if ((trunc_ln94_reg_731 == 3'd3)) begin
            gates0_2_address0_local = zext_ln98_fu_568_p1;
        end else if ((trunc_ln94_reg_731 == 3'd1)) begin
            gates0_2_address0_local = zext_ln97_fu_560_p1;
        end else if ((trunc_ln94_reg_731 == 3'd4)) begin
            gates0_2_address0_local = zext_ln96_fu_552_p1;
        end else if ((trunc_ln94_reg_731 == 3'd2)) begin
            gates0_2_address0_local = zext_ln94_1_fu_543_p1;
        end else begin
            gates0_2_address0_local = 'bx;
        end
    end else begin
        gates0_2_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((((trunc_ln94_reg_731 == 3'd4) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd3) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd2) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd1) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)))) begin
        gates0_2_ce0_local = 1'b1;
    end else begin
        gates0_2_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1))) begin
        if ((trunc_ln94_reg_731 == 3'd4)) begin
            gates0_3_address0_local = zext_ln98_fu_568_p1;
        end else if ((trunc_ln94_reg_731 == 3'd2)) begin
            gates0_3_address0_local = zext_ln97_fu_560_p1;
        end else if ((trunc_ln94_reg_731 == 3'd0)) begin
            gates0_3_address0_local = zext_ln96_fu_552_p1;
        end else if ((trunc_ln94_reg_731 == 3'd3)) begin
            gates0_3_address0_local = zext_ln94_1_fu_543_p1;
        end else begin
            gates0_3_address0_local = 'bx;
        end
    end else begin
        gates0_3_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((((trunc_ln94_reg_731 == 3'd4) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd3) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd2) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)))) begin
        gates0_3_ce0_local = 1'b1;
    end else begin
        gates0_3_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1))) begin
        if ((trunc_ln94_reg_731 == 3'd0)) begin
            gates0_4_address0_local = zext_ln98_fu_568_p1;
        end else if ((trunc_ln94_reg_731 == 3'd3)) begin
            gates0_4_address0_local = zext_ln97_fu_560_p1;
        end else if ((trunc_ln94_reg_731 == 3'd1)) begin
            gates0_4_address0_local = zext_ln96_fu_552_p1;
        end else if ((trunc_ln94_reg_731 == 3'd4)) begin
            gates0_4_address0_local = zext_ln94_1_fu_543_p1;
        end else begin
            gates0_4_address0_local = 'bx;
        end
    end else begin
        gates0_4_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((((trunc_ln94_reg_731 == 3'd4) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd3) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd1) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)))) begin
        gates0_4_ce0_local = 1'b1;
    end else begin
        gates0_4_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter2 == 1'b1))) begin
        if ((trunc_ln94_reg_731 == 3'd1)) begin
            gates0_address0_local = zext_ln98_fu_568_p1;
        end else if ((trunc_ln94_reg_731 == 3'd4)) begin
            gates0_address0_local = zext_ln97_fu_560_p1;
        end else if ((trunc_ln94_reg_731 == 3'd2)) begin
            gates0_address0_local = zext_ln96_fu_552_p1;
        end else if ((trunc_ln94_reg_731 == 3'd0)) begin
            gates0_address0_local = zext_ln94_1_fu_543_p1;
        end else begin
            gates0_address0_local = 'bx;
        end
    end else begin
        gates0_address0_local = 'bx;
    end
end

always @ (*) begin
    if ((((trunc_ln94_reg_731 == 3'd4) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd2) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd1) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)) | ((trunc_ln94_reg_731 == 3'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter2 == 1'b1)))) begin
        gates0_ce0_local = 1'b1;
    end else begin
        gates0_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter106 == 1'b1))) begin
        h0_ce0_local = 1'b1;
    end else begin
        h0_ce0_local = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter106 == 1'b1))) begin
        h0_we0_local = 1'b1;
    end else begin
        h0_we0_local = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_pp0_stage0 : begin
            ap_NS_fsm = ap_ST_fsm_pp0_stage0;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln94_1_fu_413_p2 = (phi_urem_fu_92 + 8'd1);

assign add_ln94_2_fu_527_p2 = (phi_mul_fu_96 + 16'd410);

assign add_ln94_fu_394_p2 = (ap_sig_allocacmp_j_1 + 8'd1);

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd0];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_00001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_ignoreCallOp217 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_ignoreCallOp218 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_ignoreCallOp219 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_ignoreCallOp220 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_ignoreCallOp342 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_subdone = ~(1'b1 == 1'b1);

assign ap_done = ap_done_sig;

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_enable_reg_pp0_iter0 = ap_start_int;

assign ap_loop_exit_ready = ap_condition_exit_pp0_iter0_stage0;

assign ap_ready = ap_ready_sig;

assign c0_address0 = c0_addr_reg_725_pp0_iter59_reg;

assign c0_address1 = zext_ln94_fu_400_p1;

assign c0_ce0 = c0_ce0_local;

assign c0_ce1 = c0_ce1_local;

assign c0_d0 = c0_new_reg_909;

assign c0_we0 = c0_we0_local;

assign gates0_1_address0 = gates0_1_address0_local;

assign gates0_1_ce0 = gates0_1_ce0_local;

assign gates0_2_address0 = gates0_2_address0_local;

assign gates0_2_ce0 = gates0_2_ce0_local;

assign gates0_3_address0 = gates0_3_address0_local;

assign gates0_3_ce0 = gates0_3_ce0_local;

assign gates0_4_address0 = gates0_4_address0_local;

assign gates0_4_ce0 = gates0_4_ce0_local;

assign gates0_address0 = gates0_address0_local;

assign gates0_ce0 = gates0_ce0_local;

assign grp_fu_1732_p_ce = 1'b1;

assign grp_fu_1732_p_din0 = f_gate_reg_884;

assign grp_fu_1732_p_din1 = c0_load_reg_754_pp0_iter24_reg;

assign grp_fu_1736_p_ce = 1'b1;

assign grp_fu_1736_p_din0 = i_gate_reg_879_pp0_iter44_reg;

assign grp_fu_1736_p_din1 = g_gate_reg_899;

assign grp_fu_1740_p_ce = 1'b1;

assign grp_fu_1740_p_din0 = o_gate_reg_889_pp0_iter100_reg;

assign grp_fu_1740_p_din1 = tmp_1_reg_915;

assign grp_fu_726_p_ce = 1'b1;

assign grp_fu_726_p_din0 = mul1_reg_894_pp0_iter49_reg;

assign grp_fu_726_p_din1 = mul2_reg_904;

assign grp_fu_726_p_opcode = 2'd0;

assign grp_sigmoid_fu_1744_p_din1 = tmp_reg_859;

assign grp_sigmoid_fu_1749_p_din1 = tmp_6_reg_864;

assign grp_sigmoid_fu_1754_p_din1 = tmp_s_reg_874;

assign grp_tanh_approx_fu_1759_p_din1 = tmp_8_reg_869;

assign grp_tanh_approx_fu_1764_p_din1 = c0_new_reg_909;

assign h0_address0 = zext_ln94_reg_720_pp0_iter105_reg;

assign h0_ce0 = h0_ce0_local;

assign h0_d0 = mul3_reg_920;

assign h0_we0 = h0_we0_local;

assign icmp_ln94_1_fu_419_p2 = ((add_ln94_1_fu_413_p2 < 8'd5) ? 1'b1 : 1'b0);

assign icmp_ln94_fu_388_p2 = ((ap_sig_allocacmp_j_1 == 8'd128) ? 1'b1 : 1'b0);

assign mul_ln96_fu_452_p0 = mul_ln96_fu_452_p00;

assign mul_ln96_fu_452_p00 = $unsigned(zext_ln96_1_cast_fu_440_p3);

assign mul_ln96_fu_452_p1 = 17'd410;

assign mul_ln97_fu_479_p0 = mul_ln97_fu_479_p00;

assign mul_ln97_fu_479_p00 = zext_ln97_1_cast_fu_468_p3;

assign mul_ln97_fu_479_p1 = 19'd820;

assign mul_ln98_fu_503_p0 = mul_ln98_fu_503_p00;

assign mul_ln98_fu_503_p00 = $unsigned(sext_ln98_fu_495_p1);

assign mul_ln98_fu_503_p1 = 19'd820;

assign select_ln94_fu_425_p3 = ((icmp_ln94_1_fu_419_p2[0:0] == 1'b1) ? add_ln94_1_fu_413_p2 : 8'd0);

assign sext_ln98_fu_495_p1 = zext_ln96_1_cast_fu_440_p3;

assign tmp_12_fu_533_p4 = {{phi_mul_fu_96[15:11]}};

assign tmp_6_fu_608_p11 = 'bx;

assign tmp_8_fu_635_p11 = 'bx;

assign tmp_fu_581_p11 = 'bx;

assign tmp_s_fu_662_p11 = 'bx;

assign trunc_ln94_fu_433_p1 = phi_urem_fu_92[2:0];

assign trunc_ln96_fu_437_p1 = j_1_reg_710[6:0];

assign zext_ln94_1_fu_543_p1 = tmp_12_fu_533_p4;

assign zext_ln94_fu_400_p1 = ap_sig_allocacmp_j_1;

assign zext_ln96_1_cast_fu_440_p3 = {{1'd1}, {trunc_ln96_fu_437_p1}};

assign zext_ln96_fu_552_p1 = tmp_13_reg_739;

assign zext_ln97_1_cast_fu_468_p3 = {{1'd1}, {j_1_reg_710}};

assign zext_ln97_fu_560_p1 = tmp_14_reg_744;

assign zext_ln98_fu_568_p1 = tmp_15_reg_749;

always @ (posedge ap_clk) begin
    zext_ln94_reg_720[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter1_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter2_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter3_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter4_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter5_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter6_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter7_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter8_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter9_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter10_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter11_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter12_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter13_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter14_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter15_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter16_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter17_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter18_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter19_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter20_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter21_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter22_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter23_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter24_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter25_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter26_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter27_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter28_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter29_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter30_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter31_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter32_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter33_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter34_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter35_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter36_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter37_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter38_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter39_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter40_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter41_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter42_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter43_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter44_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter45_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter46_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter47_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter48_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter49_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter50_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter51_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter52_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter53_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter54_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter55_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter56_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter57_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter58_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter59_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter60_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter61_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter62_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter63_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter64_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter65_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter66_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter67_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter68_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter69_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter70_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter71_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter72_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter73_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter74_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter75_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter76_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter77_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter78_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter79_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter80_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter81_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter82_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter83_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter84_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter85_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter86_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter87_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter88_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter89_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter90_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter91_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter92_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter93_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter94_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter95_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter96_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter97_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter98_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter99_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter100_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter101_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter102_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter103_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter104_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
    zext_ln94_reg_720_pp0_iter105_reg[63:8] <= 56'b00000000000000000000000000000000000000000000000000000000;
end

endmodule //vadd_lstm_inference_Pipeline_VITIS_LOOP_94_6

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================
`timescale 1 ns / 1 ps
module vadd_lstm_inference_c0_RAM_AUTO_1R1W (
     
    address0, ce0,
    d0, we0, 
    
      
    address1, ce1,
    
    q1, 
     
    reset, clk);

parameter DataWidth = 32;
parameter AddressWidth = 7;
parameter AddressRange = 128;
 
input[AddressWidth-1:0] address0;
input ce0;
input[DataWidth-1:0] d0;
input we0; 

 
input[AddressWidth-1:0] address1;
input ce1;

output reg[DataWidth-1:0] q1; 

input reset;
input clk;

(* ram_style = "auto"  *)reg [DataWidth-1:0] ram[0:AddressRange-1];


 

always @(posedge clk)  
begin 
    if (ce0) begin
        if (we0) 
            ram[address0] <= d0; 
    end
end 



 
  



always @(posedge clk) 
begin 
    if (ce1) begin
        q1 <= ram[address1];
    end
end 

 
 

endmodule


// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================
`timescale 1 ns / 1 ps
module vadd_lstm_inference_gates0_RAM_AUTO_1R1W (
     
    address0, ce0,
    d0, we0, 
    q0, 
     
    reset, clk);

parameter DataWidth = 32;
parameter AddressWidth = 7;
parameter AddressRange = 103;
 
input[AddressWidth-1:0] address0;
input ce0;
input[DataWidth-1:0] d0;
input we0; 
output reg[DataWidth-1:0] q0; 

input reset;
input clk;

(* ram_style = "auto"  *)reg [DataWidth-1:0] ram[0:AddressRange-1];


 





//read first
always @(posedge clk)  
begin 
    if (ce0) begin
        if (we0) 
            ram[address0] <= d0; 
        q0 <= ram[address0];

    end
end 
 
 

endmodule


// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================
`timescale 1 ns / 1 ps
module vadd_lstm_inference_h0_RAM_AUTO_1R1W (
     
    address0, ce0,
    d0, we0, 
    q0, 
     
    reset, clk);

parameter DataWidth = 32;
parameter AddressWidth = 7;
parameter AddressRange = 128;
 
input[AddressWidth-1:0] address0;
input ce0;
input[DataWidth-1:0] d0;
input we0; 
output reg[DataWidth-1:0] q0; 

input reset;
input clk;

(* ram_style = "auto"  *)reg [DataWidth-1:0] ram[0:AddressRange-1];


 





//read first
always @(posedge clk)  
begin 
    if (ce0) begin
        if (we0) 
            ram[address0] <= d0; 
        q0 <= ram[address0];

    end
end 
 
 

endmodule


// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================
`timescale 1 ns / 1 ps
module vadd_lstm_inference_logits_RAM_AUTO_1R1W (
     
    address0, ce0,
    d0, we0, 
    q0, 
     
    reset, clk);

parameter DataWidth = 32;
parameter AddressWidth = 4;
parameter AddressRange = 10;
 
input[AddressWidth-1:0] address0;
input ce0;
input[DataWidth-1:0] d0;
input we0; 
output reg[DataWidth-1:0] q0; 

input reset;
input clk;

(* ram_style = "auto"  *)reg [DataWidth-1:0] ram[0:AddressRange-1];


 





//read first
always @(posedge clk)  
begin 
    if (ce0) begin
        if (we0) 
            ram[address0] <= d0; 
        q0 <= ram[address0];

    end
end 
 
 

endmodule


// 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689

`timescale 1 ns / 1 ps

 module vadd_mul_8ns_10ns_17_1_1(din0, din1, dout);
parameter ID = 1;
parameter NUM_STAGE = 0;
parameter din0_WIDTH = 14;
parameter din1_WIDTH = 12;
parameter dout_WIDTH = 26;

input [din0_WIDTH - 1 : 0] din0; 
input [din1_WIDTH - 1 : 0] din1; 
output [dout_WIDTH - 1 : 0] dout;

wire signed [dout_WIDTH - 1 : 0] tmp_product;
























assign tmp_product = $signed({1'b0, din0}) * $signed({1'b0, din1});











assign dout = tmp_product;





















endmodule

// 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689

`timescale 1 ns / 1 ps

 module vadd_mul_9ns_11ns_19_1_1(din0, din1, dout);
parameter ID = 1;
parameter NUM_STAGE = 0;
parameter din0_WIDTH = 14;
parameter din1_WIDTH = 12;
parameter dout_WIDTH = 26;

input [din0_WIDTH - 1 : 0] din0; 
input [din1_WIDTH - 1 : 0] din1; 
output [dout_WIDTH - 1 : 0] dout;

wire signed [dout_WIDTH - 1 : 0] tmp_product;
























assign tmp_product = $signed({1'b0, din0}) * $signed({1'b0, din1});











assign dout = tmp_product;





















endmodule

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_sigmoid (
        ap_clk,
        ap_rst,
        x,
        ap_return
);


input   ap_clk;
input   ap_rst;
input  [31:0] x;
output  [31:0] ap_return;

wire   [7:0] sigmoid_lut_address0;
wire   [31:0] sigmoid_lut_q0;
wire    ap_block_pp0_stage0_11001;
wire   [0:0] or_ln30_fu_142_p2;
reg   [0:0] or_ln30_reg_384;
wire   [0:0] and_ln30_fu_148_p2;
reg   [0:0] and_ln30_reg_390;
reg   [0:0] and_ln30_reg_390_pp0_iter2_reg;
reg   [0:0] and_ln30_reg_390_pp0_iter3_reg;
reg   [0:0] and_ln30_reg_390_pp0_iter4_reg;
reg   [0:0] and_ln30_reg_390_pp0_iter5_reg;
reg   [0:0] and_ln30_reg_390_pp0_iter6_reg;
reg   [0:0] and_ln30_reg_390_pp0_iter7_reg;
reg   [0:0] and_ln30_reg_390_pp0_iter8_reg;
wire   [0:0] and_ln31_2_fu_164_p2;
reg   [0:0] and_ln31_2_reg_395;
reg   [0:0] and_ln31_2_reg_395_pp0_iter2_reg;
reg   [0:0] and_ln31_2_reg_395_pp0_iter3_reg;
reg   [0:0] and_ln31_2_reg_395_pp0_iter4_reg;
reg   [0:0] and_ln31_2_reg_395_pp0_iter5_reg;
reg   [0:0] and_ln31_2_reg_395_pp0_iter6_reg;
reg   [0:0] and_ln31_2_reg_395_pp0_iter7_reg;
reg   [0:0] and_ln31_2_reg_395_pp0_iter8_reg;
wire   [31:0] grp_fu_89_p2;
reg   [31:0] add_reg_400;
wire   [1:0] sel_tmp2_fu_170_p3;
reg   [1:0] sel_tmp2_reg_405;
reg   [1:0] sel_tmp2_reg_405_pp0_iter10_reg;
reg   [1:0] sel_tmp2_reg_405_pp0_iter11_reg;
reg   [1:0] sel_tmp2_reg_405_pp0_iter12_reg;
reg   [1:0] sel_tmp2_reg_405_pp0_iter13_reg;
reg   [1:0] sel_tmp2_reg_405_pp0_iter14_reg;
reg   [1:0] sel_tmp2_reg_405_pp0_iter15_reg;
reg   [1:0] sel_tmp2_reg_405_pp0_iter16_reg;
reg   [1:0] sel_tmp2_reg_405_pp0_iter17_reg;
reg   [1:0] sel_tmp2_reg_405_pp0_iter18_reg;
wire   [31:0] grp_fu_95_p2;
reg   [31:0] dc_reg_410;
reg   [0:0] xs_sign_reg_415;
reg   [0:0] xs_sign_reg_415_pp0_iter16_reg;
wire   [22:0] trunc_ln342_fu_197_p1;
reg   [22:0] trunc_ln342_reg_420;
wire   [0:0] tmp_fu_211_p3;
reg   [0:0] tmp_reg_425;
wire   [8:0] select_ln18_fu_229_p3;
reg   [8:0] select_ln18_reg_430;
wire   [31:0] val_fu_289_p3;
reg   [31:0] val_reg_435;
wire   [7:0] trunc_ln32_fu_327_p1;
reg   [7:0] trunc_ln32_reg_441;
wire   [0:0] icmp_ln34_fu_341_p2;
reg   [0:0] icmp_ln34_reg_446;
wire   [63:0] zext_ln35_fu_353_p1;
wire    ap_block_pp0_stage0;
reg    sigmoid_lut_ce0_local;
wire   [31:0] bitcast_ln30_fu_112_p1;
wire   [7:0] tmp_5_fu_116_p4;
wire   [22:0] trunc_ln30_fu_126_p1;
wire   [0:0] icmp_ln30_2_fu_136_p2;
wire   [0:0] icmp_ln30_fu_130_p2;
wire   [0:0] grp_fu_100_p2;
wire   [0:0] grp_fu_106_p2;
wire   [0:0] and_ln31_fu_153_p2;
wire   [0:0] xor_ln30_fu_158_p2;
wire   [31:0] data_fu_176_p1;
wire   [7:0] xs_exp_fu_187_p4;
wire   [8:0] zext_ln317_fu_201_p1;
wire   [8:0] add_ln317_fu_205_p2;
wire   [7:0] sub_ln18_fu_219_p2;
wire  signed [8:0] sext_ln18_fu_225_p1;
wire   [24:0] mantissa_fu_237_p4;
wire  signed [31:0] sext_ln18_2_fu_250_p1;
wire   [78:0] zext_ln15_fu_246_p1;
wire   [78:0] zext_ln18_fu_253_p1;
wire   [78:0] lshr_ln18_fu_257_p2;
wire   [78:0] shl_ln18_fu_263_p2;
wire   [31:0] tmp_7_fu_269_p4;
wire   [31:0] tmp_9_fu_279_p4;
wire   [31:0] result_4_fu_296_p2;
wire   [31:0] result_fu_301_p3;
wire   [0:0] tmp_10_fu_311_p3;
wire   [30:0] trunc_ln58_fu_307_p1;
wire   [30:0] idx_3_fu_319_p3;
wire   [22:0] tmp_11_fu_331_p4;
wire   [7:0] idx_4_fu_347_p3;
wire   [31:0] retval_fu_358_p7;
wire    ap_block_pp0_stage0_00001;
wire   [31:0] retval_fu_358_p9;
reg   [31:0] x_int_reg;
wire  signed [1:0] retval_fu_358_p1;
wire   [1:0] retval_fu_358_p3;
wire   [1:0] retval_fu_358_p5;
wire    ap_ce_reg;

vadd_sigmoid_sigmoid_lut_ROM_AUTO_1R #(
    .DataWidth( 32 ),
    .AddressRange( 256 ),
    .AddressWidth( 8 ))
sigmoid_lut_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(sigmoid_lut_address0),
    .ce0(sigmoid_lut_ce0_local),
    .q0(sigmoid_lut_q0)
);

vadd_fadd_32ns_32ns_32_10_full_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 10 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fadd_32ns_32ns_32_10_full_dsp_1_U17(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(x_int_reg),
    .din1(32'd1086324736),
    .ce(1'b1),
    .dout(grp_fu_89_p2)
);

vadd_fmul_32ns_32ns_32_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fmul_32ns_32ns_32_5_max_dsp_1_U18(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(add_reg_400),
    .din1(32'd1101660160),
    .ce(1'b1),
    .dout(grp_fu_95_p2)
);

vadd_fcmp_32ns_32ns_1_2_no_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 2 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 1 ))
fcmp_32ns_32ns_1_2_no_dsp_1_U19(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(x_int_reg),
    .din1(32'd1086324736),
    .ce(1'b1),
    .opcode(5'd2),
    .dout(grp_fu_100_p2)
);

vadd_fcmp_32ns_32ns_1_2_no_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 2 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 1 ))
fcmp_32ns_32ns_1_2_no_dsp_1_U20(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(x_int_reg),
    .din1(32'd3233808384),
    .ce(1'b1),
    .opcode(5'd4),
    .dout(grp_fu_106_p2)
);

(* dissolve_hierarchy = "yes" *) vadd_sparsemux_7_2_32_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .CASE0( 2'h2 ),
    .din0_WIDTH( 32 ),
    .CASE1( 2'h1 ),
    .din1_WIDTH( 32 ),
    .CASE2( 2'h0 ),
    .din2_WIDTH( 32 ),
    .def_WIDTH( 32 ),
    .sel_WIDTH( 2 ),
    .dout_WIDTH( 32 ))
sparsemux_7_2_32_1_1_U21(
    .din0(32'd1065353216),
    .din1(32'd0),
    .din2(sigmoid_lut_q0),
    .def(retval_fu_358_p7),
    .sel(sel_tmp2_reg_405_pp0_iter18_reg),
    .dout(retval_fu_358_p9)
);

always @ (posedge ap_clk) begin
    x_int_reg <= x;
end

always @ (posedge ap_clk) begin
    if ((1'b0 == ap_block_pp0_stage0_11001)) begin
        add_reg_400 <= grp_fu_89_p2;
        and_ln30_reg_390 <= and_ln30_fu_148_p2;
        and_ln30_reg_390_pp0_iter2_reg <= and_ln30_reg_390;
        and_ln30_reg_390_pp0_iter3_reg <= and_ln30_reg_390_pp0_iter2_reg;
        and_ln30_reg_390_pp0_iter4_reg <= and_ln30_reg_390_pp0_iter3_reg;
        and_ln30_reg_390_pp0_iter5_reg <= and_ln30_reg_390_pp0_iter4_reg;
        and_ln30_reg_390_pp0_iter6_reg <= and_ln30_reg_390_pp0_iter5_reg;
        and_ln30_reg_390_pp0_iter7_reg <= and_ln30_reg_390_pp0_iter6_reg;
        and_ln30_reg_390_pp0_iter8_reg <= and_ln30_reg_390_pp0_iter7_reg;
        and_ln31_2_reg_395 <= and_ln31_2_fu_164_p2;
        and_ln31_2_reg_395_pp0_iter2_reg <= and_ln31_2_reg_395;
        and_ln31_2_reg_395_pp0_iter3_reg <= and_ln31_2_reg_395_pp0_iter2_reg;
        and_ln31_2_reg_395_pp0_iter4_reg <= and_ln31_2_reg_395_pp0_iter3_reg;
        and_ln31_2_reg_395_pp0_iter5_reg <= and_ln31_2_reg_395_pp0_iter4_reg;
        and_ln31_2_reg_395_pp0_iter6_reg <= and_ln31_2_reg_395_pp0_iter5_reg;
        and_ln31_2_reg_395_pp0_iter7_reg <= and_ln31_2_reg_395_pp0_iter6_reg;
        and_ln31_2_reg_395_pp0_iter8_reg <= and_ln31_2_reg_395_pp0_iter7_reg;
        dc_reg_410 <= grp_fu_95_p2;
        icmp_ln34_reg_446 <= icmp_ln34_fu_341_p2;
        or_ln30_reg_384 <= or_ln30_fu_142_p2;
        sel_tmp2_reg_405 <= sel_tmp2_fu_170_p3;
        sel_tmp2_reg_405_pp0_iter10_reg <= sel_tmp2_reg_405;
        sel_tmp2_reg_405_pp0_iter11_reg <= sel_tmp2_reg_405_pp0_iter10_reg;
        sel_tmp2_reg_405_pp0_iter12_reg <= sel_tmp2_reg_405_pp0_iter11_reg;
        sel_tmp2_reg_405_pp0_iter13_reg <= sel_tmp2_reg_405_pp0_iter12_reg;
        sel_tmp2_reg_405_pp0_iter14_reg <= sel_tmp2_reg_405_pp0_iter13_reg;
        sel_tmp2_reg_405_pp0_iter15_reg <= sel_tmp2_reg_405_pp0_iter14_reg;
        sel_tmp2_reg_405_pp0_iter16_reg <= sel_tmp2_reg_405_pp0_iter15_reg;
        sel_tmp2_reg_405_pp0_iter17_reg <= sel_tmp2_reg_405_pp0_iter16_reg;
        sel_tmp2_reg_405_pp0_iter18_reg <= sel_tmp2_reg_405_pp0_iter17_reg;
        select_ln18_reg_430 <= select_ln18_fu_229_p3;
        tmp_reg_425 <= add_ln317_fu_205_p2[32'd8];
        trunc_ln32_reg_441 <= trunc_ln32_fu_327_p1;
        trunc_ln342_reg_420 <= trunc_ln342_fu_197_p1;
        val_reg_435 <= val_fu_289_p3;
        xs_sign_reg_415 <= data_fu_176_p1[32'd31];
        xs_sign_reg_415_pp0_iter16_reg <= xs_sign_reg_415;
    end
end

always @ (*) begin
    if ((1'b0 == ap_block_pp0_stage0_11001)) begin
        sigmoid_lut_ce0_local = 1'b1;
    end else begin
        sigmoid_lut_ce0_local = 1'b0;
    end
end

assign add_ln317_fu_205_p2 = ($signed(zext_ln317_fu_201_p1) + $signed(9'd385));

assign and_ln30_fu_148_p2 = (or_ln30_reg_384 & grp_fu_100_p2);

assign and_ln31_2_fu_164_p2 = (xor_ln30_fu_158_p2 & and_ln31_fu_153_p2);

assign and_ln31_fu_153_p2 = (or_ln30_reg_384 & grp_fu_106_p2);

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_00001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_return = retval_fu_358_p9;

assign bitcast_ln30_fu_112_p1 = x_int_reg;

assign data_fu_176_p1 = dc_reg_410;

assign icmp_ln30_2_fu_136_p2 = ((trunc_ln30_fu_126_p1 == 23'd0) ? 1'b1 : 1'b0);

assign icmp_ln30_fu_130_p2 = ((tmp_5_fu_116_p4 != 8'd255) ? 1'b1 : 1'b0);

assign icmp_ln34_fu_341_p2 = ((tmp_11_fu_331_p4 != 23'd0) ? 1'b1 : 1'b0);

assign idx_3_fu_319_p3 = ((tmp_10_fu_311_p3[0:0] == 1'b1) ? 31'd0 : trunc_ln58_fu_307_p1);

assign idx_4_fu_347_p3 = ((icmp_ln34_reg_446[0:0] == 1'b1) ? 8'd255 : trunc_ln32_reg_441);

assign lshr_ln18_fu_257_p2 = zext_ln15_fu_246_p1 >> zext_ln18_fu_253_p1;

assign mantissa_fu_237_p4 = {{{{1'd1}, {trunc_ln342_reg_420}}}, {1'd0}};

assign or_ln30_fu_142_p2 = (icmp_ln30_fu_130_p2 | icmp_ln30_2_fu_136_p2);

assign result_4_fu_296_p2 = (32'd0 - val_reg_435);

assign result_fu_301_p3 = ((xs_sign_reg_415_pp0_iter16_reg[0:0] == 1'b1) ? result_4_fu_296_p2 : val_reg_435);

assign retval_fu_358_p7 = 'bx;

assign sel_tmp2_fu_170_p3 = {{and_ln30_reg_390_pp0_iter8_reg}, {and_ln31_2_reg_395_pp0_iter8_reg}};

assign select_ln18_fu_229_p3 = ((tmp_fu_211_p3[0:0] == 1'b1) ? sext_ln18_fu_225_p1 : add_ln317_fu_205_p2);

assign sext_ln18_2_fu_250_p1 = $signed(select_ln18_reg_430);

assign sext_ln18_fu_225_p1 = $signed(sub_ln18_fu_219_p2);

assign shl_ln18_fu_263_p2 = zext_ln15_fu_246_p1 << zext_ln18_fu_253_p1;

assign sigmoid_lut_address0 = zext_ln35_fu_353_p1;

assign sub_ln18_fu_219_p2 = (8'd127 - xs_exp_fu_187_p4);

assign tmp_10_fu_311_p3 = result_fu_301_p3[32'd31];

assign tmp_11_fu_331_p4 = {{idx_3_fu_319_p3[30:8]}};

assign tmp_5_fu_116_p4 = {{bitcast_ln30_fu_112_p1[30:23]}};

assign tmp_7_fu_269_p4 = {{lshr_ln18_fu_257_p2[55:24]}};

assign tmp_9_fu_279_p4 = {{shl_ln18_fu_263_p2[55:24]}};

assign tmp_fu_211_p3 = add_ln317_fu_205_p2[32'd8];

assign trunc_ln30_fu_126_p1 = bitcast_ln30_fu_112_p1[22:0];

assign trunc_ln32_fu_327_p1 = idx_3_fu_319_p3[7:0];

assign trunc_ln342_fu_197_p1 = data_fu_176_p1[22:0];

assign trunc_ln58_fu_307_p1 = result_fu_301_p3[30:0];

assign val_fu_289_p3 = ((tmp_reg_425[0:0] == 1'b1) ? tmp_7_fu_269_p4 : tmp_9_fu_279_p4);

assign xor_ln30_fu_158_p2 = (1'd1 ^ and_ln30_fu_148_p2);

assign xs_exp_fu_187_p4 = {{data_fu_176_p1[30:23]}};

assign zext_ln15_fu_246_p1 = mantissa_fu_237_p4;

assign zext_ln18_fu_253_p1 = $unsigned(sext_ln18_2_fu_250_p1);

assign zext_ln317_fu_201_p1 = xs_exp_fu_187_p4;

assign zext_ln35_fu_353_p1 = idx_4_fu_347_p3;

endmodule //vadd_sigmoid

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================
`timescale 1 ns / 1 ps
module vadd_sigmoid_sigmoid_lut_ROM_AUTO_1R (
    address0, ce0, q0, 
    reset, clk);

parameter DataWidth = 32;
parameter AddressWidth = 8;
parameter AddressRange = 256;
 
input[AddressWidth-1:0] address0;
input ce0;
output reg[DataWidth-1:0] q0;

input reset;
input clk;

 
reg [DataWidth-1:0] rom0[0:AddressRange-1];


initial begin
     
    $readmemh("./vadd_sigmoid_sigmoid_lut_ROM_AUTO_1R.dat", rom0);
end

  
always @(posedge clk) 
begin 
    if (ce0) 
    begin
        q0 <= rom0[address0];
    end
end


endmodule


// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================
// 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689
`timescale 1ns / 1ps

module vadd_sparsemux_11_3_32_1_1 (din0,din1,din2,din3,din4,def,sel,dout);

parameter din0_WIDTH = 1;

parameter din1_WIDTH = 1;

parameter din2_WIDTH = 1;

parameter din3_WIDTH = 1;

parameter din4_WIDTH = 1;

parameter def_WIDTH = 1;
parameter sel_WIDTH = 1;
parameter dout_WIDTH = 1;

parameter [sel_WIDTH-1:0] CASE0 = 1;

parameter [sel_WIDTH-1:0] CASE1 = 1;

parameter [sel_WIDTH-1:0] CASE2 = 1;

parameter [sel_WIDTH-1:0] CASE3 = 1;

parameter [sel_WIDTH-1:0] CASE4 = 1;

parameter ID = 1;
parameter NUM_STAGE = 1;



input [din0_WIDTH-1:0] din0;

input [din1_WIDTH-1:0] din1;

input [din2_WIDTH-1:0] din2;

input [din3_WIDTH-1:0] din3;

input [din4_WIDTH-1:0] din4;

input [def_WIDTH-1:0] def;
input [sel_WIDTH-1:0] sel;

output [dout_WIDTH-1:0] dout;



reg [dout_WIDTH-1:0] dout_tmp;


always @ (*) begin
(* parallel_case *) case (sel)
    
    CASE0 : dout_tmp = din0;
    
    CASE1 : dout_tmp = din1;
    
    CASE2 : dout_tmp = din2;
    
    CASE3 : dout_tmp = din3;
    
    CASE4 : dout_tmp = din4;
    
    default : dout_tmp = def;
endcase
end


assign dout = dout_tmp;



endmodule

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================
// 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689
`timescale 1ns / 1ps

module vadd_sparsemux_7_2_32_1_1 (din0,din1,din2,def,sel,dout);

parameter din0_WIDTH = 1;

parameter din1_WIDTH = 1;

parameter din2_WIDTH = 1;

parameter def_WIDTH = 1;
parameter sel_WIDTH = 1;
parameter dout_WIDTH = 1;

parameter [sel_WIDTH-1:0] CASE0 = 1;

parameter [sel_WIDTH-1:0] CASE1 = 1;

parameter [sel_WIDTH-1:0] CASE2 = 1;

parameter ID = 1;
parameter NUM_STAGE = 1;



input [din0_WIDTH-1:0] din0;

input [din1_WIDTH-1:0] din1;

input [din2_WIDTH-1:0] din2;

input [def_WIDTH-1:0] def;
input [sel_WIDTH-1:0] sel;

output [dout_WIDTH-1:0] dout;



reg [dout_WIDTH-1:0] dout_tmp;


always @ (*) begin
(* parallel_case *) case (sel)
    
    CASE0 : dout_tmp = din0;
    
    CASE1 : dout_tmp = din1;
    
    CASE2 : dout_tmp = din2;
    
    default : dout_tmp = def;
endcase
end


assign dout = dout_tmp;



endmodule

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module vadd_tanh_approx (
        ap_clk,
        ap_rst,
        x,
        ap_return
);


input   ap_clk;
input   ap_rst;
input  [31:0] x;
output  [31:0] ap_return;

wire   [7:0] sigmoid_lut_address0;
wire   [31:0] sigmoid_lut_q0;
wire    ap_block_pp0_stage0_11001;
wire   [31:0] grp_fu_101_p2;
reg   [31:0] x_assign_reg_397;
wire   [0:0] or_ln30_fu_156_p2;
reg   [0:0] or_ln30_reg_405;
reg   [0:0] or_ln30_reg_405_pp0_iter6_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter7_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter8_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter9_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter10_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter11_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter12_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter13_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter14_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter15_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter16_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter17_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter18_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter19_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter20_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter21_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter22_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter23_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter24_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter25_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter26_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter27_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter28_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter29_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter30_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter31_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter32_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter33_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter34_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter35_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter36_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter37_reg;
reg   [0:0] or_ln30_reg_405_pp0_iter38_reg;
wire   [0:0] grp_fu_117_p2;
reg   [0:0] tmp_2_reg_411;
reg   [0:0] tmp_2_reg_411_pp0_iter7_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter8_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter9_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter10_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter11_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter12_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter13_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter14_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter15_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter16_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter17_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter18_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter19_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter20_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter21_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter22_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter23_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter24_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter25_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter26_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter27_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter28_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter29_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter30_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter31_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter32_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter33_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter34_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter35_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter36_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter37_reg;
reg   [0:0] tmp_2_reg_411_pp0_iter38_reg;
wire   [0:0] grp_fu_122_p2;
reg   [0:0] tmp_4_reg_416;
reg   [0:0] tmp_4_reg_416_pp0_iter7_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter8_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter9_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter10_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter11_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter12_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter13_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter14_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter15_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter16_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter17_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter18_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter19_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter20_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter21_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter22_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter23_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter24_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter25_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter26_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter27_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter28_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter29_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter30_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter31_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter32_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter33_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter34_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter35_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter36_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter37_reg;
reg   [0:0] tmp_4_reg_416_pp0_iter38_reg;
wire   [31:0] grp_fu_91_p2;
reg   [31:0] add_i_reg_421;
wire   [31:0] grp_fu_107_p2;
reg   [31:0] dc_reg_426;
reg   [0:0] xs_sign_reg_431;
reg   [0:0] xs_sign_reg_431_pp0_iter21_reg;
wire   [22:0] trunc_ln342_fu_183_p1;
reg   [22:0] trunc_ln342_reg_436;
wire   [0:0] tmp_fu_197_p3;
reg   [0:0] tmp_reg_441;
wire   [8:0] select_ln18_fu_215_p3;
reg   [8:0] select_ln18_reg_446;
wire   [31:0] val_fu_275_p3;
reg   [31:0] val_reg_451;
wire   [7:0] trunc_ln32_fu_313_p1;
reg   [7:0] trunc_ln32_reg_457;
wire   [0:0] icmp_ln34_fu_327_p2;
reg   [0:0] icmp_ln34_reg_462;
reg   [31:0] sigmoid_lut_load_reg_472;
wire   [31:0] grp_fu_112_p2;
reg   [31:0] phitmp_reg_477;
wire   [63:0] zext_ln35_fu_339_p1;
wire    ap_block_pp0_stage0;
reg    sigmoid_lut_ce0_local;
wire   [31:0] bitcast_ln30_fu_127_p1;
wire   [7:0] tmp_1_fu_130_p4;
wire   [22:0] trunc_ln30_fu_140_p1;
wire   [0:0] icmp_ln30_1_fu_150_p2;
wire   [0:0] icmp_ln30_fu_144_p2;
wire   [31:0] data_fu_162_p1;
wire   [7:0] xs_exp_fu_173_p4;
wire   [8:0] zext_ln317_fu_187_p1;
wire   [8:0] add_ln317_fu_191_p2;
wire   [7:0] sub_ln18_fu_205_p2;
wire  signed [8:0] sext_ln18_fu_211_p1;
wire   [24:0] mantissa_fu_223_p4;
wire  signed [31:0] sext_ln18_1_fu_236_p1;
wire   [78:0] zext_ln15_fu_232_p1;
wire   [78:0] zext_ln18_fu_239_p1;
wire   [78:0] lshr_ln18_fu_243_p2;
wire   [78:0] shl_ln18_fu_249_p2;
wire   [31:0] tmp_3_fu_255_p4;
wire   [31:0] tmp_5_fu_265_p4;
wire   [31:0] result_2_fu_282_p2;
wire   [31:0] result_fu_287_p3;
wire   [0:0] tmp_6_fu_297_p3;
wire   [30:0] trunc_ln58_fu_293_p1;
wire   [30:0] idx_1_fu_305_p3;
wire   [22:0] tmp_7_fu_317_p4;
wire   [7:0] idx_2_fu_333_p3;
wire   [0:0] and_ln30_fu_344_p2;
wire   [0:0] and_ln31_fu_348_p2;
wire   [0:0] xor_ln30_fu_352_p2;
wire   [0:0] and_ln31_1_fu_358_p2;
wire   [31:0] grp_fu_96_p2;
wire   [31:0] phi_ln_fu_372_p7;
wire   [1:0] phi_ln_fu_372_p8;
wire    ap_block_pp0_stage0_00001;
wire   [31:0] phi_ln_fu_372_p9;
reg   [31:0] x_int_reg;
wire  signed [1:0] phi_ln_fu_372_p1;
wire   [1:0] phi_ln_fu_372_p3;
wire   [1:0] phi_ln_fu_372_p5;
wire    ap_ce_reg;

vadd_sigmoid_sigmoid_lut_ROM_AUTO_1R #(
    .DataWidth( 32 ),
    .AddressRange( 256 ),
    .AddressWidth( 8 ))
sigmoid_lut_U(
    .clk(ap_clk),
    .reset(ap_rst),
    .address0(sigmoid_lut_address0),
    .ce0(sigmoid_lut_ce0_local),
    .q0(sigmoid_lut_q0)
);

vadd_fadd_32ns_32ns_32_10_full_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 10 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fadd_32ns_32ns_32_10_full_dsp_1_U26(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(x_assign_reg_397),
    .din1(32'd1086324736),
    .ce(1'b1),
    .dout(grp_fu_91_p2)
);

vadd_fadd_32ns_32ns_32_10_full_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 10 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fadd_32ns_32ns_32_10_full_dsp_1_U27(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(phitmp_reg_477),
    .din1(32'd3212836864),
    .ce(1'b1),
    .dout(grp_fu_96_p2)
);

vadd_fmul_32ns_32ns_32_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fmul_32ns_32ns_32_5_max_dsp_1_U28(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(x_int_reg),
    .din1(32'd1073741824),
    .ce(1'b1),
    .dout(grp_fu_101_p2)
);

vadd_fmul_32ns_32ns_32_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fmul_32ns_32ns_32_5_max_dsp_1_U29(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(add_i_reg_421),
    .din1(32'd1101660160),
    .ce(1'b1),
    .dout(grp_fu_107_p2)
);

vadd_fmul_32ns_32ns_32_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 32 ))
fmul_32ns_32ns_32_5_max_dsp_1_U30(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(sigmoid_lut_load_reg_472),
    .din1(32'd1073741824),
    .ce(1'b1),
    .dout(grp_fu_112_p2)
);

vadd_fcmp_32ns_32ns_1_2_no_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 2 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 1 ))
fcmp_32ns_32ns_1_2_no_dsp_1_U31(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(x_assign_reg_397),
    .din1(32'd1086324736),
    .ce(1'b1),
    .opcode(5'd2),
    .dout(grp_fu_117_p2)
);

vadd_fcmp_32ns_32ns_1_2_no_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 2 ),
    .din0_WIDTH( 32 ),
    .din1_WIDTH( 32 ),
    .dout_WIDTH( 1 ))
fcmp_32ns_32ns_1_2_no_dsp_1_U32(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(x_assign_reg_397),
    .din1(32'd3233808384),
    .ce(1'b1),
    .opcode(5'd4),
    .dout(grp_fu_122_p2)
);

(* dissolve_hierarchy = "yes" *) vadd_sparsemux_7_2_32_1_1 #(
    .ID( 1 ),
    .NUM_STAGE( 1 ),
    .CASE0( 2'h2 ),
    .din0_WIDTH( 32 ),
    .CASE1( 2'h1 ),
    .din1_WIDTH( 32 ),
    .CASE2( 2'h0 ),
    .din2_WIDTH( 32 ),
    .def_WIDTH( 32 ),
    .sel_WIDTH( 2 ),
    .dout_WIDTH( 32 ))
sparsemux_7_2_32_1_1_U33(
    .din0(32'd1065353216),
    .din1(32'd3212836864),
    .din2(grp_fu_96_p2),
    .def(phi_ln_fu_372_p7),
    .sel(phi_ln_fu_372_p8),
    .dout(phi_ln_fu_372_p9)
);

always @ (posedge ap_clk) begin
    x_int_reg <= x;
end

always @ (posedge ap_clk) begin
    if ((1'b0 == ap_block_pp0_stage0_11001)) begin
        add_i_reg_421 <= grp_fu_91_p2;
        dc_reg_426 <= grp_fu_107_p2;
        icmp_ln34_reg_462 <= icmp_ln34_fu_327_p2;
        or_ln30_reg_405 <= or_ln30_fu_156_p2;
        or_ln30_reg_405_pp0_iter10_reg <= or_ln30_reg_405_pp0_iter9_reg;
        or_ln30_reg_405_pp0_iter11_reg <= or_ln30_reg_405_pp0_iter10_reg;
        or_ln30_reg_405_pp0_iter12_reg <= or_ln30_reg_405_pp0_iter11_reg;
        or_ln30_reg_405_pp0_iter13_reg <= or_ln30_reg_405_pp0_iter12_reg;
        or_ln30_reg_405_pp0_iter14_reg <= or_ln30_reg_405_pp0_iter13_reg;
        or_ln30_reg_405_pp0_iter15_reg <= or_ln30_reg_405_pp0_iter14_reg;
        or_ln30_reg_405_pp0_iter16_reg <= or_ln30_reg_405_pp0_iter15_reg;
        or_ln30_reg_405_pp0_iter17_reg <= or_ln30_reg_405_pp0_iter16_reg;
        or_ln30_reg_405_pp0_iter18_reg <= or_ln30_reg_405_pp0_iter17_reg;
        or_ln30_reg_405_pp0_iter19_reg <= or_ln30_reg_405_pp0_iter18_reg;
        or_ln30_reg_405_pp0_iter20_reg <= or_ln30_reg_405_pp0_iter19_reg;
        or_ln30_reg_405_pp0_iter21_reg <= or_ln30_reg_405_pp0_iter20_reg;
        or_ln30_reg_405_pp0_iter22_reg <= or_ln30_reg_405_pp0_iter21_reg;
        or_ln30_reg_405_pp0_iter23_reg <= or_ln30_reg_405_pp0_iter22_reg;
        or_ln30_reg_405_pp0_iter24_reg <= or_ln30_reg_405_pp0_iter23_reg;
        or_ln30_reg_405_pp0_iter25_reg <= or_ln30_reg_405_pp0_iter24_reg;
        or_ln30_reg_405_pp0_iter26_reg <= or_ln30_reg_405_pp0_iter25_reg;
        or_ln30_reg_405_pp0_iter27_reg <= or_ln30_reg_405_pp0_iter26_reg;
        or_ln30_reg_405_pp0_iter28_reg <= or_ln30_reg_405_pp0_iter27_reg;
        or_ln30_reg_405_pp0_iter29_reg <= or_ln30_reg_405_pp0_iter28_reg;
        or_ln30_reg_405_pp0_iter30_reg <= or_ln30_reg_405_pp0_iter29_reg;
        or_ln30_reg_405_pp0_iter31_reg <= or_ln30_reg_405_pp0_iter30_reg;
        or_ln30_reg_405_pp0_iter32_reg <= or_ln30_reg_405_pp0_iter31_reg;
        or_ln30_reg_405_pp0_iter33_reg <= or_ln30_reg_405_pp0_iter32_reg;
        or_ln30_reg_405_pp0_iter34_reg <= or_ln30_reg_405_pp0_iter33_reg;
        or_ln30_reg_405_pp0_iter35_reg <= or_ln30_reg_405_pp0_iter34_reg;
        or_ln30_reg_405_pp0_iter36_reg <= or_ln30_reg_405_pp0_iter35_reg;
        or_ln30_reg_405_pp0_iter37_reg <= or_ln30_reg_405_pp0_iter36_reg;
        or_ln30_reg_405_pp0_iter38_reg <= or_ln30_reg_405_pp0_iter37_reg;
        or_ln30_reg_405_pp0_iter6_reg <= or_ln30_reg_405;
        or_ln30_reg_405_pp0_iter7_reg <= or_ln30_reg_405_pp0_iter6_reg;
        or_ln30_reg_405_pp0_iter8_reg <= or_ln30_reg_405_pp0_iter7_reg;
        or_ln30_reg_405_pp0_iter9_reg <= or_ln30_reg_405_pp0_iter8_reg;
        phitmp_reg_477 <= grp_fu_112_p2;
        select_ln18_reg_446 <= select_ln18_fu_215_p3;
        sigmoid_lut_load_reg_472 <= sigmoid_lut_q0;
        tmp_2_reg_411 <= grp_fu_117_p2;
        tmp_2_reg_411_pp0_iter10_reg <= tmp_2_reg_411_pp0_iter9_reg;
        tmp_2_reg_411_pp0_iter11_reg <= tmp_2_reg_411_pp0_iter10_reg;
        tmp_2_reg_411_pp0_iter12_reg <= tmp_2_reg_411_pp0_iter11_reg;
        tmp_2_reg_411_pp0_iter13_reg <= tmp_2_reg_411_pp0_iter12_reg;
        tmp_2_reg_411_pp0_iter14_reg <= tmp_2_reg_411_pp0_iter13_reg;
        tmp_2_reg_411_pp0_iter15_reg <= tmp_2_reg_411_pp0_iter14_reg;
        tmp_2_reg_411_pp0_iter16_reg <= tmp_2_reg_411_pp0_iter15_reg;
        tmp_2_reg_411_pp0_iter17_reg <= tmp_2_reg_411_pp0_iter16_reg;
        tmp_2_reg_411_pp0_iter18_reg <= tmp_2_reg_411_pp0_iter17_reg;
        tmp_2_reg_411_pp0_iter19_reg <= tmp_2_reg_411_pp0_iter18_reg;
        tmp_2_reg_411_pp0_iter20_reg <= tmp_2_reg_411_pp0_iter19_reg;
        tmp_2_reg_411_pp0_iter21_reg <= tmp_2_reg_411_pp0_iter20_reg;
        tmp_2_reg_411_pp0_iter22_reg <= tmp_2_reg_411_pp0_iter21_reg;
        tmp_2_reg_411_pp0_iter23_reg <= tmp_2_reg_411_pp0_iter22_reg;
        tmp_2_reg_411_pp0_iter24_reg <= tmp_2_reg_411_pp0_iter23_reg;
        tmp_2_reg_411_pp0_iter25_reg <= tmp_2_reg_411_pp0_iter24_reg;
        tmp_2_reg_411_pp0_iter26_reg <= tmp_2_reg_411_pp0_iter25_reg;
        tmp_2_reg_411_pp0_iter27_reg <= tmp_2_reg_411_pp0_iter26_reg;
        tmp_2_reg_411_pp0_iter28_reg <= tmp_2_reg_411_pp0_iter27_reg;
        tmp_2_reg_411_pp0_iter29_reg <= tmp_2_reg_411_pp0_iter28_reg;
        tmp_2_reg_411_pp0_iter30_reg <= tmp_2_reg_411_pp0_iter29_reg;
        tmp_2_reg_411_pp0_iter31_reg <= tmp_2_reg_411_pp0_iter30_reg;
        tmp_2_reg_411_pp0_iter32_reg <= tmp_2_reg_411_pp0_iter31_reg;
        tmp_2_reg_411_pp0_iter33_reg <= tmp_2_reg_411_pp0_iter32_reg;
        tmp_2_reg_411_pp0_iter34_reg <= tmp_2_reg_411_pp0_iter33_reg;
        tmp_2_reg_411_pp0_iter35_reg <= tmp_2_reg_411_pp0_iter34_reg;
        tmp_2_reg_411_pp0_iter36_reg <= tmp_2_reg_411_pp0_iter35_reg;
        tmp_2_reg_411_pp0_iter37_reg <= tmp_2_reg_411_pp0_iter36_reg;
        tmp_2_reg_411_pp0_iter38_reg <= tmp_2_reg_411_pp0_iter37_reg;
        tmp_2_reg_411_pp0_iter7_reg <= tmp_2_reg_411;
        tmp_2_reg_411_pp0_iter8_reg <= tmp_2_reg_411_pp0_iter7_reg;
        tmp_2_reg_411_pp0_iter9_reg <= tmp_2_reg_411_pp0_iter8_reg;
        tmp_4_reg_416 <= grp_fu_122_p2;
        tmp_4_reg_416_pp0_iter10_reg <= tmp_4_reg_416_pp0_iter9_reg;
        tmp_4_reg_416_pp0_iter11_reg <= tmp_4_reg_416_pp0_iter10_reg;
        tmp_4_reg_416_pp0_iter12_reg <= tmp_4_reg_416_pp0_iter11_reg;
        tmp_4_reg_416_pp0_iter13_reg <= tmp_4_reg_416_pp0_iter12_reg;
        tmp_4_reg_416_pp0_iter14_reg <= tmp_4_reg_416_pp0_iter13_reg;
        tmp_4_reg_416_pp0_iter15_reg <= tmp_4_reg_416_pp0_iter14_reg;
        tmp_4_reg_416_pp0_iter16_reg <= tmp_4_reg_416_pp0_iter15_reg;
        tmp_4_reg_416_pp0_iter17_reg <= tmp_4_reg_416_pp0_iter16_reg;
        tmp_4_reg_416_pp0_iter18_reg <= tmp_4_reg_416_pp0_iter17_reg;
        tmp_4_reg_416_pp0_iter19_reg <= tmp_4_reg_416_pp0_iter18_reg;
        tmp_4_reg_416_pp0_iter20_reg <= tmp_4_reg_416_pp0_iter19_reg;
        tmp_4_reg_416_pp0_iter21_reg <= tmp_4_reg_416_pp0_iter20_reg;
        tmp_4_reg_416_pp0_iter22_reg <= tmp_4_reg_416_pp0_iter21_reg;
        tmp_4_reg_416_pp0_iter23_reg <= tmp_4_reg_416_pp0_iter22_reg;
        tmp_4_reg_416_pp0_iter24_reg <= tmp_4_reg_416_pp0_iter23_reg;
        tmp_4_reg_416_pp0_iter25_reg <= tmp_4_reg_416_pp0_iter24_reg;
        tmp_4_reg_416_pp0_iter26_reg <= tmp_4_reg_416_pp0_iter25_reg;
        tmp_4_reg_416_pp0_iter27_reg <= tmp_4_reg_416_pp0_iter26_reg;
        tmp_4_reg_416_pp0_iter28_reg <= tmp_4_reg_416_pp0_iter27_reg;
        tmp_4_reg_416_pp0_iter29_reg <= tmp_4_reg_416_pp0_iter28_reg;
        tmp_4_reg_416_pp0_iter30_reg <= tmp_4_reg_416_pp0_iter29_reg;
        tmp_4_reg_416_pp0_iter31_reg <= tmp_4_reg_416_pp0_iter30_reg;
        tmp_4_reg_416_pp0_iter32_reg <= tmp_4_reg_416_pp0_iter31_reg;
        tmp_4_reg_416_pp0_iter33_reg <= tmp_4_reg_416_pp0_iter32_reg;
        tmp_4_reg_416_pp0_iter34_reg <= tmp_4_reg_416_pp0_iter33_reg;
        tmp_4_reg_416_pp0_iter35_reg <= tmp_4_reg_416_pp0_iter34_reg;
        tmp_4_reg_416_pp0_iter36_reg <= tmp_4_reg_416_pp0_iter35_reg;
        tmp_4_reg_416_pp0_iter37_reg <= tmp_4_reg_416_pp0_iter36_reg;
        tmp_4_reg_416_pp0_iter38_reg <= tmp_4_reg_416_pp0_iter37_reg;
        tmp_4_reg_416_pp0_iter7_reg <= tmp_4_reg_416;
        tmp_4_reg_416_pp0_iter8_reg <= tmp_4_reg_416_pp0_iter7_reg;
        tmp_4_reg_416_pp0_iter9_reg <= tmp_4_reg_416_pp0_iter8_reg;
        tmp_reg_441 <= add_ln317_fu_191_p2[32'd8];
        trunc_ln32_reg_457 <= trunc_ln32_fu_313_p1;
        trunc_ln342_reg_436 <= trunc_ln342_fu_183_p1;
        val_reg_451 <= val_fu_275_p3;
        x_assign_reg_397 <= grp_fu_101_p2;
        xs_sign_reg_431 <= data_fu_162_p1[32'd31];
        xs_sign_reg_431_pp0_iter21_reg <= xs_sign_reg_431;
    end
end

always @ (*) begin
    if ((1'b0 == ap_block_pp0_stage0_11001)) begin
        sigmoid_lut_ce0_local = 1'b1;
    end else begin
        sigmoid_lut_ce0_local = 1'b0;
    end
end

assign add_ln317_fu_191_p2 = ($signed(zext_ln317_fu_187_p1) + $signed(9'd385));

assign and_ln30_fu_344_p2 = (tmp_2_reg_411_pp0_iter38_reg & or_ln30_reg_405_pp0_iter38_reg);

assign and_ln31_1_fu_358_p2 = (xor_ln30_fu_352_p2 & and_ln31_fu_348_p2);

assign and_ln31_fu_348_p2 = (tmp_4_reg_416_pp0_iter38_reg & or_ln30_reg_405_pp0_iter38_reg);

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_00001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_return = phi_ln_fu_372_p9;

assign bitcast_ln30_fu_127_p1 = x_assign_reg_397;

assign data_fu_162_p1 = dc_reg_426;

assign icmp_ln30_1_fu_150_p2 = ((trunc_ln30_fu_140_p1 == 23'd0) ? 1'b1 : 1'b0);

assign icmp_ln30_fu_144_p2 = ((tmp_1_fu_130_p4 != 8'd255) ? 1'b1 : 1'b0);

assign icmp_ln34_fu_327_p2 = ((tmp_7_fu_317_p4 != 23'd0) ? 1'b1 : 1'b0);

assign idx_1_fu_305_p3 = ((tmp_6_fu_297_p3[0:0] == 1'b1) ? 31'd0 : trunc_ln58_fu_293_p1);

assign idx_2_fu_333_p3 = ((icmp_ln34_reg_462[0:0] == 1'b1) ? 8'd255 : trunc_ln32_reg_457);

assign lshr_ln18_fu_243_p2 = zext_ln15_fu_232_p1 >> zext_ln18_fu_239_p1;

assign mantissa_fu_223_p4 = {{{{1'd1}, {trunc_ln342_reg_436}}}, {1'd0}};

assign or_ln30_fu_156_p2 = (icmp_ln30_fu_144_p2 | icmp_ln30_1_fu_150_p2);

assign phi_ln_fu_372_p7 = 'bx;

assign phi_ln_fu_372_p8 = {{and_ln30_fu_344_p2}, {and_ln31_1_fu_358_p2}};

assign result_2_fu_282_p2 = (32'd0 - val_reg_451);

assign result_fu_287_p3 = ((xs_sign_reg_431_pp0_iter21_reg[0:0] == 1'b1) ? result_2_fu_282_p2 : val_reg_451);

assign select_ln18_fu_215_p3 = ((tmp_fu_197_p3[0:0] == 1'b1) ? sext_ln18_fu_211_p1 : add_ln317_fu_191_p2);

assign sext_ln18_1_fu_236_p1 = $signed(select_ln18_reg_446);

assign sext_ln18_fu_211_p1 = $signed(sub_ln18_fu_205_p2);

assign shl_ln18_fu_249_p2 = zext_ln15_fu_232_p1 << zext_ln18_fu_239_p1;

assign sigmoid_lut_address0 = zext_ln35_fu_339_p1;

assign sub_ln18_fu_205_p2 = (8'd127 - xs_exp_fu_173_p4);

assign tmp_1_fu_130_p4 = {{bitcast_ln30_fu_127_p1[30:23]}};

assign tmp_3_fu_255_p4 = {{lshr_ln18_fu_243_p2[55:24]}};

assign tmp_5_fu_265_p4 = {{shl_ln18_fu_249_p2[55:24]}};

assign tmp_6_fu_297_p3 = result_fu_287_p3[32'd31];

assign tmp_7_fu_317_p4 = {{idx_1_fu_305_p3[30:8]}};

assign tmp_fu_197_p3 = add_ln317_fu_191_p2[32'd8];

assign trunc_ln30_fu_140_p1 = bitcast_ln30_fu_127_p1[22:0];

assign trunc_ln32_fu_313_p1 = idx_1_fu_305_p3[7:0];

assign trunc_ln342_fu_183_p1 = data_fu_162_p1[22:0];

assign trunc_ln58_fu_293_p1 = result_fu_287_p3[30:0];

assign val_fu_275_p3 = ((tmp_reg_441[0:0] == 1'b1) ? tmp_3_fu_255_p4 : tmp_5_fu_265_p4);

assign xor_ln30_fu_352_p2 = (1'd1 ^ and_ln30_fu_344_p2);

assign xs_exp_fu_173_p4 = {{data_fu_162_p1[30:23]}};

assign zext_ln15_fu_232_p1 = mantissa_fu_223_p4;

assign zext_ln18_fu_239_p1 = $unsigned(sext_ln18_1_fu_236_p1);

assign zext_ln317_fu_187_p1 = xs_exp_fu_173_p4;

assign zext_ln35_fu_339_p1 = idx_2_fu_333_p3;

endmodule //vadd_tanh_approx

// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================
`timescale 1 ns / 1 ps

module vadd_urem_9ns_4ns_3_13_seq_1_divseq
#(parameter
    in0_WIDTH = 32,
    in1_WIDTH = 32,
    out_WIDTH = 32
)
(
    input                       clk,
    input                       reset,
    input                       ce,
    input                       start,
    input       [in0_WIDTH-1:0] dividend,
    input       [in1_WIDTH-1:0] divisor,
    output wire                 done,
    output wire [out_WIDTH-1:0] quot,
    output wire [out_WIDTH-1:0] remd
);

localparam cal_WIDTH = (in0_WIDTH > in1_WIDTH)? in0_WIDTH : in1_WIDTH;

//------------------------Local signal-------------------
reg     [in0_WIDTH-1:0] dividend0;
reg     [in1_WIDTH-1:0] divisor0;
reg     [in0_WIDTH-1:0] dividend_tmp;
reg     [in0_WIDTH-1:0] remd_tmp;
wire    [in0_WIDTH-1:0] dividend_tmp_mux;
wire    [in0_WIDTH-1:0] remd_tmp_mux;
wire    [in0_WIDTH-1:0] comb_tmp;
wire    [cal_WIDTH:0]   cal_tmp;

//------------------------Body---------------------------
assign  quot   = dividend_tmp;
assign  remd   = remd_tmp;

// dividend0, divisor0
always @(posedge clk)
begin
    if (start) begin
        dividend0 <= dividend;
        divisor0  <= divisor;
    end
end

// One-Hot Register
// r_stage[0]=1:accept input; r_stage[in0_WIDTH]=1:done
reg     [in0_WIDTH:0]     r_stage;
assign done = r_stage[in0_WIDTH];
always @(posedge clk)
begin
    if (reset == 1'b1)
        r_stage[in0_WIDTH:0] <= {in0_WIDTH{1'b0}};
    else if (ce)
        r_stage[in0_WIDTH:0] <= {r_stage[in0_WIDTH-1:0], start};
end

// MUXs
assign  dividend_tmp_mux = r_stage[0]? dividend0 : dividend_tmp;
assign  remd_tmp_mux     = r_stage[0]? {in0_WIDTH{1'b0}} : remd_tmp;

if (in0_WIDTH == 1) assign comb_tmp = dividend_tmp_mux[0];
else                assign comb_tmp = {remd_tmp_mux[in0_WIDTH-2:0], dividend_tmp_mux[in0_WIDTH-1]};

assign  cal_tmp  = {1'b0, comb_tmp} - {1'b0, divisor0};

always @(posedge clk)
begin
    if (ce) begin
        if (in0_WIDTH == 1) dividend_tmp <= ~cal_tmp[cal_WIDTH];
        else           dividend_tmp <= {dividend_tmp_mux[in0_WIDTH-2:0], ~cal_tmp[cal_WIDTH]};
        remd_tmp     <= cal_tmp[cal_WIDTH]? comb_tmp : cal_tmp[in0_WIDTH-1:0];
    end
end

endmodule

module vadd_urem_9ns_4ns_3_13_seq_1
#(parameter
        ID   = 1,
        NUM_STAGE   = 2,
        din0_WIDTH   = 32,
        din1_WIDTH   = 32,
        dout_WIDTH   = 32
)
(
        input                           clk,
        input                           reset,
        input                           ce,
        input                           start,
        output  reg                     done,
        input           [din0_WIDTH-1:0] din0,
        input           [din1_WIDTH-1:0] din1,
        output          [dout_WIDTH-1:0] dout
);
//------------------------Local signal-------------------
reg                       start0 = 'b0;
wire                      done0;
reg     [din0_WIDTH-1:0] dividend0;
reg     [din1_WIDTH-1:0] divisor0;
wire    [din0_WIDTH-1:0] dividend_u;
wire    [din1_WIDTH-1:0] divisor_u;
wire    [dout_WIDTH-1:0] quot_u;
wire    [dout_WIDTH-1:0] remd_u;
reg     [dout_WIDTH-1:0] quot;
reg     [dout_WIDTH-1:0] remd;
//------------------------Instantiation------------------
vadd_urem_9ns_4ns_3_13_seq_1_divseq #(
    .in0_WIDTH      ( din0_WIDTH ),
    .in1_WIDTH      ( din1_WIDTH ),
    .out_WIDTH      ( dout_WIDTH )
) vadd_urem_9ns_4ns_3_13_seq_1_divseq_u (
    .clk      ( clk ),
    .reset    ( reset ),
    .ce       ( ce ),
    .start    ( start0 ),
    .done     ( done0 ),
    .dividend ( dividend_u ),
    .divisor  ( divisor_u ),
    .quot     ( quot_u ),
    .remd     ( remd_u )
);
//------------------------Body---------------------------
assign dividend_u = dividend0;
assign divisor_u = divisor0;

always @(posedge clk)
begin
    if (ce) begin
        dividend0 <= din0;
        divisor0  <= din1;
        start0    <= start;
    end
end

always @(posedge clk)
begin
    done <= done0;
end

always @(posedge clk)
begin
    if (done0) begin
        quot <= quot_u;
        remd <= remd_u;
    end
end

assign dout = remd;

endmodule



// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1ns/1ps

module vadd_fcmp_32ns_32ns_1_2_no_dsp_1
#(parameter
    ID         = 1,
    NUM_STAGE  = 2,
    din0_WIDTH = 32,
    din1_WIDTH = 32,
    dout_WIDTH = 1
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  ce,
    input  wire [din0_WIDTH-1:0] din0,
    input  wire [din1_WIDTH-1:0] din1,
    input  wire [4:0]            opcode,
    output wire [dout_WIDTH-1:0] dout
);
//------------------------Parameter----------------------
// AutoESL opcode
localparam [4:0]
    AP_OEQ = 5'b00001,
    AP_OGT = 5'b00010,
    AP_OGE = 5'b00011,
    AP_OLT = 5'b00100,
    AP_OLE = 5'b00101,
    AP_ONE = 5'b00110,
    AP_UNO = 5'b01000;
// FPV6 opcode
localparam [7:0]
    OP_EQ = 8'b00010100,
    OP_GT = 8'b00100100,
    OP_GE = 8'b00110100,
    OP_LT = 8'b00001100,
    OP_LE = 8'b00011100,
    OP_NE = 8'b00101100,
    OP_UO = 8'b00000100;
//------------------------Local signal-------------------
wire                  a_tvalid;
wire [31:0]           a_tdata;
wire                  b_tvalid;
wire [31:0]           b_tdata;
wire                  op_tvalid;
reg  [7:0]            op_tdata;
wire                  r_tvalid;
wire [7:0]            r_tdata;
reg  [din0_WIDTH-1:0] din0_buf1;
reg  [din1_WIDTH-1:0] din1_buf1;
reg  [4:0]            opcode_buf1;
reg                   ce_r;
wire [dout_WIDTH-1:0] dout_i;
reg  [dout_WIDTH-1:0] dout_r;
//------------------------Instantiation------------------
vadd_fcmp_32ns_32ns_1_2_no_dsp_1_ip vadd_fcmp_32ns_32ns_1_2_no_dsp_1_ip_u (
    .s_axis_a_tvalid         ( a_tvalid ),
    .s_axis_a_tdata          ( a_tdata ),
    .s_axis_b_tvalid         ( b_tvalid ),
    .s_axis_b_tdata          ( b_tdata ),
    .s_axis_operation_tvalid ( op_tvalid ),
    .s_axis_operation_tdata  ( op_tdata ),
    .m_axis_result_tvalid    ( r_tvalid ),
    .m_axis_result_tdata     ( r_tdata )
);
//------------------------Body---------------------------
assign a_tvalid  = 1'b1;
assign a_tdata   = din0_buf1;
assign b_tvalid  = 1'b1;
assign b_tdata   = din1_buf1;
assign op_tvalid = 1'b1;
assign dout_i    = r_tdata[0];

always @(*) begin
    case (opcode_buf1)
        AP_OEQ  : op_tdata = OP_EQ;
        AP_OGT  : op_tdata = OP_GT;
        AP_OGE  : op_tdata = OP_GE;
        AP_OLT  : op_tdata = OP_LT;
        AP_OLE  : op_tdata = OP_LE;
        AP_ONE  : op_tdata = OP_NE;
        AP_UNO  : op_tdata = OP_UO;
        default : op_tdata = OP_EQ;
    endcase
end

always @(posedge clk) begin
    if (ce) begin
        din0_buf1   <= din0;
        din1_buf1   <= din1;
        opcode_buf1 <= opcode;
    end
end

always @ (posedge clk) begin
    ce_r <= ce;
end

always @ (posedge clk) begin
    if (ce_r) begin
        dout_r <= dout_i;
    end
end

assign dout = ce_r?dout_i:dout_r;
endmodule
// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1ns/1ps

module vadd_fadd_32ns_32ns_32_10_full_dsp_1
#(parameter
    ID         = 1,
    NUM_STAGE  = 3,
    din0_WIDTH = 32,
    din1_WIDTH = 32,
    dout_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  ce,
    input  wire [din0_WIDTH-1:0] din0,
    input  wire [din1_WIDTH-1:0] din1,
    output wire [dout_WIDTH-1:0] dout
);
//------------------------Local signal-------------------
wire                  aclk;
wire                  aclken;
wire                  a_tvalid;
wire [31:0]           a_tdata;
wire                  b_tvalid;
wire [31:0]           b_tdata;
wire                  r_tvalid;
wire [31:0]           r_tdata;
reg  [din0_WIDTH-1:0] din0_buf1;
reg  [din1_WIDTH-1:0] din1_buf1;
reg                   ce_r;
wire [dout_WIDTH-1:0] dout_i;
reg  [dout_WIDTH-1:0] dout_r;
//------------------------Instantiation------------------
vadd_fadd_32ns_32ns_32_10_full_dsp_1_ip vadd_fadd_32ns_32ns_32_10_full_dsp_1_ip_u (
    .aclk                 ( aclk ),
    .aclken               ( aclken ),
    .s_axis_a_tvalid      ( a_tvalid ),
    .s_axis_a_tdata       ( a_tdata ),
    .s_axis_b_tvalid      ( b_tvalid ),
    .s_axis_b_tdata       ( b_tdata ),
    .m_axis_result_tvalid ( r_tvalid ),
    .m_axis_result_tdata  ( r_tdata )
);
//------------------------Body---------------------------
assign aclk     = clk;
assign aclken   = ce_r;
assign a_tvalid = 1'b1;
assign a_tdata  = din0_buf1;
assign b_tvalid = 1'b1;
assign b_tdata  = din1_buf1;
assign dout_i   = r_tdata;

always @(posedge clk) begin
    if (ce) begin
        din0_buf1 <= din0;
        din1_buf1 <= din1;
    end
end

always @ (posedge clk) begin
    ce_r <= ce;
end

always @ (posedge clk) begin
    if (ce_r) begin
        dout_r <= dout_i;
    end
end

assign dout = ce_r?dout_i:dout_r;
endmodule
// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1ns/1ps

module vadd_fmul_32ns_32ns_32_5_max_dsp_1
#(parameter
    ID         = 1,
    NUM_STAGE  = 3,
    din0_WIDTH = 32,
    din1_WIDTH = 32,
    dout_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  ce,
    input  wire [din0_WIDTH-1:0] din0,
    input  wire [din1_WIDTH-1:0] din1,
    output wire [dout_WIDTH-1:0] dout
);
//------------------------Local signal-------------------
wire                  aclk;
wire                  aclken;
wire                  a_tvalid;
wire [31:0]           a_tdata;
wire                  b_tvalid;
wire [31:0]           b_tdata;
wire                  r_tvalid;
wire [31:0]           r_tdata;
reg  [din0_WIDTH-1:0] din0_buf1;
reg  [din1_WIDTH-1:0] din1_buf1;
reg                   ce_r;
wire [dout_WIDTH-1:0] dout_i;
reg  [dout_WIDTH-1:0] dout_r;
//------------------------Instantiation------------------
vadd_fmul_32ns_32ns_32_5_max_dsp_1_ip vadd_fmul_32ns_32ns_32_5_max_dsp_1_ip_u (
    .aclk                 ( aclk ),
    .aclken               ( aclken ),
    .s_axis_a_tvalid      ( a_tvalid ),
    .s_axis_a_tdata       ( a_tdata ),
    .s_axis_b_tvalid      ( b_tvalid ),
    .s_axis_b_tdata       ( b_tdata ),
    .m_axis_result_tvalid ( r_tvalid ),
    .m_axis_result_tdata  ( r_tdata )
);
//------------------------Body---------------------------
assign aclk     = clk;
assign aclken   = ce_r;
assign a_tvalid = 1'b1;
assign a_tdata  = din0_buf1;
assign b_tvalid = 1'b1;
assign b_tdata  = din1_buf1;
assign dout_i   = r_tdata;

always @(posedge clk) begin
    if (ce) begin
        din0_buf1 <= din0;
        din1_buf1 <= din1;
    end
end

always @ (posedge clk) begin
    ce_r <= ce;
end

always @ (posedge clk) begin
    if (ce_r) begin
        dout_r <= dout_i;
    end
end

assign dout = ce_r?dout_i:dout_r;
endmodule
// ==============================================================
// Generated by Vitis HLS v2024.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

(* CORE_GENERATION_INFO="vadd_vadd,hls_ip_2024_1,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xcvu47p-fsvh2892-2-e,HLS_INPUT_CLOCK=3.000000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=2.190000,HLS_SYN_LAT=121611025,HLS_SYN_TPT=none,HLS_SYN_MEM=8,HLS_SYN_DSP=0,HLS_SYN_FF=15054,HLS_SYN_LUT=17104,HLS_VERSION=2024_1}" *)

module vadd (
        ap_clk,
        ap_rst_n,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        m_axi_gmem0_AWVALID,
        m_axi_gmem0_AWREADY,
        m_axi_gmem0_AWADDR,
        m_axi_gmem0_AWID,
        m_axi_gmem0_AWLEN,
        m_axi_gmem0_AWSIZE,
        m_axi_gmem0_AWBURST,
        m_axi_gmem0_AWLOCK,
        m_axi_gmem0_AWCACHE,
        m_axi_gmem0_AWPROT,
        m_axi_gmem0_AWQOS,
        m_axi_gmem0_AWREGION,
        m_axi_gmem0_AWUSER,
        m_axi_gmem0_WVALID,
        m_axi_gmem0_WREADY,
        m_axi_gmem0_WDATA,
        m_axi_gmem0_WSTRB,
        m_axi_gmem0_WLAST,
        m_axi_gmem0_WID,
        m_axi_gmem0_WUSER,
        m_axi_gmem0_ARVALID,
        m_axi_gmem0_ARREADY,
        m_axi_gmem0_ARADDR,
        m_axi_gmem0_ARID,
        m_axi_gmem0_ARLEN,
        m_axi_gmem0_ARSIZE,
        m_axi_gmem0_ARBURST,
        m_axi_gmem0_ARLOCK,
        m_axi_gmem0_ARCACHE,
        m_axi_gmem0_ARPROT,
        m_axi_gmem0_ARQOS,
        m_axi_gmem0_ARREGION,
        m_axi_gmem0_ARUSER,
        m_axi_gmem0_RVALID,
        m_axi_gmem0_RREADY,
        m_axi_gmem0_RDATA,
        m_axi_gmem0_RLAST,
        m_axi_gmem0_RID,
        m_axi_gmem0_RUSER,
        m_axi_gmem0_RRESP,
        m_axi_gmem0_BVALID,
        m_axi_gmem0_BREADY,
        m_axi_gmem0_BRESP,
        m_axi_gmem0_BID,
        m_axi_gmem0_BUSER,
        m_axi_gmem1_AWVALID,
        m_axi_gmem1_AWREADY,
        m_axi_gmem1_AWADDR,
        m_axi_gmem1_AWID,
        m_axi_gmem1_AWLEN,
        m_axi_gmem1_AWSIZE,
        m_axi_gmem1_AWBURST,
        m_axi_gmem1_AWLOCK,
        m_axi_gmem1_AWCACHE,
        m_axi_gmem1_AWPROT,
        m_axi_gmem1_AWQOS,
        m_axi_gmem1_AWREGION,
        m_axi_gmem1_AWUSER,
        m_axi_gmem1_WVALID,
        m_axi_gmem1_WREADY,
        m_axi_gmem1_WDATA,
        m_axi_gmem1_WSTRB,
        m_axi_gmem1_WLAST,
        m_axi_gmem1_WID,
        m_axi_gmem1_WUSER,
        m_axi_gmem1_ARVALID,
        m_axi_gmem1_ARREADY,
        m_axi_gmem1_ARADDR,
        m_axi_gmem1_ARID,
        m_axi_gmem1_ARLEN,
        m_axi_gmem1_ARSIZE,
        m_axi_gmem1_ARBURST,
        m_axi_gmem1_ARLOCK,
        m_axi_gmem1_ARCACHE,
        m_axi_gmem1_ARPROT,
        m_axi_gmem1_ARQOS,
        m_axi_gmem1_ARREGION,
        m_axi_gmem1_ARUSER,
        m_axi_gmem1_RVALID,
        m_axi_gmem1_RREADY,
        m_axi_gmem1_RDATA,
        m_axi_gmem1_RLAST,
        m_axi_gmem1_RID,
        m_axi_gmem1_RUSER,
        m_axi_gmem1_RRESP,
        m_axi_gmem1_BVALID,
        m_axi_gmem1_BREADY,
        m_axi_gmem1_BRESP,
        m_axi_gmem1_BID,
        m_axi_gmem1_BUSER,
        s_axi_control_AWVALID,
        s_axi_control_AWREADY,
        s_axi_control_AWADDR,
        s_axi_control_WVALID,
        s_axi_control_WREADY,
        s_axi_control_WDATA,
        s_axi_control_WSTRB,
        s_axi_control_ARVALID,
        s_axi_control_ARREADY,
        s_axi_control_ARADDR,
        s_axi_control_RVALID,
        s_axi_control_RREADY,
        s_axi_control_RDATA,
        s_axi_control_RRESP,
        s_axi_control_BVALID,
        s_axi_control_BREADY,
        s_axi_control_BRESP
);

parameter    ap_ST_fsm_state1 = 2'd1;
parameter    ap_ST_fsm_state2 = 2'd2;
parameter    C_S_AXI_CONTROL_DATA_WIDTH = 32;
parameter    C_S_AXI_CONTROL_ADDR_WIDTH = 8;
parameter    C_S_AXI_DATA_WIDTH = 32;
parameter    C_M_AXI_GMEM0_ID_WIDTH = 1;
parameter    C_M_AXI_GMEM0_ADDR_WIDTH = 64;
parameter    C_M_AXI_GMEM0_DATA_WIDTH = 32;
parameter    C_M_AXI_GMEM0_AWUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM0_ARUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM0_WUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM0_RUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM0_BUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM0_USER_VALUE = 0;
parameter    C_M_AXI_GMEM0_PROT_VALUE = 0;
parameter    C_M_AXI_GMEM0_CACHE_VALUE = 3;
parameter    C_M_AXI_DATA_WIDTH = 32;
parameter    C_M_AXI_GMEM1_ID_WIDTH = 1;
parameter    C_M_AXI_GMEM1_ADDR_WIDTH = 64;
parameter    C_M_AXI_GMEM1_DATA_WIDTH = 32;
parameter    C_M_AXI_GMEM1_AWUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM1_ARUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM1_WUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM1_RUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM1_BUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM1_USER_VALUE = 0;
parameter    C_M_AXI_GMEM1_PROT_VALUE = 0;
parameter    C_M_AXI_GMEM1_CACHE_VALUE = 3;

parameter C_S_AXI_CONTROL_WSTRB_WIDTH = (32 / 8);
parameter C_S_AXI_WSTRB_WIDTH = (32 / 8);
parameter C_M_AXI_GMEM0_WSTRB_WIDTH = (32 / 8);
parameter C_M_AXI_WSTRB_WIDTH = (32 / 8);
parameter C_M_AXI_GMEM1_WSTRB_WIDTH = (32 / 8);

input   ap_clk;
input   ap_rst_n;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output   m_axi_gmem0_AWVALID;
input   m_axi_gmem0_AWREADY;
output  [C_M_AXI_GMEM0_ADDR_WIDTH - 1:0] m_axi_gmem0_AWADDR;
output  [C_M_AXI_GMEM0_ID_WIDTH - 1:0] m_axi_gmem0_AWID;
output  [7:0] m_axi_gmem0_AWLEN;
output  [2:0] m_axi_gmem0_AWSIZE;
output  [1:0] m_axi_gmem0_AWBURST;
output  [1:0] m_axi_gmem0_AWLOCK;
output  [3:0] m_axi_gmem0_AWCACHE;
output  [2:0] m_axi_gmem0_AWPROT;
output  [3:0] m_axi_gmem0_AWQOS;
output  [3:0] m_axi_gmem0_AWREGION;
output  [C_M_AXI_GMEM0_AWUSER_WIDTH - 1:0] m_axi_gmem0_AWUSER;
output   m_axi_gmem0_WVALID;
input   m_axi_gmem0_WREADY;
output  [C_M_AXI_GMEM0_DATA_WIDTH - 1:0] m_axi_gmem0_WDATA;
output  [C_M_AXI_GMEM0_WSTRB_WIDTH - 1:0] m_axi_gmem0_WSTRB;
output   m_axi_gmem0_WLAST;
output  [C_M_AXI_GMEM0_ID_WIDTH - 1:0] m_axi_gmem0_WID;
output  [C_M_AXI_GMEM0_WUSER_WIDTH - 1:0] m_axi_gmem0_WUSER;
output   m_axi_gmem0_ARVALID;
input   m_axi_gmem0_ARREADY;
output  [C_M_AXI_GMEM0_ADDR_WIDTH - 1:0] m_axi_gmem0_ARADDR;
output  [C_M_AXI_GMEM0_ID_WIDTH - 1:0] m_axi_gmem0_ARID;
output  [7:0] m_axi_gmem0_ARLEN;
output  [2:0] m_axi_gmem0_ARSIZE;
output  [1:0] m_axi_gmem0_ARBURST;
output  [1:0] m_axi_gmem0_ARLOCK;
output  [3:0] m_axi_gmem0_ARCACHE;
output  [2:0] m_axi_gmem0_ARPROT;
output  [3:0] m_axi_gmem0_ARQOS;
output  [3:0] m_axi_gmem0_ARREGION;
output  [C_M_AXI_GMEM0_ARUSER_WIDTH - 1:0] m_axi_gmem0_ARUSER;
input   m_axi_gmem0_RVALID;
output   m_axi_gmem0_RREADY;
input  [C_M_AXI_GMEM0_DATA_WIDTH - 1:0] m_axi_gmem0_RDATA;
input   m_axi_gmem0_RLAST;
input  [C_M_AXI_GMEM0_ID_WIDTH - 1:0] m_axi_gmem0_RID;
input  [C_M_AXI_GMEM0_RUSER_WIDTH - 1:0] m_axi_gmem0_RUSER;
input  [1:0] m_axi_gmem0_RRESP;
input   m_axi_gmem0_BVALID;
output   m_axi_gmem0_BREADY;
input  [1:0] m_axi_gmem0_BRESP;
input  [C_M_AXI_GMEM0_ID_WIDTH - 1:0] m_axi_gmem0_BID;
input  [C_M_AXI_GMEM0_BUSER_WIDTH - 1:0] m_axi_gmem0_BUSER;
output   m_axi_gmem1_AWVALID;
input   m_axi_gmem1_AWREADY;
output  [C_M_AXI_GMEM1_ADDR_WIDTH - 1:0] m_axi_gmem1_AWADDR;
output  [C_M_AXI_GMEM1_ID_WIDTH - 1:0] m_axi_gmem1_AWID;
output  [7:0] m_axi_gmem1_AWLEN;
output  [2:0] m_axi_gmem1_AWSIZE;
output  [1:0] m_axi_gmem1_AWBURST;
output  [1:0] m_axi_gmem1_AWLOCK;
output  [3:0] m_axi_gmem1_AWCACHE;
output  [2:0] m_axi_gmem1_AWPROT;
output  [3:0] m_axi_gmem1_AWQOS;
output  [3:0] m_axi_gmem1_AWREGION;
output  [C_M_AXI_GMEM1_AWUSER_WIDTH - 1:0] m_axi_gmem1_AWUSER;
output   m_axi_gmem1_WVALID;
input   m_axi_gmem1_WREADY;
output  [C_M_AXI_GMEM1_DATA_WIDTH - 1:0] m_axi_gmem1_WDATA;
output  [C_M_AXI_GMEM1_WSTRB_WIDTH - 1:0] m_axi_gmem1_WSTRB;
output   m_axi_gmem1_WLAST;
output  [C_M_AXI_GMEM1_ID_WIDTH - 1:0] m_axi_gmem1_WID;
output  [C_M_AXI_GMEM1_WUSER_WIDTH - 1:0] m_axi_gmem1_WUSER;
output   m_axi_gmem1_ARVALID;
input   m_axi_gmem1_ARREADY;
output  [C_M_AXI_GMEM1_ADDR_WIDTH - 1:0] m_axi_gmem1_ARADDR;
output  [C_M_AXI_GMEM1_ID_WIDTH - 1:0] m_axi_gmem1_ARID;
output  [7:0] m_axi_gmem1_ARLEN;
output  [2:0] m_axi_gmem1_ARSIZE;
output  [1:0] m_axi_gmem1_ARBURST;
output  [1:0] m_axi_gmem1_ARLOCK;
output  [3:0] m_axi_gmem1_ARCACHE;
output  [2:0] m_axi_gmem1_ARPROT;
output  [3:0] m_axi_gmem1_ARQOS;
output  [3:0] m_axi_gmem1_ARREGION;
output  [C_M_AXI_GMEM1_ARUSER_WIDTH - 1:0] m_axi_gmem1_ARUSER;
input   m_axi_gmem1_RVALID;
output   m_axi_gmem1_RREADY;
input  [C_M_AXI_GMEM1_DATA_WIDTH - 1:0] m_axi_gmem1_RDATA;
input   m_axi_gmem1_RLAST;
input  [C_M_AXI_GMEM1_ID_WIDTH - 1:0] m_axi_gmem1_RID;
input  [C_M_AXI_GMEM1_RUSER_WIDTH - 1:0] m_axi_gmem1_RUSER;
input  [1:0] m_axi_gmem1_RRESP;
input   m_axi_gmem1_BVALID;
output   m_axi_gmem1_BREADY;
input  [1:0] m_axi_gmem1_BRESP;
input  [C_M_AXI_GMEM1_ID_WIDTH - 1:0] m_axi_gmem1_BID;
input  [C_M_AXI_GMEM1_BUSER_WIDTH - 1:0] m_axi_gmem1_BUSER;
input   s_axi_control_AWVALID;
output   s_axi_control_AWREADY;
input  [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_AWADDR;
input   s_axi_control_WVALID;
output   s_axi_control_WREADY;
input  [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_WDATA;
input  [C_S_AXI_CONTROL_WSTRB_WIDTH - 1:0] s_axi_control_WSTRB;
input   s_axi_control_ARVALID;
output   s_axi_control_ARREADY;
input  [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_ARADDR;
output   s_axi_control_RVALID;
input   s_axi_control_RREADY;
output  [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_RDATA;
output  [1:0] s_axi_control_RRESP;
output   s_axi_control_BVALID;
input   s_axi_control_BREADY;
output  [1:0] s_axi_control_BRESP;

reg ap_done;
reg ap_idle;
reg ap_ready;

 reg    ap_rst_n_inv;
(* fsm_encoding = "none" *) reg   [1:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
wire   [63:0] input_seq;
wire   [63:0] wih0;
wire   [63:0] whh0;
wire   [63:0] bih0;
wire   [63:0] bhh0;
wire   [63:0] wih1;
wire   [63:0] whh1;
wire   [63:0] bih1;
wire   [63:0] bhh1;
wire   [63:0] wfc;
wire   [63:0] bfc;
wire   [63:0] pred_out;
reg   [63:0] pred_out_read_reg_196;
reg   [63:0] bfc_read_reg_201;
reg   [63:0] wfc_read_reg_206;
reg   [63:0] bhh1_read_reg_211;
reg   [63:0] bih1_read_reg_216;
reg   [63:0] whh1_read_reg_221;
reg   [63:0] wih1_read_reg_226;
reg   [63:0] bhh0_read_reg_231;
reg   [63:0] bih0_read_reg_236;
reg   [63:0] whh0_read_reg_241;
reg   [63:0] wih0_read_reg_246;
reg   [63:0] input_seq_read_reg_251;
wire    grp_lstm_inference_fu_162_ap_start;
wire    grp_lstm_inference_fu_162_ap_done;
wire    grp_lstm_inference_fu_162_ap_idle;
wire    grp_lstm_inference_fu_162_ap_ready;
wire    grp_lstm_inference_fu_162_m_axi_gmem0_AWVALID;
wire   [63:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWADDR;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWID;
wire   [31:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWLEN;
wire   [2:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWSIZE;
wire   [1:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWBURST;
wire   [1:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWLOCK;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWCACHE;
wire   [2:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWPROT;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWQOS;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWREGION;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem0_AWUSER;
wire    grp_lstm_inference_fu_162_m_axi_gmem0_WVALID;
wire   [31:0] grp_lstm_inference_fu_162_m_axi_gmem0_WDATA;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem0_WSTRB;
wire    grp_lstm_inference_fu_162_m_axi_gmem0_WLAST;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem0_WID;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem0_WUSER;
wire    grp_lstm_inference_fu_162_m_axi_gmem0_ARVALID;
wire   [63:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARADDR;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARID;
wire   [31:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARLEN;
wire   [2:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARSIZE;
wire   [1:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARBURST;
wire   [1:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARLOCK;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARCACHE;
wire   [2:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARPROT;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARQOS;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARREGION;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem0_ARUSER;
wire    grp_lstm_inference_fu_162_m_axi_gmem0_RREADY;
wire    grp_lstm_inference_fu_162_m_axi_gmem0_BREADY;
wire    grp_lstm_inference_fu_162_m_axi_gmem1_AWVALID;
wire   [63:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWADDR;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWID;
wire   [31:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWLEN;
wire   [2:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWSIZE;
wire   [1:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWBURST;
wire   [1:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWLOCK;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWCACHE;
wire   [2:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWPROT;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWQOS;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWREGION;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem1_AWUSER;
wire    grp_lstm_inference_fu_162_m_axi_gmem1_WVALID;
wire   [31:0] grp_lstm_inference_fu_162_m_axi_gmem1_WDATA;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem1_WSTRB;
wire    grp_lstm_inference_fu_162_m_axi_gmem1_WLAST;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem1_WID;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem1_WUSER;
wire    grp_lstm_inference_fu_162_m_axi_gmem1_ARVALID;
wire   [63:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARADDR;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARID;
wire   [31:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARLEN;
wire   [2:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARSIZE;
wire   [1:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARBURST;
wire   [1:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARLOCK;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARCACHE;
wire   [2:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARPROT;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARQOS;
wire   [3:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARREGION;
wire   [0:0] grp_lstm_inference_fu_162_m_axi_gmem1_ARUSER;
wire    grp_lstm_inference_fu_162_m_axi_gmem1_RREADY;
wire    grp_lstm_inference_fu_162_m_axi_gmem1_BREADY;
wire    gmem0_AWREADY;
wire    gmem0_WREADY;
reg    gmem0_ARVALID;
wire    gmem0_ARREADY;
wire    gmem0_RVALID;
reg    gmem0_RREADY;
wire   [31:0] gmem0_RDATA;
wire   [8:0] gmem0_RFIFONUM;
wire    gmem0_BVALID;
reg    gmem1_AWVALID;
wire    gmem1_AWREADY;
reg    gmem1_WVALID;
wire    gmem1_WREADY;
reg    gmem1_ARVALID;
wire    gmem1_ARREADY;
wire    gmem1_RVALID;
reg    gmem1_RREADY;
wire   [31:0] gmem1_RDATA;
wire   [8:0] gmem1_RFIFONUM;
wire    gmem1_BVALID;
reg    gmem1_BREADY;
reg    grp_lstm_inference_fu_162_ap_start_reg;
wire    ap_CS_fsm_state2;
reg   [1:0] ap_NS_fsm;
reg    ap_ST_fsm_state1_blk;
reg    ap_ST_fsm_state2_blk;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 2'd1;
#0 grp_lstm_inference_fu_162_ap_start_reg = 1'b0;
end

vadd_lstm_inference grp_lstm_inference_fu_162(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .ap_start(grp_lstm_inference_fu_162_ap_start),
    .ap_done(grp_lstm_inference_fu_162_ap_done),
    .ap_idle(grp_lstm_inference_fu_162_ap_idle),
    .ap_ready(grp_lstm_inference_fu_162_ap_ready),
    .m_axi_gmem0_AWVALID(grp_lstm_inference_fu_162_m_axi_gmem0_AWVALID),
    .m_axi_gmem0_AWREADY(1'b0),
    .m_axi_gmem0_AWADDR(grp_lstm_inference_fu_162_m_axi_gmem0_AWADDR),
    .m_axi_gmem0_AWID(grp_lstm_inference_fu_162_m_axi_gmem0_AWID),
    .m_axi_gmem0_AWLEN(grp_lstm_inference_fu_162_m_axi_gmem0_AWLEN),
    .m_axi_gmem0_AWSIZE(grp_lstm_inference_fu_162_m_axi_gmem0_AWSIZE),
    .m_axi_gmem0_AWBURST(grp_lstm_inference_fu_162_m_axi_gmem0_AWBURST),
    .m_axi_gmem0_AWLOCK(grp_lstm_inference_fu_162_m_axi_gmem0_AWLOCK),
    .m_axi_gmem0_AWCACHE(grp_lstm_inference_fu_162_m_axi_gmem0_AWCACHE),
    .m_axi_gmem0_AWPROT(grp_lstm_inference_fu_162_m_axi_gmem0_AWPROT),
    .m_axi_gmem0_AWQOS(grp_lstm_inference_fu_162_m_axi_gmem0_AWQOS),
    .m_axi_gmem0_AWREGION(grp_lstm_inference_fu_162_m_axi_gmem0_AWREGION),
    .m_axi_gmem0_AWUSER(grp_lstm_inference_fu_162_m_axi_gmem0_AWUSER),
    .m_axi_gmem0_WVALID(grp_lstm_inference_fu_162_m_axi_gmem0_WVALID),
    .m_axi_gmem0_WREADY(1'b0),
    .m_axi_gmem0_WDATA(grp_lstm_inference_fu_162_m_axi_gmem0_WDATA),
    .m_axi_gmem0_WSTRB(grp_lstm_inference_fu_162_m_axi_gmem0_WSTRB),
    .m_axi_gmem0_WLAST(grp_lstm_inference_fu_162_m_axi_gmem0_WLAST),
    .m_axi_gmem0_WID(grp_lstm_inference_fu_162_m_axi_gmem0_WID),
    .m_axi_gmem0_WUSER(grp_lstm_inference_fu_162_m_axi_gmem0_WUSER),
    .m_axi_gmem0_ARVALID(grp_lstm_inference_fu_162_m_axi_gmem0_ARVALID),
    .m_axi_gmem0_ARREADY(gmem0_ARREADY),
    .m_axi_gmem0_ARADDR(grp_lstm_inference_fu_162_m_axi_gmem0_ARADDR),
    .m_axi_gmem0_ARID(grp_lstm_inference_fu_162_m_axi_gmem0_ARID),
    .m_axi_gmem0_ARLEN(grp_lstm_inference_fu_162_m_axi_gmem0_ARLEN),
    .m_axi_gmem0_ARSIZE(grp_lstm_inference_fu_162_m_axi_gmem0_ARSIZE),
    .m_axi_gmem0_ARBURST(grp_lstm_inference_fu_162_m_axi_gmem0_ARBURST),
    .m_axi_gmem0_ARLOCK(grp_lstm_inference_fu_162_m_axi_gmem0_ARLOCK),
    .m_axi_gmem0_ARCACHE(grp_lstm_inference_fu_162_m_axi_gmem0_ARCACHE),
    .m_axi_gmem0_ARPROT(grp_lstm_inference_fu_162_m_axi_gmem0_ARPROT),
    .m_axi_gmem0_ARQOS(grp_lstm_inference_fu_162_m_axi_gmem0_ARQOS),
    .m_axi_gmem0_ARREGION(grp_lstm_inference_fu_162_m_axi_gmem0_ARREGION),
    .m_axi_gmem0_ARUSER(grp_lstm_inference_fu_162_m_axi_gmem0_ARUSER),
    .m_axi_gmem0_RVALID(gmem0_RVALID),
    .m_axi_gmem0_RREADY(grp_lstm_inference_fu_162_m_axi_gmem0_RREADY),
    .m_axi_gmem0_RDATA(gmem0_RDATA),
    .m_axi_gmem0_RLAST(1'b0),
    .m_axi_gmem0_RID(1'd0),
    .m_axi_gmem0_RFIFONUM(gmem0_RFIFONUM),
    .m_axi_gmem0_RUSER(1'd0),
    .m_axi_gmem0_RRESP(2'd0),
    .m_axi_gmem0_BVALID(1'b0),
    .m_axi_gmem0_BREADY(grp_lstm_inference_fu_162_m_axi_gmem0_BREADY),
    .m_axi_gmem0_BRESP(2'd0),
    .m_axi_gmem0_BID(1'd0),
    .m_axi_gmem0_BUSER(1'd0),
    .input_seq(input_seq_read_reg_251),
    .wih0(wih0_read_reg_246),
    .whh0(whh0_read_reg_241),
    .bih0(bih0_read_reg_236),
    .bhh0(bhh0_read_reg_231),
    .m_axi_gmem1_AWVALID(grp_lstm_inference_fu_162_m_axi_gmem1_AWVALID),
    .m_axi_gmem1_AWREADY(gmem1_AWREADY),
    .m_axi_gmem1_AWADDR(grp_lstm_inference_fu_162_m_axi_gmem1_AWADDR),
    .m_axi_gmem1_AWID(grp_lstm_inference_fu_162_m_axi_gmem1_AWID),
    .m_axi_gmem1_AWLEN(grp_lstm_inference_fu_162_m_axi_gmem1_AWLEN),
    .m_axi_gmem1_AWSIZE(grp_lstm_inference_fu_162_m_axi_gmem1_AWSIZE),
    .m_axi_gmem1_AWBURST(grp_lstm_inference_fu_162_m_axi_gmem1_AWBURST),
    .m_axi_gmem1_AWLOCK(grp_lstm_inference_fu_162_m_axi_gmem1_AWLOCK),
    .m_axi_gmem1_AWCACHE(grp_lstm_inference_fu_162_m_axi_gmem1_AWCACHE),
    .m_axi_gmem1_AWPROT(grp_lstm_inference_fu_162_m_axi_gmem1_AWPROT),
    .m_axi_gmem1_AWQOS(grp_lstm_inference_fu_162_m_axi_gmem1_AWQOS),
    .m_axi_gmem1_AWREGION(grp_lstm_inference_fu_162_m_axi_gmem1_AWREGION),
    .m_axi_gmem1_AWUSER(grp_lstm_inference_fu_162_m_axi_gmem1_AWUSER),
    .m_axi_gmem1_WVALID(grp_lstm_inference_fu_162_m_axi_gmem1_WVALID),
    .m_axi_gmem1_WREADY(gmem1_WREADY),
    .m_axi_gmem1_WDATA(grp_lstm_inference_fu_162_m_axi_gmem1_WDATA),
    .m_axi_gmem1_WSTRB(grp_lstm_inference_fu_162_m_axi_gmem1_WSTRB),
    .m_axi_gmem1_WLAST(grp_lstm_inference_fu_162_m_axi_gmem1_WLAST),
    .m_axi_gmem1_WID(grp_lstm_inference_fu_162_m_axi_gmem1_WID),
    .m_axi_gmem1_WUSER(grp_lstm_inference_fu_162_m_axi_gmem1_WUSER),
    .m_axi_gmem1_ARVALID(grp_lstm_inference_fu_162_m_axi_gmem1_ARVALID),
    .m_axi_gmem1_ARREADY(gmem1_ARREADY),
    .m_axi_gmem1_ARADDR(grp_lstm_inference_fu_162_m_axi_gmem1_ARADDR),
    .m_axi_gmem1_ARID(grp_lstm_inference_fu_162_m_axi_gmem1_ARID),
    .m_axi_gmem1_ARLEN(grp_lstm_inference_fu_162_m_axi_gmem1_ARLEN),
    .m_axi_gmem1_ARSIZE(grp_lstm_inference_fu_162_m_axi_gmem1_ARSIZE),
    .m_axi_gmem1_ARBURST(grp_lstm_inference_fu_162_m_axi_gmem1_ARBURST),
    .m_axi_gmem1_ARLOCK(grp_lstm_inference_fu_162_m_axi_gmem1_ARLOCK),
    .m_axi_gmem1_ARCACHE(grp_lstm_inference_fu_162_m_axi_gmem1_ARCACHE),
    .m_axi_gmem1_ARPROT(grp_lstm_inference_fu_162_m_axi_gmem1_ARPROT),
    .m_axi_gmem1_ARQOS(grp_lstm_inference_fu_162_m_axi_gmem1_ARQOS),
    .m_axi_gmem1_ARREGION(grp_lstm_inference_fu_162_m_axi_gmem1_ARREGION),
    .m_axi_gmem1_ARUSER(grp_lstm_inference_fu_162_m_axi_gmem1_ARUSER),
    .m_axi_gmem1_RVALID(gmem1_RVALID),
    .m_axi_gmem1_RREADY(grp_lstm_inference_fu_162_m_axi_gmem1_RREADY),
    .m_axi_gmem1_RDATA(gmem1_RDATA),
    .m_axi_gmem1_RLAST(1'b0),
    .m_axi_gmem1_RID(1'd0),
    .m_axi_gmem1_RFIFONUM(gmem1_RFIFONUM),
    .m_axi_gmem1_RUSER(1'd0),
    .m_axi_gmem1_RRESP(2'd0),
    .m_axi_gmem1_BVALID(gmem1_BVALID),
    .m_axi_gmem1_BREADY(grp_lstm_inference_fu_162_m_axi_gmem1_BREADY),
    .m_axi_gmem1_BRESP(2'd0),
    .m_axi_gmem1_BID(1'd0),
    .m_axi_gmem1_BUSER(1'd0),
    .wih1(wih1_read_reg_226),
    .whh1(whh1_read_reg_221),
    .bih1(bih1_read_reg_216),
    .bhh1(bhh1_read_reg_211),
    .wfc(wfc_read_reg_206),
    .bfc(bfc_read_reg_201),
    .pred_out(pred_out_read_reg_196)
);

vadd_control_s_axi #(
    .C_S_AXI_ADDR_WIDTH( C_S_AXI_CONTROL_ADDR_WIDTH ),
    .C_S_AXI_DATA_WIDTH( C_S_AXI_CONTROL_DATA_WIDTH ))
control_s_axi_U(
    .AWVALID(s_axi_control_AWVALID),
    .AWREADY(s_axi_control_AWREADY),
    .AWADDR(s_axi_control_AWADDR),
    .WVALID(s_axi_control_WVALID),
    .WREADY(s_axi_control_WREADY),
    .WDATA(s_axi_control_WDATA),
    .WSTRB(s_axi_control_WSTRB),
    .ARVALID(s_axi_control_ARVALID),
    .ARREADY(s_axi_control_ARREADY),
    .ARADDR(s_axi_control_ARADDR),
    .RVALID(s_axi_control_RVALID),
    .RREADY(s_axi_control_RREADY),
    .RDATA(s_axi_control_RDATA),
    .RRESP(s_axi_control_RRESP),
    .BVALID(s_axi_control_BVALID),
    .BREADY(s_axi_control_BREADY),
    .BRESP(s_axi_control_BRESP),
    .ACLK(ap_clk),
    .ARESET(ap_rst_n_inv),
    .ACLK_EN(1'b1),
    .input_seq(input_seq),
    .wih0(wih0),
    .whh0(whh0),
    .bih0(bih0),
    .bhh0(bhh0),
    .wih1(wih1),
    .whh1(whh1),
    .bih1(bih1),
    .bhh1(bhh1),
    .wfc(wfc),
    .bfc(bfc),
    .pred_out(pred_out)
);

vadd_gmem0_m_axi #(
    .CONSERVATIVE( 1 ),
    .USER_MAXREQS( 7 ),
    .MAX_READ_BURST_LENGTH( 16 ),
    .MAX_WRITE_BURST_LENGTH( 16 ),
    .C_M_AXI_ID_WIDTH( C_M_AXI_GMEM0_ID_WIDTH ),
    .C_M_AXI_ADDR_WIDTH( C_M_AXI_GMEM0_ADDR_WIDTH ),
    .C_M_AXI_DATA_WIDTH( C_M_AXI_GMEM0_DATA_WIDTH ),
    .C_M_AXI_AWUSER_WIDTH( C_M_AXI_GMEM0_AWUSER_WIDTH ),
    .C_M_AXI_ARUSER_WIDTH( C_M_AXI_GMEM0_ARUSER_WIDTH ),
    .C_M_AXI_WUSER_WIDTH( C_M_AXI_GMEM0_WUSER_WIDTH ),
    .C_M_AXI_RUSER_WIDTH( C_M_AXI_GMEM0_RUSER_WIDTH ),
    .C_M_AXI_BUSER_WIDTH( C_M_AXI_GMEM0_BUSER_WIDTH ),
    .C_USER_VALUE( C_M_AXI_GMEM0_USER_VALUE ),
    .C_PROT_VALUE( C_M_AXI_GMEM0_PROT_VALUE ),
    .C_CACHE_VALUE( C_M_AXI_GMEM0_CACHE_VALUE ),
    .CH0_USER_RFIFONUM_WIDTH( 9 ),
    .CH0_USER_DW( 32 ),
    .CH0_USER_AW( 64 ),
    .NUM_READ_OUTSTANDING( 16 ),
    .NUM_WRITE_OUTSTANDING( 0 ))
gmem0_m_axi_U(
    .AWVALID(m_axi_gmem0_AWVALID),
    .AWREADY(m_axi_gmem0_AWREADY),
    .AWADDR(m_axi_gmem0_AWADDR),
    .AWID(m_axi_gmem0_AWID),
    .AWLEN(m_axi_gmem0_AWLEN),
    .AWSIZE(m_axi_gmem0_AWSIZE),
    .AWBURST(m_axi_gmem0_AWBURST),
    .AWLOCK(m_axi_gmem0_AWLOCK),
    .AWCACHE(m_axi_gmem0_AWCACHE),
    .AWPROT(m_axi_gmem0_AWPROT),
    .AWQOS(m_axi_gmem0_AWQOS),
    .AWREGION(m_axi_gmem0_AWREGION),
    .AWUSER(m_axi_gmem0_AWUSER),
    .WVALID(m_axi_gmem0_WVALID),
    .WREADY(m_axi_gmem0_WREADY),
    .WDATA(m_axi_gmem0_WDATA),
    .WSTRB(m_axi_gmem0_WSTRB),
    .WLAST(m_axi_gmem0_WLAST),
    .WID(m_axi_gmem0_WID),
    .WUSER(m_axi_gmem0_WUSER),
    .ARVALID(m_axi_gmem0_ARVALID),
    .ARREADY(m_axi_gmem0_ARREADY),
    .ARADDR(m_axi_gmem0_ARADDR),
    .ARID(m_axi_gmem0_ARID),
    .ARLEN(m_axi_gmem0_ARLEN),
    .ARSIZE(m_axi_gmem0_ARSIZE),
    .ARBURST(m_axi_gmem0_ARBURST),
    .ARLOCK(m_axi_gmem0_ARLOCK),
    .ARCACHE(m_axi_gmem0_ARCACHE),
    .ARPROT(m_axi_gmem0_ARPROT),
    .ARQOS(m_axi_gmem0_ARQOS),
    .ARREGION(m_axi_gmem0_ARREGION),
    .ARUSER(m_axi_gmem0_ARUSER),
    .RVALID(m_axi_gmem0_RVALID),
    .RREADY(m_axi_gmem0_RREADY),
    .RDATA(m_axi_gmem0_RDATA),
    .RLAST(m_axi_gmem0_RLAST),
    .RID(m_axi_gmem0_RID),
    .RUSER(m_axi_gmem0_RUSER),
    .RRESP(m_axi_gmem0_RRESP),
    .BVALID(m_axi_gmem0_BVALID),
    .BREADY(m_axi_gmem0_BREADY),
    .BRESP(m_axi_gmem0_BRESP),
    .BID(m_axi_gmem0_BID),
    .BUSER(m_axi_gmem0_BUSER),
    .ACLK(ap_clk),
    .ARESET(ap_rst_n_inv),
    .ACLK_EN(1'b1),
    .I_CH0_ARVALID(gmem0_ARVALID),
    .I_CH0_ARREADY(gmem0_ARREADY),
    .I_CH0_ARADDR(grp_lstm_inference_fu_162_m_axi_gmem0_ARADDR),
    .I_CH0_ARLEN(grp_lstm_inference_fu_162_m_axi_gmem0_ARLEN),
    .I_CH0_RVALID(gmem0_RVALID),
    .I_CH0_RREADY(gmem0_RREADY),
    .I_CH0_RDATA(gmem0_RDATA),
    .I_CH0_RFIFONUM(gmem0_RFIFONUM),
    .I_CH0_AWVALID(1'b0),
    .I_CH0_AWREADY(gmem0_AWREADY),
    .I_CH0_AWADDR(64'd0),
    .I_CH0_AWLEN(32'd0),
    .I_CH0_WVALID(1'b0),
    .I_CH0_WREADY(gmem0_WREADY),
    .I_CH0_WDATA(32'd0),
    .I_CH0_WSTRB(4'd0),
    .I_CH0_BVALID(gmem0_BVALID),
    .I_CH0_BREADY(1'b0)
);

vadd_gmem1_m_axi #(
    .CONSERVATIVE( 1 ),
    .USER_MAXREQS( 7 ),
    .MAX_READ_BURST_LENGTH( 16 ),
    .MAX_WRITE_BURST_LENGTH( 16 ),
    .C_M_AXI_ID_WIDTH( C_M_AXI_GMEM1_ID_WIDTH ),
    .C_M_AXI_ADDR_WIDTH( C_M_AXI_GMEM1_ADDR_WIDTH ),
    .C_M_AXI_DATA_WIDTH( C_M_AXI_GMEM1_DATA_WIDTH ),
    .C_M_AXI_AWUSER_WIDTH( C_M_AXI_GMEM1_AWUSER_WIDTH ),
    .C_M_AXI_ARUSER_WIDTH( C_M_AXI_GMEM1_ARUSER_WIDTH ),
    .C_M_AXI_WUSER_WIDTH( C_M_AXI_GMEM1_WUSER_WIDTH ),
    .C_M_AXI_RUSER_WIDTH( C_M_AXI_GMEM1_RUSER_WIDTH ),
    .C_M_AXI_BUSER_WIDTH( C_M_AXI_GMEM1_BUSER_WIDTH ),
    .C_USER_VALUE( C_M_AXI_GMEM1_USER_VALUE ),
    .C_PROT_VALUE( C_M_AXI_GMEM1_PROT_VALUE ),
    .C_CACHE_VALUE( C_M_AXI_GMEM1_CACHE_VALUE ),
    .CH0_USER_RFIFONUM_WIDTH( 9 ),
    .CH0_USER_DW( 32 ),
    .CH0_USER_AW( 64 ),
    .NUM_READ_OUTSTANDING( 16 ),
    .NUM_WRITE_OUTSTANDING( 16 ))
gmem1_m_axi_U(
    .AWVALID(m_axi_gmem1_AWVALID),
    .AWREADY(m_axi_gmem1_AWREADY),
    .AWADDR(m_axi_gmem1_AWADDR),
    .AWID(m_axi_gmem1_AWID),
    .AWLEN(m_axi_gmem1_AWLEN),
    .AWSIZE(m_axi_gmem1_AWSIZE),
    .AWBURST(m_axi_gmem1_AWBURST),
    .AWLOCK(m_axi_gmem1_AWLOCK),
    .AWCACHE(m_axi_gmem1_AWCACHE),
    .AWPROT(m_axi_gmem1_AWPROT),
    .AWQOS(m_axi_gmem1_AWQOS),
    .AWREGION(m_axi_gmem1_AWREGION),
    .AWUSER(m_axi_gmem1_AWUSER),
    .WVALID(m_axi_gmem1_WVALID),
    .WREADY(m_axi_gmem1_WREADY),
    .WDATA(m_axi_gmem1_WDATA),
    .WSTRB(m_axi_gmem1_WSTRB),
    .WLAST(m_axi_gmem1_WLAST),
    .WID(m_axi_gmem1_WID),
    .WUSER(m_axi_gmem1_WUSER),
    .ARVALID(m_axi_gmem1_ARVALID),
    .ARREADY(m_axi_gmem1_ARREADY),
    .ARADDR(m_axi_gmem1_ARADDR),
    .ARID(m_axi_gmem1_ARID),
    .ARLEN(m_axi_gmem1_ARLEN),
    .ARSIZE(m_axi_gmem1_ARSIZE),
    .ARBURST(m_axi_gmem1_ARBURST),
    .ARLOCK(m_axi_gmem1_ARLOCK),
    .ARCACHE(m_axi_gmem1_ARCACHE),
    .ARPROT(m_axi_gmem1_ARPROT),
    .ARQOS(m_axi_gmem1_ARQOS),
    .ARREGION(m_axi_gmem1_ARREGION),
    .ARUSER(m_axi_gmem1_ARUSER),
    .RVALID(m_axi_gmem1_RVALID),
    .RREADY(m_axi_gmem1_RREADY),
    .RDATA(m_axi_gmem1_RDATA),
    .RLAST(m_axi_gmem1_RLAST),
    .RID(m_axi_gmem1_RID),
    .RUSER(m_axi_gmem1_RUSER),
    .RRESP(m_axi_gmem1_RRESP),
    .BVALID(m_axi_gmem1_BVALID),
    .BREADY(m_axi_gmem1_BREADY),
    .BRESP(m_axi_gmem1_BRESP),
    .BID(m_axi_gmem1_BID),
    .BUSER(m_axi_gmem1_BUSER),
    .ACLK(ap_clk),
    .ARESET(ap_rst_n_inv),
    .ACLK_EN(1'b1),
    .I_CH0_ARVALID(gmem1_ARVALID),
    .I_CH0_ARREADY(gmem1_ARREADY),
    .I_CH0_ARADDR(grp_lstm_inference_fu_162_m_axi_gmem1_ARADDR),
    .I_CH0_ARLEN(grp_lstm_inference_fu_162_m_axi_gmem1_ARLEN),
    .I_CH0_RVALID(gmem1_RVALID),
    .I_CH0_RREADY(gmem1_RREADY),
    .I_CH0_RDATA(gmem1_RDATA),
    .I_CH0_RFIFONUM(gmem1_RFIFONUM),
    .I_CH0_AWVALID(gmem1_AWVALID),
    .I_CH0_AWREADY(gmem1_AWREADY),
    .I_CH0_AWADDR(grp_lstm_inference_fu_162_m_axi_gmem1_AWADDR),
    .I_CH0_AWLEN(grp_lstm_inference_fu_162_m_axi_gmem1_AWLEN),
    .I_CH0_WVALID(gmem1_WVALID),
    .I_CH0_WREADY(gmem1_WREADY),
    .I_CH0_WDATA(grp_lstm_inference_fu_162_m_axi_gmem1_WDATA),
    .I_CH0_WSTRB(grp_lstm_inference_fu_162_m_axi_gmem1_WSTRB),
    .I_CH0_BVALID(gmem1_BVALID),
    .I_CH0_BREADY(gmem1_BREADY)
);

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        grp_lstm_inference_fu_162_ap_start_reg <= 1'b0;
    end else begin
        if (((ap_start == 1'b1) & (1'b1 == ap_CS_fsm_state1))) begin
            grp_lstm_inference_fu_162_ap_start_reg <= 1'b1;
        end else if ((grp_lstm_inference_fu_162_ap_ready == 1'b1)) begin
            grp_lstm_inference_fu_162_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state1)) begin
        bfc_read_reg_201 <= bfc;
        bhh0_read_reg_231 <= bhh0;
        bhh1_read_reg_211 <= bhh1;
        bih0_read_reg_236 <= bih0;
        bih1_read_reg_216 <= bih1;
        input_seq_read_reg_251 <= input_seq;
        pred_out_read_reg_196 <= pred_out;
        wfc_read_reg_206 <= wfc;
        whh0_read_reg_241 <= whh0;
        whh1_read_reg_221 <= whh1;
        wih0_read_reg_246 <= wih0;
        wih1_read_reg_226 <= wih1;
    end
end

always @ (*) begin
    if ((ap_start == 1'b0)) begin
        ap_ST_fsm_state1_blk = 1'b1;
    end else begin
        ap_ST_fsm_state1_blk = 1'b0;
    end
end

always @ (*) begin
    if ((grp_lstm_inference_fu_162_ap_done == 1'b0)) begin
        ap_ST_fsm_state2_blk = 1'b1;
    end else begin
        ap_ST_fsm_state2_blk = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state2) & (grp_lstm_inference_fu_162_ap_done == 1'b1))) begin
        ap_done = 1'b1;
    end else begin
        ap_done = 1'b0;
    end
end

always @ (*) begin
    if (((ap_start == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state2) & (grp_lstm_inference_fu_162_ap_done == 1'b1))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state2) | (1'b1 == ap_CS_fsm_state1))) begin
        gmem0_ARVALID = grp_lstm_inference_fu_162_m_axi_gmem0_ARVALID;
    end else begin
        gmem0_ARVALID = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state2) | (1'b1 == ap_CS_fsm_state1))) begin
        gmem0_RREADY = grp_lstm_inference_fu_162_m_axi_gmem0_RREADY;
    end else begin
        gmem0_RREADY = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state2) | (1'b1 == ap_CS_fsm_state1))) begin
        gmem1_ARVALID = grp_lstm_inference_fu_162_m_axi_gmem1_ARVALID;
    end else begin
        gmem1_ARVALID = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state2) | (1'b1 == ap_CS_fsm_state1))) begin
        gmem1_AWVALID = grp_lstm_inference_fu_162_m_axi_gmem1_AWVALID;
    end else begin
        gmem1_AWVALID = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state2) | (1'b1 == ap_CS_fsm_state1))) begin
        gmem1_BREADY = grp_lstm_inference_fu_162_m_axi_gmem1_BREADY;
    end else begin
        gmem1_BREADY = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state2) | (1'b1 == ap_CS_fsm_state1))) begin
        gmem1_RREADY = grp_lstm_inference_fu_162_m_axi_gmem1_RREADY;
    end else begin
        gmem1_RREADY = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state2) | (1'b1 == ap_CS_fsm_state1))) begin
        gmem1_WVALID = grp_lstm_inference_fu_162_m_axi_gmem1_WVALID;
    end else begin
        gmem1_WVALID = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if (((ap_start == 1'b1) & (1'b1 == ap_CS_fsm_state1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            if (((1'b1 == ap_CS_fsm_state2) & (grp_lstm_inference_fu_162_ap_done == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

always @ (*) begin
    ap_rst_n_inv = ~ap_rst_n;
end

assign grp_lstm_inference_fu_162_ap_start = grp_lstm_inference_fu_162_ap_start_reg;

endmodule //vadd
