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
module PU32 #(
	parameter integer DATA_WIDTH  = 4,
	parameter integer SCORE_WIDTH = 16,
	parameter integer LOCATION_WIDTH = 32,
	parameter integer PE_NUM = 32,
    parameter integer LOG_PE_NUM = 5,
    parameter integer BT_OUT_WIDTH = 64,
    parameter integer EN_LENGTH = 12,
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
    Nr_10         ,
    Nr_11         ,
    Nr_12         ,
    Nr_13         ,
    Nr_14         ,
    Nr_15         ,

    Nr_16          ,
    Nr_17          ,
    Nr_18          ,
    Nr_19          ,
    Nr_20         ,
    Nr_21          ,
    Nr_22          ,
    Nr_23          ,
    Nr_24          ,
    Nr_25          ,
    Nr_26         ,
    Nr_27         ,
    Nr_28         ,
    Nr_29         ,
    Nr_30         ,
    Nr_31         ,

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
    location_in_10,
    location_in_11,
    location_in_12,
    location_in_13,
    location_in_14,
    location_in_15,

    location_in_16 ,
    location_in_17 ,
    location_in_18 ,
    location_in_19 ,
    location_in_20,
    location_in_21 ,
    location_in_22 ,
    location_in_23 ,
    location_in_24 ,
    location_in_25 ,
    location_in_26,
    location_in_27,
    location_in_28,
    location_in_29,
    location_in_30,
    location_in_31,

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

    
    start_out               ,
    bt_out                  ,
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

input wire [DATA_WIDTH-1: 0] Nr_16;
input wire [DATA_WIDTH-1: 0] Nr_17;
input wire [DATA_WIDTH-1: 0] Nr_18;
input wire [DATA_WIDTH-1: 0] Nr_19;
input wire [DATA_WIDTH-1: 0] Nr_20;
input wire [DATA_WIDTH-1: 0] Nr_21;
input wire [DATA_WIDTH-1: 0] Nr_22;
input wire [DATA_WIDTH-1: 0] Nr_23;
input wire [DATA_WIDTH-1: 0] Nr_24;
input wire [DATA_WIDTH-1: 0] Nr_25;
input wire [DATA_WIDTH-1: 0] Nr_26;
input wire [DATA_WIDTH-1: 0] Nr_27;
input wire [DATA_WIDTH-1: 0] Nr_28;
input wire [DATA_WIDTH-1: 0] Nr_29;
input wire [DATA_WIDTH-1: 0] Nr_30;
input wire [DATA_WIDTH-1: 0] Nr_31;

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

input wire [LOCATION_WIDTH-1:0] location_in_16;
input wire [LOCATION_WIDTH-1:0] location_in_17;
input wire [LOCATION_WIDTH-1:0] location_in_18;
input wire [LOCATION_WIDTH-1:0] location_in_19;
input wire [LOCATION_WIDTH-1:0] location_in_20;
input wire [LOCATION_WIDTH-1:0] location_in_21;
input wire [LOCATION_WIDTH-1:0] location_in_22;
input wire [LOCATION_WIDTH-1:0] location_in_23;
input wire [LOCATION_WIDTH-1:0] location_in_24;
input wire [LOCATION_WIDTH-1:0] location_in_25;
input wire [LOCATION_WIDTH-1:0] location_in_26;
input wire [LOCATION_WIDTH-1:0] location_in_27;
input wire [LOCATION_WIDTH-1:0] location_in_28;
input wire [LOCATION_WIDTH-1:0] location_in_29;
input wire [LOCATION_WIDTH-1:0] location_in_30;
input wire [LOCATION_WIDTH-1:0] location_in_31;

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

output wire start_out;
output reg [BT_OUT_WIDTH-1 : 0] bt_out ;

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

MUX5to32 MUX5to32_INST (
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

assign PE_Nr[16] = Nr_16;
assign PE_Nr[17] = Nr_17;
assign PE_Nr[18] = Nr_18;
assign PE_Nr[19] = Nr_19;
assign PE_Nr[20] = Nr_20;
assign PE_Nr[21] = Nr_21;
assign PE_Nr[22] = Nr_22;
assign PE_Nr[23] = Nr_23;
assign PE_Nr[24] = Nr_24;
assign PE_Nr[25] = Nr_25;
assign PE_Nr[26] = Nr_26;
assign PE_Nr[27] = Nr_27;
assign PE_Nr[28] = Nr_28;
assign PE_Nr[29] = Nr_29;
assign PE_Nr[30] = Nr_30;
assign PE_Nr[31] = Nr_31;

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

assign PE_location_in[16] = location_in_16;
assign PE_location_in[17] = location_in_17;
assign PE_location_in[18] = location_in_18;
assign PE_location_in[19] = location_in_19;
assign PE_location_in[20] = location_in_20;
assign PE_location_in[21] = location_in_21;
assign PE_location_in[22] = location_in_22;
assign PE_location_in[23] = location_in_23;
assign PE_location_in[24] = location_in_24;
assign PE_location_in[25] = location_in_25;
assign PE_location_in[26] = location_in_26;
assign PE_location_in[27] = location_in_27;
assign PE_location_in[28] = location_in_28;
assign PE_location_in[29] = location_in_29;
assign PE_location_in[30] = location_in_30;
assign PE_location_in[31] = location_in_31;

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
        5'b00000: bt_out <= PE_bt_out_reg[0];
        5'b00001: bt_out <= PE_bt_out_reg[1];
        5'b00010: bt_out <= PE_bt_out_reg[2];
        5'b00011: bt_out <= PE_bt_out_reg[3];
        5'b00100: bt_out <= PE_bt_out_reg[4];
        5'b00101: bt_out <= PE_bt_out_reg[5];
        5'b00110: bt_out <= PE_bt_out_reg[6];
        5'b00111: bt_out <= PE_bt_out_reg[7];
        5'b01000: bt_out <= PE_bt_out_reg[8];
        5'b01001: bt_out <= PE_bt_out_reg[9];
        5'b01010: bt_out <= PE_bt_out_reg[10];
        5'b01011: bt_out <= PE_bt_out_reg[11];
        5'b01100: bt_out <= PE_bt_out_reg[12];
        5'b01101: bt_out <= PE_bt_out_reg[13];
        5'b01110: bt_out <= PE_bt_out_reg[14];
        5'b01111: bt_out <= PE_bt_out_reg[15];

        5'b10000: bt_out <= PE_bt_out_reg[16];
        5'b10001: bt_out <= PE_bt_out_reg[17];
        5'b10010: bt_out <= PE_bt_out_reg[18];
        5'b10011: bt_out <= PE_bt_out_reg[19];
        5'b10100: bt_out <= PE_bt_out_reg[20];
        5'b10101: bt_out <= PE_bt_out_reg[21];
        5'b10110: bt_out <= PE_bt_out_reg[22];
        5'b10111: bt_out <= PE_bt_out_reg[23];
        5'b11000: bt_out <= PE_bt_out_reg[24];
        5'b11001: bt_out <= PE_bt_out_reg[25];
        5'b11010: bt_out <= PE_bt_out_reg[26];
        5'b11011: bt_out <= PE_bt_out_reg[27];
        5'b11100: bt_out <= PE_bt_out_reg[28];
        5'b11101: bt_out <= PE_bt_out_reg[29];
        5'b11110: bt_out <= PE_bt_out_reg[30];
        5'b11111: bt_out <= PE_bt_out_reg[31];

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
//wire signed [SCORE_WIDTH-1:0] H_col_cmp_out_0;
//wire        [LOCATION_WIDTH-1:0] location_col_cmp_out_0;
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
        5'b00000: H_col_max <= COL_H_max[0];
        5'b00001: H_col_max <= COL_H_max[1];
        5'b00010: H_col_max <= COL_H_max[2];
        5'b00011: H_col_max <= COL_H_max[3];
        5'b00100: H_col_max <= COL_H_max[4];
        5'b00101: H_col_max <= COL_H_max[5];
        5'b00110: H_col_max <= COL_H_max[6];
        5'b00111: H_col_max <= COL_H_max[7];
        5'b01000: H_col_max <= COL_H_max[8];
        5'b01001: H_col_max <= COL_H_max[9];
        5'b01010: H_col_max <= COL_H_max[10];
        5'b01011: H_col_max <= COL_H_max[11];
        5'b01100: H_col_max <= COL_H_max[12];
        5'b01101: H_col_max <= COL_H_max[13];
        5'b01110: H_col_max <= COL_H_max[14];
        5'b01111: H_col_max <= COL_H_max[15];

        5'b10000: H_col_max <= COL_H_max[16];
        5'b10001: H_col_max <= COL_H_max[17];
        5'b10010: H_col_max <= COL_H_max[18];
        5'b10011: H_col_max <= COL_H_max[19];
        5'b10100: H_col_max <= COL_H_max[20];
        5'b10101: H_col_max <= COL_H_max[21];
        5'b10110: H_col_max <= COL_H_max[22];
        5'b10111: H_col_max <= COL_H_max[23];
        5'b11000: H_col_max <= COL_H_max[24];
        5'b11001: H_col_max <= COL_H_max[25];
        5'b11010: H_col_max <= COL_H_max[26];
        5'b11011: H_col_max <= COL_H_max[27];
        5'b11100: H_col_max <= COL_H_max[28];
        5'b11101: H_col_max <= COL_H_max[29];
        5'b11110: H_col_max <= COL_H_max[30];
        5'b11111: H_col_max <= COL_H_max[31];
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
        5'b00000: H_col_max_location <= COL_location_out[0];
        5'b00001: H_col_max_location <= COL_location_out[1];
        5'b00010: H_col_max_location <= COL_location_out[2];
        5'b00011: H_col_max_location <= COL_location_out[3];
        5'b00100: H_col_max_location <= COL_location_out[4];
        5'b00101: H_col_max_location <= COL_location_out[5];
        5'b00110: H_col_max_location <= COL_location_out[6];
        5'b00111: H_col_max_location <= COL_location_out[7];
        5'b01000: H_col_max_location <= COL_location_out[8];
        5'b01001: H_col_max_location <= COL_location_out[9];
        5'b01010: H_col_max_location <= COL_location_out[10];
        5'b01011: H_col_max_location <= COL_location_out[11];
        5'b01100: H_col_max_location <= COL_location_out[12];
        5'b01101: H_col_max_location <= COL_location_out[13];
        5'b01110: H_col_max_location <= COL_location_out[14];
        5'b01111: H_col_max_location <= COL_location_out[15];

        5'b10000: H_col_max_location <= COL_location_out[16];
        5'b10001: H_col_max_location <= COL_location_out[17];
        5'b10010: H_col_max_location <= COL_location_out[18];
        5'b10011: H_col_max_location <= COL_location_out[19];
        5'b10100: H_col_max_location <= COL_location_out[20];
        5'b10101: H_col_max_location <= COL_location_out[21];
        5'b10110: H_col_max_location <= COL_location_out[22];
        5'b10111: H_col_max_location <= COL_location_out[23];
        5'b11000: H_col_max_location <= COL_location_out[24];
        5'b11001: H_col_max_location <= COL_location_out[25];
        5'b11010: H_col_max_location <= COL_location_out[26];
        5'b11011: H_col_max_location <= COL_location_out[27];
        5'b11100: H_col_max_location <= COL_location_out[28];
        5'b11101: H_col_max_location <= COL_location_out[29];
        5'b11110: H_col_max_location <= COL_location_out[30];
        5'b11111: H_col_max_location <= COL_location_out[31];
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
        5'b00000: H_row_max_last_reg <= PE_H_row_max[0 ];
        5'b00001: H_row_max_last_reg <= PE_H_row_max[1 ];
        5'b00010: H_row_max_last_reg <= PE_H_row_max[2 ];
        5'b00011: H_row_max_last_reg <= PE_H_row_max[3 ];
        5'b00100: H_row_max_last_reg <= PE_H_row_max[4 ];
        5'b00101: H_row_max_last_reg <= PE_H_row_max[5 ];
        5'b00110: H_row_max_last_reg <= PE_H_row_max[6 ];
        5'b00111: H_row_max_last_reg <= PE_H_row_max[7 ];
        5'b01000: H_row_max_last_reg <= PE_H_row_max[8 ];
        5'b01001: H_row_max_last_reg <= PE_H_row_max[9 ];
        5'b01010: H_row_max_last_reg <= PE_H_row_max[10];
        5'b01011: H_row_max_last_reg <= PE_H_row_max[11];
        5'b01100: H_row_max_last_reg <= PE_H_row_max[12];
        5'b01101: H_row_max_last_reg <= PE_H_row_max[13];
        5'b01110: H_row_max_last_reg <= PE_H_row_max[14];
        5'b01111: H_row_max_last_reg <= PE_H_row_max[15];

        5'b10000: H_row_max_last_reg <= PE_H_row_max[16];
        5'b10001: H_row_max_last_reg <= PE_H_row_max[17];
        5'b10010: H_row_max_last_reg <= PE_H_row_max[18];
        5'b10011: H_row_max_last_reg <= PE_H_row_max[19];
        5'b10100: H_row_max_last_reg <= PE_H_row_max[20];
        5'b10101: H_row_max_last_reg <= PE_H_row_max[21];
        5'b10110: H_row_max_last_reg <= PE_H_row_max[22];
        5'b10111: H_row_max_last_reg <= PE_H_row_max[23];
        5'b11000: H_row_max_last_reg <= PE_H_row_max[24];
        5'b11001: H_row_max_last_reg <= PE_H_row_max[25];
        5'b11010: H_row_max_last_reg <= PE_H_row_max[26];
        5'b11011: H_row_max_last_reg <= PE_H_row_max[27];
        5'b11100: H_row_max_last_reg <= PE_H_row_max[28];
        5'b11101: H_row_max_last_reg <= PE_H_row_max[29];
        5'b11110: H_row_max_last_reg <= PE_H_row_max[30];
        5'b11111: H_row_max_last_reg <= PE_H_row_max[31];
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
        5'b00000: H_row_max_last_location_reg <= PE_location_row_out[0];
        5'b00001: H_row_max_last_location_reg <= PE_location_row_out[1];
        5'b00010: H_row_max_last_location_reg <= PE_location_row_out[2];
        5'b00011: H_row_max_last_location_reg <= PE_location_row_out[3];
        5'b00100: H_row_max_last_location_reg <= PE_location_row_out[4];
        5'b00101: H_row_max_last_location_reg <= PE_location_row_out[5];
        5'b00110: H_row_max_last_location_reg <= PE_location_row_out[6];
        5'b00111: H_row_max_last_location_reg <= PE_location_row_out[7];
        5'b01000: H_row_max_last_location_reg <= PE_location_row_out[8];
        5'b01001: H_row_max_last_location_reg <= PE_location_row_out[9];
        5'b01010: H_row_max_last_location_reg <= PE_location_row_out[10];
        5'b01011: H_row_max_last_location_reg <= PE_location_row_out[11];
        5'b01100: H_row_max_last_location_reg <= PE_location_row_out[12];
        5'b01101: H_row_max_last_location_reg <= PE_location_row_out[13];
        5'b01110: H_row_max_last_location_reg <= PE_location_row_out[14];
        5'b01111: H_row_max_last_location_reg <= PE_location_row_out[15];

        5'b10000: H_row_max_last_location_reg <= PE_location_row_out[16];
        5'b10001: H_row_max_last_location_reg <= PE_location_row_out[17];
        5'b10010: H_row_max_last_location_reg <= PE_location_row_out[18];
        5'b10011: H_row_max_last_location_reg <= PE_location_row_out[19];
        5'b10100: H_row_max_last_location_reg <= PE_location_row_out[20];
        5'b10101: H_row_max_last_location_reg <= PE_location_row_out[21];
        5'b10110: H_row_max_last_location_reg <= PE_location_row_out[22];
        5'b10111: H_row_max_last_location_reg <= PE_location_row_out[23];
        5'b11000: H_row_max_last_location_reg <= PE_location_row_out[24];
        5'b11001: H_row_max_last_location_reg <= PE_location_row_out[25];
        5'b11010: H_row_max_last_location_reg <= PE_location_row_out[26];
        5'b11011: H_row_max_last_location_reg <= PE_location_row_out[27];
        5'b11100: H_row_max_last_location_reg <= PE_location_row_out[28];
        5'b11101: H_row_max_last_location_reg <= PE_location_row_out[29];
        5'b11110: H_row_max_last_location_reg <= PE_location_row_out[30];
        5'b11111: H_row_max_last_location_reg <= PE_location_row_out[31];
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
        5'b00000: H_max_out <= CMP_H_max_out[0];
        5'b00001: H_max_out <= CMP_H_max_out[1];
        5'b00010: H_max_out <= CMP_H_max_out[2];
        5'b00011: H_max_out <= CMP_H_max_out[3];
        5'b00100: H_max_out <= CMP_H_max_out[4];
        5'b00101: H_max_out <= CMP_H_max_out[5];
        5'b00110: H_max_out <= CMP_H_max_out[6];
        5'b00111: H_max_out <= CMP_H_max_out[7];
        5'b01000: H_max_out <= CMP_H_max_out[8];
        5'b01001: H_max_out <= CMP_H_max_out[9];
        5'b01010: H_max_out <= CMP_H_max_out[10];
        5'b01011: H_max_out <= CMP_H_max_out[11];
        5'b01100: H_max_out <= CMP_H_max_out[12];
        5'b01101: H_max_out <= CMP_H_max_out[13];
        5'b01110: H_max_out <= CMP_H_max_out[14];
        5'b01111: H_max_out <= CMP_H_max_out[15];

        5'b10000: H_max_out <= CMP_H_max_out[16];
        5'b10001: H_max_out <= CMP_H_max_out[17];
        5'b10010: H_max_out <= CMP_H_max_out[18];
        5'b10011: H_max_out <= CMP_H_max_out[19];
        5'b10100: H_max_out <= CMP_H_max_out[20];
        5'b10101: H_max_out <= CMP_H_max_out[21];
        5'b10110: H_max_out <= CMP_H_max_out[22];
        5'b10111: H_max_out <= CMP_H_max_out[23];
        5'b11000: H_max_out <= CMP_H_max_out[24];
        5'b11001: H_max_out <= CMP_H_max_out[25];
        5'b11010: H_max_out <= CMP_H_max_out[26];
        5'b11011: H_max_out <= CMP_H_max_out[27];
        5'b11100: H_max_out <= CMP_H_max_out[28];
        5'b11101: H_max_out <= CMP_H_max_out[29];
        5'b11110: H_max_out <= CMP_H_max_out[30];
        5'b11111: H_max_out <= CMP_H_max_out[31];
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
        5'b00000: H_max_location <= CMP_location_out[0];
        5'b00001: H_max_location <= CMP_location_out[1];
        5'b00010: H_max_location <= CMP_location_out[2];
        5'b00011: H_max_location <= CMP_location_out[3];
        5'b00100: H_max_location <= CMP_location_out[4];
        5'b00101: H_max_location <= CMP_location_out[5];
        5'b00110: H_max_location <= CMP_location_out[6];
        5'b00111: H_max_location <= CMP_location_out[7];
        5'b01000: H_max_location <= CMP_location_out[8];
        5'b01001: H_max_location <= CMP_location_out[9];
        5'b01010: H_max_location <= CMP_location_out[10];
        5'b01011: H_max_location <= CMP_location_out[11];
        5'b01100: H_max_location <= CMP_location_out[12];
        5'b01101: H_max_location <= CMP_location_out[13];
        5'b01110: H_max_location <= CMP_location_out[14];
        5'b01111: H_max_location <= CMP_location_out[15];

        5'b10000: H_max_location <= CMP_location_out[16];
        5'b10001: H_max_location <= CMP_location_out[17];
        5'b10010: H_max_location <= CMP_location_out[18];
        5'b10011: H_max_location <= CMP_location_out[19];
        5'b10100: H_max_location <= CMP_location_out[20];
        5'b10101: H_max_location <= CMP_location_out[21];
        5'b10110: H_max_location <= CMP_location_out[22];
        5'b10111: H_max_location <= CMP_location_out[23];
        5'b11000: H_max_location <= CMP_location_out[24];
        5'b11001: H_max_location <= CMP_location_out[25];
        5'b11010: H_max_location <= CMP_location_out[26];
        5'b11011: H_max_location <= CMP_location_out[27];
        5'b11100: H_max_location <= CMP_location_out[28];
        5'b11101: H_max_location <= CMP_location_out[29];
        5'b11110: H_max_location <= CMP_location_out[30];
        5'b11111: H_max_location <= CMP_location_out[31];

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
        5'b00000: diagonal_score <= PE_H_out_col[0];
        5'b00001: diagonal_score <= PE_H_out_col[1];
        5'b00010: diagonal_score <= PE_H_out_col[2];
        5'b00011: diagonal_score <= PE_H_out_col[3];
        5'b00100: diagonal_score <= PE_H_out_col[4];
        5'b00101: diagonal_score <= PE_H_out_col[5];
        5'b00110: diagonal_score <= PE_H_out_col[6];
        5'b00111: diagonal_score <= PE_H_out_col[7];
        5'b01000: diagonal_score <= PE_H_out_col[8];
        5'b01001: diagonal_score <= PE_H_out_col[9];
        5'b01010: diagonal_score <= PE_H_out_col[10];
        5'b01011: diagonal_score <= PE_H_out_col[11];
        5'b01100: diagonal_score <= PE_H_out_col[12];
        5'b01101: diagonal_score <= PE_H_out_col[13];
        5'b01110: diagonal_score <= PE_H_out_col[14];
        5'b01111: diagonal_score <= PE_H_out_col[15];

        5'b10000: diagonal_score <= PE_H_out_col[16];
        5'b10001: diagonal_score <= PE_H_out_col[17];
        5'b10010: diagonal_score <= PE_H_out_col[18];
        5'b10011: diagonal_score <= PE_H_out_col[19];
        5'b10100: diagonal_score <= PE_H_out_col[20];
        5'b10101: diagonal_score <= PE_H_out_col[21];
        5'b10110: diagonal_score <= PE_H_out_col[22];
        5'b10111: diagonal_score <= PE_H_out_col[23];
        5'b11000: diagonal_score <= PE_H_out_col[24];
        5'b11001: diagonal_score <= PE_H_out_col[25];
        5'b11010: diagonal_score <= PE_H_out_col[26];
        5'b11011: diagonal_score <= PE_H_out_col[27];
        5'b11100: diagonal_score <= PE_H_out_col[28];
        5'b11101: diagonal_score <= PE_H_out_col[29];
        5'b11110: diagonal_score <= PE_H_out_col[30];
        5'b11111: diagonal_score <= PE_H_out_col[31];
        endcase
    end
    else begin
        diagonal_score <= diagonal_score;
    end
end
endmodule
