module BRAMController ( 
     input wire clk, // Nexys A7 clock (CLK100MHZ)
     input wire rst, // Reset signal for min/max/average
     input wire [7:0] new_temp, // New temperature data (f_data) 
     input wire new_temp_valid, // Signal indicating new temperature is valid 
     output reg [7:0] avg_temp, // Average temperature
     output reg [7:0] max_temp, // Maximum temperature 
     output reg [7:0] min_temp // Minimum temperature 
     ); 
     // BRAM instance 
     reg [7:0] bram [0:9]; // BRAM to store 10 temperature values 
     reg [3:0] write_pointer = 0; // Pointer for circular buffer 
     // Temporary variables for calculations 
     reg [11:0] temp_sum; // 12 bits to hold sum of 10 8-bit values 
     integer i; // Loop variable 
     
    
    reg [7:0] counter = 26'h00;
    reg clk_reg = 1'b1;
    
    always @(posedge clk) begin
        if(counter == 27'd999999) begin
            counter <= 27'd0;
            clk_reg <= ~clk_reg;
        end
        else
            counter <= counter + 1;
    end
     always @(posedge clk or posedge rst) begin 
        if (rst) begin // Reset logic 
            write_pointer <= 0; 
            avg_temp <= 8'd0; 
            max_temp <= 8'd0; 
            min_temp <= 8'd255;
            
        
            for (i = 0; i < 10; i = i + 1) begin 
                bram[i] <= 8'd0; 
            end 
            end 
            else if (new_temp_valid) begin 
            // Store new temperature 
            bram[write_pointer] <= new_temp; 
            write_pointer <= (write_pointer + 1) % 10; 
            // Calculate new average, max, and min 
            temp_sum = 0; 
            max_temp = 8'd1; 
            min_temp = 8'd255; 
            for (i = 0; i < 10; i = i + 1) 
                begin temp_sum = temp_sum + bram[i]; 
                if (bram[i] > max_temp) max_temp = bram[i]; 
                if (bram[i] < min_temp) min_temp = bram[i]; 
            end 
            avg_temp <= temp_sum / 10; 
        end 
    end
 endmodule
