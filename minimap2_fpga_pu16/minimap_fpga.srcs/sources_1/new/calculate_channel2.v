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
module calculate_channel2 (
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
input wire core_clk  ;
input wire core_rst_n;
input wire sys_clk   ;
input wire sys_rst_n ;
//
input wire        matrix_memory_sop ;
input wire        matrix_memory_eop ;
input wire        matrix_memory_vld ;
input wire [31:0] matrix_memory_data;
output wire       pkt_enable        ;
//
input  wire                 channel_fifo_rden ;
output wire [DATA_WIDTH-1:0] channel_fifo_rdat ;
output wire                 channel_fifo_empty;

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

/*reg                  f0_fifo_write_en;
(* mark_debug = "true" *) reg                  fifo_write_en   ;
reg [DATA_WIDTH-1:0] f0_fifo_data_in ;*/
wire                  f0_fifo_write_en;
reg                  fifo_write_en   ;
wire [DATA_WIDTH-1:0] f0_fifo_data_in ;
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
reg                 pkt1_sop;
reg                 pkt1_eop;
reg                 pkt1_vld;
reg       [31:0]    pkt1_dat;
wire                pkt1_receive_enable;
wire                result1_fifo_rden;
wire [DATA_WIDTH-1:0]   result1_fifo_rdat;
wire                result1_fifo_empty;


/*---------------------------------------------------------------------*\
                         main code 
\*---------------------------------------------------------------------*/


//assign  pkt_enable =  pkt0_receive_enable;
assign  pkt_enable =  pkt0_receive_enable || pkt1_receive_enable;



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


always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt1_sop <= #D 1'b0;
	end else if (~pkt0_receive_enable && pkt1_receive_enable) begin 
		pkt1_sop <= #D matrix_memory_sop;
	end else begin 
		pkt1_sop <= #D 1'b0;
	end
end



always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt1_eop <= #D 1'b0;
	end else if (pkt1_vld) begin 
		pkt1_eop <= #D matrix_memory_eop;
	end else begin 
		pkt1_eop <= #D 1'b0;
	end
end


always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt1_vld <= #D 1'b0;
	end else if (~pkt0_receive_enable && pkt1_receive_enable && matrix_memory_sop) begin 
		pkt1_vld <= #D 1'b1;
	end else if (pkt1_eop) begin 
		pkt1_vld <= #D 1'b0;
	end
end



always @(posedge sys_clk  or negedge sys_rst_n) 
begin 
	if (!sys_rst_n) begin 
		pkt1_dat <= #D 32'd0;
	end else if (pkt1_vld || (matrix_memory_sop && pkt1_receive_enable)) begin 
		pkt1_dat <= #D matrix_memory_data;
	end else begin 
		pkt1_dat <= #D 32'd0;
	end
end



//============================================================================================

(* max_fanout = "100" *)reg [3:0] fifo_select_cont;

always @(posedge core_clk or negedge core_rst_n) 
begin 
	if (!core_rst_n) begin 
		fifo_select_cont <= #D 4'd0;
	end else if (fifo_select_cont == 4'd1) begin 
		fifo_select_cont <= #D 4'd0;
	end else begin
		fifo_select_cont <= #D fifo_select_cont + 1;
	end
end


assign result0_fifo_rden = (~result0_fifo_empty && ~fifo_almost_full && fifo_select_cont == 4'd0);


assign result1_fifo_rden = (~result1_fifo_empty && ~fifo_almost_full && fifo_select_cont == 4'd1);


//---------------------------------------------------------------------------------------


assign  f0_fifo_write_en = result0_fifo_rden || result1_fifo_rden;


assign  f0_fifo_data_in = (result0_fifo_rden)? result0_fifo_rdat :(
                         (result1_fifo_rden)? result1_fifo_rdat : 0 );
                   
                         

/*always@(posedge core_clk or negedge core_rst_n)
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
end	*/							 
								 
														 		 
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
wire rd_start_0, vld_out_0, empty_out_0, eop_out_0;
wire [63:0] data_out_0;

wire rd_start_1, vld_out_1, empty_out_1, eop_out_1;
wire [63:0] data_out_1;

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
	.rd_start          (rd_start_0           ),
	.vld_out           (vld_out_0            ),
	.empty_out         (empty_out_0          ),
	.eop_out           (eop_out_0            ),
	.data_out          (data_out_0           )
); 

matrix_7 u_1 (
	.core_clk          (core_clk           ),
	.core_rst_n        (core_rst_n         ),
	.sys_clk           (sys_clk            ),
	.sys_rst_n         (sys_rst_n          ),
	.matrix_memory_sop (pkt1_sop           ),
	.matrix_memory_eop (pkt1_eop           ),
	.matrix_memory_vld (pkt1_vld           ),
	.matrix_memory_data(pkt1_dat           ),
	.result_fifo_rden  (result1_fifo_rden  ),
	//
	.pkt_receive_enable(pkt1_receive_enable),
	.result_fifo_rdat  (result1_fifo_rdat  ),
	.result_fifo_empty (result1_fifo_empty ),
	.rd_start          (rd_start_1           ),
	.vld_out           (vld_out_1            ),
	.empty_out         (empty_out_1          ),
	.eop_out           (eop_out_1            ),
	.data_out          (data_out_1           )
);

result_collect_2 rc0(
	.core_clk  (core_clk			),
	.core_rst_n(core_rst_n			),

	.start_0   (rd_start_0			),
	.vld_0     (vld_out_0    		),
	.empty_0   (empty_out_0  		),
	.eop_0     (eop_out_0    		),
	.data_0    (data_out_0   		),

    .start_1   (rd_start_1   		),
	.vld_1     (vld_out_1    		),
	.empty_1   (empty_out_1  		),
	.eop_1     (eop_out_1    		),
	.data_1    (data_out_1   		),

	.rd_start  (rd_start			),
	.vld_out   (vld_out				),
	.empty_out (empty_out			),
	.eop_out   (eop_out				),
	.data_out  (data_out 			)

	); 

endmodule 
