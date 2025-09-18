// Boiler plate for a midsize fpga project 
// 

import fpga_template_pkg::*; 

module fpga_template_top
    (
    input   clk,
    //---I2C-----------
    input   i2c_scl,
    inout   i2c_sda,
    //---UART----------
    input   uart_rx,    // Pin 18 - RX from USB/FTDI internal
    output  uart_tx,    // Pin 17 - TX to USB/FTDI internal 
    output  uart_tx_mon, 
    output  uart_rx_mon,
    output  [1:0] rx_state_mon,
    output  [3:0] proto_state_mon, 
    
    //---PWM-----------
    output pwm_out,
    //---Debug---------
    output  [5:0] debug_led_pin,
    input   btn_s1_resetb,     // Button 1 input
    input   btn_s2,           // Button 2 input
    //---More Ground---
    output  gnd0            // Ground output with cranked up power
    );
    
    
assign uart_rx_mon = uart_rx; 
wire debug_rx_data_valid; 
assign uart_tx_mon = uart_tx; 

assign gnd0 = 1'b0;
assign debug_led_pin = sys_cfg.debug_led;

//--------------------------------------------------------------------------------------------------------
// Clock and reset   
//-------------------------------------------------------------------------------------------------------- 

wire resetb; 
assign resetb = btn_s1_resetb; 

// Direct clock insert PLL here when needed

//--------------------------------------------------------------------------------------------------------
// Register bank structs  
//-------------------------------------------------------------------------------------------------------- 
rb_sys_cfg_wire_t sys_cfg;
assign sys_cfg.monitor_flag = 1'b0;

//--------------------------------------------------------------------------------------------------------
// Interface signals (shared between I2C and UART)
//--------------------------------------------------------------------------------------------------------
wire [7:0] rb_address;
wire [7:0] rb_data_write_to_reg;
wire [7:0] rb_data_read_from_reg;
wire rb_reg_en;
wire rb_write_en;
wire [1:0] rb_streamSt_mon;

// I2C interface signals
wire [7:0] i2c_address;
wire [7:0] i2c_data_write_to_reg;
wire i2c_reg_en;
wire i2c_write_en;
wire [1:0] i2c_streamSt_mon;

// UART interface signals
wire [7:0] uart_address;
wire [7:0] uart_data_write_to_reg;
wire uart_reg_en;
wire uart_write_en;
wire [1:0] uart_streamSt_mon;
wire [7:0] uart_debug_out;

// Debug UART signals
assign debug_uart_send = debug_send;
assign debug_uart_data = debug_byte;

//--------------------------------------------------------------------------------------------------------
// I2C interface
//--------------------------------------------------------------------------------------------------------
i2c_if i2c_inst (
    .clk                (clk),
    .resetb             (resetb),
    .sda                (i2c_sda),
    .scl                (i2c_scl),
    .address            (i2c_address),
    .data_write_to_reg  (i2c_data_write_to_reg),
    .data_read_from_reg (rb_data_read_from_reg),
    .reg_en             (i2c_reg_en),
    .write_en           (i2c_write_en),
    .streamSt_mon       (i2c_streamSt_mon)
);

//--------------------------------------------------------------------------------------------------------
// UART interface
//--------------------------------------------------------------------------------------------------------
uart_if uart_inst (
    .clk                (clk),
    .resetb             (resetb),
    .uart_rx            (uart_rx),
    .uart_tx            (uart_tx),

    .address            (uart_address),
    .data_write_to_reg  (uart_data_write_to_reg),
    .data_read_from_reg (rb_data_read_from_reg),
    .reg_en             (uart_reg_en),
    .write_en           (uart_write_en),
    .streamSt_mon       (uart_streamSt_mon),
    // Debug interface
    .debug_send         (1'b0), //0debug_uart_send),
    .debug_data         (debug_uart_data),
    .debug_out          (uart_debug_out),
    .debug_rx_data_valid (debug_rx_data_valid),
    .rx_state_mon       (rx_state_mon),
    .proto_state_mon    (proto_state_mon) 
);

//--------------------------------------------------------------------------------------------------------
// Interface arbitration (OR together since only one active at a time)
//--------------------------------------------------------------------------------------------------------
//assign rb_address = i2c_address | uart_address;
//assign rb_data_write_to_reg = i2c_data_write_to_reg | uart_data_write_to_reg;
//assign rb_reg_en = i2c_reg_en | uart_reg_en;
//assign rb_write_en = i2c_write_en | uart_write_en;

assign rb_address           = uart_address;
assign rb_data_write_to_reg = uart_data_write_to_reg;
assign rb_reg_en            = uart_reg_en;
assign rb_write_en          = uart_write_en;
assign rb_streamSt_mon      = uart_streamSt_mon; 
//--------------------------------------------------------------------------------------------------------
// Register bank        
//-------------------------------------------------------------------------------------------------------- 
rb_fpga_template rb_fpga_template_inst (
    .clk                (clk),
    .resetb             (resetb),
    .address            (rb_address),
    .data_write_in      (rb_data_write_to_reg), 
    .data_read_out      (rb_data_read_from_reg),
    .write_en           (rb_write_en),
    .sys_cfg            (sys_cfg)
    ); 

//-------------------------------------------------------------------------------------------------------- 
// Your block here                
//-------------------------------------------------------------------------------------------------------- 
pwm pwm_inst (
    .clock_in(clk),
    .reset(!resetb),
    .duty_cycle(sys_cfg.pwm_duty),  // 0x80 -> 50% 
    .pwm_out(pwm_out)
); 
         
//--------------------------------------------------------------------------------------------------------
// Debug functionality - Button S2 triggers UART debug sequence
//--------------------------------------------------------------------------------------------------------

// Button debouncing and edge detection for btn_s2
reg [2:0] btn_s2_sync;
reg btn_s2_prev;
wire btn_s2_edge;

always @(posedge clk) begin
    if (!resetb) begin
        btn_s2_sync <= 3'b000;
        btn_s2_prev <= 1'b0;
    end else begin
        btn_s2_sync <= {btn_s2_sync[1:0], btn_s2};
        btn_s2_prev <= btn_s2_sync[2];
    end
end

assign btn_s2_edge = btn_s2_sync[2] & ~btn_s2_prev;  // Rising edge

// Debug sequence generator
reg [3:0] debug_state;
reg [15:0] debug_counter;
reg [7:0] debug_byte;
reg debug_send;
reg debug_active;

localparam DEBUG_IDLE = 4'h0;
localparam DEBUG_START = 4'h1;
localparam DEBUG_SEND = 4'h2;
localparam DEBUG_WAIT = 4'h3;

// Debug sequence: "DBG:" followed by incrementing numbers 0x00 to 0x0F
always @(posedge clk) begin
    if (!resetb) begin
        //debug_led_pin <= 6'b111111;
        debug_state <= DEBUG_IDLE;
        debug_counter <= 16'h0000;
        debug_byte <= 8'h00;
        debug_send <= 1'b0;
        debug_active <= 1'b0;
    end else begin
        debug_send <= 1'b0;  // Default

        case (debug_state)
            DEBUG_IDLE: begin
                if (!btn_s2_edge) begin
                    //debug_led_pin <= 6'b000000;
                    debug_state <= DEBUG_START;
                    debug_counter <= 16'h0000;
                    debug_active <= 1'b1;
                end
            end

            DEBUG_START: begin
                if (debug_counter < 16'h1000) begin  // Prevent timeout
                    debug_counter <= debug_counter + 1;

                    // Send debug sequence with delays between bytes
                    if (debug_counter[15:8] == 8'h00) begin  // First part - send bytes
                        case (debug_counter[7:0])
                            8'h10: begin debug_byte <= 8'h44; debug_send <= 1'b1; end  // 'D'
                            8'h20: begin debug_byte <= 8'h42; debug_send <= 1'b1; end  // 'B'
                            8'h30: begin debug_byte <= 8'h47; debug_send <= 1'b1; end  // 'G'
                            8'h40: begin debug_byte <= 8'h3A; debug_send <= 1'b1; end  // ':'
                            8'h50: begin debug_byte <= 8'h20; debug_send <= 1'b1; end  // ' '
                            8'h60: begin debug_byte <= 8'h00; debug_send <= 1'b1; end  // 0x00
                            8'h70: begin debug_byte <= 8'h01; debug_send <= 1'b1; end  // 0x01
                            8'h80: begin debug_byte <= 8'h02; debug_send <= 1'b1; end  // 0x02
                            8'h90: begin debug_byte <= 8'h03; debug_send <= 1'b1; end  // 0x03
                            8'hA0: begin debug_byte <= 8'h04; debug_send <= 1'b1; end  // 0x04
                            8'hB0: begin debug_byte <= 8'h05; debug_send <= 1'b1; end  // 0x05
                            8'hC0: begin debug_byte <= 8'h06; debug_send <= 1'b1; end  // 0x06
                            8'hD0: begin debug_byte <= 8'h07; debug_send <= 1'b1; end  // 0x07
                            8'hE0: begin debug_byte <= 8'h08; debug_send <= 1'b1; end  // 0x08
                            8'hF0: begin debug_byte <= 8'h09; debug_send <= 1'b1; end  // 0x09
                            default: begin
                                // Do nothing, just count
                            end
                        endcase
                    end else if (debug_counter[15:8] == 8'h01) begin  // Second part
                        case (debug_counter[7:0])
                            8'h00: begin debug_byte <= 8'h0A; debug_send <= 1'b1; end  // 0x0A
                            8'h10: begin debug_byte <= 8'h0B; debug_send <= 1'b1; end  // 0x0B
                            8'h20: begin debug_byte <= 8'h0C; debug_send <= 1'b1; end  // 0x0C
                            8'h30: begin debug_byte <= 8'h0D; debug_send <= 1'b1; end  // 0x0D
                            8'h40: begin debug_byte <= 8'h0E; debug_send <= 1'b1; end  // 0x0E
                            8'h50: begin debug_byte <= 8'h0F; debug_send <= 1'b1; end  // 0x0F
                            8'h60: begin debug_byte <= 8'h0D; debug_send <= 1'b1; end  // '\r'
                            8'h70: begin debug_byte <= 8'h0A; debug_send <= 1'b1; end  // '\n'
                            8'h80: begin
                                debug_state <= DEBUG_IDLE;
                                debug_active <= 1'b0;
                            end
                            default: begin
                                // Do nothing, just count
                            end
                        endcase
                    end else begin
                        // Finished
                        debug_state <= DEBUG_IDLE;
                        debug_active <= 1'b0;
                    end
                end else begin
                    // Timeout
                    debug_state <= DEBUG_IDLE;
                    debug_active <= 1'b0;
                end
            end
        endcase
    end
end

//--------------------------------------------------------------------------------------------------------
// Your block here
//--------------------------------------------------------------------------------------------------------

endmodule