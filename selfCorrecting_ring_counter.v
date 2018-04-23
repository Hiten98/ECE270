//self correcting ring counter
module selfCorrecting_ring_counter(CLK, Q, R);
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
      next_Q[3] = Q[2];
      next_Q[2] = Q[1];
      next_Q[1] = Q[0];
      next_Q[0] = ~(Q[2] | Q[1] | Q[0]);
      if (R == 1'b1)
        begin
          next_Q = 4'b0000;
        end
    end
endmodule
