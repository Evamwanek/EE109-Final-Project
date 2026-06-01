set moduleName fft_kernel_Pipeline_VITIS_LOOP_80_7
set isTopModule 0
set isCombinational 0
set isDatapathOnly 0
set isPipelined 1
set pipeline_type none
set FunctionProtocol ap_ctrl_hs
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set hasInterrupt 0
set DLRegFirstOffset 0
set DLRegItemOffset 0
set C_modelName {fft_kernel_Pipeline_VITIS_LOOP_80_7}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict real_r { MEM_WIDTH 32 MEM_SIZE 4096 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict imag { MEM_WIDTH 32 MEM_SIZE 4096 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict out_real { MEM_WIDTH 32 MEM_SIZE 4096 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 0 }
dict set ap_memory_interface_dict out_imag { MEM_WIDTH 32 MEM_SIZE 4096 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 0 }
set C_modelArgList {
	{ zext_ln75 int 4 regular  }
	{ sub78 int 9 regular  }
	{ zext_ln78 int 4 regular  }
	{ half_stride int 10 regular  }
	{ sub_ln78_cast int 4 regular  }
	{ real_r int 32 regular {array 1024 { 1 3 } 1 1 }  }
	{ imag int 32 regular {array 1024 { 1 3 } 1 1 }  }
	{ out_real int 32 regular {array 1024 { 3 0 } 0 1 }  }
	{ out_imag int 32 regular {array 1024 { 3 0 } 0 1 }  }
}
set hasAXIMCache 0
set hasAXIML2Cache 0
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "zext_ln75", "interface" : "wire", "bitwidth" : 4, "direction" : "READONLY"} , 
 	{ "Name" : "sub78", "interface" : "wire", "bitwidth" : 9, "direction" : "READONLY"} , 
 	{ "Name" : "zext_ln78", "interface" : "wire", "bitwidth" : 4, "direction" : "READONLY"} , 
 	{ "Name" : "half_stride", "interface" : "wire", "bitwidth" : 10, "direction" : "READONLY"} , 
 	{ "Name" : "sub_ln78_cast", "interface" : "wire", "bitwidth" : 4, "direction" : "READONLY"} , 
 	{ "Name" : "real_r", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "imag", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "out_real", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "out_imag", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 29
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ zext_ln75 sc_in sc_lv 4 signal 0 } 
	{ sub78 sc_in sc_lv 9 signal 1 } 
	{ zext_ln78 sc_in sc_lv 4 signal 2 } 
	{ half_stride sc_in sc_lv 10 signal 3 } 
	{ sub_ln78_cast sc_in sc_lv 4 signal 4 } 
	{ real_r_address0 sc_out sc_lv 10 signal 5 } 
	{ real_r_ce0 sc_out sc_logic 1 signal 5 } 
	{ real_r_q0 sc_in sc_lv 32 signal 5 } 
	{ imag_address0 sc_out sc_lv 10 signal 6 } 
	{ imag_ce0 sc_out sc_logic 1 signal 6 } 
	{ imag_q0 sc_in sc_lv 32 signal 6 } 
	{ out_real_address1 sc_out sc_lv 10 signal 7 } 
	{ out_real_ce1 sc_out sc_logic 1 signal 7 } 
	{ out_real_we1 sc_out sc_logic 1 signal 7 } 
	{ out_real_d1 sc_out sc_lv 32 signal 7 } 
	{ out_imag_address1 sc_out sc_lv 10 signal 8 } 
	{ out_imag_ce1 sc_out sc_logic 1 signal 8 } 
	{ out_imag_we1 sc_out sc_logic 1 signal 8 } 
	{ out_imag_d1 sc_out sc_lv 32 signal 8 } 
	{ grp_fu_534_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_534_p_din1 sc_out sc_lv 16 signal -1 } 
	{ grp_fu_534_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_534_p_ce sc_out sc_logic 1 signal -1 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "zext_ln75", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "zext_ln75", "role": "default" }} , 
 	{ "name": "sub78", "direction": "in", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "sub78", "role": "default" }} , 
 	{ "name": "zext_ln78", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "zext_ln78", "role": "default" }} , 
 	{ "name": "half_stride", "direction": "in", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "half_stride", "role": "default" }} , 
 	{ "name": "sub_ln78_cast", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "sub_ln78_cast", "role": "default" }} , 
 	{ "name": "real_r_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "real_r", "role": "address0" }} , 
 	{ "name": "real_r_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "real_r", "role": "ce0" }} , 
 	{ "name": "real_r_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "real_r", "role": "q0" }} , 
 	{ "name": "imag_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "imag", "role": "address0" }} , 
 	{ "name": "imag_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "imag", "role": "ce0" }} , 
 	{ "name": "imag_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "imag", "role": "q0" }} , 
 	{ "name": "out_real_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "out_real", "role": "address1" }} , 
 	{ "name": "out_real_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "out_real", "role": "ce1" }} , 
 	{ "name": "out_real_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "out_real", "role": "we1" }} , 
 	{ "name": "out_real_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "out_real", "role": "d1" }} , 
 	{ "name": "out_imag_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "out_imag", "role": "address1" }} , 
 	{ "name": "out_imag_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "out_imag", "role": "ce1" }} , 
 	{ "name": "out_imag_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "out_imag", "role": "we1" }} , 
 	{ "name": "out_imag_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "out_imag", "role": "d1" }} , 
 	{ "name": "grp_fu_534_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_534_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_534_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "grp_fu_534_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_534_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_534_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_534_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_534_p_ce", "role": "default" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2", "3", "4"],
		"CDFG" : "fft_kernel_Pipeline_VITIS_LOOP_80_7",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "1034", "EstimateLatencyMax" : "1034",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "zext_ln75", "Type" : "None", "Direction" : "I"},
			{"Name" : "sub78", "Type" : "None", "Direction" : "I"},
			{"Name" : "zext_ln78", "Type" : "None", "Direction" : "I"},
			{"Name" : "half_stride", "Type" : "None", "Direction" : "I"},
			{"Name" : "sub_ln78_cast", "Type" : "None", "Direction" : "I"},
			{"Name" : "real_r", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "imag", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "out_real", "Type" : "Memory", "Direction" : "O"},
			{"Name" : "out_imag", "Type" : "Memory", "Direction" : "O"},
			{"Name" : "twR", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "twI", "Type" : "Memory", "Direction" : "I"}],
		"Loop" : [
			{"Name" : "VITIS_LOOP_80_7", "PipelineType" : "UPC",
				"LoopDec" : {"FSMBitwidth" : "2", "FirstState" : "ap_ST_fsm_pp0_stage0", "FirstStateIter" : "ap_enable_reg_pp0_iter0", "FirstStateBlock" : "ap_block_pp0_stage0_subdone", "LastState" : "ap_ST_fsm_pp0_stage0", "LastStateIter" : "ap_enable_reg_pp0_iter5", "LastStateBlock" : "ap_block_pp0_stage0_subdone", "QuitState" : "ap_ST_fsm_pp0_stage0", "QuitStateIter" : "ap_enable_reg_pp0_iter5", "QuitStateBlock" : "ap_block_pp0_stage0_subdone", "OneDepthLoop" : "0", "has_ap_ctrl" : "1", "has_continue" : "0"}}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.twR_U", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.twI_U", "Parent" : "0"},
	{"ID" : "3", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mul_32s_16s_32_3_1_U22", "Parent" : "0"},
	{"ID" : "4", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.flow_control_loop_pipe_sequential_init_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	fft_kernel_Pipeline_VITIS_LOOP_80_7 {
		zext_ln75 {Type I LastRead 0 FirstWrite -1}
		sub78 {Type I LastRead 0 FirstWrite -1}
		zext_ln78 {Type I LastRead 0 FirstWrite -1}
		half_stride {Type I LastRead 0 FirstWrite -1}
		sub_ln78_cast {Type I LastRead 0 FirstWrite -1}
		real_r {Type I LastRead 5 FirstWrite -1}
		imag {Type I LastRead 7 FirstWrite -1}
		out_real {Type O LastRead -1 FirstWrite 8}
		out_imag {Type O LastRead -1 FirstWrite 9}
		twR {Type I LastRead -1 FirstWrite -1}
		twI {Type I LastRead -1 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "1034", "Max" : "1034"}
	, {"Name" : "Interval", "Min" : "1034", "Max" : "1034"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	zext_ln75 { ap_none {  { zext_ln75 in_data 0 4 } } }
	sub78 { ap_none {  { sub78 in_data 0 9 } } }
	zext_ln78 { ap_none {  { zext_ln78 in_data 0 4 } } }
	half_stride { ap_none {  { half_stride in_data 0 10 } } }
	sub_ln78_cast { ap_none {  { sub_ln78_cast in_data 0 4 } } }
	real_r { ap_memory {  { real_r_address0 mem_address 1 10 }  { real_r_ce0 mem_ce 1 1 }  { real_r_q0 mem_dout 0 32 } } }
	imag { ap_memory {  { imag_address0 mem_address 1 10 }  { imag_ce0 mem_ce 1 1 }  { imag_q0 mem_dout 0 32 } } }
	out_real { ap_memory {  { out_real_address1 MemPortADDR2 1 10 }  { out_real_ce1 MemPortCE2 1 1 }  { out_real_we1 MemPortWE2 1 1 }  { out_real_d1 MemPortDIN2 1 32 } } }
	out_imag { ap_memory {  { out_imag_address1 MemPortADDR2 1 10 }  { out_imag_ce1 MemPortCE2 1 1 }  { out_imag_we1 MemPortWE2 1 1 }  { out_imag_d1 MemPortDIN2 1 32 } } }
}
