`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2019 05:04:47 PM
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


module CMP_E #(
	parameter DATA_WIDTH = 16,
	parameter BT_WIDTH = 8

)
(
	//===============Input=============//
	clk,
	rst_n,
	E_del,
	M_del,
	//================Output===========//
	MAX,
	D
);

input wire clk;
input wire rst_n;

input wire signed [DATA_WIDTH-1 : 0] E_del;
input wire signed [DATA_WIDTH-1 : 0] M_del;

output reg signed [DATA_WIDTH-1 : 0] MAX;
output reg [BT_WIDTH-1 : 0] D;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		MAX <= 16'hFFFF;
	end
	else if (E_del > M_del) begin
		MAX <= E_del;
	end
	else begin
		MAX <= M_del;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		D <= 8'hFF;
	end
	else if (E_del > M_del) begin
		D <= 8'b100;
	end
	else begin
		D <= 8'd0;
	end
end
endmodule
