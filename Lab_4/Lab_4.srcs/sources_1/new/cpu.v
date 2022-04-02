///////////////////////////////////////////////////////////////////////////
// MODULE: CPU for TSC microcomputer: cpu.v
// Author:
// Description:

// DEFINITIONS
`define WORD_SIZE 16    // data and address word size

// INCLUDE files
`include "opcodes.v"    // "opcode.v" consists of "define" statements for
// the opcodes and function codes for all instructions

// MODULE DECLARATION
module cpu (
        output readM,                       // read from memory
        output [`WORD_SIZE-1:0] address,    // current address for data
        inout [`WORD_SIZE-1:0] data,        // data being input or output
        input inputReady,                   // indicates that data is ready from the input port
        input reset_n,                      // active-low RESET signal
        input clk,                          // clock signal

        // for debuging/testing purpose
        output reg [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
        output [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
    );

    reg [`WORD_SIZE-1:0] pc;
    wire [15:0] instruction;
    wire regdst, jump, branch, memtoread, memtoreg, memwrite, regwrite, wwd;
    wire [1:0] alusrc;
    wire [3:0] aluop;

    Control ctrl(
                .instruction(instruction),
                .RegDst(regdst),
                .Jump(jump),
                .Branch(branch),
                .MemRead(memtoread),
                .MemtoReg(memtoreg),
                .ALUOp(aluop),
                .MemWrite(memwrite),
                .ALUSrc(alusrc),
                .RegWrite(regwrite),
                .WWD(wwd)
            );

    Datapath dp(
                 .data(data),
                 .clk(clk),
                 .reset_n(reset_n),
                 .inputReady(inputReady),
                 .regdst(regdst),
                 .jump(jump),
                 .aluop(aluop),
                 .alusrc(alusrc),
                 .regwrite(regwrite),
                 .wwd(wwd),
                 .readM(readM),
                 .instruction(instruction),
                 .output_port(output_port),
                 .pc(address)
             );

    always @(posedge clk) begin
        if(!reset_n) begin
            num_inst <= `WORD_SIZE'b0;
        end
        else begin
            num_inst <= num_inst + 1;
        end
    end

    // ... fill in the rest of the code

endmodule
//////////////////////////////////////////////////////////////////////////
