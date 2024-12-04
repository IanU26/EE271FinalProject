`timescale 1ns / 1ps
//Takes a 16-bit value and divides by 5.
//Input is 16-bit because of the multiplication done in 'multiply_by_9 module
module divide_by_5(
    input [15:0] x,
    output reg [7:0] y
    );
    
    always @(*) begin
        y = x / 5;
    end
    
endmodule
