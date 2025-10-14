# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an FPGA template project designed for mid-sized FPGA designs, targeting Tang Nano development boards (9K and 20K). The project uses SystemVerilog with Verilog components and provides a complete build flow from source to bitstream.

## Architecture

The project follows a layered architecture:

1. **Top Module**: `fpga_template_top` in `digital/fpga_template/fpga_template.sv`
   - Integrates all system components (I2C, UART, PWM, register bank)
   - Handles clock/reset distribution and interface arbitration
   - Uses OR-based arbitration since only one interface is active at a time

2. **Register Bank System**: Auto-generated from Go source
   - `digital/rb_fpga_template/register_bank.go` defines register layout
   - Generates SystemVerilog register bank module and type definitions
   - Creates struct-based interfaces for clean register access

3. **Interface Modules**:
   - **I2C Interface** (`digital/i2c_if/`): Slave mode I2C for register access
   - **UART Interface** (`digital/uart_if/`): Serial communication for register access
   - **PWM Module** (`digital/pwm/`): Pulse width modulation output

4. **Build System**: Make-based with multiple stages
   - SystemVerilog to Verilog conversion using sv2v
   - Synthesis with Yosys (targeting Gowin FPGA)
   - Place & Route with nextpnr-himbaechel
   - Bitstream generation with gowin_pack

## Build Commands

All builds should be run from `digital/fpga_template/` directory:

```bash
cd digital/fpga_template
```

### Core Build Commands
- `make build` - Build complete bitstream for Tang Nano 9K (default)
- `make BOARD=tangnano20k build` - Build for Tang Nano 20K
- `make load` - Load bitstream to FPGA via USB (temporary, lost on power cycle)
- `make flash` - Flash bitstream to EPROM (persistent across power cycles)
- `make clean` - Remove all build artifacts
- `make conv2v` - Convert SystemVerilog files to Verilog using sv2v
- `make info` or `make help` - Show build configuration and available commands

### Register Bank Generation
```bash
cd digital/rb_fpga_template
make regs  # Generates register bank from register_bank.go
```

### Debug/Info Commands
- `make test` - Show converted file list
- `make src` - Show SystemVerilog source files
- `make s` - Show all source files

## Key Files and Structure

### Source Organization
- `digital/fpga_template/` - Main FPGA project and top-level
- `digital/rb_fpga_template/` - Register bank definition and generation
- `digital/i2c_if/` - I2C slave interface (Verilog)
- `digital/uart_if/` - UART interface (Verilog)
- `digital/pwm/` - PWM module (Verilog)
- `python_tools/` - Python UART communication tools and test scripts
- `obj/` - Build output directory (created automatically)

### Build Configuration
Default board: Tang Nano 9K (`tangnano9k`)
- **Tang Nano 9K**: Family GW1N-9C, Device GW1NR-LV9QN88PC6/I5, Constraint file `tangnano9k.cst`
- **Tang Nano 20K**: Family GW2A-18C, Device GW2AR-LV18QN88C8/I7, Constraint file `tangnano20k.cst`

### SystemVerilog Conversion
- Original `.sv` files are converted to `.sv.conv.v` using sv2v tool
- Package imports and struct types require conversion for Yosys compatibility
- sv2v binary is located at workspace root

## Register Bank System

The register bank is defined in Go (`register_bank.go`) and auto-generates:
- SystemVerilog register module (`rb_fpga_template.sv`)
- Type definitions (`rb_fpga_template_struct.svh`)
- Register documentation files

Current register sections:
- `sys_cfg` (0x00-0x0F): System configuration including PWM duty cycle and debug LEDs
- `dsp_cfg` (0x40-0x4F): DSP configuration for filters and processing

## Development Workflow

1. Modify SystemVerilog source files
2. If register changes needed, edit `register_bank.go` and run `make regs`
3. Run `make build` to create bitstream
4. Use `make load` for temporary testing or `make flash` for persistent deployment
5. Debug using debug LED outputs (controlled via sys_cfg.debug_led register)

## Hardware Interface

- **Clock**: External clock input
- **Reset**: Button S1 (btn_s1_reset)
- **I2C**: SCL/SDA pins for register access
- **UART**: RX/TX pins (connected to USB/FTDI)
- **PWM**: Single PWM output
- **Debug**: 6-bit LED output for debugging
- **Buttons**: S1 (reset), S2 (general purpose)

## Python UART Tools

The `python_tools/` directory contains Python scripts for communicating with the FPGA via UART:

### Command Line Interface
- **`fcom`** - Command-line tool for FPGA register access (similar to scom)
  - **Auto-detects Tang Nano board** - No need to specify port manually
  - Read/write registers: `./fcom r 0x01`, `./fcom w 0x02 0x2A`
  - Named register access: `./fcom r pwm_duty`, `./fcom w debug_led 0x15`
  - Special commands: `./fcom led 0x3F`, `./fcom pwm 75.0`, `./fcom test`
  - Output formats: `-oh` (hex), `-od` (decimal), `-ob` (binary)
  - Manual port: `-p /dev/ttyUSB2` (overrides auto-detection)
  - See `python_tools/README.md` for full usage

### Main Interface Class
- **`fpga_uart_interface.py`** - Complete UART interface class with protocol implementation
  - Single read/write operations
  - Block read/write operations
  - Convenience methods for PWM, LEDs, and system config
  - Register map integration

### Test and Debug Scripts
- **`test_led_blink.py`** - Visual LED control test (recommended first test)
- **`uart_debug.py`** - Low-level UART port debugging
- **`test_simple_uart.py`** - Basic protocol testing

### Usage Examples
```bash
# Command line - quick register access
cd python_tools
./fcom pwm 75.0           # Set PWM to 75%
./fcom led 0x2A           # Set LED pattern
./fcom r pwm_duty         # Read PWM duty register
```

```python
# Python API - programmatic access
from python_tools.fpga_uart_interface import FPGAUartInterface

fpga = FPGAUartInterface(port='/dev/ttyUSB1')
if fpga.connect():
    fpga.set_pwm_duty(50.0)      # Set PWM to 50%
    fpga.set_debug_leds(0x2A)    # Control debug LEDs
    value = fpga.read_register(0x01)  # Read register
    fpga.disconnect()
```

### UART Connection Details
- **Hardware**: Tang Nano onboard USB-to-serial converter (FTDI FT2232H from SIPEED)
- **Port**: Auto-detected by `fcom` tool (typically `/dev/ttyUSB2` for UART, `/dev/ttyUSB1` for JTAG)
- **Detection**: Identifies SIPEED device (VID:PID 0403:6010) and selects UART interface (interface 01)
- **Settings**: 115200 baud, 8N1
- **Protocol**: Custom register access protocol
  - Single Write: `'W' + address_byte + data_byte`
  - Single Read: `'R' + address_byte → responds with data_byte`
  - Block Write: `'B' + start_address + length + data0 + data1 + ...`
  - Block Read: `'b' + start_address + length → responds with data0 + data1 + ...`

## Dependencies

### FPGA Tools
Required tools (should be in PATH):
- `sv2v` - SystemVerilog to Verilog converter
- `yosys` - Synthesis tool
- `nextpnr-himbaechel` - Place and route for Gowin FPGAs
- `gowin_pack` - Bitstream generation
- `openFPGALoader` - FPGA programming tool

### Python Tools
- Python 3.6+
- `pyserial` package: `pip install pyserial`