//use interface
//function:collenct the result from the save_send module

interface result_if (input bit sys_clk, sys_rst_n);
	logic [63:0] data;
	logic vld, empty, eop;
	logic start;// output fifo read_en

	modport DUT(input data, vld, eop, empty, output start)
endinterface

module result_collect(
	//result_if resultif[8]
	result_if.DUT result0, result1,result2,result3,result4, result5, result6, result7
	input logic sys_clk, sys_rst_n;
);

reg [2:0] fifo_selsect;


always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		fifo_selsect <= 3'd0;
	else begin
		case (fifo_selsect)
			'd0 : begin if (result0.eop || result0.empty) fifo_selsect <= fifo_selsect + 1'b1; end
			'd1 : begin if (result1.eop || result1.empty) fifo_selsect <= fifo_selsect + 1'b1; end
			'd2 : begin if (result2.eop || result2.empty) fifo_selsect <= fifo_selsect + 1'b1; end
			'd3 : begin if (result3.eop || result3.empty) fifo_selsect <= fifo_selsect + 1'b1; end
			'd4 : begin if (result4.eop || result4.empty) fifo_selsect <= fifo_selsect + 1'b1; end
			'd5 : begin if (result5.eop || result5.empty) fifo_selsect <= fifo_selsect + 1'b1; end
			'd6 : begin if (result6.eop || result6.empty) fifo_selsect <= fifo_selsect + 1'b1; end
			'd7 : begin if (result7.eop || result7.empty) fifo_selsect <= fifo_selsect + 1'b1; end
		endcase
	end
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		data_in <= 'd0;
	else begin
		case (fifo_selsect)
			'd0 : begin if (result0.vld ) data_in <= result0.data; end
			'd1 : begin if (result1.vld ) data_in <= result1.data; end
			'd2 : begin if (result2.vld ) data_in <= result2.data; end
			'd3 : begin if (result3.vld ) data_in <= result3.data; end
			'd4 : begin if (result4.vld ) data_in <= result4.data; end
			'd5 : begin if (result5.vld ) data_in <= result5.data; end
			'd6 : begin if (result6.vld ) data_in <= result6.data; end
			'd7 : begin if (result7.vld ) data_in <= result7.data; end
		endcase
	end
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		wr_en <= 'd0;
	else begin
		case (fifo_selsect)
			'd0 : begin if (result0.vld ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd1 : begin if (result1.vld ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd2 : begin if (result2.vld ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd3 : begin if (result3.vld ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd4 : begin if (result4.vld ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd5 : begin if (result5.vld ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd6 : begin if (result6.vld ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			'd7 : begin if (result7.vld ) wr_en <= 1'b1; else wr_en = 1'b0;  end
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
	else if (fifo_selsect == 'd0 && f0_fifo_select == 'd7 && (!result0.empty))
		start_0 <= 'd1;
	else
		start_0 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_1 <= 'd0;
	else if (fifo_selsect == 'd1 && f0_fifo_select == 'd0 && (!result1.empty))
		start_1 <= 'd1;
	else
		start_1 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_2 <= 'd0;
	else if (fifo_selsect == 'd2 && f0_fifo_select == 'd1 && (!result2.empty))
		start_2 <= 'd1;
	else
		start_2 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_3 <= 'd0;
	else if (fifo_selsect == 'd3 && f0_fifo_select == 'd2 && (!result3.empty))
		start_3 <= 'd1;
	else
		start_3 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_4 <= 'd0;
	else if (fifo_selsect == 'd4 && f0_fifo_select == 'd3 && (!result4.empty))
		start_4 <= 'd1;
	else
		start_4 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_5 <= 'd0;
	else if (fifo_selsect == 'd5 && f0_fifo_select == 'd4 && (!result5.empty))
		start_5 <= 'd1;
	else
		start_5 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_6 <= 'd0;
	else if (fifo_selsect == 'd6 && f0_fifo_select == 'd5 && (!result6.empty))
		start_6 <= 'd1;
	else
		start_6 <= 'd0;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		start_7 <= 'd0;
	else if (fifo_selsect == 'd6 && f0_fifo_select == 'd7 && (!result7.empty))
		start_7 <= 'd1;
	else
		start_7 <= 'd0;
end

endmodule