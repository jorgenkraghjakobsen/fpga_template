BOARD 		= tangnano9k
BOARD_DIR	= fpga_template/tangnano9k
FAMILY		= GW1N-9C
DEVICE		= GW1NR-LV9QN88PC6/I5

PROJ		= fpga_template

WS 			= $(shell cd ../.. ; pwd )
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
	cd ../rb_$(PROJ) ;\
	make 

test:
	@echo $(SRC_CONV)


conv2v: $(SRC_SV)
	$(foreach s,$(SRC_SV),\
	 $(shell sv2v -v -I$(WS)/digital --siloed $(PKG) $(s) > $(s).conv.v ) \
	 $(info Converting systemverilog $(s) : ))

src: 
	@echo $(SRC_SV)

s:
	@echo $(SRC)	

$(OBJ)/$(PROJ).json: conv2v $(SRC) | $(OBJ) 
	cd $(OBJ) ;\
	echo "#Yosys build script" > yosys.cmd ;\
	echo "verilog_defaults -add -I $(SRC_INC)" >> yosys.cmd ;\
	echo "read_verilog $(SRC_V) $(SRC_CONV)" >> yosys.cmd ;\
	echo "synth_gowin -top $(PROJ)_top -json $(PROJ).json" >> yosys.cmd ;\
	yosys -s yosys.cmd

# Place and Route
$(OBJ)/$(PROJ)_pnr.json: $(OBJ)/$(PROJ).json $(WS)/digital/$(BOARD_DIR).cst
	cd $(OBJ) ;\
	nextpnr-himbaechel --json $(PROJ).json --write $(PROJ)_pnr.json \
	--device ${DEVICE} --vopt family=${FAMILY} --vopt cst=$(WS)/digital/$(BOARD_DIR).cst


$(OBJ)/$(PROJ).fs: $(OBJ)/$(PROJ)_pnr.json
	cd $(OBJ) ;\
	gowin_pack -d ${FAMILY} -o $(PROJ).fs $(PROJ)_pnr.json


build: $(WS)/digital/$(BOARD_DIR).cst $(SRC_SV)
	$(MAKE) $(OBJ)/$(PROJ).fs


# Flash to Eprom and reboot
flash: 
	openFPGALoader -d /dev/ttyUSB1 -b ${BOARD} -f $(OBJ)/$(PROJ).fs

# Load bit stream to device no -f
load: 
	openFPGALoader -d /dev/ttyUSB1 -b ${BOARD} $(OBJ)/$(PROJ).fs

clean:
	rm -rf $(OBJ)
