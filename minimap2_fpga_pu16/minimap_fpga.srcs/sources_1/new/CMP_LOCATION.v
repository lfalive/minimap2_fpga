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


module CMP_LOCATION #(
    parameter integer CMP_WIDTH      = 16,
    parameter integer LOCATION_WIDTH = 24
)
(
    //==========input===============//
    clk        ,
    rst_n      ,
    location_in_0,
    value_0   ,
    location_in_1,
    value_1   ,
    //==========output===============//
    location_out,
    max
    );

input wire clk;
input wire rst_n;

input wire signed [CMP_WIDTH-1:0] value_0;
input wire signed [CMP_WIDTH-1:0] value_1;

input wire        [LOCATION_WIDTH-1:0] location_in_0;
input wire        [LOCATION_WIDTH-1:0] location_in_1;

output reg        [LOCATION_WIDTH-1:0] location_out;
output reg signed [CMP_WIDTH-1:0] max;


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        max <= 1'b0;
    end 
    else if (value_0 > value_1) begin
        max <= value_0;  
    end
    else begin
        max <= value_1;  
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

endmodule
