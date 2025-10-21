// removed package "fpga_template_pkg"
// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:4:1
// removed ["import fpga_template_pkg::*;"]
module fpga_template_top (
	clk,
	uart_rx,
	uart_tx,
	uart_tx_mon,
	uart_rx_mon,
	pwm_out,
	debug_led,
	btn_s1_resetb,
	btn_s2
);
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:8:5
	input clk;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:13:5
	input uart_rx;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:14:5
	output wire uart_tx;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:15:5
	output wire uart_tx_mon;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:16:5
	output wire uart_rx_mon;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:23:5
	output wire pwm_out;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:25:5
	output wire [5:0] debug_led;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:26:5
	input btn_s1_resetb;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:27:5
	input btn_s2;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:32:1
	assign uart_rx_mon = uart_rx;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:33:1
	wire debug_rx_data_valid;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:36:1
	reg [20:0] clk_div_counter;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:37:1
	wire resetb;
	always @(posedge clk)
		// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:38:5
		if (!resetb)
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:39:9
			clk_div_counter <= 0;
		else
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:41:9
			clk_div_counter <= clk_div_counter + 1;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:45:1
	assign uart_tx_mon = clk_div_counter[20];
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:47:1
	// removed localparam type fpga_template_pkg_rb_sys_cfg_wire_t
	wire [42:0] sys_cfg;
	assign debug_led = ~sys_cfg[31-:8];
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:56:1
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:58:5
	assign resetb = ~btn_s1_resetb;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:70:1
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:71:1
	assign sys_cfg[40] = 1'b0;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:73:1
	// removed localparam type fpga_template_pkg_rb_dsp_cfg_wire_t
	wire [7:0] dsp_cfg;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:78:1
	wire [7:0] rb_address;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:79:1
	wire [7:0] rb_data_write_to_reg;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:80:1
	wire [7:0] rb_data_read_from_reg;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:81:1
	wire rb_reg_en;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:82:1
	wire rb_write_en;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:83:1
	wire [1:0] rb_streamSt_mon;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:86:1
	wire [7:0] i2c_address;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:87:1
	wire [7:0] i2c_data_write_to_reg;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:88:1
	wire i2c_reg_en;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:89:1
	wire i2c_write_en;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:90:1
	wire [1:0] i2c_streamSt_mon;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:93:1
	wire [7:0] uart_address;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:94:1
	wire [7:0] uart_data_write_to_reg;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:95:1
	wire uart_reg_en;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:96:1
	wire uart_write_en;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:97:1
	wire [1:0] uart_streamSt_mon;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:98:1
	wire [7:0] uart_debug_out;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:99:1
	wire [1:0] uart_tx_state_mon;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:102:1
	reg debug_send;
	wire debug_uart_send;
	assign debug_uart_send = debug_send;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:103:1
	reg [7:0] debug_byte;
	wire debug_uart_data;
	assign debug_uart_data = debug_byte;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:124:1
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
		.tx_state_mon(uart_tx_state_mon)
	);
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:154:1
	assign rb_address = uart_address;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:155:1
	assign rb_data_write_to_reg = uart_data_write_to_reg;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:156:1
	assign rb_reg_en = uart_reg_en;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:157:1
	assign rb_write_en = uart_write_en;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:158:1
	assign rb_streamSt_mon = uart_streamSt_mon;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:162:1
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
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:177:1
	pwm pwm_inst(
		.clock_in(clk),
		.reset(!resetb),
		.duty_cycle(sys_cfg[39-:8]),
		.pwm_out(pwm_out)
	);
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:189:1
	reg [2:0] btn_s2_sync;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:190:1
	reg btn_s2_prev;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:191:1
	wire btn_s2_edge;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:193:1
	always @(posedge clk)
		// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:194:5
		if (!resetb) begin
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:195:9
			btn_s2_sync <= 3'b000;
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:196:9
			btn_s2_prev <= 1'b0;
		end
		else begin
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:198:9
			btn_s2_sync <= {btn_s2_sync[1:0], btn_s2};
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:199:9
			btn_s2_prev <= btn_s2_sync[2];
		end
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:203:1
	assign btn_s2_edge = btn_s2_sync[2] & ~btn_s2_prev;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:206:1
	reg [3:0] debug_state;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:207:1
	reg [15:0] debug_counter;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:208:1
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:209:1
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:210:1
	reg debug_active;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:212:1
	localparam DEBUG_IDLE = 4'h0;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:213:1
	localparam DEBUG_START = 4'h1;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:214:1
	localparam DEBUG_SEND = 4'h2;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:215:1
	localparam DEBUG_WAIT = 4'h3;
	// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:218:1
	always @(posedge clk)
		// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:219:5
		if (!resetb) begin
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:221:9
			debug_state <= DEBUG_IDLE;
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:222:9
			debug_counter <= 16'h0000;
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:223:9
			debug_byte <= 8'h00;
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:224:9
			debug_send <= 1'b0;
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:225:9
			debug_active <= 1'b0;
		end
		else begin
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:227:9
			debug_send <= 1'b0;
			// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:229:9
			case (debug_state)
				DEBUG_IDLE:
					// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:231:17
					if (!btn_s2_edge) begin
						// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:233:21
						debug_state <= DEBUG_START;
						// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:234:21
						debug_counter <= 16'h0000;
						// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:235:21
						debug_active <= 1'b1;
					end
				DEBUG_START:
					// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:240:17
					if (debug_counter < 16'h1000) begin
						// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:241:21
						debug_counter <= debug_counter + 1;
						// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:244:21
						if (debug_counter[15:8] == 8'h00)
							// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:245:25
							case (debug_counter[7:0])
								8'h10: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:246:42
									debug_byte <= 8'h44;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:246:63
									debug_send <= 1'b1;
								end
								8'h20: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:247:42
									debug_byte <= 8'h42;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:247:63
									debug_send <= 1'b1;
								end
								8'h30: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:248:42
									debug_byte <= 8'h47;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:248:63
									debug_send <= 1'b1;
								end
								8'h40: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:249:42
									debug_byte <= 8'h3a;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:249:63
									debug_send <= 1'b1;
								end
								8'h50: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:250:42
									debug_byte <= 8'h20;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:250:63
									debug_send <= 1'b1;
								end
								8'h60: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:251:42
									debug_byte <= 8'h00;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:251:63
									debug_send <= 1'b1;
								end
								8'h70: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:252:42
									debug_byte <= 8'h01;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:252:63
									debug_send <= 1'b1;
								end
								8'h80: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:253:42
									debug_byte <= 8'h02;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:253:63
									debug_send <= 1'b1;
								end
								8'h90: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:254:42
									debug_byte <= 8'h03;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:254:63
									debug_send <= 1'b1;
								end
								8'ha0: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:255:42
									debug_byte <= 8'h04;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:255:63
									debug_send <= 1'b1;
								end
								8'hb0: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:256:42
									debug_byte <= 8'h05;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:256:63
									debug_send <= 1'b1;
								end
								8'hc0: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:257:42
									debug_byte <= 8'h06;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:257:63
									debug_send <= 1'b1;
								end
								8'hd0: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:258:42
									debug_byte <= 8'h07;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:258:63
									debug_send <= 1'b1;
								end
								8'he0: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:259:42
									debug_byte <= 8'h08;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:259:63
									debug_send <= 1'b1;
								end
								8'hf0: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:260:42
									debug_byte <= 8'h09;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:260:63
									debug_send <= 1'b1;
								end
								default:
									;
							endcase
						else if (debug_counter[15:8] == 8'h01)
							// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:266:25
							case (debug_counter[7:0])
								8'h00: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:267:42
									debug_byte <= 8'h0a;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:267:63
									debug_send <= 1'b1;
								end
								8'h10: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:268:42
									debug_byte <= 8'h0b;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:268:63
									debug_send <= 1'b1;
								end
								8'h20: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:269:42
									debug_byte <= 8'h0c;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:269:63
									debug_send <= 1'b1;
								end
								8'h30: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:270:42
									debug_byte <= 8'h0d;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:270:63
									debug_send <= 1'b1;
								end
								8'h40: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:271:42
									debug_byte <= 8'h0e;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:271:63
									debug_send <= 1'b1;
								end
								8'h50: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:272:42
									debug_byte <= 8'h0f;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:272:63
									debug_send <= 1'b1;
								end
								8'h60: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:273:42
									debug_byte <= 8'h0d;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:273:63
									debug_send <= 1'b1;
								end
								8'h70: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:274:42
									debug_byte <= 8'h0a;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:274:63
									debug_send <= 1'b1;
								end
								8'h80: begin
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:276:33
									debug_state <= DEBUG_IDLE;
									// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:277:33
									debug_active <= 1'b0;
								end
								default:
									;
							endcase
						else begin
							// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:285:25
							debug_state <= DEBUG_IDLE;
							// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:286:25
							debug_active <= 1'b0;
						end
					end
					else begin
						// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:290:21
						debug_state <= DEBUG_IDLE;
						// Trace: /home/tomato-chip/fpga_template/digital/fpga_template/fpga_template.sv:291:21
						debug_active <= 1'b0;
					end
			endcase
		end
endmodule
