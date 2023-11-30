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
//  2015-02-01       jyb             initial version
//
**********************************************************************/
`timescale 1ns/1ps
module data_pkt_sim(
sys_clk,
sys_rst_n,

pcie_ram_ren, 
pcie_ram_raddr,
pcie_ram_rdat,

start_analysis,
get_data_done,

matrix_enable_0,
// matrix_enable_1,
// matrix_enable_2,
// matrix_enable_3,

pkt_data_0,
pkt_sop_0,
pkt_eop_0,
pkt_vld_0

// pkt_data_1,
// pkt_sop_1,
// pkt_eop_1,
// pkt_vld_1,

// pkt_data_2,
// pkt_sop_2,
// pkt_eop_2,
// pkt_vld_2,

// pkt_data_3,
// pkt_sop_3,
// pkt_eop_3,
// pkt_vld_3
);
/*---------------------------------------------------------------------*\
                         parameter description 
\*---------------------------------------------------------------------*/
parameter D = 1;

parameter IDLE               = 8'b0000_0001;
parameter GET_PKT_NUM        = 8'b0000_0010;
parameter WAIT_ENABLE        = 8'b0000_0100;
parameter GET_DATA_NUM       = 8'b0000_1000;
parameter GET_DATA           = 8'b0001_0000;
parameter SEND_DATA          = 8'b0010_0000;
parameter JUDGE              = 8'b0100_0000;
parameter DONE               = 8'b1000_0000;
/*---------------------------------------------------------------------*\
                         port description 
\*---------------------------------------------------------------------*/
//global signal

input   wire            sys_clk;
input   wire            sys_rst_n;

(* mark_debug = "true" *) output  wire            pcie_ram_ren; 
(* mark_debug = "true" *) output  wire  [15:0]    pcie_ram_raddr;
(* mark_debug = "true" *) input   wire  [127:0]   pcie_ram_rdat;

(* mark_debug = "true" *) input   wire            start_analysis;
output  wire            get_data_done;

(* mark_debug = "true" *) input   wire            matrix_enable_0;
// input   wire            matrix_enable_1;
// input   wire            matrix_enable_2;
// input   wire            matrix_enable_3;

output  wire  [31:0]    pkt_data_0;
output  wire            pkt_sop_0;
output  wire            pkt_eop_0;
output  wire            pkt_vld_0;

// output  wire  [31:0]    pkt_data_1;
// output  wire            pkt_sop_1;
// output  wire            pkt_eop_1;
// output  wire            pkt_vld_1;

// output  wire  [31:0]    pkt_data_2;
// output  wire            pkt_sop_2;
// output  wire            pkt_eop_2;
// output  wire            pkt_vld_2;

// output  wire  [31:0]    pkt_data_3;    
// output  wire            pkt_sop_3;
// output  wire            pkt_eop_3;
// output  wire            pkt_vld_3;

/*---------------------------------------------------------------------*\
                         reg/wire description 
\*---------------------------------------------------------------------*/
(* mark_debug = "true" *) reg       [7:0]     curr_sta;
reg       [7:0]     next_sta;


reg       [15:0]    pcie_ram_wen_cont;
reg       [15:0]    pcie_ram_ren_cont;

reg                 pcie_ram_ren_reg; 
reg       [15:0]    pcie_ram_raddr_reg;

wire                read_pcie_enable; 

(* mark_debug = "true" *)reg       [7:0]     counter1;
(* mark_debug = "true" *) reg       [31:0]    pkt_num;
reg       [31:0]    pkt_num_cont;

(* mark_debug = "true" *)reg       [7:0]     counter2;
  
(* mark_debug = "true" *) reg       [31:0]    data_num;

reg                 get_data_ren;
reg                 f0_get_data_ren;
reg                 f1_get_data_ren;
reg                 f2_get_data_ren;
reg                 f3_get_data_ren;
reg       [15:0]    data_num_cont;

 reg                 channel_fifo_free_0;
reg                 channel_fifo_free_1;
reg                 channel_fifo_free_2;
reg                 channel_fifo_free_3;
reg                 channel_fifo_free;

reg                 f0_channel_fifo_free_0;
reg                 f0_channel_fifo_free_1;
reg                 f0_channel_fifo_free_2;
reg                 f0_channel_fifo_free_3;

wire         wrfull_0            ;
wire [  7:0] wrusedw_0           ;
wire         rdempty_0           ;
wire [  8:0] wr_data_count_0     ;
wire [ 10:0] rd_data_count_0     ;
reg          wen_0               ;
reg  [127:0] wdat_0              ;
wire         select_fifo_0       ;
wire         start_read_fifo_0   ; //sys_clk
reg          f0_start_read_fifo_0; //sys_clk
wire         start_one_pkt_0     ;

wire         wrfull_1            ;
wire         wrempty_1           ;
wire [  7:0] wrusedw_1           ;
wire         rdempty_1           ;
wire [  8:0] wr_data_count_1     ;
wire [ 10:0] rd_data_count_1     ;
wire [  9:0] rdusedw_1           ;
reg          wen_1               ;
reg  [127:0] wdat_1              ;
wire         select_fifo_1       ;
wire         start_read_fifo_1   ; //sys_clk
reg          f0_start_read_fifo_1; //sys_clk
wire         start_one_pkt_1     ;

wire         wrfull_2            ;
wire         wrempty_2           ;
wire [  7:0] wrusedw_2           ;
wire         rdempty_2           ;
wire [  8:0] wr_data_count_2     ;
wire [ 10:0] rd_data_count_2     ;
wire [  9:0] rdusedw_2           ;
reg          wen_2               ;
reg  [127:0] wdat_2              ;
wire         select_fifo_2       ;
wire         start_read_fifo_2   ; //sys_clk
reg          f0_start_read_fifo_2; //sys_clk
wire         start_one_pkt_2     ;

wire         wrfull_3            ;
wire         wrempty_3           ;
wire [  7:0] wrusedw_3           ;
wire         rdempty_3           ;
wire [  8:0] wr_data_count_3     ;
wire [ 10:0] rd_data_count_3     ;
wire [  9:0] rdusedw_3           ;
reg          wen_3               ;
reg  [127:0] wdat_3              ;
wire         select_fifo_3       ;
wire         start_read_fifo_3   ; //sys_clk
reg          f0_start_read_fifo_3; //sys_clk
wire         start_one_pkt_3     ;

reg       [1:0]     fifo_select_cont;

wire      [31:0]    f0_pkt_data_0;  
reg                 pkt_sop_0_reg;   
reg                 pkt_eop_0_reg;   
reg                 pkt_vld_0_reg;

wire      [31:0]    f0_pkt_data_1;  
reg                 pkt_sop_1_reg;   
reg                 pkt_eop_1_reg;   
reg                 pkt_vld_1_reg;

wire      [31:0]    f0_pkt_data_2;  
reg                 pkt_sop_2_reg;   
reg                 pkt_eop_2_reg;   
reg                 pkt_vld_2_reg;

wire      [31:0]    f0_pkt_data_3;  
reg                 pkt_sop_3_reg;   
reg                 pkt_eop_3_reg;   
reg                 pkt_vld_3_reg;


/*---------------------------------------------------------------------*\
                         main code 
\*---------------------------------------------------------------------*/

//always@(posedge sys_clk or negedge sys_rst_n)
//begin
//  if(!sys_rst_n)begin	
//    pcie_ram_wen_cont <=#D 16'd0;
//  end else if((curr_sta == DONE || curr_sta == IDLE) && pcie_ram_wen_cont == 16'd9600) begin     
//    pcie_ram_wen_cont <=#D 16'd0;  
//  end else if(pcie_ram_wen) begin
//    pcie_ram_wen_cont <=#D pcie_ram_wen_cont + 1;    	
//  end
//end
//
//
//always@(posedge sys_clk or negedge sys_rst_n)
//begin
//  if(!sys_rst_n)begin	
//    pcie_ram_ren_cont <=#D 16'd0;
//  end else if(curr_sta == DONE) begin      
//    pcie_ram_ren_cont <=#D 16'd0;  
//  end else if(pcie_ram_ren_reg) begin
//    pcie_ram_ren_cont <=#D pcie_ram_ren_cont + 1;    	
//  end
//end    


//always@(posedge sys_clk or negedge sys_rst_n)
//begin
//  if(!sys_rst_n)begin	
//    pcie_ram_wen_cont <=#D 16'd0;
//  end else if(pcie_ram_wen_cont == 16'd9600 && curr_sta == IDLE) begin     
//    pcie_ram_wen_cont <=#D 16'd0;  
//  end else if(pcie_ram_wen) begin
//    pcie_ram_wen_cont <=#D pcie_ram_wen_cont + 1;    	
//  end
//end
//
//
//always@(posedge sys_clk or negedge sys_rst_n)
//begin
//  if(!sys_rst_n)begin	
//    pcie_ram_ren_cont <=#D 16'd0;
//  end else if(curr_sta == DONE) begin      
//    pcie_ram_ren_cont <=#D 16'd0;  
//  end else if(pcie_ram_ren_reg) begin
//    pcie_ram_ren_cont <=#D pcie_ram_ren_cont + 1;    	
//  end
//end  
//
//
//assign read_pcie_enable = (pcie_ram_wen_cont > pcie_ram_ren_cont);

//---------------------------------------------------------------------
wire send_data_done;

always@(posedge sys_clk or negedge sys_rst_n)
begin
	if(~sys_rst_n)
		curr_sta <= IDLE;
	else
		curr_sta <= next_sta;		
end 

always@(*)
begin
	next_sta = curr_sta;

	case(curr_sta) 
	  IDLE:		
	    begin
	      if(start_analysis) begin	 
	        next_sta = GET_PKT_NUM; 
	      end	
		  end	
  
    GET_PKT_NUM:
      begin 
        if(counter1 == 8'd4) begin  
          next_sta = WAIT_ENABLE; 
        end 
      end 

    WAIT_ENABLE:
      begin
        if (pkt_num == 32'd0) begin 
          next_sta = DONE;
        end else begin
          next_sta = GET_DATA_NUM;       		
        end 
      end 

    GET_DATA_NUM:
      begin
        if(counter2 == 8'd4) begin 
          next_sta = GET_DATA;         
        end 
      end 

    GET_DATA:
      begin
        if(data_num_cont == data_num-1) begin
          next_sta = SEND_DATA;          	
        end 
      end  
    
    SEND_DATA:
      begin 
        if (send_data_done) begin 
          next_sta = JUDGE;
        end
      end
    JUDGE: 
      begin
        if(pkt_num_cont == pkt_num ) begin
          next_sta = DONE;          	
        end else begin
          next_sta = WAIT_ENABLE;          	
        end 		
      end 

    DONE:
      begin
      	  next_sta = IDLE;
      end 
  
  endcase
end   

//--------------------------------------------------------------
//GET_PKT_NUM

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    counter1 <=#D 8'd0; 
  end else if(counter1 == 8'd4) begin                  
    counter1 <=#D 8'd0;   
  end else if(curr_sta == GET_PKT_NUM) begin
    counter1 <=#D counter1 + 1;   	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pkt_num <=#D 32'd0;
  end else if(counter1 == 8'd4) begin
    pkt_num <=#D pcie_ram_rdat[31:0];
  end
end



//---------------------------------------------------------------
//GET_DATA_NUM

reg counter2_en;

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    counter2_en <=#D 1'b0;
  end else if(counter2 == 8'd4) begin
    counter2_en <=#D 1'b0;    
  end else if(curr_sta == GET_DATA_NUM) begin
    counter2_en <=#D 1'b1;      	
  end else begin
    counter2_en <=#D 1'b0;  	
  end 	 	
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    counter2 <=#D 8'd0; 
  end else if(counter2 == 8'd4) begin                  
    counter2 <=#D 8'd0;   
  end else if(counter2_en) begin
    counter2 <=#D counter2 + 1;   	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    data_num <=#D 32'd0;
  end else if(counter2 == 8'd4) begin
    data_num <=#D pcie_ram_rdat[31:0]; 
  end
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pkt_num_cont <=#D 32'd0;
  end else if(curr_sta == IDLE) begin
    pkt_num_cont <=#D 32'd0;  
  end else if(counter2 == 8'd4) begin
    pkt_num_cont <=#D pkt_num_cont + 1;  	
  end 	
end

//---------------------------------------------------------------------

//GET DATA


always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    get_data_ren <=#D 1'b0;
  end else if(data_num_cont == (data_num-1)) begin
    get_data_ren <=#D 1'b0;                 
  end else if(curr_sta == GET_DATA ) begin
    get_data_ren <=#D 1'b1;   	
  end else begin
    get_data_ren <=#D 1'b0;  	
  end 		
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    f0_get_data_ren <=#D 1'b0;
    f1_get_data_ren <=#D 1'b0;
    f2_get_data_ren <=#D 1'b0;
    f3_get_data_ren <=#D 1'b0;            
  end else begin
    f0_get_data_ren <=#D get_data_ren;
    f1_get_data_ren <=#D f0_get_data_ren;
    f2_get_data_ren <=#D f1_get_data_ren;
    f3_get_data_ren <=#D f2_get_data_ren;     
  end     
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    data_num_cont <=#D 16'd0;
  end else if(get_data_ren) begin
    data_num_cont <=#D data_num_cont + 1; 
  end else begin
    data_num_cont <=#D 16'd0;  	 
  end
end 

//-----------------------------------------------------------------------------

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_ren_reg <=#D 1'b0;
  end else if(counter1 == 8'd1) begin
    pcie_ram_ren_reg <=#D 1'b1;  
  end else if(counter2 == 8'd1) begin
    pcie_ram_ren_reg <=#D 1'b1;   	
  end else if(get_data_ren) begin
    pcie_ram_ren_reg <=#D 1'b1;    	
  end else begin
    pcie_ram_ren_reg <=#D 1'b0;  	
  end 		 	 
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_raddr_reg <=#D 16'd0;
  end else if(counter1 == 8'd1) begin
    pcie_ram_raddr_reg <=#D 16'd0;  
  end else if(counter2 == 8'd1) begin
    pcie_ram_raddr_reg <=#D pcie_ram_raddr_reg + 1; 		
  end else if(get_data_ren)	begin
    pcie_ram_raddr_reg <=#D pcie_ram_raddr_reg + 1;    	
  end 	
end





always@(posedge sys_clk)
begin
  if(curr_sta == WAIT_ENABLE) begin
    channel_fifo_free_0 <=#D 1'b1;
  end else if(~f1_get_data_ren && f2_get_data_ren) begin
    channel_fifo_free_0 <=#D 1'b0;  	
  end 	
end




always@(posedge sys_clk )
begin
    f0_channel_fifo_free_0 <=#D channel_fifo_free_0;
    // f0_channel_fifo_free_1 <=#D channel_fifo_free_1;
    // f0_channel_fifo_free_2 <=#D channel_fifo_free_2;
    // f0_channel_fifo_free_3 <=#D channel_fifo_free_3; 	
end




//---------------------------------------------------------------------------------

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    wen_0 <=#D 1'b0;
  end else if( channel_fifo_free_0 && f2_get_data_ren) begin
    wen_0 <=#D 1'b1;  
  end else begin
    wen_0 <=#D 1'b0;  	
  end 	
end



always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    wdat_0 <=#D 128'd0;  
  end else if(  channel_fifo_free_0 && f2_get_data_ren) begin
    wdat_0 <=#D pcie_ram_rdat;    
  end
end






assign start_read_fifo_0 = ~channel_fifo_free_0 && f0_channel_fifo_free_0;




fifo_256x128_1024x32 u0_channel_fifo (
  .clk          (sys_clk      ),
  .din          (wdat_0       ),
  .wr_en        (wen_0        ),
  .rd_en        (pkt_vld_0_reg),
  .dout         (f0_pkt_data_0),
  .full         (wrfull_0     ),
  .empty        (rdempty_0    ),
  .rd_data_count(rd_data_count_0),
  .wr_data_count(wr_data_count_0)
);

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    f0_start_read_fifo_0 <=#D 1'b0;
  end else if(start_read_fifo_0) begin
    f0_start_read_fifo_0 <=#D 1'b1;  
  end else if(matrix_enable_0) begin
    f0_start_read_fifo_0 <=#D 1'b0;
  end
end 


assign  start_one_pkt_0 = f0_start_read_fifo_0 && matrix_enable_0;


always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pkt_sop_0_reg <=#D 1'b0;
  end else if(start_one_pkt_0) begin
    pkt_sop_0_reg <=#D 1'b1;  
  end else begin
    pkt_sop_0_reg <=#D 1'b0;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin 	
    pkt_vld_0_reg <=#D 1'b0; 
  end else if(start_one_pkt_0) begin
    pkt_vld_0_reg <=#D 1'b1;   
  end else if(pkt_eop_0_reg) begin
    pkt_vld_0_reg <=#D 1'b0; 
  end 
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pkt_eop_0_reg <=#D 1'b0;
  end else if(rd_data_count_0[9:0] == 10'd2 && ~wen_0) begin        
    pkt_eop_0_reg <=#D 1'b1;  
  end else begin
    pkt_eop_0_reg <=#D 1'b0;  	
  end 	
end


assign    pkt_data_0  = (pkt_vld_0_reg)? f0_pkt_data_0: 32'd0;
assign    pkt_sop_0   =  pkt_sop_0_reg;
assign    pkt_eop_0   =  pkt_eop_0_reg;
assign    pkt_vld_0   =  pkt_vld_0_reg;

assign send_data_done = pkt_eop_0_reg;

//==============================debug===========================//
 (* mark_debug = "true" *) reg error_flag;
 (* mark_debug = "true" *) reg error_flag_0;

always @(posedge sys_clk or negedge sys_rst_n )
begin 
  if (!sys_rst_n) begin 
    error_flag <= 1'b0;
  end else if (counter2 == 8'd4 && pcie_ram_rdat[31:0] >= 32'h000fffff ) begin 
    error_flag <= 1'b1;
  end else begin 
    error_flag <= 1'b0;
  end
end

always @(posedge sys_clk or negedge sys_rst_n )
begin 
  if (!sys_rst_n) begin 
    error_flag_0 <= 1'b0;
  end else if (curr_sta == GET_DATA && data_num >= 32'h000fffff) begin 
    error_flag_0 <= 1'b1;
  end else begin 
    error_flag_0 <= 1'b0;
  end
end





assign    pcie_ram_ren   = pcie_ram_ren_reg;

assign    pcie_ram_raddr = pcie_ram_raddr_reg;

assign    get_data_done  = (curr_sta == DONE);


endmodule
