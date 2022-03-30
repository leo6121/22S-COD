`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/29 09:50:20
// Design Name: 
// Module Name: Control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "opcodes.v"

module Control(instruction, RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
input [15:0] instruction;

output reg RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
output reg [3:0] ALUOp;

wire [3:0] opcode = instruction[15:12];
wire [5:0] func = instruction[5:0];
reg [11:0] control;


always @(*) begin
    case (opcode)
            //         RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite// 
        4'd15:
        case (func)
            `FUNC_ADD:
            assign control = {1'b1,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1};
            // `FUNC_SUB:
            // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1};            
            // `FUNC_AND:
            // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1};
            // `FUNC_ORR:
            // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1};
            // `FUNC_NOT:
            // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1};
            // `FUNC_TCP:
            // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1};
            // `FUNC_SHL:
            // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1};
            // `FUNC_SHR: 
            // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1};
            6'd28://WWD
            assign control = {1'b1,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1}; 
            default: 
            assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b0};
        endcase

        `OPCODE_ADI:
            assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b1,   1'b1};

        // `OPCODE_ORI:
        `OPCODE_LHI:
            assign control = {1'b1,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1};
        // `OPCODE_LWD:
        // `OPCODE_SWD:
        // `OPCODE_BNE:
        // `OPCODE_BEQ:
        // `OPCODE_BGZ:
        // `OPCODE_BLZ:
        `OPCODE_JMP:
            assign control = {1'b0,   1'b1, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b1};
        // `OPCODE_JAL:
        default:
            assign control = {1'b1,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     1'b0,   1'b0};


    endcase

    RegDst = control[11]; 
    Jump = control[10];
    Branch = control[9];
    MemRead = control [8];
    MemtoReg = control [7];
    ALUOp = control [6:3];
    MemWrite = control [2];
    ALUSrc = control [1];
    RegWrite = control [0];
end
endmodule
