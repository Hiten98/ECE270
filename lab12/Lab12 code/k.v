module LFSR(CLK,AP,Q);
  input wire CLK, AP;
  output reg[3:0]Q;
  wire leftbit;

  assign leftbit = (Q[3]^Q[2])^(~(Q[2]|Q[0]|Q[1]));

  always@(posedge CLK, posedge AP) begin

  	if(AP==1)
      begin
  		  Q<=4'b0000;
  	   end
  	else
      begin
  		  Q[3:0]<={Q[2:0],leftbit};
  	  end
  end
endmodule
