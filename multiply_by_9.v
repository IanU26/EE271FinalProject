`timescale 1ns / 1ps
//Takes an 8 bit input and multiplies by 9
module multiply_by_9(
    input [7:0] x,
    output reg [15:0] y
    );
    
    always @(*) begin
        y = x * 9;
    end
endmodule