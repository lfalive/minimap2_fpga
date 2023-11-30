`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2019 10:11:52 AM
// Design Name: 
// Module Name: CMP_F
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


module CMP_F #(
	parameter DATA_WIDTH = 16,
	parameter BT_WIDTH = 8

)
(
	//===============Input=============//
	clk,
	rst_n,
	F_ins,
	M_ins,
	//================Output===========//
	MAX,
	D
);

input wire clk;
input wire rst_n;

input wire signed [DATA_WIDTH-1 : 0] F_ins;
input wire signed [DATA_WIDTH-1 : 0] M_ins;

output reg signed [DATA_WIDTH-1 : 0] MAX;
output reg [BT_WIDTH-1 : 0] D;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		MAX <= 16'd0;
	end
	else if (F_ins > M_ins) begin
		MAX <= F_ins;
	end
	else begin
		MAX <= M_ins;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		D <= 8'hFF;
	end
	else if (F_ins > M_ins) begin
		D <= 8'b100000;
	end
	else begin
		D <= 8'd0;
	end
end
endmodule
