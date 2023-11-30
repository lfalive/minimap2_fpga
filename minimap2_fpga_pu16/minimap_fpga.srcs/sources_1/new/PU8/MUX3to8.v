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


module MUX3to8
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

input wire [2:0] code_in;

output reg [7:0] en_out;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        en_out <= 8'b0;
    end 
    else begin
        case (code_in)
        3'b000 : en_out <= 8'b00000001;
        3'b001 : en_out <= 8'b00000011;
        3'b010 : en_out <= 8'b00000111;
        3'b011 : en_out <= 8'b00001111;
        3'b100 : en_out <= 8'b00011111;
        3'b101 : en_out <= 8'b00111111;
        3'b110 : en_out <= 8'b01111111;
        3'b111 : en_out <= 8'b11111111;
        endcase
    end
end

endmodule
