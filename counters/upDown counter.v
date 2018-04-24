module upDown(CLK, M, Q);
  input wire CLK, M; // M=0 count down, M=1 count up
  output reg [7:0] Q;
  reg [7:0] next_Q;
  always @ (posedge CLK)
    begin
      Q <= next_Q;
    end
  always @ (Q, M)
    begin
      if (M == 1’b0)
        begin
          next_Q[0] = ~Q[0];
          next_Q[1] = Q[1] ^ ~Q[0];
          next_Q[2] = Q[2] ^ (~Q[1] & ~Q[0]);
          next_Q[3] = Q[3] ^ (~Q[2] & ~Q[1] & ~Q[0]);
          next_Q[4] = Q[4] ^ (~Q[3] & ~Q[2] & ~Q[1] & ~Q[0]);
          next_Q[5] = Q[5] ^ (~Q[4] & ~Q[3] & ~Q[2] & ~Q[1] & ~Q[0]);
          next_Q[6] = Q[6] ^ (~Q[5] & ~Q[4] & ~Q[3] & ~Q[2] & ~Q[1] & ~Q[0]);
          next_Q[7] = Q[7] ^ (~Q[6] & ~Q[5] & ~Q[4] & ~Q[3] & ~Q[2] & ~Q[1] & ~Q[0]);
        end
      else
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
    end
endmodule
