module MUX5to32
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

input wire [4:0] code_in;

output reg [31:0] en_out;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        en_out <= 8'b0;
    end 
    else begin
        case (code_in)
        5'b00000 : en_out <= 32'b00000000_00000000_00000000_00000001;
        5'b00001 : en_out <= 32'b00000000_00000000_00000000_00000011;
        5'b00010 : en_out <= 32'b00000000_00000000_00000000_00000111;
        5'b00011 : en_out <= 32'b00000000_00000000_00000000_00001111;
        5'b00100 : en_out <= 32'b00000000_00000000_00000000_00011111;
        5'b00101 : en_out <= 32'b00000000_00000000_00000000_00111111;
        5'b00110 : en_out <= 32'b00000000_00000000_00000000_01111111;
        5'b00111 : en_out <= 32'b00000000_00000000_00000000_11111111;
        5'b01000 : en_out <= 32'b00000000_00000000_00000001_11111111;
        5'b01001 : en_out <= 32'b00000000_00000000_00000011_11111111;
        5'b01010 : en_out <= 32'b00000000_00000000_00000111_11111111;
        5'b01011 : en_out <= 32'b00000000_00000000_00001111_11111111;
        5'b01100 : en_out <= 32'b00000000_00000000_00011111_11111111;
        5'b01101 : en_out <= 32'b00000000_00000000_00111111_11111111;
        5'b01110 : en_out <= 32'b00000000_00000000_01111111_11111111;
        5'b01111 : en_out <= 32'b00000000_00000000_11111111_11111111;

        5'b10000 : en_out <= 32'b00000000_00000001_11111111_11111111;
        5'b10001 : en_out <= 32'b00000000_00000011_11111111_11111111;
        5'b10010 : en_out <= 32'b00000000_00000111_11111111_11111111;
        5'b10011 : en_out <= 32'b00000000_00001111_11111111_11111111;
        5'b10100 : en_out <= 32'b00000000_00011111_11111111_11111111;
        5'b10101 : en_out <= 32'b00000000_00111111_11111111_11111111;
        5'b10110 : en_out <= 32'b00000000_01111111_11111111_11111111;
        5'b10111 : en_out <= 32'b00000000_11111111_11111111_11111111;
        5'b11000 : en_out <= 32'b00000001_11111111_11111111_11111111;
        5'b11001 : en_out <= 32'b00000011_11111111_11111111_11111111;
        5'b11010 : en_out <= 32'b00000111_11111111_11111111_11111111;
        5'b11011 : en_out <= 32'b00001111_11111111_11111111_11111111;
        5'b11100 : en_out <= 32'b00011111_11111111_11111111_11111111;
        5'b11101 : en_out <= 32'b00111111_11111111_11111111_11111111;
        5'b11110 : en_out <= 32'b01111111_11111111_11111111_11111111;
        5'b11111 : en_out <= 32'b11111111_11111111_11111111_11111111;

        endcase
    end
end

endmodule