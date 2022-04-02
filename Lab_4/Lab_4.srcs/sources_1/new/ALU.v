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
// Arithmetic
`define	OP_ADD	4'b0000
`define	OP_SUB	4'b0001
//  Bitwise Boolean operation
`define	OP_ID	4'b0010
`define	OP_NAND	4'b0011
`define	OP_NOR	4'b0100
`define	OP_XNOR	4'b0101
`define	OP_NOT	4'b0110
`define	OP_AND	4'b0111
`define	OP_OR	4'b1000
`define	OP_XOR	4'b1001
// Shifting
`define	OP_LRS	4'b1010
`define	OP_ARS	4'b1011
`define	OP_RR	4'b1100
`define	OP_LLS	4'b1101
`define	OP_ALS	4'b1110
`define	OP_RL	4'b1111

module ALU (OP, A, B, Cin, C, Cout);
    input [3:0] OP;
    input [15:0] A;
    input [15:0] B;
    input Cin;
    output reg [15:0] C;
    output reg Cout;

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

    always @(A, B, Cin, OP) begin
        case (OP)
            `OP_ADD : begin
                {Cout,C} = A+B+Cin;
            end
            `OP_SUB : begin
                {Cout,C} = A-B-Cin;
            end
            `OP_ID : begin
                Cout = 0;
                C = B;
            end
            `OP_NAND : begin
                Cout = 0;
                C = ~(A & B);
            end
            `OP_NOR : begin
                Cout = 0;
                C = ~(A | B);
            end
            `OP_XNOR : begin
                Cout = 0;
                C = ~(A ^ B);
            end
            `OP_NOT : begin
                Cout = 0;
                C = ~A;
            end
            `OP_AND : begin
                Cout = 0;
                C = A & B;
            end
            `OP_OR : begin
                Cout = 0;
                C = A | B;
            end
            `OP_XOR : begin
                Cout = 0;
                C = A ^ B;
            end
            `OP_LRS : begin
                Cout = 0;
                C = A >> 1;
            end
            `OP_ARS : begin
                Cout = 0;
                C = $signed(A) >>> 1;
            end
            `OP_RR : begin
                Cout = 0;
                C = {A[0], A[15:1]};
            end
            `OP_LLS : begin
                Cout = 0;
                C = A << 1;
            end
            `OP_ALS : begin
                Cout = 0;
                C = $signed(A) <<< 1;
            end
            `OP_RL : begin
                Cout = 0;
                C = {A[14:0], A[15]};
            end
        endcase
    end
endmodule
