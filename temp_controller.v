`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2024 10:57:04 AM
// Design Name: 
// Module Name: temp_controller
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


module temp_controller(
    input clk,
    input[7:0] current_temp,
    input [7:0] set_temp,
    output reg red,
    output reg blue
    );
    
    always@(clk)begin
        red <= (current_temp < set_temp) ? 1'b1 : 1'b0;
        blue <= (current_temp > set_temp) ? 1'b1 : 1'b0; 
    end
endmodule
