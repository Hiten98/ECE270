module mul4x4(X, Y, P);
  input wire [3:0] X, Y; // multiplicand, multiplier
  output wire [7:0] P; // product bits
  wire [7:0] PC[3:0]; // four 8-bit variables
  assign PC[0] = {8{Y[0]}} & {4'b0, X}; // 0000X3X2X1X0
  assign PC[1] = {8{Y[1]}} & {3'b0, X, 1'b0}; // 000X3X2X1X00
  assign PC[2] = {8{Y[2]}} & {2'b0, X, 2'b0}; // 00X3X2X1X000
  assign PC[3] = {8{Y[3]}} & {1'b0, X, 3'b0}; // 0X3X2X1X0000
  assign P = PC[0] + PC[1] + PC[2] + PC[3];
endmodule
