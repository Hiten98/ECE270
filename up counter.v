module upCounter(CLK, Q);
  input wire CLK;
  output reg [7:0] Q;
  reg [7:0] next_Q;
  always @ (posedge CLK)
    begin
      Q <= next_Q;
    end
  always @ (Q)
    begin
      next_Q[0] = ~Q[0];
      next_Q[1] = Q[1] ^ Q[0];
      next_Q[2] = Q[2] ^ (Q[1] & Q[0]);
      next_Q[3] = Q[3] ^ (Q[2] & Q[1] & Q[0]);
      next_Q[4] = Q[4] ^ (Q[3] & Q[2] & Q[1] & Q[0]);
      next_Q[5] = Q[5] ^ (Q[4] & Q[3] & Q[2] & Q[1] & Q[0]);
      next_Q[6] = Q[6] ^ (Q[5] & Q[4] & Q[3] & Q[2] & Q[1] & Q[0]);
      next_Q[7] = Q[7] ^ (Q[6] & Q[5] & Q[4] & Q[3] & Q[2] & Q[1] & Q[0]);
    end
endmodule
