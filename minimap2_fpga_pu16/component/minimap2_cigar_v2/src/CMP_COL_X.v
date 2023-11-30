module CMP_COL_X #(
	parameter SCORE_WIDTH = 16,
	parameter LOCATION_WIDTH = 32
)
(
	//=================INPUT=============//

	sys_clk,
	sys_rst_n,
	clear,
	location_in_0,
	value_0,
	location_in_1,
	value_1,
	en,

	//=================OUTPUT============//
	max,
	location_out,
	en_out
	);

input wire sys_clk;
input wire sys_rst_n;
input wire clear;
input wire en;

input wire signed [SCORE_WIDTH-1 : 0] value_0;
input wire signed [SCORE_WIDTH-1 : 0] value_1;
input wire 		  [LOCATION_WIDTH-1 : 0] location_in_0;
input wire 		  [LOCATION_WIDTH-1 : 0] location_in_1;

output wire signed [SCORE_WIDTH-1 : 0] max;
output wire 	   [LOCATION_WIDTH-1 : 0] location_out;
output wire en_out;

reg [LOCATION_WIDTH-1:0] location_col_out_reg_0;
reg [LOCATION_WIDTH-1:0] location_col_out_reg_1;
reg [LOCATION_WIDTH-1:0] location_col_out_reg_2;
reg [LOCATION_WIDTH-1:0] location_col_out_reg_3;
reg [LOCATION_WIDTH-1:0] location_col_out_reg_4;
reg [LOCATION_WIDTH-1:0] location_col_out_reg_5;

reg signed  [SCORE_WIDTH-1:0] H_col_max_reg_0;
reg signed  [SCORE_WIDTH-1:0] H_col_max_reg_1;
reg signed  [SCORE_WIDTH-1:0] H_col_max_reg_2;
reg signed  [SCORE_WIDTH-1:0] H_col_max_reg_3;
reg signed  [SCORE_WIDTH-1:0] H_col_max_reg_4;
reg signed  [SCORE_WIDTH-1:0] H_col_max_reg_5;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        location_col_out_reg_0 <= 1'b0;   
    end else begin
        location_col_out_reg_0 <= location_in_0;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        location_col_out_reg_1 <= 1'b0;
        location_col_out_reg_2 <= 1'b0;
        location_col_out_reg_3 <= 1'b0;
        location_col_out_reg_4 <= 1'b0;
        location_col_out_reg_5 <= 1'b0;
    end else begin
        location_col_out_reg_1 <= location_col_out_reg_0;
        location_col_out_reg_2 <= location_col_out_reg_1;
        location_col_out_reg_3 <= location_col_out_reg_2;
        location_col_out_reg_4 <= location_col_out_reg_3;
        location_col_out_reg_5 <= location_col_out_reg_4;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        H_col_max_reg_0 <= 16'sh0000;   
    end else begin
        H_col_max_reg_0 <= value_0;  
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (! sys_rst_n) begin
        H_col_max_reg_1 <= 16'sh0000;
        H_col_max_reg_2 <= 16'sh0000;
        H_col_max_reg_3 <= 16'sh0000;
        H_col_max_reg_4 <= 16'sh0000;
        H_col_max_reg_5 <= 16'sh0000;  
    end
    else begin
        H_col_max_reg_1 <= H_col_max_reg_0;
        H_col_max_reg_2 <= H_col_max_reg_1;
        H_col_max_reg_3 <= H_col_max_reg_2;
        H_col_max_reg_4 <= H_col_max_reg_3;
        H_col_max_reg_5 <= H_col_max_reg_4;   
    end
end

CMP_COL col_cmp(
    .clk (sys_clk                           ),
    .rst_n (sys_rst_n                       ),
    .clear (clear                     ),
    .location_in_0(location_col_out_reg_5 ),
    .value_0 (H_col_max_reg_5             ),
    .en(en                            ),
    .location_in_1(location_in_1       ),
    .value_1 (value_1                  ),
    .max(max                        ),
    .en_out(en_out),
    .location_out (location_out           )
    ); 
    
endmodule