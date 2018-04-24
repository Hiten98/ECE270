module carry_adder(X, Y, CIN, S);
  input wire [3:0] X, Y; // Operands
  input wire CIN; // Carry in
  output wire [3:0] S; // Sum outputs
  wire [3:0] C; // Carry equations (C[3] is Cout)
  wire [3:0] P, G;
  assign G = X & Y; // Generate functions G[0] = X[0]&Y[0]; G[1] = .. so on
  assign P = X ^ Y; // Propagate functions P[0] = X[0]^Y[0]; P[1] = .. so on
  // Carry function definitions
  assign C[0] = G[0] | CIN & P[0];
  assign C[1] = G[1] | G[0] & P[1] | CIN & P[0] & P[1];
  assign C[2] = G[2] | G[1] & P[2] | G[0] & P[1] & P[2] | CIN & P[0] & P[1] & P[2];
  assign C[3] = G[3] | G[2] & P[3] | G[1] & P[2] & P[3] | G[0] & P[1] & P[2] & P[3] | CIN & P[0] & P[1] & P[2] & P[3];
  assign S[0] = CIN ^ P[0];
  assign S[3:1] = C[2:0] ^ P[3:1];
endmodule
