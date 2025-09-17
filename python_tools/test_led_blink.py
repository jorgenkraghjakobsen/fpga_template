#!/usr/bin/env python3
"""
Test script to verify FPGA is working by observing LED changes
We'll try to write to the debug LED register and see if anything changes
"""

import time

def test_led_pattern():
    """Test if we can control LEDs to verify FPGA is working"""

    print("FPGA LED Test")
    print("=============")
    print("This test tries to write to the debug LED register.")
    print("If the FPGA is working, you should see LED changes on the board.")
    print()

    # Import our UART interface
    try:
        from fpga_uart_interface import FPGAUartInterface

        # Try to connect
        fpga = FPGAUartInterface(port='/dev/ttyUSB1')  # Use the UART interface

        if not fpga.connect():
            print("Could not connect to UART interface")
            return

        print("Connected to UART interface")
        print("Now trying to control debug LEDs...")
        print("Look at the FPGA board for LED changes!")
        print()

        # Test different LED patterns
        patterns = [
            (0x00, "All LEDs off"),
            (0x3F, "All LEDs on"),
            (0x01, "LED 0 only"),
            (0x02, "LED 1 only"),
            (0x04, "LED 2 only"),
            (0x08, "LED 3 only"),
            (0x10, "LED 4 only"),
            (0x20, "LED 5 only"),
            (0x15, "LEDs 0,2,4 (pattern 1)"),
            (0x2A, "LEDs 1,3,5 (pattern 2)")
        ]

        for pattern, description in patterns:
            print(f"Setting LEDs to 0x{pattern:02X} - {description}")

            # Try to write to debug LED register (address 0x02)
            success = fpga.write_register(0x02, pattern)

            if success:
                print("  Write command sent")
            else:
                print("  Write command failed")

            # Wait for user to observe
            print("  Look at the board LEDs now!")
            time.sleep(2.0)

        # Final test - blinking pattern
        print("\nFinal test: Blinking pattern...")
        for i in range(10):
            # Alternate between two patterns
            pattern = 0x2A if (i % 2) == 0 else 0x15
            fpga.write_register(0x02, pattern)
            print(f"  Blink {i+1}/10: Pattern 0x{pattern:02X}")
            time.sleep(0.5)

        # Turn off LEDs
        fpga.write_register(0x02, 0x00)
        print("LEDs turned off")

        fpga.disconnect()

    except ImportError:
        print("Could not import fpga_uart_interface module")
        print("Make sure fpga_uart_interface.py is in the same directory")
    except Exception as e:
        print(f"Error during LED test: {e}")

if __name__ == "__main__":
    test_led_pattern()