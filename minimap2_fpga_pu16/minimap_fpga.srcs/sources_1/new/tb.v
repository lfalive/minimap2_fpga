
module cigar_cal(
	sys_clk,
	sys_rst_n,
	bt_in,
	tb_start,
	i_pos,
	j_pos,
	address,
	rd_en,
	mask,
	n_cigar,
	m_cigar,
	cigar,
	cigar_en,
	t_len,
	tb_done
	);

input wire sys_clk;
input wire sys_rst_n;

input wire [7:0] bt_in;
input wire tb_start
input wire [7:0] i_pos;
input wire [15:0] j_pos;
input wire [15:0] t_len;

output wire [10:0] address;
output reg rd_en;
output wire [7:0] mask;

output reg [7:0] n_cigar;
output wire [7:0] m_cigar;

output reg [31:0] cigar;
output reg cigar_en;

output wire tb_done;
wire [15:0] len;
parameter TB_IDLE 	= 	6'b000001;
parameter TB_START 	= 	6'b000010;
parameter TB_HOLD 	= 	6'b000100;
parameter TB_CAL 	= 	6'b001000;
parameter TB_FLASH 	= 	6'b010000;
parameter TB_DONE	= 	6'b100000;

reg [31:0] cigar;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		TB_state <= TB_IDLE;
	else
		TB_state <= TB_next_state;
end

reg [7:0] which;

always @(posedge sys_clk or negedge sys_rst_n) begin : proc_which
	if(~sys_rst_n) begin
		which <= 'd0;
	end else begin
		which <= (bt_in >> (which<<1)) & 2'b11;
	end
end

reg [1:0] hold_cnt;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		hold_cnt <= 'd0;
	else if (TB_state == TB_START || TB_state == TB_CAL)
		hold_cnt <= 'd0;
	else
		hold_cnt <= hold_cnt + 1'b1;
end

always @(*) begin
	TB_next_state = TB_state;
	case(TB_state)
		TB_IDLE : begin
			if (tb_start)
				TB_next_state = TB_START;
		end
		TB_START : 
			TB_next_state = TB_HOLD;
		TB_HOLD :
			if (hold_cnt == 2'b10) 
			TB_next_state = TB_CAL;
		TB_CAL : 
			if (!max_i && !max_j)
				TB_next_state = TB_DONE;
			else if(!max_i || !max_j)
				TB_next_state = TB_FLASH;
			else
				TB_next_state = TB_HOLD;
		TB_FLASH : 
			TB_next_state = TB_DONE
		TB_DONE : 
			TB_next_state = TB_IDLE;
	endcase // TB_state
end



always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		max_i <= 'd0;
		max_j <= 'd0;
	end else if (TB_state == TB_START) begin
		max_i <= i_pos;
		max_j <= j_pos;
	end else if (TB_state == TB_CAL && which == 2'b00) begin
		max_i <= max_i - 1'b1;
		max_j <= max_j - 1'b1;
	end else if (TB_state == TB_CAL && which == 2'b1) begin
		max_i <= max_i - 1'b1;
		max_j <= max_j;
	end else if(TB_state == TB_CAL && which == 2'b10)begin
		max_i <= max_i;
		max_j <= max_j - 1'b1;
	end else if (TB_state == TB_FLASH) begin
		max_i <= 'd0;
		max_j <= 'd0;
	end
end

assign address = (max_i >> 3)*t_len + max_j ;
assign mask = max_i[2:0] ;


always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) 
		rd_en <= 'd0;
	else if (TB_state == TB_START || TB_state == TB_CAL)
		rd_en <= 1'b1;
	else
		rd_en <= 1'b0;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n)
		n_cigar <= 'd0;
	else if (TB_state == TB_START)
		n_cigar <= 'd1;
	else if (TB_state == TB_CAL && cigar[1:0] != which)
		n_cigar <= n_cigar + 1'b1;
	else 
		n_cigar <= n_cigar;
end

//assign m_cigar = n_cigar << 1;

assign len = (!max_i) ? max_j : max_i;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		cigar <= 'd0;
	else if (TB_state == TB_START || (TB_state == TB_CAL && which != cigar[1:0]) ) begin
		cigar <= which | 32'h0000_0010 ; // the cigar option len = 1;
	end else if (TB_state == TB_CAL && which == 2'b00 && cigar[1:0] == 2'b00 ) begin
		cigar <= cigar + 8'h10; //the cigar option len + 1;
	end else if (TB_state == TB_FLASH && which != cigar[1:0]) begin
		cigar <= which | (len << 4);
	end else if (TB_state == TB_FLASH && which == cigar[1:0])
		cigar <= cigar + len << 4;
end

always @(posedge sys_clk or negedge sys_rst_n) begin : proc_cigar_en
	if(~sys_rst_n) begin
		cigar_en <= 'b0;
	end else if (TB_state == TB_START || (TB_state == TB_CAL && which != cigar[1:0])) begin
		cigar_en <= 1'b1;
	end else begin
		cigar_en <= 1'b0;
	end
end


assign tb_done = TB_state == TB_DONE;


endmodule