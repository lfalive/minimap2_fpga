/*********************************************************************
//  Author:    jyb
//  Filename:  
//  Modified:
//  Version:   1.0
//
//  Description:
//
//  Copyright (c) 2017 Test.
//
//  All Rights Reserved.
//
//
// -------------------------------------------------------------------
//  Modification History:
//
//  Date                  Who            Description of change
//  ------------------------------------------------------------------
//  2017-05-22            jyb            initial version
//
**********************************************************************/
`timescale 1ns/1ps
`default_nettype none


module test_pkt(
//input
sys_clk,sys_rst_n,matrix_enable,pcie_write_done,pcie_ram_rdat,
//output
get_data_done,pcie_ram_ren,pcie_ram_raddr,pkt_data,pkt_sop,pkt_eop,pkt_vld
	);

/*---------------------------------------------------------------------*\
                         parameter description 
\*---------------------------------------------------------------------*/
parameter D = 0;

parameter IDLE          = 8'b0000_0001;
parameter GET_PKT_NUM   = 8'b0000_0010;
parameter WAIT_ENABLE   = 8'b0000_0100;
parameter GET_DATA_NUM  = 8'b0000_1000;
parameter GET_DATA      = 8'b0001_0000;
parameter JUDGE         = 8'b0010_0000;
parameter DONE          = 8'b0100_0000;
/*---------------------------------------------------------------------*\
                         port description 
\*---------------------------------------------------------------------*/
//global signal
input   wire            sys_clk;
input   wire            sys_rst_n;

input   wire            matrix_enable;
input   wire            pcie_write_done;     
output  wire            get_data_done;

output  wire            pcie_ram_ren; 
output  wire  [15:0]    pcie_ram_raddr;
input   wire  [31:0]    pcie_ram_rdat;

output  wire  [31:0]    pkt_data;
output  wire            pkt_sop;
output  wire            pkt_eop;
output  wire            pkt_vld;

/*---------------------------------------------------------------------*\
                         reg/wire description 
\*---------------------------------------------------------------------*/

reg       [7:0]     curr_sta;
reg       [7:0]     next_sta;

reg                 pcie_ram_ren_reg; 
reg       [15:0]    pcie_ram_raddr_reg;



reg       [7:0]     counter1;
reg       [31:0]    pkt_num;
reg       [31:0]    pkt_num_cont;

reg       [7:0]     counter2;
reg       [31:0]    data_num;

reg                 get_data_ren;
reg                 f0_get_data_ren;
reg                 f1_get_data_ren;
reg                 f2_get_data_ren;
reg                 f3_get_data_ren;
reg       [15:0]    data_num_cont;

reg       [7:0]     counter3;   

reg                 pkt_sop_reg;
reg                 pkt_eop_reg;

/*---------------------------------------------------------------------*\
                         main code 
\*---------------------------------------------------------------------*/

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
	      if(pcie_write_done) begin	 
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
      	if(matrix_enable) begin
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
        if(data_num_cont == (data_num-1)) begin
          next_sta = JUDGE;          	
        end 
      end  
 
 
    JUDGE: 
      begin
        if(counter3 == 8'd4 && pkt_num_cont == pkt_num) begin
          next_sta = DONE;          	
        end else if(counter3 == 8'd4) begin
          next_sta = WAIT_ENABLE;          	
        end 		
      end 


    DONE:
      begin
      	  next_sta = IDLE;
      end 
  
  endcase
end   

//------------------------------------------------------------------------

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
    pkt_num <=#D pcie_ram_rdat; 
  end
end

//------------------------------------------------------------------------

//GET_DATA_NUM

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    counter2 <=#D 8'd0; 
  end else if(counter2 == 8'd4) begin                  
    counter2 <=#D 8'd0;   
  end else if(curr_sta == GET_DATA_NUM) begin
    counter2 <=#D counter2 + 1;   	
  end 	
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    data_num <=#D 32'd0;
  end else if(counter2 == 8'd4) begin
    data_num <=#D pcie_ram_rdat; 
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

//------------------------------------------------------------------------

//GET DATA

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    get_data_ren <=#D 1'b0;
  end else if(data_num_cont == (data_num-1)) begin
    get_data_ren <=#D 1'b0;                 
  end else if(curr_sta == GET_DATA) begin
    get_data_ren <=#D 1'b1;   	
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

//-------------------------------------------------------------------------

//JUDGE

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    counter3 <=#D 8'd0;
  end else if(counter3 == 8'd4) begin
    counter3 <=#D 8'd0;  	 
  end else if(curr_sta == JUDGE) begin
    counter3 <=#D counter3 + 1;   
  end
end

//-------------------------------------------------------------------------


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


//----------------------------------------------------------


always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pkt_sop_reg <=#D 1'b0;
  end else if(f1_get_data_ren && ~f2_get_data_ren) begin
    pkt_sop_reg <=#D 1'b1;  
  end else begin
    pkt_sop_reg <=#D 1'b0;  	
  end
end 


always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pkt_eop_reg <=#D 1'b0;
  end else if(~f0_get_data_ren && f1_get_data_ren) begin
    pkt_eop_reg <=#D 1'b1;  
  end else begin
    pkt_eop_reg <=#D 1'b0;  	
  end 	
end


assign    pkt_sop  = pkt_sop_reg;

assign    pkt_eop  = pkt_eop_reg;

assign    pkt_vld  = f2_get_data_ren;

assign    pkt_data = (f2_get_data_ren)? pcie_ram_rdat : 32'd0;

assign    get_data_done = (curr_sta == DONE);

assign    pcie_ram_ren  = pcie_ram_ren_reg;

assign    pcie_ram_raddr = pcie_ram_raddr_reg;


endmodule