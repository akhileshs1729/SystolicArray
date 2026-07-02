module uart_receiver(input clk, rst, rdy_clr, rx, clk_en, output reg rdy, output reg [7:0] data_out);
  
  parameter start_state = 2'b00;
  parameter data_out_state = 2'b01;
  parameter stop_state = 2'b10;
  
  reg [1:0] state = start_state;
  reg [3:0] sample = 0;
  reg [3:0] index = 0;
  reg [7:0] temp_register = 8'b0;
  
  
  always @(posedge clk)
    begin
      if(rst) begin
        rdy = 0;
        data_out = 0;
      end
      
      always @(posedge clk)
        begin
          if(rdy_clr)
            rdy <= 0;
          
          if(clk_en)
            case(state) 
              
              //START STATE
              start_state : begin
                
                if(rx == 0 && sample != 0)
                  sample <= sample + 1'b1;
                
                if(sample == 15) begin
                  state <= data_out_state;
                  sample <= 0;
                  index <= 0;
                  temp_register <= 0;
                end
              end
              
              //DATA OUT STATE
              data_out_state : begin
                sample <= sample + 1'b1;
                
                if(sample == 4'h8) begin
                  temp_register[index] <= rx;
                  index <= index + 1'b1;
                end
                
                if(index == 8 && sample == 15)
                  state <= stop_state;
                
              end
              
              // STOP STATE
              stop_state: begin
                
                if(sample == 15)
                  begin
                    state <= start_state;
                    data_out <= temp_register;
                    rdy <= 1'b1;
                    sample <= 0;
                  end
                
                else
                  sample = sample + 1'b1;
              end
              
              default: begin
                state <= start_state;
              end
              endcase
        end

        end
endmodule

              
                    
                   
                  
                
            