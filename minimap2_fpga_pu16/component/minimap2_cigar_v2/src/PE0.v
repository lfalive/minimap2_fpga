`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2019 05:32:22 PM
// Design Name: 
// Module Name: PE0
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


module PE0 #(
	parameter DATA_WIDTH  = 4,
	parameter SCORE_WIDTH = 16,
	parameter BT_WIDTH = 8,
	parameter BT_OUT_WIDTH = 64,
	parameter PE_NUM = 8,
	parameter LOCATION_WIDTH = 32   
)
(
	//======================Input==================//
	sys_clk,
	sys_rst_n,

	Ns,  // ref sequence
	Nr,  // read sequence
	H_i_1_j_1,
	F1_i_j,
	F2_i_j,
	bt_in, // bit width = PE_NUM * BT_WIDTH

	Score_init, //为下一个PE的第一次运算进行H初始化,根据start_in计算一次
	H1_init, //可以自给自足，内部传,但是我们的PE0需要作为PEX，所以还是需要留接口
	H2_init,
	E1_init,
	E2_init,
	//F_init, //F可以自给自足，内部传

	start_in,
	mode,
	max_en,// max_en需要比start_in晚 6 clk
	location_in,

	//=====================Output================//
	Ns_out,
	H_out,
	F1_out,
	F2_out,
	H_max_out,
	H_out_col, //for col max
	bt_out, //bit width = PE_NUM * BT_WIDTH
	Score_out,
	H1_init_out,
	H2_init_out,
	E1_init_out,
	E2_init_out,
	location_out,
	
	start_out
	);
//将E1 E2init的值通过F1_out和F2_out传递
/*-------------------------------------------------------------------*\
                            Port Description
\*-------------------------------------------------------------------*/ 
input wire sys_clk;
input wire sys_rst_n;

input wire [DATA_WIDTH-1 : 0] Ns;
input wire [DATA_WIDTH-1 : 0] Nr;
input wire signed [SCORE_WIDTH-1 : 0] H_i_1_j_1;
input wire signed [SCORE_WIDTH-1 : 0] F1_i_j;
input wire signed [SCORE_WIDTH-1 : 0] F2_i_j;
input wire signed [SCORE_WIDTH-1 : 0] Score_init;
input wire signed [SCORE_WIDTH-1 : 0] H1_init;
input wire signed [SCORE_WIDTH-1 : 0] H2_init;
input wire signed [SCORE_WIDTH-1 : 0] E1_init;
input wire signed [SCORE_WIDTH-1 : 0] E2_init;

input wire signed [LOCATION_WIDTH-1:0] location_in;
input wire start_in;
input wire mode;
input wire max_en;
input wire [BT_OUT_WIDTH-1 : 0] bt_in;

output wire [DATA_WIDTH-1 : 0] Ns_out;
output wire signed [SCORE_WIDTH-1 : 0] H_out;
output wire signed [SCORE_WIDTH-1 : 0] F1_out;
output wire signed [SCORE_WIDTH-1 : 0] F2_out;
output wire signed [SCORE_WIDTH-1 : 0] H_max_out;
output wire signed [SCORE_WIDTH-1 : 0] H_out_col;

output wire signed [SCORE_WIDTH-1 : 0] E1_init_out;
output wire signed [SCORE_WIDTH-1 : 0] E2_init_out;
output wire signed [SCORE_WIDTH-1 : 0] H1_init_out;
output wire signed [SCORE_WIDTH-1 : 0] H2_init_out;
output wire signed [SCORE_WIDTH-1 : 0] Score_out;
output wire start_out;
output wire unsigned [BT_OUT_WIDTH-1 : 0] bt_out;
output wire signed [LOCATION_WIDTH-1:0] location_out;


/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/

wire [SCORE_WIDTH-1 : 0] S_i_j;
wire [SCORE_WIDTH-1 : 0] M_i_j;
//wire signed [SCORE_WIDTH-1 : 0] H_temp;
//reg signed [SCORE_WIDTH-1 : 0] H1_temp_reg_0;
wire signed [SCORE_WIDTH-1 : 0] max_E1_E2;
wire signed [SCORE_WIDTH-1 : 0] max_F1_F2;
wire signed [SCORE_WIDTH-1 : 0] max_E_F;
wire flag;

wire signed [SCORE_WIDTH-1 : 0] const_zero   ;
wire signed [SCORE_WIDTH-1 : 0] const_oe1_del ;
wire signed [SCORE_WIDTH-1 : 0] const_oe1_ins ;
wire signed [SCORE_WIDTH-1 : 0] const_e1_del  ;
wire signed [SCORE_WIDTH-1 : 0] const_e1_ins  ;
  
wire signed [SCORE_WIDTH-1 : 0] const_oe2_del ;
wire signed [SCORE_WIDTH-1 : 0] const_oe2_ins ;
wire signed [SCORE_WIDTH-1 : 0] const_e2_del  ;
wire signed [SCORE_WIDTH-1 : 0] const_e2_ins  ;

wire signed [SCORE_WIDTH-1 : 0] MINUS_INF  ;

reg signed [SCORE_WIDTH-1 : 0] max_E_F_reg_0;
reg flag_reg_0;

reg [DATA_WIDTH-1 : 0] Ns_reg_0;
reg [DATA_WIDTH-1 : 0] Ns_reg_1;
reg [DATA_WIDTH-1 : 0] Ns_reg_2;
reg [DATA_WIDTH-1 : 0] Ns_reg_3;
reg [DATA_WIDTH-1 : 0] Ns_reg_4;
reg [DATA_WIDTH-1 : 0] Ns_reg_5;
reg [DATA_WIDTH-1 : 0] Ns_reg_6;

reg signed [SCORE_WIDTH-1 : 0] H_out_reg_0;
reg signed [SCORE_WIDTH-1 : 0] H_out_reg_1;
reg signed [SCORE_WIDTH-1 : 0] H_out_reg_2;
reg signed [SCORE_WIDTH-1 : 0] H_out_reg_3;
reg signed [SCORE_WIDTH-1 : 0] H_out_reg_4;
reg signed [SCORE_WIDTH-1 : 0] H_out_reg_5;
reg signed [SCORE_WIDTH-1 : 0] H_out_reg_6;
reg signed [SCORE_WIDTH-1 : 0] H_out_reg_7;
reg signed [SCORE_WIDTH-1 : 0] H_out_reg_8;
reg signed [SCORE_WIDTH-1 : 0] H_out_reg_9;

reg signed [SCORE_WIDTH-1 : 0] E1_reg_0;
reg signed [SCORE_WIDTH-1 : 0] E1_reg_1;

reg signed [SCORE_WIDTH-1 : 0] E2_reg_0;
reg signed [SCORE_WIDTH-1 : 0] E2_reg_1;

reg signed [SCORE_WIDTH-1 : 0] F1_reg_0;
reg signed [SCORE_WIDTH-1 : 0] F1_reg_1;

reg signed [SCORE_WIDTH-1 : 0] F2_reg_0;
reg signed [SCORE_WIDTH-1 : 0] F2_reg_1;

reg start_out_0;
reg start_out_1;
reg start_out_2;
reg start_out_3;
reg start_out_4;
reg start_out_5;
reg start_out_6;

assign const_zero    = 16'sh0000;
assign const_oe1_del = 16'sh000E;
assign const_oe1_ins = 16'sh000E;
assign const_e1_del  = 16'sh0002;
assign const_e1_ins  = 16'sh0002;

assign const_oe2_del = 16'sh0019;
assign const_oe2_ins = 16'sh0019;
assign const_e2_del  = 16'sh0001;
assign const_e2_ins  = 16'sh0001;
//=====================KEY_signal======================//
reg signed [SCORE_WIDTH-1 : 0] E1_temp;
reg signed [SCORE_WIDTH-1 : 0] E2_temp;
reg signed [SCORE_WIDTH-1 : 0] F1_temp;
reg signed [SCORE_WIDTH-1 : 0] F2_temp;
wire en;

assign en = (mode == 1'b0) && (start_in == 1'b1);


/*-------------------------------------------------------------------*\
                          Output Description
\*-------------------------------------------------------------------*/

//====================H_init_out=======================//
//init_temp1和init_temp2主要是为循环一圈做准备
//wire signed [SCORE_WIDTH-1 : 0] const_oe1_ins ;
wire signed [SCORE_WIDTH-1 : 0] init_temp1  ;
wire signed [SCORE_WIDTH-1 : 0] init_temp2  ;

wire signed [SCORE_WIDTH-1 : 0] init_out_temp1  ;
wire signed [SCORE_WIDTH-1 : 0] init_out_temp2  ;
wire signed [SCORE_WIDTH-1 : 0] init_out 	    ;

reg signed [SCORE_WIDTH-1 : 0] init_out_reg_0;
reg signed [SCORE_WIDTH-1 : 0] init_out_reg_1;
reg signed [SCORE_WIDTH-1 : 0] init_out_reg_2;
reg signed [SCORE_WIDTH-1 : 0] H1_init_temp;
reg signed [SCORE_WIDTH-1 : 0] H2_init_temp;
reg en_reg;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		// reset
		en_reg <= 1'b0;
	end
	else begin
		en_reg <= en;
	end
end

assign init_temp1 = (en_reg == 1) ? const_oe1_ins : const_e1_ins;
assign init_temp2 = (en_reg == 1) ? const_oe2_ins : const_e2_ins;
//assign H_init_temp = (en == 1) ? score_init : H_init_out;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		H1_init_temp <= 16'd0;
	end
	else if (en == 1'b1) begin
		H1_init_temp <= Score_init;
	end
	else if (mode == 1'b0) begin
		H1_init_temp <= H1_init_out;
	end
	else if (start_in == 1'b1) begin
		H1_init_temp <= H1_init;
	end
	else begin
		H1_init_temp <= H1_init_temp;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		H2_init_temp <= 16'd0;
	end
	else if (en == 1'b1) begin
		H2_init_temp <= Score_init;
	end
	else if (mode == 1'b0) begin
		H2_init_temp <= H2_init_out;
	end
	else if (start_in == 1'b1) begin
		H2_init_temp <= H2_init;
	end
	else begin
		H2_init_temp <= H2_init_temp;
	end
end


SUB sub_H_init1(
	.CLK(sys_clk),
	.SCLR(~sys_rst_n),
	.A(H1_init_temp),
	.B(init_temp1),
	.S(init_out_temp1)
	);

SUB sub_H_init2(
	.CLK(sys_clk),
	.SCLR(~sys_rst_n),
	.A(H2_init_temp),
	.B(init_temp2),
	.S(init_out_temp2)
	);
CMP cmp_H_init(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.num1(init_out_temp1),
	.num2(init_out_temp2),
	.max(init_out)
	);
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		init_out_reg_0 <= 16'sh0000;
		init_out_reg_1 <= 16'sh0000;
		init_out_reg_2 <= 16'sh0000;
	end
	else begin
		init_out_reg_0 <= init_out;
		init_out_reg_1 <= init_out_reg_0;
		init_out_reg_2 <= init_out_reg_1;	
	end
end
assign Score_out = init_out_reg_2;


reg signed [SCORE_WIDTH-1 : 0] init_out_temp1_reg_0;
reg signed [SCORE_WIDTH-1 : 0] init_out_temp1_reg_1;
reg signed [SCORE_WIDTH-1 : 0] init_out_temp1_reg_2;
reg signed [SCORE_WIDTH-1 : 0] init_out_temp1_reg_3;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		init_out_temp1_reg_0 <= 16'sh0000;
		init_out_temp1_reg_1 <= 16'sh0000;
		init_out_temp1_reg_2 <= 16'sh0000;
		init_out_temp1_reg_3 <= 16'sh0000;
	end
	else begin
		init_out_temp1_reg_0 <= init_out_temp1;
		init_out_temp1_reg_1 <= init_out_temp1_reg_0;
		init_out_temp1_reg_2 <= init_out_temp1_reg_1;
		init_out_temp1_reg_3 <= init_out_temp1_reg_2;	
	end
end
assign H1_init_out = init_out_temp1_reg_3;

reg signed [SCORE_WIDTH-1 : 0] init_out_temp2_reg_0;
reg signed [SCORE_WIDTH-1 : 0] init_out_temp2_reg_1;
reg signed [SCORE_WIDTH-1 : 0] init_out_temp2_reg_2;
reg signed [SCORE_WIDTH-1 : 0] init_out_temp2_reg_3;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		init_out_temp2_reg_0 <= 16'sh0000;
		init_out_temp2_reg_1 <= 16'sh0000;
		init_out_temp2_reg_2 <= 16'sh0000;
		init_out_temp2_reg_3 <= 16'sh0000;
	end
	else begin
		init_out_temp2_reg_0 <= init_out_temp2;
		init_out_temp2_reg_1 <= init_out_temp2_reg_0;
		init_out_temp2_reg_2 <= init_out_temp2_reg_1;
		init_out_temp2_reg_3 <= init_out_temp2_reg_2;	
	end
end
assign H2_init_out = init_out_temp2_reg_3;

//======================END============================//

//=====================H_out===========================//
wire unsigned [BT_WIDTH-1 : 0] d0_temp;
wire unsigned [SCORE_WIDTH-1 : 0] H_out_temp;
reg  unsigned [SCORE_WIDTH-1 : 0] H_temp_reg_0;

SEQ_CMP seq_cmp(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.Nr(Nr),
	.Ns(Ns),
	.S(S_i_j));

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_temp_reg_0 <= 16'sh0000;    
    end
    else if (en == 1'b1) begin
        H_temp_reg_0 <= Score_init;
    end
    else if (mode == 1'b0) begin
    	H_temp_reg_0 <= Score_out;
    end
    else if (start_in == 1'b1) begin
		H_temp_reg_0 <= Score_init;
	end
    else begin
    	H_temp_reg_0 <= H_i_1_j_1;
    end
end

ADD Add_S_and_H(
    .CLK (sys_clk),
    .SCLR(~sys_rst_n),
    .A   (S_i_j),
    .B   (H_temp_reg_0),
    .S   (M_i_j)
    );

CMP cmp0(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.num1(E1_temp),
	.num2(E2_temp),
	.max(max_E1_E2)
	);

CMP cmp1(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.num1(F1_temp),
	.num2(F2_temp),
	.max(max_F1_F2)
	);
CMP_E_F cmp_e_f(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.E(max_E1_E2),
	.F(max_F1_F2),
	.MAX(max_E_F),
	.flag(flag)
	);
/*always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        max_E_F_reg_0 <= 16'sb0000;    
    end
    else begin
        max_E_F_reg_0 <= max_E_F;
    end
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        flag_reg_0 <= 1'b0;    
    end
    else begin
        flag_reg_0 <= flag;
    end
end*/

BT_D0 bt_d0(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.M(M_i_j),
	.E_F(max_E_F),
	.flag(flag),
	.H_i_j(H_out_temp),
	.D(d0_temp)
	);

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		H_out_reg_0 <= 16'sh0000;
		H_out_reg_1 <= 16'sh0000;
		H_out_reg_2 <= 16'sh0000;
		H_out_reg_3 <= 16'sh0000;
		H_out_reg_4 <= 16'sh0000;
		H_out_reg_5 <= 16'sh0000;
		H_out_reg_6 <= 16'sh0000;
		H_out_reg_7 <= 16'sh0000;
		H_out_reg_8 <= 16'sh0000;
		H_out_reg_9 <= 16'sh0000;
	end
	else begin
		H_out_reg_0 <= H_out_temp;
		H_out_reg_1 <= H_out_reg_0;
		H_out_reg_2 <= H_out_reg_1;
		H_out_reg_3 <= H_out_reg_2;
		H_out_reg_4 <= H_out_reg_3;
		H_out_reg_5 <= H_out_reg_4;
		H_out_reg_6 <= H_out_reg_5;
		H_out_reg_7 <= H_out_reg_6;
		H_out_reg_8 <= H_out_reg_7;
		H_out_reg_9 <= H_out_reg_8;
		
	end
end

assign H_out = H_out_reg_9;

//========================END===================//

//======================E_INIT=========================//
//E的初始化每个PE只进行一次，所以最好可以节省这个减法器
//根据H的之计算下一个PE的初始化值
assign MINUS_INF = 16'sh8fff;
//assign E_init = (en == 1'b1) ? MINUS_INF : E_init_in;
SUB sub_E1_init(
	.CLK(sys_clk),
	.SCLR(~sys_rst_n),
	.A(init_out_reg_0),
	.B(const_oe1_ins),
	.S(E1_init_out)
	);

SUB sub_E2_init(
	.CLK(sys_clk),
	.SCLR(~sys_rst_n),
	.A(init_out_reg_0),
	.B(const_oe2_ins),
	.S(E2_init_out)
	);
//======================END============================//

//=======================E1_OUT=================//
wire signed [SCORE_WIDTH-1 : 0] E1_out;
wire signed [SCORE_WIDTH-1 : 0] E1_out_temp;
wire signed [SCORE_WIDTH-1 : 0] m_minus_oe1;
wire signed [SCORE_WIDTH-1 : 0] E1_del;
wire unsigned [BT_WIDTH-1 : 0] d1_temp;
reg signed [SCORE_WIDTH-1 : 0] E1_out_reg;


always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		E1_temp <= 16'd0;
	end
	else if (en == 1'b1) begin
		E1_temp <= MINUS_INF;
	end
	else if (start_in == 1'b1) begin
		E1_temp <= E1_init;
	end
	else begin
		E1_temp <= E1_out;
	end
end

SUB sub_oe1(
	.CLK(sys_clk),
	.SCLR(!sys_rst_n),
	.A(M_i_j),
	.B(const_oe1_del),
	.S(m_minus_oe1)
	);

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		E1_reg_0 <= 16'sh0000;
		E1_reg_1 <= 16'sh0000;
	end
	else begin
		E1_reg_0 <= E1_temp;
		E1_reg_1 <= E1_reg_0;
	end
end

SUB sub_e1(
	.CLK(sys_clk),
	.SCLR(!sys_rst_n),
	.A(E1_reg_1),
	.B(const_e1_del),
	.S(E1_del)
	);

CMP_E cmp_e(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.E_del(E1_del),
	.M_del(m_minus_oe1),
	.MAX(E1_out_temp),
	.D(d1_temp)
	);
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		E1_out_reg <= 16'd0;
	end
	else begin
		E1_out_reg <= E1_out_temp;	
	end
end
assign E1_out = E1_out_reg;
//========================END===================//

//=======================E2_OUT=================//
wire signed [SCORE_WIDTH-1 : 0] E2_out;
wire signed [SCORE_WIDTH-1 : 0] E2_out_temp;
wire signed [SCORE_WIDTH-1 : 0] m_minus_oe2;
wire signed [SCORE_WIDTH-1 : 0] E2_del;
reg signed [SCORE_WIDTH-1 : 0] E2_out_reg;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		E2_temp <= 16'd0;
	end
	else if (en == 1'b1) begin
		E2_temp <= MINUS_INF;
	end
	else if (start_in == 1'b1) begin
		E2_temp <= E2_init;
	end
	else begin
		E2_temp <= E2_out;
	end
end

SUB sub_oe2(
	.CLK(sys_clk),
	.SCLR(!sys_rst_n),
	.A(M_i_j),
	.B(const_oe2_del),
	.S(m_minus_oe2)
	);

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		E2_reg_0 <= 16'sh0000;
		E2_reg_1 <= 16'sh0000;
	end
	else begin
		E2_reg_0 <= E2_temp;
		E2_reg_1 <= E2_reg_0;
	end
end

SUB sub_e2(
	.CLK(sys_clk),
	.SCLR(!sys_rst_n),
	.A(E2_reg_1),
	.B(const_e2_del),
	.S(E2_del)
	);

CMP cmp_e2(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.num1(E2_del),
	.num2(m_minus_oe2),
	.max(E2_out_temp)
	);

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		E2_out_reg <= 16'd0;
	end
	else begin
		E2_out_reg <= E2_out_temp;	
	end
end
assign E2_out = E2_out_reg;

//=====================END=================//

//======================F_INIT=========================//
wire signed [SCORE_WIDTH-1 : 0] F1_init;
wire signed [SCORE_WIDTH-1 : 0] F2_init;
wire signed [SCORE_WIDTH-1 : 0] F1_init_temp;
wire signed [SCORE_WIDTH-1 : 0] F2_init_temp;
wire signed [SCORE_WIDTH-1 : 0] F1_init_out;
wire signed [SCORE_WIDTH-1 : 0] F2_init_out;

reg signed [SCORE_WIDTH-1 : 0] F1_init_out_reg_0;
reg signed [SCORE_WIDTH-1 : 0] F1_init_out_reg_1;
reg signed [SCORE_WIDTH-1 : 0] F1_init_out_reg_2;
reg signed [SCORE_WIDTH-1 : 0] F1_init_out_reg_3;
reg signed [SCORE_WIDTH-1 : 0] F1_init_out_reg_4;
reg signed [SCORE_WIDTH-1 : 0] F1_init_out_reg_5;

reg signed [SCORE_WIDTH-1 : 0] F2_init_out_reg_0;
reg signed [SCORE_WIDTH-1 : 0] F2_init_out_reg_1;
reg signed [SCORE_WIDTH-1 : 0] F2_init_out_reg_2;
reg signed [SCORE_WIDTH-1 : 0] F2_init_out_reg_3;
reg signed [SCORE_WIDTH-1 : 0] F2_init_out_reg_4;


wire signed [SCORE_WIDTH-1 : 0] const_2oe1_ins;
wire signed [SCORE_WIDTH-1 : 0] const_2oe2_ins;

assign const_2oe1_ins = 16'sh001e; // (12+2)x2+2
assign const_2oe2_ins = 16'sh0033; // (24+1)x2+1
assign F1_init_temp = (en == 1) ? const_2oe1_ins : const_e1_ins;
assign F2_init_temp = (en == 1) ? const_2oe2_ins : const_e2_ins;
assign F1_init = (en == 1'b1) ? Score_init : F1_init_out_reg_4;
assign F2_init = (en == 1'b1) ? Score_init : F2_init_out_reg_4;
SUB sub_F1_init(
	.CLK(sys_clk),
	.SCLR(~sys_rst_n),
	.A(F1_init),
	.B(F1_init_temp),
	.S(F1_init_out)
	);
SUB sub_F2_init(
	.CLK(sys_clk),
	.SCLR(~sys_rst_n),
	.A(F2_init),
	.B(F2_init_temp),
	.S(F2_init_out)
	);

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		F1_init_out_reg_0 <= 16'sh0000;
		F1_init_out_reg_1 <= 16'sh0000;
		F1_init_out_reg_2 <= 16'sh0000;
		F1_init_out_reg_3 <= 16'sh0000;
		F1_init_out_reg_4 <= 16'sh0000;
		
	end
	else begin
		F1_init_out_reg_0 <= F1_init_out;
		F1_init_out_reg_1 <= F1_init_out_reg_0;
		F1_init_out_reg_2 <= F1_init_out_reg_1;
		F1_init_out_reg_3 <= F1_init_out_reg_2;
		F1_init_out_reg_4 <= F1_init_out_reg_3;
		
		
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		F2_init_out_reg_0 <= 16'sh0000;
		F2_init_out_reg_1 <= 16'sh0000;
		F2_init_out_reg_2 <= 16'sh0000;
		F2_init_out_reg_3 <= 16'sh0000;
		F2_init_out_reg_4 <= 16'sh0000;
		
	end
	else begin
		F2_init_out_reg_0 <= F2_init_out;
		F2_init_out_reg_1 <= F2_init_out_reg_0;
		F2_init_out_reg_2 <= F2_init_out_reg_1;
		F2_init_out_reg_3 <= F2_init_out_reg_2;
		F2_init_out_reg_4 <= F2_init_out_reg_3;
		
		
	end
end

//======================END============================//


//=======================F1_OUT=================//
wire signed [SCORE_WIDTH-1 : 0] F1_del;
wire signed [SCORE_WIDTH-1 : 0] F1_out_temp;
wire signed [BT_WIDTH-1 : 0] d2_temp;
reg  signed [SCORE_WIDTH-1 : 0] F1_out_reg;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		F1_temp <= 16'd0;
	end
	else if (en == 1'b1) begin
		F1_temp <= MINUS_INF;
	end
	else if (mode == 1'b0) begin
		F1_temp <= F1_init_out_reg_4;
	end
	else begin
		F1_temp <= F1_i_j;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		F1_reg_0 <= 16'sh0000;
		F1_reg_1 <= 16'sh0000;
	end
	else begin
		F1_reg_0 <= F1_temp;
		F1_reg_1 <= F1_reg_0;
	end
end

SUB sub_f1(
	.CLK(sys_clk),
	.SCLR(!sys_rst_n),
	.A(F1_reg_1),
	.B(const_e1_del),
	.S(F1_del)
	);

CMP_F cmp_f1(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.F_ins(F1_del),
	.M_ins(m_minus_oe1),
	.MAX(F1_out_temp),
	.D(d2_temp)
	);
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		F1_out_reg <= 16'd0;
	end
	else begin
		F1_out_reg <= F1_out_temp;		
	end
end
assign F1_out = F1_out_reg;

//========================END===================//

//=======================F2_OUT=================//
wire signed [SCORE_WIDTH-1 : 0] F2_del;
wire signed [SCORE_WIDTH-1 : 0] F2_out_temp;
reg  signed [SCORE_WIDTH-1 : 0] F2_out_reg;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		F2_temp <= 16'd0;
	end
	else if (en == 1'b1) begin
		F2_temp <= MINUS_INF;
	end
	else if (mode == 1'b0) begin
		F2_temp <= F2_init_out_reg_4;
	end
	else begin
		F2_temp <= F2_i_j;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		F2_reg_0 <= 16'sh0000;
		F2_reg_1 <= 16'sh0000;
	end
	else begin
		F2_reg_0 <= F2_temp;
		F2_reg_1 <= F2_reg_0;
	end
end

SUB sub_f2(
	.CLK(sys_clk),
	.SCLR(!sys_rst_n),
	.A(F2_reg_1),
	.B(const_e2_del),
	.S(F2_del)
	);

CMP cmp_f2(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.num1(F2_del),
	.num2(m_minus_oe2),
	.max(F2_out_temp)
	);

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		F2_out_reg <= 16'd0;
	end
	else begin
		F2_out_reg <= F2_out_temp;		
	end
end
assign F2_out = F2_out_reg;

//========================END===================//

//=======================Nr_out=================//

always @(posedge sys_clk or negedge  sys_rst_n) begin
	if (~sys_rst_n) begin
		Ns_reg_0 <= 4'b0000;
		Ns_reg_1 <= 4'b0000;
		Ns_reg_2 <= 4'b0000;
		Ns_reg_3 <= 4'b0000;
		Ns_reg_4 <= 4'b0000;
		Ns_reg_5 <= 4'b0000;
		Ns_reg_6 <= 4'b0000;
	end
	else begin
		Ns_reg_0 <= Ns;
		Ns_reg_1 <= Ns_reg_0;
		Ns_reg_2 <= Ns_reg_1;
		Ns_reg_3 <= Ns_reg_2;
		Ns_reg_4 <= Ns_reg_3;
		Ns_reg_5 <= Ns_reg_4;
		Ns_reg_6 <= Ns_reg_5;
	end
end
assign Ns_out = Ns_reg_6;
//======================END===================//

//=======================start_out=================//

always @(posedge sys_clk or negedge  sys_rst_n) begin
	if (~sys_rst_n) begin
		start_out_0 <= 1'b0;
		start_out_1 <= 1'b0;
		start_out_2 <= 1'b0;
		start_out_3 <= 1'b0;
		start_out_4 <= 1'b0;
		start_out_5 <= 1'b0;
		start_out_6 <= 1'b0;
	end
	else begin
		start_out_0 <= start_in;
		start_out_1 <= start_out_0;
		start_out_2 <= start_out_1;
		start_out_3 <= start_out_2;
		start_out_4 <= start_out_3;
		start_out_5 <= start_out_4;
		start_out_6 <= start_out_5;
	end
end

assign start_out = start_out_6 ;
//======================END===================//

//=====================BT_OUT================//
//6_clk, because it will delay for 1 cllk in the PU8 component
reg unsigned [BT_WIDTH-1 : 0] bt_out_temp;
reg unsigned [BT_WIDTH-1 : 0] d0_temp_reg_0;
reg unsigned [BT_WIDTH-1 : 0] d0_temp_reg_1;

always @(posedge sys_clk or negedge  sys_rst_n) begin
	if (~sys_rst_n) begin
		d0_temp_reg_0 <= 1'b0;
		d0_temp_reg_1 <= 1'b0;
	end
	else begin
		d0_temp_reg_0 <= d0_temp;
		d0_temp_reg_1 <= d0_temp_reg_0;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		bt_out_temp <= 8'd0;
	end
	else begin
		bt_out_temp <= (d0_temp_reg_1 | d1_temp | d2_temp);
	end
end

reg [BT_OUT_WIDTH-1 : 0] bt_in_reg_0;
reg [BT_OUT_WIDTH-1 : 0] bt_in_reg_1;
reg [BT_OUT_WIDTH-1 : 0] bt_in_reg_2;
reg [BT_OUT_WIDTH-1 : 0] bt_in_reg_3;
reg [BT_OUT_WIDTH-1 : 0] bt_in_reg_4;
reg [BT_OUT_WIDTH-1 : 0] bt_in_reg_5;
//reg [BT_OUT_WIDTH-1 : 0] bt_in_reg_6;

always @(posedge sys_clk or negedge  sys_rst_n) begin
	if (~sys_rst_n) begin
		bt_in_reg_0 <= 1'b0;
		bt_in_reg_1 <= 1'b0;
		bt_in_reg_2 <= 1'b0;
		bt_in_reg_3 <= 1'b0;
		bt_in_reg_4 <= 1'b0;
		bt_in_reg_5 <= 1'b0;
		//bt_in_reg_6 <= 1'b0;
	end
	else begin
		bt_in_reg_0 <= bt_in;
		bt_in_reg_1 <= bt_in_reg_0;
		bt_in_reg_2 <= bt_in_reg_1;
		bt_in_reg_3 <= bt_in_reg_2;
		bt_in_reg_4 <= bt_in_reg_3;
		bt_in_reg_5 <= bt_in_reg_4;
		//bt_in_reg_6 <= bt_in_reg_5;
	end
end

//assign bt_out = bt_in_reg_6<<8 | bt_out_temp ;
assign bt_out = bt_in_reg_5<<8 | d0_temp_reg_1 | d1_temp | d2_temp ;


//======================END===================//


//=====================H_MAX===================//
reg [LOCATION_WIDTH-1:0] location_in_reg_0;
reg [LOCATION_WIDTH-1:0] location_in_reg_1;
reg [LOCATION_WIDTH-1:0] location_in_reg_2;
reg [LOCATION_WIDTH-1:0] location_in_reg_3;
reg [LOCATION_WIDTH-1:0] location_in_reg_4;
reg [LOCATION_WIDTH-1:0] location_in_reg_5;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        location_in_reg_0 <= 1'b0; 
        location_in_reg_1 <= 1'b0;  
        location_in_reg_2 <= 1'b0;  
        location_in_reg_3 <= 1'b0;  
        location_in_reg_4 <= 1'b0;  
        location_in_reg_5 <= 1'b0;      
    end
    else begin
        location_in_reg_0 <= location_in;  
        location_in_reg_1 <= location_in_reg_0; 
        location_in_reg_2 <= location_in_reg_1; 
        location_in_reg_3 <= location_in_reg_2; 
        location_in_reg_4 <= location_in_reg_3; 
        location_in_reg_5 <= location_in_reg_4;  
    end
end

CMP_MAX MAX_cmp(
    .clk          (sys_clk           ),
    .rst_n        (sys_rst_n         ),
    .en           (max_en            ),
    .clear        (start_in          ),
    .location_in  (location_in_reg_5 ),
    .num          (H_out_reg_1       ),
    .location_out (location_out      ),
    .max          (H_max_out         )
    ); 
assign H_out_col = H_out_reg_2;
//=====================E N D=======================//

endmodule