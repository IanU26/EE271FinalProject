`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2024 08:31:00 PM
// Design Name: 
// Module Name: tempConverter
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


module tempConverter(
    input [7:0] c,
    output reg[7:0] f
    );
    
    reg [15:0] a;
    reg [7:0] b,d;
    
    always@(*)begin
        a = c * 9;
        b = a / 5;
        f = b + 32;
    end
    
endmodule
