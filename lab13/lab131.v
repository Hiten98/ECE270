module lab13 (DIP, i_S1_NC, i_S1_NO, i_S2_NC, i_S2_NO, o_TOPRED, o_MIDRED, o_BOTRED, o_DIS1, o_DIS2, o_DIS3, o_DIS4, o_JUMBO, o_LED_YELLOW);

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

// ====== DO NOT MODIFY ABOVE ======
// 16 * 7 bit memory array
reg [6:0] MEM[15:0];

// memory clocking signal
wire memclk;

// CPU clocking signal
wire cpuclk;

// CPU Asynchronous reset (Start)
wire start;

// Run/Start state
reg run;

// State Counter (Fetch/Execute)
reg sq;

// Address bus
wire [3:0] AB;

// Program Counter
reg [3:0] PC;
wire [3:0] PC_w; // used for "pc_block" module output connection


// Program Counter Enable
wire pcc;
assign pcc = !sq;

// Instruction Register
reg [6:0] IR;
wire [6:0] IR_w;  // used for "ir_block" module output connection

// IR Enable
wire irl;
assign irl = !sq;

// Airthematic Logic Unit
wire ale,alx,aly;  // MODE selects
wire [3:0] ALU;

// Accumulator (A) register
reg [3:0] AREG;

// CPU data bus
wire [6:0] DB;

// Memory Display bus
wire [6:0] DM;

// Memory address register
reg [3:0] MAR;

// Output Port
reg [3:0] OUTP;

// CLA Variables
wire CIN;
assign CIN = aly;

wire [3:0] SUM; // Sum bits
wire [3:0] C; // Carry bits
wire [3:0] P; // Propagate functions
wire [3:0] G; // Generate functions

// Condition Code Register
reg CF,NF,ZF,VF;

wire HLT,LDA,ADD,SUB,STA,INA,OUT;

// RAULMATIC 716 opcode definitions
// Complete using the RAULMATIC 716 Instruction Set  in the lab document

assign HLT = !IR[6] & !IR[5] & !IR[4];  // opcode 000
assign LDA = !IR[6] & !IR[5] &  IR[4];	// opcode 001
assign ADD = !IR[6] &  IR[5] & !IR[4];	// opcode 010
assign SUB = !IR[6] &  IR[5] &  IR[4];	// opcode 011
assign AND =  IR[6] & !IR[5] & !IR[4];	// opcode 100
assign STA =  IR[6] & !IR[5] &  IR[4];	// opcode 101
assign INA =  IR[6] &  IR[5] & !IR[4];	// opcode 110
assign OUT =  IR[6] &  IR[5] &  IR[4];	// opcode 111


// **************************************************** //

// Bounceless Switches
wire S1BC, S2BC;

// Write a module "bounceless_switch" with the below signals and implement two Bouncefree switches "RIGHTPB" and "LEFTPB"

bounceless RIGHTPB(.CLK(1'b0), .AR(S1_NC), .AP(S1_NO), .D(1'b0), .Q(S1BC));
bounceless LEFTPB (.CLK(1'b0), .AR(S2_NC), .AP(S2_NO), .D(1'b0), .Q(S2BC));

always @(S1BC, S2BC) begin
	LED_YELLOW_R = S1BC;
	LED_YELLOW_L = S2BC;
end

// CPU clk
assign cpuclk = DIP[7] & S1BC & run;

// CPU asynchronous reset (START)
assign start = DIP[7] & S2BC;

// Memory (write) clock
assign memclk = (S2BC & !DIP[7]) | (DIP[7] & S1BC);

// Memory edit / Run Dtatus indicators
always @(DIP[7]) begin
	JUMBO_Y = !DIP[7]; // MEM EDIT MODE   	DIP[7] == 0
	JUMBO_G =  DIP[7]; // RUN MODE 		DIP[7] == 1
end

// Memory address register for edit mode

always @(posedge S1BC or posedge start ) begin
	if (start == 1)
		MAR <= 0;
	else if (DIP[7] == 0)
		MAR <= MAR+1;
end

// Memory Edit data bus

assign DM  =    (MAR == 0) ? MEM[0]:
		(MAR == 1) ? MEM[1]:
		(MAR == 2) ? MEM[2]:
		(MAR == 3) ? MEM[3]:
		(MAR == 4) ? MEM[4]:
		(MAR == 5) ? MEM[5]:
		(MAR == 6) ? MEM[6]:
		(MAR == 7) ? MEM[7]:
		(MAR == 8) ? MEM[8]:
		(MAR == 9) ? MEM[9]:
		(MAR == 10) ? MEM[10]:
		(MAR == 11) ? MEM[11]:
		(MAR == 12) ? MEM[12]:
		(MAR == 13) ? MEM[13]:
		(MAR == 14) ? MEM[14]:
		(MAR == 15) ? MEM[15]:DM;


// CPU Data bus

assign DB  =    (AB == 0) ? MEM[0]:
		(AB == 1) ? MEM[1]:
		(AB == 2) ? MEM[2]:
		(AB == 3) ? MEM[3]:
		(AB == 4) ? MEM[4]:
		(AB == 5) ? MEM[5]:
		(AB == 6) ? MEM[6]:
		(AB == 7) ? MEM[7]:
		(AB == 8) ? MEM[8]:
		(AB == 9) ? MEM[9]:
		(AB == 10) ? MEM[10]:
		(AB == 11) ? MEM[11]:
		(AB == 12) ? MEM[12]:
		(AB == 13) ? MEM[13]:
		(AB == 14) ? MEM[14]:
		(AB == 15) ? MEM[15]:DB;

// CPU Address bus
assign AB = (DIP[7] == 0)? MAR: ((DIP[7] == 1) & (sq == 1))? IR[3:0]:((DIP[7] == 1) & (sq == 0))? PC[3:0]: AB;


// Memory Next state equations

always @(posedge memclk) begin
	if (DIP[7] == 0) MEM[AB] <= DIP[6:0];
	else if (DIP[7] == 1) begin
 		if (STA & sq) MEM[AB] <= {3'b0,AREG[3:0]};
	end
end

// State Counter
always @(posedge cpuclk or posedge start) begin
	if (start == 1)
		sq <= 0;
	else
		sq <= !sq;
end
// LED assignment
always @(sq) begin
	MIDRED[7] = sq;
end

// RUN/STOP

always @(start or  sq) begin
	if (start == 1) run = 1;
	else if ((sq == 1) & (HLT == 1)) run = 0; // do we need else if or only if
end

always @(run) begin
	JUMBO_R = !run;
end


// Program Counter
// Write a module "pc_block" with the below description and signals to implement PC function.
pc_block PC_instance (.CLK(cpuclk),.AR(start),.EN(pcc),.OUT(PC_w));


// Instruction Register
// Write a module "ir_block" with the below description and signals to implement IR function.
ir_block IR_instance (.CLK(cpuclk),.AR(start),.EN(irl),.DATA(DB),.OUT(IR_w));

// Assignmet to Registers
always @(PC_w) begin
	PC = PC_w;
end

always @(IR_w) begin
	IR = IR_w;
end

//
always @(IR) begin
	MIDRED[6:0] = IR[6:0];
end


// Arithmetic logic unit - control signals
// Complete the below Dataflow assignments
assign ale = (ADD | SUB | AND | LDA | INA) & !sq;
assign alx = AND | LDA | INA;
assign aly = SUB | LDA | INA;


// Arithmetic logic unit - CLA
assign P[3:0] = (aly == 1) ? (AREG[3:0] ^  ~DB[3:0]): (AREG[3:0] ^ DB[3:0]);
assign G[3:0] = (aly == 1) ? (AREG[3:0] &  ~DB[3:0]): (AREG[3:0] & DB[3:0]);
assign C[0] = G[0] | (CIN&P[0]);
assign C[1] = G[1] | G[0]&P[1] | CIN&P[0]&P[1];
assign C[2] = G[2] | G[1]&P[2] | G[0]&P[1]&P[2] | CIN&P[0]&P[1]&P[2];
assign C[3] = G[3] | G[2]&P[3] | G[1]&P[2]&P[3] | G[0]&P[1]&P[2]&P[3] | CIN&P[0]&P[1]&P[2]&P[3];

assign SUM[0] = CIN  ^  P[0];
assign SUM[1] = C[0] ^  P[1];
assign SUM[2] = C[1] ^  P[2];
assign SUM[3] = C[2] ^  P[3];

// ALU Condition code register

always @(posedge cpuclk, posedge start) begin
	if (start == 1) begin
		CF <= 1'b0;
		ZF <= 1'b0;
		NF <= 1'b0;
		VF <= 1'b0;
	end
	else begin
// Complete the condition codes
		CF <= ((ale & (C[3] & !alx)) | !ale & ZF) | (alx & CF);
		ZF <= (ale & !(ALU[3] | ALU[2] | ALU[1] | ALU[0])) | (!ale & ZF);
		NF <= (ale & ALU[3]) | (!ale & NF);
		VF <= (!ale & VF) | ((ale & (!alx & (C[2] ^ C[3])))) | (alx & VF);
	end
end

always @(CF,NF,ZF,VF) begin
	TOPRED[7] = CF;
	TOPRED[6] = NF;
	TOPRED[5] = ZF;
	TOPRED[4] = VF;
end

// ALU Combinational outputs
// Complete the ALU equation (use alx, aly and opcodes if required)
assign ALU = (!ale & AREG) | (LDA & DB[3:0]) | ((ADD | SUB) & SUM[3:0]) | (AND & (AREG[3:0] & DB[3:0])) | (INA & DIP[3:0]);



// Accumulator register
always @(posedge cpuclk, posedge start) begin
	if (start == 1) AREG <= 0;
	else if (ale) AREG <= ALU;
end

always @(AREG) begin
	TOPRED[3:0]  = AREG[3:0];
end

// input port

always @(DIP[7], DIP[3:0]) begin
	if (DIP[7] == 1)
		BOTRED[3:0] = DIP[3:0];
	else
		BOTRED[3:0] = 0;
end

// output port
always @(posedge cpuclk, posedge start) begin
	if (start == 1) OUTP <= 0;
	else if (sq&OUT) OUTP <= AREG;
end

always @(OUTP) begin
	BOTRED[7:4] = OUTP;
end

// 7 segment display decoding
always @(MAR) begin
	case (MAR)
		4'b0000: DIS3[6:0] = char0;
		4'b0001: DIS3[6:0] = char1;
		4'b0010: DIS3[6:0] = char2;
		4'b0011: DIS3[6:0] = char3;
		4'b0100: DIS3[6:0] = char4;
		4'b0101: DIS3[6:0] = char5;
		4'b0110: DIS3[6:0] = char6;
		4'b0111: DIS3[6:0] = char7;
		4'b1000: DIS3[6:0] = char8;
		4'b1001: DIS3[6:0] = char9;
		4'b1010: DIS3[6:0] = charA;
		4'b1011: DIS3[6:0] = charB;
		4'b1100: DIS3[6:0] = charC;
		4'b1101: DIS3[6:0] = charD;
		4'b1110: DIS3[6:0] = charE;
		4'b1111: DIS3[6:0] = charF;
	endcase
end

always @(DM) begin
	case (DM[6:4])
		3'b000: DIS2[6:0] = char0;
		3'b001: DIS2[6:0] = char1;
		3'b010: DIS2[6:0] = char2;
		3'b011: DIS2[6:0] = char3;
		3'b100: DIS2[6:0] = char4;
		3'b101: DIS2[6:0] = char5;
		3'b110: DIS2[6:0] = char6;
		3'b111: DIS2[6:0] = char7;
	endcase

	case (DM[3:0])
		4'b0000: DIS1[6:0] = char0;
		4'b0001: DIS1[6:0] = char1;
		4'b0010: DIS1[6:0] = char2;
		4'b0011: DIS1[6:0] = char3;
		4'b0100: DIS1[6:0] = char4;
		4'b0101: DIS1[6:0] = char5;
		4'b0110: DIS1[6:0] = char6;
		4'b0111: DIS1[6:0] = char7;
		4'b1000: DIS1[6:0] = char8;
		4'b1001: DIS1[6:0] = char9;
		4'b1010: DIS1[6:0] = charA;
		4'b1011: DIS1[6:0] = charB;
		4'b1100: DIS1[6:0] = charC;
		4'b1101: DIS1[6:0] = charD;
		4'b1110: DIS1[6:0] = charE;
		4'b1111: DIS1[6:0] = charF;
	endcase
end

always @(PC) begin
	case (PC)
		4'b0000: DIS4[6:0] = char0;
		4'b0001: DIS4[6:0] = char1;
		4'b0010: DIS4[6:0] = char2;
		4'b0011: DIS4[6:0] = char3;
		4'b0100: DIS4[6:0] = char4;
		4'b0101: DIS4[6:0] = char5;
		4'b0110: DIS4[6:0] = char6;
		4'b0111: DIS4[6:0] = char7;
		4'b1000: DIS4[6:0] = char8;
		4'b1001: DIS4[6:0] = char9;
		4'b1010: DIS4[6:0] = charA;
		4'b1011: DIS4[6:0] = charB;
		4'b1100: DIS4[6:0] = charC;
		4'b1101: DIS4[6:0] = charD;
		4'b1110: DIS4[6:0] = charE;
		4'b1111: DIS4[6:0] = charF;
	endcase
end


endmodule
