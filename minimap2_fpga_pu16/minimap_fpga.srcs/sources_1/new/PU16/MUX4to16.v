module MUX4to16
(
    //==========input===============//
    clk     ,
    rst_n   ,
    code_in ,
    //==========output===============//
    en_out
    );

input wire clk;
input wire rst_n;

input wire [3:0] code_in;

output reg [15:0] en_out;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        en_out <= 8'b0;
    end 
    else begin
        case (code_in)
        4'b0000 : en_out <= 16'b00000000_00000001;
        4'b0001 : en_out <= 16'b00000000_00000011;
        4'b0010 : en_out <= 16'b00000000_00000111;
        4'b0011 : en_out <= 16'b00000000_00001111;
        4'b0100 : en_out <= 16'b00000000_00011111;
        4'b0101 : en_out <= 16'b00000000_00111111;
        4'b0110 : en_out <= 16'b00000000_01111111;
        4'b0111 : en_out <= 16'b00000000_11111111;
        4'b1000 : en_out <= 16'b00000001_11111111;
        4'b1001 : en_out <= 16'b00000011_11111111;
        4'b1010 : en_out <= 16'b00000111_11111111;
        4'b1011 : en_out <= 16'b00001111_11111111;
        4'b1100 : en_out <= 16'b00011111_11111111;
        4'b1101 : en_out <= 16'b00111111_11111111;
        4'b1110 : en_out <= 16'b01111111_11111111;
        4'b1111 : en_out <= 16'b11111111_11111111;
        endcase
    end
end

endmodule