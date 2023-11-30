/*`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.12.2020 16:16:01
// Design Name: 
// Module Name: test_btRAM
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


module test_btRAM(

    );
   
reg sys_clk;
reg rd_en, ram_en;
reg [10:0] addra;
reg [63:0] ram_data_in;

wire [63:0] ram_bt_out;

initial begin
    sys_clk = 'b0;
    rd_en = 'b0;
    ram_en = 'b0;
    addra = 0;
end

initial begin

    @ (posedge sys_clk)
        ram_en = 1'b1;
    @ (posedge sys_clk)  
        ram_en = 1'b0;

end


always #5 sys_clk = ~sys_clk;


BT_RAM bt_ram(
  .clka(sys_clk),
  .ena(rd_en),
  .wea(ram_en),
  .addra(addra),
  .dina(ram_data_in),
  .douta(ram_bt_out)
);

endmodule
*/