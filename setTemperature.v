`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//This module can be used to display the desired temperature on the right of the seven segment display. 
//The output of this module should take the place of 'c_data' in the top module.
//////////////////////////////////////////////////////////////////////////////////


module setTemperature(
    input [1:0]   selectionSW,   // Used to select which output to display. Bind to switches
    input         CLK100MHZ,        // nexys clk signal
    input [7:0] c_data,             // Temp data from i2c master
    output reg[7:0] display_reg               // nexys leds = binary temp in deg F, 15-8 (set temp) 7-0 (current temp)
    );
    //reg [7:0] display_reg;
    
    always@(posedge CLK100MHZ)begin
        case(selectionSW)
            2'b00: begin
                display_reg <= 2'b00;
            end
            2'b01: begin
                display_reg <= 2'b00;
            end
            2'b10: begin
                display_reg <= 2'b00;
            end
            2'b11: begin
                display_reg <= c_data;
            end
        endcase
       
    
    end
    //assign Display = display_reg;
endmodule
