module pwm(
    input clock_in,         // Input clock on FPGA
    input reset,            // Reset signal
    input [7:0] duty_cycle, // Duty cycle of the output clock
    output pwm_out          // pwm_output signal  
);

reg [7:0]  counter;
reg pwm_r;

always @(posedge clock_in or posedge reset) begin
    if (reset) begin
        counter <= 0;
        pwm_r   <= 1;
    end else begin
        if (counter < 255) begin
            counter <= counter + 1;
            pwm_r   <= !(counter < duty_cycle);
        end else begin
            counter <= 0;
            pwm_r   <= 0;
        end
    end
end

assign pwm_out = !pwm_r;

endmodule
