
module cigar_cal(
	sys_clk,
	sys_rst_n,
	bt_in,
	tb_start,
	i_pos,
	j_pos,
	t_len,
	read_len,
	address,
	rd_en,
	mask,
	n_cigar,
	//m_cigar,
	cigar0,
	cigar_en,
	tb_done
	);

(* mark_debug = "true" *)input wire sys_clk;
input wire sys_rst_n;

input wire [7:0] bt_in;
input wire tb_start;
input wire [7:0] i_pos;
input wire [15:0] j_pos;
input wire [15:0] t_len;
input wire [7:0] read_len;

output wire [10:0] address;
output reg rd_en;
output reg [7:0] mask;

output reg [7:0] n_cigar;
//output wire [7:0] m_cigar;

(* mark_debug = "true" *)output wire [31:0] cigar0;
(* mark_debug = "true" *)output reg cigar_en;
(* mark_debug = "true" *)output wire tb_done;
wire [15:0] len;
reg [31:0] cigar;
parameter TB_IDLE 	= 	6'b000001;
parameter TB_START 	= 	6'b000010;
parameter TB_HOLD 	= 	6'b000100;
parameter TB_CAL 	= 	6'b001000;
parameter TB_FLASH 	= 	6'b010000;
parameter TB_DONE	= 	6'b100000;

(* mark_debug = "true" *)reg [5:0] TB_state;
(* mark_debug = "true" *)reg [5:0] TB_next_state;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		TB_state <= TB_IDLE;
	else
		TB_state <= TB_next_state;
end

(* mark_debug = "true" *)reg [7:0] which;
reg init_flag;
always @(posedge sys_clk or negedge sys_rst_n) begin : proc_init_flag
	if(~sys_rst_n) begin
		init_flag <= 'b0;
	end else if (TB_state == TB_DONE) begin
		init_flag <= 'b0;
	end else if (TB_state == TB_CAL) begin
		init_flag <= 'b1;
	end else begin
		init_flag <= init_flag;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin : proc_which
	if(~sys_rst_n) begin
		which <= 'd0;
	end else if (!init_flag && hold_cnt == 'd0) begin// the init which is zero
		which <= 'd0;
	end else begin
		which <= (bt_in >> (which<<1)) & 2'b11; // state must be clean for the start,so the first which
	end                                         // must be depedent for the last pkg
end

(* mark_debug = "true" *)reg [1:0] hold_cnt;
reg [7:0] max_i;
reg [15:0] max_j;
/*always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		hold_cnt <= 'd0;
	else if (TB_state == TB_START || TB_state == TB_CAL)
		hold_cnt <= 'd0;
	else
		hold_cnt <= hold_cnt + 1'b1;
end*/

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		hold_cnt <= 'd0;
	else if (TB_state == TB_START || TB_state == TB_CAL)
		hold_cnt <= 'd0;
	else if (TB_state == TB_HOLD)
		hold_cnt <= hold_cnt + 1'b1;
	else
		hold_cnt <= 'd0;
end

(* mark_debug = "true" *)reg [1:0] done_cnt;

always @(posedge sys_clk or negedge sys_rst_n) begin : proc_done_cnt
	if(~sys_rst_n) begin
		done_cnt <= 0;
	end else if (TB_state == TB_DONE)begin
		done_cnt <= done_cnt + 1'b1;
	end else
		done_cnt <= 'd0;
end

/*always @(posedge sys_clk or negedge sys_rst_n) begin : proc_done_cnt
	if(~sys_rst_n) begin
		done_cnt <= 'd0;
	end else if (TB_state == TB_DONE)begin
		done_cnt <= done_cnt + 1'b1;
	end else if (TB_state == TB_START) begin
		done_cnt <= 'd0;
	end else
		done_cnt <= done_cnt;
end*/

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
			if (hold_cnt == 2'b01) 
			TB_next_state = TB_CAL;
		TB_CAL : 
			if (!max_i && !max_j)
				TB_next_state = TB_DONE;
			else if(!max_i || !max_j)
				TB_next_state = TB_FLASH;
			else
				TB_next_state = TB_HOLD;
		TB_FLASH : 
			TB_next_state = TB_DONE;
		TB_DONE : 
			if (done_cnt == 2'b10)
				TB_next_state = TB_IDLE;
			else
				TB_next_state = TB_DONE;
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

//assign mask = max_i[2:0] ;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		mask <= 'd0;
	else if (max_i >= {read_len[7:3],3'b000})
		mask <= i_pos[2:0] - max_i[2:0];
	else 
		mask <= 3'b111 - max_i[2:0];
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) 
		rd_en <= 'd0;
	else if (TB_state == TB_START || (TB_state == TB_CAL && address))
		rd_en <= 1'b1;
	else
		rd_en <= 1'b0;
		//rd_en <= rd_en;
end

(* mark_debug = "true" *)reg [7:0] op;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n)
		n_cigar <= 'd0;
	else if (TB_state == TB_START)
		n_cigar <= 'd1;
	else if (TB_state == TB_CAL && cigar[1:0] != op[1:0] && init_flag)
		n_cigar <= n_cigar + 1'b1;
	else if (TB_state == TB_FLASH && op != cigar[1:0])
	   n_cigar <= n_cigar + 1'b1;
	else if (TB_state == TB_IDLE )
	   n_cigar<= 'd0;
	else
		n_cigar <= n_cigar;
end

//assign m_cigar = n_cigar << 1;
always @(*) begin

	case (which)
		8'b0000_0000 : op = 8'd0;
		8'b0000_0001 : op = 8'd2;
		default 	 : op = 8'd1;
	endcase // which
end

assign len = (!max_i) ? max_j : max_i;
/*always @(posedge sys_clk or negedge sys_rst_n) begin
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
end*/

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		cigar <= 'd0;
	else if (TB_state == TB_CAL && (!init_flag || op != cigar[1:0]) ) begin
		cigar <= op | 32'h0000_0010 ; // the cigar option len = 1;
	end else if (TB_state == TB_CAL && op == cigar[1:0] ) begin
		cigar <= cigar + 8'h10; //the cigar option len + 1;
	end else if (TB_state == TB_FLASH && op != cigar[1:0]) begin
		cigar <= op | (len << 4);
	end else if (TB_state == TB_FLASH && op == cigar[1:0]) begin
		cigar <= cigar + len << 4;
	end else if (TB_state == TB_DONE && !done_cnt) begin
		cigar <= n_cigar;
	end else if (TB_state == TB_DONE && done_cnt==2'b01 && !n_cigar[0])
		cigar <= 32'hFFFF_FFFF;
	/*end else if (TB_state == TB_DONE && done_cnt==2'b10)
		cigar <= 32'h0000_0000;*/

end


/*always @(posedge sys_clk or negedge sys_rst_n) begin : proc_cigar_en
	if(~sys_rst_n) begin
		cigar_en <= 'b0;
	end else if (((!max_i && !max_j) || (op != cigar[1:0])) && (hold_cnt == 2'b01 || TB_START == TB_FLASH)) begin
		cigar_en <= 1'b1;
	end else if (TB_state == TB_DONE && !done_cnt) begin
		cigar_en <= 1'b1;
	end	else if (TB_state == TB_DONE && done_cnt==2'b01 && !n_cigar[0]) begin
		cigar_en <= 1'b1;
	end else begin
		cigar_en <= 1'b0;
	end
end*/

always @(posedge sys_clk or negedge sys_rst_n) begin : proc_cigar_en
	if(~sys_rst_n) begin
		cigar_en <= 'b0;
	end else if ((TB_state == TB_CAL) && (op != cigar[1:0]) && init_flag) begin
		cigar_en <= 1'b1;
	end else if (TB_state == TB_FLASH && op != cigar[1:0]) begin
		cigar_en <= 1'b1;
	end else if (TB_state == TB_DONE && (done_cnt == 2'b01 || done_cnt == 2'b00)) begin // n_cigar
		cigar_en <= 1'b1;
	end	else if (TB_state == TB_DONE && done_cnt==2'b10 && !n_cigar[0]) begin // n_cigar
		cigar_en <= 1'b1;
	end else begin
		cigar_en <= 1'b0;
	end
end

reg [31:0] cigar_reg0;

always @(posedge sys_clk ) begin : proc_cigar_reg0
	 
	cigar_reg0 <= cigar;

end


assign tb_done = (done_cnt == 2'b11);

assign cigar0 = cigar_reg0;

endmodule