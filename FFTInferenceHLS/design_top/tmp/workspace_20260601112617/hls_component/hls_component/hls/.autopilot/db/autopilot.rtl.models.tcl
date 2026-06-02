set SynModuleInfo {
  {SRCNAME fft_kernel MODELNAME fft_kernel RTLNAME fft_kernel IS_TOP 1
    SUBMODULES {
      {MODELNAME fft_kernel_gmem0_m_axi RTLNAME fft_kernel_gmem0_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME fft_kernel_control_s_axi RTLNAME fft_kernel_control_s_axi BINDTYPE interface TYPE interface_s_axilite}
      {MODELNAME fft_kernel_flow_control_loop_pipe RTLNAME fft_kernel_flow_control_loop_pipe BINDTYPE interface TYPE internal_upc_flow_control INSTNAME fft_kernel_flow_control_loop_pipe_U}
    }
  }
}
