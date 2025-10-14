// removed package "fpga_template_pkg"
// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:4:1
// removed ["import fpga_template_pkg::*;"]
module fpga_template_top (
	clk,
	i2c_scl,
	i2c_sda,
	uart_rx,
	uart_tx,
	uart_tx_mon,
	uart_rx_mon,
	rx_state_mon,
	proto_state_mon,
	tx_state_mon,
	pwm_out,
	debug_led_pin,
	btn_s1_resetb,
	btn_s2
);
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:8:5
	input clk;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:10:5
	input i2c_scl;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:11:5
	inout i2c_sda;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:13:5
	input uart_rx;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:14:5
	output wire uart_tx;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:15:5
	output wire uart_tx_mon;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:16:5
	output wire uart_rx_mon;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:18:5
	output wire [1:0] rx_state_mon;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:19:5
	output wire [3:0] proto_state_mon;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:20:5
	output wire [1:0] tx_state_mon;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:23:5
	output wire pwm_out;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:25:5
	output wire [5:0] debug_led_pin;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:26:5
	input btn_s1_resetb;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:27:5
	input btn_s2;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:31:1
	assign uart_rx_mon = uart_rx;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:32:1
	wire debug_rx_data_valid;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:33:1
	assign uart_tx_mon = uart_tx;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:35:1
	// removed localparam type fpga_template_pkg_rb_sys_cfg_wire_t
	wire [42:0] sys_cfg;
	assign debug_led_pin = sys_cfg[31-:8];
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:41:1
	wire resetb;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:42:1
	assign resetb = btn_s1_resetb;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:49:1
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:50:1
	assign sys_cfg[40] = 1'b0;
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
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:75:1
	wire [7:0] uart_debug_out;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:78:1
	reg debug_send;
	wire debug_uart_send;
	assign debug_uart_send = debug_send;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:79:1
	reg [7:0] debug_byte;
	wire debug_uart_data;
	assign debug_uart_data = debug_byte;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:84:1
	i2c_if i2c_inst(
		.clk(clk),
		.resetb(resetb),
		.sda(i2c_sda),
		.scl(i2c_scl),
		.address(i2c_address),
		.data_write_to_reg(i2c_data_write_to_reg),
		.data_read_from_reg(rb_data_read_from_reg),
		.reg_en(i2c_reg_en),
		.write_en(i2c_write_en),
		.streamSt_mon(i2c_streamSt_mon)
	);
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:100:1
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
		.streamSt_mon(uart_streamSt_mon),
		.debug_send(debug_uart_send),
		.debug_data(debug_uart_data),
		.debug_out(uart_debug_out),
		.debug_rx_data_valid(debug_rx_data_valid),
		.rx_state_mon(),
		.proto_state_mon(),
		.tx_state_mon()
	);
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:130:1
	assign rb_address = uart_address;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:131:1
	assign rb_data_write_to_reg = uart_data_write_to_reg;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:132:1
	assign rb_reg_en = uart_reg_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:133:1
	assign rb_write_en = uart_write_en;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:134:1
	assign rb_streamSt_mon = uart_streamSt_mon;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:138:1
	rb_fpga_template rb_fpga_template_inst(
		.clk(clk),
		.resetb(resetb),
		.address(rb_address),
		.data_write_in(rb_data_write_to_reg),
		.data_read_out(rb_data_read_from_reg),
		.write_en(rb_write_en),
		.sys_cfg(sys_cfg)
	);
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:151:1
	pwm pwm_inst(
		.clock_in(clk),
		.reset(!resetb),
		.duty_cycle(sys_cfg[39-:8]),
		.pwm_out(pwm_out)
	);
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:163:1
	reg [2:0] btn_s2_sync;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:164:1
	reg btn_s2_prev;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:165:1
	wire btn_s2_edge;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:167:1
	always @(posedge clk)
		// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:168:5
		if (!resetb) begin
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:169:9
			btn_s2_sync <= 3'b000;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:170:9
			btn_s2_prev <= 1'b0;
		end
		else begin
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:172:9
			btn_s2_sync <= {btn_s2_sync[1:0], btn_s2};
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:173:9
			btn_s2_prev <= btn_s2_sync[2];
		end
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:177:1
	assign btn_s2_edge = btn_s2_sync[2] & ~btn_s2_prev;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:180:1
	reg [3:0] debug_state;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:181:1
	reg [15:0] debug_counter;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:182:1
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:183:1
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:184:1
	reg debug_active;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:186:1
	localparam DEBUG_IDLE = 4'h0;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:187:1
	localparam DEBUG_START = 4'h1;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:188:1
	localparam DEBUG_SEND = 4'h2;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:189:1
	localparam DEBUG_WAIT = 4'h3;
	// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:192:1
	always @(posedge clk)
		// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:193:5
		if (!resetb) begin
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:195:9
			debug_state <= DEBUG_IDLE;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:196:9
			debug_counter <= 16'h0000;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:197:9
			debug_byte <= 8'h00;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:198:9
			debug_send <= 1'b0;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:199:9
			debug_active <= 1'b0;
		end
		else begin
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:201:9
			debug_send <= 1'b0;
			// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:203:9
			case (debug_state)
				DEBUG_IDLE:
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:205:17
					if (!btn_s2_edge) begin
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:207:21
						debug_state <= DEBUG_START;
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:208:21
						debug_counter <= 16'h0000;
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:209:21
						debug_active <= 1'b1;
					end
				DEBUG_START:
					// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:214:17
					if (debug_counter < 16'h1000) begin
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:215:21
						debug_counter <= debug_counter + 1;
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:218:21
						if (debug_counter[15:8] == 8'h00)
							// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:219:25
							case (debug_counter[7:0])
								8'h10: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:220:42
									debug_byte <= 8'h44;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:220:63
									debug_send <= 1'b1;
								end
								8'h20: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:221:42
									debug_byte <= 8'h42;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:221:63
									debug_send <= 1'b1;
								end
								8'h30: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:222:42
									debug_byte <= 8'h47;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:222:63
									debug_send <= 1'b1;
								end
								8'h40: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:223:42
									debug_byte <= 8'h3a;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:223:63
									debug_send <= 1'b1;
								end
								8'h50: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:224:42
									debug_byte <= 8'h20;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:224:63
									debug_send <= 1'b1;
								end
								8'h60: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:225:42
									debug_byte <= 8'h00;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:225:63
									debug_send <= 1'b1;
								end
								8'h70: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:226:42
									debug_byte <= 8'h01;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:226:63
									debug_send <= 1'b1;
								end
								8'h80: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:227:42
									debug_byte <= 8'h02;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:227:63
									debug_send <= 1'b1;
								end
								8'h90: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:228:42
									debug_byte <= 8'h03;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:228:63
									debug_send <= 1'b1;
								end
								8'ha0: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:229:42
									debug_byte <= 8'h04;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:229:63
									debug_send <= 1'b1;
								end
								8'hb0: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:230:42
									debug_byte <= 8'h05;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:230:63
									debug_send <= 1'b1;
								end
								8'hc0: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:231:42
									debug_byte <= 8'h06;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:231:63
									debug_send <= 1'b1;
								end
								8'hd0: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:232:42
									debug_byte <= 8'h07;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:232:63
									debug_send <= 1'b1;
								end
								8'he0: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:233:42
									debug_byte <= 8'h08;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:233:63
									debug_send <= 1'b1;
								end
								8'hf0: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:234:42
									debug_byte <= 8'h09;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:234:63
									debug_send <= 1'b1;
								end
								default:
									;
							endcase
						else if (debug_counter[15:8] == 8'h01)
							// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:240:25
							case (debug_counter[7:0])
								8'h00: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:241:42
									debug_byte <= 8'h0a;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:241:63
									debug_send <= 1'b1;
								end
								8'h10: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:242:42
									debug_byte <= 8'h0b;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:242:63
									debug_send <= 1'b1;
								end
								8'h20: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:243:42
									debug_byte <= 8'h0c;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:243:63
									debug_send <= 1'b1;
								end
								8'h30: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:244:42
									debug_byte <= 8'h0d;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:244:63
									debug_send <= 1'b1;
								end
								8'h40: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:245:42
									debug_byte <= 8'h0e;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:245:63
									debug_send <= 1'b1;
								end
								8'h50: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:246:42
									debug_byte <= 8'h0f;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:246:63
									debug_send <= 1'b1;
								end
								8'h60: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:247:42
									debug_byte <= 8'h0d;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:247:63
									debug_send <= 1'b1;
								end
								8'h70: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:248:42
									debug_byte <= 8'h0a;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:248:63
									debug_send <= 1'b1;
								end
								8'h80: begin
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:250:33
									debug_state <= DEBUG_IDLE;
									// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:251:33
									debug_active <= 1'b0;
								end
								default:
									;
							endcase
						else begin
							// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:259:25
							debug_state <= DEBUG_IDLE;
							// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:260:25
							debug_active <= 1'b0;
						end
					end
					else begin
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:264:21
						debug_state <= DEBUG_IDLE;
						// Trace: /home/jakobsen/work/asic/workspace/fpga_template/digital/fpga_template/fpga_template.sv:265:21
						debug_active <= 1'b0;
					end
			endcase
		end
endmodule
