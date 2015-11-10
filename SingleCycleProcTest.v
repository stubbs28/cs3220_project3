`timescale 1 ns / 1 ns

module SingleCycleProcTest;

reg clk, reset;
reg[9:0] switches;
reg[3:0] keys;
wire[9:0] ledr;
wire[7:0] ledg;
wire[6:0] hex0, hex1, hex2, hex3;

integer i, counter;

always #10 clk = ~clk;

Project2 CPU(
    .SW     (switches),
    .KEY    (keys),
    .LEDR   (ledr),
    .LEDG   (ledg),
    .HEX0   (hex0),
    .HEX1   (hex1),
    .HEX2   (hex2),
    .HEX3   (hex3),
    .CLOCK_50(clk)
);

initial begin
    // Initialize instruction data
    for(i=0; i<256; i=i+1) begin
        CPU.instMemory.data[i] = 32'b0;
    end

    // Initialize data data
    for(i=0; i<32; i=i+1) begin
        CPU.dataMemory.data[i] = 32'b0;
    end

    // initialize Register File
    for(i=0; i<32; i=i+1) begin
        CPU.dprf.regs[i] = 32'b0;
    end

    CPU.dprf.regs[1] = 10;
    CPU.dprf.regs[2] = 20;

    // Load instructions into instruction data
    $readmemh("../instructions.txt", CPU.instMemory.data);

    counter = 0;
    clk = 0;
    reset = 1;

    $display("time\t clk  reset");
    $monitor("%g\t   %b    %b", $time, clk, reset);
    #10
    reset = 0;
end

always@(posedge clk) begin
    if(counter == 5)    // stop after 5 cycles
        $stop;

    $display("cycle = %d", counter);

    // print PC
    $display("PC = %d", CPU.pcOut[13:2]);
    $display("instr = %h", CPU.instMemory.data[CPU.pcOut[13:2]]);

    // print Registers
    $display("Registers");
    $display("R0 =%d, R8 =%d", CPU.dprf.regs[0], CPU.dprf.regs[8]);
    $display("R1 =%d, R9 =%d", CPU.dprf.regs[1], CPU.dprf.regs[9]);
    $display("R2 =%d, R10 =%d", CPU.dprf.regs[2], CPU.dprf.regs[10]);
    $display("R3 =%d, R11 =%d", CPU.dprf.regs[3], CPU.dprf.regs[11]);
    $display("R4 =%d, R12 =%d", CPU.dprf.regs[4], CPU.dprf.regs[12]);
    $display("R5 =%d, R13 =%d", CPU.dprf.regs[5], CPU.dprf.regs[13]);
    $display("R6 =%d, R14 =%d", CPU.dprf.regs[6], CPU.dprf.regs[14]);
    $display("R7 =%d, R15 =%d", CPU.dprf.regs[7], CPU.dprf.regs[15]);

    // print Data data
    $display("Data data: 0x00 =%d", {CPU.dataMemory.data[3] , CPU.dataMemory.data[2] , CPU.dataMemory.data[1] , CPU.dataMemory.data[0] });
    $display("Data data: 0x04 =%d", {CPU.dataMemory.data[7] , CPU.dataMemory.data[6] , CPU.dataMemory.data[5] , CPU.dataMemory.data[4] });
    $display("Data data: 0x08 =%d", {CPU.dataMemory.data[11], CPU.dataMemory.data[10], CPU.dataMemory.data[9] , CPU.dataMemory.data[8] });
    $display("Data data: 0x0c =%d", {CPU.dataMemory.data[15], CPU.dataMemory.data[14], CPU.dataMemory.data[13], CPU.dataMemory.data[12]});
    $display("Data data: 0x10 =%d", {CPU.dataMemory.data[19], CPU.dataMemory.data[18], CPU.dataMemory.data[17], CPU.dataMemory.data[16]});
    $display("Data data: 0x14 =%d", {CPU.dataMemory.data[23], CPU.dataMemory.data[22], CPU.dataMemory.data[21], CPU.dataMemory.data[20]});
    $display("Data data: 0x18 =%d", {CPU.dataMemory.data[27], CPU.dataMemory.data[26], CPU.dataMemory.data[25], CPU.dataMemory.data[24]});
    $display("Data data: 0x1c =%d", {CPU.dataMemory.data[31], CPU.dataMemory.data[30], CPU.dataMemory.data[29], CPU.dataMemory.data[28]});

    $display("\n");

    counter = counter + 1;
end


endmodule
