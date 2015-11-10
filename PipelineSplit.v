module PipelineSplit (clk, memtoReg, memWrite, jal, regWrite, incrementedPC, aluOut, sr2Out, memtoReg_m, memWrite_m, jal_m, regWrite_m, incrementedPC_m, aluOut_m, sr2Out_m);
	parameter DBITS = 32;
	
	input clk, memtoReg, memWrite, jal, regWrite;
	input [DBITS - 1 : 0] incrementedPC, aluOut, sr2Out;
	output memtoReg_m, memWrite_m, jal_m, regWrite_m;
	output [DBITS - 1 : 0] incrementedPC_m, aluOut_m, sr2Out_m;
	
	reg memtoReg_reg, memWrite_reg, jal_reg, regWrite_reg;
	reg [DBITS - 1 : 0] incrementedPC_reg, aluOut_reg, sr2Out_reg;
	
	always @(posedge clk) begin
		memtoReg_reg <= memtoReg;
		memWrite_reg <= memWrite;
		jal_reg <= jal;
		regWrite_reg <= regWrite;
		incrementedPC_reg <= incrementedPC;
		aluOut_reg <= aluOut;
		sr2Out_reg <= sr2Out;
	end
	
	assign memtoReg_m = memtoReg_reg;
	assign memWrite_m = memWrite_reg;
	assign jal_m = jal_reg;
	assign regWrite_m = regWrite_reg;
	assign incrementedPC_m = incrementedPC_reg;
	assign aluOut_m = aluOut_reg;
	assign sr2Out_m = sr2Out_reg;

endmodule