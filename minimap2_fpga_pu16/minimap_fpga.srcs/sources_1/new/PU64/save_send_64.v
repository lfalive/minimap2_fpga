`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2019 11:00:08 AM
// Design Name: 
// Module Name: sw_send
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sw_send_64 #(
	parameter PE_NUM 		= 64,
	parameter CIRCLE_SUM_BIT= 6,
	parameter RH_BANDWIDTH  = 4,
	parameter SUM_SAVE_BIT  = 3, //因为4bit,而数据大小是32位，不够则补零，因此要判断长度是否为8的整数倍
	parameter EN_LENGTH     = 14 //1+1+log(PE)+log(PE)
)
(

	//========input==========//
	sys_clk,
	core_clk,
	sys_rst_n,
	core_rst_n,
	matrix_memory_sop,
	matrix_memory_eop,
	matrix_memory_vld,
	matrix_memory_data,

	H_in,
	F_in,
	F2_in,
	bt_in,
	H1_init, //cj
	H2_init,
	E1_init,
	E2_init,
	vld,
	score_write,
	max_result,
	col_max_temp_in,
	row_max_result,
	col_max_result,
	diagonal_score,
	start_out,
	col_en_in,

	//===========output=========//
	pkt_receive_enable,
	start_in,
	final_row_en,
	mode,
	H_i_j_fifo,
	F_i_j_fifo,
	F2_i_j_fifo,
	score_init,
	Ns,
	Nr,
	H1_init_out,//cj
	H2_init_out,
	E1_init_out,
	E2_init_out,
	location,
	parameter_vld,
	pe_cnt,
	result,
	bt_en , 
	col_max_temp_out,
	max_clear,
	result_vld,

//==============
	fifo_start,
	fifo_vld,
	fifo_data,
	fifo_empty,
	fifo_eop

    );

/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/

/*function integer clogb2 (input integer bit_depth);
begin
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
bit_depth = bit_depth>>1;
end
endfunction*/

/*parameter PE_NUM = 8'd8;
parameter CIRCLE_SUM_BIT = clogb2(PE_NUM-1);
parameter RH_BANDWIDTH = 4;
//parameter SUM_SAVE_BIT = clogb2(32/RH_BANDWIDTH);
parameter SUM_SAVE_BIT = 3;
parameter EN_LENGTH = 8;//1 1 clogb2(PE_NUM) clogb2(PE_NUM)*/

parameter W_ADDR_R_LEFT    = 9'd0  ;
parameter W_ADDR_H_LEFT    = 9'd64 ;
parameter W_ADDR_R_RIGHT   = 9'd256;
parameter W_ADDR_H_RIGHT   = 9'd320;

parameter R_ADDR_R_LEFT    = 12'd0   ;
parameter R_ADDR_H_LEFT    = 12'd512 ;
parameter R_ADDR_R_RIGHT   = 12'd2048;
parameter R_ADDR_H_RIGHT   = 12'd2560;

parameter IDLE         = 11'b00000000001;
parameter GET_HEAD     = 11'b00000000010;
parameter GET_INFO     = 11'b00000000100;
parameter GET_R        = 11'b00000001000;
parameter GET_H        = 11'b00000010000;
parameter JUDGE_INPUT  = 11'b00000100000;
parameter WAIT_VLD     = 11'b00001000000;
parameter CALCULATE    = 11'b00010000000;
parameter TRACE_BACK   = 11'b00100000000;
parameter JUDGE_OUTPUT = 11'b01000000000;
parameter DONE         = 11'b10000000000;

parameter CAL_IDLE		 	= 9'b000000001;
parameter S0      		 	= 9'b000000010;
parameter S1      		 	= 9'b000000100;
parameter S2      		 	= 9'b000001000;
parameter S3      		 	= 9'b000010000;
parameter S4      		 	= 9'b000100000;
parameter S5      		 	= 9'b001000000;
parameter S6      		 	= 9'b010000000;
parameter CAL_DONE 			= 9'b100000000;

parameter LEFT 				= 1'b0;
parameter RIGHT 			= 1'b1;

parameter H_for_mismatch 	= 9'd5;  
parameter RESULT_LENGTH     = 512;
parameter PRE_RESULT_LENGHT = 160; //MAX MAX_ROW MAX_COL, DIAGONAL_SCORE

localparam CMP_LENGTH = 48;

/*-------------------------------------------------------------------*\
                          port Description                      
\*-------------------------------------------------------------------*/
input wire         sys_clk           ;
input wire         sys_rst_n         ;
input wire         core_rst_n        ;
input wire 		   core_clk 		 ;
input wire         matrix_memory_sop ;
input wire         matrix_memory_eop ;
input wire         matrix_memory_vld ;
input wire  [31:0] matrix_memory_data;
input wire  [15:0] H_in	             ;
input wire  [15:0] F_in	             ;
input wire  [15:0] F2_in	         ;
input wire  [63:0] bt_in 			 ;
input wire  [15:0] H1_init	         ;
input wire  [15:0] H2_init	         ;
input wire  [15:0] E1_init	         ;
input wire  [15:0] E2_init	         ;
input wire         vld               ;
input wire  [15:0] score_write   	 ;
input wire  [CMP_LENGTH-1:0] max_result 		 ; //48bit
input wire  [CMP_LENGTH-1:0] row_max_result 	 ;
input wire  [CMP_LENGTH-1:0] col_max_result 	 ;
input wire  [15:0] diagonal_score 	 ;
input wire 		   start_out 		 ;
input wire         col_en_in         ;
input wire [CMP_LENGTH-1 : 0] col_max_temp_in  ;
//output;
output wire        pkt_receive_enable;
output reg 		   start_in 		 ;
output wire [EN_LENGTH-1 : 0] final_row_en 	 ;
output reg         mode 			 ;
output wire [15:0] H_i_j_fifo 		 ;
output wire [15:0] F_i_j_fifo		 ;
output wire [15:0] F2_i_j_fifo		 ;
output wire [15:0] score_init 		 ;
output reg [CIRCLE_SUM_BIT:0] pe_cnt ;
output reg         parameter_vld 	 ;
output reg  [31:0 ] location 		 ;
output wire [RESULT_LENGTH-1:0] result 			 ;
output wire 		result_vld  	 ;
output reg 	   	    max_clear 	     ;
output reg  [CMP_LENGTH-1:0] col_max_temp_out	 ;

output reg  [15:0] H1_init_out	         ;
output reg  [15:0] H2_init_out	         ;
output reg  [15:0] E1_init_out	         ;
output reg  [15:0] E2_init_out	         ;

output wire [RH_BANDWIDTH-1:0] 	   Ns;
output wire [RH_BANDWIDTH-1:0] 	   Nr;

output reg bt_en;


input wire  fifo_start;
output wire fifo_vld;
output wire  fifo_eop;
output reg  fifo_empty;
output wire [63:0] fifo_data;
/*-------------------------------------------------------------------*\
                          Reg/wire Description
\*-------------------------------------------------------------------*/
(* mark_debug = "true" *) reg  [10:0]  current_state ;
reg  [10:0]  next_state    ;
wire        get_head_done ;
wire        get_info_done ;
wire        get_R_done    ;
wire        get_H_done    ;
wire        prepare_done  ;
wire        calculate_done;
reg         all_done      ;
reg         busy          ;
(* mark_debug = "true" *) reg  [ 3:0] ext_flag      ; 

reg        f_matrix_memory_sop ;
reg        f_matrix_memory_eop ;
reg        f_matrix_memory_vld ;
(* mark_debug = "true" *)reg [31:0] f_matrix_memory_data;

reg [15:0] read_len_left;
(* mark_debug = "true" *)reg [15:0] hap_len_left ;

reg [15:0] read_len_right;
(* mark_debug = "true" *)reg [15:0] hap_len_right ;

(* mark_debug = "true" *) reg [79:0] head         ;
reg [ 15:0] read_len     ;
reg [15:0] hap_len      ;
reg [12:0] read_len_mv_3;
reg [12:0] hap_len_mv_3 ;
reg [15:0] score_left   ;
reg [15:0] score_right  ;
reg [12:0] sum_save_R   ;
reg [12:0] sum_save_H   ;


reg  [31:0] data_in        ;
reg  [ 8:0] wraddress      ;
reg  [11:0] rdaddress      ;
reg         wren           ;
//reg         rden           ;
wire [ 3:0] data_out       ;



reg [  RH_BANDWIDTH-1:0] r           ;
reg [  RH_BANDWIDTH-1:0] h           ;
(* mark_debug = "true" *) reg [CIRCLE_SUM_BIT-1:0] sum_select  ;
reg [  CIRCLE_SUM_BIT-1:0] sum_select_0;
(* mark_debug = "true" *) reg [  CIRCLE_SUM_BIT:0] circle_left ;


(* mark_debug = "true" *) reg  [13:0] circle_cnt  ;
(* mark_debug = "true" *) reg  [13:0] circle_sum  ;
reg  [15:0]read_cnt    ;
reg  [15:0]hap_cnt     ;
reg        read_done   ;
wire       init        ;
reg  [5:0] cal_done_cnt;
reg  [2:0] son_cnt     ;



reg [8:0] cal_current_state;
reg [8:0] cal_next_state   ;
reg [3:0] wait_cnt         ;
reg       last_pe_vld      ;



wire [15:0] fifo_H_q;
wire [15:0] fifo_F_q;
wire [15:0] fifo_F2_q;
reg         wrreq   ;
reg         rdreq   ;
reg  [15:0] H_read  ;
reg  [15:0] F_read  ;
reg  [15:0] F2_read  ;
reg         aclr    ;

(* mark_debug = "true" *) reg pre_direction;
reg cal_direction;

reg [15:0] H_write;
reg [15:0] F_write;
reg [15:0] F2_write;

reg [1 :0] head_cnt        ;
reg        info_cnt        ;
reg [ 12:0] r_cnt           ;
(* mark_debug = "true" *) reg [ 12:0] h_cnt ;
reg        judge_input_done;
reg [15:0] score           ;
reg        wait_2clk_done  ;


(* mark_debug = "true" *) reg  [ PRE_RESULT_LENGHT-1:0] result_left      ;
(* mark_debug = "true" *) reg  [ PRE_RESULT_LENGHT-1:0] result_right     ;
reg          judge_output_done;
reg  [  6:0] done_cnt         ;
(* mark_debug = "true" *) reg  [RESULT_LENGTH-1:0] final_result     ;
(* mark_debug = "true" *) reg          final_vld        ;
reg  [  8:0] wr_base_addr_r   ;
reg  [  8:0] wr_base_addr_h   ;
wire [ 11:0] rd_base_addr_r   ;
wire [ 11:0] rd_base_addr_h   ;
wire [  9:0] H_fifo_num       ;
wire [  9:0] F_fifo_num       ;
wire [  9:0] F2_fifo_num       ;
reg  [PRE_RESULT_LENGHT-1 :0] pre_max_result   ;


wire empty_H;
wire empty_F;
wire empty_F2;
wire full_H ;
wire full_F ;
wire full_F2 ;

//*****************TB***************//
wire tb_done;

(* mark_debug = "true" *) reg flag_4;

always @(posedge sys_clk or negedge sys_rst_n)  //hap_len <7
begin
	if (!sys_rst_n) begin
		flag_4 <= 1'b0;
	end else if (hap_len <= sum_select + 1) begin 
		flag_4 <= 1'b1;
	end else begin 
		flag_4 <= 1'b0;
	end
end

assign pkt_receive_enable = (!busy); //busy信号表示当前模块正在处理数据，不能接收新的数据

always @ (posedge sys_clk ) //将输入的数据稳定一个时钟周期
begin 
	f_matrix_memory_sop <= matrix_memory_sop;
	f_matrix_memory_eop <= matrix_memory_eop;
	f_matrix_memory_vld <= matrix_memory_vld;
	f_matrix_memory_data<= matrix_memory_data;
end


//=======================Mealy FSM===============//
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		current_state <= 11'b0000000001;
	end else begin 
		current_state <= next_state;
	end 
end 

always @(*)
begin 
	next_state = current_state;
	case (current_state)
		IDLE:
			begin 
				if (matrix_memory_sop) begin
					next_state = GET_HEAD ;
				end

			end

		GET_HEAD :
			begin 
				if (get_head_done) begin 
					next_state = GET_INFO;
				end //
			end

		GET_INFO :
			begin 
				if (get_info_done && read_len_left == 8'd0 && pre_direction == LEFT) begin 
					next_state = GET_INFO;
				end else if (get_info_done && read_len_right == 8'd0 && pre_direction == RIGHT) begin 
					next_state = JUDGE_INPUT;
				end else if (get_info_done)begin 
					next_state = GET_R;
				end
			end

		GET_R :
			begin 
				if (get_R_done) begin 
					next_state = GET_H;
				end
			end

		GET_H :
			begin 
				if (get_H_done && pre_direction == LEFT) begin 
					next_state = GET_INFO;
				end else if (get_H_done) begin 
					next_state = JUDGE_INPUT;
				end
			end

		JUDGE_INPUT:
			begin 
				if (judge_input_done) begin 
					next_state = WAIT_VLD;
				end
			end	
		WAIT_VLD:
			begin 
				if (vld && read_len == 8'd0) begin 
					next_state = JUDGE_OUTPUT;
				end else if (vld) begin 
					next_state = CALCULATE;
				end 
			end

		CALCULATE :
			begin
				if (calculate_done) begin 
					next_state = TRACE_BACK;
				end
			end
			//*****************CJ***********//
		TRACE_BACK :
			begin
				if (tb_done) begin
					next_state = JUDGE_OUTPUT;
				end
			end

		JUDGE_OUTPUT:
			begin 
				if (judge_output_done && cal_direction == LEFT) begin 
					next_state = JUDGE_INPUT;
				end else if (judge_output_done)begin
					next_state = DONE;
				end
			end

		DONE :
			begin 
				if (all_done) begin 
					next_state = IDLE;
				end
			end

	endcase // current_state
end


//------------------------get_head------------------------//
//get_head 需要获取96位数据，由于data的位宽是32，所以需要三个时钟周期
always @(posedge sys_clk or negedge sys_rst_n)
begin
	if (!sys_rst_n) begin
		busy <= 1'b0;
	end else if (matrix_memory_sop) begin 
		busy <= 1'b1;
	end else if ((current_state == DONE) & all_done) begin 
		busy <= 1'b0;
	end 
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		head_cnt <= 0;
	end else if (head_cnt == 2'd2)begin 
		head_cnt <= 0;
	end else if (current_state == GET_HEAD) begin 
		head_cnt <= head_cnt + 1'b1;
	end 
end


always @(posedge sys_clk or negedge sys_rst_n)
begin
	if (!sys_rst_n) begin 
		head <= 80'd0;
	end else if (current_state == GET_HEAD && (head_cnt == 0)) begin 
		head[79:48] <= f_matrix_memory_data;
	end else if (head_cnt == 1) begin 
		head[47:16] <= f_matrix_memory_data;
	end else if (head_cnt == 2) begin 
		head[15: 0] <= f_matrix_memory_data[31:16];
	end
end

assign get_head_done = head_cnt == 2'd2;

//------------------------get_info------------------------//
//这里的info_cnt相当于get_info_flag

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		info_cnt <= 1'b0;
	end else if (info_cnt == 1) begin 
		info_cnt <= 1'b0;
	end else if (current_state == GET_INFO) begin 
		info_cnt <= 1'b1;
	end 
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		pre_direction <= LEFT;
	end else if (current_state == DONE) begin 
		pre_direction <= LEFT;
	end else if (get_info_done && read_len_left == 8'd0 && pre_direction == LEFT) begin 
		pre_direction <= RIGHT;
	end else if (get_H_done) begin 
		pre_direction <= ~pre_direction;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		hap_len_left <= 16'd0;
		read_len_left<= 16'd0;
	end else if (pre_direction == LEFT && current_state == GET_INFO && info_cnt == 1'b0) begin 
		hap_len_left <= f_matrix_memory_data[15: 0];
		read_len_left<=	f_matrix_memory_data[31:16];
	end 
end

always @(posedge sys_clk or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		hap_len_right <= 16'd0;
		read_len_right<= 16'd0;
	end else if (pre_direction == RIGHT && current_state == GET_INFO && info_cnt == 1'b0) begin 
		hap_len_right <= f_matrix_memory_data[15: 0];
		read_len_right<= f_matrix_memory_data[31:16];
	end 
end

//hap_len_mv_3和read_len_mv_3用于读取Nr和Ns，因为4bit,而数据大小是32位，不够则补零，因此要判断长度是否为8的整数倍
//sum_save_R:用于统计需要读取的个数
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		hap_len_mv_3 <= 13'd0;
		read_len_mv_3<= 13'd0;
	end else if (current_state == GET_INFO && info_cnt == 1'b0) begin 
		hap_len_mv_3 <= f_matrix_memory_data [15: 0] >> SUM_SAVE_BIT;
		read_len_mv_3<= f_matrix_memory_data [31:16] >> SUM_SAVE_BIT;
	end
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		sum_save_R <= 13'd0;
	end else if (pre_direction == LEFT && (read_len_left[SUM_SAVE_BIT-1:0] !=0) && (info_cnt == 1'b1)) begin 
		sum_save_R <= read_len_mv_3 + 1'b1;
	end else if (pre_direction == RIGHT &&(read_len_right[SUM_SAVE_BIT-1:0] !=0) && (info_cnt == 1'b1)) begin
		sum_save_R <= read_len_mv_3 + 1'b1;		
	end else if (info_cnt == 1'b1) begin 	
		sum_save_R <= read_len_mv_3;
	end 
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		sum_save_H <= 6'd0;
	end else if (pre_direction == LEFT && (hap_len_left[SUM_SAVE_BIT-1:0] != 0) && (info_cnt == 1'b1)) begin 
		sum_save_H <= hap_len_mv_3 + 1'b1;
	end else if (pre_direction == RIGHT&& (hap_len_right[SUM_SAVE_BIT-1:0] != 0) && (info_cnt == 1'b1)) begin 
		sum_save_H <= hap_len_mv_3 + 1'b1;
	end else if (info_cnt == 1'b1) begin 
		sum_save_H <= hap_len_mv_3;
	end
end

//==================Score_init===============//
always @(posedge sys_clk or negedge sys_rst_n)
begin
	if (!sys_rst_n) begin
		score_left <= 16'd0;
	end else if (pre_direction == LEFT && info_cnt == 1'b1) begin 
		score_left <= f_matrix_memory_data;
	end
end

/*always @(posedge sys_clk or negedge sys_rst_n)
begin
	if (!sys_rst_n) begin
		score_right <= 16'd0;
	end else if (current_state==JUDGE_OUTPUT && cal_direction == LEFT) begin 
		score_right <= result_left[79:64];
	end
end*/
always @(posedge sys_clk or negedge sys_rst_n)
begin
	if (!sys_rst_n) begin
		score_right <= 16'd0;
	end else if (pre_direction == RIGHT && info_cnt == 1'b1) begin 
		score_right <= f_matrix_memory_data;
	end
end

always @(posedge sys_clk )
begin 
	if (get_info_done && read_len_right == 8'd0 && pre_direction == RIGHT) begin 
		ext_flag[0] <= 1'b0;
	end else if (get_info_done && pre_direction == RIGHT) begin 
		ext_flag[0] <= 1'b1;
	end
end

always @(posedge sys_clk )
begin 
	if (get_info_done && read_len_left == 8'd0 && pre_direction == LEFT) begin 
		ext_flag[1] <= 1'b0;
	end else if (get_info_done && pre_direction == LEFT) begin 
		ext_flag[1] <= 1'b1;
	end
end

always @(posedge sys_clk)
begin 
	if (cal_direction == RIGHT && cal_done_cnt == circle_left && son_cnt == 4'd3) begin
		ext_flag[2] <= max_result[39:24] > score_right ;
	end else if (current_state == IDLE) begin 
		ext_flag[2] <= 1'b0;
	end
end 

always @(posedge sys_clk)
begin 
	if (cal_direction == LEFT && cal_done_cnt == circle_left && son_cnt == 4'd3) begin 
		ext_flag[3] <= max_result[39:24] > score_left ;
	end else if (current_state == IDLE) begin 
		ext_flag[3] <= 1'b0;
	end
end 
assign get_info_done = info_cnt == 1'b1;



//------------------------get_r------------------------//
always @(posedge sys_clk or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin
		r_cnt <= 13'd0;
	end else if (r_cnt == sum_save_R - 1'b1) begin 
		r_cnt <= 13'd0;
	end else if (current_state == GET_R) begin 
		r_cnt <= r_cnt + 1'b1;
	end
end

assign get_R_done = (current_state == GET_R ) & (r_cnt == sum_save_R - 1);

//------------------------GET_H = current_state[3] ------------------------//

always @(posedge sys_clk or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin
		h_cnt <= 13'd0;
	end else if (h_cnt == sum_save_H - 1'b1) begin 
		h_cnt <= 13'd0;
	end else if (current_state == GET_H) begin 
		h_cnt <= h_cnt + 1'b1;
	end 
end


assign get_H_done = (current_state == GET_H ) & (h_cnt == sum_save_H - 1);

(* mark_debug = "true" *) reg error_flag;
always @(posedge sys_clk )
begin 
	if (current_state == GET_H && sum_save_H == 'b0) begin 
		error_flag <= 1'b1;
	end else begin 
		error_flag <= 1'b0;
	end
end

//------------------------------JUDGE_INPUT------------------------------//
//问题：judge_input_done信号很奇怪，感觉就是延迟了一个时钟周期的功能
//JUDGE_INPUT就是用来控制 circle

always @(posedge sys_clk or negedge sys_rst_n)
begin
	if (!sys_rst_n) begin 
		judge_input_done <= 1'b0;
	end else if (judge_input_done) begin 
		judge_input_done <= 1'b0;
	end else if (current_state == JUDGE_INPUT)begin 
		judge_input_done <= 1'b1;
	end 
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		hap_len <= 16'd0;
	end else if (cal_direction == LEFT && current_state == JUDGE_INPUT) begin 
		hap_len <= hap_len_left;
	end else if (cal_direction == RIGHT && current_state == JUDGE_INPUT) begin
		hap_len <= hap_len_right;
	end 
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		read_len <= 8'd0;
	end else if (cal_direction == LEFT && current_state == JUDGE_INPUT) begin 
		read_len <= read_len_left;
	end else if (cal_direction == RIGHT && current_state == JUDGE_INPUT) begin
		read_len <= read_len_right;
	end 
end

//=====================Circle control====================//
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		circle_sum <= 'd0;
	end else if (current_state == DONE) begin 
		circle_sum <= 'd0;
	end else if (judge_input_done & (read_len[CIRCLE_SUM_BIT-1:0] == 0) ) begin 
		circle_sum <= read_len >> CIRCLE_SUM_BIT;     // 16 pe
	end else if (judge_input_done & (read_len[CIRCLE_SUM_BIT-1:0] != 0) ) begin 
		circle_sum <= (read_len >> CIRCLE_SUM_BIT) + 1'b1;
	end 
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		circle_left <= 'd0;
	end else if (current_state == DONE) begin 
		circle_left <= 'd0;
	end else if (judge_input_done & (read_len[CIRCLE_SUM_BIT-1:0] == 0))begin
		circle_left <= PE_NUM;
	end else if (judge_input_done) begin 
		circle_left <= read_len[CIRCLE_SUM_BIT-1:0];
	end
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		score <= 16'd0;
	end else if (current_state == DONE) begin 
		score <= 16'd0;
	end else if (cal_direction == LEFT && current_state == JUDGE_INPUT) begin
		score <= score_left;
	end else if (cal_direction == RIGHT && current_state == JUDGE_INPUT) begin 
		score <= score_right;
	end 
end

assign score_init = score;

//------------------------CALCULATE------------------------//
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		cal_current_state <= CAL_IDLE;
	end else begin 
		cal_current_state <= cal_next_state;
	end 
end

always @(*)
begin 
	cal_next_state = cal_current_state;
	case (cal_current_state)
		CAL_IDLE: begin 
			if (next_state == CALCULATE) begin
				cal_next_state = S0;
			end
		end

		S0: begin 
			cal_next_state = S1;
		end

		S1: begin 
			cal_next_state = S2;
		end

		S2: begin 
			cal_next_state = S3;
		end

		S3: begin 
			cal_next_state = S4;
		end

		S4: begin
			cal_next_state = S5;
		end // S4:

		S5: begin
			cal_next_state = S6;
		end

		S6: begin 
			if (!flag_4 & (read_cnt == read_len) & (hap_cnt == hap_len - 1'b1)) begin 
				cal_next_state = CAL_DONE;
			end else if (flag_4 & read_cnt == read_len - 1) begin 
				cal_next_state = CAL_DONE;
			end else begin
				cal_next_state = S0;
			end 
		end
		CAL_DONE : begin
			if (calculate_done) begin 
				cal_next_state = CAL_IDLE;
			end
		end
	endcase // cal_current_state
end

assign  calculate_done = (cal_done_cnt == circle_left ) & (son_cnt == 4'd6);

//S1

//todo :这里需要改动，初步想发是E_init放在F_wirte里

always @(posedge sys_clk )
begin 
	if (start_out) begin
		H_write <= score_write;
	end else begin 
		H_write <= H_in;
	end // end els
end

always @(posedge sys_clk )
begin 
	F_write <= F_in;
end

always @(posedge sys_clk )
begin 
	F2_write <= F2_in;
end

//S2

reg fifo_en;

always @(posedge sys_clk or negedge sys_rst_n)
begin
	if (!sys_rst_n) begin  
		fifo_en <= 1'b0;
	end else if(judge_output_done) begin
		fifo_en <= 1'b0;
	end else if (start_out && current_state == CALCULATE) begin
		fifo_en <= 1'b1;
	end 
end


always @(posedge sys_clk )
begin 
	if (cal_current_state == S1 && start_out) begin 
		wrreq <= 1'b1;
	end else if (cal_current_state == S1 && fifo_en)begin 
		wrreq <= 1'b1;
	end else begin
		wrreq <= 1'b0;
	end 
end


always @(posedge sys_clk )
begin 
	if ( mode & (cal_current_state == S2)) begin 
		rdreq <= 1'b1;
	end else begin 
		rdreq <= 1'b0;
	end
end

/***************TEST***************/
reg rdreq_reg;

always @(posedge sys_clk )
begin 
	rdreq_reg <= rdreq;
end

always @(posedge sys_clk )
begin 
	if (!sys_rst_n) begin
		H_read <= 32'd0;
		F_read <= 32'd0;
		F2_read <= 32'd0;
	end else if (rdreq_reg) begin 
		H_read <= fifo_H_q;
		F_read <= fifo_F_q;
		F2_read <= fifo_F2_q;
	end 
end

/***************END*****************/


/*always @(posedge sys_clk )
begin 
	if (!sys_rst_n) begin
		H_read <= 32'd0;
		F_read <= 32'd0;
		F2_read <= 32'd0;
	end else if (rdreq) begin 
		H_read <= fifo_H_q;
		F_read <= fifo_F_q;
		F2_read <= fifo_F2_q;
	end 
end*/

assign H_i_j_fifo = H_read;
assign F_i_j_fifo = F_read;
assign F2_i_j_fifo = F2_read;

//S3

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		r <= 4'd0;
	end else if (cal_current_state == S3) begin  
		r <= data_out;
 	end 
end 

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		location <= 32'd0;
	end else if (cal_current_state == S3) begin 
		location <= {16'd0,read_cnt};
 	end
end


//S4 todo H_for_mismatch 
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		h <= 4'd0;
	end else if (hap_cnt == hap_len) begin 
		h <= H_for_mismatch;
	end else if (cal_current_state == S4) begin 
		h <= data_out;
 	end 
end



always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		sum_select <= PE_NUM - 1'b1;
	end else if (judge_output_done) begin 
		sum_select <= PE_NUM - 1'b1;
	end else if ((circle_cnt == circle_sum - 1'b1) && current_state == CALCULATE) begin 
		sum_select <= circle_left - 1'b1;
	end
end  


always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		//sum_select <= PE_NUM - 1;
		sum_select_0 <= PE_NUM - 1'b1;
	end else if (!flag_4 & (cal_current_state == S6) & (read_cnt == read_len) & (hap_cnt == hap_len - 1'b1)) begin
		sum_select_0 <= PE_NUM - 1'b1;
	end else if (flag_4 & (cal_current_state == S6) & (read_cnt == read_len - 1)) begin
		sum_select_0 <= PE_NUM - 1'b1;
	end else if ((circle_cnt == circle_sum - 1'b1) && cal_current_state == S4) begin 
		sum_select_0 <= circle_left - 1;
	end else if (cal_current_state == S4 ) begin 
		sum_select_0 <= PE_NUM - 1'b1;
	end 
end  

assign Ns = h;
assign Nr = r;

//======================bt_en================//

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		bt_en <= 'b0;
	else if ((cal_done_cnt == circle_left) & (son_cnt == 4'd6))
		bt_en <= 'b0;
	else if ((read_cnt == PE_NUM-1 || read_cnt == read_len) && cal_current_state == S5)
		bt_en <= 'b1;
	else
		bt_en <= bt_en;
end

//=====================end===================//

always @(posedge sys_clk )
begin 
	if ((cal_current_state == S4) || son_cnt == 3'd4) begin 
		parameter_vld <= 1'b1;
	end else begin 
		parameter_vld <= 1'b0;
	end
end


always @(posedge sys_clk)
begin 
	if (current_state == CALCULATE) begin 
		max_clear <= 1'b0;
	end else begin
		max_clear <= 1'b1;
	end // end else
end

//S5

//S6

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin    
		hap_cnt <= 16'd0;
	end else if (flag_4 & (cal_current_state == S6) & (pe_cnt   == sum_select)) begin 
		hap_cnt <= 16'd0;
	end else if (!flag_4 & (cal_current_state == S6) & (hap_cnt == hap_len - 1'b1)) begin 
		hap_cnt <= 16'd0;
	end else if (cal_current_state == S6 & (hap_cnt <= hap_len - 1'b1)) begin 
		hap_cnt <= hap_cnt + 1'b1;
	end
end



always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		read_cnt <= 16'd0;
	end else if (flag_4 & (cal_current_state == S6) & (read_cnt == read_len-1'b1)) begin 
		read_cnt <= 16'd0;
	end else if (!flag_4 & (cal_current_state == S6) & (read_cnt == read_len) & (hap_cnt == hap_len - 1'b1)) begin
		read_cnt <= 16'd0;
	end else if ((cal_current_state == S6) & (pe_cnt <= sum_select)) begin 
		read_cnt <= read_cnt + 1'b1;
	end
end





always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		pe_cnt <= 6'd0;
	end else if (flag_4 & (cal_current_state == S6) & pe_cnt == sum_select) begin 
		pe_cnt <= 6'd0;
	end else if (!flag_4 & (cal_current_state == S6) & (hap_cnt == hap_len - 1)) begin 
		pe_cnt <= 6'd0;
	end else if ((cal_current_state == S6) & (pe_cnt <= sum_select)) begin 
		pe_cnt <= pe_cnt + 1'b1;
	end 
end


always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		circle_cnt <= 'd0;
	end else if (flag_4 & (cal_current_state == S6) &  (read_cnt == read_len - 1))	begin
		circle_cnt <= 'd0;
	end else if (!flag_4 & (cal_current_state == S6) & (circle_cnt == circle_sum - 1'b1) & (hap_cnt == hap_len - 1)) begin 
		circle_cnt <= 'd0;
	end else if (flag_4 & (cal_current_state == S6) & (pe_cnt   == sum_select)) begin 
		circle_cnt <= circle_cnt + 1'b1;
	end else if (!flag_4 & (cal_current_state == S6) & (hap_cnt == hap_len - 1)) begin
		circle_cnt <= circle_cnt + 1'b1;
	end
end



always @(posedge sys_clk )
begin 
	if (hap_cnt == 16'd0 && cal_current_state == S5) begin 
		start_in <= 1'b1;
	end else begin 
		start_in <= 1'b0;
	end // end else
end
//===============================cj==========================/
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		E1_init_out <= 16'd0;
	end
	else if (cal_current_state == S1 && start_out) begin 
		E1_init_out <= E1_init;
	end else begin
		E1_init_out <= E1_init_out;
	end 
end
always @(posedge sys_clk )
begin 
	if (!sys_rst_n) begin
		E2_init_out <= 16'd0;
	end
	else if (cal_current_state == S1 && start_out) begin 
		E2_init_out <= E2_init;
	end else begin
		E2_init_out <= E2_init_out;
	end 
end

always @(posedge sys_clk )
begin 
	if (!sys_rst_n) begin
		H1_init_out <= 16'd0;
	end
	else if (cal_current_state == S1 && start_out) begin 
		H1_init_out <= H1_init;
	end else begin
		H1_init_out <= H1_init_out;
	end 
end
always @(posedge sys_clk )
begin 
	if (!sys_rst_n) begin
		H2_init_out <= 16'd0;
	end
	else if (cal_current_state == S1 && start_out) begin 
		H2_init_out <= H2_init;
	end else begin
		H2_init_out <= H2_init_out;
	end 
end

/*always @(posedge sys_clk )
begin 
	if (hap_cnt == 16'd0 && cal_current_state == S5) begin 
		E1_init_out <= E1_init_temp;
	end else begin 
		E1_init_out <= E1_init_out;
	end // end else
end
always @(posedge sys_clk )
begin 
	if (hap_cnt == 16'd0 && cal_current_state == S5) begin 
		E2_init_out <= E2_init_temp;
	end else begin 
		E2_init_out <= E2_init_out;
	end // end else
end*/

//=============================END=========================//
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		mode <= 1'b0;
	end else if (judge_output_done) begin 
		mode <= 1'b0;	
	end else if (flag_4  && pe_cnt  == sum_select && cal_current_state == S6) begin 
		mode <= 1'b1;
	end else if (!flag_4 && hap_cnt == hap_len - 1 && cal_current_state == S6) begin 
		mode <= 1'b1;
	end
end

 

//CAL_DONE
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		son_cnt <= 4'd0;
	end else if (son_cnt == 4'd6) begin
		son_cnt <= 4'd0;
	end else if (cal_current_state == CAL_DONE) begin
		son_cnt <= son_cnt + 1'b1;
	end
end


always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		cal_done_cnt <= 6'd0;
	end else if ((cal_done_cnt == circle_left ) & (son_cnt == 4'd6)) begin 
		cal_done_cnt <= 6'd0;
	end else if (son_cnt == 4'd6) begin 
		cal_done_cnt <= cal_done_cnt + 1'b1;
	end
end

always @(posedge sys_clk )
begin 
	if ((cal_done_cnt == circle_left - 1) & (son_cnt == 4'd5)) begin 
		last_pe_vld <= 1'b1;
	end else begin 
		last_pe_vld <= 1'b0;
	end // end else
end
//======================CJ==================//
reg col_en;
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		col_en <= 1'b0;
	end else if ((cal_current_state == S5) & (hap_cnt == hap_len - 1'b1)) begin
		col_en <= 1'b1;
	end else begin
		col_en <= 1'b0;
	end
end
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		col_max_temp_out  <= 40'sh8fff;
	end else if (col_en_in == 1'b1) begin
		col_max_temp_out <= col_max_temp_in;
	end else begin
		col_max_temp_out <= col_max_temp_out;
	end
end
//========================END===================//
assign final_row_en = {col_en, last_pe_vld,sum_select,sum_select_0};// TODO: use variable length data

(* mark_debug = "true" *)  wire [39:0] f0_max_result;
assign f0_max_result = max_result;

/*always @(posedge sys_clk )
begin 
	if (max_result[39:24] <= score_left && cal_direction == LEFT  )begin
		pre_max_result <= {score_left,24'b0,row_max_result,col_max_result, diagonal_score};
	end else if (max_result[39:24] <= score_right && cal_direction == RIGHT) begin 
		pre_max_result <= {score_right,24'b0,row_max_result, col_max_result, diagonal_score};
	end else begin 
		pre_max_result <= {max_result,row_max_result, col_max_result, diagonal_score};
	end
end*/

always @(posedge sys_clk )
begin 
	if (max_result[47:32] <= score_left && cal_direction == LEFT  )begin
		pre_max_result <= {score_left,32'b0,row_max_result,col_max_result, diagonal_score};
	end else if (max_result[47:32] <= score_right && cal_direction == RIGHT) begin 
		pre_max_result <= {score_right,32'b0,row_max_result, col_max_result, diagonal_score};
	end else begin 
		pre_max_result <= {max_result,row_max_result, col_max_result, diagonal_score};
	end
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		result_left <= 'd0;
	end else if (judge_input_done && cal_direction == LEFT) begin
		result_left <= {score_left,144'd0};
	end else if (cal_direction == LEFT && cal_done_cnt == circle_left && son_cnt == 4'd4) begin 
		result_left <= pre_max_result;
	end
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		result_right <= 'd0;
	end else if (current_state == JUDGE_INPUT && cal_direction == RIGHT) begin
		result_right <= {score_right,144'd0};
	end else if (cal_direction == RIGHT && cal_done_cnt == circle_left && son_cnt == 4'd4) begin 
		result_right <= pre_max_result;
	end
end

always @(posedge sys_clk)
begin 
	if (judge_output_done) begin
		aclr <= 1'b1;
	end else begin 
		aclr <= 1'b0;
	end
end

//----------------------------- JUDGE OUTPUT ----------------------------//



always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		judge_output_done <= 1'b0;
	end else if (judge_output_done) begin
		judge_output_done <= 1'b0;
	end else if (current_state == JUDGE_OUTPUT) begin
		judge_output_done <= 1'b1;
	end
end


always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		cal_direction <= LEFT;
	end else if (current_state == DONE) begin 
		cal_direction <= LEFT;
	end else if (judge_output_done) begin 
		cal_direction <= ~cal_direction;
	end 
end


//----------------------------- DONE ----------------------------//

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		done_cnt <= 7'd0;
	end else if (done_cnt == 7'd30) begin 
		done_cnt <= 7'd0;
	end else if (current_state == DONE) begin 
		done_cnt <= done_cnt + 1'b1;
	end 
end

reg [31:0] unit_num;

/*always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		unit_num <= 'd0;
	else if (current_state == GET_HEAD)
		unit_num <= 'd8;  //512 bit max result
	else if (start_in==1 && mode == 1'b0)
		unit_num <= unit_num + bt_num; //bt_result
	else if (current_state == DONE&& done_cnt == 7'd4)
		unit_num <= 'd0;
	else
		unit_num <= unit_num;
end*/
wire [7:0] n_cigar;
always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		unit_num <= 'd0;
	else if (current_state == GET_HEAD)
		unit_num <= 'd8;  //512 bit max result
	else if (tb_done)
		unit_num <= unit_num + (n_cigar>>1) + 1'b1; //bt_num stand for the 64bit cigar+n_cigar
	else if (current_state == DONE&& done_cnt == 7'd4)
		unit_num <= 'd0;
	else
		unit_num <= unit_num;
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		final_result <= 512'd0;
	end else if (current_state == DONE && done_cnt == 7'd2) begin
		final_result <={unit_num, read_len_left, hap_len_left, read_len_right, hap_len_right,head,4'b0,ext_flag,8'b0,result_left,result_right}; //32+32+32+80+16+160+160
	end 
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n)
		final_vld <= 'b0;
	else if (current_state == DONE && done_cnt == 7'd2) begin
		final_vld <= 1'b1;
	end else if (current_state == DONE && done_cnt == 7'd9)begin 
		final_vld <= 1'b0;
	end else begin // end else
		final_vld <= final_vld;
	end
end

assign result     = final_result;
assign result_vld = final_vld	;

wire full_max, empty_max;
wire max_rd_en;
wire [63:0] max_result_out;

fifo_64x128_512x16 fifo_max (
  .wr_clk(sys_clk),  // input wire wr_clk
  .rd_clk(core_clk),  // input wire rd_clk
  .din(result),        // input wire [511 : 0] din
  .wr_en(result_vld),    // input wire wr_en
  .rd_en(max_rd_en),    // input wire rd_en
  .dout(max_result_out),      // output wire [63 : 0] dout
  .full(full_max),      // output wire full
  .empty(empty_max)    // output wire empty
);

always @(posedge sys_clk )
begin 
	if (done_cnt == 7'd29) begin 
		all_done <= 1'b1;
	end else begin 
		all_done <= 1'b0;
	end
end

//----------------------------- RAM ROM Operations----------------------------//

//ram_2port_512x32
//ram :用于将32位的NS和NR转换成4位的输入和输出

always @(posedge sys_clk )
begin
	if (pre_direction) begin
		wr_base_addr_r <= W_ADDR_R_RIGHT;
		wr_base_addr_h <= W_ADDR_H_RIGHT;
	end else begin 
		wr_base_addr_r <= W_ADDR_R_LEFT;
		wr_base_addr_h <= W_ADDR_H_LEFT;
	end // 
end




// assign wr_base_addr_r = (pre_direction)? ADDR_R_RIGHT:ADDR_R_LEFT;
// assign wr_base_addr_h = (pre_direction)? ADDR_H_RIGHT:ADDR_H_LEFT;

assign rd_base_addr_r = (cal_direction)? R_ADDR_R_RIGHT:R_ADDR_R_LEFT;
assign rd_base_addr_h = (cal_direction)? R_ADDR_H_RIGHT:R_ADDR_H_LEFT;


always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		wraddress <= 9'd0;
	end else if (current_state == GET_R ) begin
		wraddress <= wr_base_addr_r + r_cnt;
	end else if (current_state == GET_H ) begin 
		wraddress <= wr_base_addr_h + h_cnt;
	end 
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		wren <= 1'b0;
	end else if (current_state == GET_R || current_state == GET_H) begin 
		wren <= 1'b1;
	end else begin 
		wren <= 1'b0;
	end
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		data_in <= 32'd0;
	end else begin  
		data_in <= {f_matrix_memory_data[3:0],f_matrix_memory_data[7:4],f_matrix_memory_data[11:8],f_matrix_memory_data[15:12],f_matrix_memory_data[19:16],f_matrix_memory_data[23:20],f_matrix_memory_data[27:24],f_matrix_memory_data[31:28]};
	end 
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		rdaddress <= 12'd0;
	end else if (cal_current_state == S0) begin 
		rdaddress <= rd_base_addr_r + read_cnt;
	end else if (cal_current_state == S1) begin
		rdaddress <= rd_base_addr_h + hap_cnt;
	end
end

//========================BT_OUT===================//
reg [15:0] bt_num_temp, bt_num, bt_temp; //(((read_len-1) >> 3) + 1)*hap_len + 1'b1
always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n)
		bt_num_temp <= 'd0;
	else
		bt_num_temp <= ((read_len-1) >> 3) + 1'b1;
end

reg [15:0] hap_len_reg;
always @ (posedge sys_clk) begin
    hap_len_reg <= hap_len;
 end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n)
		bt_temp <= 'd0;
	else
		bt_temp <= bt_num_temp*hap_len_reg + 1'b1;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n)
		bt_num <= 'd0;
	else
		bt_num <= bt_temp;
end

wire [63:0] fifo_bt_in;
wire [63:0] fifo_bt_out;
reg fifo_bt_w_en, fifo_bt_r_en;

wire full_bt, empty_bt;


assign fifo_bt_in = (bt_en==1)? bt_in : bt_num;
always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (! sys_rst_n)
		fifo_bt_w_en <= 1'b0;
	else if (start_in==1 && mode == 1'b0)
		fifo_bt_w_en <= 1'b1; //write the bt data num
	else if ((cal_current_state == S2 || son_cnt == 'd2 ) && bt_en == 1'b1 )
		fifo_bt_w_en <= 1'b1; // write the bt data
	else
		fifo_bt_w_en <= 1'b0;
end

//reg [7:0] result_num;
//reg [7:0]  result_count;
//todo whether we need pp one clk for fifo_start
/*always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		fifo_bt_r_en <= 'b0;
	else if (fifo_start)
		fifo_bt_r_en <= 'b1;
	else if (result_count == result_num-1'b1)
		fifo_bt_r_en <= 'b0;
	else
		fifo_bt_r_en <= fifo_bt_r_en;
end


always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		result_num <= 'd0;
	else if (fifo_start)
		result_num <= fifo_bt_out;
	else if (fifo_eop)
		result_num <= 'd0;
	else
		result_num <= result_num;
end

always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		result_count <= 'd0;
	else if (fifo_start) 
		result_count <= 'd0;
	else if (result_count == result_num-1'b1)
		result_count <= 'd0;
	else if (fifo_vld)
		result_count <= result_count + 1'b1;
	else
		result_count <= result_count;
end*/

reg f0_bt_en;

always @ (posedge sys_clk) begin
	f0_bt_en <= bt_en;
end


//fifo_count //Asyn FIFO
reg  [7:0] fifo_w_count;
reg  [7:0] fifo_r_count;

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		fifo_w_count <= 'd0;
	else if (current_state == DONE && done_cnt == 7'd3)
		fifo_w_count <= fifo_w_count + 1'b1;
	else
		fifo_w_count <= fifo_w_count;
end

always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		fifo_r_count <= 'd0;
	else if (fifo_start)
		fifo_r_count <= fifo_r_count + 1'b1;
end
wire a_full, a_empty;
wire [7:0] afifo_w_count;
afifo_16x8 p0 (
  .wr_clk(sys_clk           ), // input wire wr_clk
  .rd_clk(core_clk          ), // input wire rd_clk
  .din   (fifo_w_count      ), // input wire [0 : 0] din
  .wr_en (~a_full   		), // input wire wr_en
  .rd_en (~a_empty       ), // input wire rd_en
  .dout  (afifo_w_count     ), // output wire [0 : 0] dout
  .full  (a_full         ), // output wire full
  .empty (a_empty        )  // output wire empty
  
);

always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		fifo_empty =  'b1;
	else if (afifo_w_count == fifo_r_count)
		fifo_empty <= 'b1;
	else 
		fifo_empty <= 'b0;
end

/*always @ (posedge core_clk or negedge core_rst_n) begin
	if (!core_rst_n)
		fifo_eop <= 'b0;
	else if (result_count == result_num-1'b1 && fifo_vld)
		fifo_eop <= 'b1;
	else
		fifo_eop <= 'b0;
end*/

wire bt_rd_en;
wire [63:0] bt_result;

fifo_64x128 fifo_bt (
  .wr_clk(sys_clk),  // input wire wr_clk
  .wr_rst(~sys_rst_n),  // input wire wr_rst
  .rd_clk(core_clk),  // input wire rd_clk
  .rd_rst(~core_rst_n),  // input wire rd_rst
  .din(fifo_bt_in),        // input wire [63 : 0] din
  .wr_en(fifo_bt_w_en),    // input wire wr_en
  .rd_en(bt_rd_en),    // input wire rd_en
  .dout(bt_result),      // output wire [63 : 0] dout
  .full(full_bt),      // output wire full
  .empty(empty_bt)   // output wire empty

);

//assign fifo_data = fifo_bt_out;
//assign fifo_vld = fifo_bt_r_en;

//=====================END=======================//
fifo_512x16 fifo_H (
  .clk(sys_clk),                  // input wire clk
  .srst(aclr),                // input wire srst
  .din(H_write),                  // input wire [31 : 0] din
  .wr_en(wrreq),              // input wire wr_en
  .rd_en(rdreq),              // input wire rd_en
  .dout(fifo_H_q),                // output wire [31 : 0] dout
  .full(full_H),                // output wire full
  .empty(empty_H),              // output wire empty
  .data_count(H_fifo_num)    // output wire [9 : 0] data_count
);


fifo_512x16 fifo_F (
  .clk(sys_clk),                  // input wire clk
  .srst(aclr),                // input wire srst
  .din(F_write),                  // input wire [31 : 0] din
  .wr_en(wrreq),              // input wire wr_en
  .rd_en(rdreq),              // input wire rd_en
  .dout(fifo_F_q),                // output wire [31 : 0] dout
  .full(full_F),                // output wire full
  .empty(empty_F),              // output wire empty
  .data_count(F_fifo_num)    // output wire [9 : 0] data_count
);
fifo_512x16 fifo_F2 (
  .clk(sys_clk),                  // input wire clk
  .srst(aclr),                // input wire srst
  .din(F2_write),                  // input wire [31 : 0] din
  .wr_en(wrreq),              // input wire wr_en
  .rd_en(rdreq),              // input wire rd_en
  .dout(fifo_F2_q),                // output wire [31 : 0] dout
  .full(full_F2),                // output wire full
  .empty(empty_F2),              // output wire empty
  .data_count(F2_fifo_num)    // output wire [9 : 0] data_count
);


//read和hap由32位变4位
ram_2port_512x32_4096x4 ram (
  .clka(sys_clk),    // input wire clka
  .wea(wren),      // input wire [0 : 0] wea
  .addra(wraddress),  // input wire [8 : 0] addra
  .dina(data_in),    // input wire [31 : 0] dina
  .clkb(sys_clk),    // input wire clkb
  .addrb(rdaddress),  // input wire [11 : 0] addrb
  .doutb(data_out)  // output wire [3 : 0] doutb
);

//---------------------------------------------------------------

max_bt max_bt(
	.core_clk(core_clk),
	.core_rst_n(core_rst_n),
	.max_rd_en(max_rd_en),
	.max_result(max_result_out),
	.bt_rd_en (bt_rd_en),
	.bt_result(bt_result),
	.rd_start(fifo_start),
	.vld_out(fifo_vld),
	//.sop_out(),
	.data_out(fifo_data),
	.eop_out(fifo_eop)
	);

//----------------------BT2RAM---------------//
wire [63:0] ram_bt_out;
wire rd_en;
reg ram_bt_w_en;
wire [10:0] addra;
reg [10:0] waddr;
reg [10:0] raddr;

wire tb_start;

/*BT_RAM bt_ram(
  .clka(sys_clk),
  .ena(rd_en),
  .wea(ram_bt_w_en),
  .addra(addra),
  .dina(fifo_bt_in),
  .douta(ram_bt_out)
);



always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (! sys_rst_n)
		ram_bt_w_en <= 1'b0;
	else if ((cal_current_state == S2 || son_cnt == 'd2 ) && bt_en == 1'b1 )
		ram_bt_w_en <= 1'b1; // write the bt data
	else
		ram_bt_w_en <= 1'b0;
end

assign tb_start = calculate_done;
always @(posedge sys_clk or negedge sys_rst_n) begin : proc_addra
	if(~sys_rst_n) begin
		waddr <= 'd0;
	end else if (tb_start) begin
		waddr <= 'd0;  //address increase circle_sum
	end else if (ram_bt_w_en) begin
		waddr <= waddr + 1'b1;  //address increase circle_sum
	end
end

assign addra = rd_en ? raddr : waddr;

reg [15:0] max_j;
reg [7:0] max_i;
always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		max_i <= 'd0;
		max_j <= 'd0;
	end else if (current_state == JUDGE_INPUT && cal_direction == RIGHT) begin
		max_i <= 'd0;
		max_j <= 'd0;
	end else if (cal_done_cnt == circle_left && son_cnt == 4'd4) begin 
		max_j <= pre_max_result[135:120] + 1'b1;
		max_i <= pre_max_result[119:112] + 1'b1; //plus 1 is benefit for the calculate
	end
end

wire [7:0] mask;
wire [7:0] n_cigar;
wire [7:0] m_cigar;

wire cigar_en;
wire [31:0] cigar;
reg [7:0] cigar_bt_in;
always @(*) begin : proc_bt_in
	case (mask)
		3'b000 : cigar_bt_in = ram_bt_out[7 :0] ;
		3'b001 : cigar_bt_in = ram_bt_out[15:8] ;
		3'b010 : cigar_bt_in = ram_bt_out[23:16];
		3'b011 : cigar_bt_in = ram_bt_out[31:24];
		3'b000 : cigar_bt_in = ram_bt_out[39:32];
		3'b001 : cigar_bt_in = ram_bt_out[47:40];
		3'b010 : cigar_bt_in = ram_bt_out[55:48];
		3'b011 : cigar_bt_in = ram_bt_out[63:56];
	endcase
end
wire [15:0] t_len;
assign t_len = (cal_direction == LEFT) ? read_len_left : read_len_right;*/

reg [31:0] tb_cnt;
reg [31:0] tb_num;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		tb_num <= 'd0;
	else if (calculate_done)
		tb_num <= read_len*6;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)
		tb_cnt <= 'd0;
	else if (current_state == TRACE_BACK)
		tb_cnt <= tb_cnt + 1'b1;
	else 
		tb_cnt <= 'd0;
end

assign tb_done = (tb_cnt == tb_num) ? 1'b1 : 1'b0;
/*cigar_cal cigar_dut(
	.sys_clk	(sys_clk	),
	.sys_rst_n	(sys_rst_n	),
	.bt_in  	(cigar_bt_in),
	.tb_start	(tb_start	),
	.i_pos		(max_i 		),
	.j_pos		(max_j		),

	.address	(raddr		),
	.rd_en 		(rd_en 		),
	.mask 		(mask		),
	.n_cigar 	(n_cigar	),
	//.m_cigar	(m_cigar	),
	.cigar0 	(cigar 		),
	.cigar_en	(cigar_en	),
	.t_len 		(t_len		),
	.tb_done	(tb_done	)
	);*/


endmodule
