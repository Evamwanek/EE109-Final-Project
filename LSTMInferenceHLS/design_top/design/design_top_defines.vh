// ============================================================================
// Amazon FPGA Hardware Development Kit
//
// Copyright 2024 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License"). You may not use
// this file except in compliance with the License. A copy of the License is
// located at
//
//    http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
// implied. See the License for the specific language governing permissions and
// limitations under the License.
// ============================================================================
`ifndef design_top_DEFINES
`define design_top_DEFINES

// Put module name of the CL design here. This is used to instantiate in top.sv
`define CL_NAME design_top

`endif

localparam int WIDTH_AXI = 32;
localparam int ADDR_WIDTH_OCL = 16;

localparam [15:0] ADDR_COMPUTE_CYCLES  = 16'h0100;
localparam [15:0] ADDR_TRANSFER_CYCLES = 16'h0104;
localparam [15:0] ADDR_TRANSFER_EN     = 16'h0108;
