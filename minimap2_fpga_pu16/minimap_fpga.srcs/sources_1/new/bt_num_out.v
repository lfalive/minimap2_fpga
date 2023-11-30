module bt_num_out(
	sys_clk,
	sys_rst_n,
	read_len,
	hap_len,
	bt_num);
input wire sys_clk;
input wire sys_rst_n;
input wire [7:0] read_len;
input wire [15:0] hap_len;
output reg [31:0] bt_num;

always @ (posedge sys_clk or negedge sys_rst_n) begin
	if (~sys_rst_n)
		bt_num <= 'd0;
	else
		bt_num <= ((read_len-1) >> 3)*hap_len;
end

endmodule