# Gemini Workspace Context: FPGA Template

This document provides context for the `fpga_template` project, an FPGA design for the Tang Nano 9K board.

## Project Overview

This project is a template for creating FPGA designs. It includes a top-level module (`fpga_template_top`) that instantiates several common peripherals:

*   **I2C Interface:** For communicating with I2C devices.
*   **UART Interface:** For serial communication with a host computer.
*   **PWM Generator:** For generating pulse-width modulated signals.
*   **Register Bank:** For controlling the FPGA's functionality from a host computer.

The project is configured for the Tang Nano 9K board and uses open-source tools for synthesis, place and route, and programming.

## Building and Running

The project is built using `make`. The following commands are available:

*   `make build`: Synthesize, place and route, and generate the bitstream.
*   `make flash`: Flash the bitstream to the FPGA's non-volatile memory.
*   `make load`: Load the bitstream to the FPGA's volatile memory.
*   `make clean`: Remove all build artifacts.

The `BOARD` variable in the `digital/fpga_template/makefile` can be changed to target other boards.

## Development Conventions

### Hardware Development

*   The main source files are located in the `digital` directory.
*   The top-level module is `digital/fpga_template/fpga_template.sv`.
*   The register bank is defined in `digital/rb_fpga_template/rb_fpga_template.sv` and is auto-generated.
*   The `sv2v` tool is used to convert SystemVerilog to Verilog.

### Software Development

*   Python tools for interacting with the FPGA are located in the `python_tools` directory.
*   The `fpga_uart_interface.py` script provides a Python class for communicating with the FPGA over UART.
*   The communication protocol is documented in the `fpga_uart_interface.py` script.
*   The register map is also documented in the `fpga_uart_interface.py` script.

### Testing

*   The `python_tools` directory contains several test scripts, including `test_led_blink.py` and `test_simple_uart.py`.
*   The `cocotb` framework is mentioned in the `README.md` file, but no `cocotb` testbenches are included in the project.
