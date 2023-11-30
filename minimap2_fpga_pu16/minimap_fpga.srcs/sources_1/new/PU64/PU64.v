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
module PU64 #(
	parameter integer DATA_WIDTH  = 4,
	parameter integer SCORE_WIDTH = 16,
	parameter integer LOCATION_WIDTH = 32,
	parameter integer PE_NUM = 64,
    parameter integer LOG_PE_NUM = 6,
    parameter integer BT_OUT_WIDTH = 64,
    parameter integer EN_LENGTH = 14,
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

    Nr_32         ,
    Nr_33         ,
    Nr_34         ,
    Nr_35         ,
    Nr_36         ,
    Nr_37         ,
    Nr_38         ,
    Nr_39         ,
    Nr_40         ,
    Nr_41         ,
    Nr_42         ,
    Nr_43         ,
    Nr_44         ,
    Nr_45         ,
    Nr_46         ,
    Nr_47         ,
    Nr_48         ,
    Nr_49         ,
    Nr_50         ,
    Nr_51         ,
    Nr_52         ,
    Nr_53         ,
    Nr_54         ,
    Nr_55         ,
    Nr_56         ,
    Nr_57         ,
    Nr_58         ,
    Nr_59         ,
    Nr_60         ,
    Nr_61         ,
    Nr_62         ,
    Nr_63         ,

    

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

    location_in_32,
    location_in_33,
    location_in_34,
    location_in_35,
    location_in_36,
    location_in_37,
    location_in_38,
    location_in_39,
    location_in_40,
    location_in_41,
    location_in_42,
    location_in_43,
    location_in_44,
    location_in_45,
    location_in_46,
    location_in_47,
    location_in_48,
    location_in_49,
    location_in_50,
    location_in_51,
    location_in_52,
    location_in_53,
    location_in_54,
    location_in_55,
    location_in_56,
    location_in_57,
    location_in_58,
    location_in_59,
    location_in_60,
    location_in_61,
    location_in_62,
    location_in_63,

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

input wire [DATA_WIDTH-1: 0] Nr_32 ; 
input wire [DATA_WIDTH-1: 0] Nr_33 ; 
input wire [DATA_WIDTH-1: 0] Nr_34 ; 
input wire [DATA_WIDTH-1: 0] Nr_35 ; 
input wire [DATA_WIDTH-1: 0] Nr_36 ; 
input wire [DATA_WIDTH-1: 0] Nr_37 ; 
input wire [DATA_WIDTH-1: 0] Nr_38 ; 
input wire [DATA_WIDTH-1: 0] Nr_39 ; 
input wire [DATA_WIDTH-1: 0] Nr_40 ; 
input wire [DATA_WIDTH-1: 0] Nr_41 ; 
input wire [DATA_WIDTH-1: 0] Nr_42 ; 
input wire [DATA_WIDTH-1: 0] Nr_43 ; 
input wire [DATA_WIDTH-1: 0] Nr_44 ; 
input wire [DATA_WIDTH-1: 0] Nr_45 ; 
input wire [DATA_WIDTH-1: 0] Nr_46 ; 
input wire [DATA_WIDTH-1: 0] Nr_47 ; 
input wire [DATA_WIDTH-1: 0] Nr_48 ; 
input wire [DATA_WIDTH-1: 0] Nr_49 ; 
input wire [DATA_WIDTH-1: 0] Nr_50 ; 
input wire [DATA_WIDTH-1: 0] Nr_51 ; 
input wire [DATA_WIDTH-1: 0] Nr_52 ; 
input wire [DATA_WIDTH-1: 0] Nr_53 ; 
input wire [DATA_WIDTH-1: 0] Nr_54 ; 
input wire [DATA_WIDTH-1: 0] Nr_55 ; 
input wire [DATA_WIDTH-1: 0] Nr_56 ; 
input wire [DATA_WIDTH-1: 0] Nr_57 ; 
input wire [DATA_WIDTH-1: 0] Nr_58 ; 
input wire [DATA_WIDTH-1: 0] Nr_59 ; 
input wire [DATA_WIDTH-1: 0] Nr_60 ; 
input wire [DATA_WIDTH-1: 0] Nr_61 ; 
input wire [DATA_WIDTH-1: 0] Nr_62 ; 
input wire [DATA_WIDTH-1: 0] Nr_63 ; 

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

input wire [LOCATION_WIDTH-1:0] location_in_32 ; 
input wire [LOCATION_WIDTH-1:0] location_in_33 ; 
input wire [LOCATION_WIDTH-1:0] location_in_34 ; 
input wire [LOCATION_WIDTH-1:0] location_in_35 ; 
input wire [LOCATION_WIDTH-1:0] location_in_36 ; 
input wire [LOCATION_WIDTH-1:0] location_in_37 ; 
input wire [LOCATION_WIDTH-1:0] location_in_38 ; 
input wire [LOCATION_WIDTH-1:0] location_in_39 ; 
input wire [LOCATION_WIDTH-1:0] location_in_40 ; 
input wire [LOCATION_WIDTH-1:0] location_in_41 ; 
input wire [LOCATION_WIDTH-1:0] location_in_42 ; 
input wire [LOCATION_WIDTH-1:0] location_in_43 ; 
input wire [LOCATION_WIDTH-1:0] location_in_44 ; 
input wire [LOCATION_WIDTH-1:0] location_in_45 ; 
input wire [LOCATION_WIDTH-1:0] location_in_46 ; 
input wire [LOCATION_WIDTH-1:0] location_in_47 ; 
input wire [LOCATION_WIDTH-1:0] location_in_48 ; 
input wire [LOCATION_WIDTH-1:0] location_in_49 ; 
input wire [LOCATION_WIDTH-1:0] location_in_50 ; 
input wire [LOCATION_WIDTH-1:0] location_in_51 ; 
input wire [LOCATION_WIDTH-1:0] location_in_52 ; 
input wire [LOCATION_WIDTH-1:0] location_in_53 ; 
input wire [LOCATION_WIDTH-1:0] location_in_54 ; 
input wire [LOCATION_WIDTH-1:0] location_in_55 ; 
input wire [LOCATION_WIDTH-1:0] location_in_56 ; 
input wire [LOCATION_WIDTH-1:0] location_in_57 ; 
input wire [LOCATION_WIDTH-1:0] location_in_58 ; 
input wire [LOCATION_WIDTH-1:0] location_in_59 ; 
input wire [LOCATION_WIDTH-1:0] location_in_60 ; 
input wire [LOCATION_WIDTH-1:0] location_in_61 ; 
input wire [LOCATION_WIDTH-1:0] location_in_62 ; 
input wire [LOCATION_WIDTH-1:0] location_in_63 ; 

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

MUX6to64 MUX6to64_INST (
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

assign PE_Nr[32] = Nr_32;
assign PE_Nr[33] = Nr_33;
assign PE_Nr[34] = Nr_34;
assign PE_Nr[35] = Nr_35;
assign PE_Nr[36] = Nr_36;
assign PE_Nr[37] = Nr_37;
assign PE_Nr[38] = Nr_38;
assign PE_Nr[39] = Nr_39;
assign PE_Nr[40] = Nr_40;
assign PE_Nr[41] = Nr_41;
assign PE_Nr[42] = Nr_42;
assign PE_Nr[43] = Nr_43;
assign PE_Nr[44] = Nr_44;
assign PE_Nr[45] = Nr_45;
assign PE_Nr[46] = Nr_46;
assign PE_Nr[47] = Nr_47;
assign PE_Nr[48] = Nr_48;
assign PE_Nr[49] = Nr_49;
assign PE_Nr[50] = Nr_50;
assign PE_Nr[51] = Nr_51;
assign PE_Nr[52] = Nr_52;
assign PE_Nr[53] = Nr_53;
assign PE_Nr[54] = Nr_54;
assign PE_Nr[55] = Nr_55;
assign PE_Nr[56] = Nr_56;
assign PE_Nr[57] = Nr_57;
assign PE_Nr[58] = Nr_58;
assign PE_Nr[59] = Nr_59;
assign PE_Nr[60] = Nr_60;
assign PE_Nr[61] = Nr_61;
assign PE_Nr[62] = Nr_62;
assign PE_Nr[63] = Nr_63;


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

assign PE_location_in[32] = location_in_32;
assign PE_location_in[33] = location_in_33;
assign PE_location_in[34] = location_in_34;
assign PE_location_in[35] = location_in_35;
assign PE_location_in[36] = location_in_36;
assign PE_location_in[37] = location_in_37;
assign PE_location_in[38] = location_in_38;
assign PE_location_in[39] = location_in_39;
assign PE_location_in[40] = location_in_40;
assign PE_location_in[41] = location_in_41;
assign PE_location_in[42] = location_in_42;
assign PE_location_in[43] = location_in_43;
assign PE_location_in[44] = location_in_44;
assign PE_location_in[45] = location_in_45;
assign PE_location_in[46] = location_in_46;
assign PE_location_in[47] = location_in_47;
assign PE_location_in[48] = location_in_48;
assign PE_location_in[49] = location_in_49;
assign PE_location_in[50] = location_in_50;
assign PE_location_in[51] = location_in_51;
assign PE_location_in[52] = location_in_52;
assign PE_location_in[53] = location_in_53;
assign PE_location_in[54] = location_in_54;
assign PE_location_in[55] = location_in_55;
assign PE_location_in[56] = location_in_56;
assign PE_location_in[57] = location_in_57;
assign PE_location_in[58] = location_in_58;
assign PE_location_in[59] = location_in_59;
assign PE_location_in[60] = location_in_60;
assign PE_location_in[61] = location_in_61;
assign PE_location_in[62] = location_in_62;
assign PE_location_in[63] = location_in_63;


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
        6'b000000: bt_out <= PE_bt_out_reg[0];
        6'b000001: bt_out <= PE_bt_out_reg[1];
        6'b000010: bt_out <= PE_bt_out_reg[2];
        6'b000011: bt_out <= PE_bt_out_reg[3];
        6'b000100: bt_out <= PE_bt_out_reg[4];
        6'b000101: bt_out <= PE_bt_out_reg[5];
        6'b000110: bt_out <= PE_bt_out_reg[6];
        6'b000111: bt_out <= PE_bt_out_reg[7];
        6'b001000: bt_out <= PE_bt_out_reg[8];
        6'b001001: bt_out <= PE_bt_out_reg[9];
        6'b001010: bt_out <= PE_bt_out_reg[10];
        6'b001011: bt_out <= PE_bt_out_reg[11];
        6'b001100: bt_out <= PE_bt_out_reg[12];
        6'b001101: bt_out <= PE_bt_out_reg[13];
        6'b001110: bt_out <= PE_bt_out_reg[14];
        6'b001111: bt_out <= PE_bt_out_reg[15];

        6'b010000: bt_out <= PE_bt_out_reg[16];
        6'b010001: bt_out <= PE_bt_out_reg[17];
        6'b010010: bt_out <= PE_bt_out_reg[18];
        6'b010011: bt_out <= PE_bt_out_reg[19];
        6'b010100: bt_out <= PE_bt_out_reg[20];
        6'b010101: bt_out <= PE_bt_out_reg[21];
        6'b010110: bt_out <= PE_bt_out_reg[22];
        6'b010111: bt_out <= PE_bt_out_reg[23];
        6'b011000: bt_out <= PE_bt_out_reg[24];
        6'b011001: bt_out <= PE_bt_out_reg[25];
        6'b011010: bt_out <= PE_bt_out_reg[26];
        6'b011011: bt_out <= PE_bt_out_reg[27];
        6'b011100: bt_out <= PE_bt_out_reg[28];
        6'b011101: bt_out <= PE_bt_out_reg[29];
        6'b011110: bt_out <= PE_bt_out_reg[30];
        6'b011111: bt_out <= PE_bt_out_reg[31];

        6'b100000: bt_out <= PE_bt_out_reg[32];
        6'b100001: bt_out <= PE_bt_out_reg[33];
        6'b100010: bt_out <= PE_bt_out_reg[34];
        6'b100011: bt_out <= PE_bt_out_reg[35];
        6'b100100: bt_out <= PE_bt_out_reg[36];
        6'b100101: bt_out <= PE_bt_out_reg[37];
        6'b100110: bt_out <= PE_bt_out_reg[38];
        6'b100111: bt_out <= PE_bt_out_reg[39];
        6'b101000: bt_out <= PE_bt_out_reg[40];
        6'b101001: bt_out <= PE_bt_out_reg[41];
        6'b101010: bt_out <= PE_bt_out_reg[42];
        6'b101011: bt_out <= PE_bt_out_reg[43];
        6'b101100: bt_out <= PE_bt_out_reg[44];
        6'b101101: bt_out <= PE_bt_out_reg[45];
        6'b101110: bt_out <= PE_bt_out_reg[46];
        6'b101111: bt_out <= PE_bt_out_reg[47];

        6'b110000: bt_out <= PE_bt_out_reg[48];
        6'b110001: bt_out <= PE_bt_out_reg[49];
        6'b110010: bt_out <= PE_bt_out_reg[50];
        6'b110011: bt_out <= PE_bt_out_reg[51];
        6'b110100: bt_out <= PE_bt_out_reg[52];
        6'b110101: bt_out <= PE_bt_out_reg[53];
        6'b110110: bt_out <= PE_bt_out_reg[54];
        6'b110111: bt_out <= PE_bt_out_reg[55];
        6'b111000: bt_out <= PE_bt_out_reg[56];
        6'b111001: bt_out <= PE_bt_out_reg[57];
        6'b111010: bt_out <= PE_bt_out_reg[58];
        6'b111011: bt_out <= PE_bt_out_reg[59];
        6'b111100: bt_out <= PE_bt_out_reg[60];
        6'b111101: bt_out <= PE_bt_out_reg[61];
        6'b111110: bt_out <= PE_bt_out_reg[62];
        6'b111111: bt_out <= PE_bt_out_reg[63];

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
        6'b000000: H_col_max <= COL_H_max[0];
        6'b000001: H_col_max <= COL_H_max[1];
        6'b000010: H_col_max <= COL_H_max[2];
        6'b000011: H_col_max <= COL_H_max[3];
        6'b000100: H_col_max <= COL_H_max[4];
        6'b000101: H_col_max <= COL_H_max[5];
        6'b000110: H_col_max <= COL_H_max[6];
        6'b000111: H_col_max <= COL_H_max[7];
        6'b001000: H_col_max <= COL_H_max[8];
        6'b001001: H_col_max <= COL_H_max[9];
        6'b001010: H_col_max <= COL_H_max[10];
        6'b001011: H_col_max <= COL_H_max[11];
        6'b001100: H_col_max <= COL_H_max[12];
        6'b001101: H_col_max <= COL_H_max[13];
        6'b001110: H_col_max <= COL_H_max[14];
        6'b001111: H_col_max <= COL_H_max[15];

        6'b010000: H_col_max <= COL_H_max[16];
        6'b010001: H_col_max <= COL_H_max[17];
        6'b010010: H_col_max <= COL_H_max[18];
        6'b010011: H_col_max <= COL_H_max[19];
        6'b010100: H_col_max <= COL_H_max[20];
        6'b010101: H_col_max <= COL_H_max[21];
        6'b010110: H_col_max <= COL_H_max[22];
        6'b010111: H_col_max <= COL_H_max[23];
        6'b011000: H_col_max <= COL_H_max[24];
        6'b011001: H_col_max <= COL_H_max[25];
        6'b011010: H_col_max <= COL_H_max[26];
        6'b011011: H_col_max <= COL_H_max[27];
        6'b011100: H_col_max <= COL_H_max[28];
        6'b011101: H_col_max <= COL_H_max[29];
        6'b011110: H_col_max <= COL_H_max[30];
        6'b011111: H_col_max <= COL_H_max[31];

        6'b100000: H_col_max <= COL_H_max[32];
        6'b100001: H_col_max <= COL_H_max[33];
        6'b100010: H_col_max <= COL_H_max[34];
        6'b100011: H_col_max <= COL_H_max[35];
        6'b100100: H_col_max <= COL_H_max[36];
        6'b100101: H_col_max <= COL_H_max[37];
        6'b100110: H_col_max <= COL_H_max[38];
        6'b100111: H_col_max <= COL_H_max[39];
        6'b101000: H_col_max <= COL_H_max[40];
        6'b101001: H_col_max <= COL_H_max[41];
        6'b101010: H_col_max <= COL_H_max[42];
        6'b101011: H_col_max <= COL_H_max[43];
        6'b101100: H_col_max <= COL_H_max[44];
        6'b101101: H_col_max <= COL_H_max[45];
        6'b101110: H_col_max <= COL_H_max[46];
        6'b101111: H_col_max <= COL_H_max[47];

        6'b110000: H_col_max <= COL_H_max[48];
        6'b110001: H_col_max <= COL_H_max[49];
        6'b110010: H_col_max <= COL_H_max[50];
        6'b110011: H_col_max <= COL_H_max[51];
        6'b110100: H_col_max <= COL_H_max[52];
        6'b110101: H_col_max <= COL_H_max[53];
        6'b110110: H_col_max <= COL_H_max[54];
        6'b110111: H_col_max <= COL_H_max[55];
        6'b111000: H_col_max <= COL_H_max[56];
        6'b111001: H_col_max <= COL_H_max[57];
        6'b111010: H_col_max <= COL_H_max[58];
        6'b111011: H_col_max <= COL_H_max[59];
        6'b111100: H_col_max <= COL_H_max[60];
        6'b111101: H_col_max <= COL_H_max[61];
        6'b111110: H_col_max <= COL_H_max[62];
        6'b111111: H_col_max <= COL_H_max[63];
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

        6'b000000: H_col_max_location <= COL_location_out[0];
        6'b000001: H_col_max_location <= COL_location_out[1];
        6'b000010: H_col_max_location <= COL_location_out[2];
        6'b000011: H_col_max_location <= COL_location_out[3];
        6'b000100: H_col_max_location <= COL_location_out[4];
        6'b000101: H_col_max_location <= COL_location_out[5];
        6'b000110: H_col_max_location <= COL_location_out[6];
        6'b000111: H_col_max_location <= COL_location_out[7];
        6'b001000: H_col_max_location <= COL_location_out[8];
        6'b001001: H_col_max_location <= COL_location_out[9];
        6'b001010: H_col_max_location <= COL_location_out[10];
        6'b001011: H_col_max_location <= COL_location_out[11];
        6'b001100: H_col_max_location <= COL_location_out[12];
        6'b001101: H_col_max_location <= COL_location_out[13];
        6'b001110: H_col_max_location <= COL_location_out[14];
        6'b001111: H_col_max_location <= COL_location_out[15];
        6'b010000: H_col_max_location <= COL_location_out[16];
        6'b010001: H_col_max_location <= COL_location_out[17];
        6'b010010: H_col_max_location <= COL_location_out[18];
        6'b010011: H_col_max_location <= COL_location_out[19];
        6'b010100: H_col_max_location <= COL_location_out[20];
        6'b010101: H_col_max_location <= COL_location_out[21];
        6'b010110: H_col_max_location <= COL_location_out[22];
        6'b010111: H_col_max_location <= COL_location_out[23];
        6'b011000: H_col_max_location <= COL_location_out[24];
        6'b011001: H_col_max_location <= COL_location_out[25];
        6'b011010: H_col_max_location <= COL_location_out[26];
        6'b011011: H_col_max_location <= COL_location_out[27];
        6'b011100: H_col_max_location <= COL_location_out[28];
        6'b011101: H_col_max_location <= COL_location_out[29];
        6'b011110: H_col_max_location <= COL_location_out[30];
        6'b011111: H_col_max_location <= COL_location_out[31];
        6'b100000: H_col_max_location <= COL_location_out[32];
        6'b100001: H_col_max_location <= COL_location_out[33];
        6'b100010: H_col_max_location <= COL_location_out[34];
        6'b100011: H_col_max_location <= COL_location_out[35];
        6'b100100: H_col_max_location <= COL_location_out[36];
        6'b100101: H_col_max_location <= COL_location_out[37];
        6'b100110: H_col_max_location <= COL_location_out[38];
        6'b100111: H_col_max_location <= COL_location_out[39];
        6'b101000: H_col_max_location <= COL_location_out[40];
        6'b101001: H_col_max_location <= COL_location_out[41];
        6'b101010: H_col_max_location <= COL_location_out[42];
        6'b101011: H_col_max_location <= COL_location_out[43];
        6'b101100: H_col_max_location <= COL_location_out[44];
        6'b101101: H_col_max_location <= COL_location_out[45];
        6'b101110: H_col_max_location <= COL_location_out[46];
        6'b101111: H_col_max_location <= COL_location_out[47];
        6'b110000: H_col_max_location <= COL_location_out[48];
        6'b110001: H_col_max_location <= COL_location_out[49];
        6'b110010: H_col_max_location <= COL_location_out[50];
        6'b110011: H_col_max_location <= COL_location_out[51];
        6'b110100: H_col_max_location <= COL_location_out[52];
        6'b110101: H_col_max_location <= COL_location_out[53];
        6'b110110: H_col_max_location <= COL_location_out[54];
        6'b110111: H_col_max_location <= COL_location_out[55];
        6'b111000: H_col_max_location <= COL_location_out[56];
        6'b111001: H_col_max_location <= COL_location_out[57];
        6'b111010: H_col_max_location <= COL_location_out[58];
        6'b111011: H_col_max_location <= COL_location_out[59];
        6'b111100: H_col_max_location <= COL_location_out[60];
        6'b111101: H_col_max_location <= COL_location_out[61];
        6'b111110: H_col_max_location <= COL_location_out[62];
        6'b111111: H_col_max_location <= COL_location_out[63];
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

        6'b000000: H_row_max_last_reg <= PE_H_row_max[0] ;
        6'b000001: H_row_max_last_reg <= PE_H_row_max[1] ;
        6'b000010: H_row_max_last_reg <= PE_H_row_max[2] ;
        6'b000011: H_row_max_last_reg <= PE_H_row_max[3] ;
        6'b000100: H_row_max_last_reg <= PE_H_row_max[4] ;
        6'b000101: H_row_max_last_reg <= PE_H_row_max[5] ;
        6'b000110: H_row_max_last_reg <= PE_H_row_max[6] ;
        6'b000111: H_row_max_last_reg <= PE_H_row_max[7] ;
        6'b001000: H_row_max_last_reg <= PE_H_row_max[8] ;
        6'b001001: H_row_max_last_reg <= PE_H_row_max[9] ;
        6'b001010: H_row_max_last_reg <= PE_H_row_max[10];
        6'b001011: H_row_max_last_reg <= PE_H_row_max[11];
        6'b001100: H_row_max_last_reg <= PE_H_row_max[12];
        6'b001101: H_row_max_last_reg <= PE_H_row_max[13];
        6'b001110: H_row_max_last_reg <= PE_H_row_max[14];
        6'b001111: H_row_max_last_reg <= PE_H_row_max[15];
        6'b010000: H_row_max_last_reg <= PE_H_row_max[16];
        6'b010001: H_row_max_last_reg <= PE_H_row_max[17];
        6'b010010: H_row_max_last_reg <= PE_H_row_max[18];
        6'b010011: H_row_max_last_reg <= PE_H_row_max[19];
        6'b010100: H_row_max_last_reg <= PE_H_row_max[20];
        6'b010101: H_row_max_last_reg <= PE_H_row_max[21];
        6'b010110: H_row_max_last_reg <= PE_H_row_max[22];
        6'b010111: H_row_max_last_reg <= PE_H_row_max[23];
        6'b011000: H_row_max_last_reg <= PE_H_row_max[24];
        6'b011001: H_row_max_last_reg <= PE_H_row_max[25];
        6'b011010: H_row_max_last_reg <= PE_H_row_max[26];
        6'b011011: H_row_max_last_reg <= PE_H_row_max[27];
        6'b011100: H_row_max_last_reg <= PE_H_row_max[28];
        6'b011101: H_row_max_last_reg <= PE_H_row_max[29];
        6'b011110: H_row_max_last_reg <= PE_H_row_max[30];
        6'b011111: H_row_max_last_reg <= PE_H_row_max[31];
        6'b100000: H_row_max_last_reg <= PE_H_row_max[32];
        6'b100001: H_row_max_last_reg <= PE_H_row_max[33];
        6'b100010: H_row_max_last_reg <= PE_H_row_max[34];
        6'b100011: H_row_max_last_reg <= PE_H_row_max[35];
        6'b100100: H_row_max_last_reg <= PE_H_row_max[36];
        6'b100101: H_row_max_last_reg <= PE_H_row_max[37];
        6'b100110: H_row_max_last_reg <= PE_H_row_max[38];
        6'b100111: H_row_max_last_reg <= PE_H_row_max[39];
        6'b101000: H_row_max_last_reg <= PE_H_row_max[40];
        6'b101001: H_row_max_last_reg <= PE_H_row_max[41];
        6'b101010: H_row_max_last_reg <= PE_H_row_max[42];
        6'b101011: H_row_max_last_reg <= PE_H_row_max[43];
        6'b101100: H_row_max_last_reg <= PE_H_row_max[44];
        6'b101101: H_row_max_last_reg <= PE_H_row_max[45];
        6'b101110: H_row_max_last_reg <= PE_H_row_max[46];
        6'b101111: H_row_max_last_reg <= PE_H_row_max[47];
        6'b110000: H_row_max_last_reg <= PE_H_row_max[48];
        6'b110001: H_row_max_last_reg <= PE_H_row_max[49];
        6'b110010: H_row_max_last_reg <= PE_H_row_max[50];
        6'b110011: H_row_max_last_reg <= PE_H_row_max[51];
        6'b110100: H_row_max_last_reg <= PE_H_row_max[52];
        6'b110101: H_row_max_last_reg <= PE_H_row_max[53];
        6'b110110: H_row_max_last_reg <= PE_H_row_max[54];
        6'b110111: H_row_max_last_reg <= PE_H_row_max[55];
        6'b111000: H_row_max_last_reg <= PE_H_row_max[56];
        6'b111001: H_row_max_last_reg <= PE_H_row_max[57];
        6'b111010: H_row_max_last_reg <= PE_H_row_max[58];
        6'b111011: H_row_max_last_reg <= PE_H_row_max[59];
        6'b111100: H_row_max_last_reg <= PE_H_row_max[60];
        6'b111101: H_row_max_last_reg <= PE_H_row_max[61];
        6'b111110: H_row_max_last_reg <= PE_H_row_max[62];
        6'b111111: H_row_max_last_reg <= PE_H_row_max[63];
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

        6'b000000: H_row_max_last_location_reg <= PE_location_row_out[0] ;
        6'b000001: H_row_max_last_location_reg <= PE_location_row_out[1] ;
        6'b000010: H_row_max_last_location_reg <= PE_location_row_out[2] ;
        6'b000011: H_row_max_last_location_reg <= PE_location_row_out[3] ;
        6'b000100: H_row_max_last_location_reg <= PE_location_row_out[4] ;
        6'b000101: H_row_max_last_location_reg <= PE_location_row_out[5] ;
        6'b000110: H_row_max_last_location_reg <= PE_location_row_out[6] ;
        6'b000111: H_row_max_last_location_reg <= PE_location_row_out[7] ;
        6'b001000: H_row_max_last_location_reg <= PE_location_row_out[8] ;
        6'b001001: H_row_max_last_location_reg <= PE_location_row_out[9] ;
        6'b001010: H_row_max_last_location_reg <= PE_location_row_out[10];
        6'b001011: H_row_max_last_location_reg <= PE_location_row_out[11];
        6'b001100: H_row_max_last_location_reg <= PE_location_row_out[12];
        6'b001101: H_row_max_last_location_reg <= PE_location_row_out[13];
        6'b001110: H_row_max_last_location_reg <= PE_location_row_out[14];
        6'b001111: H_row_max_last_location_reg <= PE_location_row_out[15];
        6'b010000: H_row_max_last_location_reg <= PE_location_row_out[16];
        6'b010001: H_row_max_last_location_reg <= PE_location_row_out[17];
        6'b010010: H_row_max_last_location_reg <= PE_location_row_out[18];
        6'b010011: H_row_max_last_location_reg <= PE_location_row_out[19];
        6'b010100: H_row_max_last_location_reg <= PE_location_row_out[20];
        6'b010101: H_row_max_last_location_reg <= PE_location_row_out[21];
        6'b010110: H_row_max_last_location_reg <= PE_location_row_out[22];
        6'b010111: H_row_max_last_location_reg <= PE_location_row_out[23];
        6'b011000: H_row_max_last_location_reg <= PE_location_row_out[24];
        6'b011001: H_row_max_last_location_reg <= PE_location_row_out[25];
        6'b011010: H_row_max_last_location_reg <= PE_location_row_out[26];
        6'b011011: H_row_max_last_location_reg <= PE_location_row_out[27];
        6'b011100: H_row_max_last_location_reg <= PE_location_row_out[28];
        6'b011101: H_row_max_last_location_reg <= PE_location_row_out[29];
        6'b011110: H_row_max_last_location_reg <= PE_location_row_out[30];
        6'b011111: H_row_max_last_location_reg <= PE_location_row_out[31];
        6'b100000: H_row_max_last_location_reg <= PE_location_row_out[32];
        6'b100001: H_row_max_last_location_reg <= PE_location_row_out[33];
        6'b100010: H_row_max_last_location_reg <= PE_location_row_out[34];
        6'b100011: H_row_max_last_location_reg <= PE_location_row_out[35];
        6'b100100: H_row_max_last_location_reg <= PE_location_row_out[36];
        6'b100101: H_row_max_last_location_reg <= PE_location_row_out[37];
        6'b100110: H_row_max_last_location_reg <= PE_location_row_out[38];
        6'b100111: H_row_max_last_location_reg <= PE_location_row_out[39];
        6'b101000: H_row_max_last_location_reg <= PE_location_row_out[40];
        6'b101001: H_row_max_last_location_reg <= PE_location_row_out[41];
        6'b101010: H_row_max_last_location_reg <= PE_location_row_out[42];
        6'b101011: H_row_max_last_location_reg <= PE_location_row_out[43];
        6'b101100: H_row_max_last_location_reg <= PE_location_row_out[44];
        6'b101101: H_row_max_last_location_reg <= PE_location_row_out[45];
        6'b101110: H_row_max_last_location_reg <= PE_location_row_out[46];
        6'b101111: H_row_max_last_location_reg <= PE_location_row_out[47];
        6'b110000: H_row_max_last_location_reg <= PE_location_row_out[48];
        6'b110001: H_row_max_last_location_reg <= PE_location_row_out[49];
        6'b110010: H_row_max_last_location_reg <= PE_location_row_out[50];
        6'b110011: H_row_max_last_location_reg <= PE_location_row_out[51];
        6'b110100: H_row_max_last_location_reg <= PE_location_row_out[52];
        6'b110101: H_row_max_last_location_reg <= PE_location_row_out[53];
        6'b110110: H_row_max_last_location_reg <= PE_location_row_out[54];
        6'b110111: H_row_max_last_location_reg <= PE_location_row_out[55];
        6'b111000: H_row_max_last_location_reg <= PE_location_row_out[56];
        6'b111001: H_row_max_last_location_reg <= PE_location_row_out[57];
        6'b111010: H_row_max_last_location_reg <= PE_location_row_out[58];
        6'b111011: H_row_max_last_location_reg <= PE_location_row_out[59];
        6'b111100: H_row_max_last_location_reg <= PE_location_row_out[60];
        6'b111101: H_row_max_last_location_reg <= PE_location_row_out[61];
        6'b111110: H_row_max_last_location_reg <= PE_location_row_out[62];
        6'b111111: H_row_max_last_location_reg <= PE_location_row_out[63];
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

        6'b000000: H_max_out <= CMP_H_max_out[0] ;
        6'b000001: H_max_out <= CMP_H_max_out[1] ;
        6'b000010: H_max_out <= CMP_H_max_out[2] ;
        6'b000011: H_max_out <= CMP_H_max_out[3] ;
        6'b000100: H_max_out <= CMP_H_max_out[4] ;
        6'b000101: H_max_out <= CMP_H_max_out[5] ;
        6'b000110: H_max_out <= CMP_H_max_out[6] ;
        6'b000111: H_max_out <= CMP_H_max_out[7] ;
        6'b001000: H_max_out <= CMP_H_max_out[8] ;
        6'b001001: H_max_out <= CMP_H_max_out[9] ;
        6'b001010: H_max_out <= CMP_H_max_out[10];
        6'b001011: H_max_out <= CMP_H_max_out[11];
        6'b001100: H_max_out <= CMP_H_max_out[12];
        6'b001101: H_max_out <= CMP_H_max_out[13];
        6'b001110: H_max_out <= CMP_H_max_out[14];
        6'b001111: H_max_out <= CMP_H_max_out[15];
        6'b010000: H_max_out <= CMP_H_max_out[16];
        6'b010001: H_max_out <= CMP_H_max_out[17];
        6'b010010: H_max_out <= CMP_H_max_out[18];
        6'b010011: H_max_out <= CMP_H_max_out[19];
        6'b010100: H_max_out <= CMP_H_max_out[20];
        6'b010101: H_max_out <= CMP_H_max_out[21];
        6'b010110: H_max_out <= CMP_H_max_out[22];
        6'b010111: H_max_out <= CMP_H_max_out[23];
        6'b011000: H_max_out <= CMP_H_max_out[24];
        6'b011001: H_max_out <= CMP_H_max_out[25];
        6'b011010: H_max_out <= CMP_H_max_out[26];
        6'b011011: H_max_out <= CMP_H_max_out[27];
        6'b011100: H_max_out <= CMP_H_max_out[28];
        6'b011101: H_max_out <= CMP_H_max_out[29];
        6'b011110: H_max_out <= CMP_H_max_out[30];
        6'b011111: H_max_out <= CMP_H_max_out[31];
        6'b100000: H_max_out <= CMP_H_max_out[32];
        6'b100001: H_max_out <= CMP_H_max_out[33];
        6'b100010: H_max_out <= CMP_H_max_out[34];
        6'b100011: H_max_out <= CMP_H_max_out[35];
        6'b100100: H_max_out <= CMP_H_max_out[36];
        6'b100101: H_max_out <= CMP_H_max_out[37];
        6'b100110: H_max_out <= CMP_H_max_out[38];
        6'b100111: H_max_out <= CMP_H_max_out[39];
        6'b101000: H_max_out <= CMP_H_max_out[40];
        6'b101001: H_max_out <= CMP_H_max_out[41];
        6'b101010: H_max_out <= CMP_H_max_out[42];
        6'b101011: H_max_out <= CMP_H_max_out[43];
        6'b101100: H_max_out <= CMP_H_max_out[44];
        6'b101101: H_max_out <= CMP_H_max_out[45];
        6'b101110: H_max_out <= CMP_H_max_out[46];
        6'b101111: H_max_out <= CMP_H_max_out[47];
        6'b110000: H_max_out <= CMP_H_max_out[48];
        6'b110001: H_max_out <= CMP_H_max_out[49];
        6'b110010: H_max_out <= CMP_H_max_out[50];
        6'b110011: H_max_out <= CMP_H_max_out[51];
        6'b110100: H_max_out <= CMP_H_max_out[52];
        6'b110101: H_max_out <= CMP_H_max_out[53];
        6'b110110: H_max_out <= CMP_H_max_out[54];
        6'b110111: H_max_out <= CMP_H_max_out[55];
        6'b111000: H_max_out <= CMP_H_max_out[56];
        6'b111001: H_max_out <= CMP_H_max_out[57];
        6'b111010: H_max_out <= CMP_H_max_out[58];
        6'b111011: H_max_out <= CMP_H_max_out[59];
        6'b111100: H_max_out <= CMP_H_max_out[60];
        6'b111101: H_max_out <= CMP_H_max_out[61];
        6'b111110: H_max_out <= CMP_H_max_out[62];
        6'b111111: H_max_out <= CMP_H_max_out[63];
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
        
        6'b000000: H_max_location <= CMP_location_out[0] ;
        6'b000001: H_max_location <= CMP_location_out[1] ;
        6'b000010: H_max_location <= CMP_location_out[2] ;
        6'b000011: H_max_location <= CMP_location_out[3] ;
        6'b000100: H_max_location <= CMP_location_out[4] ;
        6'b000101: H_max_location <= CMP_location_out[5] ;
        6'b000110: H_max_location <= CMP_location_out[6] ;
        6'b000111: H_max_location <= CMP_location_out[7] ;
        6'b001000: H_max_location <= CMP_location_out[8] ;
        6'b001001: H_max_location <= CMP_location_out[9] ;
        6'b001010: H_max_location <= CMP_location_out[10];
        6'b001011: H_max_location <= CMP_location_out[11];
        6'b001100: H_max_location <= CMP_location_out[12];
        6'b001101: H_max_location <= CMP_location_out[13];
        6'b001110: H_max_location <= CMP_location_out[14];
        6'b001111: H_max_location <= CMP_location_out[15];
        6'b010000: H_max_location <= CMP_location_out[16];
        6'b010001: H_max_location <= CMP_location_out[17];
        6'b010010: H_max_location <= CMP_location_out[18];
        6'b010011: H_max_location <= CMP_location_out[19];
        6'b010100: H_max_location <= CMP_location_out[20];
        6'b010101: H_max_location <= CMP_location_out[21];
        6'b010110: H_max_location <= CMP_location_out[22];
        6'b010111: H_max_location <= CMP_location_out[23];
        6'b011000: H_max_location <= CMP_location_out[24];
        6'b011001: H_max_location <= CMP_location_out[25];
        6'b011010: H_max_location <= CMP_location_out[26];
        6'b011011: H_max_location <= CMP_location_out[27];
        6'b011100: H_max_location <= CMP_location_out[28];
        6'b011101: H_max_location <= CMP_location_out[29];
        6'b011110: H_max_location <= CMP_location_out[30];
        6'b011111: H_max_location <= CMP_location_out[31];
        6'b100000: H_max_location <= CMP_location_out[32];
        6'b100001: H_max_location <= CMP_location_out[33];
        6'b100010: H_max_location <= CMP_location_out[34];
        6'b100011: H_max_location <= CMP_location_out[35];
        6'b100100: H_max_location <= CMP_location_out[36];
        6'b100101: H_max_location <= CMP_location_out[37];
        6'b100110: H_max_location <= CMP_location_out[38];
        6'b100111: H_max_location <= CMP_location_out[39];
        6'b101000: H_max_location <= CMP_location_out[40];
        6'b101001: H_max_location <= CMP_location_out[41];
        6'b101010: H_max_location <= CMP_location_out[42];
        6'b101011: H_max_location <= CMP_location_out[43];
        6'b101100: H_max_location <= CMP_location_out[44];
        6'b101101: H_max_location <= CMP_location_out[45];
        6'b101110: H_max_location <= CMP_location_out[46];
        6'b101111: H_max_location <= CMP_location_out[47];
        6'b110000: H_max_location <= CMP_location_out[48];
        6'b110001: H_max_location <= CMP_location_out[49];
        6'b110010: H_max_location <= CMP_location_out[50];
        6'b110011: H_max_location <= CMP_location_out[51];
        6'b110100: H_max_location <= CMP_location_out[52];
        6'b110101: H_max_location <= CMP_location_out[53];
        6'b110110: H_max_location <= CMP_location_out[54];
        6'b110111: H_max_location <= CMP_location_out[55];
        6'b111000: H_max_location <= CMP_location_out[56];
        6'b111001: H_max_location <= CMP_location_out[57];
        6'b111010: H_max_location <= CMP_location_out[58];
        6'b111011: H_max_location <= CMP_location_out[59];
        6'b111100: H_max_location <= CMP_location_out[60];
        6'b111101: H_max_location <= CMP_location_out[61];
        6'b111110: H_max_location <= CMP_location_out[62];
        6'b111111: H_max_location <= CMP_location_out[63];

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
        
        6'b000000: diagonal_score <= PE_H_out_col[0] ;
        6'b000001: diagonal_score <= PE_H_out_col[1] ;
        6'b000010: diagonal_score <= PE_H_out_col[2] ;
        6'b000011: diagonal_score <= PE_H_out_col[3] ;
        6'b000100: diagonal_score <= PE_H_out_col[4] ;
        6'b000101: diagonal_score <= PE_H_out_col[5] ;
        6'b000110: diagonal_score <= PE_H_out_col[6] ;
        6'b000111: diagonal_score <= PE_H_out_col[7] ;
        6'b001000: diagonal_score <= PE_H_out_col[8] ;
        6'b001001: diagonal_score <= PE_H_out_col[9] ;
        6'b001010: diagonal_score <= PE_H_out_col[10];
        6'b001011: diagonal_score <= PE_H_out_col[11];
        6'b001100: diagonal_score <= PE_H_out_col[12];
        6'b001101: diagonal_score <= PE_H_out_col[13];
        6'b001110: diagonal_score <= PE_H_out_col[14];
        6'b001111: diagonal_score <= PE_H_out_col[15];

        6'b010000: diagonal_score <= PE_H_out_col[16];
        6'b010001: diagonal_score <= PE_H_out_col[17];
        6'b010010: diagonal_score <= PE_H_out_col[18];
        6'b010011: diagonal_score <= PE_H_out_col[19];
        6'b010100: diagonal_score <= PE_H_out_col[20];
        6'b010101: diagonal_score <= PE_H_out_col[21];
        6'b010110: diagonal_score <= PE_H_out_col[22];
        6'b010111: diagonal_score <= PE_H_out_col[23];
        6'b011000: diagonal_score <= PE_H_out_col[24];
        6'b011001: diagonal_score <= PE_H_out_col[25];
        6'b011010: diagonal_score <= PE_H_out_col[26];
        6'b011011: diagonal_score <= PE_H_out_col[27];
        6'b011100: diagonal_score <= PE_H_out_col[28];
        6'b011101: diagonal_score <= PE_H_out_col[29];
        6'b011110: diagonal_score <= PE_H_out_col[30];
        6'b011111: diagonal_score <= PE_H_out_col[31];

        6'b100000: diagonal_score <= PE_H_out_col[32];
        6'b100001: diagonal_score <= PE_H_out_col[33];
        6'b100010: diagonal_score <= PE_H_out_col[34];
        6'b100011: diagonal_score <= PE_H_out_col[35];
        6'b100100: diagonal_score <= PE_H_out_col[36];
        6'b100101: diagonal_score <= PE_H_out_col[37];
        6'b100110: diagonal_score <= PE_H_out_col[38];
        6'b100111: diagonal_score <= PE_H_out_col[39];
        6'b101000: diagonal_score <= PE_H_out_col[40];
        6'b101001: diagonal_score <= PE_H_out_col[41];
        6'b101010: diagonal_score <= PE_H_out_col[42];
        6'b101011: diagonal_score <= PE_H_out_col[43];
        6'b101100: diagonal_score <= PE_H_out_col[44];
        6'b101101: diagonal_score <= PE_H_out_col[45];
        6'b101110: diagonal_score <= PE_H_out_col[46];
        6'b101111: diagonal_score <= PE_H_out_col[47];
        
        6'b110000: diagonal_score <= PE_H_out_col[48];
        6'b110001: diagonal_score <= PE_H_out_col[49];
        6'b110010: diagonal_score <= PE_H_out_col[50];
        6'b110011: diagonal_score <= PE_H_out_col[51];
        6'b110100: diagonal_score <= PE_H_out_col[52];
        6'b110101: diagonal_score <= PE_H_out_col[53];
        6'b110110: diagonal_score <= PE_H_out_col[54];
        6'b110111: diagonal_score <= PE_H_out_col[55];
        6'b111000: diagonal_score <= PE_H_out_col[56];
        6'b111001: diagonal_score <= PE_H_out_col[57];
        6'b111010: diagonal_score <= PE_H_out_col[58];
        6'b111011: diagonal_score <= PE_H_out_col[59];
        6'b111100: diagonal_score <= PE_H_out_col[60];
        6'b111101: diagonal_score <= PE_H_out_col[61];
        6'b111110: diagonal_score <= PE_H_out_col[62];
        6'b111111: diagonal_score <= PE_H_out_col[63];
        endcase
    end
    else begin
        diagonal_score <= diagonal_score;
    end
end
endmodule
