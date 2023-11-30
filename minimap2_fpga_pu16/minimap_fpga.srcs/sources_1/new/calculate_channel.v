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
module calculate_channel (
core_clk,
core_rst_n,
sys_clk,
sys_rst_n,

matrix_memory_sop,
matrix_memory_eop,
matrix_memory_vld,
matrix_memory_data,

pkt_enable, 
channel_fifo_rden,  
channel_fifo_rdat,  
channel_fifo_empty,

rd_start,
vld_out,
empty_out,
eop_out,
data_out

);


/*---------------------------------------------------------------------*\
                         parameter description 
\*---------------------------------------------------------------------*/

parameter  D  =  0.2;
parameter  DATA_WIDTH = 512;

/*---------------------------------------------------------------------*\
                         port description 
\*---------------------------------------------------------------------*/
//global signal
input core_clk  ;
input core_rst_n;
input sys_clk   ;
input sys_rst_n ;
//
input         matrix_memory_sop ;
input         matrix_memory_eop ;
input         matrix_memory_vld ;
input  [31:0] matrix_memory_data;
output        pkt_enable        ;
//
input                   channel_fifo_rden ;
output [DATA_WIDTH-1:0] channel_fifo_rdat ;
output                  channel_fifo_empty;

input wire rd_start;
output wire vld_out;
output wire empty_out;
output wire eop_out;
output wire [63:0] data_out;

/*---------------------------------------------------------------------*\
                         reg/wire description 
\*---------------------------------------------------------------------*/

wire [8:0] usedw           ;
wire       full            ;
wire       empty           ;
wire       fifo_almost_full;

reg                  f0_fifo_write_en;
(* mark_debug = "true" *) reg                  fifo_write_en   ;
reg [DATA_WIDTH-1:0] f0_fifo_data_in ;
(* mark_debug = "true" *) reg [DATA_WIDTH-1:0] fifo_data_in    ;
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
// reg                 pkt1_sop;
// reg                 pkt1_eop;
// reg                 pkt1_vld;
// reg       [31:0]    pkt1_dat;
// wire                pkt1_receive_enable;
// wire                result1_fifo_rden;
// wire      [127:0]   result1_fifo_rdat;
// wire                result1_fifo_empty;


/*---------------------------------------------------------------------*\
                         main code 
\*---------------------------------------------------------------------*/


assign  pkt_enable =  pkt0_receive_enable;



always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt0_sop <= #D 1'b0;
	end else if (pkt0_receive_enable) begin 
		pkt0_sop <= #D matrix_memory_sop;
	end else begin 
		pkt0_sop <= #D 1'b0;
	end
end


always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt0_eop <= #D 1'b0;
	end else if (pkt0_vld) begin 
		pkt0_eop <= #D matrix_memory_eop;
	end else begin 
		pkt0_eop <= #D 1'b0;
	end
end


always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt0_vld <= #D 1'b0;
	end else if (pkt0_receive_enable && matrix_memory_sop) begin 
		pkt0_vld <= #D 1'b1;
	end else if (pkt0_eop) begin 
		pkt0_vld <= #D 1'b0;
	end
end




always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt0_dat <= #D 32'd0;
	end else if (pkt0_vld || (matrix_memory_sop && pkt0_receive_enable)) begin 
		pkt0_dat <= #D matrix_memory_data;
	end else begin 
		pkt0_dat <= #D 32'd0;
	end
end

//-----------


// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt1_sop <= #D 1'b0;
// 	end else if (~pkt0_receive_enable && pkt1_receive_enable) begin 
// 		pkt1_sop <= #D matrix_memory_sop;
// 	end else begin 
// 		pkt1_sop <= #D 1'b0;
// 	end
// end



// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt1_eop <= #D 1'b0;
// 	end else if (pkt1_vld) begin 
// 		pkt1_eop <= #D matrix_memory_eop;
// 	end else begin 
// 		pkt1_eop <= #D 1'b0;
// 	end
// end


// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt1_vld <= #D 1'b0;
// 	end else if (~pkt0_receive_enable && pkt1_receive_enable && matrix_memory_sop) begin 
// 		pkt1_vld <= #D 1'b1;
// 	end else if (pkt1_eop) begin 
// 		pkt1_vld <= #D 1'b0;
// 	end
// end



// always @(posedge sys_clk  or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		pkt1_dat <= #D 32'd0;
// 	end else if (pkt1_vld || (matrix_memory_sop && pkt1_receive_enable)) begin 
// 		pkt1_dat <= #D matrix_memory_data;
// 	end else begin 
// 		pkt1_dat <= #D 32'd0;
// 	end
// end



//============================================================================================

// reg [3:0] fifo_select_cont;

// always @(posedge core_clk or negedge sys_rst_n) 
// begin 
// 	if (!sys_rst_n) begin 
// 		fifo_select_cont <= #D 4'd0;
// 	end else if (fifo_select_cont == 4'd1) begin 
// 		fifo_select_cont <= #D 4'd0;
// 	end else begin
// 		fifo_select_cont <= #D fifo_select_cont + 1;
// 	end
// end


assign result0_fifo_rden = (~result0_fifo_empty && ~fifo_almost_full);


// assign result1_fifo_rden = (~result1_fifo_empty && ~fifo_almost_full && fifo_select_cont == 4'd1);


//---------------------------------------------------------------------------------------


//assign  f0_fifo_write_en = result0_fifo_rden || result1_fifo_rden;
//
//
//assign  f0_fifo_data_in = (result0_fifo_rden)? result0_fifo_rdat :(
//                          (result1_fifo_rden)? result1_fifo_rdat : 0 );
                   
                         

always@(posedge core_clk or negedge core_rst_n)
begin
  if(!core_rst_n)begin	
    f0_fifo_write_en <=#D 1'b0;
  end else begin
    f0_fifo_write_en <=#D result0_fifo_rden;
  end
end								 
								 
								 
always@(posedge core_clk or negedge core_rst_n)
begin
  if(!core_rst_n)begin	
    f0_fifo_data_in <=#D 128'b0;
  end else if(result0_fifo_rden) begin
    f0_fifo_data_in <=#D result0_fifo_rdat;
  end else begin
    f0_fifo_data_in <=#D 128'b0;  
  end 
end								 
								 
														 		 
always@(posedge core_clk or negedge core_rst_n)
begin
  if(!core_rst_n)begin	
    fifo_write_en <=#D 1'b0;
  end else begin
    fifo_write_en <=#D f0_fifo_write_en;
  end
end

always@(posedge core_clk or negedge core_rst_n)
begin
  if(!core_rst_n)begin	
    fifo_data_in <=#D 128'd0;
  end else begin
    fifo_data_in <=#D f0_fifo_data_in;
  end
end
 



fifo_256x512 channel_fifo (
	.wr_clk       (core_clk         ), // input wire wr_clk
	.rd_clk       (core_clk         ), // input wire rd_clk
	.din          (fifo_data_in     ), // input wire [512 : 0] din
	.wr_en        (fifo_write_en    ), // input wire wr_en
	.rd_en        (channel_fifo_rden), // input wire rd_en
	.dout         (channel_fifo_rdat), // output wire [512 : 0] dout
	.full         (full             ), // output wire full
	.empty        (empty            ), // output wire empty
	.wr_data_count(usedw            )  // output wire [8 : 0] wr_data_count
);
//----------------------------------------------------------------------


assign fifo_almost_full = (usedw >= 9'd500); 

assign channel_fifo_empty = empty;


//----------------------------------------------------------------------


matrix_7 u_0 (
	.core_clk          (core_clk           ),
	.core_rst_n        (core_rst_n         ),
	.sys_clk           (sys_clk            ),
	.sys_rst_n         (sys_rst_n          ),
	.matrix_memory_sop (pkt0_sop           ),
	.matrix_memory_eop (pkt0_eop           ),
	.matrix_memory_vld (pkt0_vld           ),
	.matrix_memory_data(pkt0_dat           ),
	.result_fifo_rden  (result0_fifo_rden  ),
	//
	.pkt_receive_enable(pkt0_receive_enable),
	.result_fifo_rdat  (result0_fifo_rdat  ),
	.result_fifo_empty (result0_fifo_empty ),
	.rd_start          (rd_start           ),
	.vld_out           (vld_out            ),
	.empty_out         (empty_out          ),
	.eop_out           (eop_out            ),
	.data_out          (data_out           )
); 


endmodule 
