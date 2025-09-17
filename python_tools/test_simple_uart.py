#!/usr/bin/env python3
"""
Very simple UART test - just send some bytes and see what happens
Focus on /dev/ttyUSB1 which should be the UART interface
"""

import serial
import time
import sys

def test_uart_simple():
    """Test the most basic UART functionality"""

    # Based on the USB device names, ttyUSB1 should be the UART interface
    port = '/dev/ttyUSB1'

    print(f"Testing UART on {port}")
    print("According to USB device names:")
    print("  /dev/ttyUSB0 = if00 = JTAG interface")
    print("  /dev/ttyUSB1 = if01 = UART interface")
    print()

    try:
        # Open with very basic settings
        ser = serial.Serial(
            port=port,
            baudrate=115200,
            timeout=3.0  # Longer timeout
        )

        print(f"Opened {port} successfully")

        # Clear buffers and wait
        ser.reset_input_buffer()
        ser.reset_output_buffer()
        time.sleep(0.5)

        # Test 1: Send individual characters slowly
        print("\nTest 1: Sending 'Hello' character by character...")
        for char in "Hello":
            print(f"  Sending '{char}'")
            ser.write(char.encode())
            ser.flush()
            time.sleep(0.1)

            # Check for immediate response
            if ser.in_waiting > 0:
                response = ser.read(ser.in_waiting)
                print(f"  Got response: {response}")

        # Test 2: Send our UART protocol commands slowly
        print("\nTest 2: Sending UART protocol commands...")

        # Try to read address 0x00 (sys_cfg register)
        print("  Sending read command: R 0x00")
        ser.write(b'R')
        time.sleep(0.1)
        ser.write(bytes([0x00]))
        ser.flush()

        # Wait for response with multiple checks
        print("  Waiting for response...")
        for i in range(30):  # Wait up to 3 seconds
            time.sleep(0.1)
            if ser.in_waiting > 0:
                response = ser.read(ser.in_waiting)
                print(f"  Response after {(i+1)*100}ms: {response.hex().upper()}")
                break
        else:
            print("  No response after 3 seconds")

        # Test 3: Try writing something
        print("\nTest 3: Trying write command...")
        ser.reset_input_buffer()

        print("  Sending write command: W 0x02 0xAA (set debug LEDs)")
        ser.write(b'W')
        time.sleep(0.05)
        ser.write(bytes([0x02]))  # debug LED register
        time.sleep(0.05)
        ser.write(bytes([0xAA]))  # pattern
        ser.flush()

        # Check for any response (shouldn't be any for write)
        time.sleep(0.2)
        if ser.in_waiting > 0:
            response = ser.read(ser.in_waiting)
            print(f"  Unexpected write response: {response.hex().upper()}")
        else:
            print("  No response to write (expected)")

        # Test 4: Try to read back what we wrote
        print("\nTest 4: Reading back debug LED register...")
        ser.write(bytes([ord('R'), 0x02]))
        ser.flush()

        for i in range(20):
            time.sleep(0.1)
            if ser.in_waiting > 0:
                response = ser.read(ser.in_waiting)
                print(f"  Read response: {response.hex().upper()}")
                if len(response) > 0:
                    print(f"  LED register value: 0x{response[0]:02X}")
                break
        else:
            print("  Read timeout")

        ser.close()
        print("\nUART test completed")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_uart_simple()