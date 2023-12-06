//driver
class driver;
  virtual uart_if vif;
  transaction t;
  mailbox #(transaction) mbxgd;
  mailbox #(bit[7:0]) mbxds;
  event drvnext;
  
  bit[7:0] din;
  bit[7:0] datarx;
  bit wr=0;
  
  
  function new(mailbox #(transaction) mbxgd,mailbox #(bit[7:0]) mbxds);
    this.mbxgd=mbxgd;
    this.mbxds=mbxds;
  endfunction
  
  task reset();
    vif.rst<=1;
    vif.dintx<=0;
    vif.send<=0;
    vif.rx<=1;
    vif.doutrx<=0;
    vif.tx<=1;
    vif.donerx<=0;
    vif.donetx<=0;
    repeat(5) @(posedge vif.uclktx);
    vif.rst<=0;
    @(posedge vif.uclktx);
    $display("Reset done");
  endtask
  
  task run;
    forever begin
      mbxgd.get(t);
      if(t.oper==2'b00)begin
        @(posedge vif.uclktx);
        vif.rst<=0;
        vif.send<=1;          //start sending data
        vif.rx<=1;
        vif.dintx<=t.dintx;
        @(posedge vif.uclktx);
        vif.send<=0;
        repeat(9) @(posedge vif.uclktx);
        mbxds.put(t.dintx);
        $display("[DRV] : data sent : %0d", t.dintx);
        wait(vif.donetx==1);
        ->drvnext;
      end
      else if(t.oper==2'b01)begin
        @(posedge vif.uclkrx);
        vif.rst<=0;
        vif.send<=0;          //start receiving data
        vif.rx<=0;
        @(posedge vif.uclkrx);
        for(int i=0;i<=7;i++)begin
          @(posedge vif.uclkrx);
          vif.rx<=$urandom;
          datarx[i]=vif.rx;
        end
        mbxds.put(datarx);
        $display("[DRV] : data rcvd : %0d", datarx);
        wait(vif.donerx==1);
        vif.rx<=1;
        ->drvnext;
      end
      
    end
  endtask
endclass
