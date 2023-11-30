`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2019 02:50:15 PM
// Design Name: 
// Module Name: PU4_sim
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


module PU4_sim();
parameter integer SCORE_WIDTH = 16;
parameter integer LOCATION_WIDTH = 32;

//==============sys_clk && reset=============//
reg sys_rst_n;
reg sys_clk;
initial begin
	sys_clk = 1'b0;
	sys_rst_n = 1'b0;
	#25 
	sys_rst_n = 1'b1;
end

always begin
	#5 sys_clk = ~sys_clk;
end

//=================T_clk====================//
reg [2:0] T_clk;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		T_clk <= 3'd0;
	end
	else if (T_clk == 3'd6) begin
		T_clk <= 3'd0;
	end
	else begin
		T_clk <= T_clk  + 1'b1;
	end
end

//================Ns && Nr =================//
wire [3 : 0] Nr_length;
wire [3 : 0] Ns_length;
assign Ns_length = 4'd6;
assign Nr_length = 4'd3;
reg [3:0] Ns_count;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		Ns_count <= 3'd0;
	end
	else if (T_clk == 3'd5 && Ns_count < Ns_length) begin
		Ns_count <= Ns_count + 1'b1;
	end
	else begin
		Ns_count <= Ns_count;
	end
end

reg [3 : 0] Ns;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		Ns <= 4'd0;
	end
	else if (Ns_count == 4'd1) begin
		Ns <= 4'd3;
	end
	else if (Ns_count == 4'd2) begin
		Ns <= 4'd1;
	end
	else if (Ns_count == 4'd3) begin
		Ns <= 4'd2;
	end
	else if (Ns_count == 4'd4) begin
		Ns <= 4'd1;
	end
	else if (Ns_count == 4'd5) begin
		Ns <= 4'd3;
	end
	else if (Ns_count == 4'd6) begin
		Ns <= 4'd3;
	end
	else begin
		Ns <= Ns;
	end
end

reg [3:0] Nr_0;
reg [3:0] Nr_1;
reg [3:0] Nr_2;
reg [3:0] Nr_3;
initial begin
	Nr_0 <= 4'd3;
	Nr_1 <= 4'd1;
	Nr_2 <= 4'd2;
	Nr_3 <= 4'd1;
end

//================location_in =================//
reg [LOCATION_WIDTH-1 : 0] location_in_0;
reg [LOCATION_WIDTH-1 : 0] location_in_1;
reg [LOCATION_WIDTH-1 : 0] location_in_2;
reg [LOCATION_WIDTH-1 : 0] location_in_3;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n || start_in) begin
		location_in_0 <= 1'b0;
	end
	else if (T_clk == 3'd6 && Ns_count < Ns_length) begin
		location_in_0 <= location_in_0 + 1'b1;
	end
	else begin
		location_in_0 <= location_in_0;
	end
end
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n || start_in) begin
		location_in_1 <= 1'b0;
	end
	else if (T_clk == 3'd6 && Ns_count < Ns_length) begin
		location_in_1 <= location_in_1 + 1'b1;
	end
	else begin
		location_in_1 <= location_in_1;
	end
end
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n || start_in) begin
		location_in_2 <= 1'b0;
	end
	else if (T_clk == 3'd6 && Ns_count < Ns_length) begin
		location_in_2 <= location_in_2 + 1'b1;
	end
	else begin
		location_in_2 <= location_in_2;
	end
end
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n || start_in) begin
		location_in_3 <= 1'b0;
	end
	else if (T_clk == 3'd6 && Ns_count < Ns_length) begin
		location_in_3 <= location_in_3 + 1'b1;
	end
	else begin
		location_in_3 <= location_in_3;
	end
end

//====================start=====================//
reg start_in;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n) begin
		start_in <= 1'b0;
	end
	else if (T_clk == 3'd6 && Ns_count == 1) begin
		start_in <= 1'b1;
	end
	else begin
		start_in <= 1'b0;
	end
end

//======================PU4==================//
wire signed [3:0] Ns_out;
wire signed [SCORE_WIDTH-1:0] H_i_j_out;
wire signed [SCORE_WIDTH-1:0] F1_i_j_out;
wire signed [SCORE_WIDTH-1:0] F2_i_j_out;

wire signed [SCORE_WIDTH-1:0] H_init_out;
wire signed [SCORE_WIDTH-1:0] E1_init_out;
wire signed [SCORE_WIDTH-1:0] E2_init_out;

wire start_out;
wire signed [SCORE_WIDTH-1:0] H_max_out;
wire signed [LOCATION_WIDTH-1:0] H_max_location;

wire signed  [SCORE_WIDTH-1:0] H_row_max_last;
wire signed  [LOCATION_WIDTH-1:0] H_row_max_last_location;
PU4 pu4(
//==========input===============//
	.sys_clk     (sys_clk)  ,
	.sys_rst_n   (sys_rst_n)  ,
	
	.Ns           (Ns) ,

	.Nr_0         (Nr_0) ,
	.Nr_1         (Nr_1),
	.Nr_2         (Nr_2) ,
	.Nr_3         (Nr_3) ,
	
	.Score_init  (16'd0),
    .H_init      (16'd0),
    .E1_init     (16'd0),
    .E2_init     (16'd0),

	.mode        (1'b1)  ,
	.final_row_en (0) ,
	.start_in    (start_in) ,
	
	.H_i_j_fifo   (16'd0) ,
	.F1_i_j_fifo  (16'd0) ,
	.F2_i_j_fifo	 (16'd0) ,
	
	.location_in_0 (location_in_0),
	.location_in_1 (location_in_1),
	.location_in_2 (location_in_2),
	.location_in_3 (location_in_3),

//==========output===============//
    .Ns_out    (Ns_out)              ,
    .H_i_j_out (H_i_j_out)              ,
    .F1_i_j_out(F1_i_j_out)             ,
    .F2_i_j_out(F2_i_j_out)			,
    .H_init_out(H_init_out)              ,
    .E1_init_out(E1_init_out)             ,
    .E2_init_out(E2_init_out)             ,
    
    .H_row_max_last(H_row_max_last)          ,
    .H_row_max_last_location(H_row_max_last_location) ,
    
    .start_out(start_out)               ,
    .H_max_out(H_max_out)               ,
    .H_max_location(H_max_location)
    );
endmodule
