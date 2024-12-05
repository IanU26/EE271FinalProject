`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 10:11:15 PM
// Design Name: 
// Module Name: BRAM_Controller
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

module BRAM_Controller ( 
    input wire clk,     //Nexys A7 clock
    input wire rst,     //Reset signal for min/max/average
    input wire [7:0] new_temp, 
    input wire new_temp_valid, 
    output reg [7:0] avg_temp, 
    output reg [7:0] max_temp, 
    output reg [7:0] min_temp 
    ); 
    
 // BRAM instance 
    reg [7:0] bram_data_in; 
    wire [7:0] bram_data_out; 
    reg [3:0] bram_addr; 
    reg bram_we; 
    BRAM_TemperatureValues bram_inst ( 
        .clka(clk), 
        .ena(1'b1), 
        .wea(bram_we), 
        .addra(bram_addr), 
        .dina(bram_data_in), 
        .douta(bram_data_out) 
    ); 
    
    
    
    //Attempt at slower clock. 1Hz. Did not work when implemented in the always block below.
    reg [7:0] counter = 26'h00;
    reg clk_reg = 1'b1;
    
    always @(posedge clk) begin
        if(counter == 27'd99999999) begin
            counter <= 27'd0;
            clk_reg <= ~clk_reg;
        end
        else
            counter <= counter + 1;
    end
    
    
    
// Control logic 
reg [3:0] write_pointer; 
reg [7:0] temp_sum; 
integer i; 


always @(posedge clk or posedge rst) begin 
    if (rst) begin 
        write_pointer <= 4'd0; 
        bram_addr <= 4'd0; 
        bram_we <= 1'b0; 
        avg_temp <= 8'd0; 
        max_temp <= 8'd255; 
        min_temp <= 8'd0; 
        temp_sum <= 8'd0; 
    end 
    else if (new_temp_valid) begin 
        // Store new temperature 
        bram_addr <= write_pointer; 
        bram_data_in <= new_temp; 
        bram_we <= 1'b1; 
        write_pointer <= (write_pointer == 4'd9) ? 4'd0 : write_pointer + 1'd1; 
        // Calculate new average, max, and min 
        temp_sum <= 8'd0; 
        max_temp <= 8'd0; 
        min_temp <= 8'd255; 
        for (i = 0; i < 10; i = i + 1) begin 
        bram_addr <= i; 
        bram_we <= 1'b0; 
        #1; 
        // Wait for BRAM read 
        temp_sum <= temp_sum + bram_data_out; 
        if (bram_data_out > max_temp) 
            max_temp <= bram_data_out; 
        if (bram_data_out < min_temp) 
            min_temp <= bram_data_out;    
        end 
        avg_temp <= temp_sum / 8'd10; 
    
    end 
    
    else begin 
        bram_we <= 1'b0; 
    end 
end 
endmodule
