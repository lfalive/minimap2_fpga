interface Rx_if (input logic clk);
	logic [7:0] data;
	logic soc,en,clav,rclk;

	clocking cb @(posedge clk);
		output data, soc, clav;
		input en;
	endclocking : cb

	modport DUT (output en, rclk,
		input data, soc, clav);

	modport TB (clocking cb);


endinterface : Rx_if


interface Tx_if (input logic clk);
	logic [7:0] data;
	logic soc, en, clav, tclk;

	clocking cb @(posedge clk);
		input data, soc, en;
		output clav;
	endclocking : cb

	modport DUT (output data, soc, en ,tclk,
		input clk, clav);

	modport TB(clocking cb)

endinterface : Tx_if


module atm_router(Rx_if.DUT Rx0, Rx1, Rx2, Rx3,
				  Tx_if.DUT Tx0, Tx1, Tx2, Tx3,
				  input logic clk,rst); // prot and interface can mixed using
endmodule : atm_router

module top;
	bit clk, rst;
	always #5 clk = !clk;

	Rx_if Rx0(clk), Rx1(clk), Rx2(clk), Rx3(clk);
	Tx_if Tx0(clk), Tx1(clk), Tx2(clk), Tx3(clk);

	atm_router a1(.*);
	test t1 (.*);

endmodule : top

program test(Rx_if.TB rx0, rx1, rx2,rx3,
	Tx_if.TB tx0, tx1,tx2,tx3,
	input logic clk, output logic rst);

bit [7:0] bytes[ATM_CELL_SIZE];

initial begin
	rst <= 1;
	rx0.cb.data <= 0;
	receive_cell0();

end

task receive_cell0();

	@(Tx0.cb);
	tx0.cb.clav <= 1;
	wait(tx0.cb.soc == 1);
	for (int i=0; i<ATM_CELL_SIZE; i++) begin
		wait (Tx0.cb.en == 0);
		@ (Tx0.cb);
	end

endtask : receive_cell0