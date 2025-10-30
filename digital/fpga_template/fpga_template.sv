// Boiler plate for a midsize fpga project 
// 

import fpga_template_pkg::*; 

module fpga_template_top
    (
    input   clk,
    //---I2C----------- (Disabled - pins used for UART monitors)
    //input   i2c_scl,
    //inout   i2c_sda,
    
    //---UART----------
    input   uart_rx,    // Pin 70 - RX from USB/FTDI
    output  uart_tx,    // Pin 69 - TX to USB/FTDI
    
    //---PWM-----------
    output pwm_out,
    //---Debug---------
    output  [5:0] debug_led,
    
    input   btn_s1_resetb,     // Button 1 input
    input   btn_s2            // Button 2 input
    );

assign debug_led = ~sys_cfg.debug_led; // Inverted for Tang Nano 20K active-LOW LEDs

//--------------------------------------------------------------------------------------------------------
// Clock and reset
//--------------------------------------------------------------------------------------------------------

// Reset button behavior differs between boards:
// Tang Nano 9K:  Button pulls LOW when pressed  (active LOW)
// Tang Nano 20K: Button pulls HIGH when pressed (active HIGH)
wire resetb;
`ifdef TANGNANO20K
    assign resetb = ~btn_s1_resetb;   // 20K: button HIGH when pressed
`elsif TANGNANO9K
    assign resetb = btn_s1_resetb;    // 9K: button LOW when pressed, invert to get active high reset
`else
    assign resetb = ~btn_s1_resetb;   // Default to 20K behavior
`endif 

// Direct clock insert PLL here when needed

//--------------------------------------------------------------------------------------------------------
// Register bank structs  
//--------------------------------------------------------------------------------------------------------
rb_sys_cfg_wire_t sys_cfg;
rb_dsp_cfg_wire_t dsp_cfg;

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

//--------------------------------------------------------------------------------------------------------
// I2C interface - DISABLED (pins used for UART monitors)
//--------------------------------------------------------------------------------------------------------
/*i2c_if i2c_inst (
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
);*/

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
    .streamSt_mon       (uart_streamSt_mon)
);
//    // Debug interface
//    .debug_send         (debug_uart_send),
//    .debug_data         (debug_uart_data),
//    .debug_out          (uart_debug_out),
//    .debug_rx_data_valid (debug_rx_data_valid),
//    .rx_state_mon       (),
//    .proto_state_mon    (),
//    .tx_state_mon       (uart_tx_state_mon)  // Critical: prevents TX optimization
//);


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
    .reg_en             (rb_reg_en),
    .write_en           (rb_write_en),
    .sys_cfg            (sys_cfg),
    .dsp_cfg            (dsp_cfg)
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
// Your block here
//--------------------------------------------------------------------------------------------------------

endmodule