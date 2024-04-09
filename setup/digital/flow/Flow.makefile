TECH      ?= ".. TECH not set .."
ANTENNA   ?= 0
FLAT      ?= 0
HDL_TOP   ?= $(COMP)
TB_TOP    ?= $(HDL_TOP)
OBJ       = obj
OBJDIR    = $(WORKSPACE)/$(OBJ)/$(COMP)

#ifeq ($(VDD),"")
#	OBJDIR    = $(WORKSPACE)/$(OBJ)/$(COMP)
#else
#	OBJDIR    = $(WORKSPACE)/$(OBJ)/$(COMP)/$(VDD)
#endif 

GATE      ?= 0
FLATTEN   ?= 0

USE_POWER_PINS = 0

SIMULATOR ?= modelsim
GUI       = 1

OPENTOOLS ?= $(HOME)/work/opentools
OPEN_PDK  ?= $(OPENTOOLS)/open_pdks
STDCELLS  ?= hd


#debug: 
#	@echo "Simulator 	$(SIMULATOR)" \
#	@echo "Device 		$(DEVICE)" \
#	@echo "VDD			$(VDD)" \
#	@echo "OBJDIR		$(OBJDIR)"
	

DONT_EXIT = 0

reverse = $(if $(1),$(call reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))

DATETIME := $(shell date +%Y%m%d_%H%M%S)

help: 
	@echo ""
	@echo "ICW - Digital Development and Build System"
	@echo ""
	@echo "Workspace: $(WORKSPACE)"
	@echo ""
	@echo "Available targets include: "
	@echo "  synth    - synthesize the design to the tech defined by TECH=$(TECH)" 
	@echo "  simulate - simulate design using testbench in $(HDL_TOP)_tb.vhd"
	@echo ""
	@echo "Outputs go to object directory: $(OBJDIR)"
	@echo ""
	@echo "RTL:"
	@echo "$(SOURCES_RTL)"
	@echo ""
	@echo "BEHAVIOUR:"
	@echo "$(SOURCES_BEHAV)" 
	
src:
	@echo "RTL:"
	@echo "$(SOURCES_RTL)"
	@echo ""
	@echo "BEHAVIOUR:"
	@echo "$(SOURCES_BEHAV)" 

$(OBJDIR):
	mkdir -p $@

#---------------------------------------------------------------------
# Source file dependency resolution
#---------------------------------------------------------------------

$(OBJDIR)/depend.makefile:
	mkdir -p $(OBJDIR)
	$(HOME)/bin/icw depend-ng > $@

include $(OBJDIR)/depend.makefile

.PHONY: depend
depend: $(OBJDIR)/depend.makefile

#---------------------------------------------------------------------
# Debug targets 
#---------------------------------------------------------------------
show_obj:
	xdg-open $(OBJDIR)  

#---------------------------------------------------------------------
# Simulation targets
#---------------------------------------------------------------------
ifeq ($(SIMULATOR),iverilog)

	@echo "Setup for iverilog simulation" 

IVERILOG 		= /usr/bin/iverilog
IVERILOG_FLAGS 	= -g2012

# Copy custom testbench tcl script 
$(OBJDIR)/%_tb.tcl_: $(CURDIR)/%_tb.tcl
	cp -p $< $@

# or copy generic testbench tcl script 
$(OBJDIR)/%_tb.tcl: $(WORKSPACE)/setup/flow/hdl/simulation/generic_tb.tcl
	cp -p $< $@

# Call only if simfile set 
$(OBJDIR)/$(TB_TOP).rtl.simfile:  
	echo "Copy simfiles" $(SIMFILES) \
	cp -p $(CURDIR)/$(SIMFILES) $(OBJDIR)/rtl/$^ 


$(OBJDIR)/$(TB_TOP).rtl.verilog: \
  $(filter %.vs, $(SOURCES_RTL) $(SOURCES_BEHAV)) 
	mkdir -p $(OBJDIR)/rtl; \
	cd $(OBJDIR)/rtl; \
	$(IVERILOG) \
	  $(IVERILOG_FLAGS) \
	  -o $(TB_TOP) \
	  -s $(TB_TOP)_tb \
	  $(SOURCES_RTL) $(SOURCES_BEHAV); 


$(OBJDIR)/$(TB_TOP).rtl.iverilog: \
  $(OBJDIR)/$(TB_TOP).rtl.simfile \
  $(OBJDIR)/$(TB_TOP).rtl.verilog \
  $(OBJDIR)/$(TB_TOP)_tb.tcl
	cd $(OBJDIR)/rtl; \
	SRC_DIR=$(CURDIR) VIEW=$(VIEW) \
	./$(TB_TOP) 
	
simulate: $(OBJDIR)/$(TB_TOP).rtl.iverilog


$(OBJDIR)/rtl/$(TB_TOP).gtkw:
ifneq (,$(wildcard $(CURDIR)/$(TB_TOP).gtkw))	
	cp -p $(CURDIR)/$(TB_TOP).gtkw $(OBJDIR)/rtl/$^
endif 

sim-view: $(OBJDIR)/rtl/$(TB_TOP).gtkw  
	cd $(OBJDIR); \
	gtkwave -A -f rtl/$(TB_TOP).vcd 

endif


#---------------------------------------------------------------------
# Simulator modelsim 
#---------------------------------------------------------------------
ifeq ($(SIMULATOR),modelsim)

MODELSIM = /opt/intelFPGA_lite/21.1/questa_fse

#GATE = 1 
VIEW = rtl

SDF_CORNER = wc


$(OBJDIR)/%_simfile.dat: $(CURDIR)/%_simfile.dat
	cp -p $< $<

$(OBJDIR)/%_tb.tcl: $(CURDIR)/%_tb.tcl
	cp -p $< $@

#$(OBJDIR)/%_tb.tcl: $(WORKSPACE)/hdl/flow/simulation/generic_tb.tcl
#	cp -p $< $@

HAL_FLAGS = -nowarn MAXLEN -nowarn IDLENG -nowarn DECLIN -nowarn BEHINI -nowarn LCVARN -nowarn ALOWID -nowarn UPCLBL -nowarn FFASRT -lexpragma

# -voptargs=+acc
VSIM_FLAGS = +define+USE_POWER_PINS

ifeq ($(GUI),1)
  VSIM_ALLFLAGS = $(VSIM_FLAGS) -debugDB -t ps -voptargs=+acc \
  +int_delays +unit_delay=20 +alt_path_delays +delay_mode_path +tranport_int_delay \
  -suppress 2732 +nospecify
 else
  VSIM_ALLFLAGS = $(VSIM_FLAGS) -t ps -c
endif

VCOM_FLAGS =
VCOM_ALLFLAGS = $(VCOM_FLAGS) +define+USE_POWER_PINS

#---Verilog compile flags------------------------------------------------
VLOG_FLAGS := -suppress 2892 -suppress 2388 +define+USE_POWER_PINS

ifeq ($(GATE),1) 
  VLOG_FLAGS := $(VLOG_FLAGS) +initreg+0 \
  				+define+FUNCTIONAL +define+UNIT_DELAY=\#0.3 
  ifeq ($(USE_POWER_PINS),1) 
     VLOG_FLAGS := $(VLOG_FLAGS) +define+USE_POWER_PINS
  endif
endif 


$(OBJDIR)/$(TB_TOP).rtl.simfile:  
	echo "Copy simfiles" 
	cp -p $(CURDIR)/$(SIMFILES) $(OBJDIR)/rtl/$^ 


$(OBJDIR)/$(TB_TOP).rtl.vcom: \
  $(filter %.vhd, $(SOURCES_RTL) $(SOURCES_BEHAV))
	echo "--Compiling vhdl codebase --------------------------------------------------------"; \
	mkdir -p $(OBJDIR)/rtl; \
	cd $(OBJDIR)/rtl; \
	$(MODELSIM)/bin/vcom \
	  -l $@ $(VCOM_ALLFLAGS) \
	  -2008 \
	  $(filter %.vhd, $^)

$(OBJDIR)/$(VIEW)/$(COMP).vlog_opts: \
  $(WORKSPACE)/setup/hdl/flow/simulation/vlog_opts.tcl
	mkdir -p $(OBJDIR)/$(VIEW)
	TECH=$(TECH) \
	WORKSPACE=$(WORKSPACE) \
	tclsh $(WORKSPACE)/setup/hdl/flow/simulation/vlog_opts.tcl > $@


# $(OBJDIR)/rtl/$(COMP).vlog_opts
#	  -f $(OBJDIR)/rtl/$(COMP).vlog_opts \

GATE_LIBS :=
GATE_PRIM := 
ifeq ($(GATE),1) 
  GATE_LIBS  = $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_$(STD_KIT)/verilog/sky130_fd_sc_$(STD_KIT).v
  GATE_PRIM  = $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_$(STD_KIT)/verilog/primitives.v
  SYNTH_GATE = $(WORKSPACE)/digital/$(COMP)/gate/$(COMP)_$(VDD)_gate.v
#  SYNTH_GATE = $(OBJDIR)/$(COMP)_synth_gate.v

endif 

ifeq ($(USE_POWER_PINS),1) 
  SYNTH_GATE=$(COMP)_$(VDD)_gate.v

#  SYNTH_GATE=$(OBJDIR)/$(COMP)_synth_w_power.v
endif 

$(OBJDIR)/$(TB_TOP).rtl.vlog: \
  $(filter %.v %.sv , $(SOURCES_RTL) $(SOURCES_BEHAV) \
  				      $(GATE_PRIM) $(GATE_LIBS) $(SYNTH_GATE)) 
	mkdir -p $(OBJDIR)/rtl; \
	cd $(OBJDIR)/rtl; \
	$(MODELSIM)/bin/vlog \
	  -l $@ $(VLOG_FLAGS) \
	  $(filter %.v %.sv, $^); 
	
#  $(OBJDIR)/$(TB_TOP).rtl.vlog 
#   $(OBJDIR)/rtl/$(COMP).irun_opts
#   $(OBJDIR)/$(TB_TOP).rtl.vcom \
#   $(OBJDIR)/$(TB_TOP).rtl.vlog \
#$(OBJDIR)/$(TB_TOP).rtl.simfile \
    
$(OBJDIR)/$(TB_TOP).rtl.vsim: \
  $(OBJDIR)/$(TB_TOP).rtl.vlog \
  $(OBJDIR)/$(TB_TOP)_tb.tcl 
	cd $(OBJDIR)/rtl; \
	SRC_DIR=$(CURDIR) VIEW=$(VIEW) \
	$(MODELSIM)/bin/vsim \
	  -l $@.$(DATETIME) $(VSIM_ALLFLAGS) \
	  -do $(OBJDIR)/$(TB_TOP)_tb.tcl \
	  $(TB_TOP)_tb
	cp -p $@.$(DATETIME) $@

sim_comp_gate: \
  $(filter %.v %.sv , $(SOURCES_BEHAV) \
  				      $(GATE_PRIM) $(GATE_LIBS) $(SYNTH_GATE)) 
	mkdir -p $(OBJDIR)/rtl; \
	cd $(OBJDIR)/rtl; \
	$(MODELSIM)/bin/vlog \
	  -l $@ $(VLOG_FLAGS) \
	  $(filter %.v %.sv, $^); 

sim_gate: sim_comp_gate
	cd $(OBJDIR)/rtl; \
	SRC_DIR=$(CURDIR) VIEW=$(VIEW) \
	$(MODELSIM)/bin/vsim \
	  -l $@.$(DATETIME) $(VSIM_ALLFLAGS) \
	  -do $(OBJDIR)/$(TB_TOP)_tb.tcl \
	  $(TB_TOP)_tb
	cp -p $@.$(DATETIME) $@

#$(OBJDIR)/$(VIEW)/$(COMP).irun_opts: \
#  $(WORKSPACE)/setup/hdl/flow/simulation/irun_opts.tcl \
#  $(WORKSPACE)/setup/$(TECH)/tech.tcl
#	mkdir -p $(OBJDIR)/$(VIEW)
#	TECH=$(TECH) \
#	WORKSPACE=$(WORKSPACE) \
#	tclsh $(WORKSPACE)/setup/hdl/flow/simulation/irun_opts.tcl $(WORKSPACE)/setup/$(TECH)/tech.tcl > $@

$(OBJDIR)/%.sdfc: $(OBJDIR)/%.sdf
	cd $(dir $@); \
	$(INCISIVE)/bin/ncsdfc $< -output $@

$(OBJDIR)/$(HDL_TOP).$(GATE).$(SDF_CORNER).sdf_cmd: \
  $(OBJDIR)/$(HDL_TOP)_$(GATE).$(SDF_CORNER).sdfc
	mkdir -p $(OBJDIR)/$(GATE); \
	cd $(OBJDIR)/$(GATE); \
	echo "COMPILED_SDF_FILE = \"$<\"," > $@
	echo "MTM_CONTROL = \"MAXIMUM\"," >> $@
	echo "SCOPE = :dut;" >> $@


#  $(OBJDIR)/$(HDL_TOP)_$(GATE).v \

sim-elaborate: $(OBJDIR)/$(TB_TOP).$(VIEW).ncelab


simulate: $(OBJDIR)/$(TB_TOP).rtl.vsim



sim-view:
	cd $(OBJDIR)/$(VIEW); \
	$(MODELSIM)/bin/vsim \
	  -do "dataset open vsim.wlf; do $(CURDIR)/$(TB_TOP)_wave.do"

endif 

sim-ms:

sim-clean:
	rm -rf $(OBJDIR)/*.nc*
	rm -rf $(OBJDIR)/*/*.irun_opts
	rm -rf $(OBJDIR)/*/*.vlog_opts
	rm -rf $(OBJDIR)/*.irun
	rm -rf $(OBJDIR)/*.vcom
	rm -rf $(OBJDIR)/*.vlog
	rm -rf $(OBJDIR)/*.vsim


#---------------------------------------------------------------------
# Synthesis targets
#---------------------------------------------------------------------



#ICW 
# Synth Xilinx spartan7 



#---------------------------------------------------------------------
# Synthesis target VIVADO
#---------------------------------------------------------------------
ifeq ($(TECH),FPGA) 

ifeq ($(SYNTHTOOL),VIVADO)

VIVADO = /opt/Xilinx/Vivado/2022.2/bin/vivado

$(OBJDIR)/%_pins.xdc: $(CURDIR)/%_pins.xdc
	cp -p $< $@

#echo "set_property IS_GLOBAL_INCLUDE 1 [get_files $(filter %.svh,  $(SOURCES_RTL) )]" >> $@ 
	

$(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).tcl: \
  $(SOURCES_RTL) \
  $(OBJDIR)/$(HDL_TOP)_$(BOARD)_pins.xdc 
	echo "set workspace $(WORKSPACE)" > $@
	echo "set objdir $(OBJDIR)" >> $@
	echo "set srcdir $(CURDIR)" >> $@
	echo "set design_name $(HDL_TOP)" >> $@
	echo "set device $(DEVICE)" >> $@
	echo "set_part $(DEVICE)" >> $@
	echo "set pin_map $(PIN_MAP)" >> $@  
	echo "set rep_dir ./report" >> $@
	echo "file mkdir ./report" >> $@
	echo "set tmp_dir ./temp" >> $@
	echo "file mkdir ./temp" >> $@
	echo "read_vhdl  -vhdl2008 { $(filter %.vhd , $(SOURCES_RTL)) }" >> $@
	echo "read_verilog -sv { $(filter %.svh %.sv , $(SOURCES_RTL)) }" >> $@
	$(foreach s, $(filter %.v, $(SOURCES_RTL)), echo "read_verilog $(s)" >> $@; )
	echo "read_xdc $(HDL_TOP)_$(BOARD)_pins.xdc" >> $@
	echo "synth_design -top $(HDL_TOP) -part $(DEVICE) -fsm_extraction off" >> $@
	echo "opt_design" >> $@ 
	echo "power_opt_design -verbose" >> $@   
	echo "write_edif -force $(HDL_TOP).edif" >> $@
	echo "place_design -directive Explore" >> $@
	echo "phys_opt_design" >> $@
	echo "report_clock_networks" >> $@
	echo "report_timing_summary" >> $@
	echo "route_design -directive Explore" >> $@
	echo "set_property BITSTREAM.CONFIG.USR_ACCESS        0x12345678     [current_design]" >> $@
	echo "set_property CONFIG_VOLTAGE                     3.3            [current_design]" >> $@
	echo "set_property CFGBVS                             VCCO           [current_design]" >> $@
	echo "set_property BITSTREAM.CONFIG.CONFIGRATE        16             [current_design]" >> $@
	echo "set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR    No             [current_design]" >> $@
	echo "set_property SEVERITY {Warning} [get_drc_checks NSTD-1]" >> $@
	echo "write_bitstream -force $(HDL_TOP).bit" >> $@
	echo "write_bitstream -force -bin_file $(HDL_TOP)" >> $@
	echo "write_cfgmem    -force -format MCS -size 8 -loadbit \"up 0x0 $(HDL_TOP).bit\" -interface SPIx1 $(HDL_TOP)" >> $@
	echo "report_timing -nworst 40 -path_type summary" >> $@
	echo "exit" >> $@


$(OBJDIR)/$(HDL_TOP).bit: $(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).tcl
	cd $(OBJDIR); \
	$(VIVADO) -mode tcl -source $(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).tcl
	
synth: $(OBJDIR)/$(HDL_TOP).bit 

#$(OBJDIR)/$(HDL_TOP).xilinx
#echo "current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210376B48D09A]" >> $@
	
$(OBJDIR)/$(HDL_TOP)_prog.$(SYNTHTOOL).tcl: $(OBJDIR)/$(HDL_TOP).bit
	echo "open_hw_manager" > $@
	echo "connect_hw_server -url localhost:3121 -allow_non_jtag" >> $@
	echo "current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210376B48BFBA]" >> $@
	echo "set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210376B48BFBA]" >> $@
	echo "open_hw_target" >> $@
	echo "current_hw_device [get_hw_devices xc7s25_0]" >> $@
	echo "refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7s25_0] 0]" >> $@
	echo "set_property PROGRAM.FILE {./$(HDL_TOP).bin} [get_hw_devices xc7s25_0]" >> $@
	echo "program_hw_devices [get_hw_devices xc7s25_0]" >> $@ 
	echo "exit" >> $@
	
prog_xli: $(OBJDIR)/$(HDL_TOP)_prog.$(SYNTHTOOL).tcl
	cd $(OBJDIR); \
	$(VIVADO) -mode tcl -source $(OBJDIR)/$(HDL_TOP)_prog.$(SYNTHTOOL).tcl

prog: 
	openocd -f /usr/local/share/openocd/scripts/interface/ftdi/digilent-hs1.cfg \
	-f /usr/local/share/openocd/scripts/cpld/xilinx-xc7.cfg \
	-c "adapter speed 4000; init; xc7_program xc7.tap; pld load 0 $(OBJDIR)/$(HDL_TOP).bit ; exit"  
  
xc7_list:    
	openocd -f $(WORKSPACE)/flow/cmod_s7.cfg \
	-f /usr/local/share/openocd/scripts/cpld/xilinx-xc7.cfg \
	-c "adapter speed 4000; init; xc7_program xc7.tap; pld devices ; exit"

xc7_cfg:
	openocd -f $(WORKSPACE)/flow/cmod_s7.cfg \
	-c "init; pld load 0 $(OBJDIR)/$(HDL_TOP).bit; \
	shutdown" 

xc7_flash:
	openocd -f $(WORKSPACE)/flow/cmod_s7.cfg \
	-c "init; \
	jtagspi_init 0 $(WORKSPACE)/flow/fpga/bscan_spi_xc7s25.bit; \
	jtagspi_program  $(OBJDIR)/$(HDL_TOP).bin 0; \
	xc7_program xc7.tap; \
	shutdown"

# Add openFPGAloader targets 



endif 

#---------------------------------------------------------------------
# Synthesis targets : YOSYS + ABC + NextPNR (FPGA)
 #---------------------------------------------------------------------
ifeq ($(SYNTHTOOL),yosys) 

YOSYS_BIN = /usr/local/bin/yosys

#GOWIN pin_map
$(OBJDIR)/%_pins.cst: $(CURDIR)/%_pins.cst 
	cp -p $< $@

#echo "read_verilog -sv { $(filter %.svh %.sv , $(SOURCES_RTL)) }" >> $@
#echo "yosys -import" > $@; 

ifeq ($(FLATTEN),1) 
  YOSYS_FLATTEN := flatten 
endif   

$(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).cmd: \
  $(SOURCES_RTL) \
  $(OBJDIR)/$(HDL_TOP)_$(BOARD)_pins.cst 
	$(foreach s, $(filter %.svh %.sv , $(SOURCES_RTL)), echo "read_verilog -sv $(s)" >> $@; )    
	$(foreach s, $(filter %.v, $(SOURCES_RTL)), echo "read_verilog $(s)" >> $@; )
	echo "read_verilog -lib $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v" >> $@;
	echo "synth -top $(HDL_TOP)" >> $@
	echo "$(YOSYS_FLATTEN)" >> $@
	#echo "shell " >> $@ 
	echo "dfflibmap -liberty $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib" >> $@ 
	echo "abc -liberty $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib" >> $@ 
	echo "clean " >> $@  
	echo "write_verilog -noattr $(HDL_TOP)_synth_gate.v" >> $@ 
	echo "shell " >> $@  
	
$(OBJDIR)/$(HDL_TOP)_synth_gate.v: $(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).cmd
	cd $(OBJDIR); \
	$(YOSYS_BIN) -s $(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).cmd
	
synth: $(OBJDIR)/$(HDL_TOP)_synth_gate.v 

VLOG2VERILOG_BIN=/home/jakobsen/work/opentools/qflow/src/vlog2Verilog 

$(OBJDIR)/$(HDL_TOP)_synth_w_power.v: \
  $(OBJDIR)/$(HDL_TOP)_synth_gate.v  
	$(VLOG2VERILOG_BIN) -o $@ \
	-l $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef \
	-v "VDD," -g "VSS," $< 

pg: $(OBJDIR)/$(HDL_TOP)_synth_w_power.v 

endif

endif  #FPGA

#---------------------------------------------------------------------
# Synthesis targets : SKY130  
#---------------------------------------------------------------------
ifeq ($(TECH),sky130) 
ifeq ($(SYNTHTOOL),yosys) 

#--------------------------------------------------------------------------------------Synth hdl -> verilog gate netlist  

YOSYS_BIN = /usr/local/bin/yosys

#echo "read_verilog -sv { $(filter %.svh %.sv , $(SOURCES_RTL)) }" >> $@
#echo "yosys -import" > $@; 

ifeq ($(FLATTEN),1) 
  YOSYS_FLATTEN := flatten 
endif   

$(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).cmd: \
  $(SOURCES_RTL)
	$(foreach s, $(filter %.svh %.sv , $(SOURCES_RTL)), echo "read_verilog -sv $(s)" >> $@; )    
	$(foreach s, $(filter %.v, $(SOURCES_RTL)), echo "read_verilog $(s)" >> $@; )
	echo "read_verilog -lib $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_$(STDCELLS)/verilog/sky130_fd_sc_$(STDCELLS).v" >> $@;
	echo "synth -top $(HDL_TOP)" >> $@
	echo "$(YOSYS_FLATTEN)" >> $@
	#echo "shell " >> $@ 
	echo "dfflibmap -liberty $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_$(STDCELLS)/lib/sky130_fd_sc_$(STDCELLS)__$(CORNER).lib" >> $@ 
	echo "abc -liberty $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_$(STDCELLS)/lib/sky130_fd_sc_$(STDCELLS)__$(CORNER).lib" >> $@ 
	echo "clean " >> $@  
	echo "write_verilog -noattr $(HDL_TOP)_synth_gate.v" >> $@ 
	echo "shell " >> $@  
	
$(OBJDIR)/$(HDL_TOP)_synth_gate.v: $(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).cmd
	cd $(OBJDIR); \
	$(YOSYS_BIN) -s $(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).cmd
	
synth: $(OBJDIR)/$(HDL_TOP)_synth_gate.v 

VLOG2VERILOG_BIN=/home/jakobsen/work/opentools/qflow/src/vlog2Verilog 

$(OBJDIR)/$(HDL_TOP)_synth_w_power.v: \
  $(OBJDIR)/$(HDL_TOP)_synth_gate.v  
	$(VLOG2VERILOG_BIN) -o $@ \
	-l $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_$(STDCELLS).lef \
	-v "VDD," -g "VSS," $< 

pg: $(OBJDIR)/$(HDL_TOP)_synth_w_power.v 

# ---------------------------------------------------------------------------------------------Run verilog through openlane 

openlane:





endif

endif







#---------------------------------------------------------------------
# Synthesis targets : GENUS
#---------------------------------------------------------------------
ifeq ($(SYNTHTOOL),genus)

#SYNTHTOOL ?= rtlc
SYNTHTOOL ?= genus
GENUS = /opt/cad/cds/GENUS161/_hotfix/16.12
GENUS = /opt/cad/cds/GENUS162/_base

SYNTH_VIEW ?= gate

$(OBJDIR)/%_constraints.tcl: $(CURDIR)/%_constraints.tcl
	cp -p $< $@

$(OBJDIR)/%_constraints.tcl: $(WORKSPACE)/setup/hdl/flow/synthesis/constraints.tcl
	cp -p $< $@

$(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).tcl: \
  $(SOURCES_RTL) \
  $(WORKSPACE)/setup/hdl/flow/synthesis/$(SYNTHTOOL)_synth.tcl \
  $(WORKSPACE)/setup/$(TECH)/tech.tcl \
  $(OBJDIR)/$(HDL_TOP)_constraints.tcl
	echo "set workspace $(WORKSPACE)" > $@
	echo "set objdir $(OBJDIR)" >> $@
	echo "set srcdir $(CURDIR)" >> $@
	echo "set HDL_TOP $(HDL_TOP)" >> $@
	echo "set FLAT $(FLAT)" >> $@
	echo "set tech $(TECH)" >> $@
	echo "set CG 1" >> $@
	echo "set SCAN 0" >> $@
	echo "set sources {" >> $@
	$(foreach s, $^, echo "  $(s)" >> $@;)
	echo "}" >> $@
	echo 'foreach s $$  { if [string match *.tcl $$s] { source $$s } }' >> $@
	echo "ma_synth" >> $@
	echo 'if { $$env(DONT_EXIT) == 0 } { exit }' >> $@


$(OBJDIR)/$(HDL_TOP)_$(SYNTH_VIEW).v \
$(OBJDIR)/$(HDL_TOP)_$(SYNTH_VIEW).sdc \
$(OBJDIR)/$(HDL_TOP).genus: $(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).tcl
	cd $(OBJDIR); \
	DONT_EXIT=$(DONT_EXIT) $(GENUS)/bin/genus -lic_startup Virtuoso_Digital_Implem -wait 10 -file $< -overwrite -log $(OBJDIR)/$(HDL_TOP).genus.$(DATETIME).log
	cp -p $(OBJDIR)/$(HDL_TOP).genus.$(DATETIME).log $(OBJDIR)/$(HDL_TOP).genus

synth: $(OBJDIR)/$(HDL_TOP).genus

endif
ifeq ($(SYNTHTOOL),rc)

$(OBJDIR)/$(HDL_TOP)_$(SYNTH_VIEW).v \
$(OBJDIR)/$(HDL_TOP)_$(SYNTH_VIEW).sdc \
$(OBJDIR)/$(HDL_TOP).rtlc: $(OBJDIR)/$(HDL_TOP)_synth.$(SYNTHTOOL).tcl
	cd $(OBJDIR); \
	DONT_EXIT=$(DONT_EXIT) rc -file $< -overwrite -logfile $(OBJDIR)/$(HDL_TOP).rtlc.$(DATETIME)
	cp -p $(OBJDIR)/$(HDL_TOP).rtlc.$(DATETIME) $(OBJDIR)/$(HDL_TOP).rtlc

synth: $(OBJDIR)/$(HDL_TOP).rtlc

endif

synth-clean:
	rm -f $(OBJDIR)/*synth*.tcl
	rm -f $(OBJDIR)/$(HDL_TOP)_constraints.tcl


#---------------------------------------------------------------------
# PnR targets
#---------------------------------------------------------------------

PNR_VIEW = pnr

CDS_EDI := /opt/cad/cds/EDI142/_hotfix
CDS_OA_VERSION := $(notdir $(wildcard $(CDS_EDI)/oa_*))

$(OBJDIR)/%_floorplan.tcl: $(CURDIR)/%_floorplan.tcl
	cp -p $< $@

$(OBJDIR)/%_floorplan.tcl: $(WORKSPACE)/setup/hdl/flow/pnr/floorplan.tcl
	cp -p $< $@

$(OBJDIR)/$(HDL_TOP)_pnr.tcl: \
  $(WORKSPACE)/setup/hdl/flow/pnr/enc_pnr.tcl \
  $(WORKSPACE)/setup/$(TECH)/tech.tcl \
  $(OBJDIR)/$(HDL_TOP)_floorplan.tcl \
  $(OBJDIR)/$(HDL_TOP)_$(SYNTH_VIEW).v \
  $(OBJDIR)/$(HDL_TOP)_$(SYNTH_VIEW).sdc
	echo "set workspace $(WORKSPACE)" > $@
	echo "set objdir $(OBJDIR)" >> $@
	echo "set srcdir $(CURDIR)" >> $@
	echo "set HDL_TOP $(HDL_TOP)" >> $@
	echo "set ANTENNA $(ANTENNA)" >> $@
	echo "set tech $(TECH)" >> $@
	echo "set sources {" >> $@
	$(foreach s, $^, echo "  $(s)" >> $@;)
	echo "}" >> $@
	echo 'foreach s $$sources { if [string match *.tcl $$s] { source $$s } }' >> $@
	echo "ma_pnr" >> $@
	echo 'if { $$env(DONT_EXIT) == 0 } { exit }' >> $@

$(OBJDIR)/$(HDL_TOP)_pnr_view.tcl: \
  $(WORKSPACE)/setup/hdl/flow/pnr/enc_pnr.tcl \
  $(WORKSPACE)/setup/$(TECH)/tech.tcl
	echo "set workspace $(WORKSPACE)" > $@
	echo "set objdir $(OBJDIR)" >> $@
	echo "set srcdir $(CURDIR)" >> $@
	echo "set HDL_TOP $(HDL_TOP)" >> $@
	echo "set tech $(TECH)" >> $@
	echo "set sources {" >> $@
	$(foreach s, $^, echo "  $(s)" >> $@;)
	echo "}" >> $@
	echo 'foreach s $$sources { if [string match *.tcl $$s] { source $$s } }' >> $@
	echo 'restoreDesign $(OBJDIR)/$(HDL_TOP)_$(PNR_VIEW).enc.dat $(HDL_TOP)' >> $@
	echo 'win' >> $@

$(OBJDIR)/$(HDL_TOP)_$(PNR_VIEW).def \
$(OBJDIR)/$(HDL_TOP)_$(PNR_VIEW).v \
$(OBJDIR)/$(HDL_TOP).enc: $(OBJDIR)/$(HDL_TOP)_pnr.tcl $(OBJDIR)/$(HDL_TOP).$(SYNTHTOOL)
	cd $(WORKSPACE); \
	CDS_EDI=$(CDS_EDI) CDS_OA_VERSION=$(CDS_OA_VERSION) OA_HOME=$(CDS_EDI)/$(CDS_OA_VERSION) \
	DONT_EXIT=$(DONT_EXIT) \
	$(CDS_EDI)/tools/bin/encounter -lic_startup vdi -wait 10 -overwrite -log $(OBJDIR)/$(HDL_TOP).enc.$(DATETIME) -file $<
	cp -p $(OBJDIR)/$(HDL_TOP).enc.$(DATETIME) $(OBJDIR)/$(HDL_TOP).enc

$(OBJDIR)/$(HDL_TOP)-view.enc: $(OBJDIR)/$(HDL_TOP)_pnr_view.tcl
	cd $(WORKSPACE); \
	CDS_EDI=$(CDS_EDI) CDS_OA_VERSION=$(CDS_OA_VERSION) OA_HOME=$(CDS_EDI)/$(CDS_OA_VERSION) \
	DONT_EXIT=$(DONT_EXIT) \
	$(CDS_EDI)/tools/bin/encounter -lic_startup vdi -wait 10 -overwrite -log $(OBJDIR)/$(HDL_TOP)-view.enc.$(DATETIME) -file $<
	cp -p $(OBJDIR)/$(HDL_TOP)-view.enc.$(DATETIME) $(OBJDIR)/$(HDL_TOP)-view.enc

pnr: $(OBJDIR)/$(HDL_TOP).enc

pnr-view: $(OBJDIR)/$(HDL_TOP)-view.enc

pnr-clean:
	rm -f $(OBJDIR)/*pnr.tcl
	rm -f $(OBJDIR)/*pnr_view.tcl
	rm -f $(OBJDIR)/$(HDL_TOP)_floorplan.tcl


#---------------------------------------------------------------------
# Import gate-level netlist into Virtuoso
#---------------------------------------------------------------------

$(OBJDIR)/$(HDL_TOP).ihdl_param: $(WORKSPACE)/setup/hdl/bin/ihdl_import
	$< -log $(OBJDIR)/$(HDL_TOP).ihdl.log -type sch -comp $(HDL_TOP) -reflib $(REFLIB) -target $(DESIGNLIB) > $@

ifeq ($(SYNTHTOOL),genus)
$(OBJDIR)/$(HDL_TOP).ihdl: $(OBJDIR)/$(HDL_TOP).ihdl_param $(OBJDIR)/$(HDL_TOP).genus
	cd $(WORKSPACE); \
	mkdir -p tmp; \
	ihdl $(IHDL_FLAGS) -param $< $(OBJDIR)/$(HDL_TOP)_pnr_nbl7.v | tee $@
else 
$(OBJDIR)/$(HDL_TOP).ihdl: $(OBJDIR)/$(HDL_TOP).ihdl_param $(OBJDIR)/$(HDL_TOP).rtlc
	cd $(WORKSPACE); \
	mkdir -p tmp; \
	ihdl $(IHDL_FLAGS) -param $< $(OBJDIR)/$(HDL_TOP)_$(GATE).v | tee $@
endif 

import-verilog: $(OBJDIR)/$(HDL_TOP).ihdl


#---------------------------------------------------------------------
# Import DEF into Virtuoso
#---------------------------------------------------------------------

DEF_VIEW ?= $(PNR_VIEW)

$(OBJDIR)/$(HDL_TOP).defin:
	cd $(WORKSPACE); \
	defin -lib $(DESIGNLIB) -overwrite -cell $(HDL_TOP) -view layout -viewNameList "abstract" -masterLibs $(REFLIB) -def $(OBJDIR)/$(HDL_TOP)_$(DEF_VIEW).def

import-def: $(OBJDIR)/$(HDL_TOP).defin

import-clean:
	rm -rf $(OBJDIR)/$(HDL_TOP).defin
	rm -rf $(OBJDIR)/$(HDL_TOP).ihdl
	rm -rf $(OBJDIR)/$(HDL_TOP).ihdl_param

#---------------------------------------------------------------------
# FPGA Target
# Set TECH        = fpga
# Set FPGA_TARGET = DE0_CV | DE0_NANO | CMOD_S7
#---------------------------------------------------------------------

FPGA_TARGET ?= DE0_NANO

ifeq ($(FPGA_TARGET),DE0_CV)
  DEVICE = 5CEBA4F23C7
  FAMILY = \"Cyclone V\"
elseifeq ($(FPGA_TARGET),DE0_NANO)
  DEVICE = EP4CE22F17C6
  FAMILY = \"Cyclone IV E\"
elseifeq (($(FPGA_TARGET),CMOD_S7)
  DEVICE = xc7s25csga225-1
endif

$(OBJDIR)/$(FPGA_TARGET):
	mkdir -p $(OBJDIR)/$(FPGA_TARGET)

$(OBJDIR)/$(FPGA_TARGET)/$(COMP).qpf: $(OBJDIR)/$(FPGA_TARGET)
	cd $(WORKSPACE); \
	echo "DATE = \"23:59:59  January 18, 2015\"" > $@; \
	echo "PROJECT_REVISION = \"$(COMP)\"" >> $@;

$(OBJDIR)/$(FPGA_TARGET)/$(COMP).qsf: \
  $(OBJDIR)/$(FPGA_TARGET) \
  $(OBJDIR)/$(FPGA_TARGET)/$(COMP).qpf \
  $(SOURCES_RTL)
	echo "set_global_assignment -name TOP_LEVEL_ENTITY $(COMP)" > $@; \
	echo "set_global_assignment -name DEVICE $(DEVICE)" >> $@; \
	echo "set_global_assignment -name FAMILY $(FAMILY)" >> $@; \
	echo "set_global_assignment -name LAST_QUARTUS_VERSION 15.0.2" >> $@; \
	echo "set_global_assignment -name STRATIX_DEVICE_IO_STANDARD \"3.3-V LVCMOS\"" >> $@; \
	echo "set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP \"AS INPUT TRI-STATED\"" >> $@; \
	echo "set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008" >> $@; \
	$(foreach src, $(filter %.v,   $^), echo "set_global_assignment -name VERILOG_FILE $(src)" >> $@;) \
	$(foreach src, $(filter %.vhd, $^), echo "set_global_assignment -name VHDL_FILE $(src)" >> $@;) \
	$(foreach src, $(filter %.tcl, $^), cat $(src) >> $@;)

$(OBJDIR)/$(FPGA_TARGET)/makefile.fpga: \
  $(OBJDIR)/$(FPGA_TARGET) \
  $(OBJDIR)/$(FPGA_TARGET)/$(COMP).qpf \
  $(OBJDIR)/$(FPGA_TARGET)/$(COMP).qsf \
  $(OBJDIR)/$(COMP).sdc
	echo "PROJECT = $(COMP)" > $@; \
	echo "SOURCE_FILES =" >> $@; \
	echo "ASSIGNMENT_FILES = $(COMP).qsf $(COMP).qpf" >> $@; \
	cat $(WORKSPACE)/setup/hdl/flow/quartus/tail_makefile >> $@; \
	cd $(OBJDIR)/$(FPGA_TARGET); \
	make -f makefile.fpga

fpga: $(OBJDIR)/$(FPGA_TARGET)/makefile.fpga

#---------------------------------------------------------------------
# Verilog2spice 
#---------------------------------------------------------------------
VLOG2SPICE = $(OPENTOOLS)/qflow/src/vlog2Spice
VLOG2VERILOG = $(OPENTOOLS)/qflow/src/vlog2Verilog
# Add power to verilog netlist

$(RESULTS_DIR)/6_final_power.v:
	$(VLOG2VERILOG) -o $(RESULTS_DIR)/6_final_power.v \
	-l $(OPEN_PDK)/sky130/sky130A/libs.ref/sky130_fd_sc_$(STD_KIT)/lef/sky130_fd_sc_$(STD_KIT).lef \
    -v "vdd," -g "vss," \
	$(RESULTS_DIR)/6_final.v 

# Must remove .include from 6_final.spice that will be dobble included if not
analog_view: $(RESULTS_DIR)/6_final_power.v 
	rm -f $(RESULTS_DIR)/6_final_power.errors
	$(VLOG2SPICE) \
	-l $(SPICE_FILE) \
	-o $(RESULTS_DIR)/6_final.spice $(RESULTS_DIR)/6_final_power.v 2> $(RESULTS_DIR)/6_final_power.errors ;\
	$(WORKSPACE)/setup/digital/bin/add_missing_port $(RESULTS_DIR)/6_final_power.errors $(RESULTS_DIR)/6_final_power.v ;\
	$(VLOG2SPICE) \
	-l $(SPICE_FILE) \
	-o $(RESULTS_DIR)/6_final.spice $(RESULTS_DIR)/6_final_power.v 2> $(RESULTS_DIR)/6_final_power.errors ;\
	sed -i '/.include /d' $(RESULTS_DIR)/6_final.spice ;\
	mkdir -p gate ;\
	cp $(RESULTS_DIR)/6_final_power.v gate/$(COMP)_$(VDD)_gate.v ;\
	$(WORKSPACE)/digital/system_model/strip_cells_from_verilog.py --netlist 
	cp $(RESULTS_DIR)/6_final.spice  $(COMP)_$(VDD).spice ;\
	cp $(RESULTS_DIR)/6_final.cdl $(COMP)_$(VDD).cdl ;\
	$(WORKSPACE)/setup/digital/bin/gen_analog_view $(COMP).spice gate/$(COMP)_$(VDD)_gate.v > $(COMP).sym 

lvs: analog_view 
	mkdir -p lvs ;\
	echo ".include $(WORKSPACE)/setup/analog/klayout/sky130_tech/tech/sky130/lvs/standard_cells/include_$(STD_KIT).cdl" > lvs/$(COMP)_with_refs.spice ;\
	cat $(COMP).spice >> lvs/$(COMP)_with_refs.spice ;\
	klayout -b -r $(WORKSPACE)/setup/analog/klayout/sky130_tech/tech/sky130/lvs/sky130.lvs \
	-rd input=$(COMP)_$(VDD).gds \
	-rd report=lvs/$(COMP).lvsdb \
	-rd schematic=lvs/$(COMP)_with_refs.spice \
	-rd thr=4 \
	-rd run_mode=deep \
	-rd target_netlist=lvs/$(COMP)_$(VDD)_lvs.cir \
	-rd spice_net_names=false \
	-rd spice_comments=false \
	-rd scale=$(LVS_SCALE) \
	-rd verbose=false \
	-rd schematic_simplify=false \
	-rd net_only=false \
	-rd top_lvl_pins=false \
	-rd combine=true \
	-rd purge=false \
	-rd purge_nets=true \
	-rd lvs_sub=VSS

strip_tab_filler_obj:
	sed -i '/XFILLER/d' $(OBJDIR)/$(COMP)_$(VDD).spice

strip_filler_local:
	sed -i '/XFILLER/d' $(COMP)_$(VDD).spice

strip_tap_local:
	sed -i '/XTAP/d' $(COMP)_$(VDD).spice

add_prefix_vdd_spice:
	sed -i 's/system_model/system_model_$(VDD)/' $(COMP)_$(VDD).spice

#---------------------------------------------------------------------
# GDSVIEW 
#---------------------------------------------------------------------

view_gds:
	GDS3D -p $(OPENTOOLS)/GDS3D/techfiles/sky130.txt \
	-i $(GDS_FINAL_FILE) 

view_obj:
	xdg-open $(RESULTS_DIR)

get_gds:
	cp $(GDS_FINAL_FILE) $(COMP)_$(VDD).gds
	  
	

#---------------------------------------------------------------------
# Cleanup targets
#---------------------------------------------------------------------

clean_:
	rm -rf $(OBJDIR)

