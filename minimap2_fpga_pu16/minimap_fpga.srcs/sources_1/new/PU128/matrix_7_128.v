`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2019 11:25:25 AM
// Design Name: 
// Module Name: matrix_7_128
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

module matrix_7_128 #(
	parameter RH_BANDWIDTH   = 4,
	parameter PE_NUM         = 128,
	parameter CIRCLE_SUM_BIT = 7,
	parameter EN_LENGTH      = 16,
	parameter RESULT_LENGTH  = 512,
	parameter BT_OUT_WIDTH   = 64

)(
	// input

input  wire        core_clk          ,
input  wire        core_rst_n        ,
input  wire        sys_clk           ,
input  wire        sys_rst_n         ,
input  wire        matrix_memory_sop ,
input  wire        matrix_memory_eop ,
input  wire        matrix_memory_vld ,
input  wire [31:0] matrix_memory_data,
input  wire        result_fifo_rden  ,
//outpuwire ;
output wire       	pkt_receive_enable,
output wire [511:0] result_fifo_rdat  ,
output wire 		result_fifo_empty ,

//==================BT_RESULT=========//
input wire         rd_start  ,
output wire        vld_out   ,
output wire        empty_out ,
output wire        eop_out   ,
output wire [63:0] data_out
    );

/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/

parameter S0  = 7'b0000001;
parameter S1  = 7'b0000010;
parameter S2  = 7'b0000100;
parameter S3  = 7'b0001000;
parameter S4  = 7'b0010000;
parameter S5  = 7'b0100000;
parameter S6  = 7'b1000000;

parameter T0  = 7'b0000001;
parameter T1  = 7'b0000010;
parameter T2  = 7'b0000100;
parameter T3  = 7'b0001000;
parameter T4  = 7'b0010000;
parameter T5  = 7'b0100000;
parameter T6  = 7'b1000000;

/*function integer clogb2 (input integer bit_depth);
begin
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	bit_depth = bit_depth>>1;
end
endfunction*/

/*parameter RH_BANDWIDTH   = 4             ;
parameter PE_NUM         = 16          ;
//parameter CIRCLE_SUM_BIT = clogb2(PE_NUM-1);
parameter CIRCLE_SUM_BIT = 4;
//parameter CIRCLE_SUM_BIT = 2;
parameter RESULT_LENGTH = 512;
parameter EN_LENGTH = 10; //1+1+3+3
parameter BT_OUT_WIDTH = 64;*/

parameter CMP_RESULT_WIDTH = 48;
parameter LOCATION_WIDTH = 32;
//-------------------------------reg and wire ------------------------------//
/*-------------------------------------------------------------------*\
                          Reg and wire
\*-------------------------------------------------------------------*/


wire [            	  15:0] H_to_s        ;
wire [            	  15:0] F_to_s        ;
wire [            	  15:0] F2_to_s        ; //CJ
wire [            	  15:0] score_write   ;
wire [            	  15:0] H1_init_out   ;
wire [            	  15:0] H2_init_out   ;
wire [            	  15:0] E1_init_out   ;
wire [            	  15:0] E2_init_out   ;
wire [CMP_RESULT_WIDTH-1:0] max_result    ;
wire [CMP_RESULT_WIDTH-1:0] row_max_result;
wire [CMP_RESULT_WIDTH-1:0] col_max_result;
wire [			  15:0] diagonal_score;
wire                    start_out     ;
wire                    col_en_out     ;
wire [BT_OUT_WIDTH-1:0]  bt_out        ;//CJ
reg                     start_in      ;
reg  [   EN_LENGTH-1:0] final_row_en  ;
reg                     mode          ;
reg  [            15:0] H_to_pu       ;
reg  [            15:0] F_to_pu       ;
reg  [            15:0] score_init    ;
reg  [            15:0] F2_to_pu       ; //CJ
reg                     bt_en         ;//CJ
reg  [            15:0] H1_init    ;
reg  [            15:0] H2_init    ;
reg  [            15:0] E1_init    ;
reg  [            15:0] E2_init    ;
reg  [RH_BANDWIDTH-1:0] Ns            ;
reg                     max_clear     ;
reg [RH_BANDWIDTH-1:0] Nr_0 		;
reg [LOCATION_WIDTH-1:0] location_0   ;
reg [RH_BANDWIDTH-1:0] Nr_1 		;
reg [LOCATION_WIDTH-1:0] location_1   ;
reg [RH_BANDWIDTH-1:0] Nr_2 		;
reg [LOCATION_WIDTH-1:0] location_2   ;
reg [RH_BANDWIDTH-1:0] Nr_3 		;
reg [LOCATION_WIDTH-1:0] location_3   ;
reg [RH_BANDWIDTH-1:0] Nr_4 		;
reg [LOCATION_WIDTH-1:0] location_4   ;
reg [RH_BANDWIDTH-1:0] Nr_5 		;
reg [LOCATION_WIDTH-1:0] location_5   ;
reg [RH_BANDWIDTH-1:0] Nr_6 		;
reg [LOCATION_WIDTH-1:0] location_6   ;
reg [RH_BANDWIDTH-1:0] Nr_7 		;
reg [LOCATION_WIDTH-1:0] location_7   ;
reg [RH_BANDWIDTH-1:0] Nr_8 		;
reg [LOCATION_WIDTH-1:0] location_8   ;
reg [RH_BANDWIDTH-1:0] Nr_9 		;
reg [LOCATION_WIDTH-1:0] location_9   ;
reg [RH_BANDWIDTH-1:0] Nr_10 		;
reg [LOCATION_WIDTH-1:0] location_10   ;
reg [RH_BANDWIDTH-1:0] Nr_11 		;
reg [LOCATION_WIDTH-1:0] location_11   ;
reg [RH_BANDWIDTH-1:0] Nr_12 		;
reg [LOCATION_WIDTH-1:0] location_12   ;
reg [RH_BANDWIDTH-1:0] Nr_13 		;
reg [LOCATION_WIDTH-1:0] location_13   ;
reg [RH_BANDWIDTH-1:0] Nr_14 		;
reg [LOCATION_WIDTH-1:0] location_14   ;
reg [RH_BANDWIDTH-1:0] Nr_15 		;
reg [LOCATION_WIDTH-1:0] location_15   ;
reg [RH_BANDWIDTH-1:0] Nr_16 		;
reg [LOCATION_WIDTH-1:0] location_16   ;
reg [RH_BANDWIDTH-1:0] Nr_17 		;
reg [LOCATION_WIDTH-1:0] location_17   ;
reg [RH_BANDWIDTH-1:0] Nr_18 		;
reg [LOCATION_WIDTH-1:0] location_18   ;
reg [RH_BANDWIDTH-1:0] Nr_19 		;
reg [LOCATION_WIDTH-1:0] location_19   ;
reg [RH_BANDWIDTH-1:0] Nr_20 		;
reg [LOCATION_WIDTH-1:0] location_20   ;
reg [RH_BANDWIDTH-1:0] Nr_21 		;
reg [LOCATION_WIDTH-1:0] location_21   ;
reg [RH_BANDWIDTH-1:0] Nr_22 		;
reg [LOCATION_WIDTH-1:0] location_22   ;
reg [RH_BANDWIDTH-1:0] Nr_23 		;
reg [LOCATION_WIDTH-1:0] location_23   ;
reg [RH_BANDWIDTH-1:0] Nr_24 		;
reg [LOCATION_WIDTH-1:0] location_24   ;
reg [RH_BANDWIDTH-1:0] Nr_25 		;
reg [LOCATION_WIDTH-1:0] location_25   ;
reg [RH_BANDWIDTH-1:0] Nr_26 		;
reg [LOCATION_WIDTH-1:0] location_26   ;
reg [RH_BANDWIDTH-1:0] Nr_27 		;
reg [LOCATION_WIDTH-1:0] location_27   ;
reg [RH_BANDWIDTH-1:0] Nr_28 		;
reg [LOCATION_WIDTH-1:0] location_28   ;
reg [RH_BANDWIDTH-1:0] Nr_29 		;
reg [LOCATION_WIDTH-1:0] location_29   ;
reg [RH_BANDWIDTH-1:0] Nr_30 		;
reg [LOCATION_WIDTH-1:0] location_30   ;
reg [RH_BANDWIDTH-1:0] Nr_31 		;
reg [LOCATION_WIDTH-1:0] location_31   ;
reg [RH_BANDWIDTH-1:0] Nr_32 		;
reg [LOCATION_WIDTH-1:0] location_32   ;
reg [RH_BANDWIDTH-1:0] Nr_33 		;
reg [LOCATION_WIDTH-1:0] location_33   ;
reg [RH_BANDWIDTH-1:0] Nr_34 		;
reg [LOCATION_WIDTH-1:0] location_34   ;
reg [RH_BANDWIDTH-1:0] Nr_35 		;
reg [LOCATION_WIDTH-1:0] location_35   ;
reg [RH_BANDWIDTH-1:0] Nr_36 		;
reg [LOCATION_WIDTH-1:0] location_36   ;
reg [RH_BANDWIDTH-1:0] Nr_37 		;
reg [LOCATION_WIDTH-1:0] location_37   ;
reg [RH_BANDWIDTH-1:0] Nr_38 		;
reg [LOCATION_WIDTH-1:0] location_38   ;
reg [RH_BANDWIDTH-1:0] Nr_39 		;
reg [LOCATION_WIDTH-1:0] location_39   ;
reg [RH_BANDWIDTH-1:0] Nr_40 		;
reg [LOCATION_WIDTH-1:0] location_40   ;
reg [RH_BANDWIDTH-1:0] Nr_41 		;
reg [LOCATION_WIDTH-1:0] location_41   ;
reg [RH_BANDWIDTH-1:0] Nr_42 		;
reg [LOCATION_WIDTH-1:0] location_42   ;
reg [RH_BANDWIDTH-1:0] Nr_43 		;
reg [LOCATION_WIDTH-1:0] location_43   ;
reg [RH_BANDWIDTH-1:0] Nr_44 		;
reg [LOCATION_WIDTH-1:0] location_44   ;
reg [RH_BANDWIDTH-1:0] Nr_45 		;
reg [LOCATION_WIDTH-1:0] location_45   ;
reg [RH_BANDWIDTH-1:0] Nr_46 		;
reg [LOCATION_WIDTH-1:0] location_46   ;
reg [RH_BANDWIDTH-1:0] Nr_47 		;
reg [LOCATION_WIDTH-1:0] location_47   ;
reg [RH_BANDWIDTH-1:0] Nr_48 		;
reg [LOCATION_WIDTH-1:0] location_48   ;
reg [RH_BANDWIDTH-1:0] Nr_49 		;
reg [LOCATION_WIDTH-1:0] location_49   ;
reg [RH_BANDWIDTH-1:0] Nr_50 		;
reg [LOCATION_WIDTH-1:0] location_50   ;
reg [RH_BANDWIDTH-1:0] Nr_51 		;
reg [LOCATION_WIDTH-1:0] location_51   ;
reg [RH_BANDWIDTH-1:0] Nr_52 		;
reg [LOCATION_WIDTH-1:0] location_52   ;
reg [RH_BANDWIDTH-1:0] Nr_53 		;
reg [LOCATION_WIDTH-1:0] location_53   ;
reg [RH_BANDWIDTH-1:0] Nr_54 		;
reg [LOCATION_WIDTH-1:0] location_54   ;
reg [RH_BANDWIDTH-1:0] Nr_55 		;
reg [LOCATION_WIDTH-1:0] location_55   ;
reg [RH_BANDWIDTH-1:0] Nr_56 		;
reg [LOCATION_WIDTH-1:0] location_56   ;
reg [RH_BANDWIDTH-1:0] Nr_57 		;
reg [LOCATION_WIDTH-1:0] location_57   ;
reg [RH_BANDWIDTH-1:0] Nr_58 		;
reg [LOCATION_WIDTH-1:0] location_58   ;
reg [RH_BANDWIDTH-1:0] Nr_59 		;
reg [LOCATION_WIDTH-1:0] location_59   ;
reg [RH_BANDWIDTH-1:0] Nr_60 		;
reg [LOCATION_WIDTH-1:0] location_60   ;
reg [RH_BANDWIDTH-1:0] Nr_61 		;
reg [LOCATION_WIDTH-1:0] location_61   ;
reg [RH_BANDWIDTH-1:0] Nr_62 		;
reg [LOCATION_WIDTH-1:0] location_62   ;
reg [RH_BANDWIDTH-1:0] Nr_63 		;
reg [LOCATION_WIDTH-1:0] location_63   ;
reg [RH_BANDWIDTH-1:0] Nr_64 		;
reg [LOCATION_WIDTH-1:0] location_64   ;
reg [RH_BANDWIDTH-1:0] Nr_65 		;
reg [LOCATION_WIDTH-1:0] location_65   ;
reg [RH_BANDWIDTH-1:0] Nr_66 		;
reg [LOCATION_WIDTH-1:0] location_66   ;
reg [RH_BANDWIDTH-1:0] Nr_67 		;
reg [LOCATION_WIDTH-1:0] location_67   ;
reg [RH_BANDWIDTH-1:0] Nr_68 		;
reg [LOCATION_WIDTH-1:0] location_68   ;
reg [RH_BANDWIDTH-1:0] Nr_69 		;
reg [LOCATION_WIDTH-1:0] location_69   ;
reg [RH_BANDWIDTH-1:0] Nr_70 		;
reg [LOCATION_WIDTH-1:0] location_70   ;
reg [RH_BANDWIDTH-1:0] Nr_71 		;
reg [LOCATION_WIDTH-1:0] location_71   ;
reg [RH_BANDWIDTH-1:0] Nr_72 		;
reg [LOCATION_WIDTH-1:0] location_72   ;
reg [RH_BANDWIDTH-1:0] Nr_73 		;
reg [LOCATION_WIDTH-1:0] location_73   ;
reg [RH_BANDWIDTH-1:0] Nr_74 		;
reg [LOCATION_WIDTH-1:0] location_74   ;
reg [RH_BANDWIDTH-1:0] Nr_75 		;
reg [LOCATION_WIDTH-1:0] location_75   ;
reg [RH_BANDWIDTH-1:0] Nr_76 		;
reg [LOCATION_WIDTH-1:0] location_76   ;
reg [RH_BANDWIDTH-1:0] Nr_77 		;
reg [LOCATION_WIDTH-1:0] location_77   ;
reg [RH_BANDWIDTH-1:0] Nr_78 		;
reg [LOCATION_WIDTH-1:0] location_78   ;
reg [RH_BANDWIDTH-1:0] Nr_79 		;
reg [LOCATION_WIDTH-1:0] location_79   ;
reg [RH_BANDWIDTH-1:0] Nr_80 		;
reg [LOCATION_WIDTH-1:0] location_80   ;
reg [RH_BANDWIDTH-1:0] Nr_81 		;
reg [LOCATION_WIDTH-1:0] location_81   ;
reg [RH_BANDWIDTH-1:0] Nr_82 		;
reg [LOCATION_WIDTH-1:0] location_82   ;
reg [RH_BANDWIDTH-1:0] Nr_83 		;
reg [LOCATION_WIDTH-1:0] location_83   ;
reg [RH_BANDWIDTH-1:0] Nr_84 		;
reg [LOCATION_WIDTH-1:0] location_84   ;
reg [RH_BANDWIDTH-1:0] Nr_85 		;
reg [LOCATION_WIDTH-1:0] location_85   ;
reg [RH_BANDWIDTH-1:0] Nr_86 		;
reg [LOCATION_WIDTH-1:0] location_86   ;
reg [RH_BANDWIDTH-1:0] Nr_87 		;
reg [LOCATION_WIDTH-1:0] location_87   ;
reg [RH_BANDWIDTH-1:0] Nr_88 		;
reg [LOCATION_WIDTH-1:0] location_88   ;
reg [RH_BANDWIDTH-1:0] Nr_89 		;
reg [LOCATION_WIDTH-1:0] location_89   ;
reg [RH_BANDWIDTH-1:0] Nr_90 		;
reg [LOCATION_WIDTH-1:0] location_90   ;
reg [RH_BANDWIDTH-1:0] Nr_91 		;
reg [LOCATION_WIDTH-1:0] location_91   ;
reg [RH_BANDWIDTH-1:0] Nr_92 		;
reg [LOCATION_WIDTH-1:0] location_92   ;
reg [RH_BANDWIDTH-1:0] Nr_93 		;
reg [LOCATION_WIDTH-1:0] location_93   ;
reg [RH_BANDWIDTH-1:0] Nr_94 		;
reg [LOCATION_WIDTH-1:0] location_94   ;
reg [RH_BANDWIDTH-1:0] Nr_95 		;
reg [LOCATION_WIDTH-1:0] location_95   ;
reg [RH_BANDWIDTH-1:0] Nr_96 		;
reg [LOCATION_WIDTH-1:0] location_96   ;
reg [RH_BANDWIDTH-1:0] Nr_97 		;
reg [LOCATION_WIDTH-1:0] location_97   ;
reg [RH_BANDWIDTH-1:0] Nr_98 		;
reg [LOCATION_WIDTH-1:0] location_98   ;
reg [RH_BANDWIDTH-1:0] Nr_99 		;
reg [LOCATION_WIDTH-1:0] location_99   ;
reg [RH_BANDWIDTH-1:0] Nr_100 		;
reg [LOCATION_WIDTH-1:0] location_100   ;
reg [RH_BANDWIDTH-1:0] Nr_101 		;
reg [LOCATION_WIDTH-1:0] location_101   ;
reg [RH_BANDWIDTH-1:0] Nr_102 		;
reg [LOCATION_WIDTH-1:0] location_102   ;
reg [RH_BANDWIDTH-1:0] Nr_103 		;
reg [LOCATION_WIDTH-1:0] location_103   ;
reg [RH_BANDWIDTH-1:0] Nr_104 		;
reg [LOCATION_WIDTH-1:0] location_104   ;
reg [RH_BANDWIDTH-1:0] Nr_105 		;
reg [LOCATION_WIDTH-1:0] location_105   ;
reg [RH_BANDWIDTH-1:0] Nr_106 		;
reg [LOCATION_WIDTH-1:0] location_106   ;
reg [RH_BANDWIDTH-1:0] Nr_107 		;
reg [LOCATION_WIDTH-1:0] location_107   ;
reg [RH_BANDWIDTH-1:0] Nr_108 		;
reg [LOCATION_WIDTH-1:0] location_108   ;
reg [RH_BANDWIDTH-1:0] Nr_109 		;
reg [LOCATION_WIDTH-1:0] location_109   ;
reg [RH_BANDWIDTH-1:0] Nr_110 		;
reg [LOCATION_WIDTH-1:0] location_110   ;
reg [RH_BANDWIDTH-1:0] Nr_111 		;
reg [LOCATION_WIDTH-1:0] location_111   ;
reg [RH_BANDWIDTH-1:0] Nr_112 		;
reg [LOCATION_WIDTH-1:0] location_112   ;
reg [RH_BANDWIDTH-1:0] Nr_113 		;
reg [LOCATION_WIDTH-1:0] location_113   ;
reg [RH_BANDWIDTH-1:0] Nr_114 		;
reg [LOCATION_WIDTH-1:0] location_114   ;
reg [RH_BANDWIDTH-1:0] Nr_115 		;
reg [LOCATION_WIDTH-1:0] location_115   ;
reg [RH_BANDWIDTH-1:0] Nr_116 		;
reg [LOCATION_WIDTH-1:0] location_116   ;
reg [RH_BANDWIDTH-1:0] Nr_117 		;
reg [LOCATION_WIDTH-1:0] location_117   ;
reg [RH_BANDWIDTH-1:0] Nr_118 		;
reg [LOCATION_WIDTH-1:0] location_118   ;
reg [RH_BANDWIDTH-1:0] Nr_119 		;
reg [LOCATION_WIDTH-1:0] location_119   ;
reg [RH_BANDWIDTH-1:0] Nr_120 		;
reg [LOCATION_WIDTH-1:0] location_120   ;
reg [RH_BANDWIDTH-1:0] Nr_121 		;
reg [LOCATION_WIDTH-1:0] location_121   ;
reg [RH_BANDWIDTH-1:0] Nr_122 		;
reg [LOCATION_WIDTH-1:0] location_122   ;
reg [RH_BANDWIDTH-1:0] Nr_123 		;
reg [LOCATION_WIDTH-1:0] location_123   ;
reg [RH_BANDWIDTH-1:0] Nr_124 		;
reg [LOCATION_WIDTH-1:0] location_124   ;
reg [RH_BANDWIDTH-1:0] Nr_125 		;
reg [LOCATION_WIDTH-1:0] location_125   ;
reg [RH_BANDWIDTH-1:0] Nr_126 		;
reg [LOCATION_WIDTH-1:0] location_126   ;
reg [RH_BANDWIDTH-1:0] Nr_127 		;
reg [LOCATION_WIDTH-1:0] location_127   ;




wire                    sw_start_in          [6:0];
wire [   EN_LENGTH-1:0] sw_final_row_en      [6:0];
wire                    sw_mode              [6:0];
wire [            15:0] sw_H_to_pu           [6:0];
wire [            15:0] sw_F_to_pu           [6:0];
wire [            15:0] sw_F2_to_pu          [6:0];//CJ
wire                     sw_bt_en             [6:0];//CJ
wire [            15:0] sw_score_init        [6:0];
wire [RH_BANDWIDTH-1:0] sw_Ns                [6:0];
wire                    sw_parameter_vld     [6:0];
wire                    sw_max_clear         [6:0];
wire [RH_BANDWIDTH-1:0] sw_Nr                [6:0];
wire [LOCATION_WIDTH-1:0] sw_location          [6:0];
wire [CIRCLE_SUM_BIT:0] sw_pe_cnt            [6:0];
wire 					sw_pkt_receive_enable[6:0];
wire [RESULT_LENGTH-1:0] sw_result 			 [6:0];
wire 					sw_result_vld 		 [6:0];

reg                     vld                  [6:0];
reg  [            15:0] sw_H_to_s            [6:0];
reg  [            15:0] sw_F_to_s            [6:0];
reg  [            15:0] sw_F2_to_s           [6:0];//CJ
reg  [BT_OUT_WIDTH-1:0] sw_bt_to_s           [6:0];//CJ
reg  [            15:0] sw_score_write       [6:0];
reg  [CMP_RESULT_WIDTH-1:0] sw_max_result        [6:0];
reg  [CMP_RESULT_WIDTH-1:0] sw_row_max_result    [6:0];
reg  [CMP_RESULT_WIDTH-1:0] sw_col_max_result    [6:0];
reg  [            15:0] sw_diagonal_score    [6:0];
reg                     sw_start_out         [6:0];
reg  [            31:0] sw_matrix_memory_data[6:0];
reg                     sw_matrix_memory_sop [6:0];
reg                     sw_matrix_memory_eop [6:0];
reg                     sw_matrix_memory_vld [6:0];
reg  [		15 : 0 ]    sw_H1_init_in [6:0];
reg  [		15 : 0 ]    sw_H2_init_in [6:0];
reg  [		15 : 0 ]    sw_E1_init_in [6:0];
reg  [		15 : 0 ]    sw_E2_init_in [6:0];
reg      sw_col_en [6:0];

wire  [		15 : 0 ]    sw_H1_init_out [6:0];
wire  [		15 : 0 ]    sw_H2_init_out [6:0];
wire  [		15 : 0 ]    sw_E1_init_out [6:0];
wire  [		15 : 0 ]    sw_E2_init_out [6:0];
reg   [CMP_RESULT_WIDTH-1: 0 ]    sw_col_max_temp_in [6:0];
wire  [CMP_RESULT_WIDTH-1: 0 ]    sw_col_max_temp_out [6:0];
reg   [CMP_RESULT_WIDTH-1: 0 ]    U_col_max_temp_in;
wire  [CMP_RESULT_WIDTH-1: 0 ]    U_col_max_temp_out;




reg  [RH_BANDWIDTH-1:0] sw_Nr_0       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_0 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_1       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_1 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_2       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_2 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_3       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_3 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_4       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_4 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_5       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_5 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_6       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_6 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_7       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_7 	 [6:0];

reg  [RH_BANDWIDTH-1:0] sw_Nr_8       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_8 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_9       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_9 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_10       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_10 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_11       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_11 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_12       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_12 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_13       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_13 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_14       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_14 	 [6:0];
reg  [RH_BANDWIDTH-1:0] sw_Nr_15       	 [6:0];
reg  [LOCATION_WIDTH-1:0] sw_location_15 	 [6:0];


reg [RH_BANDWIDTH-1:0] sw_Nr_16 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_16    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_17 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_17    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_18 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_18    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_19 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_19    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_20 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_20    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_21 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_21    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_22 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_22    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_23 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_23    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_24 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_24    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_25 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_25    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_26 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_26    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_27 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_27    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_28 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_28    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_29 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_29    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_30 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_30    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_31 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_31    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_32 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_32    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_33 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_33    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_34 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_34    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_35 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_35    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_36 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_36    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_37 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_37    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_38 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_38    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_39 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_39    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_40 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_40    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_41 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_41    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_42 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_42    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_43 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_43    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_44 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_44    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_45 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_45    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_46 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_46    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_47 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_47    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_48 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_48    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_49 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_49    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_50 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_50    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_51 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_51    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_52 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_52    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_53 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_53    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_54 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_54    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_55 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_55    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_56 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_56    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_57 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_57    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_58 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_58    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_59 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_59    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_60 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_60    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_61 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_61    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_62 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_62    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_63 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_63    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_64 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_64    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_65 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_65    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_66 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_66    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_67 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_67    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_68 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_68    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_69 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_69    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_70 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_70    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_71 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_71    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_72 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_72    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_73 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_73    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_74 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_74    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_75 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_75    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_76 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_76    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_77 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_77    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_78 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_78    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_79 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_79    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_80 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_80    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_81 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_81    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_82 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_82    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_83 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_83    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_84 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_84    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_85 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_85    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_86 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_86    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_87 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_87    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_88 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_88    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_89 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_89    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_90 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_90    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_91 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_91    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_92 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_92    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_93 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_93    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_94 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_94    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_95 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_95    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_96 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_96    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_97 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_97    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_98 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_98    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_99 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_99    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_100 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_100    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_101 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_101    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_102 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_102    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_103 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_103    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_104 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_104    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_105 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_105    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_106 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_106    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_107 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_107    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_108 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_108    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_109 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_109    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_110 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_110    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_111 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_111    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_112 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_112    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_113 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_113    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_114 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_114    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_115 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_115    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_116 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_116    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_117 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_117    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_118 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_118    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_119 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_119    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_120 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_120    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_121 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_121    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_122 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_122    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_123 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_123    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_124 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_124    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_125 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_125    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_126 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_126    [6:0];
reg [RH_BANDWIDTH-1:0] sw_Nr_127 		 [6:0];
reg [LOCATION_WIDTH-1:0] sw_location_127    [6:0];



wire sw_fifo_start [6:0];
wire sw_fifo_vld   [6:0];
wire sw_fifo_empty [6:0];
wire sw_fifo_eop   [6:0];
wire [63:0]sw_fifo_data [6:0];

(* mark_debug = "true" *) reg  [RESULT_LENGTH-1:0] fifo_data_in    ;
wire [RESULT_LENGTH-1:0] fifo_data_out   ;
wire [  9:0] usedw           ;
(* mark_debug = "true" *)reg          fifo_write_en   ;
wire         fifo_almost_full;
wire         full            ; 


reg [6:0] current_state;
reg [6:0] next_state   ;

reg  temp_enable1     ;
reg  temp_enable2     ;
wire S_done      [6:0];

/*-------------------------------------------------------------------*\
                                 Main code       
\*-------------------------------------------------------------------*/
//temp_enable1:表明计算通道空闲 temp_enable2:表明FIFO还有空余空间
assign pkt_receive_enable = temp_enable1 & temp_enable2;

always @(posedge sys_clk or negedge sys_rst_n) begin 
	if(~sys_rst_n) begin
		temp_enable2 <= 1'b0;
	end else if (fifo_almost_full && matrix_memory_sop ) begin
		temp_enable2 <= 1'b0;
	end else if (!fifo_almost_full)
		temp_enable2 <= 1'b1;
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin 
		current_state <= 7'b0000001;
	end else begin 
		current_state <= next_state;
	end 
end

//current_state表示目前正在为哪个计算通道传输数据
//只有当当前通道得数据传输完成后，并且下一个数据还没开始传输时，才会进行状态切换
always @(*)
begin
	next_state = current_state;
	case (current_state)
		S0: begin 
			if (S_done[0]) begin 
				next_state = S1;
			end
		end

		S1: begin 
			if (S_done[1]) begin
				next_state = S2;
			end
		end

		S2: begin 
			if (S_done[2]) begin 
				next_state = S3;
			end
		end

		S3: begin 
			if (S_done[3]) begin 
				next_state = S4;
			end
		end

		S4: begin 
			if (S_done[4]) begin 
				next_state = S5;
			end
		end

		S5: begin 
			if (S_done[5]) begin 
				next_state = S6;
			end
		end

		S6: begin 
			if (S_done[6]) begin 
				next_state = S0;
			end
		end
	endcase // current_state
end

always @(posedge sys_clk or negedge sys_rst_n)
begin 
	if (!sys_rst_n) begin
		temp_enable1 <= 1'b0;
	end else begin 
	case (current_state)
		S0: begin 
				temp_enable1 <= sw_pkt_receive_enable[0];
			end

		S1: begin 
				temp_enable1 <= sw_pkt_receive_enable[1];
			end

		S2: begin 
				temp_enable1 <= sw_pkt_receive_enable[2];
			end

		S3: begin 
				temp_enable1 <= sw_pkt_receive_enable[3];
			end

		S4: begin 
				temp_enable1 <= sw_pkt_receive_enable[4];
			end

		S5: begin 
				temp_enable1 <= sw_pkt_receive_enable[5];
			end

		S6: begin 
				temp_enable1 <= sw_pkt_receive_enable[6];
			end
	endcase
	end
end

genvar gen_i;
generate
for (gen_i=0;gen_i<7;gen_i=gen_i + 1) 
begin : matrix_data_in

	assign S_done[gen_i] = (!sw_pkt_receive_enable[gen_i]) & (matrix_memory_vld != 1);

	always @(posedge sys_clk ) begin
		if (current_state[gen_i]) begin 
			sw_matrix_memory_sop[gen_i]  <= matrix_memory_sop;
			sw_matrix_memory_eop[gen_i]  <= matrix_memory_eop;
			sw_matrix_memory_vld[gen_i]  <= matrix_memory_vld;
			sw_matrix_memory_data[gen_i] <= matrix_memory_data;
		end else begin
			sw_matrix_memory_sop[gen_i]  <= 1'b0;
			sw_matrix_memory_eop[gen_i]  <= 1'b0;
			sw_matrix_memory_vld[gen_i]  <= 1'b0;
			sw_matrix_memory_data[gen_i] <= 32'd0;
		end
	end
end
endgenerate
//shift_reg就是T_clk的意思
reg [6:0] shift_reg;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		shift_reg <= 7'b0000001;
	end else begin 
		shift_reg <= {shift_reg[5:0],shift_reg[6]};
	end 
end

genvar gen_j;
generate
for (gen_j = 0 ; gen_j < 7 ; gen_j = gen_j + 1)
begin:vld_signal
	always @(posedge sys_clk)
	begin 
	 	if (shift_reg[gen_j]) begin
			vld[gen_j] <= 1'b1;
		end else begin
			vld[gen_j] <= 1'b0;
		end
	end
end	
endgenerate

/*-------------------------------------------------------------------*\
                          sw_send to PU16
\*-------------------------------------------------------------------*/
//在不同的时刻将sw_send的数据传入PU
always @(posedge sys_clk)
begin
	case (shift_reg)
		T0:begin
			start_in     <= sw_start_in[6]	  ;
			final_row_en <= sw_final_row_en[6];
			mode         <= sw_mode[6]		  ;
			H_to_pu      <= sw_H_to_pu[6]	  ;
			F_to_pu      <= sw_F_to_pu[6]	  ;
			F2_to_pu      <= sw_F2_to_pu[6]	  ;//CJ
			score_init   <= sw_score_init[6]  ;
			Ns           <= sw_Ns[6]		  ;
			max_clear    <= sw_max_clear[6]	  ;
			H1_init 	 <= sw_H1_init_out[6] ;//CJ
			bt_en        <= sw_bt_en[6]       ;//CJ
			H2_init 	 <= sw_H2_init_out[6] ;
			E1_init 	 <= sw_E1_init_out[6] ;
			E2_init 	 <= sw_E2_init_out[6] ;
			U_col_max_temp_in <= sw_col_max_temp_out[6];
		end // T0:

		T1: begin
			start_in     <= sw_start_in[0]	  ;
			final_row_en <= sw_final_row_en[0];
			mode         <= sw_mode[0]		  ;
			H_to_pu      <= sw_H_to_pu[0]	  ;
			F_to_pu      <= sw_F_to_pu[0]	  ;
			F2_to_pu      <= sw_F2_to_pu[0]	  ;//CJ
			score_init   <= sw_score_init[0]  ;
			Ns           <= sw_Ns[0]		  ;
			max_clear    <= sw_max_clear[0]	  ;
			H1_init 	 <= sw_H1_init_out[0] ;//CJ
			bt_en        <= sw_bt_en[0]       ;//CJ
			H2_init 	 <= sw_H2_init_out[0] ;
			E1_init 	 <= sw_E1_init_out[0] ;
			E2_init 	 <= sw_E2_init_out[0] ;
			U_col_max_temp_in <= sw_col_max_temp_out[0];
		end // T1:

		T2:begin
			start_in     <= sw_start_in[1]	  ;
			final_row_en <= sw_final_row_en[1];
			mode         <= sw_mode[1]		  ;
			H_to_pu      <= sw_H_to_pu[1]	  ;
			F_to_pu      <= sw_F_to_pu[1]	  ;
			F2_to_pu      <= sw_F2_to_pu[1]	  ;//CJ
			score_init   <= sw_score_init[1]  ;
			Ns           <= sw_Ns[1]		  ;
			max_clear    <= sw_max_clear[1]	  ;
			H1_init 	 <= sw_H1_init_out[1] ;//CJ
			bt_en        <= sw_bt_en[1]       ;//CJ
			H2_init 	 <= sw_H2_init_out[1] ;
			E1_init 	 <= sw_E1_init_out[1] ;
			E2_init 	 <= sw_E2_init_out[1] ;
			U_col_max_temp_in <= sw_col_max_temp_out[1];
		end // T2:

		T3:begin
			start_in     <= sw_start_in[2]	  ;
			final_row_en <= sw_final_row_en[2];
			mode         <= sw_mode[2]		  ;
			H_to_pu      <= sw_H_to_pu[2]	  ;
			F_to_pu      <= sw_F_to_pu[2]	  ;
			F2_to_pu      <= sw_F2_to_pu[2]	  ; //CJ
			score_init   <= sw_score_init[2]  ;
			Ns           <= sw_Ns[2]		  ;
			max_clear    <= sw_max_clear[2]	  ;
			H1_init 	 <= sw_H1_init_out[2] ;//CJ
			bt_en        <= sw_bt_en[2]       ;//CJ
			H2_init 	 <= sw_H2_init_out[2] ;
			E1_init 	 <= sw_E1_init_out[2] ;
			E2_init 	 <= sw_E2_init_out[2] ;
			U_col_max_temp_in <= sw_col_max_temp_out[2];
        end
        
		T4:begin
			start_in     <= sw_start_in[3]	  ;
			final_row_en <= sw_final_row_en[3];
			mode         <= sw_mode[3]		  ;
			H_to_pu      <= sw_H_to_pu[3]	  ;
			F_to_pu      <= sw_F_to_pu[3]	  ;
			F2_to_pu      <= sw_F2_to_pu[3]	  ;//CJ
			score_init   <= sw_score_init[3]  ;
			Ns           <= sw_Ns[3]		  ;
			max_clear    <= sw_max_clear[3]	  ;
			H1_init 	 <= sw_H1_init_out[3] ;//CJ
			bt_en        <= sw_bt_en[3]       ;//CJ
			H2_init 	 <= sw_H2_init_out[3] ;
			E1_init 	 <= sw_E1_init_out[3] ;
			E2_init 	 <= sw_E2_init_out[3] ;
			U_col_max_temp_in <= sw_col_max_temp_out[3];
		end // T4:

		T5:begin
			start_in     <= sw_start_in[4]	  ;
			final_row_en <= sw_final_row_en[4];
			mode         <= sw_mode[4]		  ;
			H_to_pu      <= sw_H_to_pu[4]	  ;
			F_to_pu      <= sw_F_to_pu[4]	  ;
			F2_to_pu      <= sw_F2_to_pu[4]	  ;//CJ
			score_init   <= sw_score_init[4]  ;
			Ns           <= sw_Ns[4]		  ;
			max_clear    <= sw_max_clear[4]	  ;
			H1_init 	 <= sw_H1_init_out[4] ;//CJ
			bt_en        <= sw_bt_en[4]       ;//CJ
			H2_init 	 <= sw_H2_init_out[4] ;
			E1_init 	 <= sw_E1_init_out[4] ;
			E2_init 	 <= sw_E2_init_out[4] ;
			U_col_max_temp_in <= sw_col_max_temp_out[4];
		end // T5:

		T6:begin
			start_in     <= sw_start_in[5]	  ;
			final_row_en <= sw_final_row_en[5];
			mode         <= sw_mode[5]		  ;
			H_to_pu      <= sw_H_to_pu[5]	  ;
			F_to_pu      <= sw_F_to_pu[5]	  ;
			F2_to_pu      <= sw_F2_to_pu[5]	  ;//CJ
			score_init   <= sw_score_init[5]  ;
			Ns           <= sw_Ns[5]		  ;
			max_clear    <= sw_max_clear[5]	  ;
			H1_init 	 <= sw_H1_init_out[5] ;//CJ
			bt_en        <= sw_bt_en[5]       ;//CJ
			H2_init 	 <= sw_H2_init_out[5] ;
			E1_init 	 <= sw_E1_init_out[5] ;
			E2_init 	 <= sw_E2_init_out[5] ;
			U_col_max_temp_in <= sw_col_max_temp_out[5];
		end // T6:
	endcase //
end

genvar gen_k;
generate
for(gen_k = 0; gen_k <7 ; gen_k = gen_k + 1)
begin:reg_group
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin 
			sw_Nr_0[gen_k] <=  4'b0;
			sw_Nr_1[gen_k] <=  4'b0;
			sw_Nr_2[gen_k] <=  4'b0;
			sw_Nr_3[gen_k] <=  4'b0;
			sw_Nr_4[gen_k] <=  4'b0;
			sw_Nr_5[gen_k] <=  4'b0;
			sw_Nr_6[gen_k] <=  4'b0;
			sw_Nr_7[gen_k] <=  4'b0;
			sw_Nr_8[gen_k] <=  4'b0;
			sw_Nr_9[gen_k] <=  4'b0;
			sw_Nr_10[gen_k] <= 4'b0;
			sw_Nr_11[gen_k] <= 4'b0;
			sw_Nr_12[gen_k] <= 4'b0;
			sw_Nr_13[gen_k] <= 4'b0;
			sw_Nr_14[gen_k] <= 4'b0;
			sw_Nr_15[gen_k] <= 4'b0;

			sw_Nr_16[gen_k] <= 4'b0;
			sw_Nr_17[gen_k] <= 4'b0;
			sw_Nr_18[gen_k] <= 4'b0;
			sw_Nr_19[gen_k] <= 4'b0;
			sw_Nr_20[gen_k] <= 4'b0;
			sw_Nr_21[gen_k] <= 4'b0;
			sw_Nr_22[gen_k] <= 4'b0;
			sw_Nr_23[gen_k] <= 4'b0;
			sw_Nr_24[gen_k] <= 4'b0;
			sw_Nr_25[gen_k] <= 4'b0;
			sw_Nr_26[gen_k] <= 4'b0;
			sw_Nr_27[gen_k] <= 4'b0;
			sw_Nr_28[gen_k] <= 4'b0;
			sw_Nr_29[gen_k] <= 4'b0;
			sw_Nr_30[gen_k] <= 4'b0;
			sw_Nr_31[gen_k] <= 4'b0;

			sw_Nr_32[gen_k] <= 4'b0; 
			sw_Nr_33[gen_k] <= 4'b0; 
			sw_Nr_34[gen_k] <= 4'b0; 
			sw_Nr_35[gen_k] <= 4'b0; 
			sw_Nr_36[gen_k] <= 4'b0; 
			sw_Nr_37[gen_k] <= 4'b0; 
			sw_Nr_38[gen_k] <= 4'b0; 
			sw_Nr_39[gen_k] <= 4'b0; 
			sw_Nr_40[gen_k] <= 4'b0; 
			sw_Nr_41[gen_k] <= 4'b0; 
			sw_Nr_42[gen_k] <= 4'b0; 
			sw_Nr_43[gen_k] <= 4'b0; 
			sw_Nr_44[gen_k] <= 4'b0; 
			sw_Nr_45[gen_k] <= 4'b0; 
			sw_Nr_46[gen_k] <= 4'b0; 
			sw_Nr_47[gen_k] <= 4'b0; 
			sw_Nr_48[gen_k] <= 4'b0; 
			sw_Nr_49[gen_k] <= 4'b0; 
			sw_Nr_50[gen_k] <= 4'b0; 
			sw_Nr_51[gen_k] <= 4'b0; 
			sw_Nr_52[gen_k] <= 4'b0; 
			sw_Nr_53[gen_k] <= 4'b0; 
			sw_Nr_54[gen_k] <= 4'b0; 
			sw_Nr_55[gen_k] <= 4'b0; 
			sw_Nr_56[gen_k] <= 4'b0; 
			sw_Nr_57[gen_k] <= 4'b0; 
			sw_Nr_58[gen_k] <= 4'b0; 
			sw_Nr_59[gen_k] <= 4'b0; 
			sw_Nr_60[gen_k] <= 4'b0; 
			sw_Nr_61[gen_k] <= 4'b0; 
			sw_Nr_62[gen_k] <= 4'b0; 
			sw_Nr_63[gen_k] <= 4'b0; 

			sw_Nr_64[gen_k] <= 4'b0     ;
			sw_Nr_65[gen_k] <= 4'b0     ;
			sw_Nr_66[gen_k] <= 4'b0     ;
			sw_Nr_67[gen_k] <= 4'b0     ;
			sw_Nr_68[gen_k] <= 4'b0     ;
			sw_Nr_69[gen_k] <= 4'b0     ;
			sw_Nr_70[gen_k] <= 4'b0     ;
			sw_Nr_71[gen_k] <= 4'b0     ;
			sw_Nr_72[gen_k] <= 4'b0     ;
			sw_Nr_73[gen_k] <= 4'b0     ;
			sw_Nr_74[gen_k] <= 4'b0     ;
			sw_Nr_75[gen_k] <= 4'b0     ;
			sw_Nr_76[gen_k] <= 4'b0     ;
			sw_Nr_77[gen_k] <= 4'b0     ;
			sw_Nr_78[gen_k] <= 4'b0     ;
			sw_Nr_79[gen_k] <= 4'b0     ;
			sw_Nr_80[gen_k] <= 4'b0     ;
			sw_Nr_81[gen_k] <= 4'b0     ;
			sw_Nr_82[gen_k] <= 4'b0     ;
			sw_Nr_83[gen_k] <= 4'b0     ;
			sw_Nr_84[gen_k] <= 4'b0     ;
			sw_Nr_85[gen_k] <= 4'b0     ;
			sw_Nr_86[gen_k] <= 4'b0     ;
			sw_Nr_87[gen_k] <= 4'b0     ;
			sw_Nr_88[gen_k] <= 4'b0     ;
			sw_Nr_89[gen_k] <= 4'b0     ;
			sw_Nr_90[gen_k] <= 4'b0     ;
			sw_Nr_91[gen_k] <= 4'b0     ;
			sw_Nr_92[gen_k] <= 4'b0     ;
			sw_Nr_93[gen_k] <= 4'b0     ;
			sw_Nr_94[gen_k] <= 4'b0     ;
			sw_Nr_95[gen_k] <= 4'b0     ;
			sw_Nr_96[gen_k] <= 4'b0     ;
			sw_Nr_97[gen_k] <= 4'b0     ;
			sw_Nr_98[gen_k] <= 4'b0     ;
			sw_Nr_99[gen_k] <= 4'b0     ;
			sw_Nr_100[gen_k] <= 4'b0     ;
			sw_Nr_101[gen_k] <= 4'b0     ;
			sw_Nr_102[gen_k] <= 4'b0     ;
			sw_Nr_103[gen_k] <= 4'b0     ;
			sw_Nr_104[gen_k] <= 4'b0     ;
			sw_Nr_105[gen_k] <= 4'b0     ;
			sw_Nr_106[gen_k] <= 4'b0     ;
			sw_Nr_107[gen_k] <= 4'b0     ;
			sw_Nr_108[gen_k] <= 4'b0     ;
			sw_Nr_109[gen_k] <= 4'b0     ;
			sw_Nr_110[gen_k] <= 4'b0     ;
			sw_Nr_111[gen_k] <= 4'b0     ;
			sw_Nr_112[gen_k] <= 4'b0     ;
			sw_Nr_113[gen_k] <= 4'b0     ;
			sw_Nr_114[gen_k] <= 4'b0     ;
			sw_Nr_115[gen_k] <= 4'b0     ;
			sw_Nr_116[gen_k] <= 4'b0     ;
			sw_Nr_117[gen_k] <= 4'b0     ;
			sw_Nr_118[gen_k] <= 4'b0     ;
			sw_Nr_119[gen_k] <= 4'b0     ;
			sw_Nr_120[gen_k] <= 4'b0     ;
			sw_Nr_121[gen_k] <= 4'b0     ;
			sw_Nr_122[gen_k] <= 4'b0     ;
			sw_Nr_123[gen_k] <= 4'b0     ;
			sw_Nr_124[gen_k] <= 4'b0     ;
			sw_Nr_125[gen_k] <= 4'b0     ;
			sw_Nr_126[gen_k] <= 4'b0     ;
			sw_Nr_127[gen_k] <= 4'b0     ;


		end else if (sw_parameter_vld[gen_k]) begin 
			case (sw_pe_cnt[gen_k]) 
				7'b0000000:sw_Nr_0[gen_k] <= sw_Nr[gen_k];
				7'b0000001:sw_Nr_1[gen_k] <= sw_Nr[gen_k];
				7'b0000010:sw_Nr_2[gen_k] <= sw_Nr[gen_k];
				7'b0000011:sw_Nr_3[gen_k] <= sw_Nr[gen_k];
				7'b0000100:sw_Nr_4[gen_k] <= sw_Nr[gen_k];
				7'b0000101:sw_Nr_5[gen_k] <= sw_Nr[gen_k];
				7'b0000110:sw_Nr_6[gen_k] <= sw_Nr[gen_k];
				7'b0000111:sw_Nr_7[gen_k] <= sw_Nr[gen_k];
				7'b0001000:sw_Nr_8[gen_k] <= sw_Nr[gen_k];
				7'b0001001:sw_Nr_9[gen_k] <= sw_Nr[gen_k];
				7'b0001010:sw_Nr_10[gen_k] <= sw_Nr[gen_k];
				7'b0001011:sw_Nr_11[gen_k] <= sw_Nr[gen_k];
				7'b0001100:sw_Nr_12[gen_k] <= sw_Nr[gen_k];
				7'b0001101:sw_Nr_13[gen_k] <= sw_Nr[gen_k];
				7'b0001110:sw_Nr_14[gen_k] <= sw_Nr[gen_k];
				7'b0001111:sw_Nr_15[gen_k] <= sw_Nr[gen_k];

				7'b0010000:sw_Nr_16[gen_k] <= sw_Nr[gen_k];
				7'b0010001:sw_Nr_17[gen_k] <= sw_Nr[gen_k];
				7'b0010010:sw_Nr_18[gen_k] <= sw_Nr[gen_k];
				7'b0010011:sw_Nr_19[gen_k] <= sw_Nr[gen_k];
				7'b0010100:sw_Nr_20[gen_k] <= sw_Nr[gen_k];
				7'b0010101:sw_Nr_21[gen_k] <= sw_Nr[gen_k];
				7'b0010110:sw_Nr_22[gen_k] <= sw_Nr[gen_k];
				7'b0010111:sw_Nr_23[gen_k] <= sw_Nr[gen_k];
				7'b0011000:sw_Nr_24[gen_k] <= sw_Nr[gen_k];
				7'b0011001:sw_Nr_25[gen_k] <= sw_Nr[gen_k];
				7'b0011010:sw_Nr_26[gen_k] <= sw_Nr[gen_k];
				7'b0011011:sw_Nr_27[gen_k] <= sw_Nr[gen_k];
				7'b0011100:sw_Nr_28[gen_k] <= sw_Nr[gen_k];
				7'b0011101:sw_Nr_29[gen_k] <= sw_Nr[gen_k];
				7'b0011110:sw_Nr_30[gen_k] <= sw_Nr[gen_k];
				7'b0011111:sw_Nr_31[gen_k] <= sw_Nr[gen_k];

				7'b0100000:sw_Nr_32[gen_k] <= sw_Nr[gen_k];
				7'b0100001:sw_Nr_33[gen_k] <= sw_Nr[gen_k];
				7'b0100010:sw_Nr_34[gen_k] <= sw_Nr[gen_k];
				7'b0100011:sw_Nr_35[gen_k] <= sw_Nr[gen_k];
				7'b0100100:sw_Nr_36[gen_k] <= sw_Nr[gen_k];
				7'b0100101:sw_Nr_37[gen_k] <= sw_Nr[gen_k];
				7'b0100110:sw_Nr_38[gen_k] <= sw_Nr[gen_k];
				7'b0100111:sw_Nr_39[gen_k] <= sw_Nr[gen_k];
				7'b0101000:sw_Nr_40[gen_k] <= sw_Nr[gen_k];
				7'b0101001:sw_Nr_41[gen_k] <= sw_Nr[gen_k];
				7'b0101010:sw_Nr_42[gen_k] <= sw_Nr[gen_k];
				7'b0101011:sw_Nr_43[gen_k] <= sw_Nr[gen_k];
				7'b0101100:sw_Nr_44[gen_k] <= sw_Nr[gen_k];
				7'b0101101:sw_Nr_45[gen_k] <= sw_Nr[gen_k];
				7'b0101110:sw_Nr_46[gen_k] <= sw_Nr[gen_k];
				7'b0101111:sw_Nr_47[gen_k] <= sw_Nr[gen_k];
				7'b0110000:sw_Nr_48[gen_k] <= sw_Nr[gen_k];
				7'b0110001:sw_Nr_49[gen_k] <= sw_Nr[gen_k];
				7'b0110010:sw_Nr_50[gen_k] <= sw_Nr[gen_k];
				7'b0110011:sw_Nr_51[gen_k] <= sw_Nr[gen_k];
				7'b0110100:sw_Nr_52[gen_k] <= sw_Nr[gen_k];
				7'b0110101:sw_Nr_53[gen_k] <= sw_Nr[gen_k];
				7'b0110110:sw_Nr_54[gen_k] <= sw_Nr[gen_k];
				7'b0110111:sw_Nr_55[gen_k] <= sw_Nr[gen_k];
				7'b0111000:sw_Nr_56[gen_k] <= sw_Nr[gen_k];
				7'b0111001:sw_Nr_57[gen_k] <= sw_Nr[gen_k];
				7'b0111010:sw_Nr_58[gen_k] <= sw_Nr[gen_k];
				7'b0111011:sw_Nr_59[gen_k] <= sw_Nr[gen_k];
				7'b0111100:sw_Nr_60[gen_k] <= sw_Nr[gen_k];
				7'b0111101:sw_Nr_61[gen_k] <= sw_Nr[gen_k];
				7'b0111110:sw_Nr_62[gen_k] <= sw_Nr[gen_k];
				7'b0111111:sw_Nr_63[gen_k] <= sw_Nr[gen_k];

				7'b1000000:sw_Nr_64[gen_k] <= sw_Nr[gen_k];
				7'b1000001:sw_Nr_65[gen_k] <= sw_Nr[gen_k];
				7'b1000010:sw_Nr_66[gen_k] <= sw_Nr[gen_k];
				7'b1000011:sw_Nr_67[gen_k] <= sw_Nr[gen_k];
				7'b1000100:sw_Nr_68[gen_k] <= sw_Nr[gen_k];
				7'b1000101:sw_Nr_69[gen_k] <= sw_Nr[gen_k];
				7'b1000110:sw_Nr_70[gen_k] <= sw_Nr[gen_k];
				7'b1000111:sw_Nr_71[gen_k] <= sw_Nr[gen_k];
				7'b1001000:sw_Nr_72[gen_k] <= sw_Nr[gen_k];
				7'b1001001:sw_Nr_73[gen_k] <= sw_Nr[gen_k];
				7'b1001010:sw_Nr_74[gen_k] <= sw_Nr[gen_k];
				7'b1001011:sw_Nr_75[gen_k] <= sw_Nr[gen_k];
				7'b1001100:sw_Nr_76[gen_k] <= sw_Nr[gen_k];
				7'b1001101:sw_Nr_77[gen_k] <= sw_Nr[gen_k];
				7'b1001110:sw_Nr_78[gen_k] <= sw_Nr[gen_k];
				7'b1001111:sw_Nr_79[gen_k] <= sw_Nr[gen_k];
				7'b1010000:sw_Nr_80[gen_k] <= sw_Nr[gen_k];
				7'b1010001:sw_Nr_81[gen_k] <= sw_Nr[gen_k];
				7'b1010010:sw_Nr_82[gen_k] <= sw_Nr[gen_k];
				7'b1010011:sw_Nr_83[gen_k] <= sw_Nr[gen_k];
				7'b1010100:sw_Nr_84[gen_k] <= sw_Nr[gen_k];
				7'b1010101:sw_Nr_85[gen_k] <= sw_Nr[gen_k];
				7'b1010110:sw_Nr_86[gen_k] <= sw_Nr[gen_k];
				7'b1010111:sw_Nr_87[gen_k] <= sw_Nr[gen_k];
				7'b1011000:sw_Nr_88[gen_k] <= sw_Nr[gen_k];
				7'b1011001:sw_Nr_89[gen_k] <= sw_Nr[gen_k];
				7'b1011010:sw_Nr_90[gen_k] <= sw_Nr[gen_k];
				7'b1011011:sw_Nr_91[gen_k] <= sw_Nr[gen_k];
				7'b1011100:sw_Nr_92[gen_k] <= sw_Nr[gen_k];
				7'b1011101:sw_Nr_93[gen_k] <= sw_Nr[gen_k];
				7'b1011110:sw_Nr_94[gen_k] <= sw_Nr[gen_k];
				7'b1011111:sw_Nr_95[gen_k] <= sw_Nr[gen_k];
				7'b1100000:sw_Nr_96[gen_k] <= sw_Nr[gen_k];
				7'b1100001:sw_Nr_97[gen_k] <= sw_Nr[gen_k];
				7'b1100010:sw_Nr_98[gen_k] <= sw_Nr[gen_k];
				7'b1100011:sw_Nr_99[gen_k] <= sw_Nr[gen_k];
				7'b1100100:sw_Nr_100[gen_k] <= sw_Nr[gen_k];
				7'b1100101:sw_Nr_101[gen_k] <= sw_Nr[gen_k];
				7'b1100110:sw_Nr_102[gen_k] <= sw_Nr[gen_k];
				7'b1100111:sw_Nr_103[gen_k] <= sw_Nr[gen_k];
				7'b1101000:sw_Nr_104[gen_k] <= sw_Nr[gen_k];
				7'b1101001:sw_Nr_105[gen_k] <= sw_Nr[gen_k];
				7'b1101010:sw_Nr_106[gen_k] <= sw_Nr[gen_k];
				7'b1101011:sw_Nr_107[gen_k] <= sw_Nr[gen_k];
				7'b1101100:sw_Nr_108[gen_k] <= sw_Nr[gen_k];
				7'b1101101:sw_Nr_109[gen_k] <= sw_Nr[gen_k];
				7'b1101110:sw_Nr_110[gen_k] <= sw_Nr[gen_k];
				7'b1101111:sw_Nr_111[gen_k] <= sw_Nr[gen_k];
				7'b1110000:sw_Nr_112[gen_k] <= sw_Nr[gen_k];
				7'b1110001:sw_Nr_113[gen_k] <= sw_Nr[gen_k];
				7'b1110010:sw_Nr_114[gen_k] <= sw_Nr[gen_k];
				7'b1110011:sw_Nr_115[gen_k] <= sw_Nr[gen_k];
				7'b1110100:sw_Nr_116[gen_k] <= sw_Nr[gen_k];
				7'b1110101:sw_Nr_117[gen_k] <= sw_Nr[gen_k];
				7'b1110110:sw_Nr_118[gen_k] <= sw_Nr[gen_k];
				7'b1110111:sw_Nr_119[gen_k] <= sw_Nr[gen_k];
				7'b1111000:sw_Nr_120[gen_k] <= sw_Nr[gen_k];
				7'b1111001:sw_Nr_121[gen_k] <= sw_Nr[gen_k];
				7'b1111010:sw_Nr_122[gen_k] <= sw_Nr[gen_k];
				7'b1111011:sw_Nr_123[gen_k] <= sw_Nr[gen_k];
				7'b1111100:sw_Nr_124[gen_k] <= sw_Nr[gen_k];
				7'b1111101:sw_Nr_125[gen_k] <= sw_Nr[gen_k];
				7'b1111110:sw_Nr_126[gen_k] <= sw_Nr[gen_k];
				7'b1111111:sw_Nr_127[gen_k] <= sw_Nr[gen_k];


			endcase // sw_pe_cnt[gen_k]
		end // 
	end
	
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_0[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd0) begin
			sw_location_0[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_0[gen_k][31:16] <= sw_location_0[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_1[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd1) begin
			sw_location_1[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_1[gen_k][31:16] <= sw_location_1[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_2[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd2) begin
			sw_location_2[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_2[gen_k][31:16] <= sw_location_2[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_3[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd3) begin
			sw_location_3[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_3[gen_k][31:16] <= sw_location_3[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_4[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd4) begin
			sw_location_4[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_4[gen_k][31:16] <= sw_location_4[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_5[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd5) begin
			sw_location_5[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_5[gen_k][31:16] <= sw_location_5[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_6[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd6) begin
			sw_location_6[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_6[gen_k][31:16] <= sw_location_6[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_7[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd7) begin
			sw_location_7[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_7[gen_k][31:16] <= sw_location_7[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_8[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd8) begin
			sw_location_8[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_8[gen_k][31:16] <= sw_location_8[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_9[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd9) begin
			sw_location_9[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_9[gen_k][31:16] <= sw_location_9[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_10[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd10) begin
			sw_location_10[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_10[gen_k][31:16] <= sw_location_10[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_11[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd11) begin
			sw_location_11[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_11[gen_k][31:16] <= sw_location_11[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_12[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd12) begin
			sw_location_12[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_12[gen_k][31:16] <= sw_location_12[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_13[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd13) begin
			sw_location_13[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_13[gen_k][31:16] <= sw_location_13[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_14[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd14) begin
			sw_location_14[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_14[gen_k][31:16] <= sw_location_14[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_15[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd15) begin
			sw_location_15[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_15[gen_k][31:16] <= sw_location_15[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_16[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd16) begin
			sw_location_16[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_16[gen_k][31:16] <= sw_location_16[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_17[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd17) begin
			sw_location_17[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_17[gen_k][31:16] <= sw_location_17[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_18[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd18) begin
			sw_location_18[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_18[gen_k][31:16] <= sw_location_18[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_19[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd19) begin
			sw_location_19[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_19[gen_k][31:16] <= sw_location_19[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_20[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd20) begin
			sw_location_20[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_20[gen_k][31:16] <= sw_location_20[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_21[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd21) begin
			sw_location_21[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_21[gen_k][31:16] <= sw_location_21[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_22[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd22) begin
			sw_location_22[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_22[gen_k][31:16] <= sw_location_22[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_23[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd23) begin
			sw_location_23[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_23[gen_k][31:16] <= sw_location_23[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_24[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd24) begin
			sw_location_24[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_24[gen_k][31:16] <= sw_location_24[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_25[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd25) begin
			sw_location_25[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_25[gen_k][31:16] <= sw_location_25[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_26[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd26) begin
			sw_location_26[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_26[gen_k][31:16] <= sw_location_26[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_27[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd27) begin
			sw_location_27[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_27[gen_k][31:16] <= sw_location_27[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_28[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd28) begin
			sw_location_28[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_28[gen_k][31:16] <= sw_location_28[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_29[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd29) begin
			sw_location_29[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_29[gen_k][31:16] <= sw_location_29[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_30[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd30) begin
			sw_location_30[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_30[gen_k][31:16] <= sw_location_30[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_31[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd31) begin
			sw_location_31[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_31[gen_k][31:16] <= sw_location_31[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_32[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd32) begin
			sw_location_32[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_32[gen_k][31:16] <= sw_location_32[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_33[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd33) begin
			sw_location_33[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_33[gen_k][31:16] <= sw_location_33[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_34[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd34) begin
			sw_location_34[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_34[gen_k][31:16] <= sw_location_34[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_35[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd35) begin
			sw_location_35[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_35[gen_k][31:16] <= sw_location_35[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_36[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd36) begin
			sw_location_36[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_36[gen_k][31:16] <= sw_location_36[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_37[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd37) begin
			sw_location_37[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_37[gen_k][31:16] <= sw_location_37[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_38[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd38) begin
			sw_location_38[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_38[gen_k][31:16] <= sw_location_38[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_39[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd39) begin
			sw_location_39[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_39[gen_k][31:16] <= sw_location_39[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_40[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd40) begin
			sw_location_40[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_40[gen_k][31:16] <= sw_location_40[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_41[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd41) begin
			sw_location_41[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_41[gen_k][31:16] <= sw_location_41[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_42[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd42) begin
			sw_location_42[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_42[gen_k][31:16] <= sw_location_42[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_43[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd43) begin
			sw_location_43[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_43[gen_k][31:16] <= sw_location_43[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_44[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd44) begin
			sw_location_44[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_44[gen_k][31:16] <= sw_location_44[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_45[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd45) begin
			sw_location_45[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_45[gen_k][31:16] <= sw_location_45[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_46[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd46) begin
			sw_location_46[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_46[gen_k][31:16] <= sw_location_46[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_47[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd47) begin
			sw_location_47[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_47[gen_k][31:16] <= sw_location_47[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_48[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd48) begin
			sw_location_48[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_48[gen_k][31:16] <= sw_location_48[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_49[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd49) begin
			sw_location_49[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_49[gen_k][31:16] <= sw_location_49[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_50[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd50) begin
			sw_location_50[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_50[gen_k][31:16] <= sw_location_50[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_51[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd51) begin
			sw_location_51[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_51[gen_k][31:16] <= sw_location_51[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_52[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd52) begin
			sw_location_52[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_52[gen_k][31:16] <= sw_location_52[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_53[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd53) begin
			sw_location_53[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_53[gen_k][31:16] <= sw_location_53[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_54[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd54) begin
			sw_location_54[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_54[gen_k][31:16] <= sw_location_54[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_55[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd55) begin
			sw_location_55[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_55[gen_k][31:16] <= sw_location_55[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_56[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd56) begin
			sw_location_56[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_56[gen_k][31:16] <= sw_location_56[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_57[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd57) begin
			sw_location_57[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_57[gen_k][31:16] <= sw_location_57[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_58[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd58) begin
			sw_location_58[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_58[gen_k][31:16] <= sw_location_58[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_59[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd59) begin
			sw_location_59[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_59[gen_k][31:16] <= sw_location_59[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_60[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd60) begin
			sw_location_60[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_60[gen_k][31:16] <= sw_location_60[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_61[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd61) begin
			sw_location_61[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_61[gen_k][31:16] <= sw_location_61[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_62[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd62) begin
			sw_location_62[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_62[gen_k][31:16] <= sw_location_62[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_63[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd63) begin
			sw_location_63[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_63[gen_k][31:16] <= sw_location_63[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_64[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd64) begin
			sw_location_64[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_64[gen_k][31:16] <= sw_location_64[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_65[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd65) begin
			sw_location_65[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_65[gen_k][31:16] <= sw_location_65[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_66[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd66) begin
			sw_location_66[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_66[gen_k][31:16] <= sw_location_66[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_67[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd67) begin
			sw_location_67[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_67[gen_k][31:16] <= sw_location_67[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_68[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd68) begin
			sw_location_68[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_68[gen_k][31:16] <= sw_location_68[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_69[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd69) begin
			sw_location_69[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_69[gen_k][31:16] <= sw_location_69[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_70[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd70) begin
			sw_location_70[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_70[gen_k][31:16] <= sw_location_70[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_71[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd71) begin
			sw_location_71[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_71[gen_k][31:16] <= sw_location_71[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_72[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd72) begin
			sw_location_72[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_72[gen_k][31:16] <= sw_location_72[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_73[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd73) begin
			sw_location_73[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_73[gen_k][31:16] <= sw_location_73[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_74[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd74) begin
			sw_location_74[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_74[gen_k][31:16] <= sw_location_74[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_75[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd75) begin
			sw_location_75[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_75[gen_k][31:16] <= sw_location_75[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_76[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd76) begin
			sw_location_76[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_76[gen_k][31:16] <= sw_location_76[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_77[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd77) begin
			sw_location_77[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_77[gen_k][31:16] <= sw_location_77[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_78[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd78) begin
			sw_location_78[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_78[gen_k][31:16] <= sw_location_78[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_79[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd79) begin
			sw_location_79[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_79[gen_k][31:16] <= sw_location_79[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_80[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd80) begin
			sw_location_80[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_80[gen_k][31:16] <= sw_location_80[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_81[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd81) begin
			sw_location_81[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_81[gen_k][31:16] <= sw_location_81[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_82[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd82) begin
			sw_location_82[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_82[gen_k][31:16] <= sw_location_82[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_83[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd83) begin
			sw_location_83[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_83[gen_k][31:16] <= sw_location_83[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_84[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd84) begin
			sw_location_84[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_84[gen_k][31:16] <= sw_location_84[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_85[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd85) begin
			sw_location_85[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_85[gen_k][31:16] <= sw_location_85[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_86[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd86) begin
			sw_location_86[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_86[gen_k][31:16] <= sw_location_86[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_87[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd87) begin
			sw_location_87[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_87[gen_k][31:16] <= sw_location_87[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_88[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd88) begin
			sw_location_88[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_88[gen_k][31:16] <= sw_location_88[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_89[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd89) begin
			sw_location_89[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_89[gen_k][31:16] <= sw_location_89[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_90[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd90) begin
			sw_location_90[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_90[gen_k][31:16] <= sw_location_90[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_91[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd91) begin
			sw_location_91[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_91[gen_k][31:16] <= sw_location_91[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_92[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd92) begin
			sw_location_92[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_92[gen_k][31:16] <= sw_location_92[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_93[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd93) begin
			sw_location_93[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_93[gen_k][31:16] <= sw_location_93[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_94[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd94) begin
			sw_location_94[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_94[gen_k][31:16] <= sw_location_94[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_95[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd95) begin
			sw_location_95[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_95[gen_k][31:16] <= sw_location_95[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_96[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd96) begin
			sw_location_96[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_96[gen_k][31:16] <= sw_location_96[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_97[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd97) begin
			sw_location_97[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_97[gen_k][31:16] <= sw_location_97[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_98[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd98) begin
			sw_location_98[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_98[gen_k][31:16] <= sw_location_98[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_99[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd99) begin
			sw_location_99[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_99[gen_k][31:16] <= sw_location_99[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_100[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd100) begin
			sw_location_100[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_100[gen_k][31:16] <= sw_location_100[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_101[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd101) begin
			sw_location_101[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_101[gen_k][31:16] <= sw_location_101[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_102[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd102) begin
			sw_location_102[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_102[gen_k][31:16] <= sw_location_102[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_103[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd103) begin
			sw_location_103[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_103[gen_k][31:16] <= sw_location_103[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_104[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd104) begin
			sw_location_104[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_104[gen_k][31:16] <= sw_location_104[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_105[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd105) begin
			sw_location_105[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_105[gen_k][31:16] <= sw_location_105[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_106[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd106) begin
			sw_location_106[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_106[gen_k][31:16] <= sw_location_106[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_107[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd107) begin
			sw_location_107[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_107[gen_k][31:16] <= sw_location_107[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_108[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd108) begin
			sw_location_108[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_108[gen_k][31:16] <= sw_location_108[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_109[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd109) begin
			sw_location_109[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_109[gen_k][31:16] <= sw_location_109[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_110[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd110) begin
			sw_location_110[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_110[gen_k][31:16] <= sw_location_110[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_111[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd111) begin
			sw_location_111[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_111[gen_k][31:16] <= sw_location_111[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_112[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd112) begin
			sw_location_112[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_112[gen_k][31:16] <= sw_location_112[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_113[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd113) begin
			sw_location_113[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_113[gen_k][31:16] <= sw_location_113[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_114[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd114) begin
			sw_location_114[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_114[gen_k][31:16] <= sw_location_114[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_115[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd115) begin
			sw_location_115[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_115[gen_k][31:16] <= sw_location_115[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_116[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd116) begin
			sw_location_116[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_116[gen_k][31:16] <= sw_location_116[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_117[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd117) begin
			sw_location_117[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_117[gen_k][31:16] <= sw_location_117[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_118[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd118) begin
			sw_location_118[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_118[gen_k][31:16] <= sw_location_118[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_119[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd119) begin
			sw_location_119[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_119[gen_k][31:16] <= sw_location_119[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_120[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd120) begin
			sw_location_120[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_120[gen_k][31:16] <= sw_location_120[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_121[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd121) begin
			sw_location_121[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_121[gen_k][31:16] <= sw_location_121[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_122[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd122) begin
			sw_location_122[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_122[gen_k][31:16] <= sw_location_122[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_123[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd123) begin
			sw_location_123[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_123[gen_k][31:16] <= sw_location_123[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_124[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd124) begin
			sw_location_124[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_124[gen_k][31:16] <= sw_location_124[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_125[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd125) begin
			sw_location_125[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_125[gen_k][31:16] <= sw_location_125[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_126[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd126) begin
			sw_location_126[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_126[gen_k][31:16] <= sw_location_126[gen_k][31:16] + 1'b1;
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if (!sys_rst_n) begin
			sw_location_127[gen_k] <= 32'd0;
		end else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == 'd127) begin
			sw_location_127[gen_k] <= sw_location[gen_k];
		end else if (sw_parameter_vld[gen_k]) begin
			sw_location_127[gen_k][31:16] <= sw_location_127[gen_k][31:16] + 1'b1;
		end
	end
end
endgenerate

always @(posedge sys_clk)
begin 
	case (shift_reg)
		T0:begin
				Nr_0       <=  sw_Nr_0[6]	  ;
				Nr_1       <=  sw_Nr_1[6]	  ;
				Nr_2       <=  sw_Nr_2[6]	  ;
				Nr_3       <=  sw_Nr_3[6]	  ;
				Nr_4       <=  sw_Nr_4[6]	  ;
				Nr_5       <=  sw_Nr_5[6]	  ;
				Nr_6       <=  sw_Nr_6[6]	  ;
				Nr_7       <=  sw_Nr_7[6]	  ;
				Nr_8       <=  sw_Nr_8[6]	  ;
				Nr_9       <=  sw_Nr_9[6]	  ;
				Nr_10      <= sw_Nr_10[6]	  ;
				Nr_11      <= sw_Nr_11[6]	  ;
				Nr_12      <= sw_Nr_12[6]	  ;
				Nr_13      <= sw_Nr_13[6]	  ;
				Nr_14      <= sw_Nr_14[6]	  ;
				Nr_15      <= sw_Nr_15[6]	  ;

				Nr_16      <= sw_Nr_16[6] 	  ;
				Nr_17      <= sw_Nr_17[6] 	  ;
				Nr_18      <= sw_Nr_18[6] 	  ;
				Nr_19      <= sw_Nr_19[6] 	  ;
				Nr_20      <= sw_Nr_20[6] 	  ;
				Nr_21      <= sw_Nr_21[6] 	  ;
				Nr_22      <= sw_Nr_22[6] 	  ;
				Nr_23      <= sw_Nr_23[6] 	  ;
				Nr_24      <= sw_Nr_24[6] 	  ;
				Nr_25      <= sw_Nr_25[6] 	  ;
				Nr_26      <= sw_Nr_26[6] 	  ;
				Nr_27      <= sw_Nr_27[6] 	  ;
				Nr_28      <= sw_Nr_28[6] 	  ;
				Nr_29      <= sw_Nr_29[6] 	  ;
				Nr_30      <= sw_Nr_30[6] 	  ;
				Nr_31      <= sw_Nr_31[6] 	  ;

				


				location_0 <=   sw_location_0[6];
				location_1 <=   sw_location_1[6];
				location_2 <=   sw_location_2[6];
				location_3 <=   sw_location_3[6];
				location_4 <=   sw_location_4[6];
				location_5 <=   sw_location_5[6];
				location_6 <=   sw_location_6[6];
				location_7 <=   sw_location_7[6];
				location_8 <=   sw_location_8[6];
				location_9 <=   sw_location_9[6];
				location_10 <= sw_location_10[6];
				location_11 <= sw_location_11[6];
				location_12 <= sw_location_12[6];
				location_13 <= sw_location_13[6];
				location_14 <= sw_location_14[6];
				location_15 <= sw_location_15[6];

				location_16 <= sw_location_16[6];
				location_17 <= sw_location_17[6];
				location_18 <= sw_location_18[6];
				location_19 <= sw_location_19[6];
				location_20 <= sw_location_20[6];
				location_21 <= sw_location_21[6];
				location_22 <= sw_location_22[6];
				location_23 <= sw_location_23[6];
				location_24 <= sw_location_24[6];
				location_25 <= sw_location_25[6];
				location_26 <= sw_location_26[6];
				location_27 <= sw_location_27[6];
				location_28 <= sw_location_28[6];
				location_29 <= sw_location_29[6];
				location_30 <= sw_location_30[6];
				location_31 <= sw_location_31[6];
				Nr_32      <= sw_Nr_32[6]     ;
				Nr_33      <= sw_Nr_33[6]     ;
				Nr_34      <= sw_Nr_34[6]     ;
				Nr_35      <= sw_Nr_35[6]     ;
				Nr_36      <= sw_Nr_36[6]     ;
				Nr_37      <= sw_Nr_37[6]     ;
				Nr_38      <= sw_Nr_38[6]     ;
				Nr_39      <= sw_Nr_39[6]     ;
				Nr_40      <= sw_Nr_40[6]     ;
				Nr_41      <= sw_Nr_41[6]     ;
				Nr_42      <= sw_Nr_42[6]     ;
				Nr_43      <= sw_Nr_43[6]     ;
				Nr_44      <= sw_Nr_44[6]     ;
				Nr_45      <= sw_Nr_45[6]     ;
				Nr_46      <= sw_Nr_46[6]     ;
				Nr_47      <= sw_Nr_47[6]     ;
				Nr_48      <= sw_Nr_48[6]     ;
				Nr_49      <= sw_Nr_49[6]     ;
				Nr_50      <= sw_Nr_50[6]     ;
				Nr_51      <= sw_Nr_51[6]     ;
				Nr_52      <= sw_Nr_52[6]     ;
				Nr_53      <= sw_Nr_53[6]     ;
				Nr_54      <= sw_Nr_54[6]     ;
				Nr_55      <= sw_Nr_55[6]     ;
				Nr_56      <= sw_Nr_56[6]     ;
				Nr_57      <= sw_Nr_57[6]     ;
				Nr_58      <= sw_Nr_58[6]     ;
				Nr_59      <= sw_Nr_59[6]     ;
				Nr_60      <= sw_Nr_60[6]     ;
				Nr_61      <= sw_Nr_61[6]     ;
				Nr_62      <= sw_Nr_62[6]     ;
				Nr_63      <= sw_Nr_63[6]     ;
				location_32 <= sw_location_32[6];
				location_33 <= sw_location_33[6];
				location_34 <= sw_location_34[6];
				location_35 <= sw_location_35[6];
				location_36 <= sw_location_36[6];
				location_37 <= sw_location_37[6];
				location_38 <= sw_location_38[6];
				location_39 <= sw_location_39[6];
				location_40 <= sw_location_40[6];
				location_41 <= sw_location_41[6];
				location_42 <= sw_location_42[6];
				location_43 <= sw_location_43[6];
				location_44 <= sw_location_44[6];
				location_45 <= sw_location_45[6];
				location_46 <= sw_location_46[6];
				location_47 <= sw_location_47[6];
				location_48 <= sw_location_48[6];
				location_49 <= sw_location_49[6];
				location_50 <= sw_location_50[6];
				location_51 <= sw_location_51[6];
				location_52 <= sw_location_52[6];
				location_53 <= sw_location_53[6];
				location_54 <= sw_location_54[6];
				location_55 <= sw_location_55[6];
				location_56 <= sw_location_56[6];
				location_57 <= sw_location_57[6];
				location_58 <= sw_location_58[6];
				location_59 <= sw_location_59[6];
				location_60 <= sw_location_60[6];
				location_61 <= sw_location_61[6];
				location_62 <= sw_location_62[6];
				location_63 <= sw_location_63[6];

				Nr_64      <= sw_Nr_64[6]     ;
				Nr_65      <= sw_Nr_65[6]     ;
				Nr_66      <= sw_Nr_66[6]     ;
				Nr_67      <= sw_Nr_67[6]     ;
				Nr_68      <= sw_Nr_68[6]     ;
				Nr_69      <= sw_Nr_69[6]     ;
				Nr_70      <= sw_Nr_70[6]     ;
				Nr_71      <= sw_Nr_71[6]     ;
				Nr_72      <= sw_Nr_72[6]     ;
				Nr_73      <= sw_Nr_73[6]     ;
				Nr_74      <= sw_Nr_74[6]     ;
				Nr_75      <= sw_Nr_75[6]     ;
				Nr_76      <= sw_Nr_76[6]     ;
				Nr_77      <= sw_Nr_77[6]     ;
				Nr_78      <= sw_Nr_78[6]     ;
				Nr_79      <= sw_Nr_79[6]     ;
				Nr_80      <= sw_Nr_80[6]     ;
				Nr_81      <= sw_Nr_81[6]     ;
				Nr_82      <= sw_Nr_82[6]     ;
				Nr_83      <= sw_Nr_83[6]     ;
				Nr_84      <= sw_Nr_84[6]     ;
				Nr_85      <= sw_Nr_85[6]     ;
				Nr_86      <= sw_Nr_86[6]     ;
				Nr_87      <= sw_Nr_87[6]     ;
				Nr_88      <= sw_Nr_88[6]     ;
				Nr_89      <= sw_Nr_89[6]     ;
				Nr_90      <= sw_Nr_90[6]     ;
				Nr_91      <= sw_Nr_91[6]     ;
				Nr_92      <= sw_Nr_92[6]     ;
				Nr_93      <= sw_Nr_93[6]     ;
				Nr_94      <= sw_Nr_94[6]     ;
				Nr_95      <= sw_Nr_95[6]     ;
				Nr_96      <= sw_Nr_96[6]     ;
				Nr_97      <= sw_Nr_97[6]     ;
				Nr_98      <= sw_Nr_98[6]     ;
				Nr_99      <= sw_Nr_99[6]     ;
				Nr_100      <= sw_Nr_100[6]     ;
				Nr_101      <= sw_Nr_101[6]     ;
				Nr_102      <= sw_Nr_102[6]     ;
				Nr_103      <= sw_Nr_103[6]     ;
				Nr_104      <= sw_Nr_104[6]     ;
				Nr_105      <= sw_Nr_105[6]     ;
				Nr_106      <= sw_Nr_106[6]     ;
				Nr_107      <= sw_Nr_107[6]     ;
				Nr_108      <= sw_Nr_108[6]     ;
				Nr_109      <= sw_Nr_109[6]     ;
				Nr_110      <= sw_Nr_110[6]     ;
				Nr_111      <= sw_Nr_111[6]     ;
				Nr_112      <= sw_Nr_112[6]     ;
				Nr_113      <= sw_Nr_113[6]     ;
				Nr_114      <= sw_Nr_114[6]     ;
				Nr_115      <= sw_Nr_115[6]     ;
				Nr_116      <= sw_Nr_116[6]     ;
				Nr_117      <= sw_Nr_117[6]     ;
				Nr_118      <= sw_Nr_118[6]     ;
				Nr_119      <= sw_Nr_119[6]     ;
				Nr_120      <= sw_Nr_120[6]     ;
				Nr_121      <= sw_Nr_121[6]     ;
				Nr_122      <= sw_Nr_122[6]     ;
				Nr_123      <= sw_Nr_123[6]     ;
				Nr_124      <= sw_Nr_124[6]     ;
				Nr_125      <= sw_Nr_125[6]     ;
				Nr_126      <= sw_Nr_126[6]     ;
				Nr_127      <= sw_Nr_127[6]     ;
				location_64      <= sw_location_64[6]     ;
				location_65      <= sw_location_65[6]     ;
				location_66      <= sw_location_66[6]     ;
				location_67      <= sw_location_67[6]     ;
				location_68      <= sw_location_68[6]     ;
				location_69      <= sw_location_69[6]     ;
				location_70      <= sw_location_70[6]     ;
				location_71      <= sw_location_71[6]     ;
				location_72      <= sw_location_72[6]     ;
				location_73      <= sw_location_73[6]     ;
				location_74      <= sw_location_74[6]     ;
				location_75      <= sw_location_75[6]     ;
				location_76      <= sw_location_76[6]     ;
				location_77      <= sw_location_77[6]     ;
				location_78      <= sw_location_78[6]     ;
				location_79      <= sw_location_79[6]     ;
				location_80      <= sw_location_80[6]     ;
				location_81      <= sw_location_81[6]     ;
				location_82      <= sw_location_82[6]     ;
				location_83      <= sw_location_83[6]     ;
				location_84      <= sw_location_84[6]     ;
				location_85      <= sw_location_85[6]     ;
				location_86      <= sw_location_86[6]     ;
				location_87      <= sw_location_87[6]     ;
				location_88      <= sw_location_88[6]     ;
				location_89      <= sw_location_89[6]     ;
				location_90      <= sw_location_90[6]     ;
				location_91      <= sw_location_91[6]     ;
				location_92      <= sw_location_92[6]     ;
				location_93      <= sw_location_93[6]     ;
				location_94      <= sw_location_94[6]     ;
				location_95      <= sw_location_95[6]     ;
				location_96      <= sw_location_96[6]     ;
				location_97      <= sw_location_97[6]     ;
				location_98      <= sw_location_98[6]     ;
				location_99      <= sw_location_99[6]     ;
				location_100      <= sw_location_100[6]     ;
				location_101      <= sw_location_101[6]     ;
				location_102      <= sw_location_102[6]     ;
				location_103      <= sw_location_103[6]     ;
				location_104      <= sw_location_104[6]     ;
				location_105      <= sw_location_105[6]     ;
				location_106      <= sw_location_106[6]     ;
				location_107      <= sw_location_107[6]     ;
				location_108      <= sw_location_108[6]     ;
				location_109      <= sw_location_109[6]     ;
				location_110      <= sw_location_110[6]     ;
				location_111      <= sw_location_111[6]     ;
				location_112      <= sw_location_112[6]     ;
				location_113      <= sw_location_113[6]     ;
				location_114      <= sw_location_114[6]     ;
				location_115      <= sw_location_115[6]     ;
				location_116      <= sw_location_116[6]     ;
				location_117      <= sw_location_117[6]     ;
				location_118      <= sw_location_118[6]     ;
				location_119      <= sw_location_119[6]     ;
				location_120      <= sw_location_120[6]     ;
				location_121      <= sw_location_121[6]     ;
				location_122      <= sw_location_122[6]     ;
				location_123      <= sw_location_123[6]     ;
				location_124      <= sw_location_124[6]     ;
				location_125      <= sw_location_125[6]     ;
				location_126      <= sw_location_126[6]     ;
				location_127      <= sw_location_127[6]     ;

		end // T1:

		T1:begin
				Nr_0       <= sw_Nr_0[0]	  ;
				Nr_1       <= sw_Nr_1[0]	  ;
				Nr_2       <= sw_Nr_2[0]	  ;
				Nr_3       <= sw_Nr_3[0]	  ;
				Nr_4       <= sw_Nr_4[0]	  ;
				Nr_5       <= sw_Nr_5[0]	  ;
				Nr_6       <= sw_Nr_6[0]	  ;
				Nr_7       <= sw_Nr_7[0]	  ;
				location_0 <= sw_location_0[0];
				location_1 <= sw_location_1[0];
				location_2 <= sw_location_2[0];
				location_3 <= sw_location_3[0];
				location_4 <= sw_location_4[0];
				location_5 <= sw_location_5[0];
				location_6 <= sw_location_6[0];
				location_7 <= sw_location_7[0];
				Nr_8       <= sw_Nr_8[0]	  ;
				Nr_9       <= sw_Nr_9[0]	  ;
				Nr_10      <= sw_Nr_10[0]	  ;
				Nr_11      <= sw_Nr_11[0]	  ;
				Nr_12      <= sw_Nr_12[0]	  ;
				Nr_13      <= sw_Nr_13[0]	  ;
				Nr_14      <= sw_Nr_14[0]	  ;
				Nr_15      <= sw_Nr_15[0]	  ;
				location_8 <=   sw_location_8[0];
				location_9 <=   sw_location_9[0];
				location_10 <= sw_location_10[0];
				location_11 <= sw_location_11[0];
				location_12 <= sw_location_12[0];
				location_13 <= sw_location_13[0];
				location_14 <= sw_location_14[0];
				location_15 <= sw_location_15[0];
				Nr_16      <= sw_Nr_16[0] 	  ;
				Nr_17      <= sw_Nr_17[0] 	  ;
				Nr_18      <= sw_Nr_18[0] 	  ;
				Nr_19      <= sw_Nr_19[0] 	  ;
				Nr_20      <= sw_Nr_20[0] 	  ;
				Nr_21      <= sw_Nr_21[0] 	  ;
				Nr_22      <= sw_Nr_22[0] 	  ;
				Nr_23      <= sw_Nr_23[0] 	  ;
				Nr_24      <= sw_Nr_24[0] 	  ;
				Nr_25      <= sw_Nr_25[0] 	  ;
				Nr_26      <= sw_Nr_26[0] 	  ;
				Nr_27      <= sw_Nr_27[0] 	  ;
				Nr_28      <= sw_Nr_28[0] 	  ;
				Nr_29      <= sw_Nr_29[0] 	  ;
				Nr_30      <= sw_Nr_30[0] 	  ;
				Nr_31      <= sw_Nr_31[0] 	  ;

				location_16 <= sw_location_16[0];
				location_17 <= sw_location_17[0];
				location_18 <= sw_location_18[0];
				location_19 <= sw_location_19[0];
				location_20 <= sw_location_20[0];
				location_21 <= sw_location_21[0];
				location_22 <= sw_location_22[0];
				location_23 <= sw_location_23[0];
				location_24 <= sw_location_24[0];
				location_25 <= sw_location_25[0];
				location_26 <= sw_location_26[0];
				location_27 <= sw_location_27[0];
				location_28 <= sw_location_28[0];
				location_29 <= sw_location_29[0];
				location_30 <= sw_location_30[0];
				location_31 <= sw_location_31[0];

				Nr_32      <= sw_Nr_32[0]     ;
				Nr_33      <= sw_Nr_33[0]     ;
				Nr_34      <= sw_Nr_34[0]     ;
				Nr_35      <= sw_Nr_35[0]     ;
				Nr_36      <= sw_Nr_36[0]     ;
				Nr_37      <= sw_Nr_37[0]     ;
				Nr_38      <= sw_Nr_38[0]     ;
				Nr_39      <= sw_Nr_39[0]     ;
				Nr_40      <= sw_Nr_40[0]     ;
				Nr_41      <= sw_Nr_41[0]     ;
				Nr_42      <= sw_Nr_42[0]     ;
				Nr_43      <= sw_Nr_43[0]     ;
				Nr_44      <= sw_Nr_44[0]     ;
				Nr_45      <= sw_Nr_45[0]     ;
				Nr_46      <= sw_Nr_46[0]     ;
				Nr_47      <= sw_Nr_47[0]     ;
				Nr_48      <= sw_Nr_48[0]     ;
				Nr_49      <= sw_Nr_49[0]     ;
				Nr_50      <= sw_Nr_50[0]     ;
				Nr_51      <= sw_Nr_51[0]     ;
				Nr_52      <= sw_Nr_52[0]     ;
				Nr_53      <= sw_Nr_53[0]     ;
				Nr_54      <= sw_Nr_54[0]     ;
				Nr_55      <= sw_Nr_55[0]     ;
				Nr_56      <= sw_Nr_56[0]     ;
				Nr_57      <= sw_Nr_57[0]     ;
				Nr_58      <= sw_Nr_58[0]     ;
				Nr_59      <= sw_Nr_59[0]     ;
				Nr_60      <= sw_Nr_60[0]     ;
				Nr_61      <= sw_Nr_61[0]     ;
				Nr_62      <= sw_Nr_62[0]     ;
				Nr_63      <= sw_Nr_63[0]     ;
				location_32 <= sw_location_32[0];
				location_33 <= sw_location_33[0];
				location_34 <= sw_location_34[0];
				location_35 <= sw_location_35[0];
				location_36 <= sw_location_36[0];
				location_37 <= sw_location_37[0];
				location_38 <= sw_location_38[0];
				location_39 <= sw_location_39[0];
				location_40 <= sw_location_40[0];
				location_41 <= sw_location_41[0];
				location_42 <= sw_location_42[0];
				location_43 <= sw_location_43[0];
				location_44 <= sw_location_44[0];
				location_45 <= sw_location_45[0];
				location_46 <= sw_location_46[0];
				location_47 <= sw_location_47[0];
				location_48 <= sw_location_48[0];
				location_49 <= sw_location_49[0];
				location_50 <= sw_location_50[0];
				location_51 <= sw_location_51[0];
				location_52 <= sw_location_52[0];
				location_53 <= sw_location_53[0];
				location_54 <= sw_location_54[0];
				location_55 <= sw_location_55[0];
				location_56 <= sw_location_56[0];
				location_57 <= sw_location_57[0];
				location_58 <= sw_location_58[0];
				location_59 <= sw_location_59[0];
				location_60 <= sw_location_60[0];
				location_61 <= sw_location_61[0];
				location_62 <= sw_location_62[0];
				location_63 <= sw_location_63[0];

				Nr_64      <= sw_Nr_64[0]     ;
				Nr_65      <= sw_Nr_65[0]     ;
				Nr_66      <= sw_Nr_66[0]     ;
				Nr_67      <= sw_Nr_67[0]     ;
				Nr_68      <= sw_Nr_68[0]     ;
				Nr_69      <= sw_Nr_69[0]     ;
				Nr_70      <= sw_Nr_70[0]     ;
				Nr_71      <= sw_Nr_71[0]     ;
				Nr_72      <= sw_Nr_72[0]     ;
				Nr_73      <= sw_Nr_73[0]     ;
				Nr_74      <= sw_Nr_74[0]     ;
				Nr_75      <= sw_Nr_75[0]     ;
				Nr_76      <= sw_Nr_76[0]     ;
				Nr_77      <= sw_Nr_77[0]     ;
				Nr_78      <= sw_Nr_78[0]     ;
				Nr_79      <= sw_Nr_79[0]     ;
				Nr_80      <= sw_Nr_80[0]     ;
				Nr_81      <= sw_Nr_81[0]     ;
				Nr_82      <= sw_Nr_82[0]     ;
				Nr_83      <= sw_Nr_83[0]     ;
				Nr_84      <= sw_Nr_84[0]     ;
				Nr_85      <= sw_Nr_85[0]     ;
				Nr_86      <= sw_Nr_86[0]     ;
				Nr_87      <= sw_Nr_87[0]     ;
				Nr_88      <= sw_Nr_88[0]     ;
				Nr_89      <= sw_Nr_89[0]     ;
				Nr_90      <= sw_Nr_90[0]     ;
				Nr_91      <= sw_Nr_91[0]     ;
				Nr_92      <= sw_Nr_92[0]     ;
				Nr_93      <= sw_Nr_93[0]     ;
				Nr_94      <= sw_Nr_94[0]     ;
				Nr_95      <= sw_Nr_95[0]     ;
				Nr_96      <= sw_Nr_96[0]     ;
				Nr_97      <= sw_Nr_97[0]     ;
				Nr_98      <= sw_Nr_98[0]     ;
				Nr_99      <= sw_Nr_99[0]     ;
				Nr_100      <= sw_Nr_100[0]     ;
				Nr_101      <= sw_Nr_101[0]     ;
				Nr_102      <= sw_Nr_102[0]     ;
				Nr_103      <= sw_Nr_103[0]     ;
				Nr_104      <= sw_Nr_104[0]     ;
				Nr_105      <= sw_Nr_105[0]     ;
				Nr_106      <= sw_Nr_106[0]     ;
				Nr_107      <= sw_Nr_107[0]     ;
				Nr_108      <= sw_Nr_108[0]     ;
				Nr_109      <= sw_Nr_109[0]     ;
				Nr_110      <= sw_Nr_110[0]     ;
				Nr_111      <= sw_Nr_111[0]     ;
				Nr_112      <= sw_Nr_112[0]     ;
				Nr_113      <= sw_Nr_113[0]     ;
				Nr_114      <= sw_Nr_114[0]     ;
				Nr_115      <= sw_Nr_115[0]     ;
				Nr_116      <= sw_Nr_116[0]     ;
				Nr_117      <= sw_Nr_117[0]     ;
				Nr_118      <= sw_Nr_118[0]     ;
				Nr_119      <= sw_Nr_119[0]     ;
				Nr_120      <= sw_Nr_120[0]     ;
				Nr_121      <= sw_Nr_121[0]     ;
				Nr_122      <= sw_Nr_122[0]     ;
				Nr_123      <= sw_Nr_123[0]     ;
				Nr_124      <= sw_Nr_124[0]     ;
				Nr_125      <= sw_Nr_125[0]     ;
				Nr_126      <= sw_Nr_126[0]     ;
				Nr_127      <= sw_Nr_127[0]     ;
				location_64      <= sw_location_64[0]     ;
				location_65      <= sw_location_65[0]     ;
				location_66      <= sw_location_66[0]     ;
				location_67      <= sw_location_67[0]     ;
				location_68      <= sw_location_68[0]     ;
				location_69      <= sw_location_69[0]     ;
				location_70      <= sw_location_70[0]     ;
				location_71      <= sw_location_71[0]     ;
				location_72      <= sw_location_72[0]     ;
				location_73      <= sw_location_73[0]     ;
				location_74      <= sw_location_74[0]     ;
				location_75      <= sw_location_75[0]     ;
				location_76      <= sw_location_76[0]     ;
				location_77      <= sw_location_77[0]     ;
				location_78      <= sw_location_78[0]     ;
				location_79      <= sw_location_79[0]     ;
				location_80      <= sw_location_80[0]     ;
				location_81      <= sw_location_81[0]     ;
				location_82      <= sw_location_82[0]     ;
				location_83      <= sw_location_83[0]     ;
				location_84      <= sw_location_84[0]     ;
				location_85      <= sw_location_85[0]     ;
				location_86      <= sw_location_86[0]     ;
				location_87      <= sw_location_87[0]     ;
				location_88      <= sw_location_88[0]     ;
				location_89      <= sw_location_89[0]     ;
				location_90      <= sw_location_90[0]     ;
				location_91      <= sw_location_91[0]     ;
				location_92      <= sw_location_92[0]     ;
				location_93      <= sw_location_93[0]     ;
				location_94      <= sw_location_94[0]     ;
				location_95      <= sw_location_95[0]     ;
				location_96      <= sw_location_96[0]     ;
				location_97      <= sw_location_97[0]     ;
				location_98      <= sw_location_98[0]     ;
				location_99      <= sw_location_99[0]     ;
				location_100      <= sw_location_100[0]     ;
				location_101      <= sw_location_101[0]     ;
				location_102      <= sw_location_102[0]     ;
				location_103      <= sw_location_103[0]     ;
				location_104      <= sw_location_104[0]     ;
				location_105      <= sw_location_105[0]     ;
				location_106      <= sw_location_106[0]     ;
				location_107      <= sw_location_107[0]     ;
				location_108      <= sw_location_108[0]     ;
				location_109      <= sw_location_109[0]     ;
				location_110      <= sw_location_110[0]     ;
				location_111      <= sw_location_111[0]     ;
				location_112      <= sw_location_112[0]     ;
				location_113      <= sw_location_113[0]     ;
				location_114      <= sw_location_114[0]     ;
				location_115      <= sw_location_115[0]     ;
				location_116      <= sw_location_116[0]     ;
				location_117      <= sw_location_117[0]     ;
				location_118      <= sw_location_118[0]     ;
				location_119      <= sw_location_119[0]     ;
				location_120      <= sw_location_120[0]     ;
				location_121      <= sw_location_121[0]     ;
				location_122      <= sw_location_122[0]     ;
				location_123      <= sw_location_123[0]     ;
				location_124      <= sw_location_124[0]     ;
				location_125      <= sw_location_125[0]     ;
				location_126      <= sw_location_126[0]     ;
				location_127      <= sw_location_127[0]     ;

		end 

		T2:begin
				Nr_0       <= sw_Nr_0[1]	  ;
				Nr_1       <= sw_Nr_1[1]	  ;
				Nr_2       <= sw_Nr_2[1]	  ;
				Nr_3       <= sw_Nr_3[1]	  ;
				Nr_4       <= sw_Nr_4[1]	  ;
				Nr_5       <= sw_Nr_5[1]	  ;
				Nr_6       <= sw_Nr_6[1]	  ;
				Nr_7       <= sw_Nr_7[1]	  ;
				location_0 <= sw_location_0[1];
				location_1 <= sw_location_1[1];
				location_2 <= sw_location_2[1];
				location_3 <= sw_location_3[1];
				location_4 <= sw_location_4[1];
				location_5 <= sw_location_5[1];
				location_6 <= sw_location_6[1];
				location_7 <= sw_location_7[1];
				Nr_8       <= sw_Nr_8[1]	  ;
				Nr_9       <= sw_Nr_9[1]	  ;
				Nr_10      <= sw_Nr_10[1]	  ;
				Nr_11      <= sw_Nr_11[1]	  ;
				Nr_12      <= sw_Nr_12[1]	  ;
				Nr_13      <= sw_Nr_13[1]	  ;
				Nr_14      <= sw_Nr_14[1]	  ;
				Nr_15      <= sw_Nr_15[1]	  ;
				location_8 <=   sw_location_8[1];
				location_9 <=   sw_location_9[1];
				location_10 <= sw_location_10[1];
				location_11 <= sw_location_11[1];
				location_12 <= sw_location_12[1];
				location_13 <= sw_location_13[1];
				location_14 <= sw_location_14[1];
				location_15 <= sw_location_15[1];

				Nr_16      <= sw_Nr_16[1] 	  ;
				Nr_17      <= sw_Nr_17[1] 	  ;
				Nr_18      <= sw_Nr_18[1] 	  ;
				Nr_19      <= sw_Nr_19[1] 	  ;
				Nr_20      <= sw_Nr_20[1] 	  ;
				Nr_21      <= sw_Nr_21[1] 	  ;
				Nr_22      <= sw_Nr_22[1] 	  ;
				Nr_23      <= sw_Nr_23[1] 	  ;
				Nr_24      <= sw_Nr_24[1] 	  ;
				Nr_25      <= sw_Nr_25[1] 	  ;
				Nr_26      <= sw_Nr_26[1] 	  ;
				Nr_27      <= sw_Nr_27[1] 	  ;
				Nr_28      <= sw_Nr_28[1] 	  ;
				Nr_29      <= sw_Nr_29[1] 	  ;
				Nr_30      <= sw_Nr_30[1] 	  ;
				Nr_31      <= sw_Nr_31[1] 	  ;

				location_16 <= sw_location_16[1];
				location_17 <= sw_location_17[1];
				location_18 <= sw_location_18[1];
				location_19 <= sw_location_19[1];
				location_20 <= sw_location_20[1];
				location_21 <= sw_location_21[1];
				location_22 <= sw_location_22[1];
				location_23 <= sw_location_23[1];
				location_24 <= sw_location_24[1];
				location_25 <= sw_location_25[1];
				location_26 <= sw_location_26[1];
				location_27 <= sw_location_27[1];
				location_28 <= sw_location_28[1];
				location_29 <= sw_location_29[1];
				location_30 <= sw_location_30[1];
				location_31 <= sw_location_31[1];

				Nr_32      <= sw_Nr_32[1]     ;
				Nr_33      <= sw_Nr_33[1]     ;
				Nr_34      <= sw_Nr_34[1]     ;
				Nr_35      <= sw_Nr_35[1]     ;
				Nr_36      <= sw_Nr_36[1]     ;
				Nr_37      <= sw_Nr_37[1]     ;
				Nr_38      <= sw_Nr_38[1]     ;
				Nr_39      <= sw_Nr_39[1]     ;
				Nr_40      <= sw_Nr_40[1]     ;
				Nr_41      <= sw_Nr_41[1]     ;
				Nr_42      <= sw_Nr_42[1]     ;
				Nr_43      <= sw_Nr_43[1]     ;
				Nr_44      <= sw_Nr_44[1]     ;
				Nr_45      <= sw_Nr_45[1]     ;
				Nr_46      <= sw_Nr_46[1]     ;
				Nr_47      <= sw_Nr_47[1]     ;
				Nr_48      <= sw_Nr_48[1]     ;
				Nr_49      <= sw_Nr_49[1]     ;
				Nr_50      <= sw_Nr_50[1]     ;
				Nr_51      <= sw_Nr_51[1]     ;
				Nr_52      <= sw_Nr_52[1]     ;
				Nr_53      <= sw_Nr_53[1]     ;
				Nr_54      <= sw_Nr_54[1]     ;
				Nr_55      <= sw_Nr_55[1]     ;
				Nr_56      <= sw_Nr_56[1]     ;
				Nr_57      <= sw_Nr_57[1]     ;
				Nr_58      <= sw_Nr_58[1]     ;
				Nr_59      <= sw_Nr_59[1]     ;
				Nr_60      <= sw_Nr_60[1]     ;
				Nr_61      <= sw_Nr_61[1]     ;
				Nr_62      <= sw_Nr_62[1]     ;
				Nr_63      <= sw_Nr_63[1]     ;
				location_32 <= sw_location_32[1];
				location_33 <= sw_location_33[1];
				location_34 <= sw_location_34[1];
				location_35 <= sw_location_35[1];
				location_36 <= sw_location_36[1];
				location_37 <= sw_location_37[1];
				location_38 <= sw_location_38[1];
				location_39 <= sw_location_39[1];
				location_40 <= sw_location_40[1];
				location_41 <= sw_location_41[1];
				location_42 <= sw_location_42[1];
				location_43 <= sw_location_43[1];
				location_44 <= sw_location_44[1];
				location_45 <= sw_location_45[1];
				location_46 <= sw_location_46[1];
				location_47 <= sw_location_47[1];
				location_48 <= sw_location_48[1];
				location_49 <= sw_location_49[1];
				location_50 <= sw_location_50[1];
				location_51 <= sw_location_51[1];
				location_52 <= sw_location_52[1];
				location_53 <= sw_location_53[1];
				location_54 <= sw_location_54[1];
				location_55 <= sw_location_55[1];
				location_56 <= sw_location_56[1];
				location_57 <= sw_location_57[1];
				location_58 <= sw_location_58[1];
				location_59 <= sw_location_59[1];
				location_60 <= sw_location_60[1];
				location_61 <= sw_location_61[1];
				location_62 <= sw_location_62[1];
				location_63 <= sw_location_63[1];

				Nr_64      <= sw_Nr_64[1]     ;
				Nr_65      <= sw_Nr_65[1]     ;
				Nr_66      <= sw_Nr_66[1]     ;
				Nr_67      <= sw_Nr_67[1]     ;
				Nr_68      <= sw_Nr_68[1]     ;
				Nr_69      <= sw_Nr_69[1]     ;
				Nr_70      <= sw_Nr_70[1]     ;
				Nr_71      <= sw_Nr_71[1]     ;
				Nr_72      <= sw_Nr_72[1]     ;
				Nr_73      <= sw_Nr_73[1]     ;
				Nr_74      <= sw_Nr_74[1]     ;
				Nr_75      <= sw_Nr_75[1]     ;
				Nr_76      <= sw_Nr_76[1]     ;
				Nr_77      <= sw_Nr_77[1]     ;
				Nr_78      <= sw_Nr_78[1]     ;
				Nr_79      <= sw_Nr_79[1]     ;
				Nr_80      <= sw_Nr_80[1]     ;
				Nr_81      <= sw_Nr_81[1]     ;
				Nr_82      <= sw_Nr_82[1]     ;
				Nr_83      <= sw_Nr_83[1]     ;
				Nr_84      <= sw_Nr_84[1]     ;
				Nr_85      <= sw_Nr_85[1]     ;
				Nr_86      <= sw_Nr_86[1]     ;
				Nr_87      <= sw_Nr_87[1]     ;
				Nr_88      <= sw_Nr_88[1]     ;
				Nr_89      <= sw_Nr_89[1]     ;
				Nr_90      <= sw_Nr_90[1]     ;
				Nr_91      <= sw_Nr_91[1]     ;
				Nr_92      <= sw_Nr_92[1]     ;
				Nr_93      <= sw_Nr_93[1]     ;
				Nr_94      <= sw_Nr_94[1]     ;
				Nr_95      <= sw_Nr_95[1]     ;
				Nr_96      <= sw_Nr_96[1]     ;
				Nr_97      <= sw_Nr_97[1]     ;
				Nr_98      <= sw_Nr_98[1]     ;
				Nr_99      <= sw_Nr_99[1]     ;
				Nr_100      <= sw_Nr_100[1]     ;
				Nr_101      <= sw_Nr_101[1]     ;
				Nr_102      <= sw_Nr_102[1]     ;
				Nr_103      <= sw_Nr_103[1]     ;
				Nr_104      <= sw_Nr_104[1]     ;
				Nr_105      <= sw_Nr_105[1]     ;
				Nr_106      <= sw_Nr_106[1]     ;
				Nr_107      <= sw_Nr_107[1]     ;
				Nr_108      <= sw_Nr_108[1]     ;
				Nr_109      <= sw_Nr_109[1]     ;
				Nr_110      <= sw_Nr_110[1]     ;
				Nr_111      <= sw_Nr_111[1]     ;
				Nr_112      <= sw_Nr_112[1]     ;
				Nr_113      <= sw_Nr_113[1]     ;
				Nr_114      <= sw_Nr_114[1]     ;
				Nr_115      <= sw_Nr_115[1]     ;
				Nr_116      <= sw_Nr_116[1]     ;
				Nr_117      <= sw_Nr_117[1]     ;
				Nr_118      <= sw_Nr_118[1]     ;
				Nr_119      <= sw_Nr_119[1]     ;
				Nr_120      <= sw_Nr_120[1]     ;
				Nr_121      <= sw_Nr_121[1]     ;
				Nr_122      <= sw_Nr_122[1]     ;
				Nr_123      <= sw_Nr_123[1]     ;
				Nr_124      <= sw_Nr_124[1]     ;
				Nr_125      <= sw_Nr_125[1]     ;
				Nr_126      <= sw_Nr_126[1]     ;
				Nr_127      <= sw_Nr_127[1]     ;
				location_64      <= sw_location_64[1]     ;
				location_65      <= sw_location_65[1]     ;
				location_66      <= sw_location_66[1]     ;
				location_67      <= sw_location_67[1]     ;
				location_68      <= sw_location_68[1]     ;
				location_69      <= sw_location_69[1]     ;
				location_70      <= sw_location_70[1]     ;
				location_71      <= sw_location_71[1]     ;
				location_72      <= sw_location_72[1]     ;
				location_73      <= sw_location_73[1]     ;
				location_74      <= sw_location_74[1]     ;
				location_75      <= sw_location_75[1]     ;
				location_76      <= sw_location_76[1]     ;
				location_77      <= sw_location_77[1]     ;
				location_78      <= sw_location_78[1]     ;
				location_79      <= sw_location_79[1]     ;
				location_80      <= sw_location_80[1]     ;
				location_81      <= sw_location_81[1]     ;
				location_82      <= sw_location_82[1]     ;
				location_83      <= sw_location_83[1]     ;
				location_84      <= sw_location_84[1]     ;
				location_85      <= sw_location_85[1]     ;
				location_86      <= sw_location_86[1]     ;
				location_87      <= sw_location_87[1]     ;
				location_88      <= sw_location_88[1]     ;
				location_89      <= sw_location_89[1]     ;
				location_90      <= sw_location_90[1]     ;
				location_91      <= sw_location_91[1]     ;
				location_92      <= sw_location_92[1]     ;
				location_93      <= sw_location_93[1]     ;
				location_94      <= sw_location_94[1]     ;
				location_95      <= sw_location_95[1]     ;
				location_96      <= sw_location_96[1]     ;
				location_97      <= sw_location_97[1]     ;
				location_98      <= sw_location_98[1]     ;
				location_99      <= sw_location_99[1]     ;
				location_100      <= sw_location_100[1]     ;
				location_101      <= sw_location_101[1]     ;
				location_102      <= sw_location_102[1]     ;
				location_103      <= sw_location_103[1]     ;
				location_104      <= sw_location_104[1]     ;
				location_105      <= sw_location_105[1]     ;
				location_106      <= sw_location_106[1]     ;
				location_107      <= sw_location_107[1]     ;
				location_108      <= sw_location_108[1]     ;
				location_109      <= sw_location_109[1]     ;
				location_110      <= sw_location_110[1]     ;
				location_111      <= sw_location_111[1]     ;
				location_112      <= sw_location_112[1]     ;
				location_113      <= sw_location_113[1]     ;
				location_114      <= sw_location_114[1]     ;
				location_115      <= sw_location_115[1]     ;
				location_116      <= sw_location_116[1]     ;
				location_117      <= sw_location_117[1]     ;
				location_118      <= sw_location_118[1]     ;
				location_119      <= sw_location_119[1]     ;
				location_120      <= sw_location_120[1]     ;
				location_121      <= sw_location_121[1]     ;
				location_122      <= sw_location_122[1]     ;
				location_123      <= sw_location_123[1]     ;
				location_124      <= sw_location_124[1]     ;
				location_125      <= sw_location_125[1]     ;
				location_126      <= sw_location_126[1]     ;
				location_127      <= sw_location_127[1]     ;

		end 

		T3:begin
				Nr_0       <= sw_Nr_0[2]	  ;
				Nr_1       <= sw_Nr_1[2]	  ;
				Nr_2       <= sw_Nr_2[2]	  ;
				Nr_3       <= sw_Nr_3[2]	  ;
				Nr_4       <= sw_Nr_4[2]	  ;
				Nr_5       <= sw_Nr_5[2]	  ;
				Nr_6       <= sw_Nr_6[2]	  ;
				Nr_7       <= sw_Nr_7[2]	  ;
				location_0 <= sw_location_0[2];
				location_1 <= sw_location_1[2];
				location_2 <= sw_location_2[2];
				location_3 <= sw_location_3[2];
				location_4 <= sw_location_4[2];
				location_5 <= sw_location_5[2];
				location_6 <= sw_location_6[2];
				location_7 <= sw_location_7[2];
				Nr_8       <= sw_Nr_8[2]	  ;
				Nr_9       <= sw_Nr_9[2]	  ;
				Nr_10      <= sw_Nr_10[2]	  ;
				Nr_11      <= sw_Nr_11[2]	  ;
				Nr_12      <= sw_Nr_12[2]	  ;
				Nr_13      <= sw_Nr_13[2]	  ;
				Nr_14      <= sw_Nr_14[2]	  ;
				Nr_15      <= sw_Nr_15[2]	  ;
				location_8 <=   sw_location_8[2];
				location_9 <=   sw_location_9[2];
				location_10 <= sw_location_10[2];
				location_11 <= sw_location_11[2];
				location_12 <= sw_location_12[2];
				location_13 <= sw_location_13[2];
				location_14 <= sw_location_14[2];
				location_15 <= sw_location_15[2];

				Nr_16      <= sw_Nr_16[2] 	  ;
				Nr_17      <= sw_Nr_17[2] 	  ;
				Nr_18      <= sw_Nr_18[2] 	  ;
				Nr_19      <= sw_Nr_19[2] 	  ;
				Nr_20      <= sw_Nr_20[2] 	  ;
				Nr_21      <= sw_Nr_21[2] 	  ;
				Nr_22      <= sw_Nr_22[2] 	  ;
				Nr_23      <= sw_Nr_23[2] 	  ;
				Nr_24      <= sw_Nr_24[2] 	  ;
				Nr_25      <= sw_Nr_25[2] 	  ;
				Nr_26      <= sw_Nr_26[2] 	  ;
				Nr_27      <= sw_Nr_27[2] 	  ;
				Nr_28      <= sw_Nr_28[2] 	  ;
				Nr_29      <= sw_Nr_29[2] 	  ;
				Nr_30      <= sw_Nr_30[2] 	  ;
				Nr_31      <= sw_Nr_31[2] 	  ;

				location_16 <= sw_location_16[2];
				location_17 <= sw_location_17[2];
				location_18 <= sw_location_18[2];
				location_19 <= sw_location_19[2];
				location_20 <= sw_location_20[2];
				location_21 <= sw_location_21[2];
				location_22 <= sw_location_22[2];
				location_23 <= sw_location_23[2];
				location_24 <= sw_location_24[2];
				location_25 <= sw_location_25[2];
				location_26 <= sw_location_26[2];
				location_27 <= sw_location_27[2];
				location_28 <= sw_location_28[2];
				location_29 <= sw_location_29[2];
				location_30 <= sw_location_30[2];
				location_31 <= sw_location_31[2];

				Nr_32      <= sw_Nr_32[2]     ;
				Nr_33      <= sw_Nr_33[2]     ;
				Nr_34      <= sw_Nr_34[2]     ;
				Nr_35      <= sw_Nr_35[2]     ;
				Nr_36      <= sw_Nr_36[2]     ;
				Nr_37      <= sw_Nr_37[2]     ;
				Nr_38      <= sw_Nr_38[2]     ;
				Nr_39      <= sw_Nr_39[2]     ;
				Nr_40      <= sw_Nr_40[2]     ;
				Nr_41      <= sw_Nr_41[2]     ;
				Nr_42      <= sw_Nr_42[2]     ;
				Nr_43      <= sw_Nr_43[2]     ;
				Nr_44      <= sw_Nr_44[2]     ;
				Nr_45      <= sw_Nr_45[2]     ;
				Nr_46      <= sw_Nr_46[2]     ;
				Nr_47      <= sw_Nr_47[2]     ;
				Nr_48      <= sw_Nr_48[2]     ;
				Nr_49      <= sw_Nr_49[2]     ;
				Nr_50      <= sw_Nr_50[2]     ;
				Nr_51      <= sw_Nr_51[2]     ;
				Nr_52      <= sw_Nr_52[2]     ;
				Nr_53      <= sw_Nr_53[2]     ;
				Nr_54      <= sw_Nr_54[2]     ;
				Nr_55      <= sw_Nr_55[2]     ;
				Nr_56      <= sw_Nr_56[2]     ;
				Nr_57      <= sw_Nr_57[2]     ;
				Nr_58      <= sw_Nr_58[2]     ;
				Nr_59      <= sw_Nr_59[2]     ;
				Nr_60      <= sw_Nr_60[2]     ;
				Nr_61      <= sw_Nr_61[2]     ;
				Nr_62      <= sw_Nr_62[2]     ;
				Nr_63      <= sw_Nr_63[2]     ;
				location_32 <= sw_location_32[2];
				location_33 <= sw_location_33[2];
				location_34 <= sw_location_34[2];
				location_35 <= sw_location_35[2];
				location_36 <= sw_location_36[2];
				location_37 <= sw_location_37[2];
				location_38 <= sw_location_38[2];
				location_39 <= sw_location_39[2];
				location_40 <= sw_location_40[2];
				location_41 <= sw_location_41[2];
				location_42 <= sw_location_42[2];
				location_43 <= sw_location_43[2];
				location_44 <= sw_location_44[2];
				location_45 <= sw_location_45[2];
				location_46 <= sw_location_46[2];
				location_47 <= sw_location_47[2];
				location_48 <= sw_location_48[2];
				location_49 <= sw_location_49[2];
				location_50 <= sw_location_50[2];
				location_51 <= sw_location_51[2];
				location_52 <= sw_location_52[2];
				location_53 <= sw_location_53[2];
				location_54 <= sw_location_54[2];
				location_55 <= sw_location_55[2];
				location_56 <= sw_location_56[2];
				location_57 <= sw_location_57[2];
				location_58 <= sw_location_58[2];
				location_59 <= sw_location_59[2];
				location_60 <= sw_location_60[2];
				location_61 <= sw_location_61[2];
				location_62 <= sw_location_62[2];
				location_63 <= sw_location_63[2];

				Nr_64      <= sw_Nr_64[2]     ;
				Nr_65      <= sw_Nr_65[2]     ;
				Nr_66      <= sw_Nr_66[2]     ;
				Nr_67      <= sw_Nr_67[2]     ;
				Nr_68      <= sw_Nr_68[2]     ;
				Nr_69      <= sw_Nr_69[2]     ;
				Nr_70      <= sw_Nr_70[2]     ;
				Nr_71      <= sw_Nr_71[2]     ;
				Nr_72      <= sw_Nr_72[2]     ;
				Nr_73      <= sw_Nr_73[2]     ;
				Nr_74      <= sw_Nr_74[2]     ;
				Nr_75      <= sw_Nr_75[2]     ;
				Nr_76      <= sw_Nr_76[2]     ;
				Nr_77      <= sw_Nr_77[2]     ;
				Nr_78      <= sw_Nr_78[2]     ;
				Nr_79      <= sw_Nr_79[2]     ;
				Nr_80      <= sw_Nr_80[2]     ;
				Nr_81      <= sw_Nr_81[2]     ;
				Nr_82      <= sw_Nr_82[2]     ;
				Nr_83      <= sw_Nr_83[2]     ;
				Nr_84      <= sw_Nr_84[2]     ;
				Nr_85      <= sw_Nr_85[2]     ;
				Nr_86      <= sw_Nr_86[2]     ;
				Nr_87      <= sw_Nr_87[2]     ;
				Nr_88      <= sw_Nr_88[2]     ;
				Nr_89      <= sw_Nr_89[2]     ;
				Nr_90      <= sw_Nr_90[2]     ;
				Nr_91      <= sw_Nr_91[2]     ;
				Nr_92      <= sw_Nr_92[2]     ;
				Nr_93      <= sw_Nr_93[2]     ;
				Nr_94      <= sw_Nr_94[2]     ;
				Nr_95      <= sw_Nr_95[2]     ;
				Nr_96      <= sw_Nr_96[2]     ;
				Nr_97      <= sw_Nr_97[2]     ;
				Nr_98      <= sw_Nr_98[2]     ;
				Nr_99      <= sw_Nr_99[2]     ;
				Nr_100      <= sw_Nr_100[2]     ;
				Nr_101      <= sw_Nr_101[2]     ;
				Nr_102      <= sw_Nr_102[2]     ;
				Nr_103      <= sw_Nr_103[2]     ;
				Nr_104      <= sw_Nr_104[2]     ;
				Nr_105      <= sw_Nr_105[2]     ;
				Nr_106      <= sw_Nr_106[2]     ;
				Nr_107      <= sw_Nr_107[2]     ;
				Nr_108      <= sw_Nr_108[2]     ;
				Nr_109      <= sw_Nr_109[2]     ;
				Nr_110      <= sw_Nr_110[2]     ;
				Nr_111      <= sw_Nr_111[2]     ;
				Nr_112      <= sw_Nr_112[2]     ;
				Nr_113      <= sw_Nr_113[2]     ;
				Nr_114      <= sw_Nr_114[2]     ;
				Nr_115      <= sw_Nr_115[2]     ;
				Nr_116      <= sw_Nr_116[2]     ;
				Nr_117      <= sw_Nr_117[2]     ;
				Nr_118      <= sw_Nr_118[2]     ;
				Nr_119      <= sw_Nr_119[2]     ;
				Nr_120      <= sw_Nr_120[2]     ;
				Nr_121      <= sw_Nr_121[2]     ;
				Nr_122      <= sw_Nr_122[2]     ;
				Nr_123      <= sw_Nr_123[2]     ;
				Nr_124      <= sw_Nr_124[2]     ;
				Nr_125      <= sw_Nr_125[2]     ;
				Nr_126      <= sw_Nr_126[2]     ;
				Nr_127      <= sw_Nr_127[2]     ;
				location_64      <= sw_location_64[2]     ;
				location_65      <= sw_location_65[2]     ;
				location_66      <= sw_location_66[2]     ;
				location_67      <= sw_location_67[2]     ;
				location_68      <= sw_location_68[2]     ;
				location_69      <= sw_location_69[2]     ;
				location_70      <= sw_location_70[2]     ;
				location_71      <= sw_location_71[2]     ;
				location_72      <= sw_location_72[2]     ;
				location_73      <= sw_location_73[2]     ;
				location_74      <= sw_location_74[2]     ;
				location_75      <= sw_location_75[2]     ;
				location_76      <= sw_location_76[2]     ;
				location_77      <= sw_location_77[2]     ;
				location_78      <= sw_location_78[2]     ;
				location_79      <= sw_location_79[2]     ;
				location_80      <= sw_location_80[2]     ;
				location_81      <= sw_location_81[2]     ;
				location_82      <= sw_location_82[2]     ;
				location_83      <= sw_location_83[2]     ;
				location_84      <= sw_location_84[2]     ;
				location_85      <= sw_location_85[2]     ;
				location_86      <= sw_location_86[2]     ;
				location_87      <= sw_location_87[2]     ;
				location_88      <= sw_location_88[2]     ;
				location_89      <= sw_location_89[2]     ;
				location_90      <= sw_location_90[2]     ;
				location_91      <= sw_location_91[2]     ;
				location_92      <= sw_location_92[2]     ;
				location_93      <= sw_location_93[2]     ;
				location_94      <= sw_location_94[2]     ;
				location_95      <= sw_location_95[2]     ;
				location_96      <= sw_location_96[2]     ;
				location_97      <= sw_location_97[2]     ;
				location_98      <= sw_location_98[2]     ;
				location_99      <= sw_location_99[2]     ;
				location_100      <= sw_location_100[2]     ;
				location_101      <= sw_location_101[2]     ;
				location_102      <= sw_location_102[2]     ;
				location_103      <= sw_location_103[2]     ;
				location_104      <= sw_location_104[2]     ;
				location_105      <= sw_location_105[2]     ;
				location_106      <= sw_location_106[2]     ;
				location_107      <= sw_location_107[2]     ;
				location_108      <= sw_location_108[2]     ;
				location_109      <= sw_location_109[2]     ;
				location_110      <= sw_location_110[2]     ;
				location_111      <= sw_location_111[2]     ;
				location_112      <= sw_location_112[2]     ;
				location_113      <= sw_location_113[2]     ;
				location_114      <= sw_location_114[2]     ;
				location_115      <= sw_location_115[2]     ;
				location_116      <= sw_location_116[2]     ;
				location_117      <= sw_location_117[2]     ;
				location_118      <= sw_location_118[2]     ;
				location_119      <= sw_location_119[2]     ;
				location_120      <= sw_location_120[2]     ;
				location_121      <= sw_location_121[2]     ;
				location_122      <= sw_location_122[2]     ;
				location_123      <= sw_location_123[2]     ;
				location_124      <= sw_location_124[2]     ;
				location_125      <= sw_location_125[2]     ;
				location_126      <= sw_location_126[2]     ;
				location_127      <= sw_location_127[2]     ;


		end 

		T4:begin
				Nr_0       <= sw_Nr_0[3]	  ;
				Nr_1       <= sw_Nr_1[3]	  ;
				Nr_2       <= sw_Nr_2[3]	  ;
				Nr_3       <= sw_Nr_3[3]	  ;
				Nr_4       <= sw_Nr_4[3]	  ;
				Nr_5       <= sw_Nr_5[3]	  ;
				Nr_6       <= sw_Nr_6[3]	  ;
				Nr_7       <= sw_Nr_7[3]	  ;
				location_0 <= sw_location_0[3];
				location_1 <= sw_location_1[3];
				location_2 <= sw_location_2[3];
				location_3 <= sw_location_3[3];
				location_4 <= sw_location_4[3];
				location_5 <= sw_location_5[3];
				location_6 <= sw_location_6[3];
				location_7 <= sw_location_7[3];
				Nr_8       <= sw_Nr_8[3]	  ;
				Nr_9       <= sw_Nr_9[3]	  ;
				Nr_10      <= sw_Nr_10[3]	  ;
				Nr_11      <= sw_Nr_11[3]	  ;
				Nr_12      <= sw_Nr_12[3]	  ;
				Nr_13      <= sw_Nr_13[3]	  ;
				Nr_14      <= sw_Nr_14[3]	  ;
				Nr_15      <= sw_Nr_15[3]	  ;
				location_8 <=   sw_location_8[3];
				location_9 <=   sw_location_9[3];
				location_10 <= sw_location_10[3];
				location_11 <= sw_location_11[3];
				location_12 <= sw_location_12[3];
				location_13 <= sw_location_13[3];
				location_14 <= sw_location_14[3];
				location_15 <= sw_location_15[3];

				Nr_16      <= sw_Nr_16[3] 	  ;
				Nr_17      <= sw_Nr_17[3] 	  ;
				Nr_18      <= sw_Nr_18[3] 	  ;
				Nr_19      <= sw_Nr_19[3] 	  ;
				Nr_20      <= sw_Nr_20[3] 	  ;
				Nr_21      <= sw_Nr_21[3] 	  ;
				Nr_22      <= sw_Nr_22[3] 	  ;
				Nr_23      <= sw_Nr_23[3] 	  ;
				Nr_24      <= sw_Nr_24[3] 	  ;
				Nr_25      <= sw_Nr_25[3] 	  ;
				Nr_26      <= sw_Nr_26[3] 	  ;
				Nr_27      <= sw_Nr_27[3] 	  ;
				Nr_28      <= sw_Nr_28[3] 	  ;
				Nr_29      <= sw_Nr_29[3] 	  ;
				Nr_30      <= sw_Nr_30[3] 	  ;
				Nr_31      <= sw_Nr_31[3] 	  ;

				location_16 <= sw_location_16[3];
				location_17 <= sw_location_17[3];
				location_18 <= sw_location_18[3];
				location_19 <= sw_location_19[3];
				location_20 <= sw_location_20[3];
				location_21 <= sw_location_21[3];
				location_22 <= sw_location_22[3];
				location_23 <= sw_location_23[3];
				location_24 <= sw_location_24[3];
				location_25 <= sw_location_25[3];
				location_26 <= sw_location_26[3];
				location_27 <= sw_location_27[3];
				location_28 <= sw_location_28[3];
				location_29 <= sw_location_29[3];
				location_30 <= sw_location_30[3];
				location_31 <= sw_location_31[3];

				Nr_32      <= sw_Nr_32[3]     ;
				Nr_33      <= sw_Nr_33[3]     ;
				Nr_34      <= sw_Nr_34[3]     ;
				Nr_35      <= sw_Nr_35[3]     ;
				Nr_36      <= sw_Nr_36[3]     ;
				Nr_37      <= sw_Nr_37[3]     ;
				Nr_38      <= sw_Nr_38[3]     ;
				Nr_39      <= sw_Nr_39[3]     ;
				Nr_40      <= sw_Nr_40[3]     ;
				Nr_41      <= sw_Nr_41[3]     ;
				Nr_42      <= sw_Nr_42[3]     ;
				Nr_43      <= sw_Nr_43[3]     ;
				Nr_44      <= sw_Nr_44[3]     ;
				Nr_45      <= sw_Nr_45[3]     ;
				Nr_46      <= sw_Nr_46[3]     ;
				Nr_47      <= sw_Nr_47[3]     ;
				Nr_48      <= sw_Nr_48[3]     ;
				Nr_49      <= sw_Nr_49[3]     ;
				Nr_50      <= sw_Nr_50[3]     ;
				Nr_51      <= sw_Nr_51[3]     ;
				Nr_52      <= sw_Nr_52[3]     ;
				Nr_53      <= sw_Nr_53[3]     ;
				Nr_54      <= sw_Nr_54[3]     ;
				Nr_55      <= sw_Nr_55[3]     ;
				Nr_56      <= sw_Nr_56[3]     ;
				Nr_57      <= sw_Nr_57[3]     ;
				Nr_58      <= sw_Nr_58[3]     ;
				Nr_59      <= sw_Nr_59[3]     ;
				Nr_60      <= sw_Nr_60[3]     ;
				Nr_61      <= sw_Nr_61[3]     ;
				Nr_62      <= sw_Nr_62[3]     ;
				Nr_63      <= sw_Nr_63[3]     ;
				location_32 <= sw_location_32[3];
				location_33 <= sw_location_33[3];
				location_34 <= sw_location_34[3];
				location_35 <= sw_location_35[3];
				location_36 <= sw_location_36[3];
				location_37 <= sw_location_37[3];
				location_38 <= sw_location_38[3];
				location_39 <= sw_location_39[3];
				location_40 <= sw_location_40[3];
				location_41 <= sw_location_41[3];
				location_42 <= sw_location_42[3];
				location_43 <= sw_location_43[3];
				location_44 <= sw_location_44[3];
				location_45 <= sw_location_45[3];
				location_46 <= sw_location_46[3];
				location_47 <= sw_location_47[3];
				location_48 <= sw_location_48[3];
				location_49 <= sw_location_49[3];
				location_50 <= sw_location_50[3];
				location_51 <= sw_location_51[3];
				location_52 <= sw_location_52[3];
				location_53 <= sw_location_53[3];
				location_54 <= sw_location_54[3];
				location_55 <= sw_location_55[3];
				location_56 <= sw_location_56[3];
				location_57 <= sw_location_57[3];
				location_58 <= sw_location_58[3];
				location_59 <= sw_location_59[3];
				location_60 <= sw_location_60[3];
				location_61 <= sw_location_61[3];
				location_62 <= sw_location_62[3];
				location_63 <= sw_location_63[3];

				Nr_64      <= sw_Nr_64[3]     ;
				Nr_65      <= sw_Nr_65[3]     ;
				Nr_66      <= sw_Nr_66[3]     ;
				Nr_67      <= sw_Nr_67[3]     ;
				Nr_68      <= sw_Nr_68[3]     ;
				Nr_69      <= sw_Nr_69[3]     ;
				Nr_70      <= sw_Nr_70[3]     ;
				Nr_71      <= sw_Nr_71[3]     ;
				Nr_72      <= sw_Nr_72[3]     ;
				Nr_73      <= sw_Nr_73[3]     ;
				Nr_74      <= sw_Nr_74[3]     ;
				Nr_75      <= sw_Nr_75[3]     ;
				Nr_76      <= sw_Nr_76[3]     ;
				Nr_77      <= sw_Nr_77[3]     ;
				Nr_78      <= sw_Nr_78[3]     ;
				Nr_79      <= sw_Nr_79[3]     ;
				Nr_80      <= sw_Nr_80[3]     ;
				Nr_81      <= sw_Nr_81[3]     ;
				Nr_82      <= sw_Nr_82[3]     ;
				Nr_83      <= sw_Nr_83[3]     ;
				Nr_84      <= sw_Nr_84[3]     ;
				Nr_85      <= sw_Nr_85[3]     ;
				Nr_86      <= sw_Nr_86[3]     ;
				Nr_87      <= sw_Nr_87[3]     ;
				Nr_88      <= sw_Nr_88[3]     ;
				Nr_89      <= sw_Nr_89[3]     ;
				Nr_90      <= sw_Nr_90[3]     ;
				Nr_91      <= sw_Nr_91[3]     ;
				Nr_92      <= sw_Nr_92[3]     ;
				Nr_93      <= sw_Nr_93[3]     ;
				Nr_94      <= sw_Nr_94[3]     ;
				Nr_95      <= sw_Nr_95[3]     ;
				Nr_96      <= sw_Nr_96[3]     ;
				Nr_97      <= sw_Nr_97[3]     ;
				Nr_98      <= sw_Nr_98[3]     ;
				Nr_99      <= sw_Nr_99[3]     ;
				Nr_100      <= sw_Nr_100[3]     ;
				Nr_101      <= sw_Nr_101[3]     ;
				Nr_102      <= sw_Nr_102[3]     ;
				Nr_103      <= sw_Nr_103[3]     ;
				Nr_104      <= sw_Nr_104[3]     ;
				Nr_105      <= sw_Nr_105[3]     ;
				Nr_106      <= sw_Nr_106[3]     ;
				Nr_107      <= sw_Nr_107[3]     ;
				Nr_108      <= sw_Nr_108[3]     ;
				Nr_109      <= sw_Nr_109[3]     ;
				Nr_110      <= sw_Nr_110[3]     ;
				Nr_111      <= sw_Nr_111[3]     ;
				Nr_112      <= sw_Nr_112[3]     ;
				Nr_113      <= sw_Nr_113[3]     ;
				Nr_114      <= sw_Nr_114[3]     ;
				Nr_115      <= sw_Nr_115[3]     ;
				Nr_116      <= sw_Nr_116[3]     ;
				Nr_117      <= sw_Nr_117[3]     ;
				Nr_118      <= sw_Nr_118[3]     ;
				Nr_119      <= sw_Nr_119[3]     ;
				Nr_120      <= sw_Nr_120[3]     ;
				Nr_121      <= sw_Nr_121[3]     ;
				Nr_122      <= sw_Nr_122[3]     ;
				Nr_123      <= sw_Nr_123[3]     ;
				Nr_124      <= sw_Nr_124[3]     ;
				Nr_125      <= sw_Nr_125[3]     ;
				Nr_126      <= sw_Nr_126[3]     ;
				Nr_127      <= sw_Nr_127[3]     ;
				location_64      <= sw_location_64[3]     ;
				location_65      <= sw_location_65[3]     ;
				location_66      <= sw_location_66[3]     ;
				location_67      <= sw_location_67[3]     ;
				location_68      <= sw_location_68[3]     ;
				location_69      <= sw_location_69[3]     ;
				location_70      <= sw_location_70[3]     ;
				location_71      <= sw_location_71[3]     ;
				location_72      <= sw_location_72[3]     ;
				location_73      <= sw_location_73[3]     ;
				location_74      <= sw_location_74[3]     ;
				location_75      <= sw_location_75[3]     ;
				location_76      <= sw_location_76[3]     ;
				location_77      <= sw_location_77[3]     ;
				location_78      <= sw_location_78[3]     ;
				location_79      <= sw_location_79[3]     ;
				location_80      <= sw_location_80[3]     ;
				location_81      <= sw_location_81[3]     ;
				location_82      <= sw_location_82[3]     ;
				location_83      <= sw_location_83[3]     ;
				location_84      <= sw_location_84[3]     ;
				location_85      <= sw_location_85[3]     ;
				location_86      <= sw_location_86[3]     ;
				location_87      <= sw_location_87[3]     ;
				location_88      <= sw_location_88[3]     ;
				location_89      <= sw_location_89[3]     ;
				location_90      <= sw_location_90[3]     ;
				location_91      <= sw_location_91[3]     ;
				location_92      <= sw_location_92[3]     ;
				location_93      <= sw_location_93[3]     ;
				location_94      <= sw_location_94[3]     ;
				location_95      <= sw_location_95[3]     ;
				location_96      <= sw_location_96[3]     ;
				location_97      <= sw_location_97[3]     ;
				location_98      <= sw_location_98[3]     ;
				location_99      <= sw_location_99[3]     ;
				location_100      <= sw_location_100[3]     ;
				location_101      <= sw_location_101[3]     ;
				location_102      <= sw_location_102[3]     ;
				location_103      <= sw_location_103[3]     ;
				location_104      <= sw_location_104[3]     ;
				location_105      <= sw_location_105[3]     ;
				location_106      <= sw_location_106[3]     ;
				location_107      <= sw_location_107[3]     ;
				location_108      <= sw_location_108[3]     ;
				location_109      <= sw_location_109[3]     ;
				location_110      <= sw_location_110[3]     ;
				location_111      <= sw_location_111[3]     ;
				location_112      <= sw_location_112[3]     ;
				location_113      <= sw_location_113[3]     ;
				location_114      <= sw_location_114[3]     ;
				location_115      <= sw_location_115[3]     ;
				location_116      <= sw_location_116[3]     ;
				location_117      <= sw_location_117[3]     ;
				location_118      <= sw_location_118[3]     ;
				location_119      <= sw_location_119[3]     ;
				location_120      <= sw_location_120[3]     ;
				location_121      <= sw_location_121[3]     ;
				location_122      <= sw_location_122[3]     ;
				location_123      <= sw_location_123[3]     ;
				location_124      <= sw_location_124[3]     ;
				location_125      <= sw_location_125[3]     ;
				location_126      <= sw_location_126[3]     ;
				location_127      <= sw_location_127[3]     ;

		end 

		T5:begin
				Nr_0       <= sw_Nr_0[4]	  ;
				Nr_1       <= sw_Nr_1[4]	  ;
				Nr_2       <= sw_Nr_2[4]	  ;
				Nr_3       <= sw_Nr_3[4]	  ;
				Nr_4       <= sw_Nr_4[4]	  ;
				Nr_5       <= sw_Nr_5[4]	  ;
				Nr_6       <= sw_Nr_6[4]	  ;
				Nr_7       <= sw_Nr_7[4]	  ;
				location_0 <= sw_location_0[4];
				location_1 <= sw_location_1[4];
				location_2 <= sw_location_2[4];
				location_3 <= sw_location_3[4];
				location_4 <= sw_location_4[4];
				location_5 <= sw_location_5[4];
				location_6 <= sw_location_6[4];
				location_7 <= sw_location_7[4];
				Nr_8       <= sw_Nr_8 [4]	  ;
				Nr_9       <= sw_Nr_9 [4]	  ;
				Nr_10      <= sw_Nr_10[4]	  ;
				Nr_11      <= sw_Nr_11[4]	  ;
				Nr_12      <= sw_Nr_12[4]	  ;
				Nr_13      <= sw_Nr_13[4]	  ;
				Nr_14      <= sw_Nr_14[4]	  ;
				Nr_15      <= sw_Nr_15[4]	  ;
				location_8 <=   sw_location_8[4];
				location_9 <=   sw_location_9[4];
				location_10 <= sw_location_10[4];
				location_11 <= sw_location_11[4];
				location_12 <= sw_location_12[4];
				location_13 <= sw_location_13[4];
				location_14 <= sw_location_14[4];
				location_15 <= sw_location_15[4];

				Nr_16      <= sw_Nr_16[4] 	  ;
				Nr_17      <= sw_Nr_17[4] 	  ;
				Nr_18      <= sw_Nr_18[4] 	  ;
				Nr_19      <= sw_Nr_19[4] 	  ;
				Nr_20      <= sw_Nr_20[4] 	  ;
				Nr_21      <= sw_Nr_21[4] 	  ;
				Nr_22      <= sw_Nr_22[4] 	  ;
				Nr_23      <= sw_Nr_23[4] 	  ;
				Nr_24      <= sw_Nr_24[4] 	  ;
				Nr_25      <= sw_Nr_25[4] 	  ;
				Nr_26      <= sw_Nr_26[4] 	  ;
				Nr_27      <= sw_Nr_27[4] 	  ;
				Nr_28      <= sw_Nr_28[4] 	  ;
				Nr_29      <= sw_Nr_29[4] 	  ;
				Nr_30      <= sw_Nr_30[4] 	  ;
				Nr_31      <= sw_Nr_31[4] 	  ;

				location_16 <= sw_location_16[4];
				location_17 <= sw_location_17[4];
				location_18 <= sw_location_18[4];
				location_19 <= sw_location_19[4];
				location_20 <= sw_location_20[4];
				location_21 <= sw_location_21[4];
				location_22 <= sw_location_22[4];
				location_23 <= sw_location_23[4];
				location_24 <= sw_location_24[4];
				location_25 <= sw_location_25[4];
				location_26 <= sw_location_26[4];
				location_27 <= sw_location_27[4];
				location_28 <= sw_location_28[4];
				location_29 <= sw_location_29[4];
				location_30 <= sw_location_30[4];
				location_31 <= sw_location_31[4];

				Nr_32      <= sw_Nr_32[4]     ;
				Nr_33      <= sw_Nr_33[4]     ;
				Nr_34      <= sw_Nr_34[4]     ;
				Nr_35      <= sw_Nr_35[4]     ;
				Nr_36      <= sw_Nr_36[4]     ;
				Nr_37      <= sw_Nr_37[4]     ;
				Nr_38      <= sw_Nr_38[4]     ;
				Nr_39      <= sw_Nr_39[4]     ;
				Nr_40      <= sw_Nr_40[4]     ;
				Nr_41      <= sw_Nr_41[4]     ;
				Nr_42      <= sw_Nr_42[4]     ;
				Nr_43      <= sw_Nr_43[4]     ;
				Nr_44      <= sw_Nr_44[4]     ;
				Nr_45      <= sw_Nr_45[4]     ;
				Nr_46      <= sw_Nr_46[4]     ;
				Nr_47      <= sw_Nr_47[4]     ;
				Nr_48      <= sw_Nr_48[4]     ;
				Nr_49      <= sw_Nr_49[4]     ;
				Nr_50      <= sw_Nr_50[4]     ;
				Nr_51      <= sw_Nr_51[4]     ;
				Nr_52      <= sw_Nr_52[4]     ;
				Nr_53      <= sw_Nr_53[4]     ;
				Nr_54      <= sw_Nr_54[4]     ;
				Nr_55      <= sw_Nr_55[4]     ;
				Nr_56      <= sw_Nr_56[4]     ;
				Nr_57      <= sw_Nr_57[4]     ;
				Nr_58      <= sw_Nr_58[4]     ;
				Nr_59      <= sw_Nr_59[4]     ;
				Nr_60      <= sw_Nr_60[4]     ;
				Nr_61      <= sw_Nr_61[4]     ;
				Nr_62      <= sw_Nr_62[4]     ;
				Nr_63      <= sw_Nr_63[4]     ;
				location_32 <= sw_location_32[4];
				location_33 <= sw_location_33[4];
				location_34 <= sw_location_34[4];
				location_35 <= sw_location_35[4];
				location_36 <= sw_location_36[4];
				location_37 <= sw_location_37[4];
				location_38 <= sw_location_38[4];
				location_39 <= sw_location_39[4];
				location_40 <= sw_location_40[4];
				location_41 <= sw_location_41[4];
				location_42 <= sw_location_42[4];
				location_43 <= sw_location_43[4];
				location_44 <= sw_location_44[4];
				location_45 <= sw_location_45[4];
				location_46 <= sw_location_46[4];
				location_47 <= sw_location_47[4];
				location_48 <= sw_location_48[4];
				location_49 <= sw_location_49[4];
				location_50 <= sw_location_50[4];
				location_51 <= sw_location_51[4];
				location_52 <= sw_location_52[4];
				location_53 <= sw_location_53[4];
				location_54 <= sw_location_54[4];
				location_55 <= sw_location_55[4];
				location_56 <= sw_location_56[4];
				location_57 <= sw_location_57[4];
				location_58 <= sw_location_58[4];
				location_59 <= sw_location_59[4];
				location_60 <= sw_location_60[4];
				location_61 <= sw_location_61[4];
				location_62 <= sw_location_62[4];
				location_63 <= sw_location_63[4];

				Nr_64      <= sw_Nr_64[4]     ;
				Nr_65      <= sw_Nr_65[4]     ;
				Nr_66      <= sw_Nr_66[4]     ;
				Nr_67      <= sw_Nr_67[4]     ;
				Nr_68      <= sw_Nr_68[4]     ;
				Nr_69      <= sw_Nr_69[4]     ;
				Nr_70      <= sw_Nr_70[4]     ;
				Nr_71      <= sw_Nr_71[4]     ;
				Nr_72      <= sw_Nr_72[4]     ;
				Nr_73      <= sw_Nr_73[4]     ;
				Nr_74      <= sw_Nr_74[4]     ;
				Nr_75      <= sw_Nr_75[4]     ;
				Nr_76      <= sw_Nr_76[4]     ;
				Nr_77      <= sw_Nr_77[4]     ;
				Nr_78      <= sw_Nr_78[4]     ;
				Nr_79      <= sw_Nr_79[4]     ;
				Nr_80      <= sw_Nr_80[4]     ;
				Nr_81      <= sw_Nr_81[4]     ;
				Nr_82      <= sw_Nr_82[4]     ;
				Nr_83      <= sw_Nr_83[4]     ;
				Nr_84      <= sw_Nr_84[4]     ;
				Nr_85      <= sw_Nr_85[4]     ;
				Nr_86      <= sw_Nr_86[4]     ;
				Nr_87      <= sw_Nr_87[4]     ;
				Nr_88      <= sw_Nr_88[4]     ;
				Nr_89      <= sw_Nr_89[4]     ;
				Nr_90      <= sw_Nr_90[4]     ;
				Nr_91      <= sw_Nr_91[4]     ;
				Nr_92      <= sw_Nr_92[4]     ;
				Nr_93      <= sw_Nr_93[4]     ;
				Nr_94      <= sw_Nr_94[4]     ;
				Nr_95      <= sw_Nr_95[4]     ;
				Nr_96      <= sw_Nr_96[4]     ;
				Nr_97      <= sw_Nr_97[4]     ;
				Nr_98      <= sw_Nr_98[4]     ;
				Nr_99      <= sw_Nr_99[4]     ;
				Nr_100      <= sw_Nr_100[4]     ;
				Nr_101      <= sw_Nr_101[4]     ;
				Nr_102      <= sw_Nr_102[4]     ;
				Nr_103      <= sw_Nr_103[4]     ;
				Nr_104      <= sw_Nr_104[4]     ;
				Nr_105      <= sw_Nr_105[4]     ;
				Nr_106      <= sw_Nr_106[4]     ;
				Nr_107      <= sw_Nr_107[4]     ;
				Nr_108      <= sw_Nr_108[4]     ;
				Nr_109      <= sw_Nr_109[4]     ;
				Nr_110      <= sw_Nr_110[4]     ;
				Nr_111      <= sw_Nr_111[4]     ;
				Nr_112      <= sw_Nr_112[4]     ;
				Nr_113      <= sw_Nr_113[4]     ;
				Nr_114      <= sw_Nr_114[4]     ;
				Nr_115      <= sw_Nr_115[4]     ;
				Nr_116      <= sw_Nr_116[4]     ;
				Nr_117      <= sw_Nr_117[4]     ;
				Nr_118      <= sw_Nr_118[4]     ;
				Nr_119      <= sw_Nr_119[4]     ;
				Nr_120      <= sw_Nr_120[4]     ;
				Nr_121      <= sw_Nr_121[4]     ;
				Nr_122      <= sw_Nr_122[4]     ;
				Nr_123      <= sw_Nr_123[4]     ;
				Nr_124      <= sw_Nr_124[4]     ;
				Nr_125      <= sw_Nr_125[4]     ;
				Nr_126      <= sw_Nr_126[4]     ;
				Nr_127      <= sw_Nr_127[4]     ;
				location_64      <= sw_location_64[4]     ;
				location_65      <= sw_location_65[4]     ;
				location_66      <= sw_location_66[4]     ;
				location_67      <= sw_location_67[4]     ;
				location_68      <= sw_location_68[4]     ;
				location_69      <= sw_location_69[4]     ;
				location_70      <= sw_location_70[4]     ;
				location_71      <= sw_location_71[4]     ;
				location_72      <= sw_location_72[4]     ;
				location_73      <= sw_location_73[4]     ;
				location_74      <= sw_location_74[4]     ;
				location_75      <= sw_location_75[4]     ;
				location_76      <= sw_location_76[4]     ;
				location_77      <= sw_location_77[4]     ;
				location_78      <= sw_location_78[4]     ;
				location_79      <= sw_location_79[4]     ;
				location_80      <= sw_location_80[4]     ;
				location_81      <= sw_location_81[4]     ;
				location_82      <= sw_location_82[4]     ;
				location_83      <= sw_location_83[4]     ;
				location_84      <= sw_location_84[4]     ;
				location_85      <= sw_location_85[4]     ;
				location_86      <= sw_location_86[4]     ;
				location_87      <= sw_location_87[4]     ;
				location_88      <= sw_location_88[4]     ;
				location_89      <= sw_location_89[4]     ;
				location_90      <= sw_location_90[4]     ;
				location_91      <= sw_location_91[4]     ;
				location_92      <= sw_location_92[4]     ;
				location_93      <= sw_location_93[4]     ;
				location_94      <= sw_location_94[4]     ;
				location_95      <= sw_location_95[4]     ;
				location_96      <= sw_location_96[4]     ;
				location_97      <= sw_location_97[4]     ;
				location_98      <= sw_location_98[4]     ;
				location_99      <= sw_location_99[4]     ;
				location_100      <= sw_location_100[4]     ;
				location_101      <= sw_location_101[4]     ;
				location_102      <= sw_location_102[4]     ;
				location_103      <= sw_location_103[4]     ;
				location_104      <= sw_location_104[4]     ;
				location_105      <= sw_location_105[4]     ;
				location_106      <= sw_location_106[4]     ;
				location_107      <= sw_location_107[4]     ;
				location_108      <= sw_location_108[4]     ;
				location_109      <= sw_location_109[4]     ;
				location_110      <= sw_location_110[4]     ;
				location_111      <= sw_location_111[4]     ;
				location_112      <= sw_location_112[4]     ;
				location_113      <= sw_location_113[4]     ;
				location_114      <= sw_location_114[4]     ;
				location_115      <= sw_location_115[4]     ;
				location_116      <= sw_location_116[4]     ;
				location_117      <= sw_location_117[4]     ;
				location_118      <= sw_location_118[4]     ;
				location_119      <= sw_location_119[4]     ;
				location_120      <= sw_location_120[4]     ;
				location_121      <= sw_location_121[4]     ;
				location_122      <= sw_location_122[4]     ;
				location_123      <= sw_location_123[4]     ;
				location_124      <= sw_location_124[4]     ;
				location_125      <= sw_location_125[4]     ;
				location_126      <= sw_location_126[4]     ;
				location_127      <= sw_location_127[4]     ;

		end 

		T6:begin
				Nr_0       <= sw_Nr_0[5]	  ;
				Nr_1       <= sw_Nr_1[5]	  ;
				Nr_2       <= sw_Nr_2[5]	  ;
				Nr_3       <= sw_Nr_3[5]	  ;
				Nr_4       <= sw_Nr_4[5]	  ;
				Nr_5       <= sw_Nr_5[5]	  ;
				Nr_6       <= sw_Nr_6[5]	  ;
				Nr_7       <= sw_Nr_7[5]	  ;
				location_0 <= sw_location_0[5];
				location_1 <= sw_location_1[5];
				location_2 <= sw_location_2[5];
				location_3 <= sw_location_3[5];
				location_4 <= sw_location_4[5];
				location_5 <= sw_location_5[5];
				location_6 <= sw_location_6[5];
				location_7 <= sw_location_7[5];
				Nr_8       <= sw_Nr_8 [5]	  ;
				Nr_9       <= sw_Nr_9 [5]	  ;
				Nr_10      <= sw_Nr_10[5]	  ;
				Nr_11      <= sw_Nr_11[5]	  ;
				Nr_12      <= sw_Nr_12[5]	  ;
				Nr_13      <= sw_Nr_13[5]	  ;
				Nr_14      <= sw_Nr_14[5]	  ;
				Nr_15      <= sw_Nr_15[5]	  ;
				location_8 <=   sw_location_8[5];
				location_9 <=   sw_location_9[5];
				location_10 <= sw_location_10[5];
				location_11 <= sw_location_11[5];
				location_12 <= sw_location_12[5];
				location_13 <= sw_location_13[5];
				location_14 <= sw_location_14[5];
				location_15 <= sw_location_15[5];

				Nr_16      <= sw_Nr_16[5] 	  ;
				Nr_17      <= sw_Nr_17[5] 	  ;
				Nr_18      <= sw_Nr_18[5] 	  ;
				Nr_19      <= sw_Nr_19[5] 	  ;
				Nr_20      <= sw_Nr_20[5] 	  ;
				Nr_21      <= sw_Nr_21[5] 	  ;
				Nr_22      <= sw_Nr_22[5] 	  ;
				Nr_23      <= sw_Nr_23[5] 	  ;
				Nr_24      <= sw_Nr_24[5] 	  ;
				Nr_25      <= sw_Nr_25[5] 	  ;
				Nr_26      <= sw_Nr_26[5] 	  ;
				Nr_27      <= sw_Nr_27[5] 	  ;
				Nr_28      <= sw_Nr_28[5] 	  ;
				Nr_29      <= sw_Nr_29[5] 	  ;
				Nr_30      <= sw_Nr_30[5] 	  ;
				Nr_31      <= sw_Nr_31[5] 	  ;

				location_16 <= sw_location_16[5];
				location_17 <= sw_location_17[5];
				location_18 <= sw_location_18[5];
				location_19 <= sw_location_19[5];
				location_20 <= sw_location_20[5];
				location_21 <= sw_location_21[5];
				location_22 <= sw_location_22[5];
				location_23 <= sw_location_23[5];
				location_24 <= sw_location_24[5];
				location_25 <= sw_location_25[5];
				location_26 <= sw_location_26[5];
				location_27 <= sw_location_27[5];
				location_28 <= sw_location_28[5];
				location_29 <= sw_location_29[5];
				location_30 <= sw_location_30[5];
				location_31 <= sw_location_31[5];

				Nr_32      <= sw_Nr_32[5]     ;
				Nr_33      <= sw_Nr_33[5]     ;
				Nr_34      <= sw_Nr_34[5]     ;
				Nr_35      <= sw_Nr_35[5]     ;
				Nr_36      <= sw_Nr_36[5]     ;
				Nr_37      <= sw_Nr_37[5]     ;
				Nr_38      <= sw_Nr_38[5]     ;
				Nr_39      <= sw_Nr_39[5]     ;
				Nr_40      <= sw_Nr_40[5]     ;
				Nr_41      <= sw_Nr_41[5]     ;
				Nr_42      <= sw_Nr_42[5]     ;
				Nr_43      <= sw_Nr_43[5]     ;
				Nr_44      <= sw_Nr_44[5]     ;
				Nr_45      <= sw_Nr_45[5]     ;
				Nr_46      <= sw_Nr_46[5]     ;
				Nr_47      <= sw_Nr_47[5]     ;
				Nr_48      <= sw_Nr_48[5]     ;
				Nr_49      <= sw_Nr_49[5]     ;
				Nr_50      <= sw_Nr_50[5]     ;
				Nr_51      <= sw_Nr_51[5]     ;
				Nr_52      <= sw_Nr_52[5]     ;
				Nr_53      <= sw_Nr_53[5]     ;
				Nr_54      <= sw_Nr_54[5]     ;
				Nr_55      <= sw_Nr_55[5]     ;
				Nr_56      <= sw_Nr_56[5]     ;
				Nr_57      <= sw_Nr_57[5]     ;
				Nr_58      <= sw_Nr_58[5]     ;
				Nr_59      <= sw_Nr_59[5]     ;
				Nr_60      <= sw_Nr_60[5]     ;
				Nr_61      <= sw_Nr_61[5]     ;
				Nr_62      <= sw_Nr_62[5]     ;
				Nr_63      <= sw_Nr_63[5]     ;
				location_32 <= sw_location_32[5];
				location_33 <= sw_location_33[5];
				location_34 <= sw_location_34[5];
				location_35 <= sw_location_35[5];
				location_36 <= sw_location_36[5];
				location_37 <= sw_location_37[5];
				location_38 <= sw_location_38[5];
				location_39 <= sw_location_39[5];
				location_40 <= sw_location_40[5];
				location_41 <= sw_location_41[5];
				location_42 <= sw_location_42[5];
				location_43 <= sw_location_43[5];
				location_44 <= sw_location_44[5];
				location_45 <= sw_location_45[5];
				location_46 <= sw_location_46[5];
				location_47 <= sw_location_47[5];
				location_48 <= sw_location_48[5];
				location_49 <= sw_location_49[5];
				location_50 <= sw_location_50[5];
				location_51 <= sw_location_51[5];
				location_52 <= sw_location_52[5];
				location_53 <= sw_location_53[5];
				location_54 <= sw_location_54[5];
				location_55 <= sw_location_55[5];
				location_56 <= sw_location_56[5];
				location_57 <= sw_location_57[5];
				location_58 <= sw_location_58[5];
				location_59 <= sw_location_59[5];
				location_60 <= sw_location_60[5];
				location_61 <= sw_location_61[5];
				location_62 <= sw_location_62[5];
				location_63 <= sw_location_63[5];

				Nr_64      <= sw_Nr_64[5]     ;
				Nr_65      <= sw_Nr_65[5]     ;
				Nr_66      <= sw_Nr_66[5]     ;
				Nr_67      <= sw_Nr_67[5]     ;
				Nr_68      <= sw_Nr_68[5]     ;
				Nr_69      <= sw_Nr_69[5]     ;
				Nr_70      <= sw_Nr_70[5]     ;
				Nr_71      <= sw_Nr_71[5]     ;
				Nr_72      <= sw_Nr_72[5]     ;
				Nr_73      <= sw_Nr_73[5]     ;
				Nr_74      <= sw_Nr_74[5]     ;
				Nr_75      <= sw_Nr_75[5]     ;
				Nr_76      <= sw_Nr_76[5]     ;
				Nr_77      <= sw_Nr_77[5]     ;
				Nr_78      <= sw_Nr_78[5]     ;
				Nr_79      <= sw_Nr_79[5]     ;
				Nr_80      <= sw_Nr_80[5]     ;
				Nr_81      <= sw_Nr_81[5]     ;
				Nr_82      <= sw_Nr_82[5]     ;
				Nr_83      <= sw_Nr_83[5]     ;
				Nr_84      <= sw_Nr_84[5]     ;
				Nr_85      <= sw_Nr_85[5]     ;
				Nr_86      <= sw_Nr_86[5]     ;
				Nr_87      <= sw_Nr_87[5]     ;
				Nr_88      <= sw_Nr_88[5]     ;
				Nr_89      <= sw_Nr_89[5]     ;
				Nr_90      <= sw_Nr_90[5]     ;
				Nr_91      <= sw_Nr_91[5]     ;
				Nr_92      <= sw_Nr_92[5]     ;
				Nr_93      <= sw_Nr_93[5]     ;
				Nr_94      <= sw_Nr_94[5]     ;
				Nr_95      <= sw_Nr_95[5]     ;
				Nr_96      <= sw_Nr_96[5]     ;
				Nr_97      <= sw_Nr_97[5]     ;
				Nr_98      <= sw_Nr_98[5]     ;
				Nr_99      <= sw_Nr_99[5]     ;
				Nr_100      <= sw_Nr_100[5]     ;
				Nr_101      <= sw_Nr_101[5]     ;
				Nr_102      <= sw_Nr_102[5]     ;
				Nr_103      <= sw_Nr_103[5]     ;
				Nr_104      <= sw_Nr_104[5]     ;
				Nr_105      <= sw_Nr_105[5]     ;
				Nr_106      <= sw_Nr_106[5]     ;
				Nr_107      <= sw_Nr_107[5]     ;
				Nr_108      <= sw_Nr_108[5]     ;
				Nr_109      <= sw_Nr_109[5]     ;
				Nr_110      <= sw_Nr_110[5]     ;
				Nr_111      <= sw_Nr_111[5]     ;
				Nr_112      <= sw_Nr_112[5]     ;
				Nr_113      <= sw_Nr_113[5]     ;
				Nr_114      <= sw_Nr_114[5]     ;
				Nr_115      <= sw_Nr_115[5]     ;
				Nr_116      <= sw_Nr_116[5]     ;
				Nr_117      <= sw_Nr_117[5]     ;
				Nr_118      <= sw_Nr_118[5]     ;
				Nr_119      <= sw_Nr_119[5]     ;
				Nr_120      <= sw_Nr_120[5]     ;
				Nr_121      <= sw_Nr_121[5]     ;
				Nr_122      <= sw_Nr_122[5]     ;
				Nr_123      <= sw_Nr_123[5]     ;
				Nr_124      <= sw_Nr_124[5]     ;
				Nr_125      <= sw_Nr_125[5]     ;
				Nr_126      <= sw_Nr_126[5]     ;
				Nr_127      <= sw_Nr_127[5]     ;
				location_64      <= sw_location_64[5]     ;
				location_65      <= sw_location_65[5]     ;
				location_66      <= sw_location_66[5]     ;
				location_67      <= sw_location_67[5]     ;
				location_68      <= sw_location_68[5]     ;
				location_69      <= sw_location_69[5]     ;
				location_70      <= sw_location_70[5]     ;
				location_71      <= sw_location_71[5]     ;
				location_72      <= sw_location_72[5]     ;
				location_73      <= sw_location_73[5]     ;
				location_74      <= sw_location_74[5]     ;
				location_75      <= sw_location_75[5]     ;
				location_76      <= sw_location_76[5]     ;
				location_77      <= sw_location_77[5]     ;
				location_78      <= sw_location_78[5]     ;
				location_79      <= sw_location_79[5]     ;
				location_80      <= sw_location_80[5]     ;
				location_81      <= sw_location_81[5]     ;
				location_82      <= sw_location_82[5]     ;
				location_83      <= sw_location_83[5]     ;
				location_84      <= sw_location_84[5]     ;
				location_85      <= sw_location_85[5]     ;
				location_86      <= sw_location_86[5]     ;
				location_87      <= sw_location_87[5]     ;
				location_88      <= sw_location_88[5]     ;
				location_89      <= sw_location_89[5]     ;
				location_90      <= sw_location_90[5]     ;
				location_91      <= sw_location_91[5]     ;
				location_92      <= sw_location_92[5]     ;
				location_93      <= sw_location_93[5]     ;
				location_94      <= sw_location_94[5]     ;
				location_95      <= sw_location_95[5]     ;
				location_96      <= sw_location_96[5]     ;
				location_97      <= sw_location_97[5]     ;
				location_98      <= sw_location_98[5]     ;
				location_99      <= sw_location_99[5]     ;
				location_100      <= sw_location_100[5]     ;
				location_101      <= sw_location_101[5]     ;
				location_102      <= sw_location_102[5]     ;
				location_103      <= sw_location_103[5]     ;
				location_104      <= sw_location_104[5]     ;
				location_105      <= sw_location_105[5]     ;
				location_106      <= sw_location_106[5]     ;
				location_107      <= sw_location_107[5]     ;
				location_108      <= sw_location_108[5]     ;
				location_109      <= sw_location_109[5]     ;
				location_110      <= sw_location_110[5]     ;
				location_111      <= sw_location_111[5]     ;
				location_112      <= sw_location_112[5]     ;
				location_113      <= sw_location_113[5]     ;
				location_114      <= sw_location_114[5]     ;
				location_115      <= sw_location_115[5]     ;
				location_116      <= sw_location_116[5]     ;
				location_117      <= sw_location_117[5]     ;
				location_118      <= sw_location_118[5]     ;
				location_119      <= sw_location_119[5]     ;
				location_120      <= sw_location_120[5]     ;
				location_121      <= sw_location_121[5]     ;
				location_122      <= sw_location_122[5]     ;
				location_123      <= sw_location_123[5]     ;
				location_124      <= sw_location_124[5]     ;
				location_125      <= sw_location_125[5]     ;
				location_126      <= sw_location_126[5]     ;
				location_127      <= sw_location_127[5]     ;

		end 
	endcase 
end

/*-------------------------------------------------------------------*\
                          PU4 to sw_send
\*-------------------------------------------------------------------*/
always @(posedge  sys_clk)
begin 
	case (shift_reg)
		T0: begin
			sw_H_to_s        [5] <= H_to_s 		  ;
			sw_F_to_s        [5] <= F_to_s 		  ; 
			sw_F2_to_s       [5] <= F2_to_s 	  ; //CJ
			sw_bt_to_s       [4] <= bt_out        ; //
			sw_score_write   [5] <= score_write   ;
			sw_max_result    [3] <= max_result 	  ;
			sw_row_max_result[3] <= row_max_result;
			sw_col_max_result[3] <= col_max_result;
			sw_diagonal_score[3] <= diagonal_score;
			sw_start_out     [5] <= start_out 	  ;
			sw_H1_init_in	 [5] <= H1_init_out	  ;
 			sw_H2_init_in	 [5] <= H2_init_out	  ;
 			sw_E1_init_in	 [5] <= E1_init_out	  ;
 			sw_E2_init_in	 [5] <= E2_init_out	  ;
 			sw_col_max_temp_in[5]<= U_col_max_temp_out;
 			sw_col_en        [5] <= col_en_out;

		end // T3:

		T1: begin
			sw_H_to_s        [6] <= H_to_s 		  ;
			sw_F_to_s        [6] <= F_to_s 		  ; 
			sw_F2_to_s        [6] <= F2_to_s 	  ; //CJ
			sw_bt_to_s       [5] <= bt_out        ; //CJ
			sw_score_write   [6] <= score_write   ;
			sw_max_result    [4] <= max_result 	  ;
			sw_row_max_result[4] <= row_max_result;
			sw_col_max_result[4] <= col_max_result;
			sw_diagonal_score[4] <= diagonal_score;
			sw_start_out     [6] <= start_out 	  ;
			sw_H1_init_in	 [6] <= H1_init_out	  ;
 			sw_H2_init_in	 [6] <= H2_init_out	  ;
 			sw_E1_init_in	 [6] <= E1_init_out	  ;
 			sw_E2_init_in	 [6] <= E2_init_out	  ;
 			sw_col_max_temp_in[6]<= U_col_max_temp_out;
 			sw_col_en        [6] <= col_en_out;
		end // T3:

		T2: begin
			sw_H_to_s        [0] <= H_to_s 		  ;
			sw_F_to_s        [0] <= F_to_s 		  ; 
			sw_F2_to_s        [0] <= F2_to_s 		  ; //CJ
			sw_bt_to_s       [6] <= bt_out        ;
			sw_score_write   [0] <= score_write   ;
			sw_max_result    [5] <= max_result 	  ;
			sw_row_max_result[5] <= row_max_result;
			sw_col_max_result[5] <= col_max_result;
			sw_diagonal_score[5] <= diagonal_score;
			sw_start_out     [0] <= start_out 	  ;
			sw_H1_init_in	 [0] <= H1_init_out	  ;
 			sw_H2_init_in	 [0] <= H2_init_out	  ;
 			sw_E1_init_in	 [0] <= E1_init_out	  ;
 			sw_E2_init_in	 [0] <= E2_init_out	  ;
 			sw_col_max_temp_in[0]<= U_col_max_temp_out;
 			sw_col_en        [0] <= col_en_out;
		end // T3:

		T3: begin
			sw_H_to_s        [1] <= H_to_s 		  ;
			sw_F_to_s        [1] <= F_to_s 		  ; 
			sw_F2_to_s        [1] <= F2_to_s 		  ; //CJ
			sw_bt_to_s       [0] <= bt_out        ; //because the bt_out is later one clk than H_to_S
			sw_score_write   [1] <= score_write   ;
			sw_max_result    [6] <= max_result 	  ;
			sw_row_max_result[6] <= row_max_result;
			sw_col_max_result[6] <= col_max_result;
			sw_diagonal_score[6] <= diagonal_score;
			sw_start_out     [1] <= start_out 	  ;
			sw_H1_init_in	 [1] <= H1_init_out	  ;
 			sw_H2_init_in	 [1] <= H2_init_out	  ;
 			sw_E1_init_in	 [1] <= E1_init_out	  ;
 			sw_E2_init_in	 [1] <= E2_init_out	  ;
 			sw_col_max_temp_in[1]<= U_col_max_temp_out;
 			sw_col_en        [1] <= col_en_out;
		end // T3:

		T4: begin
			sw_H_to_s        [2] <= H_to_s 		  ;
			sw_F_to_s        [2] <= F_to_s 		  ; 
			sw_F2_to_s        [2] <= F2_to_s 		  ; //CJ
			sw_bt_to_s       [1] <= bt_out        ;
			sw_score_write   [2] <= score_write   ;
			sw_max_result    [0] <= max_result 	  ;
			sw_row_max_result[0] <= row_max_result;
			sw_col_max_result[0] <= col_max_result;
			sw_diagonal_score[0] <= diagonal_score;
			sw_start_out     [2] <= start_out 	  ;
			sw_H1_init_in	 [2] <= H1_init_out	  ;
 			sw_H2_init_in	 [2] <= H2_init_out	  ;
 			sw_E1_init_in	 [2] <= E1_init_out	  ;
 			sw_E2_init_in	 [2] <= E2_init_out	  ;
 			sw_col_max_temp_in[2]<= U_col_max_temp_out;
 			sw_col_en        [2] <= col_en_out;
		end // T3:

		T5: begin
			sw_H_to_s        [3] <= H_to_s 		  ;
			sw_F_to_s        [3] <= F_to_s 		  ; 
			sw_F2_to_s       [3] <= F2_to_s 	  ; //CJ
			sw_bt_to_s       [2] <= bt_out        ;
			sw_score_write   [3] <= score_write   ;
			sw_max_result    [1] <= max_result 	  ;
			sw_row_max_result[1] <= row_max_result;
			sw_col_max_result[1] <= col_max_result;
			sw_diagonal_score[1] <= diagonal_score;
			sw_start_out     [3] <= start_out 	  ;
			sw_H1_init_in	 [3] <= H1_init_out	  ;
 			sw_H2_init_in	 [3] <= H2_init_out	  ;
 			sw_E1_init_in	 [3] <= E1_init_out	  ;
 			sw_E2_init_in	 [3] <= E2_init_out	  ;
 			sw_col_max_temp_in[3]<= U_col_max_temp_out;
 			sw_col_en        [3] <= col_en_out;
		end // T3:

		T6: begin
			sw_H_to_s        [4] <= H_to_s 		  ;
			sw_F_to_s        [4] <= F_to_s 		  ;
			sw_F2_to_s        [4] <= F2_to_s 		  ; //CJ 
			sw_bt_to_s       [3] <= bt_out        ;
			sw_score_write   [4] <= score_write   ;
			sw_max_result    [2] <= max_result 	  ;
			sw_row_max_result[2] <= row_max_result;
			sw_col_max_result[2] <= col_max_result;
			sw_diagonal_score[2] <= diagonal_score;
			sw_start_out     [4] <= start_out 	  ;
			sw_H1_init_in	 [4] <= H1_init_out	  ;
 			sw_H2_init_in	 [4] <= H2_init_out	  ;
 			sw_E1_init_in	 [4] <= E1_init_out	  ;
 			sw_E2_init_in	 [4] <= E2_init_out	  ;
 			sw_col_max_temp_in[4]<= U_col_max_temp_out;
 			sw_col_en        [4] <= col_en_out;
		end // T3:
	endcase // 
end

/*-------------------------------------------------------------------*\
                          result ouput
\*-------------------------------------------------------------------*/
wire [9:0] rd_data_count;


fifo_512x512 u0 (
	.din          (fifo_data_in     ),
	.wr_en        (fifo_write_en    ),
	.rd_en        (result_fifo_rden ),
	.wr_clk       (sys_clk          ),
	.rd_clk       (core_clk         ),
	.dout         (result_fifo_rdat ),
	.wr_data_count(usedw            ),
	.rd_data_count(rd_data_count	),
	.full         (full             ),
	.empty        (result_fifo_empty)
);

assign fifo_almost_full = (usedw > 9'd485);

always @(posedge sys_clk )
begin
	case (shift_reg)
		T0:begin
			fifo_write_en <= sw_result_vld[0];
			fifo_data_in  <= sw_result[0];
		end // T0:

		T1:begin
			fifo_write_en <= sw_result_vld[1];
			fifo_data_in  <= sw_result[1];
		end // T1:

		T2:begin 
			fifo_write_en <= sw_result_vld[2];
			fifo_data_in  <= sw_result[2];
		end // T2:

		T3:begin 
			fifo_write_en <= sw_result_vld[3];
			fifo_data_in  <= sw_result[3];
		end // T2:

		T4:begin 
			fifo_write_en <= sw_result_vld[4];
			fifo_data_in  <= sw_result[4];
		end // T2:

		T5:begin 
			fifo_write_en <= sw_result_vld[5];
			fifo_data_in  <= sw_result[5];
		end // T2:

		T6:begin 
			fifo_write_en <= sw_result_vld[6];
			fifo_data_in  <= sw_result[6];
		end // T2:
	endcase 
end

genvar gen_m;
generate
for (gen_m = 0 ; gen_m < 7 ; gen_m = gen_m + 1) begin:sw_send
sw_send_128 s (
	.sys_clk           (sys_clk                     ),
	.sys_rst_n         (sys_rst_n                   ),
	.core_clk          (core_clk                    ),
	.core_rst_n        (core_rst_n                  ),
	.matrix_memory_sop (sw_matrix_memory_sop[gen_m] ),
	.matrix_memory_eop (sw_matrix_memory_eop[gen_m] ),
	.matrix_memory_vld (sw_matrix_memory_vld[gen_m] ),
	.matrix_memory_data(sw_matrix_memory_data[gen_m]),
	.H_in              (sw_H_to_s[gen_m]            ),
	.F_in              (sw_F_to_s[gen_m]            ),
	.F2_in              (sw_F2_to_s[gen_m]            ),//CJ
	.bt_in              (sw_bt_to_s[gen_m]         	 ), //cj
	.H1_init			(sw_H1_init_in[gen_m]			),
	.H2_init			(sw_H2_init_in[gen_m]			),
	.E1_init			(sw_E1_init_in[gen_m]			),
	.E2_init			(sw_E2_init_in[gen_m]			),
	.vld               (vld[gen_m]                  ),
	.score_write       (sw_score_write[gen_m]       ),
	.max_result        (sw_max_result[gen_m]        ),
	.row_max_result    (sw_row_max_result[gen_m]    ),
	.col_max_result    (sw_col_max_result[gen_m]	),
	.col_max_temp_in   (sw_col_max_temp_in[gen_m]   ),
	.start_out         (sw_start_out[gen_m]         ),
	.col_en_in         (sw_col_en[gen_m] 			),
	.diagonal_score    (sw_diagonal_score[gen_m] 	),
	//output
	.pkt_receive_enable(sw_pkt_receive_enable[gen_m]),
	.start_in          (sw_start_in[gen_m]          ),
	.final_row_en      (sw_final_row_en[gen_m]      ),
	.mode              (sw_mode[gen_m]              ),
	.H_i_j_fifo        (sw_H_to_pu[gen_m]           ),
	.F_i_j_fifo        (sw_F_to_pu[gen_m]           ),
	.F2_i_j_fifo        (sw_F2_to_pu[gen_m]           ),//CJ
	.score_init        (sw_score_init[gen_m]        ),
	.Ns                (sw_Ns[gen_m]                ),
	.Nr                (sw_Nr[gen_m]                ),
	.H1_init_out	   (sw_H1_init_out[gen_m]			),
	.H2_init_out	   (sw_H2_init_out[gen_m]			),
	.E1_init_out	   (sw_E1_init_out[gen_m]			),
	.E2_init_out	   (sw_E2_init_out[gen_m]			),
	.parameter_vld     (sw_parameter_vld[gen_m]     ),
	.col_max_temp_out  (sw_col_max_temp_out[gen_m]		),
	.location          (sw_location[gen_m]          ),
	.pe_cnt            (sw_pe_cnt[gen_m]            ),
	.max_clear         (sw_max_clear[gen_m]         ),
	.result            (sw_result[gen_m] 			),
	.bt_en             (sw_bt_en[gen_m]          ), //CJ
	.result_vld        (sw_result_vld[gen_m]		),
	.fifo_start        (sw_fifo_start[gen_m]        ),
	.fifo_vld          (sw_fifo_vld[gen_m] 			),
	.fifo_empty        (sw_fifo_empty[gen_m]		),
	.fifo_eop          (sw_fifo_eop[gen_m]			),
	.fifo_data         (sw_fifo_data[gen_m]			)		
);
end 
endgenerate

result_collect rc(
	.sys_clk  (core_clk),
	.sys_rst_n(core_rst_n),
	.vld_0  (sw_fifo_vld  	[0])  ,
    .empty_0(sw_fifo_empty	[0]),
    .eop_0  (sw_fifo_eop 	[0])  ,
    .data_0 (sw_fifo_data	[0]) ,
    .vld_1  (sw_fifo_vld 	[1])  ,
    .empty_1(sw_fifo_empty	[1]),
    .eop_1  (sw_fifo_eop 	[1])  ,
    .data_1 (sw_fifo_data	[1]) ,
    .vld_2  (sw_fifo_vld 	[2])  ,
    .empty_2(sw_fifo_empty	[2]),
    .eop_2  (sw_fifo_eop 	[2])  ,
    .data_2 (sw_fifo_data	[2]) ,
    .vld_3  (sw_fifo_vld	[3])  ,
    .empty_3(sw_fifo_empty	[3]),
    .eop_3  (sw_fifo_eop	[3])  ,
    .data_3 (sw_fifo_data	[3]) ,
    .vld_4  (sw_fifo_vld	[4])  ,
    .empty_4(sw_fifo_empty	[4]),
    .eop_4  (sw_fifo_eop	[4])  ,
    .data_4 (sw_fifo_data	[4]) ,
    .vld_5  (sw_fifo_vld	[5])  ,
    .empty_5(sw_fifo_empty	[5]),
    .eop_5  (sw_fifo_eop	[5])  ,
    .data_5 (sw_fifo_data	[5]) ,
    .vld_6  (sw_fifo_vld	[6])  ,
    .empty_6(sw_fifo_empty	[6]),
    .eop_6  (sw_fifo_eop	[6])  ,
    .data_6 (sw_fifo_data	[6]) ,
    
    .start_0(sw_fifo_start	[0]),
    .start_1(sw_fifo_start	[1]),
    .start_2(sw_fifo_start	[2]),
    .start_3(sw_fifo_start	[3]),
    .start_4(sw_fifo_start	[4]),
    .start_5(sw_fifo_start	[5]),
    .start_6(sw_fifo_start	[6]),


    .rd_start (rd_start)		,
    .vld_out  (vld_out)			,
    .empty_out(empty_out) 		,
    .eop_out  (eop_out)			,
    .data_out (data_out)		
);


PU128 p0 (
	.sys_clk                (sys_clk              ),
	.sys_rst_n              (sys_rst_n            ),
	.mode                   (mode                 ),
	.start_in               (start_in             ),
	.final_row_en           (final_row_en         ),
	.Ns                     (Ns                   ),
	.Nr_0                   (Nr_0                 ),
	.Nr_1                   (Nr_1                 ),
	.Nr_2                   (Nr_2                 ),
	.Nr_3                   (Nr_3                 ),
	.Nr_4                   (Nr_4                 ),
	.Nr_5                   (Nr_5                 ),
	.Nr_6                   (Nr_6                 ),
	.Nr_7                   (Nr_7                 ),
	.Nr_8                   (Nr_8                  ),
	.Nr_9                   (Nr_9                  ),
	.Nr_10                  (Nr_10                 ),
	.Nr_11                  (Nr_11                 ),
	.Nr_12                  (Nr_12                 ),
	.Nr_13                  (Nr_13                 ),
	.Nr_14                  (Nr_14                 ),
	.Nr_15                  (Nr_15                 ),

	.Nr_16					(Nr_16				   ), 
	.Nr_17					(Nr_17				   ),
	.Nr_18					(Nr_18				   ),
	.Nr_19					(Nr_19				   ),
	.Nr_20					(Nr_20				   ),
	.Nr_21					(Nr_21				   ),
	.Nr_22					(Nr_22				   ),
	.Nr_23					(Nr_23				   ),
	.Nr_24					(Nr_24				   ),
	.Nr_25					(Nr_25				   ),
	.Nr_26					(Nr_26				   ),
	.Nr_27					(Nr_27				   ),
	.Nr_28					(Nr_28				   ),
	.Nr_29					(Nr_29				   ),
	.Nr_30					(Nr_30				   ),
	.Nr_31					(Nr_31				   ),

	.Nr_32					(Nr_32				   ),
    .Nr_33					(Nr_33				   ),
    .Nr_34					(Nr_34				   ),
    .Nr_35					(Nr_35				   ),
    .Nr_36					(Nr_36				   ),
    .Nr_37					(Nr_37				   ),
    .Nr_38					(Nr_38				   ),
    .Nr_39					(Nr_39				   ),
    .Nr_40					(Nr_40				   ),
    .Nr_41					(Nr_41				   ),
    .Nr_42					(Nr_42				   ),
    .Nr_43					(Nr_43				   ),
    .Nr_44					(Nr_44				   ),
    .Nr_45					(Nr_45				   ),
    .Nr_46					(Nr_46				   ),
    .Nr_47					(Nr_47				   ),
    .Nr_48					(Nr_48				   ),
    .Nr_49					(Nr_49				   ),
    .Nr_50					(Nr_50				   ),
    .Nr_51					(Nr_51				   ),
    .Nr_52					(Nr_52				   ),
    .Nr_53					(Nr_53				   ),
    .Nr_54					(Nr_54				   ),
    .Nr_55					(Nr_55				   ),
    .Nr_56					(Nr_56				   ),
    .Nr_57					(Nr_57				   ),
    .Nr_58					(Nr_58				   ),
    .Nr_59					(Nr_59				   ),
    .Nr_60					(Nr_60				   ),
    .Nr_61					(Nr_61				   ),
    .Nr_62					(Nr_62				   ),
    .Nr_63					(Nr_63				   ),

	.Nr_64					(Nr_64					),
	.Nr_65					(Nr_65					),
	.Nr_66					(Nr_66					),
	.Nr_67					(Nr_67					),
	.Nr_68					(Nr_68					),
	.Nr_69					(Nr_69					),
	.Nr_70					(Nr_70					),
	.Nr_71					(Nr_71					),
	.Nr_72					(Nr_72					),
	.Nr_73					(Nr_73					),
	.Nr_74					(Nr_74					),
	.Nr_75					(Nr_75					),
	.Nr_76					(Nr_76					),
	.Nr_77					(Nr_77					),
	.Nr_78					(Nr_78					),
	.Nr_79					(Nr_79					),
	.Nr_80					(Nr_80					),
	.Nr_81					(Nr_81					),
	.Nr_82					(Nr_82					),
	.Nr_83					(Nr_83					),
	.Nr_84					(Nr_84					),
	.Nr_85					(Nr_85					),
	.Nr_86					(Nr_86					),
	.Nr_87					(Nr_87					),
	.Nr_88					(Nr_88					),
	.Nr_89					(Nr_89					),
	.Nr_90					(Nr_90					),
	.Nr_91					(Nr_91					),
	.Nr_92					(Nr_92					),
	.Nr_93					(Nr_93					),
	.Nr_94					(Nr_94					),
	.Nr_95					(Nr_95					),
	.Nr_96					(Nr_96					),
	.Nr_97					(Nr_97					),
	.Nr_98					(Nr_98					),
	.Nr_99					(Nr_99					),
	.Nr_100					(Nr_100					),
	.Nr_101					(Nr_101					),
	.Nr_102					(Nr_102					),
	.Nr_103					(Nr_103					),
	.Nr_104					(Nr_104					),
	.Nr_105					(Nr_105					),
	.Nr_106					(Nr_106					),
	.Nr_107					(Nr_107					),
	.Nr_108					(Nr_108					),
	.Nr_109					(Nr_109					),
	.Nr_110					(Nr_110					),
	.Nr_111					(Nr_111					),
	.Nr_112					(Nr_112					),
	.Nr_113					(Nr_113					),
	.Nr_114					(Nr_114					),
	.Nr_115					(Nr_115					),
	.Nr_116					(Nr_116					),
	.Nr_117					(Nr_117					),
	.Nr_118					(Nr_118					),
	.Nr_119					(Nr_119					),
	.Nr_120					(Nr_120					),
	.Nr_121					(Nr_121					),
	.Nr_122					(Nr_122					),
	.Nr_123					(Nr_123					),
	.Nr_124					(Nr_124					),
	.Nr_125					(Nr_125					),
	.Nr_126					(Nr_126					),
	.Nr_127					(Nr_127					),



	.H1_init				(H1_init			  ),
	.H2_init				(H2_init			  ),
	.E1_init				(E1_init			  ),
	.E2_init				(E2_init			  ),
	.location_in_0          (location_0           ),
	.location_in_1          (location_1           ),
	.location_in_2          (location_2           ),
	.location_in_3          (location_3           ),
	.location_in_4          (location_4           ),
	.location_in_5          (location_5           ),
	.location_in_6          (location_6           ),
	.location_in_7          (location_7           ),
	.location_in_8          (location_8           ),
	.location_in_9          (location_9           ),
	.location_in_10         (location_10          ),
	.location_in_11         (location_11          ),
	.location_in_12         (location_12          ),
	.location_in_13         (location_13          ),
	.location_in_14         (location_14          ),
	.location_in_15         (location_15          ),

	.location_in_16			(location_16		  ),
	.location_in_17			(location_17		  ),
	.location_in_18			(location_18		  ),
	.location_in_19			(location_19		  ),
	.location_in_20			(location_20		  ),
	.location_in_21			(location_21		  ),
	.location_in_22			(location_22		  ),
	.location_in_23			(location_23		  ),
	.location_in_24			(location_24		  ),
	.location_in_25			(location_25		  ),
	.location_in_26			(location_26		  ),
	.location_in_27			(location_27		  ),
	.location_in_28			(location_28		  ),
	.location_in_29			(location_29		  ),
	.location_in_30			(location_30		  ),
	.location_in_31			(location_31		  ),

	.location_in_32			(location_32          ),
    .location_in_33			(location_33		  ),
    .location_in_34			(location_34		  ),
    .location_in_35			(location_35		  ),
    .location_in_36			(location_36		  ),
    .location_in_37			(location_37		  ),
    .location_in_38			(location_38		  ),
    .location_in_39			(location_39		  ),
    .location_in_40			(location_40		  ),
    .location_in_41			(location_41		  ),
    .location_in_42			(location_42		  ),
    .location_in_43			(location_43		  ),
    .location_in_44			(location_44		  ),
    .location_in_45			(location_45		  ),
    .location_in_46			(location_46		  ),
    .location_in_47			(location_47		  ),
    .location_in_48			(location_48		  ),
    .location_in_49			(location_49		  ),
    .location_in_50			(location_50		  ),
    .location_in_51			(location_51		  ),
    .location_in_52			(location_52		  ),
    .location_in_53			(location_53		  ),
    .location_in_54			(location_54		  ),
    .location_in_55			(location_55		  ),
    .location_in_56			(location_56		  ),
    .location_in_57			(location_57		  ),
    .location_in_58			(location_58		  ),
    .location_in_59			(location_59		  ),
    .location_in_60			(location_60		  ),
    .location_in_61			(location_61		  ),
    .location_in_62			(location_62		  ),
    .location_in_63			(location_63		  ),

    .location_in_64			(location_64			),
	.location_in_65			(location_65			),
	.location_in_66			(location_66			),
	.location_in_67			(location_67			),
	.location_in_68			(location_68			),
	.location_in_69			(location_69			),
	.location_in_70			(location_70			),
	.location_in_71			(location_71			),
	.location_in_72			(location_72			),
	.location_in_73			(location_73			),
	.location_in_74			(location_74			),
	.location_in_75			(location_75			),
	.location_in_76			(location_76			),
	.location_in_77			(location_77			),
	.location_in_78			(location_78			),
	.location_in_79			(location_79			),
	.location_in_80			(location_80			),
	.location_in_81			(location_81			),
	.location_in_82			(location_82			),
	.location_in_83			(location_83			),
	.location_in_84			(location_84			),
	.location_in_85			(location_85			),
	.location_in_86			(location_86			),
	.location_in_87			(location_87			),
	.location_in_88			(location_88			),
	.location_in_89			(location_89			),
	.location_in_90			(location_90			),
	.location_in_91			(location_91			),
	.location_in_92			(location_92			),
	.location_in_93			(location_93			),
	.location_in_94			(location_94			),
	.location_in_95			(location_95			),
	.location_in_96			(location_96			),
	.location_in_97			(location_97			),
	.location_in_98			(location_98			),
	.location_in_99			(location_99			),
	.location_in_100		(location_100			),
	.location_in_101		(location_101			),
	.location_in_102		(location_102			),
	.location_in_103		(location_103			),
	.location_in_104		(location_104			),
	.location_in_105		(location_105			),
	.location_in_106		(location_106			),
	.location_in_107		(location_107			),
	.location_in_108		(location_108			),
	.location_in_109		(location_109			),
	.location_in_110		(location_110			),
	.location_in_111		(location_111			),
	.location_in_112		(location_112			),
	.location_in_113		(location_113			),
	.location_in_114		(location_114			),
	.location_in_115		(location_115			),
	.location_in_116		(location_116			),
	.location_in_117		(location_117			),
	.location_in_118		(location_118			),
	.location_in_119		(location_119			),
	.location_in_120		(location_120			),
	.location_in_121		(location_121			),
	.location_in_122		(location_122			),
	.location_in_123		(location_123			),
	.location_in_124		(location_124			),
	.location_in_125		(location_125			),
	.location_in_126		(location_126			),
	.location_in_127		(location_127			),


	.Score_init             (score_init           ),
	.H_i_j_fifo             (H_to_pu              ),
	.F_i_j_fifo             (F_to_pu              ),
	.F2_i_j_fifo            (F2_to_pu              ), //CJ
	.bt_en                  (bt_en                ),//CJ
	.col_max_in             (U_col_max_temp_in      ),
	// .clear                  (max_clear            ),
	//output
	.start_out              (start_out            ),
	.H_i_j_out              (H_to_s               ),
	.F_i_j_out              (F_to_s               ),
	.F2_i_j_out             (F2_to_s               ),//CJ
	.col_max_out 			(U_col_max_temp_out  		  ),
	.Score_out              (score_write          ),
	.col_en 				(col_en_out 			  ), //CJ
	.H1_init_out	   	    (H1_init_out			),
	.H2_init_out	   	    (H2_init_out			),
	.E1_init_out	   	    (E1_init_out			),
	.E2_init_out	   	    (E2_init_out			),
	.bt_out 	            (bt_out                 ),
//	.bt_out0				(bt_out0				),
	.H_max_out              (max_result[47:32]    ),
	.H_max_location         (max_result[31: 0]     ),
	.H_row_max_last         (row_max_result[47:32]),
	.H_row_max_last_location(row_max_result[31: 0] ),
	.H_col_max				(col_max_result[47:32]),
	.H_col_max_location		(col_max_result[31: 0] ),
	.diagonal_score     	(diagonal_score 	   )
);

endmodule
