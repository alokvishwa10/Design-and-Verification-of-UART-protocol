`include "interface.sv"

//Top module
module uart_top #(parameter clk_freq=1000000, parameter baud_rate=9600)
  (input clk, 
   input rst,
   input rx,
   input [7:0] dintx,
   input send,
   output tx,
   output [7:0] doutrx,
   output donetx,
   output donerx
  );
  
  uarttx utx(clk,rst,send,dintx,tx,donetx);
  uartrx urx(clk,rst,rx,donerx,doutrx);
endmodule



// Transmitter module
module uarttx #(parameter clk_freq=1000000, parameter baud_rate=9600) (input clk,rst,send, 
                                                                       input [7:0] tx_data,
                                                                      output reg tx, donetx);
  localparam clkcount=(clk_freq/baud_rate);
  integer count=0;
  integer counts=0;
  reg uclk=0;
  reg[7:0] din;
  
  enum bit[1:0] {idle = 2'b00, start = 2'b01, transfer = 2'b10, done = 2'b11} state;
  
  always@(posedge clk)begin
    if(count<clkcount/2)
      count<=count+1;
    else begin
      count<=0;
      uclk<=~uclk;
    end
  end
  
  always@(posedge uclk)begin
    if(rst) state<=idle;
    else begin
      case(state)
        idle: begin
          count<=0;
          counts<=0;
          tx<=1;
          donetx<=0;
          if(send)begin
            state<=transfer;
            din<=tx_data;
            tx<=0;
          end
          else state<=idle;
        end
        
        transfer: begin
          if(counts<=7)begin
            counts<=counts+1;
            tx<=din[counts];
            state<=transfer;
          end
          else begin
            counts<=0;
            tx=1;
            state<=idle;
            donetx<=1;
          end
        end
        
        default: state<=idle;
        
      endcase
    end
  end
  
endmodule

//Receiver module

module uartrx #(parameter clk_freq=1000000, parameter baud_rate=9600) (input clk,rst,rx,
                                                                      output reg done,
                                                                       output reg[7:0] rxdata);
  
  localparam clkcount=(clk_freq/baud_rate);
  integer count=0;
  integer counts=0;
  reg uclk=0;
  
  enum bit[1:0] {idle=00,start=01} state;
  
  always@(posedge clk)begin
    if(count<clkcount/2)
      count<=count+1;
    else begin
      count<=0;
      uclk<=~uclk;
    end
  end
  
  always@(posedge uclk)begin
    if(rst) state<=idle;
    else begin
      case(state)
        idle: begin
          rxdata<=8'h0;
          counts<=0;
          done<=0;
          if(rx==1'b0)
            state<=start;
          else state<=idle;
        end
        
        start: begin
          if(counts<=7)begin
            counts<=counts+1;
            rxdata<={rx,rxdata[7:1]};
          end
          else begin
            counts<=0;
            done<=1;
            state<=idle;
          end
        end
        
        default: state<=idle;
        
      endcase
    end
  end
endmodule
