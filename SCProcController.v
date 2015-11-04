module SCProcController(opcode, aluControl, memtoReg, memWrite, branch, jal, alusrc, regWrite);
	input [7:0] opcode;
	output [7:0] aluControl;
	output memtoReg, memWrite, branch, jal, alusrc, regWrite;

	reg [13:0] ctrl;

	assign aluControl[7:0] = ctrl[13:6];
	assign memtoReg = ctrl[5];
	assign memWrite = ctrl[4];
	assign branch = ctrl[3];
	assign jal = ctrl[2];
	assign alusrc = ctrl[1];
	assign regWrite = ctrl[0];

	always @(*) begin
		if (opcode[4]) begin
			if (opcode[5]) ctrl <= {opcode, 6'b000111};			// JAL
			else if (opcode[6]) ctrl <= {opcode, 6'b010010};	// SW
			else ctrl <= {opcode, 6'b100011};						// LW
		end else if (opcode[7]) ctrl <= {opcode, 6'b000011};	// ALUI, CMPI 
		else if (opcode[6])	ctrl <= {opcode, 6'b001000};		// BCOND
		else ctrl <= {opcode, 6'b000001};							// ALUR, CMPR 
	end

endmodule


