module bounceless_switch(CLK, AR, AP, D, BFC)

// CLK = clock
// AR = async reset
// AP = asyncy set
// D = Data
// BFC = output
input wire CLK, AR, AP, D;
output wire BFC;

always @ (posedge CLK, posedge AR, posedge AP)
  begin
    if (AR == 1'b1)
      begin
        BFC <= 0;
      end
    else if (AP == 1'b1)
      begin
        BFC <= 1;
      end
    else
      begin
        BFC <= D;
      end
  end
endmodule
