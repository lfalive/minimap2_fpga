//function :colect the result from save_send to one file

module result_collect(
	//result_if resultif[8]
	sys_clk,
	sys_rst_n,

	vld_0,
	empty_0,
	eop_0,
	data_0,

	vld_1,
	empty_1,
	eop_1,
	data_1,

	vld_2,
	empty_2,
	eop_2,
	data_2,

	vld_3,
	empty_3,
	eop_3,
	data_3,

	vld_4,
	empty_4,
	eop_4,
	data_4,

	vld_5,
	empty_5,
	eop_5,
	data_5,

	rd_start,

	vld_6,
	empty_6,
	eop_6,
	data_6,

	/*vld_7,
	empty_7,
	eop_7,
	data_7,*/

	start_0,
	start_1,
	start_2,
	start_3,
	start_4,
	start_5,
	start_6,
	/*start_7*/

	vld_out,
	empty_out,
	eop_out,
	data_out

);

input wire sys_clk, sys_rst_n;

(* mark_debug = "true" *)input wire vld_0, empty_0, eop_0;
input wire [63:0] data_0;
(* mark_debug = "true" *)input wire vld_1, empty_1, eop_1;
input wire [63:0] data_1;
(* mark_debug = "true" *)input wire vld_2, empty_2, eop_2;
input wire [63:0] data_2;
(* mark_debug = "true" *)input wire vld_3, empty_3, eop_3;
input wire [63:0] data_3;
(* mark_debug = "true" *)input wire vld_4, empty_4, eop_4;
input wire  [63:0] data_4;
(* mark_debug = "true" *)input wire vld_5, empty_5, eop_5;
input wire [63:0] data_5;
(* mark_debug = "true" *)input wire vld_6, empty_6, eop_6;
input wire [63:0] data_6;

input wire rd_start;

output reg start_0, start_1, start_2, start_3, start_4, start_5, start_6;

(* mark_debug = "true" *)   output wire vld_out, empty_out;
output reg eop_out;
output wire [63:0] data_out;

reg [2:0] fifo_selsect;
reg [2:0] f0_fifo_select;


always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		fifo_selsect <= 3'd0;
	else begin
		case (fifo_selsect)
			'd0 : begin if (eop_0 || (empty_0 && !vld_0)) fifo_selsect <= fifo_selsect + 1'b1; end
			'd1 : begin if (eop_1 || (empty_1 && !vld_1)) fifo_selsect <= fifo_selsect + 1'b1; end
			'd2 : begin if (eop_2 || (empty_2 && !vld_2)) fifo_selsect <= fifo_selsect + 1'b1; end
			'd3 : begin if (eop_3 || (empty_3 && !vld_3)) fifo_selsect <= fifo_selsect + 1'b1; end
			'd4 : begin if (eop_4 || (empty_4 && !vld_4)) fifo_selsect <= fifo_selsect + 1'b1; end
			'd5 : begin if (eop_5 || (empty_5 && !vld_5)) fifo_selsect <= fifo_selsect + 1'b1; end
			'd6 : begin if (eop_6 || (empty_6 && !vld_6)) fifo_selsect <= 'd0; end
				//default : fifo_selsect <= 'd0;

		endcase
	end
end

reg [63:0] data_in;
reg wr_en;
always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		data_in <= 'd0;
	else begin
		case (fifo_selsect)
			'd0 : begin if (vld_0 ) data_in <= data_0; end
			'd1 : begin if (vld_1 ) data_in <= data_1; end
			'd2 : begin if (vld_2 ) data_in <= data_2; end
			'd3 : begin if (vld_3 ) data_in <= data_3; end
			'd4 : begin if (vld_4 ) data_in <= data_4; end
			'd5 : begin if (vld_5 ) data_in <= data_5; end
			'd6 : begin if (vld_6 ) data_in <= data_6; end
		endcase
	end
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		wr_en <= 'd0;
	else begin
		case (fifo_selsect)
			'd0 : begin if (vld_0 ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd1 : begin if (vld_1 ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd2 : begin if (vld_2 ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd3 : begin if (vld_3 ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd4 : begin if (vld_4 ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd5 : begin if (vld_5 ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd6 : begin if (vld_6 ) wr_en <= 1'b1; else wr_en = 1'b0;  end
		endcase
	end
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		f0_fifo_select <= 'd0;
	else
		f0_fifo_select <= fifo_selsect;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_0 <= 'd0;
	else if (fifo_selsect == 'd0 && f0_fifo_select == 'd6 && (!empty_0))
		start_0 <= 'd1;
	else
		start_0 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_1 <= 'd0;
	else if (fifo_selsect == 'd1 && f0_fifo_select == 'd0 && (!empty_1))
		start_1 <= 'd1;
	else
		start_1 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_2 <= 'd0;
	else if (fifo_selsect == 'd2 && f0_fifo_select == 'd1 && (!empty_2))
		start_2 <= 'd1;
	else
		start_2 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_3 <= 'd0;
	else if (fifo_selsect == 'd3 && f0_fifo_select == 'd2 && (!empty_3))
		start_3 <= 'd1;
	else
		start_3 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_4 <= 'd0;
	else if (fifo_selsect == 'd4 && f0_fifo_select == 'd3 && (!empty_4))
		start_4 <= 'd1;
	else
		start_4 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_5 <= 'd0;
	else if (fifo_selsect == 'd5 && f0_fifo_select == 'd4 && (!empty_5))
		start_5 <= 'd1;
	else
		start_5 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_6 <= 'd0;
	else if (fifo_selsect == 'd6 && f0_fifo_select == 'd5 && (!empty_6))
		start_6 <= 'd1;
	else
		start_6 <= 'd0;
end
wire full, empty;
reg rd_en;
(* mark_debug = "true" *)reg [7:0] result_cnt, result_num;
wire eop_in;
assign eop_in = eop_0|eop_1|eop_2|eop_3|eop_4|eop_5;
always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n)
		result_cnt <= 'd0;
	else if (eop_in)
		result_cnt <= result_cnt + 1'b1;
	else if (rd_start)
		result_cnt <= result_cnt - 1'b1;
	else
		result_cnt <= result_cnt;
end
assign empty_out = (result_cnt == 'd0) ? 1'b1 : 1'b0;

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n)
		result_num <= 'd0;
	else if (rd_start)
		result_num <= data_out;
	else if (eop_out)
		result_num <= 'd0;
	else
		result_num <= result_num;
end

reg [7:0] num_cnt;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n)
		num_cnt <= 'd0;
	else if (rd_start || num_cnt == result_num-1)
		num_cnt <= 'd0;
	else 
		num_cnt <= num_cnt + 1'b1;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) 
		rd_en <= 'b0;
	else if (rd_start)
		rd_en <= 'b1;
	else if (num_cnt == result_num - 1'b1)
		rd_en <= 'b0;
	else
		rd_en <= rd_en;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		eop_out <= 'b0;
	else if (num_cnt == result_num-2 && vld_out)
		eop_out <= 'b1;
	else
		eop_out <= 'b0;
end

assign vld_out = rd_en;


fifo_64x1024 fifo0 (
  .clk(sys_clk),      // input wire clk
  .din(data_in),      // input wire [63 : 0] din
  .wr_en(wr_en),  // input wire wr_en
  .rd_en(rd_en),  // input wire rd_en
  .dout(data_out),    // output wire [63 : 0] dout
  .full(full),    // output wire full
  .empty(empty)  // output wire empty
);

endmodule