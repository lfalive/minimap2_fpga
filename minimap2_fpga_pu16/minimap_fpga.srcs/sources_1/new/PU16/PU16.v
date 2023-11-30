`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2019 09:31:06 AM
// Design Name: 
// Module Name: PU8
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
//由于PU只进行计算而没有控制，因此它计算的控制信号都要从sw_send出传出来，因此导致接口较多。
//但是这样模块分工的优点是PU代码比较简洁并且只管计算
//还可以在PU上设置状态机，通过一根信号使得PU的状态和外部状态可以同步，这样PU就有控制和计算两部分
//since the control signal is too many, we can use the interface
module PU16 #(
	parameter integer DATA_WIDTH  = 4,
	parameter integer SCORE_WIDTH = 16,
	parameter integer LOCATION_WIDTH = 32,
	parameter integer PE_NUM = 16,
    parameter integer LOG_PE_NUM = 4,
    parameter integer BT_OUT_WIDTH = 64,
    parameter integer EN_LENGTH = 10,
    parameter integer CMP_RESULT_WIDTH = 48
)
(
//==========input===============//
	sys_clk       ,
	sys_rst_n     ,
	
	Ns            ,

    Nr_0          ,
    Nr_1          ,
    Nr_2          ,
    Nr_3          ,
    Nr_4          ,
    Nr_5          ,
    Nr_6          ,
    Nr_7          ,
    Nr_8          ,
    Nr_9          ,
    Nr_10          ,
    Nr_11         ,
    Nr_12         ,
    Nr_13         ,
    Nr_14         ,
    Nr_15         ,

	Score_init    ,
    H1_init       ,
    H2_init       ,
    E1_init       ,
    E2_init       ,
    col_max_in    ,

	mode          , //低电平表示第一次，高电平表示轮询
	final_row_en  ,
	start_in      ,
	
	H_i_j_fifo    ,
	F_i_j_fifo    ,
	F2_i_j_fifo	  ,
	
	//location_in  ,
    location_in_0 ,
    location_in_1 ,
    location_in_2 ,
    location_in_3 ,
    location_in_4 ,
    location_in_5 ,
    location_in_6 ,
    location_in_7 ,
    location_in_8 ,
    location_in_9 ,
    location_in_10 ,
    location_in_11,
    location_in_12,
    location_in_13 ,
    location_in_14 ,
    location_in_15 ,

//==========output===============//
    Ns_out                  ,
    H_i_j_out               ,
    F_i_j_out              ,
    F2_i_j_out				,
    Score_out               ,
    //H_init_out              ,
    E1_init_out             ,
    E2_init_out             ,
    H1_init_out             ,
    H2_init_out             ,
    
    H_row_max_last          , //最后一个PE的最大值
    H_row_max_last_location ,
    H_col_max,
    H_col_max_location      ,
    col_max_out             ,
    diagonal_score          ,

    bt_en                   ,
    bt_flag                 , // 

    
    start_out               ,
    bt_out                  ,
    bt_out0                 , //
    col_en                  ,
    H_max_out               ,
    H_max_location

    );

input wire sys_clk   ;
input wire sys_rst_n ;

input wire mode      ;
input wire start_in  ;
input wire [EN_LENGTH-1 : 0] final_row_en   ;

input wire [DATA_WIDTH-1: 0] Ns;
input wire [DATA_WIDTH-1: 0] Nr_0;
input wire [DATA_WIDTH-1: 0] Nr_1;
input wire [DATA_WIDTH-1: 0] Nr_2;
input wire [DATA_WIDTH-1: 0] Nr_3;
input wire [DATA_WIDTH-1: 0] Nr_4;
input wire [DATA_WIDTH-1: 0] Nr_5;
input wire [DATA_WIDTH-1: 0] Nr_6;
input wire [DATA_WIDTH-1: 0] Nr_7;
input wire [DATA_WIDTH-1: 0] Nr_8;
input wire [DATA_WIDTH-1: 0] Nr_9;
input wire [DATA_WIDTH-1: 0] Nr_10;
input wire [DATA_WIDTH-1: 0] Nr_11;
input wire [DATA_WIDTH-1: 0] Nr_12;
input wire [DATA_WIDTH-1: 0] Nr_13;
input wire [DATA_WIDTH-1: 0] Nr_14;
input wire [DATA_WIDTH-1: 0] Nr_15;

//input wire [DATA_WIDTH-1 : 0] Nr[PE_NUM-1 : 0];
//input Wire [LOCATION_WIDTH_1 : 0] location_in[PE_NUM-1 : 0];

input wire [LOCATION_WIDTH-1:0] location_in_0;
input wire [LOCATION_WIDTH-1:0] location_in_1;
input wire [LOCATION_WIDTH-1:0] location_in_2;
input wire [LOCATION_WIDTH-1:0] location_in_3;
input wire [LOCATION_WIDTH-1:0] location_in_4;
input wire [LOCATION_WIDTH-1:0] location_in_5;
input wire [LOCATION_WIDTH-1:0] location_in_6;
input wire [LOCATION_WIDTH-1:0] location_in_7;

input wire [LOCATION_WIDTH-1:0] location_in_8;
input wire [LOCATION_WIDTH-1:0] location_in_9;
input wire [LOCATION_WIDTH-1:0] location_in_10;
input wire [LOCATION_WIDTH-1:0] location_in_11;
input wire [LOCATION_WIDTH-1:0] location_in_12;
input wire [LOCATION_WIDTH-1:0] location_in_13;
input wire [LOCATION_WIDTH-1:0] location_in_14;
input wire [LOCATION_WIDTH-1:0] location_in_15;

input wire signed [SCORE_WIDTH-1:0] Score_init;
input wire signed [SCORE_WIDTH-1:0] H1_init;
input wire signed [SCORE_WIDTH-1:0] H2_init;
input wire signed [SCORE_WIDTH-1:0] E1_init;
input wire signed [SCORE_WIDTH-1:0] E2_init;
input wire signed [CMP_RESULT_WIDTH-1:0] col_max_in;
//input wire signed [LOCATION_WIDTH-1:0] H_col_max_location_in;

input wire signed [SCORE_WIDTH-1:0] H_i_j_fifo;
input wire signed [SCORE_WIDTH-1:0] F_i_j_fifo;
input wire signed [SCORE_WIDTH-1:0] F2_i_j_fifo; //CJ
input wire bt_en ;
input wire bt_flag;
output wire start_out;
output reg [BT_OUT_WIDTH-1 : 0] bt_out ;
output reg [BT_OUT_WIDTH-1 : 0] bt_out0 ;

output wire signed [DATA_WIDTH-1:0] Ns_out;
output wire signed [SCORE_WIDTH-1:0] H_i_j_out;
output wire signed [SCORE_WIDTH-1:0] F_i_j_out;
output wire signed [SCORE_WIDTH-1:0] F2_i_j_out; //CJ
output wire signed [SCORE_WIDTH-1:0] Score_out;
output wire signed [CMP_RESULT_WIDTH-1:0] col_max_out;

output wire signed [SCORE_WIDTH-1:0] E1_init_out;//CJ
output wire signed [SCORE_WIDTH-1:0] E2_init_out;//CJ
output wire signed [SCORE_WIDTH-1:0] H1_init_out;//CJ
output wire signed [SCORE_WIDTH-1:0] H2_init_out;//CJ
output wire col_en;

output reg signed [SCORE_WIDTH-1:0] H_max_out;
output reg signed [LOCATION_WIDTH-1:0] H_max_location;

output reg signed [SCORE_WIDTH-1:0] H_col_max;
output reg signed [LOCATION_WIDTH-1:0] H_col_max_location;
output reg signed [SCORE_WIDTH-1 : 0] diagonal_score;

output reg signed  [SCORE_WIDTH-1:0] H_row_max_last;
output reg signed  [LOCATION_WIDTH-1:0] H_row_max_last_location;

//==========================PE ARRAY====================//

wire        [DATA_WIDTH-1:0 ] PE_Ns_out    [0 : PE_NUM-1];
wire        [DATA_WIDTH-1:0 ] PE_Nr        [0 : PE_NUM-1];
wire signed [SCORE_WIDTH-1:0] PE_H_out     [0 : PE_NUM-1];
wire signed [SCORE_WIDTH-1:0] PE_H_out_col [0 : PE_NUM-1];
wire signed [SCORE_WIDTH-1:0] PE_F1_out    [0 : PE_NUM-1];
wire signed [SCORE_WIDTH-1:0] PE_F2_out    [0 : PE_NUM-1];

wire signed [SCORE_WIDTH-1 : 0] PE_H_row_max   [0 : PE_NUM-1];
wire signed [SCORE_WIDTH-1 : 0] PE_E1_init_out [0 : PE_NUM-1];
wire signed [SCORE_WIDTH-1 : 0] PE_E2_init_out [0 : PE_NUM-1];
wire signed [SCORE_WIDTH-1 : 0] PE_H1_init_out [0 : PE_NUM-1];
wire signed [SCORE_WIDTH-1 : 0] PE_H2_init_out [0 : PE_NUM-1];
wire signed [SCORE_WIDTH-1 : 0] PE_Score_out   [0 : PE_NUM-1];

wire signed [LOCATION_WIDTH-1:0] PE_location_row_out [PE_NUM-1 : 0];
wire signed [LOCATION_WIDTH-1:0] PE_location_in      [PE_NUM-1 : 0];
wire        [BT_OUT_WIDTH-1 : 0] PE_bt_out     [0 : PE_NUM-1];
wire PE_start_out [0 : PE_NUM-1];
wire [PE_NUM-1 : 0] en_out;

//====================SCORE_MAX===================//
wire       final_en        ;
reg        f0_final_en     ;
wire [LOG_PE_NUM-1:0] final_row_num   ;
reg  [LOG_PE_NUM-1:0] f0_final_row_num;


assign final_row_num = final_row_en[EN_LENGTH-3 -: LOG_PE_NUM];
assign final_en      = final_row_en[EN_LENGTH-2]  ;

always @(posedge sys_clk )
begin 
    f0_final_en      <= final_en     ;
    f0_final_row_num <= final_row_num;
end

MUX4to16 MUX4to16_INST (
    .clk    (sys_clk          ),
    .rst_n  (sys_rst_n        ),
    .code_in(final_row_en[LOG_PE_NUM-1:0]), // log(PE_NUM)
    .en_out (en_out           )
);

//=====================END======================//

//======================PE0================//
wire signed [SCORE_WIDTH-1:0] Score_in;
assign PE_Nr[0] = Nr_0;
assign PE_location_in[0] = location_in_0;
assign Score_in = ((start_in == 1'b1) && (mode ==1'b0)) ? Score_init : H_i_j_fifo ;
wire [63:0] bt_in;
assign bt_in = 'd0;
PE0 pe0(
    .sys_clk    (sys_clk             ),
    .sys_rst_n  (sys_rst_n           ),
    
    .Ns         (Ns                  ),
    .Nr         (PE_Nr[0]                ),
    .H_i_1_j_1  (H_i_j_fifo          ),
    .F1_i_j     (F_i_j_fifo         ),
    .F2_i_j     (F2_i_j_fifo         ),
    .bt_in      (bt_in               ),

    .Score_init (Score_in            ),
    .H1_init    (H1_init             ),
    .H2_init    (H2_init             ),
    .E1_init    (E1_init             ),
    .E2_init    (E2_init             ),
    
    .start_in   (start_in            ),
    .mode       (mode                ),
    .max_en     (en_out[0]           ),
    .location_in(PE_location_in[0]       ),  

    .Ns_out     (PE_Ns_out[0]            ),    
    .H_out      (PE_H_out[0]             ),
    .H_out_col  (PE_H_out_col[0]         ),
    .F1_out     (PE_F1_out[0]            ),
    .F2_out     (PE_F2_out[0]            ),
    
    .H_max_out   (PE_H_row_max[0]        ),
    .Score_out   (PE_Score_out[0]        ),
    .H1_init_out (PE_H1_init_out[0]      ),
    .H2_init_out (PE_H2_init_out[0]      ),
    .E1_init_out (PE_E1_init_out[0]      ),
    .E2_init_out (PE_E2_init_out[0]      ),
    .bt_out      (PE_bt_out[0]           ),
    
    
    .location_out(PE_location_row_out[0] ),
    .start_out   (PE_start_out[0]        )
    );
//=====================END====================//
//====================generate================//
//todo : should use for loop and string link
/*genvar i_tmp;
generate
    for (i_tmp=1; i_tmp<PE_NUM; i_tmp=i_tmp+1) begin:PE_begin
        assign PE_Nr[i_tmp] = Nr[i_tmp];
        assign PE_location_in[i_tmp] = location_in[i_tmp];
    end
endgenerate*/

assign PE_Nr[1] = Nr_1;
assign PE_Nr[2] = Nr_2;
assign PE_Nr[3] = Nr_3;
assign PE_Nr[4] = Nr_4;
assign PE_Nr[5] = Nr_5;
assign PE_Nr[6] = Nr_6;
assign PE_Nr[7] = Nr_7;
assign PE_Nr[8] = Nr_8;
assign PE_Nr[9] = Nr_9;
assign PE_Nr[10] = Nr_10;
assign PE_Nr[11] = Nr_11;
assign PE_Nr[12] = Nr_12;
assign PE_Nr[13] = Nr_13;
assign PE_Nr[14] = Nr_14;
assign PE_Nr[15] = Nr_15;


assign PE_location_in[1] = location_in_1;
assign PE_location_in[2] = location_in_2;
assign PE_location_in[3] = location_in_3;
assign PE_location_in[4] = location_in_4;
assign PE_location_in[5] = location_in_5;
assign PE_location_in[6] = location_in_6;
assign PE_location_in[7] = location_in_7;
assign PE_location_in[8] = location_in_8;
assign PE_location_in[9] = location_in_9;
assign PE_location_in[10] = location_in_10;
assign PE_location_in[11] = location_in_11;
assign PE_location_in[12] = location_in_12;
assign PE_location_in[13] = location_in_13;
assign PE_location_in[14] = location_in_14;
assign PE_location_in[15] = location_in_15;

reg [BT_OUT_WIDTH-1:0] PE_bt_out_reg [ PE_NUM-1 : 0];
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n)
        PE_bt_out_reg[0] <= 'd0;
    else 
        PE_bt_out_reg[0] <= PE_bt_out[0];
end

genvar gen_i;
generate

    for (gen_i=1; gen_i<PE_NUM; gen_i=gen_i+1 ) 
    begin : PE_ARRAY
    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (! sys_rst_n)
            PE_bt_out_reg[gen_i] <= 'd0;
        else 
            PE_bt_out_reg[gen_i] <= PE_bt_out[gen_i];
    end

    PEx pe(
    .sys_clk    (sys_clk             ),
    .sys_rst_n  (sys_rst_n           ),
    
    .Ns         (PE_Ns_out[gen_i-1]          ),
    .Nr         (PE_Nr[gen_i]                ),
    .bt_in      (PE_bt_out_reg[gen_i-1]          ),
    .H_i_1_j_1  (PE_H_out[gen_i-1]           ),
    .F1_i_j     (PE_F1_out[gen_i-1]          ),
    .F2_i_j     (PE_F2_out[gen_i-1]          ),

    .Score_in   (PE_Score_out[gen_i-1]        ),
    .H1_init    (PE_H1_init_out[gen_i-1]       ),
    .H2_init    (PE_H2_init_out[gen_i-1]       ),
    .E1_init    (PE_E1_init_out[gen_i-1]           ),
    .E2_init    (PE_E2_init_out[gen_i-1]       ),
    
    .start_in   (PE_start_out[gen_i-1]            ),
    .max_en     (en_out[gen_i]           ),
    .location_in(PE_location_in[gen_i]       ),  

    .Ns_out     (PE_Ns_out[gen_i]            ),    
    .H_out      (PE_H_out[gen_i]             ),
    .H_out_col  (PE_H_out_col[gen_i]         ),
    .F1_out     (PE_F1_out[gen_i]             ),
    .F2_out     (PE_F2_out[gen_i]             ),
    
    .H_max_out   (PE_H_row_max[gen_i]          ),
    .Score_out   (PE_Score_out[gen_i]          ),
    .H1_init_out (PE_H1_init_out[gen_i]      ),
    .H2_init_out (PE_H2_init_out[gen_i]      ),
    .E1_init_out (PE_E1_init_out[gen_i]      ),
    .E2_init_out (PE_E2_init_out[gen_i]      ),
    .bt_out      (PE_bt_out[gen_i]           ),
    
    
    
    .location_out(PE_location_row_out[gen_i] ),
    .start_out   (PE_start_out[gen_i]        )
    );
    end
    
endgenerate

assign Ns_out      = PE_Ns_out[PE_NUM-1];
assign start_out   = PE_start_out[PE_NUM-1];
assign H_i_j_out   = PE_H_out[PE_NUM-1];
assign F_i_j_out   = PE_F1_out[PE_NUM-1];
assign F2_i_j_out  = PE_F2_out[PE_NUM-1];
assign Score_out   = PE_Score_out[PE_NUM-1];
assign H1_init_out = PE_H1_init_out[PE_NUM-1];
assign H2_init_out = PE_H2_init_out[PE_NUM-1];
assign E1_init_out = PE_E1_init_out[PE_NUM-1];
assign E2_init_out = PE_E2_init_out[PE_NUM-1];
//assign bt_out      = PE_bt_out[PE_NUM-1]; //should use case format
//=====================END====================//

//======================bt_out========================//

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        bt_out <= 64'sh0000;   
    end
    else if (bt_en) begin
        case (final_row_num)
        4'b0000: bt_out <= PE_bt_out_reg[0];
        4'b0001: bt_out <= PE_bt_out_reg[1];
        4'b0010: bt_out <= PE_bt_out_reg[2];
        4'b0011: bt_out <= PE_bt_out_reg[3];
        4'b0100: bt_out <= PE_bt_out_reg[4];
        4'b0101: bt_out <= PE_bt_out_reg[5];
        4'b0110: bt_out <= PE_bt_out_reg[6];
        4'b0111: bt_out <= PE_bt_out_reg[7];
        4'b1000: bt_out <= PE_bt_out_reg[8];
        4'b1001: bt_out <= PE_bt_out_reg[9];
        4'b1010: bt_out <= PE_bt_out_reg[10];
        4'b1011: bt_out <= PE_bt_out_reg[11];
        4'b1100: bt_out <= PE_bt_out_reg[12];
        4'b1101: bt_out <= PE_bt_out_reg[13];
        4'b1110: bt_out <= PE_bt_out_reg[14];
        4'b1111: bt_out <= PE_bt_out_reg[15];
        endcase
    end
    else begin
        bt_out <= bt_out;
    end
end
//=======================end==========================//
//=========================H_Col_MAX==================//
wire H_col_max_en;
assign H_col_max_en = final_row_en[EN_LENGTH-1];//高电平开始最后一个计算，延迟14个周期，得到结果
reg max_en_0 ;
reg max_en_1 ;
reg max_en_2 ;
reg max_en_3 ;
reg max_en_4 ;
reg max_en_5 ;
reg max_en_6 ;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        max_en_0  <= 1'b0;
        max_en_1  <= 1'b0;
        max_en_2  <= 1'b0;
        max_en_3  <= 1'b0;
        max_en_4  <= 1'b0;
        max_en_5  <= 1'b0;
        max_en_6  <= 1'b0;
    end
    else begin
        max_en_0  <= H_col_max_en;
        max_en_1  <= max_en_0 ;
        max_en_2  <= max_en_1;
        max_en_3  <= max_en_2;
        max_en_4  <= max_en_3;
        max_en_5  <= max_en_4;
        max_en_6  <= max_en_5;
    end
end
//###############CMP0###################
wire signed [SCORE_WIDTH-1:0] H_col_cmp_out_0;
wire        [LOCATION_WIDTH-1:0] location_col_cmp_out_0;
//wire en_out_0;

reg [LOCATION_WIDTH-1:0] location_col_out_0_reg_0;
reg [LOCATION_WIDTH-1:0] location_col_out_0_reg_1;
reg [LOCATION_WIDTH-1:0] location_col_out_0_reg_2;
reg [LOCATION_WIDTH-1:0] location_col_out_0_reg_3;
reg [LOCATION_WIDTH-1:0] location_col_out_0_reg_4;
reg [LOCATION_WIDTH-1:0] location_col_out_0_reg_5;

reg signed  [SCORE_WIDTH-1:0] H_col_max_0_reg_0;
reg signed  [SCORE_WIDTH-1:0] H_col_max_0_reg_1;
reg signed  [SCORE_WIDTH-1:0] H_col_max_0_reg_2;
reg signed  [SCORE_WIDTH-1:0] H_col_max_0_reg_3;
reg signed  [SCORE_WIDTH-1:0] H_col_max_0_reg_4;
reg signed  [SCORE_WIDTH-1:0] H_col_max_0_reg_5;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        location_col_out_0_reg_0 <= 1'b0;   
        location_col_out_0_reg_1 <= 1'b0;
        location_col_out_0_reg_2 <= 1'b0;
        location_col_out_0_reg_3 <= 1'b0;
        location_col_out_0_reg_4 <= 1'b0;
        location_col_out_0_reg_5 <= 1'b0;
    end
    else begin
        location_col_out_0_reg_0 <= col_max_in[47:16];
        location_col_out_0_reg_1 <= location_col_out_0_reg_0;
        location_col_out_0_reg_2 <= location_col_out_0_reg_1;
        location_col_out_0_reg_3 <= location_col_out_0_reg_2;
        location_col_out_0_reg_4 <= location_col_out_0_reg_3;
        location_col_out_0_reg_5 <= location_col_out_0_reg_4;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_col_max_0_reg_0 <= 16'sh0000;
        H_col_max_0_reg_1 <= 16'sh0000;
        H_col_max_0_reg_2 <= 16'sh0000;
        H_col_max_0_reg_3 <= 16'sh0000;
        H_col_max_0_reg_4 <= 16'sh0000;
        H_col_max_0_reg_5 <= 16'sh0000;  
    end
    else begin
        H_col_max_0_reg_0 <= col_max_in[15:0];
        H_col_max_0_reg_1 <= H_col_max_0_reg_0;
        H_col_max_0_reg_2 <= H_col_max_0_reg_1;
        H_col_max_0_reg_3 <= H_col_max_0_reg_2;
        H_col_max_0_reg_4 <= H_col_max_0_reg_3;
        H_col_max_0_reg_5 <= H_col_max_0_reg_4;   
    end
end

//assign H_col_max_0_reg_5_temp = (en_out_3 == 1'b1) ? H_col_max_0_reg_5 : 16'sh8fff;
//assign location_col_out_0_reg_5_temp = (en_out_3 == 1'b1) ? location_col_out_0_reg_5 : 0;
wire clear;
assign clear = start_in & (!mode);
reg mode_reg_0;
reg mode_reg_1;
reg mode_reg_2;
reg mode_reg_3;
reg mode_reg_4;
reg mode_reg_5;
reg mode_reg_6;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        mode_reg_0 <= 16'sh0000;
        mode_reg_1 <= 16'sh0000;
        mode_reg_2 <= 16'sh0000;
        mode_reg_3 <= 16'sh0000;
        mode_reg_4 <= 16'sh0000;
        mode_reg_5 <= 16'sh0000;
        mode_reg_6 <= 16'sh0000;  
    end
    else begin
        mode_reg_0 <= mode;
        mode_reg_1 <= mode_reg_0;
        mode_reg_2 <= mode_reg_1;
        mode_reg_3 <= mode_reg_2;
        mode_reg_4 <= mode_reg_3;
        mode_reg_5 <= mode_reg_4;   
        mode_reg_6 <= mode_reg_5;   
    end
end
wire [LOCATION_WIDTH-1 : 0] COL_location_out[0 : PE_NUM-1];
wire [SCORE_WIDTH-1 : 0]    COL_H_max       [0 : PE_NUM-1];
wire                        COL_en_out      [0 : PE_NUM-1];

CMP_COL_INIT col_cmp_0(
    .clk (sys_clk                           ),
    .rst_n (sys_rst_n                       ),
    .clear (clear                 ),
    .en (max_en_6),
    .mode(mode_reg_6                        ),
    .location_in_0(location_col_out_0_reg_5 ),
    .value_0 (H_col_max_0_reg_5             ),
    .location_in_1(PE_location_row_out[0]       ),
    .value_1 (PE_H_out_col[0]                   ),
    .max(COL_H_max[0]                    ),
    .en_out(COL_en_out[0]                       ),
    .location_out (COL_location_out[0]           )
    ); 

//====================GENGERAT=================//
genvar gen_j;
generate
    for(gen_j=1; gen_j<PE_NUM; gen_j=gen_j+1)
    begin:CMP_COL
        CMP_COL_X col_cmp(
        .sys_clk (sys_clk                           ),
        .sys_rst_n (sys_rst_n                       ),
        .clear (clear                     ),
        .location_in_0(COL_location_out[gen_j-1] ),
        .value_0 (COL_H_max[gen_j-1]             ),
        .en(COL_en_out[gen_j-1]                            ),
        .location_in_1(PE_location_row_out[gen_j]       ),
        .value_1 (PE_H_out_col[gen_j]                  ),
        .max(COL_H_max[gen_j]                        ),
        .en_out(COL_en_out[gen_j]),
        .location_out (COL_location_out[gen_j]           )
    ); 
    end
endgenerate


//###############H_col_max_last###############


always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_col_max <= 16'sh0000;   
    end
    else if (f0_final_en) begin
        case (f0_final_row_num)
        4'b0000: H_col_max <= COL_H_max[0];
        4'b0001: H_col_max <= COL_H_max[1];
        4'b0010: H_col_max <= COL_H_max[2];
        4'b0011: H_col_max <= COL_H_max[3];
        4'b0100: H_col_max <= COL_H_max[4];
        4'b0101: H_col_max <= COL_H_max[5];
        4'b0110: H_col_max <= COL_H_max[6];
        4'b0111: H_col_max <= COL_H_max[7];
        4'b1000: H_col_max <= COL_H_max[8];
        4'b1001: H_col_max <= COL_H_max[9];
        4'b1010: H_col_max <= COL_H_max[10];
        4'b1011: H_col_max <= COL_H_max[11];
        4'b1100: H_col_max <= COL_H_max[12];
        4'b1101: H_col_max <= COL_H_max[13];
        4'b1110: H_col_max <= COL_H_max[14];
        4'b1111: H_col_max <= COL_H_max[15];
        endcase
    end
    else begin
        H_col_max <= H_col_max;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_col_max_location <= 1'b0;   
    end
    else if (f0_final_en) begin
        case (f0_final_row_num)
        4'b0000: H_col_max_location <= COL_location_out[0];
        4'b0001: H_col_max_location <= COL_location_out[1];
        4'b0010: H_col_max_location <= COL_location_out[2];
        4'b0011: H_col_max_location <= COL_location_out[3];
        4'b0100: H_col_max_location <= COL_location_out[4];
        4'b0101: H_col_max_location <= COL_location_out[5];
        4'b0110: H_col_max_location <= COL_location_out[6];
        4'b0111: H_col_max_location <= COL_location_out[7];
        4'b1000: H_col_max_location <= COL_location_out[8];
        4'b1001: H_col_max_location <= COL_location_out[9];
        4'b1010: H_col_max_location <= COL_location_out[10];
        4'b1011: H_col_max_location <= COL_location_out[11];
        4'b1100: H_col_max_location <= COL_location_out[12];
        4'b1101: H_col_max_location <= COL_location_out[13];
        4'b1110: H_col_max_location <= COL_location_out[14];
        4'b1111: H_col_max_location <= COL_location_out[15];
        endcase
    end
    else begin
        H_col_max_location <= H_col_max_location;
    end
end


//#################H_row_max###################
wire [SCORE_WIDTH-1:0]    CMP_H_max_out   [0 : PE_NUM-1];
wire [LOCATION_WIDTH-1:0] CMP_location_out[0 : PE_NUM-1];

reg [LOCATION_WIDTH-1:0] location_row_out_0_reg_0;
reg [LOCATION_WIDTH-1:0] location_row_out_0_reg_1;
reg [LOCATION_WIDTH-1:0] location_row_out_0_reg_2;
reg [LOCATION_WIDTH-1:0] location_row_out_0_reg_3;
reg [LOCATION_WIDTH-1:0] location_row_out_0_reg_4;
reg [LOCATION_WIDTH-1:0] location_row_out_0_reg_5;

reg signed  [SCORE_WIDTH-1:0] H_row_max_0_reg_0;
reg signed  [SCORE_WIDTH-1:0] H_row_max_0_reg_1;
reg signed  [SCORE_WIDTH-1:0] H_row_max_0_reg_2;
reg signed  [SCORE_WIDTH-1:0] H_row_max_0_reg_3;
reg signed  [SCORE_WIDTH-1:0] H_row_max_0_reg_4;
reg signed  [SCORE_WIDTH-1:0] H_row_max_0_reg_5;

reg start_in_reg_0;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        start_in_reg_0 <= 1'b0;
    end
    else begin
        start_in_reg_0 <= start_in;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        location_row_out_0_reg_0 <= 1'b0;   
    end else if (start_in_reg_0 && !mode_reg_0) begin 
        location_row_out_0_reg_0 <= 1'b0;
    end else begin
        location_row_out_0_reg_0 <= CMP_location_out[PE_NUM-1];  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        location_row_out_0_reg_1 <= 1'b0;
        location_row_out_0_reg_2 <= 1'b0;
        location_row_out_0_reg_3 <= 1'b0;
        location_row_out_0_reg_4 <= 1'b0;
        location_row_out_0_reg_5 <= 1'b0;
    end
    else begin
        location_row_out_0_reg_1 <= location_row_out_0_reg_0;
        location_row_out_0_reg_2 <= location_row_out_0_reg_1;
        location_row_out_0_reg_3 <= location_row_out_0_reg_2;
        location_row_out_0_reg_4 <= location_row_out_0_reg_3;
        location_row_out_0_reg_5 <= location_row_out_0_reg_4;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        H_row_max_0_reg_0 <= 16'sh8FFF;   
    end else if (start_in_reg_0 && !mode_reg_0) begin
        H_row_max_0_reg_0 <= 16'sh8FFF;
    end else begin
        H_row_max_0_reg_0 <= CMP_H_max_out[PE_NUM-1];  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_row_max_0_reg_1 <= 16'sh0000;
        H_row_max_0_reg_2 <= 16'sh0000;
        H_row_max_0_reg_3 <= 16'sh0000;
        H_row_max_0_reg_4 <= 16'sh0000;
        H_row_max_0_reg_5 <= 16'sh0000;  
    end
    else begin
        H_row_max_0_reg_1 <= H_row_max_0_reg_0;
        H_row_max_0_reg_2 <= H_row_max_0_reg_1;
        H_row_max_0_reg_3 <= H_row_max_0_reg_2;
        H_row_max_0_reg_4 <= H_row_max_0_reg_3;
        H_row_max_0_reg_5 <= H_row_max_0_reg_4;   
    end
end


CMP_LOCATION_INIT MAX_cmp_0(
    .clk (sys_clk                           ),
    .rst_n (sys_rst_n                       ),

    .clear( clear),
    .en(max_en_6),
    .mode(mode_reg_6),
    .location_in_0(location_row_out_0_reg_5 ),
    .value_0 (H_row_max_0_reg_5             ),

    .location_in_1(PE_location_row_out[0]       ),
    .value_1 (PE_H_row_max[0]                   ),
    .max(CMP_H_max_out[0]                        ),
    .location_out (CMP_location_out[0]           )
    ); 

//====================END===================//

genvar gen_cmp;
generate
    for(gen_cmp=1; gen_cmp< PE_NUM; gen_cmp=gen_cmp+1) 
    begin : CMP
        CMP_LOCATION_X MAX_cmp(
        .sys_clk (sys_clk                       ),
        .sys_rst_n (sys_rst_n                   ),
        .en(COL_en_out[gen_cmp-1]               ),
        .clear(clear                        ),
        .start_in(start_in_reg_0            ),
        .mode_in(mode_reg_0                    ),
        .location_in_0(CMP_location_out[gen_cmp-1] ),
        .value_0 (CMP_H_max_out[gen_cmp-1]         ),
        .location_in_1(PE_location_row_out[gen_cmp]   ),
        .value_1 (PE_H_row_max[gen_cmp]               ),
    
        .max(CMP_H_max_out[gen_cmp]                    ),
        .location_out (CMP_location_out[gen_cmp]       )
    );
    end
endgenerate
//=====================END==================//


//###############H_row_max_last###############
reg signed [SCORE_WIDTH-1:0] H_row_max_last_reg;
reg signed [LOCATION_WIDTH-1:0] H_row_max_last_location_reg;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_row_max_last_reg <= 16'sh0000;   
    end
    else if (final_en) begin
        case (final_row_num)
        4'b0000: H_row_max_last_reg <= PE_H_row_max[0];
        4'b0001: H_row_max_last_reg <= PE_H_row_max[1];
        4'b0010: H_row_max_last_reg <= PE_H_row_max[2];
        4'b0011: H_row_max_last_reg <= PE_H_row_max[3];
        4'b0100: H_row_max_last_reg <= PE_H_row_max[4];
        4'b0101: H_row_max_last_reg <= PE_H_row_max[5];
        4'b0110: H_row_max_last_reg <= PE_H_row_max[6];
        4'b0111: H_row_max_last_reg <= PE_H_row_max[7];
        4'b1000: H_row_max_last_reg <= PE_H_row_max[8];
        4'b1001: H_row_max_last_reg <= PE_H_row_max[9];
        4'b1010: H_row_max_last_reg <= PE_H_row_max[10];
        4'b1011: H_row_max_last_reg <= PE_H_row_max[11];
        4'b1100: H_row_max_last_reg <= PE_H_row_max[12];
        4'b1101: H_row_max_last_reg <= PE_H_row_max[13];
        4'b1110: H_row_max_last_reg <= PE_H_row_max[14];
        4'b1111: H_row_max_last_reg <= PE_H_row_max[15];
        endcase
    end
    else begin
    	H_row_max_last_reg <= H_row_max_last_reg;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        H_row_max_last_location_reg <= 1'b0;   
    end
    else if (final_en) begin
        case (final_row_num)
        4'b0000: H_row_max_last_location_reg <= PE_location_row_out[0];
        4'b0001: H_row_max_last_location_reg <= PE_location_row_out[1];
        4'b0010: H_row_max_last_location_reg <= PE_location_row_out[2];
        4'b0011: H_row_max_last_location_reg <= PE_location_row_out[3];
        4'b0100: H_row_max_last_location_reg <= PE_location_row_out[4];
        4'b0101: H_row_max_last_location_reg <= PE_location_row_out[5];
        4'b0110: H_row_max_last_location_reg <= PE_location_row_out[6];
        4'b0111: H_row_max_last_location_reg <= PE_location_row_out[7];
        4'b1000: H_row_max_last_location_reg <= PE_location_row_out[8];
        4'b1001: H_row_max_last_location_reg <= PE_location_row_out[9];
        4'b1010: H_row_max_last_location_reg <= PE_location_row_out[10];
        4'b1011: H_row_max_last_location_reg <= PE_location_row_out[11];
        4'b1100: H_row_max_last_location_reg <= PE_location_row_out[12];
        4'b1101: H_row_max_last_location_reg <= PE_location_row_out[13];
        4'b1110: H_row_max_last_location_reg <= PE_location_row_out[14];
        4'b1111: H_row_max_last_location_reg <= PE_location_row_out[15];
        endcase
    end
    else begin
    	H_row_max_last_location_reg <= H_row_max_last_location_reg;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        H_row_max_last <= 16'sh0000;   
    end
    else begin
        H_row_max_last <= H_row_max_last_reg;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        H_row_max_last_location <= 1'b0;   
    end
    else begin
        H_row_max_last_location <= H_row_max_last_location_reg;
    end
end

//========================END=========================//

//=======================H_MAX_OUT====================//
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_max_out <= 16'sh0000;   
    end
    else if (f0_final_en) begin
        case (f0_final_row_num)
        4'b0000: H_max_out <= CMP_H_max_out[0];
        4'b0001: H_max_out <= CMP_H_max_out[1];
        4'b0010: H_max_out <= CMP_H_max_out[2];
        4'b0011: H_max_out <= CMP_H_max_out[3];
        4'b0100: H_max_out <= CMP_H_max_out[4];
        4'b0101: H_max_out <= CMP_H_max_out[5];
        4'b0110: H_max_out <= CMP_H_max_out[6];
        4'b0111: H_max_out <= CMP_H_max_out[7];
        4'b1000: H_max_out <= CMP_H_max_out[8];
        4'b1001: H_max_out <= CMP_H_max_out[9];
        4'b1010: H_max_out <= CMP_H_max_out[10];
        4'b1011: H_max_out <= CMP_H_max_out[11];
        4'b1100: H_max_out <= CMP_H_max_out[12];
        4'b1101: H_max_out <= CMP_H_max_out[13];
        4'b1110: H_max_out <= CMP_H_max_out[14];
        4'b1111: H_max_out <= CMP_H_max_out[15];
        endcase
    end
    else begin
        H_max_out <= H_max_out;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_max_location <= 1'b0;   
    end
    else if (f0_final_en) begin
        case (f0_final_row_num)
        4'b0000: H_max_location <= CMP_location_out[0];
        4'b0001: H_max_location <= CMP_location_out[1];
        4'b0010: H_max_location <= CMP_location_out[2];
        4'b0011: H_max_location <= CMP_location_out[3];
        4'b0100: H_max_location <= CMP_location_out[4];
        4'b0101: H_max_location <= CMP_location_out[5];
        4'b0110: H_max_location <= CMP_location_out[6];
        4'b0111: H_max_location <= CMP_location_out[7];
        4'b1000: H_max_location <= CMP_location_out[8];
        4'b1001: H_max_location <= CMP_location_out[9];
        4'b1010: H_max_location <= CMP_location_out[10];
        4'b1011: H_max_location <= CMP_location_out[11];
        4'b1100: H_max_location <= CMP_location_out[12];
        4'b1101: H_max_location <= CMP_location_out[13];
        4'b1110: H_max_location <= CMP_location_out[14];
        4'b1111: H_max_location <= CMP_location_out[15];
        endcase
    end
    else begin
        H_max_location <= H_max_location;
    end
end


assign col_max_out = {COL_location_out[PE_NUM-1], COL_H_max[PE_NUM-1]};//circle loop compare

reg en_out_2_reg_0;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        en_out_2_reg_0 <= 1'b0;        
    end
    else begin
        en_out_2_reg_0 <= en_out[PE_NUM-2];
    end
end
assign col_en = en_out_2_reg_0;

//=====================diagonal_score===============//
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        diagonal_score <= 16'sh0000;   
    end
    else if (final_en) begin
        case (final_row_num)
        4'b0000: diagonal_score <= PE_H_out_col[0];
        4'b0001: diagonal_score <= PE_H_out_col[1];
        4'b0010: diagonal_score <= PE_H_out_col[2];
        4'b0011: diagonal_score <= PE_H_out_col[3];
        4'b0100: diagonal_score <= PE_H_out_col[4];
        4'b0101: diagonal_score <= PE_H_out_col[5];
        4'b0110: diagonal_score <= PE_H_out_col[6];
        4'b0111: diagonal_score <= PE_H_out_col[7];
        4'b1000: diagonal_score <= PE_H_out_col[8];
        4'b1001: diagonal_score <= PE_H_out_col[9];
        4'b1010: diagonal_score <= PE_H_out_col[10];
        4'b1011: diagonal_score <= PE_H_out_col[11];
        4'b1100: diagonal_score <= PE_H_out_col[12];
        4'b1101: diagonal_score <= PE_H_out_col[13];
        4'b1110: diagonal_score <= PE_H_out_col[14];
        4'b1111: diagonal_score <= PE_H_out_col[15];
        endcase
    end
    else begin
        diagonal_score <= diagonal_score;
    end
end
endmodule
