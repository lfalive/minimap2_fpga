import sys

def PU64_out():
	PE_NUM = 128
	PE_BEGIN = 64
	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('Nr_%d   ,' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	#  	print('location_in_%d,' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('input wire [DATA_WIDTH-1: 0] Nr_%d ; ' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('input wire [LOCATION_WIDTH-1:0] location_in_%d ; ' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('assign PE_Nr[%d] = Nr_%d;' %(i,i))


	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('assign PE_location_in[%d] = location_in_%d;' %(i,i))

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('bt_out <= PE_bt_out_reg[%d];' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('H_col_max <= COL_H_max[%d];' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('H_col_max_location <= COL_location_out[%d];' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('H_row_max_last_reg <= PE_H_row_max[%d];' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('H_row_max_last_location_reg <= PE_location_row_out[%d];' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('H_max_out <= CMP_H_max_out[%d];' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('H_max_location <= CMP_location_out[%d];' % i)

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('diagonal_score <= PE_H_out_col[%d];' % i)

	# for i in range(PE_BEGIN, PE_NUM):
	# 	print('reg [RH_BANDWIDTH-1:0] Nr_%d 		;' % i)
	# 	print('reg [			23:0] location_%d   ;' % i)

	# for i in range(PE_BEGIN, PE_NUM):
	# 	print('reg [RH_BANDWIDTH-1:0] sw_Nr_%d 		 [6:0];' % i)
	# 	print('reg [			 23:0] sw_location_%d    [6:0];' % i)

	# for i in range(PE_BEGIN, PE_NUM):
	# 	print('sw_Nr_%d[gen_k] <= 4\'b0     ;' % i )

	# for i in range(PE_BEGIN, PE_NUM):
	# 	print('sw_Nr_%d[gen_k] <= sw_Nr[gen_k];' % i )








	# for i in range(0, PE_NUM):
	# 	print('reg [RH_BANDWIDTH-1:0] Nr_%d 		;' % i)
	# 	print('reg [LOCATION_WIDTH-1:0] location_%d   ;' % i)

	# for i in range(0, PE_NUM):
	# 	print('reg [RH_BANDWIDTH-1:0] sw_Nr_%d 		 [6:0];' % i)
	# 	print('reg [LOCATION_WIDTH-1:0] sw_location_%d    [6:0];' % i)

	for i in range(0, PE_NUM):
		print('\talways @(posedge sys_clk or negedge sys_rst_n)\n\tbegin')
		print('\t\tif (!sys_rst_n) begin')
		print('\t\t\tsw_location_%d[gen_k] <= 32\'d0;' % i)
		print('\t\tend else if (sw_parameter_vld[gen_k] && sw_pe_cnt[gen_k] == \'d%d) begin' % i)
		print('\t\t\tsw_location_%d[gen_k] <= sw_location[gen_k];' % i)
		print('\t\tend else if (sw_parameter_vld[gen_k]) begin')
		print('\t\t\tsw_location_%d[gen_k][31:16] <= sw_location_%d[gen_k][31:16] + 1\'b1;' % (i, i))
		print('\t\tend\n\tend')

	# for i in range(PE_BEGIN, PE_NUM):
	# 	print('Nr_%d      <= sw_Nr_%d[6]     ;' %(i,i))

	# for i in range(PE_BEGIN, PE_NUM):
	# 	print('location_%d      <= sw_location_%d[6]     ;' %(i,i))

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('.Nr_%d\t\t\t\t\t(Nr_%d\t\t\t\t\t),' % (i, i))

	# for i in range(PE_BEGIN,PE_NUM):
	# 	print('.location_in_%d\t\t\t(location_%d\t\t\t),' % (i, i))
PU64_out()
