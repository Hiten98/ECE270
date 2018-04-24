Lab 13 individual equations:
HLT = !IR[6] & !IR[5] & !IR[4];  // opcode 000
LDA = !IR[6] & !IR[5] &  IR[4];	// opcode 001
ADD = !IR[6] &  IR[5] & !IR[4];	// opcode 010
SUB = !IR[6] &  IR[5] &  IR[4];	// opcode 011
AND =  IR[6] & !IR[5] & !IR[4];	// opcode 100
STA =  IR[6] & !IR[5] &  IR[4];	// opcode 101
INA =  IR[6] &  IR[5] & !IR[4];	// opcode 110
OUT =  IR[6] &  IR[5] &  IR[4];	// opcode 111

// from table on page 1 of handoout
ale = (ADD | SUB | AND | LDA | INA) & !sq;
alx = AND | LDA | INA;
aly = SUB | LDA | INA;

// from table on page 1 of handout
CF <= ((ale & (C[3] & !alx)) | !ale & ZF) | (alx & CF);
ZF <= (ale & !(ALU[3] | ALU[2] | ALU[1] | ALU[0])) | (!ale & ZF);
NF <= (ale & ALU[3]) | (!ale & NF);
VF <= (!ale & VF) | ((ale & (!alx & (C[2] ^ C[3])))) | (alx & VF);

//  !ale & AREG = if alu is not enabled, hold state
// if load, then load in values from db[3:0]
// if ADD or SUB, load in sum
// if AND, then AND ALU and DataBus
// if INA, then load in values from DIP switches
ALU = (!ale & AREG) | (LDA & DB[3:0]) | ((ADD | SUB) & SUM[3:0]) | (AND & (AREG[3:0] & DB[3:0])) | (INA & DIP[3:0]);
