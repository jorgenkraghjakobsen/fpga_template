#!/usr/bin/env python3
"""
Test known working registers to isolate the issue
"""

import time
from fpga_uart_interface import FPGAUartInterface

def test_known_registers():
    """Test registers we know should work"""

    print("Known Register Test")
    print("==================")

    fpga = FPGAUartInterface(port='/dev/ttyUSB1', verbose=True)
    if not fpga.connect():
        print("Failed to connect")
        return

    try:
        # Test debug LED register (0x02) - this should work
        print("\n1. Testing debug LED register (0x02)...")

        # Write a pattern
        test_value = 0x2A  # 00101010 pattern
        success = fpga.write_register(0x02, test_value)
        print(f"  Write 0x{test_value:02X} to 0x02: {'OK' if success else 'FAIL'}")
        time.sleep(0.1)

        # Read it back
        value = fpga.read_register(0x02)
        if value is not None:
            print(f"  Read back: 0x{value:02X}")
            print(f"  Match: {'YES' if value == test_value else 'NO'}")
        else:
            print("  Read failed")

        # Test PWM register (0x01)
        print("\n2. Testing PWM register (0x01)...")

        test_value = 0x80  # 50% duty cycle
        success = fpga.write_register(0x01, test_value)
        print(f"  Write 0x{test_value:02X} to 0x01: {'OK' if success else 'FAIL'}")
        time.sleep(0.1)

        value = fpga.read_register(0x01)
        if value is not None:
            print(f"  Read back: 0x{value:02X}")
            print(f"  Match: {'YES' if value == test_value else 'NO'}")
        else:
            print("  Read failed")

        # Test sys_cfg control register (0x00)
        print("\n3. Testing sys_cfg control register (0x00)...")

        test_value = 0x03  # Set bits 0 and 1
        success = fpga.write_register(0x00, test_value)
        print(f"  Write 0x{test_value:02X} to 0x00: {'OK' if success else 'FAIL'}")
        time.sleep(0.1)

        value = fpga.read_register(0x00)
        if value is not None:
            print(f"  Read back: 0x{value:02X}")
            print(f"  Match: {'YES' if value == test_value else 'NO'}")
        else:
            print("  Read failed")

        # Test an address that should be empty/unused (0x10)
        print("\n4. Testing unused register (0x10)...")

        test_value = 0xAA
        success = fpga.write_register(0x10, test_value)
        print(f"  Write 0x{test_value:02X} to 0x10: {'OK' if success else 'FAIL'}")
        time.sleep(0.1)

        value = fpga.read_register(0x10)
        if value is not None:
            print(f"  Read back: 0x{value:02X}")
            print(f"  Match: {'YES' if value == test_value else 'NO'}")
            if value == 0x00:
                print("  (This register might not be implemented)")
        else:
            print("  Read failed")

        # Now test block read on known working registers
        print("\n5. Testing block read on known registers...")

        # First set up known values
        fpga.write_register(0x00, 0x11)
        fpga.write_register(0x01, 0x22)
        fpga.write_register(0x02, 0x33)
        time.sleep(0.2)

        # Try block read
        result = fpga.read_block(0x00, 3)
        if result:
            print(f"  Block read result: {[hex(x) for x in result]}")
            print(f"  Expected approx:   ['0x11', '0x22', '0x33']")
        else:
            print("  Block read failed")

    finally:
        fpga.disconnect()

if __name__ == "__main__":
    test_known_registers()