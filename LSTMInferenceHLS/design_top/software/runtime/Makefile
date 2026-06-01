SDK_USERSPACE_DIR = $(SDK_DIR)/userspace
SDE_EXAMPLE_DIR   = ../src

INCLUDES  = -I$(SDK_USERSPACE_DIR)/include \
            -I$(SDK_USERSPACE_DIR)/fpga_libs/fpga_mgmt
LDFLAGS   = -L$(SDK_USERSPACE_DIR)/lib/so
LDLIBS    = -lfpga_mgmt
OPT       = -DFPGA_ALLOW_NON_ROOT -DCONFIG_LOGLEVEL=1
CFLAGS    = $(OPT) -g -Wall -Werror -W -Wno-parentheses \
            -Wstrict-prototypes -Wmissing-prototypes $(INCLUDES)

.PHONY: all clean check_env design_top

all: check_env design_top

design_top: $(SDE_EXAMPLE_DIR)/design_top.c check_env
	gcc $< -o $@ $(LDFLAGS) $(LDLIBS) $(CFLAGS) -lm

clean:
	rm -f design_top

check_env:
ifndef SDK_DIR
	$(error SDK_DIR is undefined. Run: source $(HOME)/aws-fpga/sdk_setup.sh)
endif
