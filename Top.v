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
    wire [7:0] ave_temp;            //Used with BRAM controller
    wire [7:0] max_temp;
    wire [7:0] min_temp;
    
//Commented out to test Nakul's code
/* 
    // Instantiate i2c master
    i2c_master i2cmaster(
        .clk_200KHz(w_200KHz),
        .temp_data(c_data),
        .SDA(TMP_SDA),
        .SCL(TMP_SCL)
    );
*/    

temperature_sensor_interface i2cmaster(
        .clk_200KHz(w_200KHz),
        .sensor_data(TMP_SDA),
        .temperature_output(c_data),
        .sensor_clock(TMP_SCL)
    );
    // Instantiate 200kHz clock generator. Used in the i2cmaster above. 
    clkgen_200KHz clkgen(
        .clk_100MHz(CLK100MHZ),
        .clk_200KHz(w_200KHz)
    );
    
    // Displays temp values on 7 segment display. 
    seg7c segcontrol(
        .clk_100MHz(CLK100MHZ),
        //.c_data(c_data),
        .display_data(display_data),
        .f_data(f_data),
        .SEG(SEG),
        .AN(AN)
    );
    
    tempConverter tempconv(
        .c(c_data),
        .f(f_data)
    );
 
    setTemperature set(
      .selectionSW(selectionSW),
      .CLK100MHZ(CLK100MHZ),
      .c_data(f_data),
      .display_reg(display_data)
    );
    // Set LED values for temperature data

    BRAM_TemperatureValues bram_inst( 
    .clka(CLK100MHZ), // Connect to your clock signal 
    .ena(1'b1), // Enable signal, always enabled in this case 
    .wea(bram_we), // Write enable signal 
    .addra(bram_addr), // Address for read/write operations 
    .dina(bram_data_in), // Data input for write operations 
    .douta(bram_data_out) // Data output for read operations 
    );
    
    assign LED[15:8] = f_data;
    assign LED[7:0] = display_data;
    //assign LED[7:0]  = c_data;
endmodule
