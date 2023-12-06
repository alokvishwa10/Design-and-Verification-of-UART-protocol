//transaction
class transaction;
  typedef enum bit[1:0] {write=2'b00, read=2'b01} oper_type;
  randc oper_type oper;
  rand bit[7:0] dintx;
  bit rx;
  bit send;
  bit tx;
  bit[7:0] doutrx;
  bit donetx;
  bit donerx;
  
  function void display(input string tag);
    $display("[%0s] : operation : %0s, send : %0b, Tx_data : %0b, Rx_in : %0b, Tx_out : %0b, Rx_out : %0b, Donetx %0b, Donerx : %0b ", tag, oper.name(), send, dintx, rx, tx, doutrx, donetx,donerx);
  endfunction
  
  function transaction copy();
    copy=new;
    copy.rx=this.rx;
    copy.dintx=this.dintx;
    copy.send=this.send;
    copy.tx=this.tx;
    copy.doutrx=this.doutrx;
    copy.donetx=this.donetx;
    copy.donerx=this.donerx;
    copy.oper=this.oper;
  endfunction
  
endclass
