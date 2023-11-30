interface if_add_port (input bit clk); //define the interface
	logic a, b, cin, sum, cout;   //declare all the port

	clocking cp@(posedge clk) // declare the direction of the port in the same clk
		output a, b, cin;
	endclocking

	clocking cn@(posedge clk)
		input a, b, cin, sum, cout;
	endclocking

	modport simulus(clocking cp);
	modport adder(input a, b, cin, output sum, cout);
	modport monitor(clocking cn);

endinterface

module simulus(if_add_port.simulus port);
	always @ (port.cp) begin
		port.cp.a <= $random()%2;
		port.cp.b <= $random()%2;
		port.cp.cin <= $random()%2;

	end

endmodule : simulus

module adder(if_add_port.adder prot);
	assign {port.cout, port.sum} = port.a + port.b + port.cin;

endmodule

module monitor(if_add_port.montor mon);
	always @ (mon.cn) begin
		$display("%d%d%d%d%d",mon.cn.a, mon.cn.b, mon.cn.cin, mon.cn.cout, mon.cn.sum);
	end
endmodule

module top();
	bit clk;
	if_add_port port(clk);
	simulus sim(
		port.simulus);
	adder add(
		port.adder);
	monitor mon(
		port.monitor);
	initial begin
		clk = 0;
	end
	always #5 clk = ~clk;
endmodule
