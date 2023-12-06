//generator
class generator;
  transaction t;
  mailbox #(transaction) mbxgd;
  event drvnext,sconext,done;
  int count=0;
  
  function new(mailbox #(transaction) mbxgd);
    this.mbxgd=mbxgd;
    t=new;
  endfunction
  
  task run;
    repeat(count)begin
      assert(t.randomize) else $warning("Randomization failed");
      mbxgd.put(t.copy);
      t.display("GEN");
      @(drvnext);
      @(sconext);
    end
    ->done;
  endtask
endclass
