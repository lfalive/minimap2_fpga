`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2019 10:24:14 AM
// Design Name: 
// Module Name: CMP
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


module CMP #(
	parameter DATA_WIDTH = 16

)
(
	//===============Input=============//
	clk,
	rst_n,
	num1,
	num2,
	//================Output===========//
	max
	);

input wire clk;
input wire rst_n;

input wire signed [DATA_WIDTH-1 : 0] num1;
input wire signed [DATA_WIDTH-1 : 0] num2;

output reg signed [DATA_WIDTH-1 : 0] max;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		max <= 16'd0;
	end
	else if (num1 > num2) begin
		max <= num1;
	end
	else begin
		max <= num2;
	end
end
endmodule
