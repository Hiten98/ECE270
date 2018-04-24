module selfCorrecting_johnson_counter_states(CLK, R, Q, S);
// declarations
input wire CLK, R;
output reg [3:0] Q;
output reg [7:0] S;
reg [3:0] next_Q;

always @ (posedge CLK)
  begin
    Q <= next_Q;
  end

always @ (Q)
  begin
    next_Q[3] = ~R & Q[2];
    next_Q[2] = ~R & Q[1];
    next_Q[1] = ~ R & Q[0];
    next_Q[0] = R | (~R & ~Q[3]);
    S[0] = ~Q[3] & ~Q[0];
    S[1] = ~Q[1] & Q[0];
    S[2] = ~Q[2] & Q[1];
    S[3] = ~Q[3] & Q[2];
    S[4] = Q[3] & Q[0];
    S[5] = Q[1] & ~Q[0];
    S[6] = Q[2] & ~Q[1];
    S[7] = Q[3] & ~Q[2];
  end
endmodule
