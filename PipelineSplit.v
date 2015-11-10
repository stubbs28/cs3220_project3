module PipelineSplit (clk, flush, memtoReg, memWrite, jal, regWrite, incrementedPC, dstReg, aluOut, dataFwdOut2, memtoReg_m, memWrite_m, jal_m, regWrite_m, incrementedPC_m, dstReg_m, aluOut_m, dataFwdOut2_m);
	parameter DBITS = 32;
	
	input clk, flush, memtoReg, memWrite, jal, regWrite;
	input [DBITS - 1 : 0] incrementedPC, dstReg, aluOut, dataFwdOut2;
	output memtoReg_m, memWrite_m, jal_m, regWrite_m;
	output [DBITS - 1 : 0] incrementedPC_m, dstReg_m, aluOut_m, dataFwdOut2_m;
	
	reg memtoReg_reg, memWrite_reg, jal_reg, regWrite_reg;
	reg [DBITS - 1 : 0] incrementedPC_reg, dstReg_reg, aluOut_reg, dataFwdOut2_reg;
	
	always @(posedge clk) begin
		memtoReg_reg <= memtoReg;
		memWrite_reg <= memWrite;
		jal_reg <= jal;
		regWrite_reg <= regWrite;
		incrementedPC_reg <= incrementedPC;
		dstReg_reg <= dstReg;
		aluOut_reg <= aluOut;
		dataFwdOut2_reg <= dataFwdOut2;
		if (flush) begin
			memWrite_reg <= 1'b0;
			regWrite_reg <= 1'b0;
		end
	end
	
	assign memtoReg_m = memtoReg_reg;
	assign memWrite_m = memWrite_reg;
	assign jal_m = jal_reg;
	assign regWrite_m = regWrite_reg;
	assign incrementedPC_m = incrementedPC_reg;
	assign dstReg_m = dstReg_reg;
	assign aluOut_m = aluOut_reg;
	assign dataFwdOut2_m = dataFwdOut2_reg;

endmodule