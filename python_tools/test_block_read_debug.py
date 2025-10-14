#!/usr/bin/env python3
"""
Debug block read issues specifically
"""

import serial
import time
from fpga_uart_interface import FPGAUartInterface

def test_block_read_debug():
    """Debug block read functionality step by step"""

    print("Block Read Debug Test")
    print("====================")

    fpga = FPGAUartInterface(port='/dev/ttyUSB1', verbose=True)
    if not fpga.connect():
        print("Failed to connect")
        return

    try:
        # First, write some known data using single writes
        print("\n1. Writing test data using single writes...")
        test_addresses = [0x10, 0x11, 0x12]
        test_values = [0xAA, 0xBB, 0xCC]

        for addr, val in zip(test_addresses, test_values):
            success = fpga.write_register(addr, val)
            print(f"  Write 0x{val:02X} to 0x{addr:02X}: {'OK' if success else 'FAIL'}")
            time.sleep(0.1)

        # Verify with single reads
        print("\n2. Verifying with single reads...")
        for addr, expected in zip(test_addresses, test_values):
            value = fpga.read_register(addr)
            if value is not None:
                status = 'OK' if value == expected else f'MISMATCH (expected 0x{expected:02X})'
                print(f"  Read from 0x{addr:02X}: 0x{value:02X} - {status}")
            else:
                print(f"  Read from 0x{addr:02X}: TIMEOUT")
            time.sleep(0.1)

        # Now test block read
        print("\n3. Testing block read...")

        # Debug the raw serial communication
        print("\n3a. Raw serial block read test...")
        fpga.serial.reset_input_buffer()

        # Send block read command: 'b' + start_addr + length
        cmd = bytes([ord('b'), 0x10, 3])  # Read 3 bytes starting at 0x10
        print(f"  Sending command: {cmd.hex().upper()}")

        fpga.serial.write(cmd)
        fpga.serial.flush()

        # Wait for response and show what we get back
        print("  Waiting for response...")
        received_bytes = []
        start_time = time.time()

        while len(received_bytes) < 3 and (time.time() - start_time) < 5:
            if fpga.serial.in_waiting > 0:
                new_bytes = fpga.serial.read(fpga.serial.in_waiting)
                received_bytes.extend(new_bytes)
                print(f"  Got {len(new_bytes)} bytes: {new_bytes.hex().upper()}")
            time.sleep(0.1)

        print(f"  Total received: {len(received_bytes)} bytes")
        if received_bytes:
            print(f"  Data: {[hex(b) for b in received_bytes]}")

        # Test with the class method
        print("\n3b. Using class method...")
        result = fpga.read_block(0x10, 3)
        if result:
            print(f"  Block read result: {[hex(x) for x in result]}")
            print(f"  Expected:          {[hex(x) for x in test_values]}")

            if result == test_values:
                print("  Block read: SUCCESS!")
            else:
                print("  Block read: MISMATCH!")
        else:
            print("  Block read: FAILED")

        # Test with different sizes
        print("\n4. Testing different block sizes...")

        # Test single byte block read
        result = fpga.read_block(0x10, 1)
        print(f"  1-byte block read: {[hex(x) for x in result] if result else 'FAILED'}")

        # Test 2-byte block read
        result = fpga.read_block(0x10, 2)
        print(f"  2-byte block read: {[hex(x) for x in result] if result else 'FAILED'}")

        # Test timing with delays
        print("\n5. Testing with longer timeout...")
        fpga.serial.timeout = 5.0  # Increase timeout
        result = fpga.read_block(0x10, 3)
        print(f"  5s timeout result: {[hex(x) for x in result] if result else 'FAILED'}")

    finally:
        fpga.disconnect()

if __name__ == "__main__":
    test_block_read_debug()