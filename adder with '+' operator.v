module cla4p(X, Y, CIN, S);
  input wire [3:0] X, Y; // operands
  input wire CIN; // LSB carry-in
  output wire [3:0] S; // sum outputs
  assign S = X + Y + CIN;
endmodule
