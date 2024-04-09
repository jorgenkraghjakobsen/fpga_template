//`include "./rb_paral/rb_paral_struct.svh" 
import paral_pkg::*; 

module paral_top
    ( 
    //input   reset,  
    input   clk, 
    //---i2c-----------   
    input   i2c_scl,    
    inout   i2c_sda,
    //---SPI-----------
    input   spi_adc_di,
    output  spi_adc_do,
    output  spi_adc_sck,  
    output  spi_adc_cs, 
    input   spi_esp_di, 
    output  spi_esp_do,   
    output  spi_esp_sck, 
    output  spi_esp_cs, 
    //---ADC-----------
    input   adc_drdy,
    output  adc_reset,
    output  adc_start,
    output  adc_power,
    //--ADC VCXO voltage control-------
    output pwm_out, 
    //---Debug---------
    output  [5:0] debug_led_pin,
    input   btn1_reset,     // Button 1 input   
    input   btn2,           // Button 2 input   
    output  gnd0            // Ground output adc_gnd    
    );
    
assign gnd0 = 0;
//--------------------------------------------------------------------------------------------------------
// Register bank structs  
//-------------------------------------------------------------------------------------------------------- 
rb_sys_cfg_wire_t sys_cfg;
rb_adc_cfg_wire_t adc_cfg;
rb_dsp_cfg_wire_t dsp_cfg;
//rb_debug_wire_t debug;



//SKAL LAVES OM
//--------------------------------------------------------------------------------------------------------
//PLL       
//--------------------------------------------------------------------------------------------------------
wire clkoutp;
wire clkoutd;
wire clkoutd3;
wire lock_o;

wire gw_gnd;
  
assign gw_gnd = 1'b0;    

rPLL rpll_inst(
 .CLKOUT(clkout_pll),
 .LOCK(lock_o),
 .CLKOUTP(clkoutp),     //rPLL clock output signal with phase and duty cycle adjustment 
 .CLKOUTD(clkoutd),     //Clock output signal of rPLL through SDIV, output signal of CLKOUT or CLKOUTP through SDIV divider output signal.
 .CLKOUTD3(clkoutd3),   //Clock output signal of rPLL through DIV3, output signal of CLKOUT or CLKOUTP through DIV3.
 .RESET(gw_gnd),    // Reset signal  
 .RESET_P(gw_gnd),  // Reset signal
 .CLKIN(clk),           // 27 MHz input clock from external oscillator
 .CLKFB(gw_gnd), //??????????????
 .FBDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),    //4 = FBDIV Actual Value 5
 .IDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),     //0 = IDIV Actual Value 1
 .ODSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),     //2 = ODIV Actual Value 2
 .PSDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),        //Phase dynamic adjustment
 .DUTYDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),      //Duty cycle dynamic adjustment
 .FDLY({gw_gnd,gw_gnd,gw_gnd,gw_gnd}) 
);
   
defparam rpll_inst.FCLKIN = "27";               //Reference clock frequency   
defparam rpll_inst.DYN_IDIV_SEL = "false";      //IDIV frequency division coefficient static control parameter or dynamic control signal selection.
defparam rpll_inst.IDIV_SEL = 0;                //IDIV frequency division coefficient static setting  1 Virkede
defparam rpll_inst.DYN_FBDIV_SEL = "false";     //FBDIV frequency division coefficient static control parameter or dynamic control signal selection.
defparam rpll_inst.FBDIV_SEL = 5;              //FBDIV frequency division coefficient static setting 34 Virkede
defparam rpll_inst.ODIV_SEL = 4;                //ODIV frequency division coefficient static setting 
defparam rpll_inst.PSDA_SEL = "0000";           //Phase static adjustment 
defparam rpll_inst.DYN_DA_EN = "false";         //The dynamic signal is selected as the control of phase and duty cycle adjustment.
defparam rpll_inst.DUTYDA_SEL = "1000";         //Duty cycle static adjustment     
defparam rpll_inst.CLKOUT_FT_DIR = 1'b1;        //CLKOUT trim direction setting
defparam rpll_inst.CLKOUTP_FT_DIR = 1'b1;       //CLKOUTP trim direction setting      
defparam rpll_inst.CLKOUT_DLY_STEP = 0;         //CLKOUT trim coefficient setting  
defparam rpll_inst.CLKOUTP_DLY_STEP = 0;        //CLKOUTP trim coefficient setting 
defparam rpll_inst.CLKFB_SEL ="internal";       //CLKFB source selection "external"/"internal"
defparam rpll_inst.CLKOUT_BYPASS = "false";     //Bypasses rPLL, and CLKOUT comes directly from CLKIN.
defparam rpll_inst.CLKOUTP_BYPASS = "false";    //Bypasses rPLL, and CLKOUTP comes directly from CLKIN.
defparam rpll_inst.CLKOUTD_BYPASS = "false";    //Bypasses rPLL, and CLKOUTD comes directly from CLKIN.
defparam rpll_inst.DYN_SDIV_SEL = 2;            //SDIV frequency division coefficient static setting
defparam rpll_inst.CLKOUTD_SRC = "CLKOUT";      //CLKOUTD source selection
defparam rpll_inst.CLKOUTD3_SRC = "CLKOUT";     //CLKOUTD3 source selection
defparam rpll_inst.DEVICE = "GW1NR-9";          //Device family


/*
clock_divider clock_divider_inst( 
    .clock_in(clkout_pll),     // 31.25 MHz input clock
    .clock_out(adc_clk)          // Lock signal
);*/
//TIL HER

//--------------------------------------------------------------------------------------------------------
//PWM
//--------------------------------------------------------------------------------------------------------
pwm pwm_inst (
    .clock_in(clkout_pll),
    .reset(!btn1_reset),
    .duty_cycle(sys_cfg.pwm_xvco),  // 210-> 49.9985 (0.0015)
    .pwm_out(pwm_out)
); 
//--------------------------------------------------------------------------------------------------------
// i2c  
//-------------------------------------------------------------------------------------------------------- 
wire [7:0] rb_address;
wire [7:0] rb_data_write_to_reg;
wire [7:0] rb_data_read_from_reg;
wire rb_reg_en;    
wire rb_write_en;
wire [1:0] rb_streamSt_mon;

i2c_if i2c_inst ( 
    .clk                (clk),
    .resetb             (btn1_reset),
    .sda                (i2c_sda),
    .scl                (i2c_scl),
    .address            (rb_address),
    .data_write_to_reg  (rb_data_write_to_reg), 
    .data_read_from_reg (rb_data_read_from_reg),
    .reg_en             (rb_reg_en), 
    .write_en           (rb_write_en),
    .streamSt_mon       (rb_streamSt_mon) 
    ); 
//--------------------------------------------------------------------------------------------------------
// Register bank        
//-------------------------------------------------------------------------------------------------------- 
rb_paral rb_paral_inst (
    .clk                (clk),
    .resetb             (btn1_reset),
    .address            (rb_address),
    .data_write_in      (rb_data_write_to_reg), 
    .data_read_out      (rb_data_read_from_reg),
    //.reg_en           (rb_reg_en),
    .write_en           (rb_write_en),
    .adc_cfg            (adc_cfg),
    .sys_cfg            (sys_cfg), 
    .dsp_cfg            (dsp_cfg)
    //.debug              (debug) 
    ); 
//-------------------------------------------------------------------------------------------------------- 
// ADC interface for SPI (ADS1298)               
//-------------------------------------------------------------------------------------------------------- 
adc_if adc_if_inst ( 
    .clk                (clk),
    .resetb             (btn1_reset),
    .spi_adc_di         (spi_adc_di),
    .spi_adc_do         (spi_adc_do),
    .spi_adc_sck        (spi_adc_sck),
    .spi_adc_cs         (spi_adc_cs),
    .adc_drdy           (adc_drdy), 
    .adc_reset          (adc_reset),
    .adc_start          (adc_start),
    .adc_power          (adc_power),
    //.debug_led          (debug_led_pin),
    .ecg_data_out       (ecg_data_out),
    .ram_write_addr     (ram_write_addr),
    .ram_write_ce       (ram_write_ce),
    .adc_cfg            (adc_cfg),
    .sys_cfg            (sys_cfg)
    );
//-------------------------------------------------------------------------------------------------------- 
// DSP interface for ECG data                 
//-------------------------------------------------------------------------------------------------------- 

dsp_if dsp_if_inst (
    .clk                (clk),
    .resetb             (btn1_reset),
    .raw_ecg_in         (ram_ecg_out),
    //.dsp_read_addr      (read_addr),
    .filt_ecg_out       (filt_ecg_data_out),
    .dsp_cfg            (dsp_cfg),
    .sys_cfg            (sys_cfg) 
    );
//--------------------------------------------------------------------------------------------------------
// ESP32 interface for SPI                              
//-------------------------------------------------------------------------------------------------------- 
esp_if esp_if_inst ( 
   .clk                 (clk),   
   .resetb              (btn1_reset),
   .spi_esp_di          (spi_esp_di),
   .spi_esp_do          (spi_esp_do),
   .spi_esp_sck         (spi_esp_sck),
   .spi_esp_cs          (spi_esp_cs), 
   .ram_read_addr       (read_addr),
   .filt_ecg_in         (filt_ecg_data_out),
   //.debug_led           (debug_led_pin),
   .sys_cfg             (sys_cfg)
   ); 
//--------------------------------------------------------------------------------------------------------
//SDP-BRAM for RAW ECG data                    
//-------------------------------------------------------------------------------------------------------- 
reg [8:0] read_addr;
reg [8:0] ram_write_addr;
reg ram_write_ce;
wire [23:0] ecg_data_out;       //Write value to RAM
wire [23:0] filt_ecg_data_out;  //Filtered value from DSP
wire [31:0] ram_ecg_out;       //Read value from RAM
raw_ecg_ram ecg_mem(
    .clk                (clk),
    .write_clk          (clk),
    .reset              (!btn1_reset),
    .write_reset        (!btn1_reset),
    .write_ce           (ram_write_ce), //Enable RAM write, active high
    .read_ad            (read_addr),    
    .read_data          (ram_ecg_out),
    .write_ad           (ram_write_addr), // 511 * 32bits = 16.352 we have 511/9 = 56.7 samples
    .write_data         ({8'h00 ,ecg_data_out})
    );
//--------------------------------------------------------------------------------------------------------
// Debug
//--------------------------------------------------------------------------------------------------------

    //c2  c1   c1
    //0 0000 0000
//assign read_addr = {adc_cfg.CONFIG2[0], adc_cfg.CONFIG1}; // Read value from RAM
//assign adc_cfg.CH1SET = ram_ecg_out[7:0]; // Read value from RAM
//assign adc_cfg.CH2SET = ram_ecg_out[15:8]; // Read value from RAM
//assign adc_cfg.CH3SET = ram_ecg_out[23:16]; // Read value from RAM skal være read only
//assign adc_cfg.CH4SET = ram_ecg_out[31:24]; // Read value from RAM 
//assign adc_cfg.CH5SET = 8'h77; // det virker her!
assign debug_led_pin = sys_cfg.debug_led;
       
          
endmodule