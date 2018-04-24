module lab12_top (DIP, i_S1_NC, i_S1_NO, i_S2_NC, i_S2_NO, o_TOPRED, o_MIDRED, o_BOTRED, o_DIS1, o_DIS2, o_DIS3, o_DIS4, o_JUMBO, o_LED_YELLOW);

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
reg [6:0] rDIS1;
reg [6:0] rDIS2;
reg [6:0] rDIS3;
reg [6:0] rDIS4;
wire [6:0] wDIS1;
wire [6:0] wDIS2;
wire [6:0] wDIS3;
wire [6:0] wDIS4;
reg JUMBO_unused, JUMBO_R, JUMBO_Y, JUMBO_G;
reg LED_YELLOW_L, LED_YELLOW_R;

assign S1_NC = ~i_S1_NC;
assign S1_NO = ~i_S1_NO;
assign S2_NC = ~i_S2_NC;
assign S2_NO = ~i_S2_NO;
assign o_TOPRED = ~TOPRED;
assign o_MIDRED = ~MIDRED;
assign o_BOTRED = ~BOTRED;
assign o_DIS1 = (calc_en==1)?~wDIS1:~rDIS1;
assign o_DIS2 = (calc_en==1)?~wDIS2:~rDIS2;
assign o_DIS3 = (calc_en==1)?~wDIS3:~rDIS3;
assign o_DIS4 = (calc_en==1)?~wDIS4:~rDIS4;
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

// ====== DO NOT MODIFY ABOVE ====== //
// NOTE: The Displays need multiple drivers in the last step of this experiment.
//	 You might have to modify the declarations for DIS1 to DIS4.
//step1
  wire [7:0] temp_TR;
  button S2(.CLK(1'b0),.AR(S2_NC),.AP(S2_NO),.D(1'b0),.BFC(S2BC));
  /*cla4 step1(.X(DIP[7:4]),.Y(DIP[3:0]),.CIN(S2BC),.CF(temp_TR[7]),.NF(temp_TR[6]),.ZF(temp_TR[5]),.VF(temp_TR[4]),.S(temp_TR[3:0]));
  always@(DIP,S2BC)begin
  	TOPRED[3:0] = temp_TR[3:0];
  	TOPRED[7] = temp_TR[7];
  	TOPRED[6] = temp_TR[6];
  	TOPRED[5] = temp_TR[5];
  	TOPRED[4] = temp_TR[4];

  end
  */
  //step2
  //cla4 step2(.X(DIP[7:4]),.Y(DIP[3:0]),.CIN(1'b1),.CF(temp_TR[7]),.NF(temp_TR[6]),.ZF(temp_TR[5]),.VF(temp_TR[4]),.S(temp_TR[3:0]));
  wire XEQY = temp_TR[5];
  wire XGY = (temp_TR[4] & temp_TR[6]) | ((!temp_TR[4])&(!temp_TR[6])&(!temp_TR[5]));
  wire XLY = (temp_TR[4]^temp_TR[6]);
  always@(DIP)
    begin
    	TOPRED[3:0] = temp_TR[3:0];
    	TOPRED[7] = temp_TR[7];
    	TOPRED[6] = temp_TR[6];
    	TOPRED[5] = temp_TR[5];
    	TOPRED[4] = temp_TR[4];

      if(XGY==1)
        begin
      		JUMBO_G = 0;
      		JUMBO_Y = 1;
      		JUMBO_R = 0;
      	end
      else if(XEQY == 1)
        begin
        	JUMBO_G = 1;
        	JUMBO_Y = 0;
        	JUMBO_R = 0;
        end
      else if (XLY ==1)
        begin
      		JUMBO_G = 0;
      		JUMBO_Y = 0;
      		JUMBO_R = 1;
      	end
      if(DIP[7]==1)
      begin
    		TOPRED = 0;
    		JUMBO_G = 0;
    		JUMBO_Y = 0;
    		JUMBO_R = 0;
      end
    end
  //step3
  button S1(.CLK(1'b0),.AR(S1_NC),.AP(S1_NO),.D(1'b0),.BFC(S1BC));
  wire [3:0] temp_MR;
  LFSR step3(.CLK(S1BC),.AP(S2BC),.Q(temp_MR));
  always@(S1BC)
    begin
  	 if(DIP[7]==0)
  		 MIDRED[3:0] <= temp_MR;
  	 else
  		MIDRED = 0;
  end
  cla4 step3_2(.X(temp_MR),.Y(DIP[3:0]),.CIN(1'b1),.CF(temp_TR[7]),.NF(temp_TR[6]),.ZF(temp_TR[5]),.VF(temp_TR[4]),.S(temp_TR[3:0]));
  //step4
  reg [3:0] count;
  always @(posedge S1BC, posedge S2BC)
    begin
  	 if(S2BC == 1'b1)
  		 count <= 4'b0001;
  	 else if(count != 4'b1010)
  		 count <= count + 1;
    end
  assign wDIS4 =
    (count ==0)?char0:
    (count ==1)?char1:
    (count ==2)?char2:
    (count ==3)?char3:
    (count ==4)?char4:
    (count ==5)?char5:
    (count ==6)?char6:
    (count ==7)?char7:
    (count ==8)?char8:
    (count ==9)?char9: char9;

  assign calc_en = (count!=4'b1010);
  /*counter step4(.CLK(S1BC),.AR(S2BC),.Q(temp));
  always@(temp)begin
  	case(temp)
  		4'b0001: rDIS4 = char1; //1
  		4'b0010: rDIS4 = char2; //2
  		4'b0011: rDIS4 = char3; //3
  		4'b0100: rDIS4 = char4; //4
  		4'b0101: rDIS4 = char5; //5
  		4'b0110: rDIS4 = char6; //6
  		4'b0111: rDIS4 = char7; //7
  		4'b1000: rDIS4 = char8; //8
  		4'b1001: rDIS4 = char9; //9
  	endcase
  end*/
  //step5
  wire [4:0] Z;
  reg [7:0] total;

  assign Z = (XEQY)?({1'b0,total[3:0]}+5'b01001):(XGY)?({1'b0, total[3:0]}+5'b00100):{1'b0,total[3:0]};
  assign c =  Z[4] | (Z[3] & Z[2]) | (Z[3] & Z[1]);

  always @ (posedge S1BC, posedge S2BC) begin
  	if(S2BC == 1'b1) begin
  		total <= 8'b00000000;
  	end
  	else if(calc_en==1)begin
  		if(c)begin
  			total[3:0] <= Z[3:0] + 4'b0110;
  			total[7:4] <= total[7:4] + 4'b0001;
  		end
  		else begin
  			total[3:0] <= Z[3:0];
  			total[7:4] <= total[7:4];
  		end
  	end
  end

  assign wDIS1 =
  	(total[3:0] == 0)? char0:
  	(total[3:0] == 1)? char1:
  	(total[3:0] == 2)? char2:
  	(total[3:0] == 3)? char3:
  	(total[3:0] == 4)? char4:
  	(total[3:0] == 5)? char5:
  	(total[3:0] == 6)? char6:
  	(total[3:0] == 7)? char7:
  	(total[3:0] == 8)? char8:
  	(total[3:0] == 9)? char9: blank;

  assign wDIS2 =
  	(total[7:4] == 0)? char0:
  	(total[7:4] == 1)? char1:
  	(total[7:4] == 2)? char2:
  	(total[7:4] == 3)? char3:
  	(total[7:4] == 4)? char4:
  	(total[7:4] == 5)? char5:
  	(total[7:4] == 6)? char6:
  	(total[7:4] == 7)? char7:
  	(total[7:4] == 8)? char8:
  	(total[7:4] == 9)? char9: blank;

  //step6

  output reg CLK1;
  output reg CLK2;

  always @(posedge tmr_out)begin
  	CLK1 <= ~CLK1;
  end
  always @(posedge CLK1)begin
  	CLK2 <= ~CLK2;
  end
  always @(posedge CLK2,posedge S2BC)begin
  	if(S2BC == 1'b1)begin
  		rDIS1 <= blank;
   		rDIS2 <= blank;
  		rDIS3 <= blank;
  		rDIS4 <= blank;
  	end
  	else begin
  		rDIS1 <= nDIS;
   		rDIS2 <= rDIS1;
  		rDIS3 <= rDIS2;
  		rDIS4 <= rDIS3;
  	end
  end

  wire [1:0]M;
  reg [3:0]R;
  reg [3:0]next_R;
  output wire [6:0] nDIS;

  localparam B0 = 4'b0000;
  localparam B1 = 4'b0001;
  localparam B2 = 4'b0010;
  localparam B3 = 4'b0011;
  localparam B4 = 4'b0100;
  localparam B5 = 4'b0101;
  localparam B6 = 4'b0110;
  localparam B7 = 4'b0111;
  localparam B8 = 4'b1000;
  localparam B9 = 4'b1001;
  localparam B10 = 4'b1010;
  localparam B11 = 4'b1011;
  localparam B12 = 4'b1100;
  localparam B13 = 4'b1101;
  localparam B14 = 4'b1110;
  localparam B15 = 4'b1111;

  assign M[1] = (calc_en==0) & ((!total[7] & !total[5] & !total[4]) | (!total[7] & !total[6]));
  assign M[0] = (calc_en==0) & (total[7] | (total[6]&total[4])|(total[6]&total[5]));

  assign nDIS =
  	(R == 0)?blank:
  	(R == 1)?wDIS2:
  	(R == 2)?wDIS1:
  	(R == 3)?blank:
  	(R == 4)?charY:
  	(R == 5)?charE:
  	(R == 6)?charA:
  	(R == 7)?charH:
  	(R == 8)?blank:
  	(R == 9)?blank:
  	(R == 10)?charL:
  	(R == 11)?charO:
  	(R == 12)?charS:
  	(R == 13)?charE:
  	(R == 14)?charR:
  	(R == 15)?blank: blank;
  always @(posedge CLK2, posedge S2BC)begin
  	if(S2BC == 1'b1)
  		R<= 0;
  	else
  		R<=next_R;
  end
  always@(R,M)begin
  next_R = B0;
  	case(R)
  		B0: if(M!=2'b00) next_R = B1;
  		B1: if(M!=2'b00) next_R = B2;
  		B2: if(M!=2'b00) next_R = B3;
  		B3: begin
  			if(M==2'b01)next_R = B4;
  			else if (M==2'b10) next_R = B10;
  			end
  		B4: if(M==2'b01) next_R = B5;
  		B5: if(M==2'b01) next_R = B6;
  		B6: if(M==2'b01) next_R = B7;
  		B7: if(M==2'b01) next_R = B8;
  		B8: next_R = B9;
  		B9: next_R = B0;
  		B10: if(M==2'b10) next_R = B11;
  		B11: if(M==2'b10) next_R = B12;
  		B12: if(M==2'b10) next_R = B13;
  		B13: if(M==2'b10) next_R = B14;
  		B14: next_R = B8;
  	endcase
  end
  endmodule
  module button(CLK, AR, AP, D, BFC);
  input wire CLK; // Clock input for DFF
  input wire AR,AP; // Asynchronous Reset and Preset
  input wire D; // Data input for DFF
  output reg BFC; // Bounce Free Switch output
  always @ (posedge CLK, posedge AR, posedge AP) begin
  if (AR == 1'b1)
  BFC <= 0;
  else if (AP == 1'b1)
  BFC <= 1;
  else
  BFC <= D;
  end
endmodule
