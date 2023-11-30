////////////////////////////////////////////////////////////////////////////
//-- (c) Copyright 2012 - 2013 Xilinx, Inc. All rights reserved.
//--
//-- This file contains confidential and proprietary information
//-- of Xilinx, Inc. and is protected under U.S. and
//-- international copyright and other intellectual property
//-- laws.
//--
//-- DISCLAIMER
//-- This disclaimer is not a license and does not grant any
//-- rights to the materials distributed herewith. Except as
//-- otherwise provided in a valid license issued to you by
//-- Xilinx, and to the maximum extent permitted by applicable
//-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//-- (2) Xilinx shall not be liable (whether in contract or tort,
//-- including negligence, or under any other theory of
//-- liability) for any loss or damage of any kind or nature
//-- related to, arising under or in connection with these
//-- materials, including for any direct, or any indirect,
//-- special, incidental, or consequential loss or damage
//-- (including loss of data, profits, goodwill, or any type of
//-- loss or damage suffered as a result of any action brought
//-- by a third party) even if such damage or loss was
//-- reasonably foreseeable or Xilinx had been advised of the
//-- possibility of the same.
//--
//-- CRITICAL APPLICATIONS
//-- Xilinx products are not designed or intended to be fail-
//-- safe, or for use in any application requiring fail-safe
//-- performance, such as life-support or safety devices or
//-- systems, Class III medical devices, nuclear facilities,
//-- applications related to the deployment of airbags, or any
//-- other applications that could lead to death, personal
//-- injury, or severe property or environmental damage
//-- (individually and collectively, "Critical
//-- Applications"). Customer assumes the sole risk and
//-- liability of any use of Xilinx products in Critical
//-- Applications, subject only to applicable laws and
//-- regulations governing limitations on product liability.
//--
//-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//-- PART OF THIS FILE AT ALL TIMES.
////////////////////////////////////////////////////////////////////////////
//
// AXI4 Master Example
//
// The purpose of this design is to provide a high-throughput AXI4 example
// and AXI4 throughput demonstration.
//
// The example user application performs a simple memory
// test through continuous burst writes to memory, followed by burst
// reads.
//
// To modify this example for other applications, edit/remove the logic
// associated with the 'Example' section comments. For clarity, most
// transfer qualifiers are left as constants, but can be easily added
// to their associated channels
//
////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

`define C_M_AXI_ADDR_WIDTH 32

module axi_master #(
  // Transaction number is the number of write and read transactions the master
  // will perform as a part of this example memory test.
  // Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
  parameter                integer C_BURST_LEN              = 16           ,
  parameter                integer C_M_AXI_DATA_WIDTH       = 512          ,
  parameter                        DDR_UP_ADDR_START        = 32'h90000000 , //up the result
  parameter                        DDR_UP_ADDR_END          = 32'ha0000000 ,
  parameter                        DDR_DOWN_ADDR_START      = 32'h00000000 , // down the result data
  parameter                        DDR_DOWN_ADDR_END        = 32'h80000000 ,
  parameter                        WRITE_C_TRANSACTIONS_NUM = 4            , // have to less than 16 WRITE PKG大小
  parameter                        READ_C_TRANSACTIONS_NUM  = 128,   //READ数据包大小128K
  parameter                        RESULT_DATA_LENGTH       = 512
) (
  // Asserts when write transactions are complet
  // output wire WCOMPLETE,
  // Asserts when read transactions are complete
  // output wire RCOMPLETE,
  // System Signals
  // System Signals
  input  wire                            M_AXI_ACLK   ,
  input  wire                            M_AXI_ARESETN,
  input  wire                            core_clk     , //slow clk is read result clk
  input  wire                            core_rst_n   ,
  output wire [                    31:0] down_head    ,
  output wire [                    31:0] up_tail      ,
(* mark_debug = "true" *)  input  wire [                    31:0] down_cnt     ,
  (* mark_debug = "true" *)input  wire [                    31:0] up_cnt       ,
  input  wire [                    31:0] reg_rsv0     ,

  output wire  [                    31:0] sop0_cnt     ,
  output wire  [                    31:0] sop1_cnt     ,
  output wire  [                    31:0] sop2_cnt     ,
  output wire  [                    31:0] sop3_cnt     ,
  output wire  [                    31:0] result_cnt   ,
  // Master Interface Write Address
  output wire [ `C_M_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR ,
  output wire [                     7:0] M_AXI_AWLEN  ,
  output wire [                     2:0] M_AXI_AWSIZE ,
  output wire [                     1:0] M_AXI_AWBURST,
  //  output wire M_AXI_AWLOCK,
  //  output wire [3:0] M_AXI_AWCACHE,
  //  output wire [2:0] M_AXI_AWPROT,
  //  output wire [3:0] M_AXI_AWQOS,
  output wire                            M_AXI_AWVALID,
  input  wire                            M_AXI_AWREADY,
  // Master Interface Write Data
  output wire [  C_M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA  ,
  output wire [C_M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB  ,
  output wire                            M_AXI_WLAST  ,
  output wire                            M_AXI_WVALID ,
  input  wire                            M_AXI_WREADY ,
  // Master Interface Write Response
  input  wire [                     1:0] M_AXI_BRESP  ,
  input  wire                            M_AXI_BVALID ,
  output wire                            M_AXI_BREADY ,
  // Master Interface Read Address
  (* mark_debug = "true" *)   output wire [`C_M_AXI_ADDR_WIDTH-1:0]      M_AXI_ARADDR,
  output wire [                     7:0] M_AXI_ARLEN  ,
  output wire [                     2:0] M_AXI_ARSIZE ,
  output wire [                     1:0] M_AXI_ARBURST,
  //  output wire [1:0] M_AXI_ARLOCK,
  //  output wire [3:0] M_AXI_ARCACHE,
  //  output wire [2:0] M_AXI_ARPROT,
  //  output wire [3:0] M_AXI_ARQOS,
  (* mark_debug = "true" *)   output wire M_AXI_ARVALID,
  (* mark_debug = "true" *)    input  wire M_AXI_ARREADY,
  // Master Interface Read Data
  (* mark_debug = "true" *)   input  wire [C_M_AXI_DATA_WIDTH-1:0]      M_AXI_RDATA,
  input  wire [                     1:0] M_AXI_RRESP  ,
  input  wire                            M_AXI_RLAST  ,
  (* mark_debug = "true" *)    input  wire M_AXI_RVALID,
  (* mark_debug = "true" *)    output wire M_AXI_RREADY
);

parameter IDLE         = 5'b00001;
parameter WAIT_START   = 5'b00010;
parameter SEND_ADDR    = 5'b00100;
parameter RECEIVE_DATA = 5'b01000;
parameter CHECK_CONT   = 5'b10000;
   


parameter MAX_TIME_OUT = 32'd4000000;

parameter PAC_DEPTH    = 2 *C_BURST_LEN * WRITE_C_TRANSACTIONS_NUM;


parameter READ_PAC_OFF  = 32'd1024 * READ_C_TRANSACTIONS_NUM;
parameter WRITE_PAC_OFF = 32'd1024 * WRITE_C_TRANSACTIONS_NUM;

parameter UP_DDR_SUM    = (DDR_UP_ADDR_END - DDR_UP_ADDR_START)/WRITE_PAC_OFF;

parameter W_IDLE       = 6'b000001;
parameter W_WAIT_START = 6'b000010; 
parameter W_SEND_ADDR  = 6'b000100;
parameter W_WAIT_FIFO  = 6'b001000;
parameter W_WRITE_DATA = 6'b010000;
parameter W_CHECK_CONT = 6'b100000;




// Base address of targeted slave
localparam  C_TARGET_SLAVE_BASE_ADDR = `C_M_AXI_ADDR_WIDTH'h00000000;

// Master waits for C_START_COUNT number of clock cycles
// before initiating a write transaction
localparam integer  C_START_COUNT            = 22;

// AXI4 internal temp signals
reg [`C_M_AXI_ADDR_WIDTH-1:0] axi_awaddr;
reg axi_awvalid;
wire [C_M_AXI_DATA_WIDTH-1:0] axi_wdata;
reg axi_wlast;
reg axi_wvalid;
reg axi_bready;
reg [`C_M_AXI_ADDR_WIDTH-1:0] axi_araddr;
reg axi_arvalid;
reg axi_rready;

// function called clogb2 that returns an integer which has the
// value of the ceiling of the log base 2.
function integer clogb2 (input integer bit_depth);
begin
  for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
    bit_depth = bit_depth >> 1;
  end
endfunction

  // Example user application signals


  localparam integer WAIT_COUNT_BITS = clogb2(C_START_COUNT-1);
  reg  [WAIT_COUNT_BITS-1:0] wait_counter;


  localparam integer LP_BEAT_NUM = clogb2(C_BURST_LEN-1);
  // write beat count in a burst
  reg [LP_BEAT_NUM:0] write_index;
  // read beat count in a burst
  reg [LP_BEAT_NUM:0] read_index;

  // total number of burst transfers is master length divided by burst length and burst size
  localparam integer WRITE_C_NO_BURSTS_REQ = clogb2(WRITE_C_TRANSACTIONS_NUM);
  localparam integer READ_C_NO_BURSTS_REQ  = clogb2(READ_C_TRANSACTIONS_NUM) ;  

  // The burst counters are used to track the number of burst transfers of
  // C_BURST_LEN burst length needed to transfer 2^C_M_AXI_MASTER_LENGTH bytes of data
  (* mark_debug = "true" *)reg  [WRITE_C_NO_BURSTS_REQ : 0] write_burst_counter;
  reg  [READ_C_NO_BURSTS_REQ  : 0] read_burst_counter;

  wire start_single_burst_write;
  wire start_single_burst_read;

  reg burst_write_active;
  reg burst_read_active;
  // Local address counters
  reg [8:0] araddr_offset = 'b0;
  reg [8:0] awaddr_offset = 'b0;

  reg [C_M_AXI_DATA_WIDTH-1:0] expected_rdata;

  // Interface response error flags
  wire write_resp_error;
  wire read_resp_error;

  wire wnext;
  wire rnext;

  // Example State machine to initialize counter, initialize write transactions,
  // initialize read transactions and comparison of read data with the
  // written data words.
                                      // of the written data with the read data

wire pkt_analysis_done;


wire               matrix_enable_0;
wire               matrix_enable_1;
wire               matrix_enable_2;
wire               matrix_enable_3;


 wire               pkt_sop_0;
 wire               pkt_eop_0;
 wire               pkt_vld_0;
 wire    [31:0]     pkt_dat_0;

wire               pkt_sop_1;
wire               pkt_eop_1;
wire               pkt_vld_1;
wire    [31:0]     pkt_dat_1;      

wire               pkt_sop_2;
wire               pkt_eop_2;
wire               pkt_vld_2;
wire    [31:0]     pkt_dat_2;

wire               pkt_sop_3;
wire               pkt_eop_3;
wire               pkt_vld_3;
wire    [31:0]     pkt_dat_3;  




wire signal_a_in_fifo_full;
wire signal_a_in_fifo_empty;


wire signal_b_in_fifo_full;
wire signal_b_in_fifo_empty;
wire sys_curr_reset ;
wire core_curr_reset;


/////////////////
//I/O Connections
/////////////////
////////////////////
//Write Address (AW)
////////////////////

//  assign M_AXI_AWID = 'b0;

  assign M_AXI_AWADDR = C_TARGET_SLAVE_BASE_ADDR + axi_awaddr;

  assign M_AXI_AWLEN = C_BURST_LEN - 1;

  assign M_AXI_AWSIZE = clogb2((C_M_AXI_DATA_WIDTH/8)-1);

  assign M_AXI_AWBURST = 2'b01;


  assign M_AXI_AWVALID = axi_awvalid;

///////////////
//Write Data(W)
///////////////
  //assign M_AXI_WDATA = axi_wdata;

//All bursts are complete and aligned in this example
  assign M_AXI_WSTRB = {(C_M_AXI_DATA_WIDTH/8){1'b1}};
  assign M_AXI_WLAST = axi_wlast;
//  assign M_AXI_WUSER = 'b0;
  assign M_AXI_WVALID = axi_wvalid;

////////////////////
//Write Response (B)
////////////////////
  assign M_AXI_BREADY = axi_bready;

///////////////////
//Read Address (AR)
///////////////////
  assign M_AXI_ARADDR = C_TARGET_SLAVE_BASE_ADDR + axi_araddr;

  assign M_AXI_ARLEN = C_BURST_LEN - 1;

  assign M_AXI_ARSIZE = clogb2((C_M_AXI_DATA_WIDTH/8)-1);

  assign M_AXI_ARBURST = 2'b01;

  assign M_AXI_ARVALID = axi_arvalid;

////////////////////////////
//Read and Read Response (R)
////////////////////////////
  assign M_AXI_RREADY = axi_rready;

////////////////////
//Example design I/O
////////////////////

///////////////////////
//Write Address Channel
///////////////////////


 (* mark_debug = "true" *) reg pcie_mem_free ;
wire curr_reset;

assign curr_reset = reg_rsv0[0];


     

always@(posedge M_AXI_ACLK) 
begin
  if(!M_AXI_ARESETN) begin 
    pcie_mem_free <= 1'b1;
  end else if ((read_burst_counter == READ_C_TRANSACTIONS_NUM - 1) && M_AXI_ARREADY && axi_arvalid) begin 
    pcie_mem_free <= 1'b0;
  end else if (pkt_analysis_done) begin 
    pcie_mem_free <= 1'b1;
  end 
end




(* mark_debug = "true" *) reg [4:0] rd_cur_sta;
reg [4:0] rd_next_sta;




always @ ( posedge M_AXI_ACLK)
  begin
    if (!M_AXI_ARESETN | curr_reset) begin 
    	rd_cur_sta <= IDLE;
    end else begin 
    	rd_cur_sta <= rd_next_sta;
    end
end

always @ (*)
begin
  rd_next_sta = rd_cur_sta;
  case (rd_cur_sta) 
  IDLE: begin 
          if (pcie_mem_free && down_cnt > 0) begin 
          rd_next_sta = WAIT_START;
        end
      end

  WAIT_START : begin
  	rd_next_sta = SEND_ADDR;
  end 

  SEND_ADDR : begin 
  	if (M_AXI_ARVALID && M_AXI_ARREADY) begin 
  		rd_next_sta = RECEIVE_DATA;
  	end
  end

  RECEIVE_DATA : begin 
  	if (rnext && read_index == C_BURST_LEN - 1) begin
  		rd_next_sta = CHECK_CONT;
  	end
  end

  CHECK_CONT : begin 
  	if (read_burst_counter == 'b0 ) begin 
  		rd_next_sta = IDLE;
  	end else begin 
  		rd_next_sta = WAIT_START;
  	end
  end
  endcase
end

assign start_single_burst_read = (rd_cur_sta == WAIT_START) ;



always @(posedge M_AXI_ACLK)
  begin

    if (M_AXI_ARESETN == 0 )
      begin
        axi_arvalid <= 1'b0;
      end
    // If previously not valid , start next transaction
    else if (~axi_arvalid && start_single_burst_read)
      begin
        axi_arvalid <= 1'b1;
      end
    else if (M_AXI_ARREADY && axi_arvalid)
      begin
        axi_arvalid <= 1'b0;
      end
end


// Next address after ARREADY indicates previous address acceptance
  always @(posedge M_AXI_ACLK)
  begin
    if (M_AXI_ARESETN == 0 | curr_reset) begin
        axi_araddr <= 'b0;
    end else if (M_AXI_ARREADY && axi_arvalid && (axi_araddr == DDR_DOWN_ADDR_END - 32'd1024)) begin
        axi_araddr <= 'b0;
    end else if (M_AXI_ARREADY && axi_arvalid) begin
        axi_araddr <= axi_araddr + 32'd1024 ;
    end else 
        axi_araddr <= axi_araddr;
  end


//////////////////////////////////
//Read Data (and Response) Channel
//////////////////////////////////

 // Forward movement occurs when the channel is valid and ready
  assign rnext = M_AXI_RVALID && axi_rready;


/* Burst length counter. Uses extra counter register bit to indicate terminal
 count to reduce decode logic */
  always @(posedge M_AXI_ACLK)
  begin
    if (M_AXI_ARESETN == 0 || start_single_burst_read)
      begin
        read_index <= 0;
      end
    else if (rnext && (read_index != C_BURST_LEN-1))
      begin
        read_index <= read_index + 1;
      end
    else
      read_index <= read_index;
  end


/*
 The Read Data channel returns the results of the read request
 In this example the data checker is always able to accept
 more data, so no need to throttle the RREADY signal
 */
always @(posedge M_AXI_ACLK)
begin
    if (M_AXI_ARESETN == 0 )
      begin
        axi_rready <= 1'b0;
      end
    // accept/acknowledge rdata/rresp with axi_rready by the master
    // when M_AXI_RVALID is asserted by slave
    else if (M_AXI_RVALID && ~axi_rready)begin
        axi_rready <= 1'b1;
    end else if (rnext && read_index == C_BURST_LEN-1)  begin
        axi_rready <= 1'b0;
    end
end


always @(posedge M_AXI_ACLK)
  begin
    if (M_AXI_ARESETN == 0) begin 
        read_burst_counter <= 'b0;
    end else if (M_AXI_ARREADY && M_AXI_ARVALID && (read_burst_counter == READ_C_TRANSACTIONS_NUM - 1))begin 
    	read_burst_counter <= 'b0;
    end else if (M_AXI_ARREADY && axi_arvalid) begin 
    	read_burst_counter <= read_burst_counter + 1'b1;
    end
end
//--------------------pkt_analysis_top------------------//

pkt_analysis_top u_pkt_analysis_top(
    .sys_clk                 (M_AXI_ACLK               ),
    .sys_rst_n               (M_AXI_ARESETN              ),

    .ddr4_rdat_vld            (rnext             ),
    .ddr4_rdat                (M_AXI_RDATA       ),

    .matrix_enable_0          (matrix_enable_0       ),
    .matrix_enable_1          (matrix_enable_1       ),
    .matrix_enable_2          (matrix_enable_2       ),
    .matrix_enable_3          (matrix_enable_3       ),

    .pcie_ram_free            (pkt_analysis_done     ),

    .pkt_data_0               (pkt_dat_0              ),
    .pkt_sop_0                (pkt_sop_0              ), 
    .pkt_eop_0                (pkt_eop_0              ), 
    .pkt_vld_0                (pkt_vld_0              ), 
                                                     
    .pkt_data_1               (pkt_dat_1              ),
    .pkt_sop_1                (pkt_sop_1              ), 
    .pkt_eop_1                (pkt_eop_1              ), 
    .pkt_vld_1                (pkt_vld_1              ), 
                                             
    .pkt_data_2               (pkt_dat_2              ),
    .pkt_sop_2                (pkt_sop_2              ), 
    .pkt_eop_2                (pkt_eop_2              ), 
    .pkt_vld_2                (pkt_vld_2              ), 
                                             
    .pkt_data_3               (pkt_dat_3              ),
    .pkt_sop_3                (pkt_sop_3              ), 
    .pkt_eop_3                (pkt_eop_3              ), 
    .pkt_vld_3                (pkt_vld_3              )    
                                             


);

wire [RESULT_DATA_LENGTH-1 : 0] result0_fifo_rdat ;
wire         result0_fifo_empty;
wire         result0_fifo_rden ;

wire [RESULT_DATA_LENGTH-1 : 0] result1_fifo_rdat ;
wire         result1_fifo_empty;
wire         result1_fifo_rden ;

(* mark_debug = "true" *)wire start_0, vld_0, empty_0, eop_0;
wire [63:0] data_0;

(* mark_debug = "true" *)wire start_1, vld_1, empty_1, eop_1;
wire [63:0] data_1;

calculate_ctl_top u0_calculate_ctl_top (
 .core_clk            (core_clk          ),
 .core_rst_n          (core_rst_n        ),
  .sys_clk             (M_AXI_ACLK        ),
  .sys_rst_n           (M_AXI_ARESETN     ),
  
 .result_fifo_rdat    (result0_fifo_rdat ),
 .result_fifo_empty   (result0_fifo_empty),
 .result_fifo_rden    (result0_fifo_rden ),
  
  
 .matrix_memory_sop_0 (pkt_sop_0         ),
 .matrix_memory_eop_0 (pkt_eop_0         ),
 .matrix_memory_vld_0 (pkt_vld_0         ),
 .matrix_memory_data_0(pkt_dat_0         ),
 .pkt_enable_0        (matrix_enable_0   ),
  
 .matrix_memory_sop_1 (pkt_sop_1         ),
 .matrix_memory_eop_1 (pkt_eop_1         ),
 .matrix_memory_vld_1 (pkt_vld_1         ),
 .matrix_memory_data_1(pkt_dat_1         ),
 .pkt_enable_1        (matrix_enable_1   ),

  .rd_start          (start_0            ),
  .vld_out           (vld_0              ),
  .empty_out         (empty_0            ),
  .eop_out           (eop_0              ),
  .data_out          (data_0             )
 );
 

calculate_ctl_top u1_calculate_ctl_top (
 .core_clk            (core_clk          ),
 .core_rst_n          (core_rst_n        ),
 .sys_clk             (M_AXI_ACLK        ),
 .sys_rst_n           (M_AXI_ARESETN     ),

  
 .result_fifo_rdat    (result1_fifo_rdat ),
 .result_fifo_empty   (result1_fifo_empty),
 .result_fifo_rden    (result1_fifo_rden ),
  
 .matrix_memory_sop_0 (pkt_sop_2         ),
 .matrix_memory_eop_0 (pkt_eop_2         ),
 .matrix_memory_vld_0 (pkt_vld_2         ),
 .matrix_memory_data_0(pkt_dat_2         ),
 .pkt_enable_0        (matrix_enable_2   ),
  
 .matrix_memory_sop_1 (pkt_sop_3         ),
 .matrix_memory_eop_1 (pkt_eop_3         ),
 .matrix_memory_vld_1 (pkt_vld_3         ),
 .matrix_memory_data_1(pkt_dat_3         ),
 .pkt_enable_1        (matrix_enable_3   ),

  .rd_start          (start_1           ),
  .vld_out           (vld_1             ),
  .empty_out         (empty_1           ),
  .eop_out           (eop_1             ),
  .data_out          (data_1            )
 );

//-------------------------WRITE----------------------//

(* mark_debug = "true" *)reg  [ 63:0] fifo_data_in     ;
(* mark_debug = "true" *)reg          fifo_write_en    ;
(* mark_debug = "true" *)wire         fifo_read_en     ;
(* mark_debug = "true" *)wire [511:0] result_fifo_rdat ;
wire         full             ;
 (* mark_debug = "true" *) wire         result_fifo_empty;
 (* mark_debug = "true" *) wire [  9:0] rd_data_count    ;
 (* mark_debug = "true" *) wire [ 10:0] wr_data_count    ;
wire         fifo_almost_full ;

wire [63:0] f0_fifo_data_in ;
wire         f0_fifo_write_en;
reg         fifo_select_cont;

reg [3:0] current_state;
reg [3:0] next_state   ;

reg [10:0] write_en_cont;
reg [ 3:0] burst_cont   ;
reg        ddr4_free    ;


always @(posedge core_clk or negedge core_rst_n) 
begin 
 if (!core_rst_n) begin 
   fifo_select_cont <= 1'b0;
 end else begin 
   fifo_select_cont <= fifo_select_cont + 1'b1;
 end // end else
end


assign result0_fifo_rden = (~result0_fifo_empty && ~fifo_almost_full && (fifo_select_cont == 1'b0));
assign result1_fifo_rden = (~result1_fifo_empty && ~fifo_almost_full && (fifo_select_cont == 1'b1));

/*always @(posedge core_clk or negedge core_rst_n) 
begin 
 if (!core_rst_n) begin 
   f0_fifo_write_en <= 1'b0;
 end else begin 
   f0_fifo_write_en <= result0_fifo_rden || result1_fifo_rden ;
 end // end else
end*/

/*always @(posedge core_clk or negedge core_rst_n) 
begin 
 if (!core_rst_n) begin 
   f0_fifo_data_in <= 512'd0;
 end else if (result0_fifo_rden) begin 
   f0_fifo_data_in <= result0_fifo_rdat;
 end else if (result1_fifo_rden) begin 
   f0_fifo_data_in <= result1_fifo_rdat;
 end // end else if 
end*/

fill_out_packge package(
  .core_clk   (core_clk     ),
  .core_rst_n (core_rst_n   ),

  .vld_0      (vld_0        ),
  .empty_0    (empty_0      ),
  .eop_0      (eop_0        ),
  .data_0     (data_0       ),

  .vld_1      (vld_1        ),
  .empty_1    (empty_1      ),
  .eop_1      (eop_1        ),
  .data_1     (data_1       ),

  .start_0    (start_0      ),
  .start_1    (start_1      ),

  .wr_en      (f0_fifo_write_en),
  .data_in    (f0_fifo_data_in )

  //unit_num_count  
);

/*fifo_512x256_256x512 u0 (
  .wr_clk       (core_clk         ),
  .rd_clk       (M_AXI_ACLK       ),
  .din          (fifo_data_in     ),
  .wr_en        (fifo_write_en    ),
  .rd_en        (fifo_read_en     ),
  .dout         (result_fifo_rdat ),
  .full         (full             ),
  .empty        (result_fifo_empty),
  .rd_data_count(rd_data_count    ),
  .wr_data_count(wr_data_count    )
);*/

/*fifo_512x512 u0 (
  .wr_clk       (core_clk         ),
  .rd_clk       (M_AXI_ACLK       ),
  .din          (fifo_data_in     ),
  .wr_en        (fifo_write_en    ),
  .rd_en        (fifo_read_en     ),
  .dout         (result_fifo_rdat ),
  .full         (full             ),
  .empty        (result_fifo_empty),
  .rd_data_count(rd_data_count    ),
  .wr_data_count(wr_data_count    )
);*/

fifo_512x256_64x2048 u0 (
  .wr_clk       (core_clk         ),
  .rd_clk       (M_AXI_ACLK       ),
  .din          (fifo_data_in     ),
  .wr_en        (fifo_write_en    ),
  .rd_en        (fifo_read_en     ),
  .dout         (result_fifo_rdat ),
  .full         (full             ),
  .empty        (result_fifo_empty),
  .rd_data_count(rd_data_count    ),
  .wr_data_count(wr_data_count    )
);

 (* mark_debug = "true" *) wire       pulldown_alldone;
wire       afifo_out       ;
wire       bfifo_out       ;
 (* mark_debug = "true" *) wire       core_pulldown   ;
 (* mark_debug = "true" *) reg  [5:0] wr_cur_sta      ;
reg  [5:0] wr_next_sta     ;

 (* mark_debug = "true" *) reg [31:0] counter_empty   ;
 (* mark_debug = "true" *) reg        all_done        ;
reg        en_counter_empty;

 (* mark_debug = "true" *) wire axi_pullup ;
 (* mark_debug = "true" *) wire core_pullup;

 

assign fifo_almost_full = (wr_data_count >= 11'd495);

always @(posedge core_clk or negedge core_rst_n)
begin 
 if (!core_rst_n) begin 
   en_counter_empty <= 1'b0;
 end else if (result0_fifo_rden || result1_fifo_rden) begin 
   en_counter_empty <= 1'b1;
 end else if (all_done) begin 
   en_counter_empty <= 1'b0;
 end 
end




always @(posedge core_clk or negedge core_rst_n)
begin 
 if (!core_rst_n)
   counter_empty <= 32'b0;
 else if (f0_fifo_write_en || all_done)
   counter_empty <= 32'b0;
 else if ((!f0_fifo_write_en) && en_counter_empty && counter_empty <= MAX_TIME_OUT) 
   counter_empty <= counter_empty + 32'b1;
end

always @(posedge core_clk or negedge core_rst_n)
begin 
 if (!core_rst_n)
   all_done <= 1'b0;
 else if (result0_fifo_rden || result1_fifo_rden)
   all_done <= 1'b0;
 else if (core_pulldown  && all_done ) 
   all_done <= 1'b0;
 else if (counter_empty >= MAX_TIME_OUT&& core_pullup && wr_data_count < 128 ) //result num < 32  32*256/8=1K 128*64/8=1K
   all_done <= 1'b1;
end

reg  [31:0] all_done_cnt    ;
reg  [31:0] axi_all_done_cnt;
wire        all_done_empty  ;
wire [31:0] fifo_out        ;

always@(posedge core_clk or negedge core_rst_n)
begin
  if(!core_rst_n)begin 
    fifo_write_en <= 1'b0;
  end else if (f0_fifo_write_en)begin
    fifo_write_en <= 1'b1;
  end else if (all_done && !fifo_almost_full) begin 
   fifo_write_en <= 1'b1;
  end else begin 
   fifo_write_en <= 1'b0;
  end
end

always@(posedge core_clk or negedge core_rst_n)
  begin
    if(!core_rst_n)begin
      fifo_data_in <= 64'd0;
    end else if (f0_fifo_write_en) begin
      // fifo_data_in <= {f0_fifo_data_in[7:0],f0_fifo_data_in[15:8],f0_fifo_data_in[23:16],f0_fifo_data_in[31:24],f0_fifo_data_in[39:32],f0_fifo_data_in[47:40],f0_fifo_data_in[55:48],f0_fifo_data_in[63:56],f0_fifo_data_in[71:64],f0_fifo_data_in[79:72],f0_fifo_data_in[87:80],f0_fifo_data_in[95:88],f0_fifo_data_in[103:96],f0_fifo_data_in[111:104],f0_fifo_data_in[119:112],f0_fifo_data_in[127:120]};
      //fifo_data_in <= f0_fifo_data_in;
      fifo_data_in <= {f0_fifo_data_in[7:0],f0_fifo_data_in[15:8],f0_fifo_data_in[23:16],f0_fifo_data_in[31:24],f0_fifo_data_in[39:32],f0_fifo_data_in[47:40],f0_fifo_data_in[55:48],f0_fifo_data_in[63:56]};
    end else if (all_done) begin
      fifo_data_in <= 64'hffff_ffff_ffff_ffff;
    end else begin
      fifo_data_in <= 64'd0;
    end
  end






assign pulldown_alldone = (wr_cur_sta == W_CHECK_CONT) && (write_burst_counter == 1'b0) ;
assign core_pulldown    = ~signal_a_in_fifo_empty;
assign axi_pullup       = (wr_cur_sta == W_WAIT_FIFO);
assign core_pullup      = ~signal_b_in_fifo_empty;

afifo_16x1 p0 (
  .wr_clk(M_AXI_ACLK                    ), // input wire wr_clk
  .rd_clk(core_clk                      ), // input wire rd_clk
  .din   (1'b1                          ), // input wire [0 : 0] din
  .wr_en (pulldown_alldone && ~signal_a_in_fifo_full), // input wire wr_en
  .rd_en (~signal_a_in_fifo_empty       ), // input wire rd_en
  .dout  (afifo_out                     ), // output wire [0 : 0] dout
  .full  (signal_a_in_fifo_full         ), // output wire full
  .empty (signal_a_in_fifo_empty        )  // output wire empty
); //wr_cur_sta == w_check_cont

afifo_16x1 p1 (
  .wr_clk(M_AXI_ACLK                    ), // input wire wr_clk
  .rd_clk(core_clk                      ), // input wire rd_clk
  .din   (1'b1                          ), // input wire [0 : 0] din
  .wr_en (axi_pullup && ~signal_b_in_fifo_full), // input wire wr_en
  .rd_en (~signal_b_in_fifo_empty       ), // input wire rd_en
  .dout  (bfifo_out                     ), // output wire [0 : 0] dout
  .full  (signal_b_in_fifo_full         ), // output wire full
  .empty (signal_b_in_fifo_empty        )  // output wire empty
); //wr_cur_sta == w_wait_fifo

//---------------------axi_bus-----------------------//

always @(posedge M_AXI_ACLK)
begin 
  if (up_cnt < UP_DDR_SUM - 1) begin 
		ddr4_free <= 1'b1;
	end else begin 
		ddr4_free <= 1'b0;
	end
end




always @(posedge M_AXI_ACLK)
begin 
	if (!M_AXI_ARESETN | curr_reset) begin 
		wr_cur_sta <= 6'b000001;
	end else begin 
		wr_cur_sta <= wr_next_sta;
	end 
end



always @(*)
begin 
	wr_next_sta = wr_cur_sta;
	case (wr_cur_sta)
		W_IDLE:begin 
			if (ddr4_free) begin 
				wr_next_sta = W_WAIT_FIFO;
			end
		end

		W_WAIT_FIFO: begin //0x80
			if (rd_data_count >= 10'd16) begin 
				wr_next_sta = W_WAIT_START;
			end
		end

		W_WAIT_START: begin //0x02
			wr_next_sta = W_SEND_ADDR;
		end


		W_SEND_ADDR: begin //04
			if (axi_awvalid && M_AXI_AWREADY) begin 
				wr_next_sta = W_WRITE_DATA;
			end
		end



		W_WRITE_DATA: begin //0x10
			if (wnext&& (write_index == C_BURST_LEN-1)) begin 
				wr_next_sta = W_CHECK_CONT;
			end
		end

		W_CHECK_CONT: begin //0x20
			if (write_burst_counter > 0) begin 
				wr_next_sta = W_WAIT_FIFO;
			end else if (write_burst_counter == 0) begin 
				wr_next_sta = W_IDLE;
			end 
		end
	endcase // wr_cur_sta
end

assign start_single_burst_write = wr_cur_sta == W_WAIT_START;
assign fifo_read_en = M_AXI_WVALID && M_AXI_WREADY && (!result_fifo_empty);




always @(posedge M_AXI_ACLK)
  begin

    if (M_AXI_ARESETN == 0 )
      begin
        axi_awvalid <= 1'b0;
      end
    // If previously not valid , start next transaction  wr_cur_sta posedge
    else if (~axi_awvalid && start_single_burst_write)
      begin
        axi_awvalid <= 1'b1;
      end
    /* Once asserted, VALIDs cannot be deasserted, so axi_awvalid
    must wait until transaction is accepted */
    else if (M_AXI_AWREADY && axi_awvalid)
      begin
        axi_awvalid <= 1'b0;
      end
end

always @(posedge M_AXI_ACLK)
  begin
    if (M_AXI_ARESETN == 0 | curr_reset == 1) begin
        axi_awaddr <= DDR_UP_ADDR_START;
    end else if (M_AXI_AWREADY && axi_awvalid && (axi_awaddr == DDR_UP_ADDR_END - 32'd1024) )begin 
    	axi_awaddr <= DDR_UP_ADDR_START;
    end else if (M_AXI_AWREADY && axi_awvalid) begin
        axi_awaddr <= axi_awaddr + 32'd1024;
    end
end

assign wnext = M_AXI_WREADY && axi_wvalid;

always @(posedge M_AXI_ACLK)
  begin
    if (M_AXI_ARESETN == 0 )
      begin
        axi_wvalid <= 1'b0;
      end
    // If previously not valid, start next transaction
    else if (~axi_wvalid && wr_cur_sta == W_WRITE_DATA)
      begin
        axi_wvalid <= 1'b1;
      end
    else if (wnext && axi_wlast)
      axi_wvalid <= 1'b0;
    else
      axi_wvalid <= axi_wvalid;
end

always @(posedge M_AXI_ACLK)
  begin
    if (M_AXI_ARESETN == 0 )
      begin
        axi_wlast <= 1'b0;
      end
    else if (((write_index == C_BURST_LEN-2 && C_BURST_LEN >= 2) && wnext) || (C_BURST_LEN == 1 ))
      begin
        axi_wlast <= 1'b1;
      end
    else if (wnext)
      axi_wlast <= 1'b0;
    else if (axi_wlast && C_BURST_LEN == 1)
      axi_wlast <= 1'b0;
    else
      axi_wlast <= axi_wlast;
end
/*
 Check for last read completion.
 This logic is to qualify the last read count with the final read
 response. This demonstrates how to confirm that a read has been
 committed.
 */


  always @(posedge M_AXI_ACLK)
  begin
    if (M_AXI_ARESETN == 0 || start_single_burst_write)
      begin
        write_index <= 0;
      end
    else if (wnext && (write_index != C_BURST_LEN-1))
      begin
        write_index <= write_index + 1;
      end
  end


always @(posedge M_AXI_ACLK)
  begin
    if (M_AXI_ARESETN == 0) begin
        write_burst_counter <= 'b0;
    end else if (M_AXI_AWREADY && axi_awvalid && (write_burst_counter == WRITE_C_TRANSACTIONS_NUM -1 )) begin 
    	write_burst_counter <= 'b0;
    end	else if (M_AXI_AWREADY && axi_awvalid) begin 
      write_burst_counter <= write_burst_counter + 1'b1;
    end 
end


//assign M_AXI_WDATA = result_fifo_rdat;

assign M_AXI_WDATA = {result_fifo_rdat[63:0],result_fifo_rdat[127:64],result_fifo_rdat[191:128],result_fifo_rdat[255:192],result_fifo_rdat[319:256],result_fifo_rdat[383:320],result_fifo_rdat[447:384],result_fifo_rdat[511:448]};

always @(posedge M_AXI_ACLK)
  begin
    if (M_AXI_ARESETN == 0 )
      begin
        axi_bready <= 1'b0;
      end
    else if (M_AXI_BVALID && ~axi_bready)
      begin
        axi_bready <= 1'b1;
      end
    else if (axi_bready)
      begin
        axi_bready <= 1'b0;
      end
end


reg [31:0] down_head_0;
reg [31:0] up_tail_0  ;

always @ (posedge M_AXI_ACLK)
begin 
	if (!M_AXI_ARESETN | curr_reset) begin 
		down_head_0 <= DDR_DOWN_ADDR_START;
	end else if (rd_cur_sta == CHECK_CONT && read_burst_counter == 'b0 && down_head_0 == DDR_DOWN_ADDR_END - READ_PAC_OFF) begin
		down_head_0 <= DDR_DOWN_ADDR_START;
	end else if (rd_cur_sta == CHECK_CONT && read_burst_counter == 'b0 ) begin 
		down_head_0 <= down_head_0 + READ_PAC_OFF;
	end
end

always @ (posedge M_AXI_ACLK)
begin 
	if (!M_AXI_ARESETN | curr_reset) begin 
		up_tail_0 <= DDR_UP_ADDR_START;
	end else if (wr_cur_sta == W_CHECK_CONT && write_burst_counter == 'b0 && up_tail_0 == DDR_UP_ADDR_END - WRITE_PAC_OFF) begin 
		up_tail_0 <= DDR_UP_ADDR_START;
	end else if (wr_cur_sta == W_CHECK_CONT && write_burst_counter == 'b0) begin 
		up_tail_0 <= up_tail_0 + WRITE_PAC_OFF;
	end
end




assign down_head = down_head_0;
assign up_tail = up_tail_0;



////////////////////
//debug
////////////////////\
reg [31:0] f0_sop0_cnt;
reg [31:0] f0_sop1_cnt;
reg [31:0] f0_sop2_cnt;
reg [31:0] f0_sop3_cnt;

reg [31:0] f0_result_cnt;


always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) 
begin 
  if (!M_AXI_ARESETN) begin 
    f0_sop0_cnt <= 32'd0;
  end else if (curr_reset) begin
    f0_sop0_cnt <= 32'd0;
  end else if (pkt_sop_0) begin 
    f0_sop0_cnt <= f0_sop0_cnt + 1'b1;
  end 
end


always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) 
begin 
  if (!M_AXI_ARESETN ) begin 
    f0_sop1_cnt <= 32'd0;
  end else if (curr_reset) begin
    f0_sop1_cnt <= 32'd0;
  end else if (pkt_sop_1) begin 
    f0_sop1_cnt <= f0_sop1_cnt + 1'b1;
  end 
end


always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) 
begin 
  if (!M_AXI_ARESETN ) begin 
    f0_sop2_cnt <= 32'd0;
  end else if (curr_reset) begin
    f0_sop2_cnt <= 32'd0;
  end else if (pkt_sop_2) begin 
    f0_sop2_cnt <= f0_sop2_cnt + 1'b1;
  end 
end


always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) 
begin 
  if (!M_AXI_ARESETN) begin 
    f0_sop3_cnt <= 32'd0;
  end else if (curr_reset) begin
    f0_sop3_cnt <= 32'd0;
  end else if (pkt_sop_3) begin 
    f0_sop3_cnt <= f0_sop3_cnt + 1'b1;
  end 
end


always @(posedge core_clk or negedge core_rst_n) 
begin 
  if (!core_rst_n) begin 
    f0_result_cnt <= 32'd0;
  end else if(core_curr_reset) begin
    f0_result_cnt <= 32'd0;
  end else if (eop_0||eop_1) begin 
    f0_result_cnt <= f0_result_cnt + 32'd1;
  end
end

assign sop0_cnt = f0_sop0_cnt;
assign sop1_cnt = f0_sop1_cnt;
assign sop2_cnt = f0_sop2_cnt;
assign sop3_cnt = f0_sop3_cnt;

wire sop0_empty;
wire sop1_empty;
wire sop2_empty;
wire sop3_empty;
wire res_empty ;
wire sys_curr_empty ;
wire core_curr_empty;

afifo_16x1 core_curr (
  .wr_clk(M_AXI_ACLK      ), // input wire wr_clk
  .rd_clk(core_clk        ), // input wire rd_clk
  .din   (curr_reset      ), // input wire [0 : 0] din
  .wr_en (1               ), // input wire wr_en
  .rd_en (~core_curr_empty), // input wire rd_en
  .dout  (core_curr_reset ), // output wire [0 : 0] dout
  .full  (                ), // output wire full
  .empty (core_curr_empty )  // output wire empty
);



afifo_32x16 res (
  .wr_clk(core_clk     ),
  .rd_clk(M_AXI_ACLK   ),
  .wr_en (1            ),
  .din   (f0_result_cnt),
  .rd_en (!res_empty   ),
  .dout  (result_cnt   ),
  .full  (             ),
  .empty (res_empty    )
);





endmodule