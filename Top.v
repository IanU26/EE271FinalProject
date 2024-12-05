`timescale 1ns / 1ps
//  This module performs the i2c communication that will be used to transmit temperature data
//  from the on-board temperature sensor.
//  i2c is a master-slave serial communication protocol that utilizes 
//  
//  INPUTS: Global clock, bi-directional SDATA 
//  OUTPUTS: Decoded temperature data, SClock
//
//
//

module temperature_sensor_interface(
    input clk_200KHz,
    inout sensor_data,
    output [7:0] temperature_output,
    output sensor_clock
);

wire data_line_direction;
// Clock Generation Logic
reg [3:0] clock_divider = 4'b0;
reg clock_signal = 1'b1;

// SCL Clock Assignment
assign sensor_clock = clock_signal;

// Signal Declarations
parameter [7:0] device_identifier = 8'b1001_0111;
reg [7:0] temperature_msb = 8'b0;
reg [7:0] temperature_lsb = 8'b0;
reg output_bit = 1'b1;
reg [11:0] cycle_counter = 12'b0;
reg [7:0] temperature_buffer;

// Enhanced State Declarations
localparam [4:0] INITIALIZATION = 5'h00,
TRANSMISSION_START = 5'h01,
ADDRESS_TRANSMISSION_6 = 5'h02,
ADDRESS_TRANSMISSION_5 = 5'h03,
ADDRESS_TRANSMISSION_4 = 5'h04,
ADDRESS_TRANSMISSION_3 = 5'h05,
ADDRESS_TRANSMISSION_2 = 5'h06,
ADDRESS_TRANSMISSION_1 = 5'h07,
ADDRESS_TRANSMISSION_0 = 5'h08,
READ_WRITE_MODE = 5'h09,
ACKNOWLEDGMENT_RECEPTION = 5'h0A,
MSB_RECEPTION_7 = 5'h0B,
MSB_RECEPTION_6 = 5'h0C,
MSB_RECEPTION_5 = 5'h0D,
MSB_RECEPTION_4 = 5'h0E,
MSB_RECEPTION_3 = 5'h0F,
MSB_RECEPTION_2 = 5'h10,
MSB_RECEPTION_1 = 5'h11,
MSB_RECEPTION_0 = 5'h12,
ACKNOWLEDGMENT_TRANSMISSION = 5'h13,
LSB_RECEPTION_7 = 5'h14,
LSB_RECEPTION_6 = 5'h15,
LSB_RECEPTION_5 = 5'h16,
LSB_RECEPTION_4 = 5'h17,
LSB_RECEPTION_3 = 5'h18,
LSB_RECEPTION_2 = 5'h19,
LSB_RECEPTION_1 = 5'h1A,
LSB_RECEPTION_0 = 5'h1B,
NO_ACKNOWLEDGMENT = 5'h1C;

reg [4:0] current_state = INITIALIZATION;

always @(posedge clk_200KHz) begin
    // Clock Divider Logic
    if(clock_divider == 9) begin
        clock_divider <= 4'b0;
        clock_signal <= ~clock_signal;
    end
    else
        clock_divider <= clock_divider + 1;
        cycle_counter <= cycle_counter + 1;
        
        
        // State Transition Logic
        case(current_state)
        
        INITIALIZATION: begin
            if(cycle_counter == 12'd1999)
            current_state <= TRANSMISSION_START;
        end
        
        TRANSMISSION_START: begin
            if(cycle_counter == 12'd2004)
            output_bit <= 1'b0;
            if(cycle_counter == 12'd2013)
            current_state <= ADDRESS_TRANSMISSION_6;
        end
        
        ADDRESS_TRANSMISSION_6: begin
            output_bit <= device_identifier[7];
            if(cycle_counter == 12'd2033)
            current_state <= ADDRESS_TRANSMISSION_5;
        end
        
        ADDRESS_TRANSMISSION_5: begin
            output_bit <= device_identifier[6];
            if(cycle_counter == 12'd2053)
            current_state <= ADDRESS_TRANSMISSION_4;
        end
        
        ADDRESS_TRANSMISSION_4: begin
            output_bit <= device_identifier[5];
            if(cycle_counter == 12'd2073)
            current_state <= ADDRESS_TRANSMISSION_3;
        end
        
        ADDRESS_TRANSMISSION_3: begin
            output_bit <= device_identifier[4];
            if(cycle_counter == 12'd2093)
            current_state <= ADDRESS_TRANSMISSION_2;
        end
        
        ADDRESS_TRANSMISSION_2: begin
            output_bit <= device_identifier[3];
            if(cycle_counter == 12'd2113)
            current_state <= ADDRESS_TRANSMISSION_1;
        end
        
        ADDRESS_TRANSMISSION_1: begin
            output_bit <= device_identifier[2];
            if(cycle_counter == 12'd2133)
            current_state <= ADDRESS_TRANSMISSION_0;
        end
        
        ADDRESS_TRANSMISSION_0: begin
            output_bit <= device_identifier[1];
            if(cycle_counter == 12'd2153)
            current_state <= READ_WRITE_MODE;
        end
        
        READ_WRITE_MODE: begin
            output_bit <= device_identifier[0];
            if(cycle_counter == 12'd2169)
            current_state <= ACKNOWLEDGMENT_RECEPTION;
        end
        
        ACKNOWLEDGMENT_RECEPTION: begin
            if(cycle_counter == 12'd2189)
            current_state <= MSB_RECEPTION_7;
        end
        
        MSB_RECEPTION_7: begin
            temperature_msb[7] <= input_bit;
            if(cycle_counter == 12'd2209)
            current_state <= MSB_RECEPTION_6;
        end
        
        MSB_RECEPTION_6: begin
            temperature_msb[6] <= input_bit;
            if(cycle_counter == 12'd2229)
            current_state <= MSB_RECEPTION_5;
        end
        
        MSB_RECEPTION_5: begin
            temperature_msb[5] <= input_bit;
            if(cycle_counter == 12'd2249)
            current_state <= MSB_RECEPTION_4;       
        end
        
        MSB_RECEPTION_4: begin
            temperature_msb[4] <= input_bit;
            if(cycle_counter == 12'd2269)
            current_state <= MSB_RECEPTION_3;
        end
        
        MSB_RECEPTION_3: begin
            temperature_msb[3] <= input_bit;
            if(cycle_counter == 12'd2289)
            current_state <= MSB_RECEPTION_2;
        end
        
        MSB_RECEPTION_2: begin
        temperature_msb[2] <= input_bit;
        if(cycle_counter == 12'd2309)
        current_state <= MSB_RECEPTION_1;
        end
        
        MSB_RECEPTION_1: begin
            temperature_msb[1] <= input_bit;
            if(cycle_counter == 12'd2329)
                current_state <= MSB_RECEPTION_0;   
        end
        
        MSB_RECEPTION_0: begin
        
        output_bit <= 1'b0;
        
        temperature_msb[0] <= input_bit;
        if(cycle_counter == 12'd2349)
        current_state <= ACKNOWLEDGMENT_TRANSMISSION;
        
    end
    ACKNOWLEDGMENT_TRANSMISSION: begin
    
    if(cycle_counter == 12'd2369)
    current_state <= LSB_RECEPTION_7;
    end
    
    LSB_RECEPTION_7: begin
    temperature_lsb[7] <= input_bit;
    if(cycle_counter == 12'd2389)
        current_state <= LSB_RECEPTION_6;
    
    end
    
    LSB_RECEPTION_6: begin
        temperature_lsb[6] <= input_bit;
        if(cycle_counter == 12'd2409)
            current_state <= LSB_RECEPTION_5;
    end
    
    LSB_RECEPTION_5: begin
        temperature_lsb[5] <= input_bit;
        if(cycle_counter == 12'd2429)
            current_state <= LSB_RECEPTION_4;
    end
    
    LSB_RECEPTION_4: begin
        temperature_lsb[4] <= input_bit;
        if(cycle_counter == 12'd2449)
            current_state <= LSB_RECEPTION_3;
    end
    
    LSB_RECEPTION_3: begin
        temperature_lsb[3] <= input_bit;
        if(cycle_counter == 12'd2469)
            current_state <= LSB_RECEPTION_2;
    end
    
    LSB_RECEPTION_2: begin
        temperature_lsb[2] <= input_bit;
        if(cycle_counter == 12'd2489)   
            current_state <= LSB_RECEPTION_1;
    end
    
    LSB_RECEPTION_1: begin
        temperature_lsb[1] <= input_bit;
        if(cycle_counter == 12'd2509)   
            current_state <= LSB_RECEPTION_0;
    end
    
    LSB_RECEPTION_0: begin
        output_bit <= 1'b1; 
        temperature_lsb[0] <= input_bit;
       
        if(cycle_counter == 12'd2529)
            current_state <= NO_ACKNOWLEDGMENT; 
    end
    NO_ACKNOWLEDGMENT: begin
        if(cycle_counter == 12'd2559) begin
        cycle_counter <= 12'd2000;
        current_state <= TRANSMISSION_START;
    end

end
endcase
end
// Temperature Data Buffering
always @(posedge clk_200KHz)
if(current_state == NO_ACKNOWLEDGMENT)
    temperature_buffer <= { temperature_msb[6:0], temperature_lsb[7] };

// SDA Line Direction Control
assign data_line_direction = (
current_state == INITIALIZATION || current_state == TRANSMISSION_START || 
current_state == ADDRESS_TRANSMISSION_6 || current_state == ADDRESS_TRANSMISSION_5 ||
current_state == ADDRESS_TRANSMISSION_4 || current_state == ADDRESS_TRANSMISSION_3 ||
current_state == ADDRESS_TRANSMISSION_2 || current_state == ADDRESS_TRANSMISSION_1 ||
current_state == ADDRESS_TRANSMISSION_0 || current_state == READ_WRITE_MODE ||
current_state == ACKNOWLEDGMENT_TRANSMISSION || current_state == NO_ACKNOWLEDGMENT) ? 1 : 0;
// Bidirectional Data Line Management
assign sensor_data = data_line_direction ? output_bit : 1'bz;
assign input_bit = sensor_data;
assign temperature_output = temperature_buffer;
endmodule
