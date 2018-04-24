module pc_block(CLK, AR, EN, OUT);
  input wire CLK, AR, EN;
  output wire [3:0] OUT;
  wire [3:0] next_PC;
  reg [3:0] PC;
  assign out = PC | 5'bzzzzz;
  always @ (posedge CLK, posedge AR)
  	begin
  		if(AR == 1'b1)
  			begin
  				PC <= 4'b0000;
  			end
  		else
  			begin
  				PC <= next_PC;
  			end
  	end
  assign next_PC = (EN) ? (PC + 1) : PC;
endmodule
