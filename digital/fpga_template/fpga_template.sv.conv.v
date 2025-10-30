// removed package "fpga_template_pkg"
// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:4:1
// removed ["import fpga_template_pkg::*;"]
module fpga_template_top (
	clk,
	uart_rx,
	uart_tx,
	pwm_out,
	debug_led,
	btn_s1_resetb,
	btn_s2
);
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:8:5
	input clk;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:14:5
	input uart_rx;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:15:5
	output wire uart_tx;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:18:5
	output wire pwm_out;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:20:5
	output wire [5:0] debug_led;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:22:5
	input btn_s1_resetb;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:23:5
	input btn_s2;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:26:1
	// removed localparam type fpga_template_pkg_rb_sys_cfg_wire_t
	wire [42:0] sys_cfg;
	assign debug_led = ~sys_cfg[31-:8];
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:35:1
	wire resetb;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:39:5
	assign resetb = btn_s1_resetb;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:49:1
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:50:1
	// removed localparam type fpga_template_pkg_rb_dsp_cfg_wire_t
	wire [7:0] dsp_cfg;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:55:1
	wire [7:0] rb_address;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:56:1
	wire [7:0] rb_data_write_to_reg;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:57:1
	wire [7:0] rb_data_read_from_reg;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:58:1
	wire rb_reg_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:59:1
	wire rb_write_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:60:1
	wire [1:0] rb_streamSt_mon;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:63:1
	wire [7:0] i2c_address;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:64:1
	wire [7:0] i2c_data_write_to_reg;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:65:1
	wire i2c_reg_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:66:1
	wire i2c_write_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:67:1
	wire [1:0] i2c_streamSt_mon;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:70:1
	wire [7:0] uart_address;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:71:1
	wire [7:0] uart_data_write_to_reg;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:72:1
	wire uart_reg_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:73:1
	wire uart_write_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:74:1
	wire [1:0] uart_streamSt_mon;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:95:1
	uart_if uart_inst(
		.clk(clk),
		.resetb(resetb),
		.uart_rx(uart_rx),
		.uart_tx(uart_tx),
		.address(uart_address),
		.data_write_to_reg(uart_data_write_to_reg),
		.data_read_from_reg(rb_data_read_from_reg),
		.reg_en(uart_reg_en),
		.write_en(uart_write_en),
		.streamSt_mon(uart_streamSt_mon)
	);
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:119:1
	assign rb_address = uart_address;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:120:1
	assign rb_data_write_to_reg = uart_data_write_to_reg;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:121:1
	assign rb_reg_en = uart_reg_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:122:1
	assign rb_write_en = uart_write_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:123:1
	assign rb_streamSt_mon = uart_streamSt_mon;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:128:1
	rb_fpga_template rb_fpga_template_inst(
		.clk(clk),
		.resetb(resetb),
		.address(rb_address),
		.data_write_in(rb_data_write_to_reg),
		.data_read_out(rb_data_read_from_reg),
		.reg_en(rb_reg_en),
		.write_en(rb_write_en),
		.sys_cfg(sys_cfg),
		.dsp_cfg(dsp_cfg)
	);
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:143:1
	pwm pwm_inst(
		.clock_in(clk),
		.reset(!resetb),
		.duty_cycle(sys_cfg[39-:8]),
		.pwm_out(pwm_out)
	);
endmodule
