`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2019 10:44:28 AM
// Design Name: 
// Module Name: SEQ_CMP
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


module SEQ_CMP #(
    parameter integer CMP_WIDTH = 4,
    parameter integer SCORE_WIDTH = 16
)
(
    //==========input===============//
    clk   ,
    rst_n ,
    Nr    ,
    Ns    ,
    //==========output===============//
    S
    );

input wire clk   ;
input wire rst_n ;

input wire [CMP_WIDTH-1:0] Nr;
input wire [CMP_WIDTH-1:0] Ns;

output reg signed [SCORE_WIDTH-1:0] S;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        S <= 16'sh0000;  //0
    end
    else if (Nr > 3 || Ns > 3) begin
        S <= 16'shFFFF; //-1 N_Penalty
    end
    else if (Nr == Ns) begin
        S <= 16'sh0002;  //2 match
    end
    else begin
        S <= 16'shFFF8;  //-8 mismatch
    end
end

endmodule

