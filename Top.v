`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Team: Ian Ulrich, Maokun Wang, Yatish Chandra, Nakul Raghav
// Module Name: top
// Project Name: Thermometer
// Target Devices: Nexys A7-100T
// Tool Versions: Vivado 2021.2
// Description: Temperature controller with ADT7420 temp sensor aboard Nexys A7
//              - temperature read out on 8 LEDs and 7 Segment Displays
//              - desired temperature setting
//              - 
//////////////////////////////////////////////////////////////////////////////////
module top(
    input         selection,
    input [1:0]   selectionSW,      //Used to select the displayed temp
    input         CLK100MHZ,        // nexys clk signal
    inout         TMP_SDA,          // i2c sda on temp sensor - bidirectional
    output        TMP_SCL,          // i2c scl on temp sensor
    output [6:0]  SEG,              // 7 segments of each display
    output [7:0]  AN,               // 8 anodes of 8 displays
    output [15:0] LED               // nexys leds = binary temp in deg F, 15-8 (set temp) 7-0 (current temp)
    );
    
    wire w_200KHz;                  // 200kHz SCL
    wire [7:0] c_data;              // 8 bits of Celsius temperature data
    wire [7:0] f_data;              // 8 bits of Fahrenheit temperature data
    wire [7:0] display_data;        // 8 bits of display temp (set temp/average temp/etc)

    // Instantiate i2c master
    i2c_master i2cmaster(
        .clk_200KHz(w_200KHz),
        .temp_data(c_data),
        .SDA(TMP_SDA),
        .SCL(TMP_SCL)
    );
    
    // Instantiate 200kHz clock generator
    clkgen_200KHz clkgen(
        .clk_100MHz(CLK100MHZ),
        .clk_200KHz(w_200KHz)
    );
    
    seg7c segcontrol(
        .clk_100MHz(CLK100MHZ),
        //.c_data(c_data),
        .c_data(display_data),
        .f_data(f_data),
        .SEG(SEG),
        .AN(AN)
    );
    
    temp_converter tempconv(
        .c(c_data),
        .f(f_data)
    );
 
    setTemperature set(
      .selectionSW(selectionSW),
      .CLK100MHZ(CLK100MHZ),
      .c_data(c_data),
      .Display(display_data)
    );
    // Set LED values for temperature data

    assign LED[15:8] = f_data;
    assign LED[7:0] = display_data;
    //assign LED[7:0]  = c_data;
endmodule