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
  output reg readM,                       // read from memory
  output [`WORD_SIZE-1:0] address,    // current address for data
  inout [`WORD_SIZE-1:0] data,        // data being input or output
  input inputReady,                   // indicates that data is ready from the input port
  input reset_n,                      // active-low RESET signal
  input clk,                          // clock signal

  // for debuging/testing purpose
  output reg [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
  output reg [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
);

reg [`WORD_SIZE-1:0] pc;
wire regdst, jump, branch, memtoread, memtoreg, memwrite, alusrc, regwrite;
wire [3:0] aluop;
wire fin;
wire [15:0] readdata1;

Control ctrl(
    .instruction(data),
    .RegDst(regdst),
    .Jump(jump),
    .Branch(branch),
    .MemRead(memtoread),
    .MemtoReg(memtoreg),
    .ALUOP(aluop),
    .MemWrite(memwrite),
    .ALUSrc(alusrc),
    .RegWrite(write)
);

Datapath dp(
    .instruction(data),
    .clk(clk),
    .reset_n(reset_n),
    .write(RegWrite),
    .readdata1(readdata1),
    .fin(fin)
); 

always @(posedge clk) begin
    if(!reset_n) begin
        pc <= `WORD_SIZE'b0;
    end
    else begin
        if (fin) begin
            num_inst <= num_inst + 1;
            readM <= 1'b1;

            if(jump) begin
                pc <= {pc[15:12], data[11:0]};
            end
            else begin
                pc <= pc + 1;    
            end        
            if (data[15:12] == 4'd15 & data[5:0] == 6'd28) begin//WWD
                output_port <= readdata1;            
            end
        end
        else begin
            num_inst <= num_inst;
            readM <= 1'b0;
        end
    end
end

  // ... fill in the rest of the code

endmodule
//////////////////////////////////////////////////////////////////////////
