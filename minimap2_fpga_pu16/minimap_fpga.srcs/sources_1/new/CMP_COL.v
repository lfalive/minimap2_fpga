`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2019 11:58:42 AM
// Design Name: 
// Module Name: CMP_COL
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


module CMP_COL #(
    parameter integer CMP_WIDTH      = 16,
    parameter integer LOCATION_WIDTH = 32
)
(
    //==========input===============//
    clk        ,
    rst_n      ,
    en          ,
    clear       ,

    location_in_0,
    value_0   ,
    location_in_1,
    value_1   ,
    //==========output===============//
    location_out,
    en_out,
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

output wire        [LOCATION_WIDTH-1:0] location_out;
output wire signed [CMP_WIDTH-1:0] max;
output wire en_out;

reg        [LOCATION_WIDTH-1:0] location_out_temp;
reg signed [CMP_WIDTH-1:0] max_temp;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n || clear ) begin
        max_temp <= 16'sh8fff;
    end 
    else if (value_0 > value_1 ) begin
        max_temp <= value_0;
    end
    else begin
        max_temp <= value_1;  
    end
end


always @(posedge clk or negedge rst_n) begin
    if(~rst_n || clear) begin
        location_out_temp <= 1'b0;
    end 
    else if(value_0 > value_1) begin
        location_out_temp <= location_in_0;  
    end
    else begin
        location_out_temp <= location_in_1;
    end
end

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
assign en_out = en_out_6;

/*reg [LOCATION_WIDTH-1:0] location_out_reg_0;
reg [LOCATION_WIDTH-1:0] location_out_reg_1;
reg [LOCATION_WIDTH-1:0] location_out_reg_2;
reg [LOCATION_WIDTH-1:0] location_out_reg_3;
reg [LOCATION_WIDTH-1:0] location_out_reg_4;
reg [LOCATION_WIDTH-1:0] location_out_reg_5;

always @(posedge clk or negedge rst_n) begin
    if (! rst_n) begin
    	location_out_reg_0 <= 1'b0;
        location_out_reg_1 <= 1'b0;
        location_out_reg_2 <= 1'b0;
        location_out_reg_3 <= 1'b0;
        location_out_reg_4 <= 1'b0;
        location_out_reg_5 <= 1'b0;
    end
    else begin
    	location_out_reg_0 <= location_out_temp;
        location_out_reg_1 <= location_out_reg_0;
        location_out_reg_2 <= location_out_reg_1;
        location_out_reg_3 <= location_out_reg_2;
        location_out_reg_4 <= location_out_reg_3;
        location_out_reg_5 <= location_out_reg_4;
    end
 end

reg signed  [CMP_WIDTH-1:0] max_reg_0;
reg signed  [CMP_WIDTH-1:0] max_reg_1;
reg signed  [CMP_WIDTH-1:0] max_reg_2;
reg signed  [CMP_WIDTH-1:0] max_reg_3;
reg signed  [CMP_WIDTH-1:0] max_reg_4;
reg signed  [CMP_WIDTH-1:0] max_reg_5;

always @(posedge clk or negedge rst_n) begin
    if (! rst_n) begin
    	max_reg_0 <= 16'sh0000;
        max_reg_1 <= 16'sh0000;
        max_reg_2 <= 16'sh0000;
        max_reg_3 <= 16'sh0000;
        max_reg_4 <= 16'sh0000;
        max_reg_5 <= 16'sh0000;  
    end
    else begin
    	max_reg_0 <= max_temp;
        max_reg_1 <= max_reg_0;
        max_reg_2 <= max_reg_1;
        max_reg_3 <= max_reg_2;
        max_reg_4 <= max_reg_3;
        max_reg_5 <= max_reg_4;   
    end
end

assign max = max_reg_5;
assign location_out = location_out_reg_5;*/

assign max = max_temp;
assign location_out = location_out_temp;

endmodule
