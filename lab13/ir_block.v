module ir_block(CLK, AR, EN, DATA, OUT);
  input wire AR, CLK, EN;   // EN =  instruction load enable
  input wire [6:0] DATA;    //data bus
  output reg [6:0] OUT;   // data bus connected to addr bus
  reg [6:0] IR;
  wire [6:0] next_IR;
  assign OUT = IR;
  always @ (posedge CLK, posedge AR)
  	begin
  		if(AR == 1'b1)
  			begin
  				IR <= 7'b0000000;
  			end
  		else if(EN == 1'b1)
  			begin
  				IR <= next_IR;
  			end
  	end
    // if enabled ouput is data, else hold current state
  assign next_IR = (EN) ? DATA: IR;
endmodule
