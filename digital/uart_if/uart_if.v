// UART interface for register bank access
// Compatible with I2C interface - same register bank signals
// Author: Claude Code
// Protocol: Register read/write with block operations over UART
// Format:
//   Single Write: 'W' + address_byte + data_byte
//   Single Read:  'R' + address_byte → responds with data_byte
//   Block Write:  'B' + start_address + length + data0 + data1 + ... + dataN
//   Block Read:   'b' + start_address + length → responds with data0 + data1 + ... + dataN

module uart_if (
    input clk,
    input resetb,
    input uart_rx,
    output uart_tx,
    output [7:0] address,
    output [7:0] data_write_to_reg,
    input [7:0] data_read_from_reg,
    output reg_en,
    output write_en,
    output [1:0] streamSt_mon,
    // Debug interface
    input debug_send,
    input [7:0] debug_data,
    output [7:0] debug_out,
    output [1:0] rx_state_mon,
    output [1:0] proto_state_mon,
    output [1:0] debug_rx_state,

    output debug_start_detected,
    output debug_rx_data_valid
);

// UART parameters
parameter CLK_FREQ = 27000000;  // 27 MHz system clock
parameter BAUD_RATE = 115200;   // Standard baud rate
parameter BIT_TIMER = CLK_FREQ / BAUD_RATE;  // ~234 for 27MHz/115200

// UART receiver
reg [15:0] rx_clk_divider;
reg [3:0] rx_bit_count;
reg [7:0] rx_data_reg /* synthesis keep */;
reg rx_data_valid /* synthesis keep */;
reg [1:0] rx_state;
reg [7:0] rx_shift_reg /* synthesis keep */;

// UART RX synchronizer (critical for async signals)
reg uart_rx_sync1, uart_rx_sync2;
wire uart_rx_synced;

// UART transmitter
reg [15:0] tx_clk_divider;
reg [3:0] tx_bit_count;
reg [7:0] tx_data_reg;
reg tx_start;
reg tx_busy;
reg [1:0] tx_state;
reg [7:0] tx_shift_reg;
reg tx_reg;

// Protocol state machine
reg [3:0] proto_state /* synthesis keep */;
reg [7:0] cmd_reg;
reg [7:0] addr_reg;
reg [7:0] data_reg;
reg [7:0] length_reg;
reg [7:0] block_counter;
reg [7:0] current_addr;
reg write_enable;
reg reg_enable;
reg [7:0] tx_queue [0:255];  // Buffer for block read responses
reg [7:0] tx_queue_write_ptr;
reg [7:0] tx_queue_read_ptr;
reg tx_queue_empty;
reg block_read_active;

// State definitions
localparam RX_IDLE = 2'b00;
localparam RX_START = 2'b01;
localparam RX_DATA = 2'b10;
localparam RX_STOP = 2'b11;

localparam TX_IDLE = 2'b00;
localparam TX_START = 2'b01;
localparam TX_DATA = 2'b10;
localparam TX_STOP = 2'b11;

localparam PROTO_IDLE = 4'b0000;
localparam PROTO_ADDR = 4'b0001;
localparam PROTO_DATA = 4'b0010;
localparam PROTO_RESPOND = 4'b0011;
localparam PROTO_BLOCK_LENGTH = 4'b0100;
localparam PROTO_BLOCK_WRITE = 4'b0101;
localparam PROTO_BLOCK_READ_START = 4'b0110;
localparam PROTO_BLOCK_READ_WAIT = 4'b0111;
localparam PROTO_BLOCK_READ_SEND = 4'b1000;


assign uart_tx = tx_reg;
assign address = current_addr;
assign data_write_to_reg = data_reg;
assign write_en = write_enable;
assign reg_en = reg_enable;
assign streamSt_mon = {current_addr[0], write_enable};

// TX queue management
assign tx_queue_empty = (tx_queue_write_ptr == tx_queue_read_ptr) && !block_read_active;

// Synchronized UART RX
assign uart_rx_synced = uart_rx_sync2;

//===========================================
// UART Receiver
//===========================================
// Synchronizer for UART RX
always @(posedge clk) begin
    if (!resetb) begin
        uart_rx_sync1 <= 1;
        uart_rx_sync2 <= 1;
    end else begin
        uart_rx_sync1 <= uart_rx;
        uart_rx_sync2 <= uart_rx_sync1;
    end
end

always @(posedge clk) begin
    if (!resetb) begin
        rx_clk_divider <= 0;
        rx_bit_count <= 0;
        rx_data_reg <= 0;
        rx_data_valid <= 0;
        rx_state <= RX_IDLE;
        rx_shift_reg <= 0;
    end else begin
        rx_data_valid <= 0;

        case (rx_state)
            RX_IDLE: begin
                rx_clk_divider <= 0;
                rx_bit_count <= 0;
                if (!uart_rx_synced) begin  // Start bit detected
                    rx_state <= RX_START;
                    rx_clk_divider <= BIT_TIMER / 2;  // Sample at middle of bit
                end
            end

            RX_START: begin
                if (rx_clk_divider == 0) begin
                    rx_clk_divider <= BIT_TIMER;
                    if (!uart_rx_synced) begin  // Valid start bit
                        rx_state <= RX_DATA;
                        rx_shift_reg <= 0;
                        rx_bit_count <= 0;
                    end else begin  // False start
                        rx_state <= RX_IDLE;
                    end
                end else begin
                    rx_clk_divider <= rx_clk_divider - 1;
                end
            end

            RX_DATA: begin
                if (rx_clk_divider == 0) begin
                    rx_clk_divider <= BIT_TIMER;
                    rx_shift_reg <= {uart_rx_synced, rx_shift_reg[7:1]};  // LSB first
                    rx_bit_count <= rx_bit_count + 1;
                    if (rx_bit_count == 7) begin
                        rx_state <= RX_STOP;
                    end
                end else begin
                    rx_clk_divider <= rx_clk_divider - 1;
                end
            end

            RX_STOP: begin
                if (rx_clk_divider == 0) begin
                    rx_state <= RX_IDLE;
                    // Temporarily bypass stop bit check for debugging
                    rx_data_reg <= rx_shift_reg;
                    rx_data_valid <= 1;
                end 
                else begin
                    rx_clk_divider <= rx_clk_divider - 1;
                end
            end
        endcase
    end
end

//===========================================
// UART Transmitter with Queue Support
//===========================================
always @(posedge clk) begin
    if (!resetb) begin
        tx_clk_divider <= 0;
        tx_bit_count <= 0;
        tx_data_reg <= 0;
        tx_start <= 0;
        tx_busy <= 0;
        tx_state <= TX_IDLE;
        tx_shift_reg <= 0;
        tx_reg <= 1;  // Idle high
        tx_queue_read_ptr <= 0;
    end else begin
        case (tx_state)
            TX_IDLE: begin
                tx_reg <= 1;  // Idle high
                tx_busy <= 0;

                // Check for debug data first (higher priority)
                if (debug_send && !tx_start) begin
                    tx_data_reg <= debug_data;
                    tx_start <= 1;
                end
                // Then check for queued data to send
                else if (!tx_queue_empty && !tx_start) begin
                    tx_data_reg <= tx_queue[tx_queue_read_ptr];
                    tx_queue_read_ptr <= tx_queue_read_ptr + 1;
                    tx_start <= 1;
                end

                if (tx_start) begin
                    tx_busy <= 1;
                    tx_state <= TX_START;
                    tx_clk_divider <= BIT_TIMER;
                    tx_shift_reg <= tx_data_reg;
                    tx_bit_count <= 0;
                end
            end

            TX_START: begin
                tx_reg <= 0;  // Start bit
                if (tx_clk_divider == 0) begin
                    tx_clk_divider <= BIT_TIMER;
                    tx_state <= TX_DATA;
                end else begin
                    tx_clk_divider <= tx_clk_divider - 1;
                end
            end

            TX_DATA: begin
                tx_reg <= tx_shift_reg[0];  // LSB first
                if (tx_clk_divider == 0) begin
                    tx_clk_divider <= BIT_TIMER;
                    tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};
                    tx_bit_count <= tx_bit_count + 1;
                    if (tx_bit_count == 7) begin
                        tx_state <= TX_STOP;
                    end
                end else begin
                    tx_clk_divider <= tx_clk_divider - 1;
                end
            end

            TX_STOP: begin
                tx_reg <= 1;  // Stop bit
                if (tx_clk_divider == 0) begin
                    tx_state <= TX_IDLE;
                end else begin
                    tx_clk_divider <= tx_clk_divider - 1;
                end
            end
        endcase

        // Clear tx_start after one clock
        if (tx_start) begin
            tx_start <= 0;
        end
    end
end

//===========================================
// Protocol Handler with Block Operations
//===========================================
always @(posedge clk) begin
    if (!resetb) begin
        proto_state <= PROTO_IDLE;
        cmd_reg <= 0;
        addr_reg <= 0;
        data_reg <= 0;
        length_reg <= 0;
        block_counter <= 0;
        current_addr <= 0;
        write_enable <= 0;
        reg_enable <= 0;
        tx_queue_write_ptr <= 0;
        block_read_active <= 0;
    end else begin
        write_enable <= 0;
        reg_enable <= 0;

        if (rx_data_valid) begin
            case (proto_state)
                PROTO_IDLE: begin
                    cmd_reg <= rx_data_reg;
                    case (rx_data_reg)
                        8'h57, 8'h77: begin  // 'W' or 'w' - Single write
                            proto_state <= PROTO_ADDR;
                        end
                        8'h52, 8'h72: begin  // 'R' or 'r' - Single read
                            proto_state <= PROTO_ADDR;
                        end
                        8'h42: begin  // 'B' - Block write
                            proto_state <= PROTO_ADDR;
                        end
                        8'h62: begin  // 'b' - Block read
                            proto_state <= PROTO_ADDR;
                        end
                        default: proto_state <= PROTO_IDLE;
                    endcase
                end

                PROTO_ADDR: begin
                    addr_reg     <= rx_data_reg;
                    current_addr <= rx_data_reg;
                    case (cmd_reg)  // Use registered cmd_reg
                        8'h57, 8'h77: begin  // Single write
                            proto_state <= PROTO_DATA;
                        end
                        8'h52, 8'h72: begin  // Single read
                            proto_state <= PROTO_RESPOND;
                            reg_enable <= 1;
                        end
                        8'h42, 8'h62: begin  // Block operations
                            proto_state <= PROTO_BLOCK_LENGTH;
                        end
                        default: proto_state <= PROTO_IDLE;
                    endcase
                end

                PROTO_BLOCK_LENGTH: begin
                    length_reg <= rx_data_reg;
                    block_counter <= 0;
                    case (cmd_reg)
                        8'h42: begin  // Block write
                            proto_state <= PROTO_BLOCK_WRITE;
                        end
                        8'h62: begin  // Block read
                            proto_state <= PROTO_BLOCK_READ_START;
                            tx_queue_write_ptr <= 0;
                            block_read_active <= 1;
                        end
                        default: proto_state <= PROTO_IDLE;
                    endcase
                end

                PROTO_BLOCK_WRITE: begin
                    data_reg <= rx_data_reg;
                    current_addr <= addr_reg + block_counter;
                    write_enable <= 1;
                    reg_enable <= 1;
                    block_counter <= block_counter + 1;

                    if (block_counter >= length_reg - 1) begin
                        proto_state <= PROTO_IDLE;
                    end
                end

                PROTO_DATA: begin
                    data_reg <= rx_data_reg;
                    current_addr <= addr_reg;
                    write_enable <= 1;
                    reg_enable <= 1;
                    proto_state <= PROTO_IDLE;
                end

                default: proto_state <= PROTO_IDLE;
            endcase
        end 
        else begin // not rx_data_valid
            case (proto_state)
                PROTO_RESPOND: begin
                    // Single read response
                    if (!tx_busy) begin
                        tx_queue[tx_queue_write_ptr] <= data_read_from_reg;
                        tx_queue_write_ptr <= tx_queue_write_ptr + 1;
                        proto_state <= PROTO_IDLE;
                    end
                end

                PROTO_BLOCK_READ_START: begin
                    current_addr <= addr_reg + block_counter;
                    reg_enable <= 1;
                    proto_state <= PROTO_BLOCK_READ_WAIT;
                end

                PROTO_BLOCK_READ_WAIT: begin
                    // Wait one cycle for register data
                    proto_state <= PROTO_BLOCK_READ_SEND;
                end

                PROTO_BLOCK_READ_SEND: begin
                    // Queue the read data
                    tx_queue[tx_queue_write_ptr] <= data_read_from_reg;
                    tx_queue_write_ptr <= tx_queue_write_ptr + 1;
                    block_counter <= block_counter + 1;

                    if (block_counter >= length_reg - 1) begin
                        block_read_active <= 0;
                        proto_state <= PROTO_IDLE;
                    end else begin
                        proto_state <= PROTO_BLOCK_READ_START;
                    end
                end
                // For all other states, just wait.
                default: ;
            endcase
        end
    end
end
assign debug_out = rx_data_reg | rx_shift_reg | {7'b0, rx_data_valid}; 
assign rx_state_mon     = rx_state[1:0];
assign proto_state_mon  = proto_state[1:0]; 
assign debug_rx_state = rx_state;
assign debug_start_detected = (rx_state == RX_IDLE && !uart_rx_synced);
assign debug_rx_data_valid  = rx_data_valid ; 
endmodule