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


module CMP_MAX #(
    parameter integer CMP_WIDTH = 16,
    parameter integer LOCATION_WIDTH = 32
)
(
    //==========input===============//
    clk         ,
    rst_n       ,

    en          ,
    clear       ,

    location_in ,
    num         ,
    //==========output===============//
    location_out ,
    max
    );

input wire clk   ;
input wire rst_n ;
input wire en    ;
input wire clear ;

input wire signed [CMP_WIDTH-1:0] num;
input wire        [LOCATION_WIDTH-1:0] location_in;

output reg        [LOCATION_WIDTH-1:0] location_out;
output reg signed [CMP_WIDTH-1:0] max;

reg signed [CMP_WIDTH-1:0] max_0;
reg signed [CMP_WIDTH-1:0] max_1;
reg signed [CMP_WIDTH-1:0] max_2;
reg signed [CMP_WIDTH-1:0] max_3;
reg signed [CMP_WIDTH-1:0] max_4;
reg signed [CMP_WIDTH-1:0] max_5;

reg signed [LOCATION_WIDTH-1:0] location_out_reg_0;
reg signed [LOCATION_WIDTH-1:0] location_out_reg_1;
reg signed [LOCATION_WIDTH-1:0] location_out_reg_2;
reg signed [LOCATION_WIDTH-1:0] location_out_reg_3;
reg signed [LOCATION_WIDTH-1:0] location_out_reg_4;
reg signed [LOCATION_WIDTH-1:0] location_out_reg_5;

reg f0_clear;
reg f1_clear;
reg f2_clear;
reg f3_clear;
reg f4_clear;
reg f5_clear;

always @(posedge clk )
begin 
    f0_clear <= clear   ;
    f1_clear <= f0_clear;
    f2_clear <= f1_clear;
    f3_clear <= f2_clear;
    f4_clear <= f3_clear;
    f5_clear <= f4_clear;
end

reg f0_en;
reg f1_en;
reg f2_en;
reg f3_en;
reg f4_en;

always @(posedge clk )
begin 
    f0_en <= en   ;
    f1_en <= f0_en;
    f2_en <= f1_en;
    f3_en <= f2_en;
    f4_en <= f3_en;
   // f5_en <= f4_en;
end


always @(posedge clk or negedge rst_n) begin
    if((~rst_n) || (clear)) begin
        max_0 <= 1'b0;
    end 
    else begin
        max_0 <= max;  
    end
end

always @(posedge clk or negedge rst_n) begin
    if((~rst_n) ) begin
        max_1 <= 1'b0;
    end 
    else begin
        max_1 <= max_0;  
    end
end

always @(posedge clk or negedge rst_n) begin
    if((~rst_n) ) begin
        max_2 <= 1'b0;
    end 
    else begin
        max_2 <= max_1;  
    end
end

always @(posedge clk or negedge rst_n) begin
    if((~rst_n) ) begin
        max_3 <= 1'b0;
    end 
    else begin
        max_3 <= max_2;  
    end
end

always @(posedge clk or negedge rst_n) begin
    if((~rst_n)) begin
        max_4 <= 1'b0;
    end 
    else begin
        max_4 <= max_3;  
    end
end

always @(posedge clk or negedge rst_n) begin
    if((~rst_n) ) begin
        max_5 <= 1'b0;
    end 
    else begin
        max_5 <= max_4;  
    end
end

//-------------------

always @(posedge clk or negedge rst_n) begin
    if((~rst_n) || (clear)) begin
        location_out_reg_0 <= 1'b0;
    end 
    else begin
        location_out_reg_0 <= location_out;  
    end
end

always @(posedge clk or negedge rst_n) begin
    if((~rst_n) ) begin
        location_out_reg_1 <= 1'b0;
    end 
    else begin
        location_out_reg_1 <= location_out_reg_0;  
    end
end

always @(posedge clk or negedge rst_n) begin
    if((~rst_n)) begin
        location_out_reg_2 <= 1'b0;
    end 
    else begin
        location_out_reg_2 <= location_out_reg_1;  
    end
end

always @(posedge clk or negedge rst_n) begin
    if((~rst_n) ) begin
        location_out_reg_3 <= 1'b0;
    end 
    else begin
        location_out_reg_3 <= location_out_reg_2;  
    end
end

always @(posedge clk or negedge rst_n) begin
    if((~rst_n) ) begin
        location_out_reg_4 <= 1'b0;
    end 
    else begin
        location_out_reg_4 <= location_out_reg_3;  
    end
end

always @(posedge clk or negedge rst_n) begin
    if((~rst_n) ) begin
        location_out_reg_5 <= 1'b0;
    end 
    else begin
        location_out_reg_5 <= location_out_reg_4;  
    end
end

always @(posedge clk ) 
begin    
    if((num > max_5) && f4_en ) begin
        location_out <= location_in;  
    end else if (f4_en && f5_clear) begin 
        location_out <= location_in;
    end else if (f4_en) begin 
        location_out <= location_out_reg_5;
    end  else begin 
        location_out <= 0;
    end
end
always @(posedge clk ) 
begin   
    if (f4_en && f5_clear) begin 
        max <= num;
    end else if((num > max_5) && (f4_en == 1'b1)) begin
        max <= num;  
    end else if (f4_en) begin
        max <= max_5;
    end else begin 
        max <= 16'sh8fff;
    end 
end

endmodule
