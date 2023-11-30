`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2019 03:16:13 PM
// Design Name: 
// Module Name: CMP_LOCATION_CJ
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


module CMP_LOCATION_CJ #(

    parameter integer CMP_WIDTH      = 16,
    parameter integer LOCATION_WIDTH = 32
)
(
    //==========input===============//
    clk        ,
    rst_n      ,
    en 		   ,
    clear      ,
    location_in_0,
    value_0   ,
    location_in_1,
    value_1   ,
    //==========output===============//
    //en_out , 
    location_out,
    max
    );

input wire clk;
input wire rst_n;
input wire en ;
input wire clear;

input wire signed [CMP_WIDTH-1:0] value_0;
input wire signed [CMP_WIDTH-1:0] value_1;

input wire        [LOCATION_WIDTH-1:0] location_in_0;
input wire        [LOCATION_WIDTH-1:0] location_in_1;

output reg        [LOCATION_WIDTH-1:0] location_out;
output reg signed [CMP_WIDTH-1:0] max;
//output wire en_out;


always @(posedge clk or negedge rst_n) begin
    if(~rst_n || clear) begin
        max <= 16'sh8FFF;
    end 
    else if ( en && value_0 > value_1) begin
        max <= value_0;  
    end
    else if (en && value_0 <= value_1) begin
        max <= value_1;  
    end
    else begin
    	max <= max;
    end
end


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        location_out <= 1'b0;
    end 
    else if(value_0 > value_1) begin
        location_out <= location_in_0;  
    end
    else begin
        location_out <= location_in_1;
    end
end
/*
reg en_out_0;
reg en_out_1;
reg en_out_2;
reg en_out_3;
reg en_out_4;
reg en_out_5;
reg en_out_6;

always @(posedge clk or negedge rst_n) begin
    if (! rst_n) begin
        en_out_0 <= 1'b0;
        en_out_1 <= 1'b0;
        en_out_2 <= 1'b0;
        en_out_3 <= 1'b0;
        en_out_4 <= 1'b0;
        en_out_5 <= 1'b0;
        en_out_6 <= 1'b0;
    end else begin
        en_out_0 <= en;
        en_out_1 <= en_out_0;
        en_out_2 <= en_out_1;
        en_out_3 <= en_out_2;
        en_out_4 <= en_out_3;
        en_out_5 <= en_out_4;
        en_out_6 <= en_out_5;
    end
end
assign en_out = en_out_6;*/

endmodule

