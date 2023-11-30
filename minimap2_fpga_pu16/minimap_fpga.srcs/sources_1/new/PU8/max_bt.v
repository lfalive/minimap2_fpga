module max_bt(
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

input wire core_clk, core_rst_n;
output reg max_rd_en;
input  wire [63:0] max_result;

output reg bt_rd_en;
input wire [63:0] bt_result;

input wire rd_start;
output reg vld_out, eop_out,sop_out;
output reg [63:0] data_out;


parameter IDLE 		= 4'b0001;
parameter MAX_OUT 	= 4'b0010;
parameter BT_OUT	= 4'b0100;
parameter DONE 		= 4'b1000;

parameter MAX_NUM = 8 ;//  512/64

reg [3:0] cur_state, next_state;
reg [2:0] max_cnt;

reg [7:0] bt_cnt, bt_num;

reg rd_start_reg;

always @(posedge core_clk or negedge core_rst_n) begin
	if (~core_rst_n)
		cur_state <= IDLE;
	else
		cur_state <= next_state;
end

always @ (*) begin
	next_state = cur_state;
	case (cur_state)
		IDLE	: begin if(rd_start) next_state = MAX_OUT; end
		MAX_OUT : begin if (max_cnt == MAX_NUM-1) next_state = BT_OUT; end
		BT_OUT  : begin if (bt_cnt == bt_num-1) next_state = DONE ; end
		DONE    : begin next_state = IDLE; end
	endcase // cur_state
end

always @(*) begin
	
	case (cur_state)
		IDLE : begin
			max_rd_en = 1'b0;
			bt_rd_en = 1'b0;
			vld_out = 1'b0;
			eop_out = 1'b0;
			sop_out = 1'b0;
			data_out = 'd0;
		end
		MAX_OUT : begin
			max_rd_en = 1'b1;
			bt_rd_en = 1'b0;
			vld_out = 1'b1;
			eop_out = 1'b0;
			data_out = max_result;
			if (max_cnt == 'd0)
				sop_out = 1'b1;
			else
				sop_out = 1'b0;
			
		end
		BT_OUT : begin
			max_rd_en = 1'b0;
			bt_rd_en = 1'b1;
			vld_out = 1'b1;
			data_out = bt_result;
			sop_out = 1'b0;
			if (bt_cnt == bt_num-1)
				eop_out = 1'b1;
			else
				eop_out = 1'b0;

		end
		DONE : begin
			max_rd_en = 1'b0;
			bt_rd_en = 1'b0;
			vld_out = 1'b0;
			eop_out = 1'b0;
			data_out = 'd0;
			sop_out = 1'b0;
		end
	endcase // cur_state
end

/*always @(posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n) begin
		max_rd_en = 1'b0;
		bt_rd_en <= 1'b0;
		vld_out  <= 1'b0;
		eop_out  <= 1'b0;
		sop_out  <= 1'b0;
		data_out <= 'd0;
	end else begin
		case (cur_state)
			IDLE : begin
				max_rd_en <= 1'b0;
				bt_rd_en  <= 1'b0;
				vld_out   <= 1'b0;
				eop_out   <= 1'b0;
				sop_out   <= 1'b0;
				data_out  <= 'd0;
			end
			MAX_OUT : begin
				max_rd_en <= 1'b1;
				bt_rd_en  <= 1'b0;
				vld_out   <= 1'b1;
				eop_out   <= 1'b0;
				data_out  <= max_result;
				if (max_cnt == 'd0)
					sop_out <= 1'b1;
				else
					sop_out <= 1'b0;
				
			end
			BT_OUT : begin
				max_rd_en <= 1'b0;
				bt_rd_en  <= 1'b1;
				vld_out   <= 1'b1;
				data_out  <= bt_result;
				sop_out   <= 1'b0;
				if (bt_cnt == bt_num-1)
					eop_out <= 1'b1;
				else
					eop_out <= 1'b0;
	
			end
			DONE : begin
				max_rd_en <= 1'b0;
				bt_rd_en  <= 1'b0;
				vld_out   <= 1'b0;
				eop_out   <= 1'b0;
				data_out  <= 'd0;
				sop_out   <= 1'b0;
			end
		endcase // cur_state
	end
end*/

always @(posedge core_clk or negedge core_rst_n) begin
	if (~core_rst_n)
		max_cnt <= 'd0;
	else if (max_cnt == MAX_NUM-1)
		max_cnt <= 'd0;
	else if (cur_state == MAX_OUT)
		max_cnt <= max_cnt + 1'b1;
	else
		max_cnt <= max_cnt;
end


//reg rd_start_reg_0;
always @ (posedge core_clk) begin
	rd_start_reg <= rd_start;
	//rd_start_reg_0 <= rd_start_reg;
end

always @(posedge core_clk or negedge core_rst_n) begin
	if (~core_rst_n)
		bt_num <= 'd0;
	else if (rd_start_reg)
		bt_num <= max_result-8;
	else
		bt_num <= bt_num;
end

always @(posedge core_clk or negedge core_rst_n) begin
	if (~core_rst_n)
		bt_cnt <= 'd0;
	else if (bt_cnt == bt_num-1)
		bt_cnt <= 'd0;
	else if (cur_state == BT_OUT)
		bt_cnt <= bt_cnt + 1'b1;
	else
		bt_cnt <= bt_cnt;
end

endmodule