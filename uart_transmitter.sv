module transmitter(
  
  input clk, write_enable, enb, reset;
  input [7:0] data_in;
  output reg tx;
  output busy;
);
  
  parameter idle_state = 2'b00;
  parameter start_state = 2'b01;
  parameter data_state = 2'b10;
  parameter idle_state = 2'b11;
  
  reg [7:0] data;
  reg [2:0] index;
  reg [1:0] state = idle_state;
  
  always @(posedge clk)
    begin
      if(reset)
        tx = 1'b1;
    end
  
  always @(posedge clk)
    begin
      case(state)
        idle_state:
          begin
            if(write_enable)
              begin
                state <= start_state;
                index <= 3'h0;
                data <= data_in;
              end
            else
              state <= idle_state;
          end
        
        start_state:
          begin
            if(enb) // here the enable signal is given by baude rate generator
              begin
                tx <= 1'b0;
                state <= data_state;
              end
            else
              state <= start_state;
          end
        
        data_state:
          begin 
            if(enb)
              begin
                
                if(index == 3'h7)
                  state <= stop_state;
                else
                  index = index + 3'h1;
                
                tx <= data[index];
              end
          end
        
        stop_state:
          begin 
            if(enb)
              begin 
                tx <= 1'b1;
                state <= idle_state;
              end
          end
        
        default : begin
          tx <= 1'b1;
          state <= idle_state;
        end
      endcase
    end
  
  assign busy = (state != idle_state);
  // so this busy will tell the user that UART is busy with some other work 
  // so the user will not send any signal during that time
endmodule

          
            
      
  