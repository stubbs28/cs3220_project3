module Project2(SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
  input  [9:0] SW;
  input  [3:0] KEY;
  input  CLOCK_50;
  output [9:0] LEDR;
  output [7:0] LEDG;
  output [6:0] HEX0,HEX1,HEX2,HEX3;

  parameter ADDR_KEY             = 32'hF0000010;
  parameter ADDR_SW              = 32'hF0000014;
  parameter ADDR_HEX             = 32'hF0000000;
  parameter ADDR_LEDR            = 32'hF0000004;
  parameter ADDR_LEDG            = 32'hF0000008;
 

  parameter DBITS         				 = 32;
  parameter INST_BIT_WIDTH				 = 32;
  parameter START_PC       			   = 32'h40;
  parameter REG_INDEX_BIT_WIDTH 	 = 4;
 
  parameter IMEM_INIT_FILE				 = "Test2.mif";
  
  parameter IMEM_ADDR_BIT_WIDTH 		 = 11;
  parameter IMEM_DATA_BIT_WIDTH 		 = INST_BIT_WIDTH;
  parameter TRUE_DMEM_ADDR_BIT_WIDTH = 11;
  parameter DMEM_ADDR_BIT_WIDTH      = INST_BIT_WIDTH - 2;
  parameter DMEM_DATA_BIT_WIDTH      = INST_BIT_WIDTH;
  parameter IMEM_PC_BITS_HI     		 = IMEM_ADDR_BIT_WIDTH + 2;
  parameter IMEM_PC_BITS_LO     		 = 2;
  
  //PLL, clock genration, and reset generation
  wire clk, lock;
  PLL	PLL_inst (.inclk0 (CLOCK_50),.c0 (clk),.locked (lock));
  wire reset = ~lock;

  // Wires..
  wire pcWrtEn = 1'b1;
  wire flush, memtoReg, memWrite, branch, jal, alusrc, regWrite;
  wire memtoReg_m, memWrite_m, jal_m, regWrite_m;	// pipelineSplit - memory
  wire [7:0] aluControl, ledg;
  wire [9:0] ledr;
  wire [15:0] hex;
  wire [IMEM_DATA_BIT_WIDTH - 1 : 0] instWord;
  wire [DBITS - 1 : 0] pcIn, pcOut, incrementedPC, pcAdderOut, signExtImm;
  wire [DBITS - 1 : 0] dstReg, srReg1, srReg2, srOut1, srOut2;
  wire [DBITS - 1 : 0] dataFwdOut1, dataFwdOut2, aluMuxOut, aluOut;
  wire [DBITS - 1 : 0] dataMuxOut, memDataOut;
  wire [DBITS - 1 : 0] incrementedPC_m, dstReg_m, aluOut_m, dataFwdOut2_m; // pipelineSplit - memory
  
  assign flush = (branch & aluOut[0]) | jal_m;
  
  // Create PCMUX
  Mux3to1 #(DBITS) pcMux (
    .sel({jal_m, (branch & aluOut[0])}),
    .dInSrc1(incrementedPC),
    .dInSrc2(pcAdderOut),
    .dInSrc3(aluOut),
    .dOut(pcIn)
  );

  // This PC instantiation is your starting point
  Register #(DBITS, START_PC) pc (
    .clk(clk),
    .reset(reset),
    .wrtEn(pcWrtEn),
    .dataIn(pcIn),
    .dataOut(pcOut)
  );
  
  // Create PC Increament (PC + 4)
  PCIncrement pcIncrement (
    .dIn(pcOut),
    .dOut(incrementedPC)
  );
  
  // Create Instruction Memory
  InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMemory (
    .addr(pcOut[IMEM_PC_BITS_HI - 1 : IMEM_PC_BITS_LO]),
    .dataOut(instWord)
  );

  // Create Controller(SCProcController)
  SCProcController controller (
    .opcode({instWord[3:0],instWord[7:4]}),
    .aluControl(aluControl),
    .memtoReg(memtoReg),
    .memWrite(memWrite),
    .branch(branch), 
    .jal(jal),
    .alusrc(alusrc),
    .regWrite(regWrite)
  );
  
  // Get register addresses
  assign dstReg = instWord[31:28];
  assign srReg1 = (memWrite | branch) ? instWord[31:28] : instWord[27:24];
  assign srReg2 = (memWrite | branch) ? instWord[27:24] : instWord[23:20];

  // Create SignExtension
  SignExtension #(16, DBITS) signExtension (
    .dIn(instWord[23:8]),
    .dOut(signExtImm)
  );

  // Create pcAdder (incrementedPC + signExtImm << 2)
  PCAdder pcAdder (
    .dIn1(incrementedPC),
    .dIn2(signExtImm),
    .dOut(pcAdderOut)
  );

  // Create Dual Ported Register File
  RegisterFile #(DBITS, REG_INDEX_BIT_WIDTH) dprf (
    .clk(clk),
    .wrtEn(regWrite_m),
    .dIn(dataMuxOut),
    .dr(dstReg_m),
    .sr1(srReg1),
    .sr2(srReg2),
    .sr1Out(srOut1),
    .sr2Out(srOut2)
  );
  
  // Create DataFwdMux1 (Between DPRF and ALU)
  Mux2to1 #(DBITS) dataFwdMux1(
    .sel(((srReg1 == dstReg_m) && regWrite_m) ? 1'b1 : 1'b0),
	 .dInSrc1(srOut1),
	 .dInSrc2(dataMuxOut),
	 .dOut(dataFwdOut1)
  );
  
  Mux2to1 #(DBITS) dataFwdMux2(
    .sel(((srReg2 == dstReg_m) && regWrite_m) ? 1'b1 : 1'b0),
	 .dInSrc1(srOut2),
	 .dInSrc2(dataMuxOut),
	 .dOut(dataFwdOut2)
  );

  // Create AluMux (Between DPRF and ALU)
  Mux2to1 #(DBITS) aluMux (
    .sel(alusrc),
    .dInSrc1(dataFwdOut2),
    .dInSrc2(signExtImm),
    .dOut(aluMuxOut)
  );

  // Create ALU
  ALU alu (
    .dIn1(dataFwdOut1),
    .dIn2(aluMuxOut),
    .op1(aluControl[7:4]),
    .op2(aluControl[3:0]),
    .dOut(aluOut)
  );
  
  // Pipeline Split
  PipelineSplit #(DBITS) pipelineSplit (
    .clk(clk),
	 .flush(flush),
	 .memtoReg(memtoReg), 
	 .memWrite(memWrite), 
	 .jal(jal), 
	 .regWrite(regWrite), 
	 .incrementedPC(incrementedPC),
	 .dstReg(dstReg),
	 .aluOut(aluOut), 
	 .dataFwdOut2(dataFwdOut2), 
	 .memtoReg_m(memtoReg_m), 
	 .memWrite_m(memWrite_m), 
	 .jal_m(jal_m), 
	 .regWrite_m(regWrite_m), 
	 .incrementedPC_m(incrementedPC_m),
	 .dstReg_m(dstReg_m),
	 .aluOut_m(aluOut_m), 
	 .dataFwdOut2_m(dataFwdOut2_m)
  );
  
  // Create DataMemory
  DataMemory #(IMEM_INIT_FILE, DMEM_ADDR_BIT_WIDTH, DMEM_DATA_BIT_WIDTH, TRUE_DMEM_ADDR_BIT_WIDTH) dataMemory (
    .clk(clk),
    .wrtEn(memWrite_m),
    .addr(aluOut_m),
    .dIn(dataFwdOut2_m),
    .sw(SW),
    .key(KEY),
    .ledr(ledr),
    .ledg(ledg),
    .hex(hex),
    .dOut(memDataOut)
  );

  // Create dataMux
  Mux3to1 #(DBITS) dataMux (
    .sel({jal_m, memtoReg_m}),
    .dInSrc1(aluOut_m),
    .dInSrc2(memDataOut),
    .dInSrc3(incrementedPC_m),
    .dOut(dataMuxOut)
  );
  
  // Create SevenSeg for HEX3
  SevenSeg sevenSeg3 (
    .dIn(hex[15:12]),
    .dOut(HEX3)
  );

  // Create SevenSeg for HEX2
  SevenSeg sevenSeg2 (
    .dIn(hex[11:8]),
    .dOut(HEX2)
  );

  // Create SevenSeg for HEX1
  SevenSeg sevenSeg1 (
    .dIn(hex[7:4]),
    .dOut(HEX1)
  );

  // Create SevenSeg for HEX0
  SevenSeg sevenSeg0 (
    .dIn(hex[3:0]),
    .dOut(HEX0)
  );

  assign LEDR = ledr;
  assign LEDG = ledg;
  
endmodule
