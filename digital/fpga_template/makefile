BOARD 		= tangnano9k
FAMILY		= GW1N-9C
DEVICE		= GW1NR-LV9QN88PC6/I5

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
	  $(shell sv2v -v -I$(WS)/digital --siloed $(PKG) $(s) > $(s).conv.v) \
	  $(info Converting systemverilog $(s) : ))

$(OBJ)/$(PROJ).json: conv2v $(SRC) | $(OBJ) 
	echo "#Yosys build script" > $(OBJ)/yosys.cmd
	echo "verilog_defaults -add -I $(SRC_INC)" >> $(OBJ)/yosys.cmd
	echo "read_verilog $(SRC_V) $(SRC_CONV)" >> $(OBJ)/yosys.cmd
	echo "synth_gowin -top $(PROJ)_top -json $(OBJ)/$(PROJ).json" >> $(OBJ)/yosys.cmd
	yosys -s $(OBJ)/yosys.cmd

# Place and Route
$(OBJ)/$(PROJ)_pnr.json: $(OBJ)/$(PROJ).json $(WS)/digital/$(PROJ)/tangnano9k.cst
	nextpnr-himbaechel --json $(OBJ)/$(PROJ).json --write $(OBJ)/$(PROJ)_pnr.json \
	--device ${DEVICE} --vopt family=${FAMILY} --vopt cst=$(WS)/digital/$(PROJ)/tangnano9k.cst


$(OBJ)/$(PROJ).fs: $(OBJ)/$(PROJ)_pnr.json
	gowin_pack -d ${FAMILY} -o $(OBJ)/$(PROJ).fs $(OBJ)/$(PROJ)_pnr.json


build: $(OBJ)/$(PROJ).fs


# Flash to Eprom and reboot
flash: 
	openFPGALoader -d /dev/ttyUSB1 -b ${BOARD} -f $(OBJ)/$(PROJ).fs

# Load bit stream to device no -f
load: 
	openFPGALoader -d /dev/ttyUSB1 -b ${BOARD} $(OBJ)/$(PROJ).fs

clean:
	rm -rf $(OBJ)