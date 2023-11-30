//function:fill the fifo data is 4K num
module fill_out_packge(
	core_clk,
	core_rst_n,

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
	wr_en,
	data_in
	//unit_num_count  
);

//we use the pre data_num to predict the next data_num ,so there is no need to transfer the uniti_num

parameter NUM_DATA_WIDTH = 10; //log(NUM)
parameter NUM = 512; //4kB/64bit
reg [NUM_DATA_WIDTH-1 : 0] unit_num; 
input wire core_clk, core_rst_n;

(* mark_debug = "true" *)input wire vld_0, empty_0, eop_0;
(* mark_debug = "true" *)input wire [63:0] data_0;
(* mark_debug = "true" *)input wire vld_1, empty_1, eop_1;
(* mark_debug = "true" *)input wire [63:0] data_1;

(* mark_debug = "true" *)output reg start_0, start_1;
(* mark_debug = "true" *)output reg fill_pack_flag;

(* mark_debug = "true" *)output reg  wr_en;
(* mark_debug = "true" *)output reg [63:0] data_in;
(* mark_debug = "true" *)reg [NUM_DATA_WIDTH-1 : 0] unit_num_count;

(* mark_debug = "true" *)reg fifo_selsect;
reg f0_fifo_select;

always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		fifo_selsect <= 'd0;
	else begin
		case (fifo_selsect)
			'd0 : begin if (eop_0 || (empty_0 && !vld_0)) fifo_selsect <= fifo_selsect + 1'b1; end
			'd1 : begin if (eop_1 || (empty_1 && !vld_1)) fifo_selsect <= fifo_selsect + 1'b1; end
		endcase
	end
end

//reg [63:0] data_in;
//reg wr_en;
always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		data_in <= 'hffff_ffff_ffff_ffff;
	else begin
		if (fill_pack_flag)
			data_in <= 'hffff_ffff_ffff_ffff;
		else begin
			case (fifo_selsect)
				'd0 : begin if (vld_0 ) data_in <= data_0; end
				'd1 : begin if (vld_1 ) data_in <= data_1; end
			endcase
		end
	end
end

always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		wr_en <= 'd0;
	else begin
		if (fill_pack_flag)
			wr_en <= 1'b1;
		else begin
			case (fifo_selsect)
				'd0 : begin if (vld_0 ) wr_en <= 1'b1; else wr_en = 1'b0;  end
				'd1 : begin if (vld_1 ) wr_en <= 1'b1; else wr_en = 1'b0;  end
			endcase
		end
	end
end

always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		f0_fifo_select <= 'd0;
	else
		f0_fifo_select <= fifo_selsect;
end

always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		start_0 <= 'd0;
	else if (fill_pack_flag)
		start_0 <= 'd0;
	else if (fifo_selsect == 'd0 && f0_fifo_select == 'd1 && (!empty_0))
		start_0 <= 'd1;
	else
		start_0 <= 'd0;
end

always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		start_1 <= 'd0;
	else if (fill_pack_flag)
		start_1 <= 'd0;
	else if (fifo_selsect == 'd1 && f0_fifo_select == 'd0 && (!empty_1))
		start_1 <= 'd1;
	else
		start_1 <= 'd0;
end


reg start_0_reg, start_1_reg;

always @(posedge core_clk ) begin
	start_0_reg <= start_0;
	start_1_reg <= start_1;
end


always @ (posedge core_clk or negedge core_rst_n) begin
	if (~core_rst_n)
		unit_num <= 'd0;
	else if (start_0_reg)
		unit_num <= data_0;
	else if (start_1_reg)
		unit_num <= data_1;
	else
		unit_num <= unit_num;
end

always @ (posedge core_clk or negedge core_rst_n) begin
	if (~core_rst_n)
		unit_num_count <= 'd0;
	else if (start_0_reg)
		unit_num_count <= unit_num_count + data_0;
	else if (start_1_reg)
		unit_num_count <= unit_num_count + data_1;
	else if (unit_num_count == NUM-1)
		unit_num_count <= 'd0;
	else if (fill_pack_flag)
		unit_num_count <= unit_num_count + 1'b1;
	else
		unit_num_count <= unit_num_count;
end

always @ (posedge core_clk or negedge core_rst_n) begin
	if (~core_rst_n)
		fill_pack_flag <= 'b0;
	else if (unit_num_count < NUM-1 && unit_num_count + unit_num > NUM-1 && ~vld_0 && ~vld_1)
		fill_pack_flag <= 'b1;
	else
		fill_pack_flag <= 'b0;
end


/*wire full, empty;
wire [63:0] data_out;
wire rd_en;*/
/*fifo_64x1024 fifo0 (
  .clk(core_clk),      // input wire clk
  .din(data_in),      // input wire [63 : 0] din
  .wr_en(wr_en),  // input wire wr_en
  .rd_en(rd_en),  // input wire rd_en
  .dout(data_out),    // output wire [63 : 0] dout
  .full(full),    // output wire full
  .empty(empty)  // output wire empty
);*/
endmodule