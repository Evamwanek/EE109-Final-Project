set SynModuleInfo {
  {SRCNAME fft_kernel_Pipeline_VITIS_LOOP_49_2 MODELNAME fft_kernel_Pipeline_VITIS_LOOP_49_2 RTLNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_49_2
    SUBMODULES {
      {MODELNAME fft_kernel_flow_control_loop_pipe_sequential_init RTLNAME fft_kernel_flow_control_loop_pipe_sequential_init BINDTYPE interface TYPE internal_upc_flow_control INSTNAME fft_kernel_flow_control_loop_pipe_sequential_init_U}
    }
  }
  {SRCNAME fft_kernel_Pipeline_VITIS_LOOP_55_3 MODELNAME fft_kernel_Pipeline_VITIS_LOOP_55_3 RTLNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_55_3
    SUBMODULES {
      {MODELNAME fft_kernel_mul_32s_15ns_32_3_1 RTLNAME fft_kernel_mul_32s_15ns_32_3_1 BINDTYPE op TYPE mul IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_55_3_hamming_ROM_AUTO_1R RTLNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_55_3_hamming_ROM_AUTO_1R BINDTYPE storage TYPE rom IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
    }
  }
  {SRCNAME fft_kernel_Pipeline_VITIS_LOOP_62_4 MODELNAME fft_kernel_Pipeline_VITIS_LOOP_62_4 RTLNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_62_4}
  {SRCNAME fft_kernel_Pipeline_VITIS_LOOP_69_5 MODELNAME fft_kernel_Pipeline_VITIS_LOOP_69_5 RTLNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_69_5}
  {SRCNAME fft_kernel_Pipeline_VITIS_LOOP_80_7 MODELNAME fft_kernel_Pipeline_VITIS_LOOP_80_7 RTLNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_80_7
    SUBMODULES {
      {MODELNAME fft_kernel_mul_32s_16s_32_3_1 RTLNAME fft_kernel_mul_32s_16s_32_3_1 BINDTYPE op TYPE mul IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_80_7_twR_ROM_AUTO_1R RTLNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_80_7_twR_ROM_AUTO_1R BINDTYPE storage TYPE rom IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_80_7_twI_ROM_AUTO_1R RTLNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_80_7_twI_ROM_AUTO_1R BINDTYPE storage TYPE rom IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
    }
  }
  {SRCNAME fft_kernel_Pipeline_VITIS_LOOP_109_8 MODELNAME fft_kernel_Pipeline_VITIS_LOOP_109_8 RTLNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_109_8}
  {SRCNAME fft_kernel_Pipeline_VITIS_LOOP_116_9 MODELNAME fft_kernel_Pipeline_VITIS_LOOP_116_9 RTLNAME fft_kernel_fft_kernel_Pipeline_VITIS_LOOP_116_9}
  {SRCNAME fft_kernel MODELNAME fft_kernel RTLNAME fft_kernel IS_TOP 1
    SUBMODULES {
      {MODELNAME fft_kernel_mul_32s_15s_32_3_1 RTLNAME fft_kernel_mul_32s_15s_32_3_1 BINDTYPE op TYPE mul IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME fft_kernel_real_RAM_2P_BRAM_1R1W RTLNAME fft_kernel_real_RAM_2P_BRAM_1R1W BINDTYPE storage TYPE ram_2p IMPL bram LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME fft_kernel_gmem0_m_axi RTLNAME fft_kernel_gmem0_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME fft_kernel_gmem1_m_axi RTLNAME fft_kernel_gmem1_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME fft_kernel_gmem2_m_axi RTLNAME fft_kernel_gmem2_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME fft_kernel_gmem3_m_axi RTLNAME fft_kernel_gmem3_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME fft_kernel_control_s_axi RTLNAME fft_kernel_control_s_axi BINDTYPE interface TYPE interface_s_axilite}
    }
  }
}
