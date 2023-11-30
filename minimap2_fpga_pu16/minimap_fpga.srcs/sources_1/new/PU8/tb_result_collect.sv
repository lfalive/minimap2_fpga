
interface if_port(input bit clk);
	logic vld, empty, eop, start;
	logic [63:0] data;

	clocking cp@(posedge clk);
		inout vld, empty, eop, data;
		input start;

	endclocking

	modport sim(clocking cp);
	modport dut(input vld, empty, eop, data,output start);

endinterface


module tb_result_collect(if_port.sim port);
	logic [3:0] count;
	logic [3:0] data_num;

	always @ (port.cp) begin
		if (port.cp.start)
			data_num <= $random()%8;
		else
			data_num <= 'd0;
	end


	always @ (port.cp) begin
		if (port.cp.start)
			count <= 'd0;
		else if (count == data_num)
			count <= 'd0;
		else 
			count <= count + 1'b1;
	end

	always @ (port.cp) begin
		if (port.cp.start)
			port.cp.vld <= 1'b1;
		else if (count == data_num)
			port.cp.vld <= 1'b0;
		else
			port.cp.vld <= port.cp.vld;
	end

	always @ (port.cp ) begin
		if (port.cp.start)
			port.cp.data <= 'd0;
		else if (port.cp.vld)
			port.cp.data <= port.cp.data + 1'b1;
		else
			port.cp.data <= 'd0;
	end

	always @ (port.cp) begin
		if (port.cp.start)
			port.cp.eop <= 'd0;
		else if (count == data_num)
			port.cp.eop <= 'd1;
		else
			port.cp.eop <= 'd0;
	end

	
	initial begin
	   port.cp.empty <= 1'b1;
	   //repeat(4) @(port.cp);
	   #10
	   port.cp.empty <= 1'b0;
	end

endmodule

module top();
	timeunit 1ns;
	timeprecision 100ps;

	bit clk, sys_rst_n;

	initial begin
		clk = 0;
		sys_rst_n = 0;
		#10
		sys_rst_n = 1;
	end

	always #5 clk = ~clk;


	if_port port0(clk), port1(clk), port2(clk), port3(clk), 
	port4(clk), port5(clk), port6(clk), port7(clk);

	tb_result_collect t0(port0.sim);
	tb_result_collect t1(port1.sim);
	tb_result_collect t2(port2.sim);
	tb_result_collect t3(port3.sim);
	tb_result_collect t4(port0.sim);
	tb_result_collect t5(port1.sim);

	result_collect u0(
		.sys_clk(clk),
		.sys_rst_n(sys_rst_n),
		.vld_0  (port0.vld)  ,
        .empty_0(port0.empty),
        .eop_0  (port0.eop)  ,
        .data_0 (port0.data) ,

        .vld_1  (port1.vld)  ,
        .empty_1(port1.empty),
        .eop_1  (port1.eop)  ,
        .data_1  (port1.data) ,

        .vld_2  (port2.vld)  ,
        .empty_2(port2.empty),
        .eop_2  (port2.eop)  ,
        .data_2 (port2.data) ,

        .vld_3  (port3.vld)  ,
        .empty_3(port3.empty),
        .eop_3  (port3.eop)  ,
        .data_3 (port3.data) ,

        .vld_4  (port4.vld)  ,
        .empty_4(port4.empty),
        .eop_4  (port4.eop)  ,
        .data_4 (port4.data) ,

        .vld_5  (port5.vld)  ,
        .empty_5(port5.empty),
        .eop_5  (port5.eop)  ,
        .data_5 (port5.data) ,


        .start_0(port0.start),
        .start_1(port1.start),
        .start_2(port2.start),
        .start_3(port3.start),
        .start_4(port4.start),
        .start_5(port5.start)

        );

endmodule




