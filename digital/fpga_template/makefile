# Include FPGA device selection if available (sets FPGA_BOARD and FPGA_SERIAL)
-include .fpga_device

# Board selection: tangnano9k or tangnano20k
# Override with: make BOARD=tangnano20k build
# Default: Use FPGA_BOARD from device selection, or tangnano20k if not set
BOARD 		?= $(if $(FPGA_BOARD),$(FPGA_BOARD),tangnano20k)

# Board-specific parameters
ifeq ($(BOARD),tangnano20k)
    FAMILY		= GW2A-18C
    DEVICE		= GW2AR-LV18QN88C8/I7
    CST_FILE	= tangnano20k.cst
    BOARD_DEFINE	= TANGNANO20K
else ifeq ($(BOARD),tangnano9k)
    FAMILY		= GW1N-9C
    DEVICE		= GW1NR-LV9QN88PC6/I5
    CST_FILE	= tangnano9k.cst
    BOARD_DEFINE	= TANGNANO9K
else
    $(error Unknown BOARD: $(BOARD). Valid options: tangnano9k, tangnano20k)
endif

PROJ		= fpga_template

MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
WS		= $(abspath $(MAKEFILE_DIR)/../..)
OBJ 		= $(WS)/obj/$(PROJ)

SRC_INC 	= $(WS)/digital
PKG 		= $(WS)/digital/rb_$(PROJ)/rb_$(PROJ)_struct.svh

.PHONY: $(OBJ)
# Create Object build dir
$(OBJ):
	mkdir -p $@

SRC_I2C = \
	digital/i2c_if/i2c_if.v \
	digital/i2c_if/i2cSlave_define.v \
	digital/i2c_if/serialInterface.v \
	digital/i2c_if/timescale.v

SRC_UART = \
	digital/uart_if/uart_if.v

SRC_RB_IF = $(SRC_I2C) $(SRC_UART) 

SRC_LIST = \
	digital/pwm/pwm.v \
	$(SRC_RB_IF) \
	digital/rb_$(PROJ)/rb_$(PROJ).sv \
	digital/$(PROJ)/$(PROJ).sv


SRC = $(addprefix $(WS)/, $(SRC_LIST) )
SRC_SV = $(filter %.sv ,$(SRC))
SRC_V  = $(filter %.v ,$(SRC))
SRC_CONV = $(addsuffix .conv.v,$(SRC_SV))

$(WS)/digital/rb_$(PROJ)/rb_$(PROJ).sv: $(WS)/digital/rb_$(PROJ)/register_bank.go 
	cd $(WS)/digital/rb_$(PROJ) && go run register_bank.go > rb_$(PROJ).sv
	cp $(WS)/digital/rb_$(PROJ)/reg_file_fpga_template $(WS)/digital/fpga_template/test/.reg_file_fpga_template

test:
	@echo $(SRC_CONV)


conv2v: $(SRC_SV)
	$(foreach s,$(SRC_SV), \
	  $(shell sv2v -v -I$(WS)/digital --siloed -D$(BOARD_DEFINE) $(PKG) $(s) > $(s).conv.v) \
	  $(info Converting systemverilog $(s) : ))

$(OBJ)/$(PROJ).json: conv2v $(SRC) | $(OBJ) 
	echo "#Yosys build script" > $(OBJ)/yosys.cmd
	echo "verilog_defaults -add -I $(SRC_INC)" >> $(OBJ)/yosys.cmd
	echo "read_verilog $(SRC_V) $(SRC_CONV)" >> $(OBJ)/yosys.cmd
	echo "synth_gowin -top $(PROJ)_top -json $(OBJ)/$(PROJ).json" >> $(OBJ)/yosys.cmd
	yosys -s $(OBJ)/yosys.cmd

# Place and Route
$(OBJ)/$(PROJ)_pnr.json: $(OBJ)/$(PROJ).json $(WS)/digital/$(PROJ)/$(CST_FILE)
	nextpnr-himbaechel --freq 27 --json $(OBJ)/$(PROJ).json --write $(OBJ)/$(PROJ)_pnr.json \
	--device ${DEVICE} --vopt family=${FAMILY} --vopt cst=$(WS)/digital/$(PROJ)/$(CST_FILE)


$(OBJ)/$(PROJ).fs: $(OBJ)/$(PROJ)_pnr.json
	gowin_pack -d ${FAMILY} -o $(OBJ)/$(PROJ).fs $(OBJ)/$(PROJ)_pnr.json


build: $(OBJ)/$(PROJ).fs


# Flash to Eprom and reboot
flash:
	@if [ -z "$(FPGA_SERIAL)" ]; then \
		echo "Error: No FPGA device selected. Run 'make find-device' first."; \
		exit 1; \
	fi
	openFPGALoader --ftdi-serial "$(FPGA_SERIAL)" --ftdi-channel 0 -b ${BOARD} -f $(OBJ)/$(PROJ).fs

# Load bit stream to device no -f
load:
	@if [ -z "$(FPGA_SERIAL)" ]; then \
		echo "Error: No FPGA device selected. Run 'make find-device' first."; \
		exit 1; \
	fi
	openFPGALoader --ftdi-serial "$(FPGA_SERIAL)" --ftdi-channel 0 -b ${BOARD} $(OBJ)/$(PROJ).fs

clean:
	rm -rf $(OBJ)

# FPGA Device Selection Targets
find-device:
	@./scripts/select_fpga_device.sh

show-device:
	@if [ -f .fpga_device ]; then \
		echo "Currently selected FPGA device:"; \
		grep -v '^#' .fpga_device | grep 'FPGA_SERIAL' | sed 's/FPGA_SERIAL=/  Serial: /'; \
		grep -v '^#' .fpga_device | grep 'FPGA_BOARD' | sed 's/FPGA_BOARD=/  Board: /'; \
		echo ""; \
		grep '^# Device:' .fpga_device | sed 's/^# /  /'; \
		echo ""; \
		echo "Use 'make find-device' to change selection"; \
	else \
		echo "No FPGA device selected."; \
		echo "Run 'make find-device' to select a device."; \
	fi

clear-device:
	@if [ -f .fpga_device ]; then \
		rm -f .fpga_device; \
		echo "Device selection cleared."; \
		echo "Run 'make find-device' to select a new device."; \
	else \
		echo "No device selection to clear."; \
	fi

# Show build information and help
info:
	@echo "===== Build Configuration ====="
	@echo "BOARD:   $(BOARD)"
	@echo "FAMILY:  $(FAMILY)"
	@echo "DEVICE:  $(DEVICE)"
	@echo "CST:     $(CST_FILE)"
	@echo "PROJECT: $(PROJ)"
	@if [ -n "$(FPGA_SERIAL)" ]; then \
		echo "FPGA:    Selected (Serial: $(FPGA_SERIAL))"; \
	else \
		echo "FPGA:    No device selected - run 'make find-device'"; \
	fi
	@echo ""
	@echo "===== Usage ====="
	@echo "Build for Tang Nano 9K (default):"
	@echo "  make build"
	@echo "  make BOARD=tangnano9k build"
	@echo ""
	@echo "Build for Tang Nano 20K:"
	@echo "  make BOARD=tangnano20k build"
	@echo ""
	@echo "Device Selection (required before flash/load):"
	@echo "  make find-device       - Scan and select FPGA device"
	@echo "  make show-device       - Show currently selected device"
	@echo "  make clear-device      - Clear device selection"
	@echo ""
	@echo "Programming commands:"
	@echo "  make load              - Load bitstream to FPGA (temporary)"
	@echo "  make flash             - Flash bitstream to EPROM (persistent)"
	@echo ""
	@echo "Other commands:"
	@echo "  make clean             - Remove all build artifacts"
	@echo "  make info              - Show this information"

help: info