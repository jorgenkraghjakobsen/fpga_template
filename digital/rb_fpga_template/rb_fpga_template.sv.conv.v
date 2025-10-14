// removed package "fpga_template_pkg"
// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:6:1
// removed ["import fpga_template_pkg::*;"]
module rb_fpga_template (
	clk,
	resetb,
	address,
	data_write_in,
	data_read_out,
	reg_en,
	write_en,
	sys_cfg,
	dsp_cfg
);
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:9:13
	parameter ADR_BITS = 8;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:12:2
	input wire clk;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:13:2
	input wire resetb;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:14:2
	input wire [ADR_BITS - 1:0] address;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:15:2
	input wire [7:0] data_write_in;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:16:2
	output reg [7:0] data_read_out;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:17:2
	input wire reg_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:18:2
	input wire write_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:20:2
	// removed localparam type fpga_template_pkg_rb_sys_cfg_wire_t
	inout wire [42:0] sys_cfg;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:21:2
	// removed localparam type fpga_template_pkg_rb_dsp_cfg_wire_t
	inout wire [7:0] dsp_cfg;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:27:1
	reg reg__sys_cfg__enable_stuf;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:28:1
	reg reg__sys_cfg__enable_other;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:29:1
	reg [7:0] reg__sys_cfg__pwm_duty;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:30:1
	reg [7:0] reg__sys_cfg__debug_led;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:31:1
	reg [7:0] reg__sys_cfg__debug_data0;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:32:1
	reg [7:0] reg__sys_cfg__debug_data1;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:33:1
	reg [7:0] reg__sys_cfg__debug_data2;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:36:1
	reg reg__dsp_cfg__bypass_enable;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:37:1
	reg reg__dsp_cfg__dc_filter_enable;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:38:1
	reg reg__dsp_cfg__bp_filter_enable;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:39:1
	reg reg__dsp_cfg__dec_filter_enable;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:40:1
	reg reg__dsp_cfg__pli_filter_enable;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:41:1
	reg reg__dsp_cfg__placeholder1;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:42:1
	reg reg__dsp_cfg__placeholder2;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:43:1
	reg reg__dsp_cfg__placeholder3;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:45:1
	always @(posedge clk)
		// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:47:3
		if (resetb == 0) begin
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:51:5
			reg__sys_cfg__enable_stuf <= 1'b0;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:52:5
			reg__sys_cfg__enable_other <= 1'b1;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:53:5
			reg__sys_cfg__pwm_duty <= 8'b10000101;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:54:5
			reg__sys_cfg__debug_led <= 8'b10101010;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:55:5
			reg__sys_cfg__debug_data0 <= 8'b00000000;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:56:5
			reg__sys_cfg__debug_data1 <= 8'b00000001;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:57:5
			reg__sys_cfg__debug_data2 <= 8'b00000010;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:60:5
			reg__dsp_cfg__bypass_enable <= 1'b1;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:61:5
			reg__dsp_cfg__dc_filter_enable <= 1'b1;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:62:5
			reg__dsp_cfg__bp_filter_enable <= 1'b1;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:63:5
			reg__dsp_cfg__dec_filter_enable <= 1'b1;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:64:5
			reg__dsp_cfg__pli_filter_enable <= 1'b1;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:65:5
			reg__dsp_cfg__placeholder1 <= 1'b0;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:66:5
			reg__dsp_cfg__placeholder2 <= 1'b0;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:67:5
			reg__dsp_cfg__placeholder3 <= 1'b0;
		end
		else
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:71:5
			if (write_en)
				// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:73:7
				case (address)
					0: begin
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:75:15
						reg__sys_cfg__enable_stuf <= data_write_in[0:0];
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:76:15
						reg__sys_cfg__enable_other <= data_write_in[1:1];
					end
					1:
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:78:15
						reg__sys_cfg__pwm_duty <= data_write_in[7:0];
					2:
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:80:15
						reg__sys_cfg__debug_led <= data_write_in[7:0];
					4:
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:82:15
						reg__sys_cfg__debug_data0 <= data_write_in[7:0];
					5:
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:84:15
						reg__sys_cfg__debug_data1 <= data_write_in[7:0];
					6:
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:86:15
						reg__sys_cfg__debug_data2 <= data_write_in[7:0];
					64: begin
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:89:15
						reg__dsp_cfg__bypass_enable <= data_write_in[0:0];
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:90:15
						reg__dsp_cfg__dc_filter_enable <= data_write_in[1:1];
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:91:15
						reg__dsp_cfg__bp_filter_enable <= data_write_in[2:2];
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:92:15
						reg__dsp_cfg__dec_filter_enable <= data_write_in[3:3];
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:93:15
						reg__dsp_cfg__pli_filter_enable <= data_write_in[4:4];
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:94:15
						reg__dsp_cfg__placeholder1 <= data_write_in[5:5];
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:95:15
						reg__dsp_cfg__placeholder2 <= data_write_in[6:6];
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:96:15
						reg__dsp_cfg__placeholder3 <= data_write_in[7:7];
					end
				endcase
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:103:1
	always @(posedge clk)
		// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:105:3
		if (resetb == 0)
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:106:5
			data_read_out <= 8'b00000000;
		else
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:109:5
			case (address)
				0: begin
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:111:15
					data_read_out[0:0] <= reg__sys_cfg__enable_stuf;
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:112:15
					data_read_out[1:1] <= reg__sys_cfg__enable_other;
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:113:15
					data_read_out[2:2] <= sys_cfg[40];
				end
				1:
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:115:15
					data_read_out[7:0] <= reg__sys_cfg__pwm_duty;
				2:
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:117:15
					data_read_out[7:0] <= reg__sys_cfg__debug_led;
				4:
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:119:15
					data_read_out[7:0] <= reg__sys_cfg__debug_data0;
				5:
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:121:15
					data_read_out[7:0] <= reg__sys_cfg__debug_data1;
				6:
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:123:15
					data_read_out[7:0] <= reg__sys_cfg__debug_data2;
				64: begin
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:126:15
					data_read_out[0:0] <= reg__dsp_cfg__bypass_enable;
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:127:15
					data_read_out[1:1] <= reg__dsp_cfg__dc_filter_enable;
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:128:15
					data_read_out[2:2] <= reg__dsp_cfg__bp_filter_enable;
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:129:15
					data_read_out[3:3] <= reg__dsp_cfg__dec_filter_enable;
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:130:15
					data_read_out[4:4] <= reg__dsp_cfg__pli_filter_enable;
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:131:15
					data_read_out[5:5] <= reg__dsp_cfg__placeholder1;
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:132:15
					data_read_out[6:6] <= reg__dsp_cfg__placeholder2;
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:133:15
					data_read_out[7:7] <= reg__dsp_cfg__placeholder3;
				end
				default:
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:135:17
					data_read_out <= 8'b00000000;
			endcase
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:140:1
	assign sys_cfg[42] = reg__sys_cfg__enable_stuf;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:141:1
	assign sys_cfg[41] = reg__sys_cfg__enable_other;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:142:1
	assign sys_cfg[39-:8] = reg__sys_cfg__pwm_duty;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:143:1
	assign sys_cfg[31-:8] = reg__sys_cfg__debug_led;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:144:1
	assign sys_cfg[23-:8] = reg__sys_cfg__debug_data0;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:145:1
	assign sys_cfg[15-:8] = reg__sys_cfg__debug_data1;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:146:1
	assign sys_cfg[7-:8] = reg__sys_cfg__debug_data2;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:147:1
	assign dsp_cfg[7] = reg__dsp_cfg__bypass_enable;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:148:1
	assign dsp_cfg[6] = reg__dsp_cfg__dc_filter_enable;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:149:1
	assign dsp_cfg[5] = reg__dsp_cfg__bp_filter_enable;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:150:1
	assign dsp_cfg[4] = reg__dsp_cfg__dec_filter_enable;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:151:1
	assign dsp_cfg[3] = reg__dsp_cfg__pli_filter_enable;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:152:1
	assign dsp_cfg[2] = reg__dsp_cfg__placeholder1;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:153:1
	assign dsp_cfg[1] = reg__dsp_cfg__placeholder2;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/rb_fpga_template/rb_fpga_template.sv:154:1
	assign dsp_cfg[0] = reg__dsp_cfg__placeholder3;
endmodule
