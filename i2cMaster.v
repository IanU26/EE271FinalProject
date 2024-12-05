//Original I2CMaster code. 
/*
`timescale 1ns / 1ps


module i2c_master(
    input clk_200KHz,               // i_clk
    inout SDA,                      // i2c standard interface signal
    output [7:0] temp_data,         // 8 bits binary representation of deg C
    output SCL                      // i2c standard interface signal - 10KHZ
    );
    
    wire SDA_dir;                   // SDA direction signal
    
    // *** GENERATE 10kHz SCL clock from 200kHz ***************************
    // 200 x 10^3 / 10 x 10^3 / 2 = 10
    reg [3:0] counter = 4'b0;  // count up to 9
    reg clk_reg = 1'b1; 
      
    // Set value of i2c SCL signal to the sensor - 10kHz            
    assign SCL = clk_reg;   
    // ********************************************************************     

    // Signal Declarations               
    parameter [7:0] sensor_address_plus_read = 8'b1001_0111;// 0x97
    reg [7:0] tMSB = 8'b0;                                  // Temp data MSB
    reg [7:0] tLSB = 8'b0;                                  // Temp data LSB
    reg o_bit = 1'b1;                                       // output bit to SDA - starts HIGH
    reg [11:0] count = 12'b0;                               // State Machine Synchronizing Counter
    reg [7:0] temp_data_reg;					            // Temp data buffer register			

    // State Declarations - need 28 states
    localparam [4:0] POWER_UP   = 5'h00,
                     START      = 5'h01,
                     SEND_ADDR6 = 5'h02,
					 SEND_ADDR5 = 5'h03,
					 SEND_ADDR4 = 5'h04,
					 SEND_ADDR3 = 5'h05,
					 SEND_ADDR2 = 5'h06,
					 SEND_ADDR1 = 5'h07,
					 SEND_ADDR0 = 5'h08,
					 SEND_RW    = 5'h09,
                     REC_ACK    = 5'h0A,
                     REC_MSB7   = 5'h0B,
					 REC_MSB6	= 5'h0C,
					 REC_MSB5	= 5'h0D,
					 REC_MSB4	= 5'h0E,
					 REC_MSB3	= 5'h0F,
					 REC_MSB2	= 5'h10,
					 REC_MSB1	= 5'h11,
					 REC_MSB0	= 5'h12,
                     SEND_ACK   = 5'h13,
                     REC_LSB7   = 5'h14,
					 REC_LSB6	= 5'h15,
					 REC_LSB5	= 5'h16,
					 REC_LSB4	= 5'h17,
					 REC_LSB3	= 5'h18,
					 REC_LSB2	= 5'h19,
					 REC_LSB1	= 5'h1A,
					 REC_LSB0	= 5'h1B,
                     NACK       = 5'h1C;
      
    reg [4:0] state_reg = POWER_UP;                         // state register
                       
    always @(posedge clk_200KHz) begin
            // Counters Logic
            if(counter == 9) begin
                counter <= 4'b0;
                clk_reg <= ~clk_reg;    // toggle reg
            end
            else
                counter <= counter + 1;

			count <= count + 1;
			
			// State Machine Logic
			// 'COUNT' is used to determine how many cycles between state transitions.
		    // The machine goes through the states from top --> bottom
            case(state_reg)
                
                POWER_UP    : begin
                                if(count == 12'd1999)
                                    state_reg <= START;
                end
                
                START       : begin
                                if(count == 12'd2004)
                                    o_bit <= 1'b0;          // send START condition 1/4 clock after SCL goes high    
                                if(count == 12'd2013)
                                    state_reg <= SEND_ADDR6; 
                end
                SEND_ADDR6  : begin
                                o_bit <= sensor_address_plus_read[7];
                                if(count == 12'd2033)
                                    state_reg <= SEND_ADDR5;
                end
				SEND_ADDR5  : begin
                                o_bit <= sensor_address_plus_read[6];
                                if(count == 12'd2053)
                                    state_reg <= SEND_ADDR4;
                end
				SEND_ADDR4  : begin
                                o_bit <= sensor_address_plus_read[5];
                                if(count == 12'd2073)
                                    state_reg <= SEND_ADDR3;
                end
				SEND_ADDR3  : begin
                                o_bit <= sensor_address_plus_read[4];
                                if(count == 12'd2093)
                                    state_reg <= SEND_ADDR2;
                end
				SEND_ADDR2  : begin
                                o_bit <= sensor_address_plus_read[3];
                                if(count == 12'd2113)
                                    state_reg <= SEND_ADDR1;
                end
				SEND_ADDR1  : begin
                                o_bit <= sensor_address_plus_read[2];
                                if(count == 12'd2133)
                                    state_reg <= SEND_ADDR0;
                end
				SEND_ADDR0  : begin
                                o_bit <= sensor_address_plus_read[1];
                                if(count == 12'd2153)
                                    state_reg <= SEND_RW;
                end
				SEND_RW     : begin
                                o_bit <= sensor_address_plus_read[0];
				if(count == 12'd2169)
                                    state_reg <= REC_ACK;
                end
                REC_ACK     : begin
                                if(count == 12'd2189)
                                    state_reg <= REC_MSB7;
                end
                REC_MSB7     : begin
                                tMSB[7] <= i_bit;
                                if(count == 12'd2209)
                                    state_reg <= REC_MSB6;
                                
                end
				REC_MSB6     : begin
                                tMSB[6] <= i_bit;
                                if(count == 12'd2229)
                                    state_reg <= REC_MSB5;
                                
                end
				REC_MSB5     : begin
                                tMSB[5] <= i_bit;
                                if(count == 12'd2249)
                                    state_reg <= REC_MSB4;
                                
                end
				REC_MSB4     : begin
                                tMSB[4] <= i_bit;
                                if(count == 12'd2269)
                                    state_reg <= REC_MSB3;
                                
                end
				REC_MSB3     : begin
                                tMSB[3] <= i_bit;
                                if(count == 12'd2289)
                                    state_reg <= REC_MSB2;
                                
                end
				REC_MSB2     : begin
                                tMSB[2] <= i_bit;
                                if(count == 12'd2309)
                                    state_reg <= REC_MSB1;
                                
                end
				REC_MSB1     : begin
                                tMSB[1] <= i_bit;
                                if(count == 12'd2329)
                                    state_reg <= REC_MSB0;
                                
                end
				REC_MSB0     : begin
								o_bit <= 1'b0;
                                tMSB[0] <= i_bit;
                                if(count == 12'd2349)
                                    state_reg <= SEND_ACK;
                                
                end
                SEND_ACK   : begin
                                if(count == 12'd2369)
                                    state_reg <= REC_LSB7;
                end
                REC_LSB7    : begin
                                tLSB[7] <= i_bit;
                                if(count == 12'd2389)
									state_reg <= REC_LSB6;
                end
                REC_LSB6    : begin
                                tLSB[6] <= i_bit;
                                if(count == 12'd2409)
									state_reg <= REC_LSB5;
                end
				REC_LSB5    : begin
                                tLSB[5] <= i_bit;
                                if(count == 12'd2429)
									state_reg <= REC_LSB4;
                end
				REC_LSB4    : begin
                                tLSB[4] <= i_bit;
                                if(count == 12'd2449)
									state_reg <= REC_LSB3;
                end
				REC_LSB3    : begin
                                tLSB[3] <= i_bit;
                                if(count == 12'd2469)
									state_reg <= REC_LSB2;
                end
				REC_LSB2    : begin
                                tLSB[2] <= i_bit;
                                if(count == 12'd2489)
									state_reg <= REC_LSB1;
                end
				REC_LSB1    : begin
                                tLSB[1] <= i_bit;
                                if(count == 12'd2509)
									state_reg <= REC_LSB0;
                end
				REC_LSB0    : begin
								o_bit <= 1'b1;
                                tLSB[0] <= i_bit;
                                if(count == 12'd2529)
									state_reg <= NACK;
                end
                NACK        : begin
                                if(count == 12'd2559) begin
									count <= 12'd2000;
                                    state_reg <= START;
								end
                end
            endcase     
    end      
    
    // Buffer for temperature data
    always @(posedge clk_200KHz)
        if(state_reg == NACK)
            temp_data_reg <= { tMSB[6:0], tLSB[7] };
    
    
    // Control direction of SDA bidirectional inout signal
    assign SDA_dir = (state_reg == POWER_UP || state_reg == START || state_reg == SEND_ADDR6 || state_reg == SEND_ADDR5 ||
					  state_reg == SEND_ADDR4 || state_reg == SEND_ADDR3 || state_reg == SEND_ADDR2 || state_reg == SEND_ADDR1 ||
                      state_reg == SEND_ADDR0 || state_reg == SEND_RW || state_reg == SEND_ACK || state_reg == NACK) ? 1 : 0;
    // Set the value of SDA for output - from master to sensor
    assign SDA = SDA_dir ? o_bit : 1'bz;
    // Set value of input wire when SDA is used as an input - from sensor to master
    assign i_bit = SDA;
    // Outputted temperature data
    assign temp_data = temp_data_reg;
 
endmodule
*/


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
