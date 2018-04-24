module selfCorrecting_johnson_counter(CLK, R, Q);
// declarations
input wire CLK, R;
output reg [3:0] Q;
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
  end
endmodule
