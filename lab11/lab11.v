module lab11(DIP, i_S1_NC, i_S1_NO, i_S2_NC, i_S2_NO, o_TOPRED, o_MIDRED, o_BOTRED, o_DIS1, o_DIS2, o_DIS3, o_DIS4, o_JUMBO, o_LED_YELLOW);

// ====== DO NOT MODIFY BELOW ======
input wire [7:0] DIP /*synthesis loc="26,25,24,23,76,77,78,79"*/;		// DIP switches (MSB on the left)

input wire i_S1_NC /*synthesis loc="58"*/;					// ACTIVE LOW normally closed (down position)
input wire i_S1_NO /*synthesis loc="59"*/;					// ACTIVE LOW normally opened (up position)
input wire i_S2_NC /*synthesis loc="60"*/;					// ACTIVE LOW normally closed (down position)
input wire i_S2_NO /*synthesis loc="61"*/;					// ACTIVE LOW normally opened (up position)

output wire [7:0] o_TOPRED /*synthesis loc="28,29,30,31,32,33,39,40"*/;			// ACTIVE LOW first row of LED (from top, MSB on the left)
output wire [7:0] o_MIDRED /*synthesis loc="130,131,132,133,134,135,138,139"*/;		// ACTIVE LOW second row of LED (from top, MSB on the left)
output wire [7:0] o_BOTRED /*synthesis loc="112,111,105,104,103,102,101,100"*/;		// ACTIVE LOW third row of LED (from top, MSB on the left)

output wire [6:0] o_DIS1 /*synthesis loc="87,86,85,84,83,81,80"*/;			// ACTIVE LOW right most 7-segment
output wire [6:0] o_DIS2 /*synthesis loc="98,97,96,95,94,93,88"*/;			// ACTIVE LOW second right most 7-segment
output wire [6:0] o_DIS3 /*synthesis loc="125,124,123,122,121,120,116"*/;		// ACTIVE LOW second left most 7-segment
output wire [6:0] o_DIS4 /*synthesis loc="44,48,49,50,51,52,53"*/;			// ACTIVE LOW left most 7-segment

output wire [3:0] o_JUMBO /*synthesis loc="143,142,141,140*/;			// ACTIVE LOW Jumbo R-Y-G LED (unused, RED, YELLOW, GREEN)

output wire [1:0] o_LED_YELLOW /*synthesis loc="62,63*/;			// ACTIVE LOW yellow LED next to pushbuttons

// Active Low Assignments
wire S1_NC, S1_NO, S2_NC, S2_NO;
reg [7:0] TOPRED;
reg [7:0] MIDRED;
reg [7:0] BOTRED;
reg [6:0] DIS1;
reg [6:0] DIS2;
reg [6:0] DIS3;
reg [6:0] DIS4;
reg JUMBO_unused, JUMBO_R, JUMBO_Y, JUMBO_G;
reg LED_YELLOW_L, LED_YELLOW_R;

assign S1_NC = ~i_S1_NC;
assign S1_NO = ~i_S1_NO;
assign S2_NC = ~i_S2_NC;
assign S2_NO = ~i_S2_NO;
assign o_TOPRED = ~TOPRED;
assign o_MIDRED = ~MIDRED;
assign o_BOTRED = ~BOTRED;
assign o_DIS1 = ~DIS1;
assign o_DIS2 = ~DIS2;
assign o_DIS3 = ~DIS3;
assign o_DIS4 = ~DIS4;
assign o_JUMBO = {~JUMBO_unused, ~JUMBO_G, ~JUMBO_Y, ~JUMBO_R};
assign o_LED_YELLOW = {~LED_YELLOW_L, ~LED_YELLOW_R};


// Oscillator

wire osc_dis, tmr_rst, osc_out, tmr_out;
assign osc_dis = 1'b0;
assign tmr_rst = 1'b0;

defparam I1.TIMER_DIV = "1048576";
OSCTIMER I1 (.DYNOSCDIS(osc_dis), .TIMERRES(tmr_rst), .OSCOUT(osc_out), .TIMEROUT(tmr_out));


// 7-segment alphanumeric display code
localparam blank = 7'b0000000;
localparam char0 = 7'b1111110;
localparam char1 = 7'b0110000;
localparam char2 = 7'b1101101;
localparam char3 = 7'b1111001;
localparam char4 = 7'b0110011;
localparam char5 = 7'b1011011;
localparam char6 = 7'b1011111;
localparam char7 = 7'b1110000;
localparam char8 = 7'b1111111;
localparam char9 = 7'b1111011;
localparam charA = 7'b1110111;
localparam charB = 7'b0011111;
localparam charC = 7'b1001110;
localparam charD = 7'b0111101;
localparam charE = 7'b1001111;
localparam charF = 7'b1000111;
localparam charG = 7'b1111011;
localparam charH = 7'b0110111;
localparam charI = 7'b0010000;
localparam charJ = 7'b0111000;
localparam charL = 7'b0001110;
localparam charN = 7'b0010101;
localparam charO = 7'b0011101;
localparam charP = 7'b1100111;
localparam charR = 7'b0000101;
localparam charS = 7'b1011011;
localparam charU = 7'b0111110;
localparam charY = 7'b0111011;

//my variables
reg [1:0] timr;
reg [6:0] D1;
reg [6:0] D2;
reg [6:0] D3;
reg [6:0] D4;
reg [3:0] state;
reg [3:0] nextState;
reg [7:0] LED;
reg [7:0] nextLED;
reg [1:0] locked;
reg [1:0] prevLocked;
reg [7:0] mid;
reg [7:0] nextMid;


always @ (posedge tmr_out)
	begin
		if(DIP[7] == 1'b1)
			begin
				locked[1:0] = 2'b00;
				nextState = 4'b0000;
				nextMid <= 8'b00000001;
			end
		if(timr == 2'b 00)
			begin
				timr <= 2'b01;
				LED_YELLOW_R <= 0;
				//DIS4 <= D4;
			end
		else if (timr == 2'b01)
			begin
				timr <= 2'b10;
				LED_YELLOW_R <= 0;
				//DIS3 <= D3;
			end
		else if(timr == 2'b10)
			begin
				timr <= 2'b11;
				LED_YELLOW_R <= 0;
				//DIS2 <= D2;
			end
		else if(timr == 2'b11)
			begin
				//do the displaying stuff:
				if(DIP[7] == 1'b1)
					begin
						locked[1:0] = 2'b00;
						nextState = 4'b0000;
						nextMid <= 8'b00000001;
					end
				if(prevLocked[1:0] != locked[1:0])
					begin
						prevLocked[1:0] = locked[1:0];
						nextState = 4'b0000;
					end

				if(locked[1:0] == 2'b00) // secure
					begin
						case(state)
							4'b0000: nextState = 4'b0001;
							4'b0001: nextState = 4'b0010;
							4'b0010: nextState = 4'b0011;
							4'b0011: nextState = 4'b0100;
							4'b0100: nextState = 4'b0101;
							4'b0101: nextState = 4'b0110;
							4'b0110: nextState = 4'b0000;
						endcase
					end
				else if(locked[1:0] == 2'b01) //open
					begin
						case(state)
							4'b0000: nextState = 4'b0111;
							4'b0111: nextState = 4'b1000;
							4'b1000: nextState = 4'b0010;
							4'b0010: nextState = 4'b1001;
							4'b1001: nextState = 4'b0000;
						endcase
					end
				else if(locked[1:0] == 2'b11) //error
					begin
						case(state)
							4'b0000: nextState = 4'b0010;
							4'b0010: nextState = 4'b0101;
							4'b0101: nextState = 4'b1010;
							4'b1010: nextState = 4'b0111;
							4'b0111: nextState = 4'b1011;
							4'b1011: nextState = 4'b0000;
						endcase
					end
				timr <= 2'b00;
				LED_YELLOW_R <= 1;
				if(DIP[0] == 1'b1)
					begin
						// generate sequence:  (mine not from the class itself)
						nextLED[0] = LED[1] ^ LED[0];
						nextLED[1] = LED[2] ^ LED[1];
						nextLED[2] = LED[3] ^ LED[2];
						nextLED[3] = LED[4] ^ LED[3];
						nextLED[4] = LED[5] ^ LED[4];
						nextLED[5] = LED[6] ^ LED[5];
						nextLED[6] = !LED[0];
						nextLED[7] = !LED[1];
					end
				else
					begin
						LED <= LED;
						nextLED = LED;
					end
				if(DIP[7] == 1'b1)
					begin
						locked[1:0] = 2'b00;
						nextState = 4'b0000;
						nextMid <= 8'b00000001;
						JUMBO_Y = 1'b0;
						JUMBO_R = 1'b0;
						JUMBO_G = 1'b0;
					end
				if(prevLocked[1:0] != locked[1:0])
					begin
						prevLocked[1:0] = locked[1:0];
						nextState = 4'b0000;
					end
				case (nextState)
					4'b0000: D1 = blank;
					4'b0001: D1 = charS;
					4'b0010: D1 = charE;
					4'b0011: D1 = charC;
					4'b0100: D1 = charU;
					4'b0101: D1 = charR;
					4'b0110: D1 = charE;
					4'b0111: D1 = charO;
					4'b1000: D1 = charP;
					4'b1001: D1 = charN;
					4'b1010: D1 = charR;
					4'b1011: D1 = charR;
				endcase

				if(DIP[1] == 1'b1)
					begin
						TOPRED <= 8'b00000000;
					end
				else
					begin
						LED <= nextLED;
						TOPRED <= nextLED;
					end
				if(S1_NC == 1'b1)
					begin
						LED_YELLOW_L = 1'b1;
						JUMBO_Y = 1'b0;
					end
				else if(locked[1:0] == 2'b00)
					begin
						JUMBO_Y = 1'b1;
						LED_YELLOW_L = 1'b0;
            //self correcting  ring counter
						nextMid[7] <= mid[6];
						nextMid[6] <= mid[5];
						nextMid[5] <= mid[4];
						nextMid[4] <= mid[3];
						nextMid[3] <= mid[2];
						nextMid[2] <= mid[1];
						nextMid[1] <= mid[0];
						nextMid[0] <= !(mid[6] | mid[5] | mid[4] | mid[3] | mid[2] | mid[1] | mid[0]);
						BOTRED[7] = S2_NC;
            // check if input matches
						if(mid[7:0] == 8'b00000001)
							begin
								if(S2_NC == TOPRED[0])
									begin
										locked = 2'b11;
										nextState = 4'b0000;
										JUMBO_R = 1'b1;
									end
							end
						else if(mid[7:0] == 8'b00000010)
							begin
								if(S2_NC == TOPRED[1])
									begin
										locked = 2'b11;
										nextState = 4'b0000;
										JUMBO_R = 1'b1;
									end
							end
						else if(mid[7:0] == 8'b00000100)
							begin
								if(S2_NC == TOPRED[2])
									begin
										locked = 2'b11;
										nextState = 4'b0000;
										JUMBO_R = 1'b1;
									end
							end
						else if(mid[7:0] == 8'b00001000)
							begin
								if(S2_NC == TOPRED[3])
									begin
										locked = 2'b11;
										nextState = 4'b0000;
										JUMBO_R = 1'b1;
									end
							end
						else if(mid[7:0] == 8'b00010000)
							begin
								if(S2_NC == TOPRED[4])
									begin
										locked = 2'b11;
										nextState = 4'b0000;
										JUMBO_R = 1'b1;
									end
							end
						else if(mid[7:0] == 8'b00100000)
							begin
								if(S2_NC == TOPRED[5])
									begin
										locked = 2'b11;
										nextState = 4'b0000;
										JUMBO_R = 1'b1;
									end
							end
						else if(mid[7:0] == 8'b01000000)
							begin
								if(S2_NC == TOPRED[6])
									begin
										locked = 2'b11;
										nextState = 4'b0000;
										JUMBO_R = 1'b1;
									end
							end
						else if(mid[7:0] == 8'b10000000)
							begin
								if(S2_NC == TOPRED[7])
									begin
										locked = 2'b11;
										nextState = 4'b0000;
										JUMBO_R = 1'b1;
									end
								else
									begin
										locked = 2'b01;
										nextState = 4'b0000;
										JUMBO_G = 1'b1;
									end
							end
					end
				if(DIP[7] == 1'b1)
					begin
						locked[1:0] = 2'b00;
						nextState = 4'b0000;
						nextMid <= 8'b00000001;
						BOTRED <= 8'b00000000;
						JUMBO_Y = 1'b0;
						JUMBO_R = 1'b0;
						JUMBO_G = 1'b0;
					end

        // scrolling display:
				DIS4 <= DIS3;
				DIS3 <= DIS2;
				DIS2 <= DIS1;
				DIS1 <= D1;
				state <= nextState;
				mid <= nextMid;
				MIDRED <= mid;

			end
		end

endmodule
