/*********************************************************************
//  Author:    jyb
//  Filename:  
//  Modified:
//  Version:   1.0
//
//  Description:
//
//  Copyright (c) 2006   Combrio Networks.
//
//  All Rights Reserved.
//
//
// -------------------------------------------------------------------
//  Modification History:
//
//  Date             Who            Description of change
//  ------------------------------------------------------------------
//  2017-06-29       jyb             initial version
//
**********************************************************************/
module calculate_ctl_top (
core_clk,
core_rst_n,
sys_clk,
sys_rst_n,

result_fifo_rdat,
result_fifo_rden,
result_fifo_empty,

matrix_memory_sop_0, 
matrix_memory_eop_0, 
matrix_memory_vld_0, 
matrix_memory_data_0,
pkt_enable_0,

matrix_memory_sop_1, 
matrix_memory_eop_1, 
matrix_memory_vld_1, 
matrix_memory_data_1,
pkt_enable_1,


rd_start,
vld_out,
empty_out,
eop_out,
data_out

// matrix_memory_sop_2,
// matrix_memory_eop_2,
// matrix_memory_vld_2,
// matrix_memory_data_2,
// pkt_enable_2,

// matrix_memory_sop_3 ,
// matrix_memory_eop_3 ,
// matrix_memory_vld_3 ,
// matrix_memory_data_3,
// pkt_enable_3,

// matrix_memory_sop_4 ,
// matrix_memory_eop_4 ,
// matrix_memory_vld_4 ,
// matrix_memory_data_4,
// pkt_enable_4,

// matrix_memory_sop_5 ,
// matrix_memory_eop_5 ,
// matrix_memory_vld_5 ,
// matrix_memory_data_5,
// pkt_enable_5,

// matrix_memory_sop_6 ,
// matrix_memory_eop_6 ,
// matrix_memory_vld_6 ,
// matrix_memory_data_6,
// pkt_enable_6,

// matrix_memory_sop_7 ,
// matrix_memory_eop_7 ,
// matrix_memory_vld_7 ,
// matrix_memory_data_7,
// pkt_enable_7



);


/*---------------------------------------------------------------------*\
                         parameter description 
\*---------------------------------------------------------------------*/
parameter D            = 0.2          ;
parameter MAX_TIME_OUT = 32'd500000000;
parameter MAX_DATA_NUM = 15'd19200    ;
parameter DATA_WIDTH   = 512          ;
/*---------------------------------------------------------------------*\
                         port description 
\*---------------------------------------------------------------------*/
//global signal
input core_clk  ;
input core_rst_n;
input sys_clk   ;
input sys_rst_n ;
//
input         matrix_memory_sop_0 ;
input         matrix_memory_eop_0 ;
input         matrix_memory_vld_0 ;
input  [31:0] matrix_memory_data_0;
output        pkt_enable_0        ;
//
input         matrix_memory_sop_1 ;
input         matrix_memory_eop_1 ;
input         matrix_memory_vld_1 ;
input  [31:0] matrix_memory_data_1;
output        pkt_enable_1        ;

input wire rd_start;
(* mark_debug = "true" *)output wire vld_out;
output wire empty_out;
(* mark_debug = "true" *)output wire eop_out;
(* mark_debug = "true" *)output wire [63:0] data_out;
// //
// input               matrix_memory_sop_2 ;
// input               matrix_memory_eop_2 ;
// input               matrix_memory_vld_2 ;
// input     [31:0]    matrix_memory_data_2;
// output              pkt_enable_2;
// //
// input               matrix_memory_sop_3 ;
// input               matrix_memory_eop_3 ;
// input               matrix_memory_vld_3 ;
// input     [31:0]    matrix_memory_data_3;
// output              pkt_enable_3;
// //
// input               matrix_memory_sop_4 ;
// input               matrix_memory_eop_4 ;
// input               matrix_memory_vld_4 ;
// input     [31:0]    matrix_memory_data_4;
// output              pkt_enable_4;
// //
// input               matrix_memory_sop_5 ;
// input               matrix_memory_eop_5 ;
// input               matrix_memory_vld_5 ;
// input     [31:0]    matrix_memory_data_5;
// output              pkt_enable_5;
// //
// input               matrix_memory_sop_6 ;
// input               matrix_memory_eop_6 ;
// input               matrix_memory_vld_6 ;
// input     [31:0]    matrix_memory_data_6;
// output              pkt_enable_6;
// //
// input               matrix_memory_sop_7 ;
// input               matrix_memory_eop_7 ;
// input               matrix_memory_vld_7 ;
// input     [31:0]    matrix_memory_data_7;
// output              pkt_enable_7;
// //
output [DATA_WIDTH-1:0] result_fifo_rdat ;
output                  result_fifo_empty;
input                   result_fifo_rden ;


/*---------------------------------------------------------------------*\
                         reg/wire description 
\*---------------------------------------------------------------------*/
wire                  full            ;
wire                  fifo_almost_full;
reg                   f0_fifo_write_en;
reg                   fifo_write_en   ;
reg  [DATA_WIDTH-1:0] f0_fifo_data_in ;
reg  [DATA_WIDTH-1:0] fifo_data_in    ;
wire [           10:0] wr_data_count   ;





//
reg                   pkt0_sop           ;
reg                   pkt0_eop           ;
reg                   pkt0_vld           ;
reg  [          31:0] pkt0_dat           ;
wire                  pkt0_receive_enable;
wire                  result0_fifo_rden  ;
wire [DATA_WIDTH-1:0] result0_fifo_rdat  ;
wire                  result0_fifo_empty ;
//
reg                   pkt1_sop           ;
reg                   pkt1_eop           ;
reg                   pkt1_vld           ;
reg  [          31:0] pkt1_dat           ;
wire                  pkt1_receive_enable;
wire                  result1_fifo_rden  ;
wire [DATA_WIDTH-1:0] result1_fifo_rdat  ;
wire                  result1_fifo_empty ;
// //
// reg                 pkt2_sop;
// reg                 pkt2_eop;
// reg                 pkt2_vld;
// reg       [31:0]    pkt2_dat;
// wire                pkt2_receive_enable;
// wire                result2_fifo_rden;
// wire      [127:0]   result2_fifo_rdat;
// wire                result2_fifo_empty;
// //
// reg                 pkt3_sop;
// reg                 pkt3_eop;
// reg                 pkt3_vld;
// reg       [31:0]    pkt3_dat;
// wire                pkt3_receive_enable;
// wire                result3_fifo_rden;
// wire      [127:0]   result3_fifo_rdat;
// wire                result3_fifo_empty;
// //
// reg                 pkt4_sop;
// reg                 pkt4_eop;
// reg                 pkt4_vld;
// reg       [31:0]    pkt4_dat;
// wire                pkt4_receive_enable;
// wire                result4_fifo_rden;
// wire      [127:0]   result4_fifo_rdat;
// wire                result4_fifo_empty;
// //
// reg                 pkt5_sop;
// reg                 pkt5_eop;
// reg                 pkt5_vld;
// reg       [31:0]    pkt5_dat;
// wire                pkt5_receive_enable;
// wire                result5_fifo_rden;
// wire      [127:0]   result5_fifo_rdat;
// wire                result5_fifo_empty;
// //
// reg                 pkt6_sop;
// reg                 pkt6_eop;
// reg                 pkt6_vld;
// reg       [31:0]    pkt6_dat;
// wire                pkt6_receive_enable;
// wire                result6_fifo_rden;
// wire      [127:0]   result6_fifo_rdat;
// wire                result6_fifo_empty;
// //
// reg                 pkt7_sop;
// reg                 pkt7_eop;
// reg                 pkt7_vld;
// reg       [31:0]    pkt7_dat;
// wire                pkt7_receive_enable;
// wire                result7_fifo_rden;
// wire      [127:0]   result7_fifo_rdat;
// wire                result7_fifo_empty;
/*---------------------------------------------------------------------*\
                         main code 
\*---------------------------------------------------------------------*/
 

//assign  pkt_enable =  pkt0_receive_enable || pkt1_receive_enable;

assign  pkt_enable_0 = pkt0_receive_enable;

assign  pkt_enable_1 = pkt1_receive_enable;  

// assign  pkt_enable_2 = pkt2_receive_enable;

// assign  pkt_enable_3 = pkt3_receive_enable;  

// assign  pkt_enable_4 = pkt4_receive_enable;

// assign  pkt_enable_5 = pkt5_receive_enable;  

// assign  pkt_enable_6 = pkt6_receive_enable;

// assign  pkt_enable_7 = pkt7_receive_enable;  

//-----------------------------------------------------------------------

always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt0_sop <= #D 1'b0;
	end else if (pkt0_receive_enable) begin 
		pkt0_sop <= #D matrix_memory_sop_0;
	end else begin 
		pkt0_sop <= #D 1'b0;
	end
end

always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt0_eop <= #D 1'b0;
	end else if (pkt0_vld) begin 
		pkt0_eop <= #D matrix_memory_eop_0;
	end else begin 
		pkt0_eop <= #D 1'b0;
	end
end

always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt0_vld <= #D 1'b0;
	end else if (pkt0_receive_enable && matrix_memory_sop_0) begin 
		pkt0_vld <= #D 1'b1;
	end else if (pkt0_eop) begin 
		pkt0_vld <= #D 1'b0;
	end
end

always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt0_dat <= #D 32'd0;
	end else if (pkt0_vld || (matrix_memory_sop_0 && pkt0_receive_enable)) begin 
		pkt0_dat <= #D matrix_memory_data_0;
	end else begin 
		pkt0_dat <= #D 32'd0;
	end
end

//-----------------------------------------------------------------------------------------------------

always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt1_sop <= #D 1'b0;
	end else if (pkt1_receive_enable) begin 
		pkt1_sop <= #D matrix_memory_sop_1;
	end else begin 
		pkt1_sop <= #D 1'b0;
	end
end

always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt1_eop <= #D 1'b0;
	end else if (pkt1_vld) begin 
		pkt1_eop <= #D matrix_memory_eop_1;
	end else begin 
		pkt1_eop <= #D 1'b0;
	end
end

always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt1_vld <= #D 1'b0;
	end else if (pkt1_receive_enable && matrix_memory_sop_1) begin 
		pkt1_vld <= #D 1'b1;
	end else if (pkt1_eop) begin 
		pkt1_vld <= #D 1'b0;
	end
end

always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt1_dat <= #D 32'd0;
	end else if (pkt1_vld || (matrix_memory_sop_1 && pkt1_receive_enable)) begin 
		pkt1_dat <= #D matrix_memory_data_1;
	end else begin 
		pkt1_dat <= #D 32'd0;
	end
end

//-----------------------------------------------------------------------------------------------------

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt2_sop <= #D 1'b0;
// 	end else if (pkt2_receive_enable) begin 
// 		pkt2_sop <= #D matrix_memory_sop_2;
// 	end else begin 
// 		pkt2_sop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt2_eop <= #D 1'b0;
// 	end else if (pkt2_vld) begin 
// 		pkt2_eop <= #D matrix_memory_eop_2;
// 	end else begin 
// 		pkt2_eop <= #D 1'b0;
// 	end
// end


// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt2_vld <= #D 1'b0;
// 	end else if (pkt2_receive_enable && matrix_memory_sop_2) begin 
// 		pkt2_vld <= #D 1'b1;
// 	end else if (pkt2_eop) begin 
// 		pkt2_vld <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt2_dat <= #D 32'd0;
// 	end else if (pkt2_vld || (matrix_memory_sop_2 && pkt2_receive_enable)) begin 
// 		pkt2_dat <= #D matrix_memory_data_2;
// 	end else begin 
// 		pkt2_dat <= #D 32'd0;
// 	end
// end

// //-----------------------------------------------------------------------------------------------------

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt3_sop <= #D 1'b0;
// 	end else if (pkt3_receive_enable) begin 
// 		pkt3_sop <= #D matrix_memory_sop_3;
// 	end else begin 
// 		pkt3_sop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt3_eop <= #D 1'b0;
// 	end else if (pkt3_vld) begin 
// 		pkt3_eop <= #D matrix_memory_eop_3;
// 	end else begin 
// 		pkt3_eop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt3_vld <= #D 1'b0;
// 	end else if (pkt3_receive_enable && matrix_memory_sop_3) begin 
// 		pkt3_vld <= #D 1'b1;
// 	end else if (pkt3_eop) begin 
// 		pkt3_vld <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt3_dat <= #D 32'd0;
// 	end else if (pkt3_vld || (matrix_memory_sop_3 && pkt3_receive_enable)) begin 
// 		pkt3_dat <= #D matrix_memory_data_3;
// 	end else begin 
// 		pkt3_dat <= #D 32'd0;
// 	end
// end

// //-----------------------------------------------------------------------------------------------------

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt4_sop <= #D 1'b0;
// 	end else if (pkt4_receive_enable) begin 
// 		pkt4_sop <= #D matrix_memory_sop_4;
// 	end else begin 
// 		pkt4_sop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt4_eop <= #D 1'b0;
// 	end else if (pkt4_vld) begin 
// 		pkt4_eop <= #D matrix_memory_eop_4;
// 	end else begin 
// 		pkt4_eop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt4_vld <= #D 1'b0;
// 	end else if (pkt4_receive_enable && matrix_memory_sop_4) begin 
// 		pkt4_vld <= #D 1'b1;
// 	end else if (pkt4_eop) begin 
// 		pkt4_vld <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt4_dat <= #D 32'd0;
// 	end else if (pkt4_vld || (matrix_memory_sop_4 && pkt4_receive_enable)) begin 
// 		pkt4_dat <= #D matrix_memory_data_4;
// 	end else begin 
// 		pkt4_dat <= #D 32'd0;
// 	end
// end

// //-----------------------------------------------------------------------------------------------------

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt5_sop <= #D 1'b0;
// 	end else if (pkt5_receive_enable) begin 
// 		pkt5_sop <= #D matrix_memory_sop_5;
// 	end else begin 
// 		pkt5_sop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt5_eop <= #D 1'b0;
// 	end else if (pkt5_vld) begin 
// 		pkt5_eop <= #D matrix_memory_eop_5;
// 	end else begin 
// 		pkt5_eop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt5_vld <= #D 1'b0;
// 	end else if (pkt5_receive_enable && matrix_memory_sop_5) begin 
// 		pkt5_vld <= #D 1'b1;
// 	end else if (pkt5_eop) begin 
// 		pkt5_vld <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt5_dat <= #D 32'd0;
// 	end else if (pkt5_vld || (matrix_memory_sop_5 && pkt5_receive_enable)) begin 
// 		pkt5_dat <= #D matrix_memory_data_5;
// 	end else begin 
// 		pkt5_dat <= #D 32'd0;
// 	end
// end

// //-----------------------------------------------------------------------------------------------------

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt6_sop <= #D 1'b0;
// 	end else if (pkt6_receive_enable) begin 
// 		pkt6_sop <= #D matrix_memory_sop_6;
// 	end else begin 
// 		pkt6_sop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt6_eop <= #D 1'b0;
// 	end else if (pkt6_vld) begin 
// 		pkt6_eop <= #D matrix_memory_eop_6;
// 	end else begin 
// 		pkt6_eop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt6_vld <= #D 1'b0;
// 	end else if (pkt6_receive_enable && matrix_memory_sop_6) begin 
// 		pkt6_vld <= #D 1'b1;
// 	end else if (pkt6_eop) begin 
// 		pkt6_vld <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt6_dat <= #D 32'd0;
// 	end else if (pkt6_vld || (matrix_memory_sop_6 && pkt6_receive_enable)) begin 
// 		pkt6_dat <= #D matrix_memory_data_6;
// 	end else begin 
// 		pkt6_dat <= #D 32'd0;
// 	end
// end

// //-----------------------------------------------------------------------------------------------------

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt7_sop <= #D 1'b0;
// 	end else if (pkt7_receive_enable) begin 
// 		pkt7_sop <= #D matrix_memory_sop_7;
// 	end else begin 
// 		pkt7_sop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt7_eop <= #D 1'b0;
// 	end else if (pkt7_vld) begin 
// 		pkt7_eop <= #D matrix_memory_eop_7;
// 	end else begin 
// 		pkt7_eop <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt7_vld <= #D 1'b0;
// 	end else if (pkt7_receive_enable && matrix_memory_sop_7) begin 
// 		pkt7_vld <= #D 1'b1;
// 	end else if (pkt7_eop) begin 
// 		pkt7_vld <= #D 1'b0;
// 	end
// end

// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt7_dat <= #D 32'd0;
// 	end else if (pkt7_vld || (matrix_memory_sop_7 && pkt7_receive_enable)) begin 
// 		pkt7_dat <= #D matrix_memory_data_7;
// 	end else begin 
// 		pkt7_dat <= #D 32'd0;
// 	end
// end




//======================================================================================================

reg [3:0] fifo_select_cont;

always @(posedge core_clk  or negedge core_rst_n) 
begin 
	if (!core_rst_n) begin 
		fifo_select_cont <= #D 4'd0;
	end else if (fifo_select_cont == 4'd1) begin 
		fifo_select_cont <= #D 4'd0;
	end else begin 
		fifo_select_cont <= #D fifo_select_cont + 1;
	end
end


assign result0_fifo_rden = (~result0_fifo_empty && ~fifo_almost_full && fifo_select_cont==4'd0);

assign result1_fifo_rden = (~result1_fifo_empty && ~fifo_almost_full && fifo_select_cont==4'd1);






//assign  f0_fifo_write_en = result0_fifo_rden || result1_fifo_rden || result2_fifo_rden || result3_fifo_rden ||   
//                           result4_fifo_rden || result5_fifo_rden || result6_fifo_rden || result7_fifo_rden; 
//
//
//
//
//assign  f0_fifo_data_in = (result0_fifo_rden)? result0_fifo_rdat : (
//                          (result1_fifo_rden)? result1_fifo_rdat : (
//                          (result2_fifo_rden)? result2_fifo_rdat : (
//                          (result3_fifo_rden)? result3_fifo_rdat : (                          
//                          (result4_fifo_rden)? result4_fifo_rdat : (                          
//                          (result5_fifo_rden)? result5_fifo_rdat : (                          
//                          (result6_fifo_rden)? result6_fifo_rdat : (                          
//                          (result7_fifo_rden)? result7_fifo_rdat : 0)))))));                                    
 

always @(posedge core_clk or negedge core_rst_n)
begin 
	if (!core_rst_n) begin
		f0_fifo_write_en <= 1'b0;
	end else begin
		f0_fifo_write_en <= result0_fifo_rden || result1_fifo_rden ; 
   end 
end


always @(posedge core_clk or negedge core_rst_n)
	begin
		if (!core_rst_n) begin
			f0_fifo_data_in <= 512'b0;
		end else if(result0_fifo_rden) begin
			f0_fifo_data_in <= result0_fifo_rdat;
		end else if(result1_fifo_rden) begin
			f0_fifo_data_in <= result1_fifo_rdat;
		end else begin
			f0_fifo_data_in <= 512'b0;
		end
	end


//---------------------------------------------------------------------


/*fifo_1024x256 u_fifo_1024x256 (
	.clk       (core_clk         ),
	.din       (fifo_data_in     ),
	.wr_en     (fifo_write_en    ),
	.rd_en     (result_fifo_rden ),
	.dout      (result_fifo_rdat ),
	.full      (full             ),
	.empty     (result_fifo_empty),
	.data_count(wr_data_count    )
);*/

fifo_1024x512 u_fifo_1024x512 (
	.clk       (core_clk         ),
	.din       (fifo_data_in     ),
	.wr_en     (fifo_write_en    ),
	.rd_en     (result_fifo_rden ),
	.dout      (result_fifo_rdat ),
	.full      (full             ),
	.empty     (result_fifo_empty),
	.data_count(wr_data_count    )
);


assign fifo_almost_full = (wr_data_count >= 'd1010); 

//==============


always@(posedge core_clk or negedge core_rst_n)
begin
  if(!core_rst_n)
  	fifo_data_in <= 512'b0;
  else 
  	fifo_data_in <= f0_fifo_data_in;
end
  
always@(posedge core_clk or negedge core_rst_n)
begin
  if(!core_rst_n)
  	fifo_write_en <= 1'b0;
  else 
  	fifo_write_en <= f0_fifo_write_en;
end





//-----------------------------------------------------------------------------------
(* mark_debug = "true" *)wire start_0, vld_0, empty_0, eop_0;
(* mark_debug = "true" *)wire [63:0] data_0;

wire start_1, vld_1, empty_1, eop_1;
wire [63:0] data_1;

calculate_channel2 u0 (
	.core_clk          (core_clk           ),
	.core_rst_n        (core_rst_n         ),
	.sys_clk           (sys_clk            ),
	.sys_rst_n         (sys_rst_n          ),
	.matrix_memory_sop (pkt0_sop           ),
	.matrix_memory_eop (pkt0_eop           ),
	.matrix_memory_vld (pkt0_vld           ),
	.matrix_memory_data(pkt0_dat           ),
	.pkt_enable        (pkt0_receive_enable),
	.channel_fifo_rden (result0_fifo_rden  ),
	.channel_fifo_rdat (result0_fifo_rdat  ),
	.channel_fifo_empty(result0_fifo_empty ),

	.rd_start          (start_0		       ),
	.vld_out 		   (vld_0 			   ),
	.empty_out         (empty_0 		   ),
	.eop_out           (eop_0     		   ),
	.data_out          (data_0             )
);

calculate_channel2 u1 (
	.core_clk          (core_clk           ),
	.core_rst_n        (core_rst_n         ),
	.sys_clk           (sys_clk            ),
	.sys_rst_n         (sys_rst_n          ),
	.matrix_memory_sop (pkt1_sop           ),
	.matrix_memory_eop (pkt1_eop           ),
	.matrix_memory_vld (pkt1_vld           ),
	.matrix_memory_data(pkt1_dat           ),
	.pkt_enable        (pkt1_receive_enable),
	.channel_fifo_rden (result1_fifo_rden  ),
	.channel_fifo_rdat (result1_fifo_rdat  ),
	.channel_fifo_empty(result1_fifo_empty ),

	.rd_start          (start_1		       ),
	.vld_out 		   (vld_1 			   ),
	.empty_out         (empty_1 		   ),
	.eop_out           (eop_1     		   ),
	.data_out          (data_1             )
);

result_collect_2 rc0(
	.core_clk  (core_clk			),
	.core_rst_n(core_rst_n			),

	.start_0   (start_0				),
	.vld_0     (vld_0 				),
	.empty_0   (empty_0 			),
	.eop_0     (eop_0 				),
	.data_0    (data_0 				),

    .start_1   (start_1				),
	.vld_1     (vld_1 				),
	.empty_1   (empty_1 			),
	.eop_1     (eop_1 				),
	.data_1    (data_1 				),

	.rd_start  (rd_start			),
	.vld_out   (vld_out				),
	.empty_out (empty_out			),
	.eop_out   (eop_out				),
	.data_out  (data_out 			)

	);

// calculate_channel u2(
//    .core_clk              (core_clk            ),
//    .sys_clk               (sys_clk             ),
//    .sys_rst_n             (sys_rst_n           ),
// 	 .matrix_memory_sop     (pkt2_sop            ),
// 	 .matrix_memory_eop     (pkt2_eop            ),
// 	 .matrix_memory_vld     (pkt2_vld            ),
// 	 .matrix_memory_data    (pkt2_dat            ), 
//    .pkt_enable            (pkt2_receive_enable ), 
//    .channel_fifo_rden     (result2_fifo_rden   ),  
//    .channel_fifo_rdat     (result2_fifo_rdat   ),  
//    .channel_fifo_empty    (result2_fifo_empty  )
// );

// calculate_channel u3(
//    .core_clk              (core_clk            ),
//    .sys_clk               (sys_clk             ),
//    .sys_rst_n             (sys_rst_n           ),
// 	 .matrix_memory_sop     (pkt3_sop            ),
// 	 .matrix_memory_eop     (pkt3_eop            ),
// 	 .matrix_memory_vld     (pkt3_vld            ),
// 	 .matrix_memory_data    (pkt3_dat            ), 
//    .pkt_enable            (pkt3_receive_enable ), 
//    .channel_fifo_rden     (result3_fifo_rden   ),  
//    .channel_fifo_rdat     (result3_fifo_rdat   ),  
//    .channel_fifo_empty    (result3_fifo_empty  )
// );


// calculate_channel u4(
//    .core_clk              (core_clk            ),
//    .sys_clk               (sys_clk             ),
//    .sys_rst_n             (sys_rst_n           ),
// 	 .matrix_memory_sop     (pkt4_sop            ),
// 	 .matrix_memory_eop     (pkt4_eop            ),
// 	 .matrix_memory_vld     (pkt4_vld            ),
// 	 .matrix_memory_data    (pkt4_dat            ), 
//    .pkt_enable            (pkt4_receive_enable ), 
//    .channel_fifo_rden     (result4_fifo_rden   ),  
//    .channel_fifo_rdat     (result4_fifo_rdat   ),  
//    .channel_fifo_empty    (result4_fifo_empty  )
// );

// calculate_channel u5(
//    .core_clk              (core_clk            ),   
// 	.sys_clk               (sys_clk             ),
//    .sys_rst_n             (sys_rst_n           ),
// 	 .matrix_memory_sop     (pkt5_sop            ),
// 	 .matrix_memory_eop     (pkt5_eop            ),
// 	 .matrix_memory_vld     (pkt5_vld            ),
// 	 .matrix_memory_data    (pkt5_dat            ), 
//    .pkt_enable            (pkt5_receive_enable ), 
//    .channel_fifo_rden     (result5_fifo_rden   ),  
//    .channel_fifo_rdat     (result5_fifo_rdat   ),  
//    .channel_fifo_empty    (result5_fifo_empty  )
// );

// calculate_channel u6(
//    .core_clk              (core_clk            ),  
//   .sys_clk               (sys_clk             ),
//    .sys_rst_n             (sys_rst_n           ),
// 	 .matrix_memory_sop     (pkt6_sop            ),
// 	 .matrix_memory_eop     (pkt6_eop            ),
// 	 .matrix_memory_vld     (pkt6_vld            ),
// 	 .matrix_memory_data    (pkt6_dat            ), 
//    .pkt_enable            (pkt6_receive_enable ), 
//    .channel_fifo_rden     (result6_fifo_rden   ),  
//    .channel_fifo_rdat     (result6_fifo_rdat   ),  
//    .channel_fifo_empty    (result6_fifo_empty  )
// );

// calculate_channel u7(
//    .core_clk              (core_clk            ),
//    .sys_clk               (sys_clk             ),
//    .sys_rst_n             (sys_rst_n           ),
// 	 .matrix_memory_sop     (pkt7_sop            ),
// 	 .matrix_memory_eop     (pkt7_eop            ),
// 	 .matrix_memory_vld     (pkt7_vld            ),
// 	 .matrix_memory_data    (pkt7_dat            ), 
//    .pkt_enable            (pkt7_receive_enable ), 
//    .channel_fifo_rden     (result7_fifo_rden   ),  
//    .channel_fifo_rdat     (result7_fifo_rdat   ),  
//    .channel_fifo_empty    (result7_fifo_empty  )
// );
//===============================================================

//(*noprune*) reg [31:0]  sop_cont;
//(*noprune*) reg [31:0]  fifo_in_cont;
//(*noprune*) reg [31:0]  fifo_out_cont;

//always @(posedge sys_clk or negedge sys_rst_n) 
//begin
//	if (!sys_rst_n) begin
//      sop_cont <=#D 32'd0;
//	end else if (matrix_memory_sop_0 || matrix_memory_sop_1 || matrix_memory_sop_2 || matrix_memory_sop_3 ||
//	             matrix_memory_sop_4 || matrix_memory_sop_5 || matrix_memory_sop_6 || matrix_memory_sop_7 )begin
//      sop_cont <=#D sop_cont + 1;
//	end 
//end 
//
//
//always @(posedge sys_clk or negedge sys_rst_n) 
//begin
//	if (!sys_rst_n) begin
//      fifo_in_cont <=#D 32'd0;
//	end else if (fifo_write_en) begin
//      fifo_in_cont <=#D fifo_in_cont + 1;
//	end 
//end
//
//always @(posedge sys_clk or negedge sys_rst_n) 
//begin
//	if (!sys_rst_n) begin
//      fifo_out_cont <=#D 32'd0;
//	end else if (fifo_read_en) begin
//      fifo_out_cont <=#D fifo_out_cont + 1;
//	end 
//end


endmodule 


