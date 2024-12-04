`timescale 1ns / 1ps
//This module takes in the 100MHz clock present on the Nexys and outputs a 200KHz clock 
module clkgen_200KHz(
    input clk_100MHz,
    output clk_200KHz
    );
    
    //We iterate the counter every posedge of clk.
    //Every 250 posedges we reset counter and invert output clk.
    //clk_200KHz = clk_100MHz / 2 / 250
    reg [7:0] counter = 8'h00;
    reg clk_reg = 1'b1;
    
    always @(posedge clk_100MHz) begin
        if(counter == 249) begin
            counter <= 8'h00;
            clk_reg <= ~clk_reg;
        end
        else
            counter <= counter + 1;
    end
    
    assign clk_200KHz = clk_reg;
    
endmodule