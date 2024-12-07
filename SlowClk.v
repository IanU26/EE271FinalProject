`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 05:17:47 PM
// Design Name: 
// Module Name: SlowClk
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

`timescale 1ns / 1ps
//This module takes in the 100MHz clock present on the Nexys and outputs a 200KHz clock 
module clkgen_1Hz(
    input clk_100MHz,
    output clk_1Hz
    );
    
    //We iterate the counter every posedge of clk.
    //Every 250 posedges we reset counter and invert output clk.
    //clk_200KHz = clk_100MHz / 2 / 250
    reg [26:0] counter = 27'd0;
    reg clk_reg = 1'b1;
    
    always @(posedge clk_100MHz) begin
        if(counter == 45000000) begin
            counter <= 27'd0;
            clk_reg <= ~clk_reg;
        end
        else
            counter <= counter + 1;
    end
    
    assign clk_1Hz = clk_reg;
    
endmodule