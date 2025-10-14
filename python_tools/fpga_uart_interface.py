#!/usr/bin/env python3
"""
FPGA UART Interface Class
Reusable Python class for communicating with the FPGA register bank via UART.
On tangnano9k ttyUSB1 is used for uart communication

Protocol:
- Single Write: 'W' + address_byte + data_byte
- Single Read:  'R' + address_byte → responds with data_byte
- Block Write:  'B' + start_address + length + data0 + data1 + ... + dataN
- Block Read:   'b' + start_address + length → responds with data0 + data1 + ... + dataN

Register Map (from reg_file_fpga_template):
- sys_cfg.enable_stuf (0x00 bit 0): Enable stuf
- sys_cfg.enable_other (0x00 bit 1): Enable other stuf
- sys_cfg.monitor_flag (0x00 bit 2): Monitor internal flag (read-only)
- sys_cfg.pwm_duty (0x01): Counter value for PWM (8-bit)
- sys_cfg.debug_led (0x02): Debug led signals (6-bit)
- dsp_cfg.bypass_enable (0x40 bit 0): Bypass filters on the DSP
- dsp_cfg.dc_filter_enable (0x40 bit 1): Bypass DC filter on the DSP
- ... (more DSP config at 0x40)

Author: Claude Code
"""

import serial
import time
from typing import List, Optional, Union


class FPGAUartInterface:
    """UART interface for FPGA register bank communication."""

    # On tangnano9k ttyUSB1 is used for uart communication
    def __init__(self, port: str = '/dev/ttyUSB1', baudrate: int = 115200, timeout: float = 1.0, verbose: bool = True):
        """
        Initialize UART connection to FPGA.

        Args:
            port: Serial port device (e.g., '/dev/ttyUSB0', '/dev/ttyUSB1')
            baudrate: UART baud rate (default 115200, matching FPGA)
            timeout: Read timeout in seconds
            verbose: Whether to print connection messages
        """
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.serial = None
        self.verbose = verbose

        # Register map for convenience
        self.registers = {
            # sys_cfg section (0x00-0x0F)
            'sys_cfg_control': 0x00,      # bits 0,1,2 for enable_stuf, enable_other, monitor_flag
            'pwm_duty': 0x01,             # PWM duty cycle (8-bit, 0x80 = 50%)
            'debug_led': 0x02,            # Debug LED output (6-bit)

            # dsp_cfg section (0x40-0x4F)
            'dsp_cfg_control': 0x40,      # DSP filter enables and placeholders
        }

    def connect(self) -> bool:
        """
        Establish UART connection to FPGA.

        Returns:
            True if connection successful, False otherwise
        """
        try:
            self.serial = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                timeout=self.timeout
            )
            # Clear any existing data in buffers
            self.serial.reset_input_buffer()
            self.serial.reset_output_buffer()
            if self.verbose:
                print(f"Connected to FPGA on {self.port} at {self.baudrate} baud")
            return True
        except serial.SerialException as e:
            print(f"Failed to connect to {self.port}: {e}")
            return False

    def disconnect(self):
        """Close UART connection."""
        if self.serial and self.serial.is_open:
            self.serial.close()
            if self.verbose:
                print("Disconnected from FPGA")

    def write_register(self, address: int, data: int) -> bool:
        """
        Write single byte to register.

        Args:
            address: Register address (0-255)
            data: Data byte to write (0-255)

        Returns:
            True if write successful, False otherwise
        """
        if not self.serial or not self.serial.is_open:
            print("UART not connected")
            return False

        try:
            # Send: 'W' + address + data
            cmd = bytes([ord('W'), address & 0xFF, data & 0xFF])
            self.serial.write(cmd)
            self.serial.flush()
            time.sleep(0.05) # Wait for FPGA to process
            self.serial.reset_input_buffer() # Clear any response
            return True
        except serial.SerialException as e:
            print(f"Write error: {e}")
            return False

    def read_register(self, address: int) -> Optional[int]:
        """
        Read single byte from register.

        Args:
            address: Register address (0-255)

        Returns:
            Data byte (0-255) if successful, None if error
        """
        if not self.serial or not self.serial.is_open:
            print("UART not connected")
            return None

        try:
            # Clear input buffer before read
            self.serial.reset_input_buffer()

            # Send: 'R' + address
            cmd = bytes([ord('R'), address & 0xFF])
            self.serial.write(cmd)
            self.serial.flush()

            # Read response
            response = self.serial.read(1)
            if len(response) == 1:
                return response[0]
            else:
                print(f"Read timeout on address 0x{address:02X}")
                return None

        except serial.SerialException as e:
            print(f"Read error: {e}")
            return None

    def write_block(self, start_address: int, data: List[int]) -> bool:
        """
        Write block of bytes to consecutive registers.

        Args:
            start_address: Starting register address
            data: List of data bytes to write

        Returns:
            True if write successful, False otherwise
        """
        if not self.serial or not self.serial.is_open:
            print("UART not connected")
            return False

        if len(data) == 0 or len(data) > 255:
            print("Invalid block size (1-255 bytes)")
            return False

        try:
            # Send: 'B' + start_address + length + data[0] + data[1] + ...
            cmd = bytes([ord('B'), start_address & 0xFF, len(data)])
            cmd += bytes([d & 0xFF for d in data])
            self.serial.write(cmd)
            self.serial.flush()
            time.sleep(0.05) # Wait for FPGA to process
            self.serial.reset_input_buffer() # Clear any response
            return True
        except serial.SerialException as e:
            print(f"Block write error: {e}")
            return False

    def read_block(self, start_address: int, length: int) -> Optional[List[int]]:
        """
        Read block of bytes from consecutive registers.

        Args:
            start_address: Starting register address
            length: Number of bytes to read (1-255)

        Returns:
            List of data bytes if successful, None if error
        """
        if not self.serial or not self.serial.is_open:
            print("UART not connected")
            return None

        if length == 0 or length > 255:
            print("Invalid block size (1-255 bytes)")
            return None

        try:
            # Clear input buffer before read
            self.serial.reset_input_buffer()

            # Send: 'b' + start_address + length
            cmd = bytes([ord('b'), start_address & 0xFF, length])
            self.serial.write(cmd)
            self.serial.flush()

            # WORKAROUND: FPGA sends too much data, need to find the correct bytes
            # Read more data than requested to handle FPGA buffer issue
            max_response_size = 256
            response = self.serial.read(max_response_size)

            if len(response) < length:
                print(f"Block read timeout: got {len(response)} of {length} bytes")
                return None

            # FPGA sends correct data at the end of the response
            # Find the last occurrence of the expected length
            if len(response) > length:
                # Take the last 'length' bytes which should be the correct data
                correct_data = response[-length:]
                return list(correct_data)
            else:
                return list(response[:length])

        except serial.SerialException as e:
            print(f"Block read error: {e}")
            return None

    def set_pwm_duty(self, duty_percent: float) -> bool:
        """
        Set PWM duty cycle as percentage.

        Args:
            duty_percent: Duty cycle percentage (0.0 - 100.0)

        Returns:
            True if successful, False otherwise
        """
        if not (0.0 <= duty_percent <= 100.0):
            print("Duty cycle must be 0-100%")
            return False

        # Convert percentage to 8-bit value (0x80 = 50%)
        duty_value = int((duty_percent / 100.0) * 255)
        return self.write_register(self.registers['pwm_duty'], duty_value)

    def get_pwm_duty(self) -> Optional[float]:
        """
        Get current PWM duty cycle as percentage.

        Returns:
            Duty cycle percentage if successful, None if error
        """
        duty_value = self.read_register(self.registers['pwm_duty'])
        if duty_value is not None:
            return (duty_value / 255.0) * 100.0
        return None

    def set_debug_leds(self, led_pattern: int) -> bool:
        """
        Set debug LED pattern.

        Args:
            led_pattern: 6-bit LED pattern (0-63)

        Returns:
            True if successful, False otherwise
        """
        if not (0 <= led_pattern <= 63):
            print("LED pattern must be 0-63 (6 bits)")
            return False

        return self.write_register(self.registers['debug_led'], led_pattern)

    def get_debug_leds(self) -> Optional[int]:
        """
        Get current debug LED pattern.

        Returns:
            6-bit LED pattern if successful, None if error
        """
        return self.read_register(self.registers['debug_led'])

    def set_sys_cfg_bits(self, enable_stuf: bool = None, enable_other: bool = None) -> bool:
        """
        Set individual bits in sys_cfg control register.

        Args:
            enable_stuf: Set bit 0 if not None
            enable_other: Set bit 1 if not None

        Returns:
            True if successful, False otherwise
        """
        # Read current value
        current = self.read_register(self.registers['sys_cfg_control'])
        if current is None:
            return False

        # Modify bits as requested
        if enable_stuf is not None:
            if enable_stuf:
                current |= 0x01  # Set bit 0
            else:
                current &= ~0x01  # Clear bit 0

        if enable_other is not None:
            if enable_other:
                current |= 0x02  # Set bit 1
            else:
                current &= ~0x02  # Clear bit 1

        return self.write_register(self.registers['sys_cfg_control'], current)

    def get_sys_cfg_status(self) -> Optional[dict]:
        """
        Get system configuration status bits.

        Returns:
            Dictionary with status bits if successful, None if error
        """
        value = self.read_register(self.registers['sys_cfg_control'])
        if value is not None:
            return {
                'enable_stuf': bool(value & 0x01),
                'enable_other': bool(value & 0x02),
                'monitor_flag': bool(value & 0x04)  # Read-only bit
            }
        return None

    def dump_registers(self, start_addr: int = 0x00, end_addr: int = 0x4F) -> bool:
        """
        Dump register contents for debugging.

        Args:
            start_addr: Starting address
            end_addr: Ending address

        Returns:
            True if successful, False otherwise
        """
        print(f"\nRegister dump (0x{start_addr:02X} - 0x{end_addr:02X}):")
        print("Addr  Value  Binary   Description")
        print("-" * 40)

        success = True
        for addr in range(start_addr, end_addr + 1):
            value = self.read_register(addr)
            if value is not None:
                binary = f"{value:08b}"

                # Add description for known registers
                desc = ""
                if addr == 0x00:
                    desc = "sys_cfg control"
                elif addr == 0x01:
                    desc = f"PWM duty ({(value/255*100):.1f}%)"
                elif addr == 0x02:
                    desc = f"Debug LEDs (0x{value:02X})"
                elif addr == 0x40:
                    desc = "dsp_cfg control"

                print(f"0x{addr:02X}  0x{value:02X}   {binary}  {desc}")
            else:
                print(f"0x{addr:02X}  ERROR")
                success = False

        return success


def main():
    """Example usage and test of the FPGA UART interface."""
    print("FPGA UART Interface Test")
    print("========================")

    # Try different common USB-to-serial ports
    ports_to_try = ['/dev/ttyUSB0', '/dev/ttyUSB1', '/dev/ttyACM0']

    fpga = None
    for port in ports_to_try:
        fpga = FPGAUartInterface(port=port)
        if fpga.connect():
            break
        fpga = None

    if not fpga:
        print("Could not connect to FPGA on any port")
        return

    try:
        # Test basic register operations
        print("\n1. Testing basic register read/write...")

        # Set PWM to 50% duty cycle
        print("Setting PWM duty to 50%...")
        fpga.set_pwm_duty(50.0)

        # Read back PWM duty
        duty = fpga.get_pwm_duty()
        print(f"Current PWM duty: {duty:.1f}%")

        # Test debug LEDs - count from 0 to 63
        print("\n2. Testing debug LEDs (cycling pattern)...")
        for i in range(8):
            pattern = (1 << i) if i < 6 else 0  # Single LED moving, then off
            fpga.set_debug_leds(pattern)
            current = fpga.get_debug_leds()
            print(f"LED pattern: 0x{pattern:02X} -> readback: 0x{current:02X}")
            time.sleep(0.2)

        # Test system config bits
        print("\n3. Testing system config bits...")
        fpga.set_sys_cfg_bits(enable_stuf=True, enable_other=False)
        status = fpga.get_sys_cfg_status()
        if status:
            print(f"System config: {status}")

        # Test block operations
        print("\n4. Testing block operations...")
        test_data = [0x11, 0x22, 0x33]
        print(f"Writing block data {[hex(x) for x in test_data]} to addresses 0x10-0x12")
        fpga.write_block(0x10, test_data)

        read_data = fpga.read_block(0x10, 3)
        if read_data:
            print(f"Read back: {[hex(x) for x in read_data]}")
            if read_data == test_data:
                print("Block operation SUCCESS!")
            else:
                print("Block operation MISMATCH!")

        # Register dump
        print("\n5. Register dump:")
        fpga.dump_registers(0x00, 0x05)  # sys_cfg section
        fpga.dump_registers(0x40, 0x42)  # dsp_cfg section

    finally:
        fpga.disconnect()


if __name__ == "__main__":
    main()