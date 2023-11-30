//funciton: collect the result from matrix and fill the 4KB with 0xffff_ffff_ffff_ffff

module tb_fill_out_package();

reg clk, rst_n;

reg start_0;
wire vld_0, empty_0, eop_0;
wire [63:0] data_0;

wire [9:0] data_sum;

reg start_1;
wire vld_1, empty_1, eop_1;
wire [63:0] data_1;

initial begin
	clk = 0;
	rst_n = 0;

	#10
	rst_n = 1;
end

always #5 clk = ~clk;
gen_data u0(
	.clk(clk),
	.rst_n(rst_n),
	.start(start_0),
	.vld(vld_0),
	.empty(empty_0),
	.eop(eop_0),
	.data_sum(data_sum),
	.data(data_0)
	);

gen_data u1(
	.clk(clk),
	.rst_n(rst_n),
	.start(start_1),
	.vld(vld_1),
	.empty(empty_1),
	.eop(eop_1),
	.data_sum(data_sum),
	.data(data_1)
	);

wire fill_pack_flag;

fill_out_packge f0(
	clk,
	rst_n,

	vld_0,
	empty_0,
	eop_0,
	data_0,

	vld_1,
	empty_1,
	eop_1,
	data_1,

	start_0,
	start_1,

	fill_pack_flag,
	data_sum
);

endmodule

module gen_data(
	clk,
	rst_n,
	start,
	data_sum,
	vld,
	empty,
	eop,
	data);

input wire clk, rst_n;
input wire start;
input wire [9:0] data_sum;
output reg vld, empty, eop;
output wire [63:0] data;
reg [63:0] data_temp;
reg start_reg;
reg [7:0] data_num;

always @ (posedge clk) begin
	start_reg <= start;
end

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		data_num <= 'd0;
	else if (start)
		data_num <= $random()%10 + 1'b1;
	else if (eop)
		data_num <= 'd0;
	else
		data_num <= data_num;
end

reg [7:0] data_cnt;

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		vld <= 'b0;
	else if (start && data_sum+data_num <32)
		vld <= 'b1;
	else if (data_cnt == data_num-1'b1)
		vld <= 'b0;
	else
		vld <= vld;
end

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		data_cnt <= 'd0;
	else if (start)
		data_cnt <= 'd0;
	else if (data_cnt == data_num -1'b1 )
		data_cnt <= 'd0;
	else if (vld)
		data_cnt <= data_cnt + 1'b1;
	else
		data_cnt <= data_cnt;
end

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		eop <= 'b0;
	else if (data_cnt == data_num-1'b1 && vld)
		eop <= 'b1;
	else
		eop <= 'b0;
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		data_temp <= 'd0;
	else if (data_cnt < data_num-1'b1 && vld)
		data_temp <= $random()%8 + 1'b1;
	else
		data_temp <= 'd0;
end 

assign data = (start_reg) ? data_num : data_temp;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		empty <= 1'b1;
	else
		empty <= 1'b0;
end

endmodule