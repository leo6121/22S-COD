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
`include "ALU.v"

module Control(instruction, RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, WWD);
    input [15:0] instruction;

    output reg RegDst;//write register 0 for rt, 1 for rd
    output reg Jump;// 0 for pc+1, 1 for pc[15:12]+target address
    output reg Branch;
    output reg MemRead;
    output reg MemtoReg;
    output reg MemWrite;
    output reg [1:0] ALUSrc;//aluinput2 0 for regdata2, 1 for sign-extended imm, 2 for imm<<8
    output reg RegWrite;//write enable
    output reg WWD;//1 for instruction is wwd
    output reg [3:0] ALUOp;//alu opcode

    wire [3:0] opcode = instruction[15:12];
    wire [5:0] func = instruction[5:0];
    reg [13:0] control;


    always @(*) begin
        case (opcode)
            //                       RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite ,WWD//
            4'd15:
            case (func)
                `FUNC_ADD:
                    assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     `OP_ADD,  1'b0,     2'b00,   1'b1,    1'b0};
                // `FUNC_SUB:
                // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     2'b00,   1'b1,    1'b0};
                // `FUNC_AND:
                // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     2'b00,   1'b1,    1'b0};
                // `FUNC_ORR:
                // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     2'b00,   1'b1,    1'b0};
                // `FUNC_NOT:
                // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     2'b00,   1'b1,    1'b0};
                // `FUNC_TCP:
                // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     2'b00,   1'b1,    1'b0};
                // `FUNC_SHL:
                // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     2'b00,   1'b1,    1'b0};
                // `FUNC_SHR:
                // assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     2'b00,   1'b1,    1'b0};
                6'd28://WWD
                    assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     `OP_ID,  1'b0,     2'b00,   1'b1,    1'b1};
                default:
                    assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     2'b00,   1'b0,    1'b0};
            endcase

            `OPCODE_ADI:
                assign control = {1'b1,   1'b0, 1'b0,   1'b0,    1'b0,     `OP_ADD,  1'b0,     2'b01,   1'b1,    1'b0};

            // `OPCODE_ORI:
            `OPCODE_LHI:
                assign control = {1'b1,   1'b0, 1'b0,   1'b0,    1'b0,     `OP_ID,  1'b0,     2'b10,   1'b1,    1'b0};
            // `OPCODE_LWD:
            // `OPCODE_SWD:
            // `OPCODE_BNE:
            // `OPCODE_BEQ:
            // `OPCODE_BGZ:
            // `OPCODE_BLZ:
            `OPCODE_JMP:
                assign control = {1'b1,   1'b1, 1'b0,   1'b0,    1'b0,      `OP_ID,  1'b0,     2'b00,   1'b1,    1'b0};
            // `OPCODE_JAL:
            default:
                assign control = {1'b0,   1'b0, 1'b0,   1'b0,    1'b0,     4'b0,  1'b0,     2'b00,   1'b0,    1'b0};


        endcase

        RegDst = control[13];
        Jump = control[12];
        Branch = control[11];
        MemRead = control [10];
        MemtoReg = control [9];
        ALUOp = control [8:5];
        MemWrite = control [4];
        ALUSrc = control [3:2];
        RegWrite = control [1];
        WWD = control[0];
    end
endmodule
