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
//  2017-10-20       jyb             initial version
//
**********************************************************************/
module pkt_analysis_top(
input   wire            sys_clk,
input   wire            sys_rst_n,



input   wire            ddr4_rdat_vld,
input   wire   [511:0]  ddr4_rdat,

input   wire            matrix_enable_0,
input   wire            matrix_enable_1,
input   wire            matrix_enable_2,
input   wire            matrix_enable_3,


output  wire            pcie_ram_free,

output  wire   [31:0]   pkt_data_0,
output  wire            pkt_sop_0, 
output  wire            pkt_eop_0, 
output  wire            pkt_vld_0, 
   
output  wire   [31:0]   pkt_data_1,
output  wire            pkt_sop_1, 
output  wire            pkt_eop_1, 
output  wire            pkt_vld_1, 

output  wire   [31:0]   pkt_data_2,
output  wire            pkt_sop_2, 
output  wire            pkt_eop_2, 
output  wire            pkt_vld_2, 

output  wire   [31:0]   pkt_data_3,
output  wire            pkt_sop_3, 
output  wire            pkt_eop_3, 
output  wire            pkt_vld_3  


);
/*---------------------------------------------------------------------*\
                         parameter description 
\*---------------------------------------------------------------------*/
parameter D = 1;
/*---------------------------------------------------------------------*\
                         port description 
\*---------------------------------------------------------------------*/

/*---------------------------------------------------------------------*\
                         reg/wire description 
\*---------------------------------------------------------------------*/

  (* mark_debug = "true" *) reg             pcie_ram_wen_0;
 reg   [511:0]   pcie_ram_wdat_0;
 (* mark_debug = "true" *) reg   [10:0]    pcie_ram_waddr_0;
 (* mark_debug = "true" *) reg             pcie_ram_free_0;
 wire            pcie_ram_ren_0; 
wire  [12:0]    pcie_ram_raddr_0;
wire  [127:0]   pcie_ram_rdat_0;

 (* mark_debug = "true" *) reg             pcie_ram_wen_1;
reg   [511:0]   pcie_ram_wdat_1;
 (* mark_debug = "true" *)reg   [10:0]    pcie_ram_waddr_1;
 (* mark_debug = "true" *)reg             pcie_ram_free_1;
wire            pcie_ram_ren_1; 
wire  [12:0]    pcie_ram_raddr_1;
wire  [127:0]   pcie_ram_rdat_1;

 (* mark_debug = "true" *) reg             pcie_ram_wen_2;
reg   [511:0]   pcie_ram_wdat_2;
 (* mark_debug = "true" *) reg   [10:0]    pcie_ram_waddr_2;
 (* mark_debug = "true" *)reg             pcie_ram_free_2;
wire            pcie_ram_ren_2; 
wire  [12:0]    pcie_ram_raddr_2;
wire  [127:0]   pcie_ram_rdat_2;

 (* mark_debug = "true" *)reg             pcie_ram_wen_3;
reg   [511:0]   pcie_ram_wdat_3;
 (* mark_debug = "true" *)reg   [10:0]    pcie_ram_waddr_3;
 (* mark_debug = "true" *)reg             pcie_ram_free_3;
wire            pcie_ram_ren_3; 
wire  [12:0]    pcie_ram_raddr_3;
wire  [127:0]   pcie_ram_rdat_3;

wire            get_data_done_0;
wire            get_data_done_1;
wire            get_data_done_2;
wire            get_data_done_3;


(* mark_debug = "true" *)reg             start_analysis_0;
(* mark_debug = "true" *)reg             start_analysis_1;
(* mark_debug = "true" *)reg             start_analysis_2;
(* mark_debug = "true" *)reg             start_analysis_3;





 (* mark_debug = "true" *) reg   [1:0]     ram_select;
reg             pcie_ram_free_reg;
/*---------------------------------------------------------------------*\
                         main code 
\*---------------------------------------------------------------------*/
reg         f0_ddr_vld;
reg [511:0] f0_ddr_rdat;

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
  	f0_ddr_vld <= 1'b0;
  	f0_ddr_rdat<= 512'd0;
  end else begin 
  	f0_ddr_vld <= ddr4_rdat_vld;
  	// f0_ddr_rdat<= {ddr4_rdat[7:0],ddr4_rdat[15:8],ddr4_rdat[23:16],ddr4_rdat[31:24],ddr4_rdat[39:32],ddr4_rdat[47:40],ddr4_rdat[55:48],ddr4_rdat[63:56],ddr4_rdat[71:64],ddr4_rdat[79:72],ddr4_rdat[87:80],ddr4_rdat[95:88],ddr4_rdat[103:96],ddr4_rdat[111:104],ddr4_rdat[119:112],ddr4_rdat[127:120],ddr4_rdat[135:128],ddr4_rdat[143:136],ddr4_rdat[151:144],ddr4_rdat[159:152],ddr4_rdat[167:160],ddr4_rdat[175:168],ddr4_rdat[183:176],ddr4_rdat[191:184],ddr4_rdat[199:192],ddr4_rdat[207:200],ddr4_rdat[215:208],ddr4_rdat[223:216],ddr4_rdat[231:224],ddr4_rdat[239:232],ddr4_rdat[247:240],ddr4_rdat[255:248],ddr4_rdat[263:256],ddr4_rdat[271:264],ddr4_rdat[279:272],ddr4_rdat[287:280],ddr4_rdat[295:288],ddr4_rdat[303:296],ddr4_rdat[311:304],ddr4_rdat[319:312],ddr4_rdat[327:320],ddr4_rdat[335:328],ddr4_rdat[343:336],ddr4_rdat[351:344],ddr4_rdat[359:352],ddr4_rdat[367:360],ddr4_rdat[375:368],ddr4_rdat[383:376],ddr4_rdat[391:384],ddr4_rdat[399:392],ddr4_rdat[407:400],ddr4_rdat[415:408],ddr4_rdat[423:416],ddr4_rdat[431:424],ddr4_rdat[439:432],ddr4_rdat[447:440],ddr4_rdat[455:448],ddr4_rdat[463:456],ddr4_rdat[471:464],ddr4_rdat[479:472],ddr4_rdat[487:480],ddr4_rdat[495:488],ddr4_rdat[503:496],ddr4_rdat[511:504]};
    f0_ddr_rdat <= ddr4_rdat;
  end
end




always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    ram_select <=#D 2'd0;
  end else begin
    case (ram_select)  
      2'd0: begin if(pcie_ram_wen_0 && pcie_ram_waddr_0==11'd2047) ram_select <= #D ram_select + 1; end  
      2'd1: begin if(pcie_ram_wen_1 && pcie_ram_waddr_1==11'd2047) ram_select <= ram_select + 1; end 
      2'd2: begin if(pcie_ram_wen_2 && pcie_ram_waddr_2==11'd2047) ram_select <= ram_select + 1; end 
      2'd3: begin if(pcie_ram_wen_3 && pcie_ram_waddr_3==11'd2047) ram_select <= ram_select + 1; end 
    endcase 
  end
end 

//-----------------------------------------------------------------------------------------------------

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_free_0 <=#D 1'b1;
  end else if(pcie_ram_wen_0 && pcie_ram_waddr_0==11'd1) begin
    pcie_ram_free_0 <=#D 1'b0;   
  end else if(get_data_done_0) begin
    pcie_ram_free_0 <=#D 1'b1;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_free_1 <=#D 1'b1;
  end else if(pcie_ram_wen_1 && pcie_ram_waddr_1==11'd1) begin
    pcie_ram_free_1 <=#D 1'b0;   
  end else if(get_data_done_1) begin
    pcie_ram_free_1 <=#D 1'b1;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_free_2 <=#D 1'b1;
  end else if(pcie_ram_wen_2 && pcie_ram_waddr_2==11'd1) begin
    pcie_ram_free_2 <=#D 1'b0;   
  end else if(get_data_done_2) begin
    pcie_ram_free_2 <=#D 1'b1;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_free_3 <=#D 1'b1;
  end else if(pcie_ram_wen_3 && pcie_ram_waddr_3==11'd1) begin
    pcie_ram_free_3 <=#D 1'b0;   
  end else if(get_data_done_3) begin
    pcie_ram_free_3 <=#D 1'b1;  	
  end 	
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_free_reg <=#D 1'b0;
  end else begin
    case (ram_select)  
      2'd0: begin 
              if(pcie_ram_free_0)   pcie_ram_free_reg <= 1;  
              else                  pcie_ram_free_reg <= 0;
            end 

      2'd1: begin 
              if(pcie_ram_free_1)   pcie_ram_free_reg <= 1;  
              else                  pcie_ram_free_reg <= 0;
            end 
      
      2'd2: begin 
              if(pcie_ram_free_2)   pcie_ram_free_reg <= 1;  
              else                  pcie_ram_free_reg <= 0;
            end 
   
      2'd3: begin 
              if(pcie_ram_free_3)   pcie_ram_free_reg <= 1;  
              else                  pcie_ram_free_reg <= 0;
            end    
    endcase 
  end	
end

assign pcie_ram_free  =  pcie_ram_free_reg;

//-----------------------------------------------------------------------------------------------------

/*always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_wen_0 <=#D 1'b0;
  end else if(ram_select==2'd0 && f0_ddr_vld) begin
    pcie_ram_wen_0 <=#D 1'b1;   
  end else begin
    pcie_ram_wen_0 <=#D 1'b0;  	
  end 	
end*/
always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin 
    pcie_ram_wen_0 <=#D 1'b0;
  end else if(pcie_ram_waddr_0==11'd2047 && f0_ddr_vld) begin
    pcie_ram_wen_0 <=#D 1'b0;  
  end else if(ram_select==2'd0 && f0_ddr_vld) begin
    pcie_ram_wen_0 <=#D 1'b1; 
  end else begin
    pcie_ram_wen_0 <=#D 1'b0;   
  end   
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_wdat_0 <=#D 512'b0;
  end else if(ram_select==2'd0 && f0_ddr_vld) begin
    pcie_ram_wdat_0 <=#D f0_ddr_rdat;   
  end else begin
    pcie_ram_wdat_0 <=#D 512'b0;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_waddr_0 <=#D 11'b0;
  end else if(pcie_ram_wen_0 && pcie_ram_waddr_0==11'd2047) begin
    pcie_ram_waddr_0 <=#D 11'b0;   
  end else if(pcie_ram_wen_0) begin
    pcie_ram_waddr_0 <=#D pcie_ram_waddr_0 + 1;  	
  end 	
end

//-----------------------------------------------------------------------------------------------------

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_wen_1 <=#D 1'b0;
  end else if(pcie_ram_waddr_1==11'd2047 && f0_ddr_vld) begin
    pcie_ram_wen_1 <=#D 1'b0;  
  end else if(ram_select==2'd1 && f0_ddr_vld) begin
    pcie_ram_wen_1 <=#D 1'b1;   
  end else begin
    pcie_ram_wen_1 <=#D 1'b0;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_wdat_1 <=#D 512'b0;
  end else if(ram_select==2'd1 && f0_ddr_vld) begin
    pcie_ram_wdat_1 <=#D f0_ddr_rdat;  
  end else begin
    pcie_ram_wdat_1 <=#D 512'b0;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_waddr_1 <=#D 11'b0;
  end else if(pcie_ram_wen_1 && pcie_ram_waddr_1==11'd2047) begin
    pcie_ram_waddr_1 <=#D 11'b0;   
  end else if(pcie_ram_wen_1) begin
    pcie_ram_waddr_1 <=#D pcie_ram_waddr_1 + 1;  	
  end 	
end

//-----------------------------------------------------------------------------------------------------

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_wen_2 <=#D 1'b0;
  end else if(pcie_ram_waddr_2==11'd2047 && f0_ddr_vld) begin
    pcie_ram_wen_2 <=#D 1'b0;  
  end else if(ram_select==2'd2 && f0_ddr_vld) begin
    pcie_ram_wen_2 <=#D 1'b1;   
  end else begin
    pcie_ram_wen_2 <=#D 1'b0;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_wdat_2 <=#D 512'b0;
  end else if(ram_select==2'd2 && f0_ddr_vld) begin
    pcie_ram_wdat_2 <=#D f0_ddr_rdat;   
  end else begin
    pcie_ram_wdat_2 <=#D 512'b0;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_waddr_2 <=#D 11'b0;
  end else if(pcie_ram_wen_2 && pcie_ram_waddr_2==11'd2047) begin
    pcie_ram_waddr_2 <=#D 11'b0;   
  end else if(pcie_ram_wen_2) begin
    pcie_ram_waddr_2 <=#D pcie_ram_waddr_2 + 1;  	
  end 	
end

//-----------------------------------------------------------------------------------------------------

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_wen_3 <=#D 1'b0;
  end else if(pcie_ram_waddr_3==11'd2047 && f0_ddr_vld) begin
    pcie_ram_wen_3 <=#D 1'b0;  
  end else if(ram_select==2'd3 && f0_ddr_vld) begin
    pcie_ram_wen_3 <=#D 1'b1;   
  end else begin
    pcie_ram_wen_3 <=#D 1'b0;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_wdat_3 <=#D 512'b0;
  end else if(ram_select==2'd3 && f0_ddr_vld) begin
    pcie_ram_wdat_3 <=#D f0_ddr_rdat;  
  end else begin
    pcie_ram_wdat_3 <=#D 512'b0;  	
  end 	
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
  if(!sys_rst_n)begin	
    pcie_ram_waddr_3 <=#D 11'b0;
  end else if(pcie_ram_wen_3 && pcie_ram_waddr_3==11'd2047) begin
    pcie_ram_waddr_3 <=#D 11'b0;   
  end else if(pcie_ram_wen_3) begin
    pcie_ram_waddr_3 <=#D pcie_ram_waddr_3 + 1;  	
  end 	
end

//-----------------------------------------------------------------------------------------------------


always@(posedge sys_clk)
begin
  if(pcie_ram_wen_0 && pcie_ram_waddr_0==11'd2047) begin	
    start_analysis_0 <=#D 1'b1;
  end else begin
    start_analysis_0 <=#D 1'b0;  
  end
end

always@(posedge sys_clk)
begin
  if(pcie_ram_wen_1 && pcie_ram_waddr_1==11'd2047) begin	
    start_analysis_1 <=#D 1'b1;
  end else begin
    start_analysis_1 <=#D 1'b0;  
  end
end

always@(posedge sys_clk)
begin
  if(pcie_ram_wen_2 && pcie_ram_waddr_2==11'd2047) begin	
    start_analysis_2 <=#D 1'b1;
  end else begin
    start_analysis_2 <=#D 1'b0;  
  end
end

always@(posedge sys_clk)
begin
  if(pcie_ram_wen_3 && pcie_ram_waddr_3==11'd2047) begin	
    start_analysis_3 <=#D 1'b1;
  end else begin
    start_analysis_3 <=#D 1'b0;  
  end
end


//==================================================================================

data_pkt u0_data_pkt(
   //input
   .sys_clk         (sys_clk           ),  
   .sys_rst_n       (sys_rst_n         ),
   //
   .pcie_ram_ren    (pcie_ram_ren_0    ), //output
   .pcie_ram_raddr  (pcie_ram_raddr_0  ), //output
   .pcie_ram_rdat   (pcie_ram_rdat_0   ),//input
   //
   .start_analysis   (start_analysis_0 ),
   .get_data_done   (get_data_done_0   ),
   //
   .matrix_enable_0 (matrix_enable_0   ),
   .pkt_data_0      (pkt_data_0        ),
   .pkt_sop_0       (pkt_sop_0         ),
   .pkt_eop_0       (pkt_eop_0         ),
   .pkt_vld_0       (pkt_vld_0         )
);



ram_2048x512_8192x128 u0_data_pkt_ram (
  //write
  .clka (sys_clk        ), // input wire clka
  .wea  (pcie_ram_wen_0  ), // input wire [0 : 0] wea
  .addra(pcie_ram_waddr_0), // input wire [10 : 0] addra
  .dina (pcie_ram_wdat_0 ), // input wire [511 : 0] dina
  //read
  .clkb (sys_clk         ), // input wire clkb
  .enb  (1'b1            ), // input wire enb
  .addrb(pcie_ram_raddr_0), // input wire [12 : 0] addrb
  .doutb(pcie_ram_rdat_0 )  // output wire [127 : 0] doutb
);

//--------------------------------------------------------------------------
data_pkt u1_data_pkt(
   //
   .sys_clk         (sys_clk),  
   .sys_rst_n       (sys_rst_n),
   //
   .pcie_ram_ren    (pcie_ram_ren_1    ), 
   .pcie_ram_raddr  (pcie_ram_raddr_1  ),
   .pcie_ram_rdat   (pcie_ram_rdat_1   ),
   //
   .start_analysis  (start_analysis_1 ),
   .get_data_done   (get_data_done_1   ),
   //
   .matrix_enable_0 (matrix_enable_1   ),
   .pkt_data_0      (pkt_data_1        ),
   .pkt_sop_0       (pkt_sop_1         ),
   .pkt_eop_0       (pkt_eop_1         ),
   .pkt_vld_0       (pkt_vld_1         )
   //                                    

);



ram_2048x512_8192x128 u1_data_pkt_ram (
  //write
  .clka (sys_clk        ), // input wire clka
  .wea  (pcie_ram_wen_1  ), // input wire [0 : 0] wea
  .addra(pcie_ram_waddr_1), // input wire [10 : 0] addra
  .dina (pcie_ram_wdat_1 ), // input wire [511 : 0] dina
  //read
  .clkb (sys_clk         ), // input wire clkb
  .enb  (1'b1            ), // input wire enb
  .addrb(pcie_ram_raddr_1), // input wire [12 : 0] addrb
  .doutb(pcie_ram_rdat_1 )  // output wire [127 : 0] doutb
);

//--------------------------------------------------------------------------


data_pkt u2_data_pkt(
   //
   .sys_clk         (sys_clk           ),  
   .sys_rst_n       (sys_rst_n         ),
   //
   .pcie_ram_ren    (pcie_ram_ren_2    ), 
   .pcie_ram_raddr  (pcie_ram_raddr_2  ),
   .pcie_ram_rdat   (pcie_ram_rdat_2   ),
   //
   .start_analysis   (start_analysis_2 ),
   .get_data_done   (get_data_done_2   ),
   //
   .matrix_enable_0 (matrix_enable_2   ),
   //
   .pkt_data_0      (pkt_data_2        ),
   .pkt_sop_0       (pkt_sop_2         ),
   .pkt_eop_0       (pkt_eop_2         ),
   .pkt_vld_0       (pkt_vld_2         )
   //                                    
);



ram_2048x512_8192x128 u2_data_pkt_ram (
  //write
  .clka (sys_clk        ), // input wire clka
  .wea  (pcie_ram_wen_2  ), // input wire [0 : 0] wea
  .addra(pcie_ram_waddr_2), // input wire [10 : 0] addra
  .dina (pcie_ram_wdat_2 ), // input wire [511 : 0] dina
  //read
  .clkb (sys_clk         ), // input wire clkb
  .enb  (1'b1            ), // input wire enb
  .addrb(pcie_ram_raddr_2), // input wire [12 : 0] addrb
  .doutb(pcie_ram_rdat_2 )  // output wire [127 : 0] doutb
);

//--------------------------------------------------------------------------

data_pkt u3_data_pkt(
   //
   .sys_clk         (sys_clk           ),  
   .sys_rst_n       (sys_rst_n         ),
   //
   .pcie_ram_ren    (pcie_ram_ren_3    ), 
   .pcie_ram_raddr  (pcie_ram_raddr_3  ),
   .pcie_ram_rdat   (pcie_ram_rdat_3   ),
   //
   .start_analysis   (start_analysis_3 ),
   .get_data_done   (get_data_done_3   ),
   //
   .matrix_enable_0 (matrix_enable_3   ),
   //
   .pkt_data_0      (pkt_data_3        ),
   .pkt_sop_0       (pkt_sop_3         ),
   .pkt_eop_0       (pkt_eop_3         ),
   .pkt_vld_0       (pkt_vld_3         )
   //                                    
);


ram_2048x512_8192x128 u3_data_pkt_ram (
  //write
  .clka (sys_clk        ), // input wire clka
  .wea  (pcie_ram_wen_3  ), // input wire [0 : 0] wea
  .addra(pcie_ram_waddr_3), // input wire [10 : 0] addra
  .dina (pcie_ram_wdat_3 ), // input wire [511 : 0] dina
  //read
  .clkb (sys_clk         ), // input wire clkb
  .enb  (1'b1            ), // input wire enb
  .addrb(pcie_ram_raddr_3), // input wire [12 : 0] addrb
  .doutb(pcie_ram_rdat_3 )  // output wire [127 : 0] doutb
);

//--------------------------------------------------------------------------







endmodule

