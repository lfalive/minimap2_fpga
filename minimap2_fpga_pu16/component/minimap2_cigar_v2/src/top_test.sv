
module top_test();


  parameter                        RESULT_DATA_LENGTH       = 512;

//******************END*******************//

/*****************CLK**********************/
reg M_AXI_ACLK, M_AXI_ARESETN;
reg core_clk, core_rst_n;
always #5 M_AXI_ACLK = ~M_AXI_ACLK;
always #2 core_clk = ~core_clk;

initial begin
	 M_AXI_ARESETN = 1'b0; 
	 M_AXI_ACLK   = 1'b0;
     core_clk  = 1'b0;
     core_rst_n= 1'b0;

#31  M_AXI_ARESETN = 1'b1;
     core_rst_n= 1'b1;


	@(posedge M_AXI_ACLK);
	repeat(60000000)
		@(posedge M_AXI_ACLK);
	$stop;
end


/*******************END*********************/


/*******ROM 4 block 128K for pkt_analysis_top****/
reg wea, ena;
reg [13:0] addra;
reg [511:0] dina;
wire [511:0] douta;
reg flag, ddr_vld ;

reg start;
ram_512x8192 ROM_INIT (
  .clka(M_AXI_ACLK),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [13 : 0] addra
  .dina(dina),    // input wire [511 : 0] dina
  .douta(douta)  // output wire [511 : 0] douta
);

initial begin
	start = 0;
	dina = 'd0;

	repeat (5)
		@(posedge M_AXI_ACLK);
	start = 1'b1;
	@(posedge M_AXI_ACLK);
	start = 1'b0;
end

always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN)begin
	if (!M_AXI_ARESETN) begin
		ena <= 'b0;
		wea <= 'b0;
	end else if (start)
		ena <= 'b1;
	else if (addra == 'd8191)
		ena <= 'b0;
end
reg [5:0] done_cnt;
reg flag_2;

always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin
	if (!M_AXI_ARESETN)
		flag_2 <= 'b0;
	else if (addra[10:0] == 'd2047)
		flag_2 <= 'b1;
	else 
		flag_2 <= 'b0;
end

always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin
	if (!M_AXI_ARESETN)
		addra <= 'd0;
	else if (start==1'b1 || done_cnt == 'd30)
		addra <= 'd0;
	else if (flag_2)
		addra <= addra;
	else if (addra < 'd8192)
		addra <= addra + 1'b1;
end


always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN)begin
	if (!M_AXI_ARESETN)
		done_cnt <= 'd0;
	else if (done_cnt == 'd30)
		done_cnt <= 'd0;
	else if (flag)
		done_cnt <= done_cnt + 1'b1;
end

always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN)begin
	if (!M_AXI_ARESETN)
		ddr_vld <= 'd0;
	else if (start)
		ddr_vld <= 'b1;
	else if (addra == 'd8191)
		ddr_vld <= 'b0;
end

always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN)begin
	if (!M_AXI_ARESETN)
		flag <= 'd0;
	else if (addra == 'd8191)
		flag <= 'b1;
	else if (done_cnt == 'd30)
		flag <= 'b0;
end

reg ddr_vld_reg_0, ddr_vld_reg_1;
always @(posedge M_AXI_ACLK) begin
	ddr_vld_reg_0 <= ddr_vld;
	ddr_vld_reg_1 <= ddr_vld_reg_0;
end
/*************************END*********************/
//*****************dispate data to 128K**************/
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

wire [511:0] ddr_out;
wire [511:0] ddr_out_test;
//pcie_ram_rdat[7:0],pcie_ram_rdat[15:8],pcie_ram_rdat[23:16],pcie_ram_rdat[31:24],pcie_ram_rdat[39:32],pcie_ram_rdat[47:40],pcie_ram_rdat[55:48],pcie_ram_rdat[63:56],pcie_ram_rdat[71:64],pcie_ram_rdat[79:72],pcie_ram_rdat[87:80],pcie_ram_rdat[95:88],pcie_ram_rdat[103:96],pcie_ram_rdat[111:104],pcie_ram_rdat[119:112],pcie_ram_rdat[127:120];
//assign ddr_out = {douta[127:0], douta[255:128], douta[383:256], douta[511:384]};
assign ddr_out = {douta[7:0], douta[15:8], douta[23:16], douta[31:24], douta[39:32], douta[47:40], douta[55:48], douta[63:56], douta[71:64], douta[79:72], douta[87:80], douta[95:88], douta[103:96], douta[111:104], douta[119:112], douta[127:120], douta[135:128], douta[143:136], douta[151:144], douta[159:152], douta[167:160], douta[175:168], douta[183:176], douta[191:184], douta[199:192], douta[207:200], douta[215:208], douta[223:216], douta[231:224], douta[239:232], douta[247:240], douta[255:248], douta[263:256], douta[271:264], douta[279:272], douta[287:280], douta[295:288], douta[303:296], douta[311:304], douta[319:312], douta[327:320], douta[335:328], douta[343:336], douta[351:344], douta[359:352], douta[367:360], douta[375:368], douta[383:376], douta[391:384], douta[399:392], douta[407:400], douta[415:408], douta[423:416], douta[431:424], douta[439:432], douta[447:440], douta[455:448], douta[463:456], douta[471:464], douta[479:472], douta[487:480], douta[495:488], douta[503:496], douta[511:504]};
pkt_analysis_top u_pkt_analysis_top(
    .sys_clk                 (M_AXI_ACLK             ),
    .sys_rst_n               (M_AXI_ARESETN          ),

    .ddr4_rdat_vld            (ddr_vld_reg_1         ),
    .ddr4_rdat                (ddr_out     			 ),

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

initial begin 
  forever begin 
    @ (posedge M_AXI_ACLK);
    if (top_test.u0_calculate_ctl_top.u0.u_0.fifo_write_en) begin 

        
        $display ("data:%016x",top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in);
        
        $display("id:%d-%d-%d-%d",top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[415:384],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[383:352],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[351:344],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[343:336]);
        
        $display("LEFT");
        $display("read_len:%d hap_len:%d",top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[479:464],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[463:448]);
        $display("max:%d max_q:%d max_t:%d",top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[320:304],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[287:272],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[303:288]);
        $display("mqe:%d mqe_t:%d",top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[271:256],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[255:240]);
        $display("mte:%d mte_q:%d",$signed(top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[223:208]),top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[191:176]);
        $display("diagonal:%d",$signed(top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[175:160]));//+160
        
        $display("RIGHT");
        $display("read_len:%d hap_len:%d",top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[447:432],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[431:416]);
        $display("max:%d max_q:%d max_t:%d",top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[159:144],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[127:112],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[143:128]);
        $display("mqe:%d mqe_t:%d",top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[111:96],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[95:80]);
        $display("mte:%d mte_q:%d",$signed(top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[63:48]),top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[31:16]);
        $display("diagonal:%d",$signed(top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[15:0]));       
        
    end
  end
end

initial begin 
  forever begin 
    @ (posedge M_AXI_ACLK);
    if (top_test.u0_calculate_ctl_top.u0.u_1.fifo_write_en) begin 

        
        $display ("data:%016x",top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in);
        
        $display("id:%d-%d-%d-%d",top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[415:384],top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[383:352],top_test.u0_calculate_ctl_top.u0.u_0.fifo_data_in[351:344],top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[343:336]);
        
        $display("LEFT");
        $display("read_len:%d hap_len:%d",top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[479:464],top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[463:448]);
        $display("max:%d max_q:%d max_t:%d",top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[320:304],top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[287:272],top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[303:288]);
        $display("mqe:%d mqe_t:%d",top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[271:256],top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[255:240]);
        $display("mte:%d mte_q:%d",$signed(top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[223:208]),top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[191:176]);
        $display("diagonal:%d",$signed(top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[175:160]));//+160
        
        $display("RIGHT");
        $display("read_len:%d hap_len:%d",top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[447:432],top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[431:416]);
        $display("max:%d max_q:%d max_t:%d",top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[159:144],top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[127:112],top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[143:128]);
        $display("mqe:%d mqe_t:%d",top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[111:96],top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[95:80]);
        $display("mte:%d mte_q:%d",$signed(top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[63:48]),top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[31:16]);
        $display("diagonal:%d",$signed(top_test.u0_calculate_ctl_top.u0.u_1.fifo_data_in[15:0]));       
        
    end
  end
end

endmodule