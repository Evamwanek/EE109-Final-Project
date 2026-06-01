#!/usr/bin/env python3
import vitis
import os
import shutil
import glob
from datetime import datetime

tmpdir = 'tmp'
date = datetime.now().strftime("%Y%m%d%I%M%S")
workspace_name = 'workspace_' + date
workspace = os.path.join(tmpdir, workspace_name)
comp_name = "hls_component"
cwd = os.getcwd()

if os.path.isdir(tmpdir):
    shutil.rmtree(tmpdir, ignore_errors=True)
    print(f"Deleted workspaces in {tmpdir}")

print(f"CWD is {cwd}")
print(f"Workspace path is {workspace}")
print(f"Creating component {comp_name}")

client = vitis.create_client()
client.set_workspace(workspace)

comp = client.create_hls_component(name=comp_name)

cfg_path = os.path.join(workspace, comp_name, 'hls_config.cfg')
cfg_obj = client.get_config_file(cfg_path)

cfg_obj.set_value('', key='part', value='xcvu47p-fsvh2892-2-e')

# Optional XRT/xcl2 testbench include paths
xcl2_dir = os.path.expanduser("~/aws-fpga/vitis/examples/vitis_examples/common/includes/xcl2")
xcl2_cpp = os.path.join(xcl2_dir, "xcl2.cpp")
xrt_path = "/opt/xilinx/xrt/include"

# FFT source files
cfg_obj.add_lines('hls', ['syn.file=' + cwd + '/../src/fft_kernel.cpp'])

# Testbench / host files, only needed if your host.cpp exists in ../src/
cfg_obj.add_lines('hls', ['tb.file=' + cwd + '/../src/host.cpp'])
cfg_obj.add_lines('hls', ['tb.file=' + xcl2_cpp])
cfg_obj.set_value('hls', key='tb.cflags', value=f'-I{xcl2_dir} -I{xrt_path} -I{cwd}/../src')

# HLS settings
cfg_obj.set_value('hls', key='syn.top', value='fft_kernel')
cfg_obj.set_value('hls', key='clock', value='3ns')
cfg_obj.set_value('hls', key='flow_target', value='vivado')
cfg_obj.set_value('hls', key='package.output.format', value='rtl')
cfg_obj.set_value('hls', key='package.output.syn', value='false')

comp.run('SYNTHESIS')

verilog_dir = os.path.join(workspace, comp_name, comp_name, 'hls', 'syn', 'verilog')
output_file = os.path.join(cwd, 'design', 'concat_top.v')

os.makedirs(os.path.join(cwd, 'design'), exist_ok=True)

print(f"Concatenating Verilog files into {output_file}...")

v_files = glob.glob(os.path.join(verilog_dir, '*.*v'))

top_module = os.path.join(verilog_dir, 'fft_kernel.v')
if top_module in v_files:
    v_files.remove(top_module)
    v_files.append(top_module)

with open(output_file, 'w') as outfile:
    for v_file in v_files:
        with open(v_file, 'r') as infile:
            outfile.write(infile.read())
            outfile.write("\n\n")

print("Concatenation complete!")

vitis.dispose()