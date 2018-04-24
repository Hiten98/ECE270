module cla4(X, Y, CIN, CF, NF, ZF,VF, S);
  input wire [3:0] X, Y; // Operands
  input wire CIN; // Carry in
  output wire [3:0] S; // Sum outputs
  output wire CF, NF, ZF, VF;
  wire [3:0] C; // Carry equations (C[3] is Cout)
  wire [3:0] P, G;
  assign G[0] = X[0] & (Y[0]^CIN); // Generate functions G[0] = X[0]&Y[0]; G[1] = .. so on
  assign G[1] = X[1] & (Y[1]^CIN);
  assign G[2] = X[2] & (Y[2]^CIN);
  assign G[3] = X[3] & (Y[3]^CIN);
  assign P[0] = X[0] ^ Y[0]^CIN; // Propagate functions P[0] = X[0]^Y[0];P[1] = .. so on
  assign P[1] = X[1] ^ Y[1]^CIN;
  assign P[2] = X[2] ^ Y[2]^CIN;
  assign P[3] = X[3] ^ Y[3]^CIN;
  // Carry function definitions
  assign C[0] = G[0] | CIN & P[0];
  assign C[1] = G[1] | G[0] & P[1] | CIN & P[0] & P[1];
  assign C[2] = G[2] | G[1] & P[2] | G[0] & P[1] & P[2] | CIN & P[0] & P[1] & P[2];
  assign C[3] = G[3] | G[2] & P[3] | G[1] & P[2] & P[3] | G[0] & P[1] & P[2] & P[3]| CIN & P[0] & P[1] & P[2] & P[3];
  assign S[0] = CIN ^ P[0];
  assign S[3:1] = C[2:0] ^ P[3:1];

  assign CF = C[3];
  assign NF = S[3];
  assign ZF = !(S[0]|S[1]|S[2]|S[3]);
  assign VF = C[3] ^ C[2];
endmodule
