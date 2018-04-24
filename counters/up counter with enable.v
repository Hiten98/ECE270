module upWithEN(CLK, AR, EN, Q);
    input wire CLK;
    input wire AR; // Asynchronous Reset
    input wire EN; // Counts up only if EN=1
    output reg [7:0] Q;
    reg [7:0] next_Q;
    // If AR asserted, resets to 00...0 (regardless of whether or not enabled)
    always @ (posedge CLK, posedge AR)
      begin
        if (AR == 1’b1)
        Q <= 8’b00000000;
        else if (EN == 1’b1)
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
