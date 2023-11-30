`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/10/2018 10:41:11 AM
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


module MUX2to4
(
    //==========input===============//
    clk     ,
    rst_n   ,
    code_in ,
    //==========output===============//
    en_out
    );

input wire clk;
input wire rst_n;

input wire [1:0] code_in;

output reg signed [3:0] en_out;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        en_out <= 'b0;
    end 
    else begin
        case (code_in)
        2'b00 : en_out <= 4'b0001;
        2'b01 : en_out <= 4'b0011;
        2'b10 : en_out <= 4'b0111;
        2'b11 : en_out <= 4'b1111;
        endcase
    end
end

endmodule
