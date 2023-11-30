`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2019 09:31:24 AM
// Design Name: 
// Module Name: CMP_LOCATION_INIT
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


module CMP_LOCATION_INIT #(

    parameter integer CMP_WIDTH      = 16,
    parameter integer LOCATION_WIDTH = 32
)
(
    //==========input===============//
    clk        ,
    rst_n      ,
    clear	   ,
    en         ,
    mode       ,
    location_in_0,
    value_0   ,
    location_in_1,
    value_1   , // link to the PE
    //==========output===============//
    location_out,
    max
    );

input wire clk;
input wire rst_n;

input wire en ;
input wire clear;
input wire mode ;

input wire signed [CMP_WIDTH-1:0] value_0;
input wire signed [CMP_WIDTH-1:0] value_1;

input wire        [LOCATION_WIDTH-1:0] location_in_0;
input wire        [LOCATION_WIDTH-1:0] location_in_1;

output reg        [LOCATION_WIDTH-1:0] location_out;
output reg signed [CMP_WIDTH-1:0] max;


always @(posedge clk or negedge rst_n) begin
    if(~rst_n || clear) begin
        max <= 16'sh8FFF;
    end 
    else if (en && !mode) begin
    	max <= value_1;
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
    else if (en && !mode) begin
    	location_out <= location_in_1;
    end
    else if ( en && value_0 > value_1) begin
        location_out <= location_in_0;  
    end
    else if (en && value_0 <= value_1) begin
        location_out <= location_in_1;
    end
    else begin
    	location_out <= location_out;
    end
end

endmodule

