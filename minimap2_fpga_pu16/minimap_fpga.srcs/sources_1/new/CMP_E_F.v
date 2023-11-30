`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2019 11:09:48 AM
// Design Name: 
// Module Name: CMP_E_F
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


module CMP_E_F #(
	parameter DATA_WIDTH = 16

)
(
	//===================Input=================//
	clk,
	rst_n,
	E,
	F,
	//===================Output===============//
	MAX,
	flag	//flag=1 stand for E>F
	);
input wire clk;
input wire rst_n;

input wire signed [DATA_WIDTH-1 : 0] E;
input wire signed [DATA_WIDTH-1 : 0] F;

output reg signed [DATA_WIDTH-1 : 0] MAX;
output reg flag;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		MAX <= 16'd0;
	end
	else if (E > F) begin
		MAX <= E;
	end
	else begin
		MAX <= F;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		flag <= 1'b0;
	end
	else if (E > F) begin
		flag <= 1'b1;
	end
	else begin
		flag <= 1'b0;
	end
end
endmodule
