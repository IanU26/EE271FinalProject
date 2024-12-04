`timescale 1ns / 1ps
//This module converts celcius to fahrenheit. F = 9/5*C+32
module temp_converter(
    input [7:0] c,
    output [7:0] f
    );
    
    wire [15:0] p;
    wire [7:0] q;
    
    multiply_by_9 MULT9(.x(c), .y(p));
    divide_by_5 DIV5(.x(p), .y(q));
    add_32 ADD32(.x(q), .y(f));
    
endmodule