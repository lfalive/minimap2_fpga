module tb_max_bt_result();

reg core_clk, core_rst_n;

reg sys_clk, sys_rst_n;
wire max_rd_en, bt_rd_en;
reg max_wr_en, bt_wr_en;
reg [511:0] max_din;
reg [63:0] bt_din, bt_result;
reg [63:0] max_result;

reg rd_start;

initial begin
	sys_clk = 0;
	sys_rst_n = 0;
	#10
	sys_rst_n = 1;
end

always #5 sys_clk = ~sys_clk;

initial begin
	core_clk = 0;
	core_rst_n = 0;
	#20
	core_rst_n = 1;
end

always #10 core_clk = ~core_clk;

initial begin
	max_wr_en = 0;
	repeat (2) begin
	@ (posedge sys_clk)
	max_din = 512'h0000_0000_0000_0005_0000_0000_0000_0001_0000_0000_0000_0002_0000_0000_0000_0003_0000_0000_0000_0004_0000_0000_0000_000a_0000_0000_0000_000b_0000_0000_0000_000c;
	max_wr_en = 1;
	end
	@(posedge sys_clk) ;
	max_wr_en = 0;
end

initial begin
	bt_wr_en = 0;
	bt_din = 'd0;
	rd_start = 'b0;
	repeat (5) @ (posedge sys_clk);
	repeat (7) begin
	@ (posedge sys_clk) 
		bt_wr_en = 1;
		bt_din = bt_din + 1'b1;
	end
	bt_wr_en = 0;
	@ (posedge core_clk) ;
	rd_start = 1;
	@ (posedge core_clk) ;
	rd_start = 0;
end
wire empty_max;
fifo_64x128_512x16 your_instance_name (
  .wr_clk(sys_clk),  // input wire wr_clk
  .rd_clk(core_clk),  // input wire rd_clk
  .din(max_din),        // input wire [511 : 0] din
  .wr_en(max_wr_en),    // input wire wr_en
  .rd_en(max_rd_en),    // input wire rd_en
  .dout(max_result),      // output wire [63 : 0] dout
  //.full(full_max),      // output wire full
  .empty(empty_max)    // output wire empty
);

fifo_64x128 fifo_bt (
  .wr_clk(sys_clk),  // input wire wr_clk
  .wr_rst(~sys_rst_n),  // input wire wr_rst
  .rd_clk(core_clk),  // input wire rd_clk
  .rd_rst(~core_rst_n),  // input wire rd_rst
  .din(bt_din),        // input wire [63 : 0] din
  .wr_en(bt_wr_en),    // input wire wr_en
  .rd_en(bt_rd_en),    // input wire rd_en
  .dout(bt_result)      // output wire [63 : 0] dout
 // .full(full_bt),      // output wire full
 // .empty(empty_bt)   // output wire empty

);

wire vld_out, eop_out, sop_out;
wire [63:0] data_out;
max_bt dut(
	core_clk,
	core_rst_n,

	max_rd_en,
	max_result,

	bt_rd_en,
	bt_result,
	rd_start,
	vld_out,
	sop_out,
	data_out,
	eop_out
	);

endmodule