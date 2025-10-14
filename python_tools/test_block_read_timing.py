#!/usr/bin/env python3
"""
Debug block read timing issues
"""

import serial
import time

def test_block_read_timing():
    """Test block read with careful timing analysis"""

    print("Block Read Timing Debug")
    print("======================")

    try:
        ser = serial.Serial('/dev/ttyUSB1', 115200, timeout=0.1)
        ser.reset_input_buffer()
        ser.reset_output_buffer()
        time.sleep(0.1)

        print("Connected to UART")

        # First, set up known values in known working registers
        print("\n1. Setting up known values...")

        # Write to 0x01 (PWM register)
        ser.write(bytes([ord('W'), 0x01, 0xAA]))
        ser.flush()
        time.sleep(0.1)
        ser.reset_input_buffer()

        # Write to 0x02 (LED register)
        ser.write(bytes([ord('W'), 0x02, 0xBB]))
        ser.flush()
        time.sleep(0.1)
        ser.reset_input_buffer()

        # Verify with single reads
        print("\n2. Verifying with single reads...")

        ser.write(bytes([ord('R'), 0x01]))
        ser.flush()
        time.sleep(0.1)
        response = ser.read(10)
        print(f"  Single read 0x01: {response.hex().upper()} (expected: AA)")

        ser.write(bytes([ord('R'), 0x02]))
        ser.flush()
        time.sleep(0.1)
        response = ser.read(10)
        print(f"  Single read 0x02: {response.hex().upper()} (expected: BB)")

        # Now try block read with detailed timing
        print("\n3. Block read with timing analysis...")

        ser.reset_input_buffer()

        # Send block read command
        cmd = bytes([ord('b'), 0x01, 2])  # Read 2 bytes from 0x01
        print(f"  Sending: {cmd.hex().upper()}")

        ser.write(cmd)
        ser.flush()

        # Monitor response byte by byte with timestamps
        print("  Monitoring response...")
        start_time = time.time()
        received = []

        for i in range(50):  # Check for 5 seconds
            if ser.in_waiting > 0:
                new_bytes = ser.read(ser.in_waiting)
                timestamp = time.time() - start_time
                received.extend(new_bytes)
                print(f"    {timestamp:.3f}s: Got {len(new_bytes)} bytes: {new_bytes.hex().upper()}")

                if len(received) >= 2:
                    break
            time.sleep(0.1)

        print(f"  Total received: {len(received)} bytes")
        if received:
            print(f"  Expected: AA BB")
            print(f"  Actual:   {' '.join(f'{b:02X}' for b in received[:2])}")

        # Try a different block read approach - send bytes individually
        print("\n4. Sending block read command byte by byte...")

        ser.reset_input_buffer()

        print("  Sending 'b'...")
        ser.write(bytes([ord('b')]))
        ser.flush()
        time.sleep(0.2)

        print("  Sending address 0x01...")
        ser.write(bytes([0x01]))
        ser.flush()
        time.sleep(0.2)

        print("  Sending length 2...")
        ser.write(bytes([2]))
        ser.flush()
        time.sleep(0.2)

        # Check for response
        received = []
        for i in range(30):
            if ser.in_waiting > 0:
                new_bytes = ser.read(ser.in_waiting)
                received.extend(new_bytes)
                print(f"    Got {len(new_bytes)} bytes: {new_bytes.hex().upper()}")
                if len(received) >= 2:
                    break
            time.sleep(0.1)

        print(f"  Final result: {' '.join(f'{b:02X}' for b in received[:2])}")

        ser.close()

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_block_read_timing()