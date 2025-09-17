#!/usr/bin/env python3
"""
Simple UART debug tool for the FPGA interface.
Tests basic communication step by step.
"""

import serial
import time
import sys

def test_uart_port(port, baudrate=115200):
    """Test basic UART communication on a specific port."""
    print(f"\nTesting {port} at {baudrate} baud...")

    try:
        ser = serial.Serial(
            port=port,
            baudrate=baudrate,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            timeout=2.0,  # Longer timeout
            xonxoff=False,
            rtscts=False,
            dsrdtr=False
        )

        # Clear buffers
        ser.reset_input_buffer()
        ser.reset_output_buffer()
        time.sleep(0.1)  # Let UART settle

        print(f"Successfully opened {port}")

        # Test 1: Simple single-byte write (just 'W' command)
        print("Test 1: Sending single 'W' byte...")
        ser.write(b'W')
        ser.flush()
        time.sleep(0.1)

        # Check if anything comes back
        available = ser.in_waiting
        if available > 0:
            response = ser.read(available)
            print(f"Got {available} bytes back: {response.hex()}")
        else:
            print("No response")

        # Test 2: Try a complete write command
        print("\nTest 2: Complete write command (W + addr + data)...")
        ser.reset_input_buffer()

        # Write to address 0x02 (debug_led) with value 0x15 (pattern)
        cmd = bytes([ord('W'), 0x02, 0x15])
        print(f"Sending: {cmd.hex().upper()}")
        ser.write(cmd)
        ser.flush()
        time.sleep(0.2)  # Give time for processing

        # Check response
        available = ser.in_waiting
        if available > 0:
            response = ser.read(available)
            print(f"Got {available} bytes back: {response.hex()}")
        else:
            print("No response (expected for write)")

        # Test 3: Try a read command
        print("\nTest 3: Read command (R + addr)...")
        ser.reset_input_buffer()

        # Read from address 0x02 (debug_led)
        cmd = bytes([ord('R'), 0x02])
        print(f"Sending: {cmd.hex().upper()}")
        ser.write(cmd)
        ser.flush()

        # Wait for response with multiple attempts
        for attempt in range(10):  # Try for 1 second total
            time.sleep(0.1)
            available = ser.in_waiting
            if available > 0:
                response = ser.read(available)
                print(f"Got response after {attempt*100}ms: {response.hex().upper()}")
                if len(response) >= 1:
                    print(f"Read value: 0x{response[0]:02X} ({response[0]})")
                break
        else:
            print("Read timed out after 1 second")

        # Test 4: Check for continuous data
        print("\nTest 4: Listening for any continuous data...")
        ser.reset_input_buffer()
        time.sleep(0.5)
        available = ser.in_waiting
        if available > 0:
            data = ser.read(available)
            print(f"Continuous data: {data.hex().upper()}")
        else:
            print("No continuous data")

        # Test 5: Different baud rates
        ser.close()
        print(f"\nTesting different baud rates on {port}...")

        for baud in [9600, 57600, 115200, 230400]:
            try:
                test_ser = serial.Serial(port, baud, timeout=0.5)
                test_ser.reset_input_buffer()
                test_ser.write(b'R\x00')  # Try to read address 0
                test_ser.flush()
                time.sleep(0.2)

                if test_ser.in_waiting > 0:
                    response = test_ser.read(test_ser.in_waiting)
                    print(f"  {baud} baud: Got response {response.hex().upper()}")
                else:
                    print(f"  {baud} baud: No response")

                test_ser.close()
            except Exception as e:
                print(f"  {baud} baud: Error - {e}")

        print(f"Finished testing {port}")
        return True

    except serial.SerialException as e:
        print(f"Failed to open {port}: {e}")
        return False
    except Exception as e:
        print(f"Error testing {port}: {e}")
        return False

def main():
    print("FPGA UART Debug Tool")
    print("===================")

    # Test both USB ports
    ports = ['/dev/ttyUSB0', '/dev/ttyUSB1']

    for port in ports:
        if test_uart_port(port):
            print(f"\n{port} is accessible")
        else:
            print(f"\n{port} failed")

    print("\nDebug complete!")

if __name__ == "__main__":
    main()