interface uart_if;
  logic clk;
  logic rst;
  logic uclktx;
  logic uclkrx;
  logic rx;
  logic [7:0] dintx;
  logic send;
  logic tx;
  logic [7:0] doutrx;
  logic donetx;
  logic donerx;
endinterface
