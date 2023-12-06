//monitor
class monitor;
  transaction tr;
  virtual uart_if vif;
  mailbox #(bit[7:0]) mbxms;
  
  bit[7:0] srx;
  bit[7:0] rrx;
  
  function new(mailbox #(bit[7:0]) mbxms);
    this.mbxms=mbxms;
  endfunction
  
  task run;
    forever begin
      @(posedge vif.uclktx);
      if ( (vif.send== 1'b1) && (vif.rx == 1'b1) )begin
        @(posedge vif.uclktx); //start collecting tx data from next clock tick
        for(int i = 0; i<= 7; i++) begin 
            @(posedge vif.uclktx);
            srx[i] = vif.tx;
        end
        $display("[MON] : DATA SEND on UART TX %0d", srx);
        @(posedge vif.uclktx);
        mbxms.put(srx);
      end
      
      else if ((vif.rx == 1'b0) && (vif.send == 1'b0) ) begin
        wait(vif.donerx == 1);
        rrx = vif.doutrx;     
        $display("[MON] : DATA RCVD RX %0d", rrx);
        @(posedge vif.uclktx); 
        mbxms.put(rrx);
      end
    end  
  endtask
endclass
