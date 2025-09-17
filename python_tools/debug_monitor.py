#!/usr/bin/env python3
"""
FPGA Debug Monitor
Monitors UART output for debug messages from the FPGA.
Press Button S2 on the FPGA to trigger debug sequence.

Debug sequence expected: "DBG: " followed by bytes 0x00-0x0F and newline
"""

import serial
import time
import sys

def monitor_debug_output(port='/dev/ttyUSB0', baudrate=115200):
    """Monitor UART for debug output from FPGA."""

    print(f"FPGA Debug Monitor")
    print(f"==================")
    print(f"Port: {port}")
    print(f"Baud: {baudrate}")
    print()
    print("Instructions:")
    print("1. Make sure FPGA is programmed and running")
    print("2. Press Button S2 on the FPGA to send debug sequence")
    print("3. Press Ctrl+C to exit")
    print()
    print("Waiting for debug data...")
    print("-" * 40)

    try:
        # Open serial port
        ser = serial.Serial(
            port=port,
            baudrate=baudrate,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            timeout=0.1  # Non-blocking read
        )

        # Clear any existing data
        ser.reset_input_buffer()

        received_data = bytearray()
        last_activity = time.time()

        while True:
            # Read available data
            if ser.in_waiting > 0:
                data = ser.read(ser.in_waiting)
                received_data.extend(data)
                last_activity = time.time()

                # Display raw bytes
                for byte in data:
                    if 32 <= byte <= 126:  # Printable ASCII
                        char = chr(byte)
                        print(f"RX: 0x{byte:02X} '{char}'")
                    else:
                        print(f"RX: 0x{byte:02X} [non-printable]")

                # Check for complete debug sequence
                data_str = received_data.decode('ascii', errors='ignore')
                if 'DBG:' in data_str:
                    print()
                    print("✓ Debug sequence detected!")

                    # Find the debug sequence
                    dbg_start = data_str.find('DBG:')
                    if dbg_start >= 0:
                        debug_part = data_str[dbg_start:]
                        print(f"Debug message: '{debug_part.strip()}'")

                        # Show hex dump of the sequence
                        hex_bytes = []
                        for i in range(dbg_start, len(received_data)):
                            if i < len(received_data):
                                hex_bytes.append(f"0x{received_data[i]:02X}")

                        if hex_bytes:
                            print(f"Hex bytes: {' '.join(hex_bytes)}")

                        # Analyze the data bytes after "DBG: "
                        dbg_data_start = dbg_start + 5  # Skip "DBG: "
                        if len(received_data) > dbg_data_start:
                            data_bytes = received_data[dbg_data_start:]
                            print(f"Data portion: {' '.join(f'0x{b:02X}' for b in data_bytes)}")

                            # Check if it's the expected sequence 0x00-0x0F
                            expected = list(range(16))
                            actual = []
                            for b in data_bytes:
                                if b < 16:  # Only count bytes 0x00-0x0F
                                    actual.append(b)
                                elif b == 0x0D or b == 0x0A:  # CR/LF
                                    break

                            if actual == expected:
                                print("✓ Complete sequence 0x00-0x0F received correctly!")
                            else:
                                print(f"⚠ Expected 0x00-0x0F, got: {[f'0x{b:02X}' for b in actual]}")

                    print()
                    print("Clearing buffer, waiting for next debug sequence...")
                    print("-" * 40)
                    received_data.clear()

            # Show periodic status
            if time.time() - last_activity > 5.0:
                print(f"[{time.strftime('%H:%M:%S')}] Still listening... (press Button S2 on FPGA)")
                last_activity = time.time()

            # Brief sleep to prevent CPU spinning
            time.sleep(0.01)

    except serial.SerialException as e:
        print(f"Serial port error: {e}")
        return False
    except KeyboardInterrupt:
        print()
        print("Monitor stopped by user")
        return True
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()

def main():
    if len(sys.argv) > 1:
        port = sys.argv[1]
    else:
        port = '/dev/ttyUSB0'

    if len(sys.argv) > 2:
        baudrate = int(sys.argv[2])
    else:
        baudrate = 115200

    success = monitor_debug_output(port, baudrate)
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())