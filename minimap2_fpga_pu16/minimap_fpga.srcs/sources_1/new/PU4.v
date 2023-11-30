`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2019 09:31:06 AM
// Design Name: 
// Module Name: PU4
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
module PU4 #(
	parameter integer DATA_WIDTH  = 4,
	parameter integer SCORE_WIDTH = 16,
	parameter integer LOCATION_WIDTH = 24
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

	Score_init    ,
    H1_init       ,
    H2_init      ,
    E1_init     ,
    E2_init     ,
    col_max_in,

	mode          , //低电平表示第一次，高电平表示轮询
	final_row_en  ,
	start_in      ,
	
	H_i_j_fifo    ,
	F_i_j_fifo   ,
	F2_i_j_fifo	  ,
	
	location_in_0 ,
	location_in_1 ,
	location_in_2 ,
	location_in_3 ,

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

    
    start_out               ,
    col_en                  ,
    H_max_out               ,
    H_max_location

    );

input wire sys_clk   ;
input wire sys_rst_n ;

input wire mode      ;
input wire start_in  ;

input wire [6:0] final_row_en;

input wire [DATA_WIDTH-1: 0] Ns;

input wire [DATA_WIDTH-1: 0] Nr_0;
input wire [DATA_WIDTH-1: 0] Nr_1;
input wire [DATA_WIDTH-1: 0] Nr_2;
input wire [DATA_WIDTH-1: 0] Nr_3;

input wire [LOCATION_WIDTH-1:0] location_in_0;
input wire [LOCATION_WIDTH-1:0] location_in_1;
input wire [LOCATION_WIDTH-1:0] location_in_2;
input wire [LOCATION_WIDTH-1:0] location_in_3;

input wire signed [SCORE_WIDTH-1:0] Score_init;
input wire signed [SCORE_WIDTH-1:0] H1_init;
input wire signed [SCORE_WIDTH-1:0] H2_init;
input wire signed [SCORE_WIDTH-1:0] E1_init;
input wire signed [SCORE_WIDTH-1:0] E2_init;
input wire signed [39:0] col_max_in;
//input wire signed [LOCATION_WIDTH-1:0] H_col_max_location_in;

input wire signed [SCORE_WIDTH-1:0] H_i_j_fifo;
input wire signed [SCORE_WIDTH-1:0] F_i_j_fifo;
input wire signed [SCORE_WIDTH-1:0] F2_i_j_fifo; //CJ

output wire start_out;

output wire signed [DATA_WIDTH-1:0] Ns_out;
output wire signed [SCORE_WIDTH-1:0] H_i_j_out;
output wire signed [SCORE_WIDTH-1:0] F_i_j_out;
output wire signed [SCORE_WIDTH-1:0] F2_i_j_out; //CJ
output wire signed [SCORE_WIDTH-1:0] Score_out;
output wire signed [39:0] col_max_out;

output wire signed [SCORE_WIDTH-1:0] E1_init_out;//CJ
output wire signed [SCORE_WIDTH-1:0] E2_init_out;//CJ
output wire signed [SCORE_WIDTH-1:0] H1_init_out;//CJ
output wire signed [SCORE_WIDTH-1:0] H2_init_out;//CJ
output wire col_en;

output reg signed [SCORE_WIDTH-1:0] H_max_out;
output reg signed [LOCATION_WIDTH-1:0] H_max_location;

output reg signed [39:0] H_col_max;
output reg signed [LOCATION_WIDTH-1:0] H_col_max_location;
output reg signed [SCORE_WIDTH-1 : 0] diagonal_score;

output reg signed  [SCORE_WIDTH-1:0] H_row_max_last;
output reg signed  [LOCATION_WIDTH-1:0] H_row_max_last_location;

wire [3:0] en_out;
//======================PE0================//


wire start_out_0;
wire signed [SCORE_WIDTH-1:0] H_out_0;
wire signed [SCORE_WIDTH-1:0] H_out_col_0;
wire signed [SCORE_WIDTH-1:0] F1_out_0;
wire signed [SCORE_WIDTH-1:0] F2_out_0;
wire signed [SCORE_WIDTH-1 : 0] H_row_max_0;
wire signed [SCORE_WIDTH-1 : 0] H_init_out_0;
wire        [DATA_WIDTH-1:0 ] Ns_out_0;

wire signed [LOCATION_WIDTH-1:0] location_row_out_0;

wire signed [SCORE_WIDTH-1:0] Score_in;

wire signed [SCORE_WIDTH-1 : 0] E1_init_out_0;
wire signed [SCORE_WIDTH-1 : 0] E2_init_out_0;
wire signed [SCORE_WIDTH-1 : 0] H1_init_out_0;
wire signed [SCORE_WIDTH-1 : 0] H2_init_out_0;
wire signed [SCORE_WIDTH-1 : 0] Score_out_0;

assign Score_in = ((start_in == 1'b1) && (mode ==1'b0)) ? Score_init : H_i_j_fifo ;

PE0 pe0(
    .sys_clk    (sys_clk             ),
    .sys_rst_n  (sys_rst_n           ),
    
    .Ns         (Ns                  ),
    .Nr         (Nr_0                ),
    .H_i_1_j_1  (H_i_j_fifo          ),
    .F1_i_j     (F_i_j_fifo         ),
    .F2_i_j		(F2_i_j_fifo		 ),

    .Score_init (Score_in            ),
    .H1_init     (H1_init         	 ),
    .H2_init    ( H2_init            ),
    .E1_init	(E1_init 			 ),
    .E2_init	(E2_init 			 ),
    
    .start_in   (start_in            ),
    .mode       (mode                ),
    .max_en     (en_out[0]           ),
    .location_in(location_in_0       ),  

    .Ns_out     (Ns_out_0            ),    
    .H_out      (H_out_0             ),
    .H_out_col  (H_out_col_0         ),
    .F1_out     (F1_out_0            ),
    .F2_out     (F2_out_0            ),
    
    .H_max_out  (H_row_max_0         ),
    .Score_out  (Score_out_0       ),
    .H1_init_out (H1_init_out_0      ),
    .H2_init_out (H2_init_out_0      ),
    .E1_init_out (E1_init_out_0      ),
    .E2_init_out (E2_init_out_0      ),
    
    
    .location_out(location_row_out_0 ),
    .start_out   (start_out_0        )
    );
//=====================END====================//

//======================PE1================//
wire        [DATA_WIDTH-1:0 ] Ns_out_1;
wire signed [SCORE_WIDTH-1:0] H_out_1;
wire signed [SCORE_WIDTH-1:0] H_out_col_1;
wire signed [SCORE_WIDTH-1:0] F1_out_1;
wire signed [SCORE_WIDTH-1:0] F2_out_1;

wire signed [SCORE_WIDTH-1 : 0] H_row_max_1;
wire signed [SCORE_WIDTH-1 : 0] E1_init_out_1;
wire signed [SCORE_WIDTH-1 : 0] E2_init_out_1;
wire signed [SCORE_WIDTH-1 : 0] H1_init_out_1;
wire signed [SCORE_WIDTH-1 : 0] H2_init_out_1;
wire signed [SCORE_WIDTH-1 : 0] Score_out_1;

wire signed [LOCATION_WIDTH-1:0] location_row_out_1;
wire start_out_1;

PEx pe1(
    .sys_clk    (sys_clk             ),
    .sys_rst_n  (sys_rst_n           ),
    
    .Ns         (Ns_out_0            ),
    .Nr         (Nr_1                ),
    .H_i_1_j_1  (H_out_0             ),
    .F1_i_j     (F1_out_0            ),
    .F2_i_j		(F2_out_0		     ),

    .Score_in   (Score_out_0        ),
    .H1_init    (H1_init_out_0       ),
    .H2_init    (H2_init_out_0       ),
    .E1_init	(E1_init_out_0	     ),
    .E2_init	(E2_init_out_0		 ),
    
    .start_in   (start_out_0         ),
    .max_en     (en_out[1]           ),
    .location_in(location_in_1       ),  

    .Ns_out     (Ns_out_1            ),    
    .H_out      (H_out_1             ),
    .H_out_col  (H_out_col_1         ),
    .F1_out     (F1_out_1            ),
    .F2_out     (F2_out_1            ),
    
    .H_max_out  (H_row_max_1         ),
    .Score_out  (Score_out_1       ),
    .H1_init_out (H1_init_out_1      ),
    .H2_init_out (H2_init_out_1      ),
    .E1_init_out(E1_init_out_1       ),
    .E2_init_out(E2_init_out_1       ),

    
    
    .location_out(location_row_out_1 ),
    .start_out  (start_out_1         )
    );
//=====================END====================//

//======================PE1================//
wire        [DATA_WIDTH-1:0 ] Ns_out_2;
wire signed [SCORE_WIDTH-1:0] H_out_2;
wire signed [SCORE_WIDTH-1:0] H_out_col_2;
wire signed [SCORE_WIDTH-1:0] F1_out_2;
wire signed [SCORE_WIDTH-1:0] F2_out_2;

wire signed [SCORE_WIDTH-1 : 0] H_row_max_2;
wire signed [SCORE_WIDTH-1 : 0] E1_init_out_2;
wire signed [SCORE_WIDTH-1 : 0] E2_init_out_2;
wire signed [SCORE_WIDTH-1 : 0] H1_init_out_2;
wire signed [SCORE_WIDTH-1 : 0] H2_init_out_2;
wire signed [SCORE_WIDTH-1 : 0] Score_out_2;

wire signed [LOCATION_WIDTH-1:0] location_row_out_2;
wire start_out_2;

PEx pe2(
    .sys_clk    (sys_clk             ),
    .sys_rst_n  (sys_rst_n           ),
    
    .Ns         (Ns_out_1            ),
    .Nr         (Nr_2                ),
    .H_i_1_j_1  (H_out_1             ),
    .F1_i_j     (F1_out_1            ),
    .F2_i_j		(F2_out_1		     ),

    .Score_in   (Score_out_1        ),
    .H1_init    (H1_init_out_1       ),
    .H2_init    (H2_init_out_1       ),
    .E1_init	(E1_init_out_1		 ),
    .E2_init	(E2_init_out_1		 ),
    
    .start_in   (start_out_1         ),
    .max_en     (en_out[2]           ),
    .location_in(location_in_2       ),  

    .Ns_out     (Ns_out_2            ),    
    .H_out      (H_out_2             ),
    .H_out_col  (H_out_col_2         ),
    .F1_out     (F1_out_2            ),
    .F2_out     (F2_out_2            ),
    
    .H_max_out  (H_row_max_2         ),
    .Score_out  (Score_out_2       ),
    .H1_init_out (H1_init_out_2      ),
    .H2_init_out (H2_init_out_2      ),
    .E1_init_out (E1_init_out_2      ),
    .E2_init_out (E2_init_out_2      ),
    
    
    .location_out(location_row_out_2 ),
    .start_out  (start_out_2         )
    );
//=====================END====================//

//======================PE1================//
wire        [DATA_WIDTH-1:0 ] Ns_out_3;
wire signed [SCORE_WIDTH-1:0]  H_out_3;
wire signed [SCORE_WIDTH-1:0] H_out_col_3;
wire signed [SCORE_WIDTH-1:0] F1_out_3;
wire signed [SCORE_WIDTH-1:0] F2_out_3;

wire signed [SCORE_WIDTH-1 : 0]   H_row_max_3;
wire signed [SCORE_WIDTH-1 : 0] E1_init_out_3;
wire signed [SCORE_WIDTH-1 : 0] E2_init_out_3;
wire signed [SCORE_WIDTH-1 : 0] H1_init_out_3;
wire signed [SCORE_WIDTH-1 : 0] H2_init_out_3;
wire signed [SCORE_WIDTH-1 : 0] Score_out_3;

wire signed [LOCATION_WIDTH-1:0] location_row_out_3;
wire start_out_3;

PEx pe3(
    .sys_clk    (sys_clk             ),
    .sys_rst_n  (sys_rst_n           ),
    
    .Ns         (Ns_out_2            ),
    .Nr         (Nr_3                ),
    .H_i_1_j_1  (H_out_2          ),
    .F1_i_j     (F1_out_2         ),
    .F2_i_j		(F2_out_2		  ),

    .Score_in   (Score_out_2        ),
    .H1_init    (H1_init_out_2       ),
    .H2_init    (H2_init_out_2       ),
    .E1_init	(E1_init_out_2			 ),
    .E2_init	(E2_init_out_2		 ),
    
    .start_in   (start_out_2            ),
    .max_en     (en_out[3]           ),
    .location_in(location_in_3       ),  

    .Ns_out     (Ns_out_3            ),    
    .H_out      (H_out_3             ),
    .H_out_col  (H_out_col_3         ),
    .F1_out     (F1_out_3             ),
    .F2_out     (F2_out_3             ),
    
    .H_max_out   (H_row_max_3         ),
    .Score_out  (Score_out_3       ),
    .H1_init_out (H1_init_out_3      ),
    .H2_init_out (H2_init_out_3      ),
    .E1_init_out (E1_init_out_3),
    .E2_init_out (E2_init_out_3),
    
    
    
    .location_out(location_row_out_3 ),
    .start_out  (start_out_3        )
    );

assign Ns_out = Ns_out_3;
assign start_out = start_out_3;
assign H_i_j_out = H_out_3;
assign F_i_j_out = F1_out_3;
assign F2_i_j_out = F2_out_3;
assign Score_out = Score_out_3;
assign H1_init_out = H1_init_out_3;
assign H2_init_out = H2_init_out_3;
assign E1_init_out = E1_init_out_3;
assign E2_init_out = E2_init_out_3;

//=======================END======================//


//====================SCORE_MAX===================//
wire       final_en        ;
reg        f0_final_en     ;
wire [1:0] final_row_num   ;
reg  [1:0] f0_final_row_num;


assign final_row_num = final_row_en[4:3];
assign final_en      = final_row_en[5]  ;

always @(posedge sys_clk )
begin
    f0_final_en      <= final_en     ;
    f0_final_row_num <= final_row_num;
end

MUX2to4 MUX2to4_INST (
    .clk    (sys_clk          ),
    .rst_n  (sys_rst_n        ),
    .code_in(final_row_en[2:0]),
    .en_out (en_out           )
);

//=====================END======================//

//###############CMP0###################
wire signed [SCORE_WIDTH-1:0] H_max_out_0;
wire        [LOCATION_WIDTH-1:0] location_out_0;

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
        location_row_out_0_reg_0 <= location_out_3;  
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
        H_row_max_0_reg_0 <= H_max_out_3;  
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

/*CMP_LOCATION MAX_cmp_0(
    .clk (sys_clk                           ),
    .rst_n (sys_rst_n                       ),
    .location_in_0(location_row_out_0_reg_5 ),
    .value_0 (H_row_max_0_reg_5             ),
    //.value_a (), //cj
    .location_in_1(location_row_out_0       ),
    .value_1 (H_row_max_0                   ),
    //.value_b (),
    .max(H_max_out_0                        ),
    .location_out (location_out_0           )
    ); */
reg max_en_6 ;
wire clear;
reg mode_reg_6;
CMP_LOCATION_INIT MAX_cmp_0(
    .clk (sys_clk                           ),
    .rst_n (sys_rst_n                       ),

    .clear( clear),
    .en(max_en_6),
    .mode(mode_reg_6),
    .location_in_0(location_row_out_0_reg_5 ),
    .value_0 (H_row_max_0_reg_5             ),

    .location_in_1(location_row_out_0       ),
    .value_1 (H_row_max_0                   ),
    .max(H_max_out_0                        ),
    .location_out (location_out_0           )
    ); 

//====================END===================//

//###############CMP1###################
wire signed [SCORE_WIDTH-1:0] H_max_out_1;
wire        [LOCATION_WIDTH-1:0] location_out_1;
wire H_en_out_1;

reg [LOCATION_WIDTH-1:0] location_out_0_reg_0;
reg [LOCATION_WIDTH-1:0] location_out_0_reg_1;
reg [LOCATION_WIDTH-1:0] location_out_0_reg_2;
reg [LOCATION_WIDTH-1:0] location_out_0_reg_3;
reg [LOCATION_WIDTH-1:0] location_out_0_reg_4;
reg [LOCATION_WIDTH-1:0] location_out_0_reg_5;

reg signed [SCORE_WIDTH-1:0] H_max_out_0_reg_0;
reg signed [SCORE_WIDTH-1:0] H_max_out_0_reg_1;
reg signed [SCORE_WIDTH-1:0] H_max_out_0_reg_2;
reg signed [SCORE_WIDTH-1:0] H_max_out_0_reg_3;
reg signed [SCORE_WIDTH-1:0] H_max_out_0_reg_4;
reg signed [SCORE_WIDTH-1:0] H_max_out_0_reg_5;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        location_out_0_reg_0 <= 1'b0;   
    end else if (start_in_reg_0 && !mode_reg_0) begin
        location_out_0_reg_0 <= 1'b0; 
    end else begin
        location_out_0_reg_0 <= location_out_0;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        location_out_0_reg_1 <= 1'b0;
        location_out_0_reg_2 <= 1'b0;
        location_out_0_reg_3 <= 1'b0;
        location_out_0_reg_4 <= 1'b0;
        location_out_0_reg_5 <= 1'b0;
    end
    else begin
        location_out_0_reg_1 <= location_out_0_reg_0;
        location_out_0_reg_2 <= location_out_0_reg_1;
        location_out_0_reg_3 <= location_out_0_reg_2;
        location_out_0_reg_4 <= location_out_0_reg_3;
        location_out_0_reg_5 <= location_out_0_reg_4;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n ) begin
        H_max_out_0_reg_0 <= 16'sh0000;   
    end else if (start_in_reg_0 && !mode_reg_0) begin 
        H_max_out_0_reg_0 <= 16'sh0000; 
    end else begin
        H_max_out_0_reg_0 <= H_max_out_0;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_max_out_0_reg_1 <= 16'sh0000;
        H_max_out_0_reg_2 <= 16'sh0000;
        H_max_out_0_reg_3 <= 16'sh0000;
        H_max_out_0_reg_4 <= 16'sh0000;
        H_max_out_0_reg_5 <= 16'sh0000;  
    end
    else begin
        H_max_out_0_reg_1 <= H_max_out_0_reg_0;
        H_max_out_0_reg_2 <= H_max_out_0_reg_1;
        H_max_out_0_reg_3 <= H_max_out_0_reg_2;
        H_max_out_0_reg_4 <= H_max_out_0_reg_3;
        H_max_out_0_reg_5 <= H_max_out_0_reg_4;   
    end
end
wire en_out_0;
CMP_LOCATION_CJ MAX_cmp_1(
	.clk (sys_clk                       ),
	.rst_n (sys_rst_n                   ),
    .en(en_out_0      ),
    .clear(clear),
	.location_in_0(location_out_0_reg_5 ),
	.value_0 (H_max_out_0_reg_5         ),
	.location_in_1(location_row_out_1   ),
	.value_1 (H_row_max_1               ),

	.max(H_max_out_1                    ),
	.location_out (location_out_1       )
    ); 

/*CMP_COL MAX_cmp_1(
    .clk (sys_clk                           ),
    .rst_n (sys_rst_n                       ),
    .clear (clear                     ),
    .location_in_0(location_out_0_reg_5 ),
    .value_0 (H_max_out_0_reg_5             ),
    .en(H_en_out_0                            ),
    .location_in_1(location_row_out_1       ),
    .value_1 (H_row_max_1                    ),
    .max(H_max_out_1                        ),
    .en_out(H_en_out_1),
    .location_out (location_out_1           )
    ); */
//=====================END==================//
//###############CMP2###################
wire signed [SCORE_WIDTH-1:0] H_max_out_2;
wire        [LOCATION_WIDTH-1:0] location_out_2;

reg [LOCATION_WIDTH-1:0] location_out_1_reg_0;
reg [LOCATION_WIDTH-1:0] location_out_1_reg_1;
reg [LOCATION_WIDTH-1:0] location_out_1_reg_2;
reg [LOCATION_WIDTH-1:0] location_out_1_reg_3;
reg [LOCATION_WIDTH-1:0] location_out_1_reg_4;
reg [LOCATION_WIDTH-1:0] location_out_1_reg_5;

reg signed [SCORE_WIDTH-1:0] H_max_out_1_reg_0;
reg signed [SCORE_WIDTH-1:0] H_max_out_1_reg_1;
reg signed [SCORE_WIDTH-1:0] H_max_out_1_reg_2;
reg signed [SCORE_WIDTH-1:0] H_max_out_1_reg_3;
reg signed [SCORE_WIDTH-1:0] H_max_out_1_reg_4;
reg signed [SCORE_WIDTH-1:0] H_max_out_1_reg_5;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        location_out_1_reg_0 <= 1'b0;   
    end else if (start_in_reg_0 && !mode_reg_0) begin
        location_out_1_reg_0 <= 1'b0;
    end else begin
        location_out_1_reg_0 <= location_out_1;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin       
        location_out_1_reg_1 <= 1'b0;
        location_out_1_reg_2 <= 1'b0;
        location_out_1_reg_3 <= 1'b0;
        location_out_1_reg_4 <= 1'b0;
        location_out_1_reg_5 <= 1'b0;
    end
    else begin
        location_out_1_reg_1 <= location_out_1_reg_0;
        location_out_1_reg_2 <= location_out_1_reg_1;
        location_out_1_reg_3 <= location_out_1_reg_2;
        location_out_1_reg_4 <= location_out_1_reg_3;
        location_out_1_reg_5 <= location_out_1_reg_4;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n ) begin
        H_max_out_1_reg_0 <= 16'sh0000;   
    end else if (start_in_reg_0 && !mode_reg_0) begin
        H_max_out_1_reg_0 <= 16'sh0000;
    end else begin
        H_max_out_1_reg_0 <= H_max_out_1;  
    end
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_max_out_1_reg_1 <= 16'sh0000;
        H_max_out_1_reg_2 <= 16'sh0000;
        H_max_out_1_reg_3 <= 16'sh0000;
        H_max_out_1_reg_4 <= 16'sh0000;
        H_max_out_1_reg_5 <= 16'sh0000;  
    end
    else begin
        H_max_out_1_reg_1 <= H_max_out_1_reg_0;
        H_max_out_1_reg_2 <= H_max_out_1_reg_1;
        H_max_out_1_reg_3 <= H_max_out_1_reg_2;
        H_max_out_1_reg_4 <= H_max_out_1_reg_3;
        H_max_out_1_reg_5 <= H_max_out_1_reg_4;   
    end
end
wire en_out_1;

CMP_LOCATION_CJ MAX_cmp_2(
    .clk (sys_clk                       ),
    .rst_n (sys_rst_n                   ),
    .en(en_out_1),
    .clear(clear),
    .location_in_0(location_out_1_reg_5 ),
    .value_0 (H_max_out_1_reg_5         ),
    .location_in_1(location_row_out_2   ),
    .value_1 (H_row_max_2               ),

    .max(H_max_out_2                    ),
    .location_out (location_out_2       )
    );
//=====================END==================//

//###############CMP3###################
wire signed [SCORE_WIDTH-1:0] H_max_out_3;
wire        [LOCATION_WIDTH-1:0] location_out_3;

reg [LOCATION_WIDTH-1:0] location_out_2_reg_0;
reg [LOCATION_WIDTH-1:0] location_out_2_reg_1;
reg [LOCATION_WIDTH-1:0] location_out_2_reg_2;
reg [LOCATION_WIDTH-1:0] location_out_2_reg_3;
reg [LOCATION_WIDTH-1:0] location_out_2_reg_4;
reg [LOCATION_WIDTH-1:0] location_out_2_reg_5;

reg signed [SCORE_WIDTH-1:0] H_max_out_2_reg_0;
reg signed [SCORE_WIDTH-1:0] H_max_out_2_reg_1;
reg signed [SCORE_WIDTH-1:0] H_max_out_2_reg_2;
reg signed [SCORE_WIDTH-1:0] H_max_out_2_reg_3;
reg signed [SCORE_WIDTH-1:0] H_max_out_2_reg_4;
reg signed [SCORE_WIDTH-1:0] H_max_out_2_reg_5;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n ) begin
        location_out_2_reg_0 <= 1'b0;   
    end else if (start_in_reg_0 && !mode_reg_0) begin 
        location_out_2_reg_0 <= 1'b0; 
    end else begin
        location_out_2_reg_0 <= location_out_2;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin 
        location_out_2_reg_1 <= 1'b0;
        location_out_2_reg_2 <= 1'b0;
        location_out_2_reg_3 <= 1'b0;
        location_out_2_reg_4 <= 1'b0;
        location_out_2_reg_5 <= 1'b0;
    end
    else begin
        location_out_2_reg_1 <= location_out_2_reg_0;
        location_out_2_reg_2 <= location_out_2_reg_1;
        location_out_2_reg_3 <= location_out_2_reg_2;
        location_out_2_reg_4 <= location_out_2_reg_3;
        location_out_2_reg_5 <= location_out_2_reg_4;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n ) begin
        H_max_out_2_reg_0 <= 16'sh0000;   
    end else if (start_in_reg_0 && !mode_reg_0) begin 
        H_max_out_2_reg_0 <= 16'sh0000; 
    end else begin
        H_max_out_2_reg_0 <= H_max_out_2;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_max_out_2_reg_1 <= 16'sh0000;
        H_max_out_2_reg_2 <= 16'sh0000;
        H_max_out_2_reg_3 <= 16'sh0000;
        H_max_out_2_reg_4 <= 16'sh0000;
        H_max_out_2_reg_5 <= 16'sh0000;  
    end
    else begin
        H_max_out_2_reg_1 <= H_max_out_2_reg_0;
        H_max_out_2_reg_2 <= H_max_out_2_reg_1;
        H_max_out_2_reg_3 <= H_max_out_2_reg_2;
        H_max_out_2_reg_4 <= H_max_out_2_reg_3;
        H_max_out_2_reg_5 <= H_max_out_2_reg_4;   
    end
end
wire en_out_2;
CMP_LOCATION_CJ MAX_cmp_3(
    .clk (sys_clk                       ),
    .rst_n (sys_rst_n                   ),
    .en(en_out_2),
    .clear(clear),
    .location_in_0(location_out_2_reg_5 ),
    .value_0 (H_max_out_2_reg_5         ),
    .location_in_1(location_row_out_3   ),
    .value_1 (H_row_max_3               ),
    .max(H_max_out_3                    ),
    .location_out (location_out_3       )
    );

//###############H_row_max_last###############
reg signed [SCORE_WIDTH-1:0] H_row_max_last_reg;
reg signed [SCORE_WIDTH-1:0] H_row_max_last_location_reg;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_row_max_last_reg <= 16'sh0000;   
    end
    else if (final_en) begin
        case (final_row_num)
        9'h000: H_row_max_last_reg <= H_row_max_0;
        9'h001: H_row_max_last_reg <= H_row_max_1;
        9'h002: H_row_max_last_reg <= H_row_max_2;
        9'h003: H_row_max_last_reg <= H_row_max_3;
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
        9'h000: H_row_max_last_location_reg <= location_row_out_0;
        9'h001: H_row_max_last_location_reg <= location_row_out_1;
        9'h002: H_row_max_last_location_reg <= location_row_out_2;
        9'h003: H_row_max_last_location_reg <= location_row_out_3;
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

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_max_out <= 16'sh0000;   
    end
    else if (f0_final_en) begin
        case (f0_final_row_num)
        9'h000: H_max_out <= H_max_out_0;
        9'h001: H_max_out <= H_max_out_1;
        9'h002: H_max_out <= H_max_out_2;
        9'h003: H_max_out <= H_max_out_3;
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
        9'h000: H_max_location <= location_out_0;
        9'h001: H_max_location <= location_out_1;
        9'h002: H_max_location <= location_out_2;
        9'h003: H_max_location <= location_out_3;
        endcase
    end
    else begin
        H_max_location <= H_max_location;
    end
end

//=========================H_Col_MAX==================//
wire H_col_max_en;
assign H_col_max_en = final_row_en[6];//高电平开始最后一个计算，延迟14个周期，得到结果
reg max_en_0 ;
reg max_en_1 ;
reg max_en_2 ;
reg max_en_3 ;
reg max_en_4 ;
reg max_en_5 ;
//reg max_en_6 ;

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
        location_col_out_0_reg_0 <= col_max_in[39:16];
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
//wire clear;
assign clear = start_in & (!mode);
reg mode_reg_0;
reg mode_reg_1;
reg mode_reg_2;
reg mode_reg_3;
reg mode_reg_4;
reg mode_reg_5;
//reg mode_reg_6;

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

CMP_COL_INIT col_cmp_0(
    .clk (sys_clk                           ),
    .rst_n (sys_rst_n                       ),
    .clear (clear                 ),
    .en (max_en_6),
    .mode(mode_reg_6                        ),
    .location_in_0(location_col_out_0_reg_5 ),
    .value_0 (H_col_max_0_reg_5             ),
    .location_in_1(location_row_out_0       ),
    .value_1 (H_out_col_0                   ),
    .max(H_col_cmp_out_0                        ),
    .en_out(en_out_0),
    .location_out (location_col_cmp_out_0           )
    ); 

//###############CMP1###################
wire signed [SCORE_WIDTH-1:0] H_col_cmp_out_1;
wire        [LOCATION_WIDTH-1:0] location_col_cmp_out_1;
//wire en_out_1;

reg [LOCATION_WIDTH-1:0] location_col_out_1_reg_0;
reg [LOCATION_WIDTH-1:0] location_col_out_1_reg_1;
reg [LOCATION_WIDTH-1:0] location_col_out_1_reg_2;
reg [LOCATION_WIDTH-1:0] location_col_out_1_reg_3;
reg [LOCATION_WIDTH-1:0] location_col_out_1_reg_4;
reg [LOCATION_WIDTH-1:0] location_col_out_1_reg_5;

reg signed  [SCORE_WIDTH-1:0] H_col_max_1_reg_0;
reg signed  [SCORE_WIDTH-1:0] H_col_max_1_reg_1;
reg signed  [SCORE_WIDTH-1:0] H_col_max_1_reg_2;
reg signed  [SCORE_WIDTH-1:0] H_col_max_1_reg_3;
reg signed  [SCORE_WIDTH-1:0] H_col_max_1_reg_4;
reg signed  [SCORE_WIDTH-1:0] H_col_max_1_reg_5;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        location_col_out_1_reg_0 <= 1'b0;   
    end else begin
        location_col_out_1_reg_0 <= location_col_cmp_out_0;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        location_col_out_1_reg_1 <= 1'b0;
        location_col_out_1_reg_2 <= 1'b0;
        location_col_out_1_reg_3 <= 1'b0;
        location_col_out_1_reg_4 <= 1'b0;
        location_col_out_1_reg_5 <= 1'b0;
    end else begin
        location_col_out_1_reg_1 <= location_col_out_1_reg_0;
        location_col_out_1_reg_2 <= location_col_out_1_reg_1;
        location_col_out_1_reg_3 <= location_col_out_1_reg_2;
        location_col_out_1_reg_4 <= location_col_out_1_reg_3;
        location_col_out_1_reg_5 <= location_col_out_1_reg_4;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        H_col_max_1_reg_0 <= 16'sh0000;   
    end else begin
        H_col_max_1_reg_0 <= H_col_cmp_out_0;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_col_max_1_reg_1 <= 16'sh0000;
        H_col_max_1_reg_2 <= 16'sh0000;
        H_col_max_1_reg_3 <= 16'sh0000;
        H_col_max_1_reg_4 <= 16'sh0000;
        H_col_max_1_reg_5 <= 16'sh0000;  
    end
    else begin
        H_col_max_1_reg_1 <= H_col_max_1_reg_0;
        H_col_max_1_reg_2 <= H_col_max_1_reg_1;
        H_col_max_1_reg_3 <= H_col_max_1_reg_2;
        H_col_max_1_reg_4 <= H_col_max_1_reg_3;
        H_col_max_1_reg_5 <= H_col_max_1_reg_4;   
    end
end

CMP_COL col_cmp_1(
    .clk (sys_clk                           ),
    .rst_n (sys_rst_n                       ),
    .clear (clear                     ),
    .location_in_0(location_col_out_1_reg_5 ),
    .value_0 (H_col_max_1_reg_5             ),
    .en(en_out_0                            ),
    .location_in_1(location_row_out_1       ),
    .value_1 (H_out_col_1                  ),
    .max(H_col_cmp_out_1                        ),
    .en_out(en_out_1),
    .location_out (location_col_cmp_out_1           )
    ); 

//###############CMP2###################
wire signed [SCORE_WIDTH-1:0] H_col_cmp_out_2;
wire        [LOCATION_WIDTH-1:0] location_col_cmp_out_2;
//wire en_out_2;

reg [LOCATION_WIDTH-1:0] location_col_out_2_reg_0;
reg [LOCATION_WIDTH-1:0] location_col_out_2_reg_1;
reg [LOCATION_WIDTH-1:0] location_col_out_2_reg_2;
reg [LOCATION_WIDTH-1:0] location_col_out_2_reg_3;
reg [LOCATION_WIDTH-1:0] location_col_out_2_reg_4;
reg [LOCATION_WIDTH-1:0] location_col_out_2_reg_5;

reg signed  [SCORE_WIDTH-1:0] H_col_max_2_reg_0;
reg signed  [SCORE_WIDTH-1:0] H_col_max_2_reg_1;
reg signed  [SCORE_WIDTH-1:0] H_col_max_2_reg_2;
reg signed  [SCORE_WIDTH-1:0] H_col_max_2_reg_3;
reg signed  [SCORE_WIDTH-1:0] H_col_max_2_reg_4;
reg signed  [SCORE_WIDTH-1:0] H_col_max_2_reg_5;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        location_col_out_2_reg_0 <= 1'b0;   
        location_col_out_2_reg_1 <= 1'b0;
        location_col_out_2_reg_2 <= 1'b0;
        location_col_out_2_reg_3 <= 1'b0;
        location_col_out_2_reg_4 <= 1'b0;
        location_col_out_2_reg_5 <= 1'b0;
    end else begin
        location_col_out_2_reg_0 <= location_col_cmp_out_1;
        location_col_out_2_reg_1 <= location_col_out_2_reg_0;
        location_col_out_2_reg_2 <= location_col_out_2_reg_1;
        location_col_out_2_reg_3 <= location_col_out_2_reg_2;
        location_col_out_2_reg_4 <= location_col_out_2_reg_3;
        location_col_out_2_reg_5 <= location_col_out_2_reg_4;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_col_max_2_reg_0 <= 16'sh0000; 
        H_col_max_2_reg_1 <= 16'sh0000;
        H_col_max_2_reg_2 <= 16'sh0000;
        H_col_max_2_reg_3 <= 16'sh0000;
        H_col_max_2_reg_4 <= 16'sh0000;
        H_col_max_2_reg_5 <= 16'sh0000;  
    end
    else begin
        H_col_max_2_reg_0 <= H_col_cmp_out_1; 
        H_col_max_2_reg_1 <= H_col_max_2_reg_0;
        H_col_max_2_reg_2 <= H_col_max_2_reg_1;
        H_col_max_2_reg_3 <= H_col_max_2_reg_2;
        H_col_max_2_reg_4 <= H_col_max_2_reg_3;
        H_col_max_2_reg_5 <= H_col_max_2_reg_4;   
    end
end

CMP_COL col_cmp_2(
    .clk (sys_clk                           ),
    .rst_n (sys_rst_n                       ),
    .clear (clear                     ),
    .en(en_out_1),
    .location_in_0(location_col_out_2_reg_5 ),
    .value_0 (H_col_max_2_reg_5             ),
    .location_in_1(location_row_out_2       ),
    .value_1 (H_out_col_2                  ),
    .max(H_col_cmp_out_2                        ),
    .en_out(en_out_2),
    .location_out (location_col_cmp_out_2           )
    ); 

//###############CMP3###################
wire signed [SCORE_WIDTH-1:0] H_col_cmp_out_3;
wire        [LOCATION_WIDTH-1:0] location_col_cmp_out_3;
//wire en_out_3;

reg [LOCATION_WIDTH-1:0] location_col_out_3_reg_0;
reg [LOCATION_WIDTH-1:0] location_col_out_3_reg_1;
reg [LOCATION_WIDTH-1:0] location_col_out_3_reg_2;
reg [LOCATION_WIDTH-1:0] location_col_out_3_reg_3;
reg [LOCATION_WIDTH-1:0] location_col_out_3_reg_4;
reg [LOCATION_WIDTH-1:0] location_col_out_3_reg_5;

reg signed  [SCORE_WIDTH-1:0] H_col_max_3_reg_0;
reg signed  [SCORE_WIDTH-1:0] H_col_max_3_reg_1;
reg signed  [SCORE_WIDTH-1:0] H_col_max_3_reg_2;
reg signed  [SCORE_WIDTH-1:0] H_col_max_3_reg_3;
reg signed  [SCORE_WIDTH-1:0] H_col_max_3_reg_4;
reg signed  [SCORE_WIDTH-1:0] H_col_max_3_reg_5;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        location_col_out_3_reg_0 <= 1'b0; 
        location_col_out_3_reg_1 <= 1'b0;
        location_col_out_3_reg_2 <= 1'b0;
        location_col_out_3_reg_3 <= 1'b0;
        location_col_out_3_reg_4 <= 1'b0;
        location_col_out_3_reg_5 <= 1'b0;
    end  else begin
        location_col_out_3_reg_0 <= location_col_cmp_out_2;  
        location_col_out_3_reg_1 <= location_col_out_3_reg_0;
        location_col_out_3_reg_2 <= location_col_out_3_reg_1;
        location_col_out_3_reg_3 <= location_col_out_3_reg_2;
        location_col_out_3_reg_4 <= location_col_out_3_reg_3;
        location_col_out_3_reg_5 <= location_col_out_3_reg_4;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_col_max_3_reg_0 <= 16'sh0000;   
        H_col_max_3_reg_1 <= 16'sh0000;
        H_col_max_3_reg_2 <= 16'sh0000;
        H_col_max_3_reg_3 <= 16'sh0000;
        H_col_max_3_reg_4 <= 16'sh0000;
        H_col_max_3_reg_5 <= 16'sh0000;  
    end
    else begin
        H_col_max_3_reg_0 <= H_col_cmp_out_2;  
        H_col_max_3_reg_1 <= H_col_max_3_reg_0;
        H_col_max_3_reg_2 <= H_col_max_3_reg_1;
        H_col_max_3_reg_3 <= H_col_max_3_reg_2;
        H_col_max_3_reg_4 <= H_col_max_3_reg_3;
        H_col_max_3_reg_5 <= H_col_max_3_reg_4;   
    end
end

CMP_COL col_cmp_3(
    .clk (sys_clk                           ),
    .rst_n (sys_rst_n                       ),
    .clear (clear                       ),
    .en(en_out_2),
    .location_in_0(location_col_out_3_reg_5 ),
    .value_0 (H_col_max_3_reg_5             ),
    
    .location_in_1(location_row_out_3       ),
    .value_1 (H_out_col_3                  ),
    .max(H_col_cmp_out_3                       ),
    .en_out(en_out_3),
    .location_out (location_col_cmp_out_3           )
    ); 

//###############H_col_max_last###############

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_col_max <= 16'sh0000;   
    end
    else if (f0_final_en) begin
        case (f0_final_row_num)
        9'h000: H_col_max <= H_col_cmp_out_0;
        9'h001: H_col_max <= H_col_cmp_out_1;
        9'h002: H_col_max <= H_col_cmp_out_2;
        9'h003: H_col_max <= H_col_cmp_out_3;
        endcase
    end
    else begin
        H_max_out <= H_max_out;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_col_max_location <= 1'b0;   
    end
    else if (f0_final_en) begin
        case (f0_final_row_num)
        9'h000: H_col_max_location <= location_col_cmp_out_0;
        9'h001: H_col_max_location <= location_col_cmp_out_1;
        9'h002: H_col_max_location <= location_col_cmp_out_2;
        9'h003: H_col_max_location <= location_col_cmp_out_3;
        endcase
    end
    else begin
        H_col_max_location <= H_col_max_location;
    end
end
assign col_max_out = {location_col_cmp_out_3, H_col_cmp_out_3};

reg en_out_2_reg_0;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        en_out_2_reg_0 <= 1'b0;        
    end
    else begin
        en_out_2_reg_0 <= en_out_2;
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
        9'h000: diagonal_score <= H_out_col_0;
        9'h001: diagonal_score <= H_out_col_1;
        9'h002: diagonal_score <= H_out_col_2;
        9'h003: diagonal_score <= H_out_col_3;
        endcase
    end
    else begin
        diagonal_score <= diagonal_score;
    end
end
endmodule
