`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2019 11:24:01 AM
// Design Name: 
// Module Name: bt_d0
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


module BT_D0 #(
	parameter DATA_WIDTH = 16,
	parameter BT_WIDTH = 8
)
(
	//============Input============//
	clk,
	rst_n,
	M,
	E_F,
	flag, //flag =1 E >F
	//============Output==========//
	H_i_j,
	D
	);

input wire clk ;
input wire rst_n;

input wire signed [DATA_WIDTH-1 : 0] M;
input wire signed [DATA_WIDTH-1 : 0] E_F;
input wire flag;

output reg signed [DATA_WIDTH-1 : 0] H_i_j;
output reg [BT_WIDTH-1:0] D;

always @(posedge clk or posedge rst_n) begin
	if (~rst_n) begin
		D <= 8'hFF;
	end
	else if (M > E_F) begin
		D <= 8'd0;
	end
	else if (flag == 1 && E_F >= M) begin
		D <= 8'd1;
	end
	else if (flag == 0 && E_F >= M) begin
		D <= 8'd2;
	end
end

always @(posedge clk or posedge rst_n) begin
	if (~rst_n) begin
		H_i_j <= 8'hFF;
	end
	else if (M > E_F) begin
		H_i_j <= M;
	end
	else begin
		H_i_j <= E_F;
	end
end

endmodule
