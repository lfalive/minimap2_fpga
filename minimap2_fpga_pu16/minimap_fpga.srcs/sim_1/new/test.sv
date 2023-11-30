`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2018 05:03:37 PM
// Design Name: 
// Module Name: test
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
//  2015-02-01        jyb             initial version
//
**********************************************************************/
`timescale 1ns/1ps
module test;
/*---------------------------------------------------------------------*\
                         parameter description 
\*---------------------------------------------------------------------*/
parameter D = 0;
//parameter PKT_NUM = 100;
parameter PKT_NUM = 0;
/*---------------------------------------------------------------------*\
                         port description 
\*---------------------------------------------------------------------*/
reg                 sys_clk;
reg                 sys_rst_n;
reg                 core_clk;
reg                 core_rst_n;
reg                 pcie_write_done;

wire                get_data_done;
wire                pcie_ram_ren; 
wire      [ 15:0]   pcie_ram_raddr;
wire      [127:0]   pcie_ram_rdat;
wire      [ 31:0]   pkt_data;
wire                pkt_sop;
wire                pkt_eop;
wire                pkt_vld;

wire                pkt_enable;

wire                empty   ;
/*---------------------------------------------------------------------*\
                         reg/wire description 
\*---------------------------------------------------------------------*/


/*---------------------------------------------------------------------*\
                         main code 
\*---------------------------------------------------------------------*/

// ram_9600x128 u1(
// 	 .data                     (128'b0              ), 
// 	 .wraddress                (0              ),
// 	 .rdaddress                (pcie_ram_raddr ),
// 	 .wren                     (1'b0           ),
// 	 .clock                    (sys_clk        ),
// 	 .rden                     (pcie_ram_ren   ),
// 	 .q                        (pcie_ram_rdat  )
// );	



ram_8192x128 u1 (
  .clka(sys_clk),    // input wire clka
  .clkb (sys_clk),
  .addrb(pcie_ram_raddr),  // input wire [15 : 0] addrb
  .doutb(pcie_ram_rdat)  // output wire [31 : 0] doutb
);


wire pkt_enable_16;
wire pkt_enable_32;
wire pkt_enable_64;
wire pkt_enable_128;
data_pkt_sim u0 (
  //input
  .sys_clk        (sys_clk        ),
  .sys_rst_n      (sys_rst_n      ),
  .matrix_enable_0(pkt_enable     ),
  .start_analysis (pcie_write_done),
  .pcie_ram_rdat  (pcie_ram_rdat  ),
  //output
  .get_data_done  (get_data_done  ),
  .pcie_ram_ren   (pcie_ram_ren   ),
  .pcie_ram_raddr (pcie_ram_raddr ),
  .pkt_data_0     (pkt_data       ),
  .pkt_sop_0      (pkt_sop        ),
  .pkt_eop_0      (pkt_eop        ),
  .pkt_vld_0      (pkt_vld        )
);
wire         rd_start  ;
wire        vld_out   ;
wire        empty_out ;
wire        eop_out   ;
wire [63:0] data_out   ;
matrix_7 uut (
   .sys_clk                  (sys_clk        ),
   .sys_rst_n                (sys_rst_n      ),
   .core_clk                 (core_clk       ),
   .core_rst_n               (core_rst_n     ),
   .matrix_memory_sop        (pkt_sop        ),
   .matrix_memory_eop        (pkt_eop        ),
   .matrix_memory_vld        (pkt_vld        ),
   .matrix_memory_data       (pkt_data       ),
   .pkt_receive_enable       (pkt_enable     ),
   //
   .result_fifo_rden         (!empty           ),
   .result_fifo_rdat         (               ),
   .result_fifo_empty        (empty          ),
    .rd_start  (~empty_out),
    .vld_out (vld_out)  ,
    .empty_out(empty_out) ,
    .eop_out  (eop_out) ,
    .data_out (data_out)
);

wire        vld_out_16   ;
wire        empty_out_16 ;
wire        eop_out_16   ;
wire [63:0] data_out_16   ;
wire empty_16 ;

matrix_7_16 uut_16 (
   .sys_clk                  (sys_clk        ),
   .sys_rst_n                (sys_rst_n      ),
   .core_clk                 (core_clk       ),
   .core_rst_n               (core_rst_n     ),
   .matrix_memory_sop        (pkt_sop        ),
   .matrix_memory_eop        (pkt_eop        ),
   .matrix_memory_vld        (pkt_vld        ),
   .matrix_memory_data       (pkt_data       ),
   .pkt_receive_enable       (pkt_enable_16     ),
   //
   .result_fifo_rden         (!empty_16           ),
   .result_fifo_rdat         (               ),
   .result_fifo_empty        (empty_16          ),
    .rd_start  (~empty_out_16),
    .vld_out (vld_out_16)  ,
    .empty_out(empty_out_16) ,
    .eop_out  (eop_out_16) ,
    .data_out (data_out_16)
);


wire        vld_out_32   ;
wire        empty_out_32 ;
wire        eop_out_32   ;
wire [63:0] data_out_32   ;
wire empty_32 ;

matrix_7_32 uut_32 (
   .sys_clk                  (sys_clk        ),
   .sys_rst_n                (sys_rst_n      ),
   .core_clk                 (core_clk       ),
   .core_rst_n               (core_rst_n     ),
   .matrix_memory_sop        (pkt_sop        ),
   .matrix_memory_eop        (pkt_eop        ),
   .matrix_memory_vld        (pkt_vld        ),
   .matrix_memory_data       (pkt_data       ),
   .pkt_receive_enable       (pkt_enable_32     ),
   //
   .result_fifo_rden         (!empty_32           ),
   .result_fifo_rdat         (               ),
   .result_fifo_empty        (empty_32          ),
    .rd_start  (~empty_out_32),
    .vld_out (vld_out_32)  ,
    .empty_out(empty_out_32) ,
    .eop_out  (eop_out_32) ,
    .data_out (data_out_32)
);


wire        vld_out_64   ;
wire        empty_out_64 ;
wire        eop_out_64   ;
wire [63:0] data_out_64   ;
wire empty_64 ;

matrix_7_64 uut_64 (
   .sys_clk                  (sys_clk        ),
   .sys_rst_n                (sys_rst_n      ),
   .core_clk                 (core_clk       ),
   .core_rst_n               (core_rst_n     ),
   .matrix_memory_sop        (pkt_sop        ),
   .matrix_memory_eop        (pkt_eop        ),
   .matrix_memory_vld        (pkt_vld        ),
   .matrix_memory_data       (pkt_data       ),
   .pkt_receive_enable       (pkt_enable_64     ),
   //
   .result_fifo_rden         (!empty_64           ),
   .result_fifo_rdat         (               ),
   .result_fifo_empty        (empty_64          ),
    .rd_start  (~empty_out_64),
    .vld_out (vld_out_64)  ,
    .empty_out(empty_out_64) ,
    .eop_out  (eop_out_64) ,
    .data_out (data_out_64)
);

wire        vld_out_128   ;
wire        empty_out_128 ;
wire        eop_out_128   ;
wire [63:0] data_out_128   ;
wire empty_128 ;

matrix_7_128 uut_128 (
   .sys_clk                  (sys_clk        ),
   .sys_rst_n                (sys_rst_n      ),
   .core_clk                 (core_clk       ),
   .core_rst_n               (core_rst_n     ),
   .matrix_memory_sop        (pkt_sop        ),
   .matrix_memory_eop        (pkt_eop        ),
   .matrix_memory_vld        (pkt_vld        ),
   .matrix_memory_data       (pkt_data       ),
   .pkt_receive_enable       (pkt_enable_128     ),
   //
   .result_fifo_rden         (!empty_128           ),
   .result_fifo_rdat         (               ),
   .result_fifo_empty        (empty_128          ),
    .rd_start  (~empty_out_128),
    .vld_out (vld_out_128)  ,
    .empty_out(empty_out_128) ,
    .eop_out  (eop_out_128) ,
    .data_out (data_out_128)
);/**/

always #5  sys_clk   = ~sys_clk;
always #2  core_clk  = ~core_clk;



reg       [7:0]     counter;
reg       [8:0]     result_cnt;
reg       [31:0] 	sum       ;
reg       [31:0] 	sop_cnt   ; 

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    counter <=#D 8'd0;
  end else if(counter == 8'd30) begin
    counter <=#D counter;
  end else begin
    counter <=#D counter + 1;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
 if(!sys_rst_n)begin	
   pcie_write_done <=#D 1'b0;
 end else if(counter == 8'd20) begin
   pcie_write_done <=#D 1'b1;   
 end else if(get_data_done && sum < PKT_NUM) begin
   pcie_write_done <=#D 1'b1;   	
 end else begin
   pcie_write_done <=#D 1'b0;	
 end 
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
 if(!sys_rst_n)begin	
 	sum <= 0;
 end else if(sum == PKT_NUM) begin 
 	sum <= sum;
 end else if (get_data_done)begin 
 	sum <= sum + 1;
 end // end else
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
 if(!sys_rst_n)begin	
 	sop_cnt <= 0;
 end else if (pkt_sop)begin 
 	sop_cnt <= sop_cnt + 1;
 end // end else
end



initial begin
	 sys_rst_n = 1'b0; 
	 sys_clk   = 1'b0;
     core_clk  = 1'b0;
     core_rst_n= 1'b0;
     result_cnt= 1'b0;

#31  sys_rst_n = 1'b1;
     core_rst_n= 1'b1;


@(posedge sys_clk);
repeat(60000000)
@(posedge sys_clk);
$stop;
end



initial begin 
  forever begin 
    @ (posedge sys_clk);
    if (test.uut.fifo_write_en) begin 
        $display ("UUT_7");
        $display ("data:%016x",test.uut.fifo_data_in);
        
        $display("id:%d-%d-%d-%d",test.uut.fifo_data_in[415:384],test.uut.fifo_data_in[383:352],test.uut.fifo_data_in[351:344],test.uut.fifo_data_in[343:336]);
        
        $display("LEFT");
        $display("read_len:%d hap_len:%d",test.uut.fifo_data_in[479:464],test.uut.fifo_data_in[463:448]);
        $display("max:%d max_q:%d max_t:%d",test.uut.fifo_data_in[320:304],test.uut.fifo_data_in[287:272],test.uut.fifo_data_in[303:288]);
        $display("mqe:%d mqe_t:%d",test.uut.fifo_data_in[271:256],test.uut.fifo_data_in[255:240]);
        $display("mte:%d mte_q:%d",$signed(test.uut.fifo_data_in[223:208]),test.uut.fifo_data_in[191:176]);
        $display("diagonal:%d",$signed(test.uut.fifo_data_in[175:160]));//+160
        
        $display("RIGHT");
        $display("read_len:%d hap_len:%d",test.uut.fifo_data_in[447:432],test.uut.fifo_data_in[431:416]);
        $display("max:%d max_q:%d max_t:%d",test.uut.fifo_data_in[159:144],test.uut.fifo_data_in[127:112],test.uut.fifo_data_in[143:128]);
        $display("mqe:%d mqe_t:%d",test.uut.fifo_data_in[111:96],test.uut.fifo_data_in[95:80]);
        $display("mte:%d mte_q:%d",$signed(test.uut.fifo_data_in[63:48]),test.uut.fifo_data_in[31:16]);
        $display("diagonal:%d",$signed(test.uut.fifo_data_in[15:0]));        
        
    end
  end
end

initial begin 
  forever begin 
    @ (posedge sys_clk);
    if (test.uut_16.fifo_write_en) begin 
        $display ("UUT_16");
        $display ("data:%016x",test.uut_16.fifo_data_in);
        
        $display("id:%d-%d-%d-%d",test.uut_16.fifo_data_in[415:384],test.uut_16.fifo_data_in[383:352],test.uut_16.fifo_data_in[351:344],test.uut_16.fifo_data_in[343:336]);
        
        $display("LEFT");
        $display("read_len:%d hap_len:%d",test.uut_16.fifo_data_in[479:464],test.uut_16.fifo_data_in[463:448]);
        $display("max:%d max_q:%d max_t:%d",test.uut_16.fifo_data_in[320:304],test.uut_16.fifo_data_in[287:272],test.uut_16.fifo_data_in[303:288]);
        $display("mqe:%d mqe_t:%d",test.uut_16.fifo_data_in[271:256],test.uut_16.fifo_data_in[255:240]);
        $display("mte:%d mte_q:%d",$signed(test.uut_16.fifo_data_in[223:208]),test.uut_16.fifo_data_in[191:176]);
        $display("diagonal:%d",$signed(test.uut_16.fifo_data_in[175:160]));//+160
        
        $display("RIGHT");
        $display("read_len:%d hap_len:%d",test.uut_16.fifo_data_in[447:432],test.uut_16.fifo_data_in[431:416]);
        $display("max:%d max_q:%d max_t:%d",test.uut_16.fifo_data_in[159:144],test.uut_16.fifo_data_in[127:112],test.uut_16.fifo_data_in[143:128]);
        $display("mqe:%d mqe_t:%d",test.uut_16.fifo_data_in[111:96],test.uut_16.fifo_data_in[95:80]);
        $display("mte:%d mte_q:%d",$signed(test.uut_16.fifo_data_in[63:48]),test.uut_16.fifo_data_in[31:16]);
        $display("diagonal:%d",$signed(test.uut_16.fifo_data_in[15:0]));        
        
    end
  end
end

initial begin 
  forever begin 
    @ (posedge sys_clk);
    if (test.uut_32.fifo_write_en) begin 
        $display ("UUT_32");
        $display ("data:%016x",test.uut_32.fifo_data_in);
        
        $display("id:%d-%d-%d-%d",test.uut_32.fifo_data_in[415:384],test.uut_32.fifo_data_in[383:352],test.uut_32.fifo_data_in[351:344],test.uut_32.fifo_data_in[343:336]);
        
        $display("LEFT");
        $display("read_len:%d hap_len:%d",test.uut_32.fifo_data_in[479:464],test.uut_32.fifo_data_in[463:448]);
        $display("max:%d max_q:%d max_t:%d",test.uut_32.fifo_data_in[320:304],test.uut_32.fifo_data_in[287:272],test.uut_32.fifo_data_in[303:288]);
        $display("mqe:%d mqe_t:%d",test.uut_32.fifo_data_in[271:256],test.uut_32.fifo_data_in[255:240]);
        $display("mte:%d mte_q:%d",$signed(test.uut_32.fifo_data_in[223:208]),test.uut_32.fifo_data_in[191:176]);
        $display("diagonal:%d",$signed(test.uut_32.fifo_data_in[175:160]));//+160
        
        $display("RIGHT");
        $display("read_len:%d hap_len:%d",test.uut_32.fifo_data_in[447:432],test.uut_32.fifo_data_in[431:416]);
        $display("max:%d max_q:%d max_t:%d",test.uut_32.fifo_data_in[159:144],test.uut_32.fifo_data_in[127:112],test.uut_32.fifo_data_in[143:128]);
        $display("mqe:%d mqe_t:%d",test.uut_32.fifo_data_in[111:96],test.uut_32.fifo_data_in[95:80]);
        $display("mte:%d mte_q:%d",$signed(test.uut_32.fifo_data_in[63:48]),test.uut_32.fifo_data_in[31:16]);
        $display("diagonal:%d",$signed(test.uut_32.fifo_data_in[15:0]));        
        
    end
  end
end

initial begin 
  forever begin 
    @ (posedge sys_clk);
    if (test.uut_64.fifo_write_en) begin 
        $display ("UUT_64");
        $display ("data:%016x",test.uut_64.fifo_data_in);
        
        $display("id:%d-%d-%d-%d",test.uut_64.fifo_data_in[415:384],test.uut_64.fifo_data_in[383:352],test.uut_64.fifo_data_in[351:344],test.uut_64.fifo_data_in[343:336]);
        
        $display("LEFT");
        $display("read_len:%d hap_len:%d",test.uut_64.fifo_data_in[479:464],test.uut_64.fifo_data_in[463:448]);
        $display("max:%d max_q:%d max_t:%d",test.uut_64.fifo_data_in[320:304],test.uut_64.fifo_data_in[287:272],test.uut_64.fifo_data_in[303:288]);
        $display("mqe:%d mqe_t:%d",test.uut_64.fifo_data_in[271:256],test.uut_64.fifo_data_in[255:240]);
        $display("mte:%d mte_q:%d",$signed(test.uut_64.fifo_data_in[223:208]),test.uut_64.fifo_data_in[191:176]);
        $display("diagonal:%d",$signed(test.uut_64.fifo_data_in[175:160]));//+160
        
        $display("RIGHT");
        $display("read_len:%d hap_len:%d",test.uut_64.fifo_data_in[447:432],test.uut_64.fifo_data_in[431:416]);
        $display("max:%d max_q:%d max_t:%d",test.uut_64.fifo_data_in[159:144],test.uut_64.fifo_data_in[127:112],test.uut_64.fifo_data_in[143:128]);
        $display("mqe:%d mqe_t:%d",test.uut_64.fifo_data_in[111:96],test.uut_64.fifo_data_in[95:80]);
        $display("mte:%d mte_q:%d",$signed(test.uut_64.fifo_data_in[63:48]),test.uut_64.fifo_data_in[31:16]);
        $display("diagonal:%d",$signed(test.uut_64.fifo_data_in[15:0]));        
        
    end
  end
end

initial begin 
  forever begin 
    @ (posedge sys_clk);
    if (test.uut_128.fifo_write_en) begin 
        $display ("UUT_128");
        $display ("data:%016x",test.uut_128.fifo_data_in);
        
        $display("id:%d-%d-%d-%d",test.uut_128.fifo_data_in[415:384],test.uut_128.fifo_data_in[383:352],test.uut_128.fifo_data_in[351:344],test.uut_128.fifo_data_in[343:336]);
        
        $display("LEFT");
        $display("read_len:%d hap_len:%d",test.uut_128.fifo_data_in[479:464],test.uut_128.fifo_data_in[463:448]);
        $display("max:%d max_q:%d max_t:%d",test.uut_128.fifo_data_in[320:304],test.uut_128.fifo_data_in[287:272],test.uut_128.fifo_data_in[303:288]);
        $display("mqe:%d mqe_t:%d",test.uut_128.fifo_data_in[271:256],test.uut_128.fifo_data_in[255:240]);
        $display("mte:%d mte_q:%d",$signed(test.uut_128.fifo_data_in[223:208]),test.uut_128.fifo_data_in[191:176]);
        $display("diagonal:%d",$signed(test.uut_128.fifo_data_in[175:160]));//+160
        
        $display("RIGHT");
        $display("read_len:%d hap_len:%d",test.uut_128.fifo_data_in[447:432],test.uut_128.fifo_data_in[431:416]);
        $display("max:%d max_q:%d max_t:%d",test.uut_128.fifo_data_in[159:144],test.uut_128.fifo_data_in[127:112],test.uut_128.fifo_data_in[143:128]);
        $display("mqe:%d mqe_t:%d",test.uut_128.fifo_data_in[111:96],test.uut_128.fifo_data_in[95:80]);
        $display("mte:%d mte_q:%d",$signed(test.uut_128.fifo_data_in[63:48]),test.uut_128.fifo_data_in[31:16]);
        $display("diagonal:%d",$signed(test.uut_128.fifo_data_in[15:0]));        
        
    end
  end
end/**/


// initial begin 
//   forever begin 
//     @ (posedge sys_clk);
//     if (test.uut.fifo_data_in == 256'h0000000000000001001500070007000400070012001300070007000200070012 && test.uut.fifo_write_en) begin
//         result_cnt = result_cnt + 1;
//     	$display ("sum:%d",result_cnt);
//     end
//   end
// end


// initial begin
// //wait(sys_rst_n);	
// 	$fsdbDumpfile("./test_data_pkt_top.fsdb");
//  	// $fsdbDumpvars(1,test.uut.u_read_analyze.calculate_p_inst); 
//     $fsdbDumpvars(4,test);
// end


// Local Variables:
// verilog-library-files:("../source/test_phy.v" )
// End:


endmodule   