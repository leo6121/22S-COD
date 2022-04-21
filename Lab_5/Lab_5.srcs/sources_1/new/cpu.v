`timescale 1ns/100ps

`include "opcodes.v"
`include "constants.v"

module cpu (
    output readM, // read from memory
    output writeM, // write to memory
    output [`WORD_SIZE-1:0] address, // current address for data
    inout [`WORD_SIZE-1:0] data, // data being input or output
    input inputReady, // indicates that data is ready from the input port
    input reset_n, // active-low RESET signal
    input clk, // clock signal
    
    // for debuging/testing purpose
    output [`WORD_SIZE-1:0] num_inst, // number of instruction during execution
    output [`WORD_SIZE-1:0] output_port, // this will be used for a "WWD" instruction
    output is_halted // 1 if the cpu is halted
);
    // ... fill in the rest of the code
    wire pcwritecond, pcwrite, memaddr, writedata, irwrite, regwrite, wwd, hlt;
    wire [3:0] aluop;
    wire [1:0] pcsource, alusrcA, alusrcB, regdst;
    wire [`WORD_SIZE-1:0] instruction;

    Datapath datapath (
        .clk(clk), 
        .reset_n(reset_n), 
        .data(data),
        .inputReady(inputReady),
        .PCWriteCond(pcwritecond),
        .PCWrite(pcwrite),
        .Memaddr(memaddr),
        .MemRead(readM),
        .MemWrite(writeM), 
        .Writedata(writedata), 
        .IRWrite(irwrite), 
        .PCSource(pcsource), 
        .ALUOp(aluop), 
        .ALUSrcA(alusrcA),
        .ALUSrcB(alusrcB), 
        .RegWrite(regwrite), 
        .RegDst(regdst), 
        .wwd(wwd), 
        .address(address),
        .output_port(output_port), 
        .instruction(instruction)
    );

    Control control(
        .clk(clk), 
        .reset_n(reset_n), 
        .instruction(instruction), 
        .PCWriteCond(pcwritecond),
        .PCWrite(pcwrite),
        .Memaddr(memaddr),
        .MemRead(readM),
        .MemWrite(writeM), 
        .Writedata(writedata), 
        .IRWrite(irwrite), 
        .PCSource(pcsource), 
        .ALUOp(aluop), 
        .ALUSrcA(alusrcA),
        .ALUSrcB(alusrcB), 
        .RegWrite(regwrite), 
        .RegDst(regdst), 
        .wwd(wwd),  
        .hlt(is_halted), 
        .num_inst(num_inst)
    );
endmodule
