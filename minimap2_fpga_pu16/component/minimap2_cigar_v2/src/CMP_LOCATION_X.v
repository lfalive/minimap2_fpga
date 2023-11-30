module CMP_LOCATION_X #(
	parameter integer CMP_WIDTH =16,
	parameter integer LOCATION_WIDTH = 32
)
(

//===============input===========//
	sys_clk,
	sys_rst_n,
	
	en,
	clear,
	start_in,
	mode_in,
	location_in_0,
	value_0,
	location_in_1,
	value_1,
//===============output==========//	
	max,
	location_out
);
input wire sys_clk;
input wire sys_rst_n;
input wire en;
input wire clear;
input wire start_in;
input wire mode_in;
input wire signed [CMP_WIDTH-1:0] value_0;
input wire signed [CMP_WIDTH-1:0] value_1;

input wire        [LOCATION_WIDTH-1:0] location_in_0;
input wire        [LOCATION_WIDTH-1:0] location_in_1;

output wire        [LOCATION_WIDTH-1:0] location_out;
output wire signed [CMP_WIDTH-1:0] max;

reg [LOCATION_WIDTH-1:0] location_in_0_reg_0;
reg [LOCATION_WIDTH-1:0] location_in_0_reg_1;
reg [LOCATION_WIDTH-1:0] location_in_0_reg_2;
reg [LOCATION_WIDTH-1:0] location_in_0_reg_3;
reg [LOCATION_WIDTH-1:0] location_in_0_reg_4;
reg [LOCATION_WIDTH-1:0] location_in_0_reg_5;

reg signed [CMP_WIDTH-1:0] H_max_out_0_reg_0;
reg signed [CMP_WIDTH-1:0] H_max_out_0_reg_1;
reg signed [CMP_WIDTH-1:0] H_max_out_0_reg_2;
reg signed [CMP_WIDTH-1:0] H_max_out_0_reg_3;
reg signed [CMP_WIDTH-1:0] H_max_out_0_reg_4;
reg signed [CMP_WIDTH-1:0] H_max_out_0_reg_5;


always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n ) begin
        H_max_out_0_reg_0 <= 16'sh0000;   
    end else if (start_in && !mode_in) begin 
        H_max_out_0_reg_0 <= 16'sh0000; 
    end else begin
        H_max_out_0_reg_0 <= value_0;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n ) begin
        location_in_0_reg_0 <= 1'b0;   
    end else if (start_in && !mode_in) begin 
        location_in_0_reg_0 <= 1'b0; 
    end else begin
        location_in_0_reg_0 <= location_in_0;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        location_in_0_reg_1 <= 1'b0;
        location_in_0_reg_2 <= 1'b0;
        location_in_0_reg_3 <= 1'b0;
        location_in_0_reg_4 <= 1'b0;
        location_in_0_reg_5 <= 1'b0;
    end
    else begin
        location_in_0_reg_1 <= location_in_0_reg_0;
        location_in_0_reg_2 <= location_in_0_reg_1;
        location_in_0_reg_3 <= location_in_0_reg_2;
        location_in_0_reg_4 <= location_in_0_reg_3;
        location_in_0_reg_5 <= location_in_0_reg_4;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_max_out_0_reg_1 <= 16'sh0000;
        H_max_out_0_reg_2 <= 16'sh0000;
        H_max_out_0_reg_3 <= 16'sh0000;
        H_max_out_0_reg_4 <= 16'sh0000;
        H_max_out_0_reg_5 <= 16'sh0000;  
    end
    else begin
        H_max_out_0_reg_1 <= value_0;
        H_max_out_0_reg_2 <= H_max_out_0_reg_1;
        H_max_out_0_reg_3 <= H_max_out_0_reg_2;
        H_max_out_0_reg_4 <= H_max_out_0_reg_3;
        H_max_out_0_reg_5 <= H_max_out_0_reg_4;   
    end
end

CMP_LOCATION_CJ MAX_cmp_1(
	.clk (sys_clk                       ),
	.rst_n (sys_rst_n                   ),
    .en(en      ),
    .clear(clear),
	.location_in_0(location_in_0_reg_5 ),
	.value_0 (H_max_out_0_reg_5         ),
	.location_in_1(location_in_1   ),
	.value_1 (value_1               ),

	.max(max                    ),
	.location_out (location_out       )
    ); 
    
endmodule