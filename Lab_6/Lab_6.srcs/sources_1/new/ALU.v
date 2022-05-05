//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/03/08 11:44:45
// Design Name:
// Module Name: ALU
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

module ALU (OP, A, B, C, branchcond);
    input [3:0] OP;
    input [15:0] A;
    input [15:0] B;
    output reg [15:0] C;
    output reg branchcond;

    wire [15:0] signa;


    // wire [16:0] add, sub;

    // assign add = A + B + Cin;
    // assign sub = A - B - Cin;

    // assign C = (OP == `OP_ADD) ? add[15:0] :
    //            (OP == `OP_SUB) ? sub[15:0] :
    //            (OP == `OP_ID) ? A :
    //            (OP == `OP_NAND) ? ~(A & B) :
    //            (OP == `OP_NOR) ? ~(A | B) :
    //            (OP == `OP_XNOR) ? ~(A ^ B) :
    //            (OP == `OP_NOT) ? ~A :
    //            (OP == `OP_AND) ? A & B :
    //            (OP == `OP_OR) ? A | B :
    //            (OP == `OP_XOR) ? A ^ B :
    //            (OP == `OP_LRS) ? A >> 1 :
    //            (OP == `OP_ARS) ? $signed(A) >>> 1 :
    //            (OP == `OP_RR) ? {A[0], A[15:1]} :
    //            (OP == `OP_LLS) ? A << 1 :
    //            (OP == `OP_ALS) ? $signed(A) <<< 1 : {A[14:0], A[15]};

    // assign Cout = (OP == `OP_ADD) ? add[16] :
    //               (OP == `OP_SUB) ? sub[16] : 1'b0;

    always @(*) begin

        case (OP)
            `OP_ADD : begin
                C = A + B;
                branchcond = 0;
            end
            `OP_SUB : begin
                C = A - B;
                branchcond = 0;
            end
            `OP_IDA : begin
                C = A;
                branchcond = 0;
            end
            `OP_IDB : begin
                C = B;
                branchcond = 0;
            end
            `OP_LLS : begin
                C = A << 1;
                branchcond = 0;
            end
            `OP_XNOR : begin
                C = ~(A ^ B);
                branchcond = 0;
            end
            `OP_NOT : begin
                C = ~A;
                branchcond = 0;
            end
            `OP_AND : begin
                C = A & B;
                branchcond = 0;
            end
            `OP_OR : begin
                C = A | B;
                branchcond = 0;
            end
            `OP_XOR : begin
                C = A ^ B;
                branchcond = 0;
            end
            `OP_LRS : begin
                C = A >> 1;
                branchcond = 0;
            end
            `OP_TCP : begin
                C = ~A+1;
                branchcond = 0;
            end
            `OP_EQ : begin
                C = 16'b0;
                branchcond = (A == B) ? 1 : 0;
            end
            `OP_GZ : begin
                C = 16'b0;
                branchcond = ($signed(A) > 0) ? 1 : 0;
            end
            `OP_LZ : begin
                C = 16'b0;
                branchcond = ($signed(A) < 0) ? 1 : 0;
            end
            `OP_NE : begin
                C = 16'b0;
                branchcond = (A != B) ? 1 : 0;
            end
        endcase
    end
endmodule