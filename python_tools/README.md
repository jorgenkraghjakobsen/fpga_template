# Python UART Tools

This directory contains Python tools for communicating with the FPGA via UART interface.

## Files

### Main Interface
- **`fpga_uart_interface.py`** - Main reusable UART interface class for FPGA communication
- **`fcom`** - Command-line interface for FPGA register access (executable)

### Test and Debug Tools
- **`test_led_blink.py`** - LED control test to verify FPGA functionality
- **uart_debug.py`** - Low-level UART debugging and port testing
- **`test_simple_uart.py`** - Basic UART protocol testing

## Usage

### Command Line Interface (fcom)
The `fcom` tool provides a command-line interface similar to `scom`:

```bash
# Show help
./fcom -h

# Read registers
./fcom r 0x01                    # Read PWM duty register
./fcom r pwm_duty                # Read using symbolic name

# Write registers
./fcom w 0x02 0x2A              # Write to debug LED register
./fcom w debug_led 0x15         # Write using symbolic name

# Special commands
./fcom led 0x3F                 # Set LED pattern (all LEDs on)
./fcom pwm 75.0                 # Set PWM to 75% duty cycle
./fcom test                     # Test UART connection
./fcom info                     # Show register map

# Dump registers
./fcom d 0x00 0x05             # Dump registers 0x00 to 0x05

# Block operations
./fcom b 0x10 0xAA 0xBB 0xCC   # Block write
./fcom br 0x00 3               # Block read 3 bytes

# Output formats
./fcom r 0x01 -od              # Decimal output
./fcom r 0x01 -ob              # Binary output
./fcom r 0x01 -oh              # Hex output (default)

# Different ports
./fcom r 0x01 -p /dev/ttyUSB0  # Use different port
```

### Python API Usage
```python
from fpga_uart_interface import FPGAUartInterface

# Connect to FPGA
fpga = FPGAUartInterface(port='/dev/ttyUSB1')
if fpga.connect():
    # Set PWM duty cycle to 75%
    fpga.set_pwm_duty(75.0)

    # Set debug LED pattern
    fpga.set_debug_leds(0x2A)  # LEDs 1,3,5

    # Read register directly
    value = fpga.read_register(0x01)  # PWM duty register

    fpga.disconnect()
```

### Running Test Scripts
```bash
cd python_tools

# Test LED control (visual verification)
python3 test_led_blink.py

# Debug UART communication
python3 uart_debug.py

# Test basic protocol
python3 test_simple_uart.py

# Run main interface with examples
python3 fpga_uart_interface.py
```

## UART Protocol

The FPGA implements a simple UART protocol:

- **Single Write**: `'W' + address_byte + data_byte`
- **Single Read**: `'R' + address_byte → responds with data_byte`
- **Block Write**: `'B' + start_address + length + data0 + data1 + ...`
- **Block Read**: `'b' + start_address + length → responds with data0 + data1 + ...`

## Hardware Connection

- **Port**: `/dev/ttyUSB0` (UART interface on Tang Nano 9K)
- **Baud Rate**: 115200
- **Data**: 8 bits, No parity, 1 stop bit

## Register Map

Key registers available through the interface:

| Address | Register | Description |
|---------|----------|-------------|
| 0x00 | sys_cfg_control | System control bits (enable_stuf, enable_other, monitor_flag) |
| 0x01 | pwm_duty | PWM duty cycle (8-bit, 0x80 = 50%) |
| 0x02 | debug_led | Debug LED pattern (6-bit) |
| 0x40 | dsp_cfg_control | DSP configuration |

## Requirements

- Python 3.6+
- pyserial package: `pip install pyserial`

## Known Issues

- Read operations currently timeout - write operations work correctly
- Block operations may have timing issues
- Requires investigation of FPGA UART TX implementation