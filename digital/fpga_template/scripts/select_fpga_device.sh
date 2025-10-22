#!/bin/bash
# FPGA Device Selection Script
# Scans for connected FPGA boards and allows interactive selection using arrow keys

set -euo pipefail

# Color codes for prettier output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# File to store selected device
DEVICE_FILE=".fpga_device"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICE_FILE_PATH="$PROJECT_DIR/$DEVICE_FILE"

# Temporary file for storing device list
TEMP_DEVICES="/tmp/fpga_devices_$$.txt"

cleanup() {
    rm -f "$TEMP_DEVICES"
}
trap cleanup EXIT

echo -e "${CYAN}${BOLD}=== FPGA Device Selection ===${NC}\n"

# Scan for USB devices using openFPGALoader
echo -e "${YELLOW}Scanning for connected FPGA boards...${NC}"
if ! USB_OUTPUT=$(openFPGALoader --scan-usb 2>&1); then
    echo -e "${RED}Error: Failed to scan USB devices${NC}"
    exit 1
fi

# Parse the output to extract FPGA devices
# Format: Bus device vid:pid probe type manufacturer serial product
# Example: 003 027 0x0403:0x6010 FTDI2232 SIPEED 2023030621 20K's FRIEND

# Skip header lines and extract SIPEED/FTDI devices
echo "$USB_OUTPUT" | grep -E "SIPEED|FTDI" | grep "0x0403:0x6010" > "$TEMP_DEVICES" || true

# Check if any devices were found
DEVICE_COUNT=$(wc -l < "$TEMP_DEVICES" || echo "0")

if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${RED}No FPGA devices found!${NC}"
    echo -e "${YELLOW}Please ensure your Tang Nano board is connected via USB.${NC}"
    exit 1
fi

echo -e "${GREEN}Found $DEVICE_COUNT FPGA device(s)${NC}\n"

# Parse devices into arrays
declare -a SERIALS
declare -a PRODUCTS
declare -a BUS_DEVICES

idx=0
while IFS= read -r line; do
    # Parse each field
    # Format: Bus device vid:pid probe_type manufacturer serial product...
    BUS=$(echo "$line" | awk '{print $1}')
    DEVICE=$(echo "$line" | awk '{print $2}')

    # Extract everything from field 6 onward, then split serial/product intelligently
    # Serial comes after SIPEED, product typically starts with capital letter after serial
    REST=$(echo "$line" | awk '{for(i=6;i<=NF;i++) printf "%s ", $i}')

    # For Tang Nano boards:
    # - 20K: serial="2023030621", product="20K's FRIEND"
    # - 9K: serial="FactoryAIOT Pro", product="JTAG Debugger"
    # Strategy: Look for common product patterns, everything before is serial
    if echo "$REST" | grep -q "20K"; then
        SERIAL=$(echo "$REST" | sed 's/20K.*//' | sed 's/ *$//')
        PRODUCT=$(echo "$REST" | grep -o '20K.*' | sed 's/ *$//')
    elif echo "$REST" | grep -q "JTAG"; then
        SERIAL=$(echo "$REST" | sed 's/JTAG.*//' | sed 's/ *$//')
        PRODUCT=$(echo "$REST" | grep -o 'JTAG.*' | sed 's/ *$//')
    elif echo "$REST" | grep -q "9K"; then
        SERIAL=$(echo "$REST" | sed 's/9K.*//' | sed 's/ *$//')
        PRODUCT=$(echo "$REST" | grep -o '9K.*' | sed 's/ *$//')
    else
        # Fallback: use first word as serial, rest as product
        SERIAL=$(echo "$REST" | awk '{print $1}')
        PRODUCT=$(echo "$REST" | awk '{for(i=2;i<=NF;i++) printf "%s ", $i}' | sed 's/ *$//')
    fi

    SERIALS[$idx]="$SERIAL"
    PRODUCTS[$idx]="$PRODUCT"
    BUS_DEVICES[$idx]="$BUS:$DEVICE"

    idx=$((idx + 1))
done < "$TEMP_DEVICES"

# If only one device, auto-select it
if [ "$DEVICE_COUNT" -eq 1 ]; then
    echo -e "${GREEN}Only one device found - auto-selecting:${NC}"
    echo -e "  ${BOLD}${PRODUCTS[0]}${NC} (Serial: ${SERIALS[0]})"

    # Detect board type
    BOARD_TYPE="tangnano20k"  # Default
    if [[ "${PRODUCTS[0]}" == *"20K"* ]] || [[ "${PRODUCTS[0]}" == *"20k"* ]]; then
        BOARD_TYPE="tangnano20k"
    elif [[ "${PRODUCTS[0]}" == *"9K"* ]] || [[ "${PRODUCTS[0]}" == *"9k"* ]]; then
        BOARD_TYPE="tangnano9k"
    elif [[ "${SERIALS[0]}" == "FactoryAIOT"* ]] || [[ "${PRODUCTS[0]}" == *"JTAG"* ]]; then
        BOARD_TYPE="tangnano9k"
    fi

    echo -e "  Board Type: ${BOLD}${BOARD_TYPE}${NC}"

    # Save to file
    cat > "$DEVICE_FILE_PATH" <<EOF
# Auto-generated FPGA device selection
# Generated: $(date)
# Device: ${PRODUCTS[0]}
FPGA_SERIAL=${SERIALS[0]}
FPGA_BOARD=${BOARD_TYPE}
EOF

    echo -e "\n${GREEN}✓ Device saved to $DEVICE_FILE${NC}"
    echo -e "${CYAN}You can now use 'make flash' and 'make load'${NC}"
    exit 0
fi

# Multiple devices - use numbered selection (simple and reliable)
echo -e "${BOLD}Select FPGA device:${NC}\n"

for i in "${!SERIALS[@]}"; do
    echo -e "  [$((i+1))] ${PRODUCTS[$i]} (Serial: ${SERIALS[$i]})"
done

echo -e "\n${YELLOW}Enter device number (1-$DEVICE_COUNT) or 'q' to cancel:${NC} "
read -r selection

# Check for quit
if [[ "$selection" == "q" ]] || [[ "$selection" == "Q" ]]; then
    echo -e "${YELLOW}Selection cancelled${NC}"
    exit 0
fi

# Validate input
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "$DEVICE_COUNT" ]; then
    echo -e "${RED}Invalid selection: must be a number between 1 and $DEVICE_COUNT${NC}"
    exit 1
fi

SELECTED=$((selection - 1))

# Confirm selection
if [ -t 0 ] && [ -t 1 ]; then
    clear
fi
echo -e "\n${CYAN}${BOLD}=== FPGA Device Selection ===${NC}\n"
echo -e "${GREEN}Selected device:${NC}"
echo -e "  ${BOLD}${PRODUCTS[$SELECTED]}${NC}"
echo -e "  Serial: ${SERIALS[$SELECTED]}"
echo -e "  Bus/Device: ${BUS_DEVICES[$SELECTED]}"

# Detect board type from product name
BOARD_TYPE="tangnano20k"  # Default
if [[ "${PRODUCTS[$SELECTED]}" == *"20K"* ]] || [[ "${PRODUCTS[$SELECTED]}" == *"20k"* ]]; then
    BOARD_TYPE="tangnano20k"
elif [[ "${PRODUCTS[$SELECTED]}" == *"9K"* ]] || [[ "${PRODUCTS[$SELECTED]}" == *"9k"* ]]; then
    BOARD_TYPE="tangnano9k"
elif [[ "${SERIALS[$SELECTED]}" == "FactoryAIOT"* ]] || [[ "${PRODUCTS[$SELECTED]}" == *"JTAG"* ]]; then
    # Tang Nano 9K often shows up as "Pro JTAG Debugger" or "FactoryAIOT"
    BOARD_TYPE="tangnano9k"
fi

echo -e "  Board Type: ${BOLD}${BOARD_TYPE}${NC}"

# Save to file
cat > "$DEVICE_FILE_PATH" <<EOF
# Auto-generated FPGA device selection
# Generated: $(date)
# Device: ${PRODUCTS[$SELECTED]}
# Serial: ${SERIALS[$SELECTED]}
FPGA_SERIAL=${SERIALS[$SELECTED]}
FPGA_BOARD=${BOARD_TYPE}
EOF

echo -e "\n${GREEN}✓ Device selection saved to $DEVICE_FILE${NC}"
echo -e "${CYAN}You can now use 'make flash' and 'make load'${NC}"
echo -e "${YELLOW}Tip: Use 'make show-device' to see current selection${NC}"

exit 0
