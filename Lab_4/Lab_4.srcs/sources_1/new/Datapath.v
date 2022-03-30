`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/03/29 11:31:13
// Design Name:
// Module Name: Datapath
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
`define WORD_SIZE 16    // data and address word size


module Datapath(instruction, clk, reset_n, write, readdata1, fin);
    input [15:0] instruction;
    input clk;
    input reset_n;
    input write;
    output [15:0] readdata1;
    output reg fin; // Alu calculation finish

    wire [3:0] op;
    wire [15:0] aluresult, aluinput1, aluinput2, data1, data2, data3;
    wire cin, cout, write_enable;
    wire [1:0] addr1, addr2, addr3;
    reg alufin, rffin;

    ALU alu(
            .OP(op),
            .A(aluresult),
            .B(aluinput1),
            .Cin(cin),
            .C(aluinput2),
            .Cout(cout)
        );

    RF rf(
           .clk(clk),
           .reset_n(reset_n),
           .write(write_enable),
           .addr1(addr1),
           .addr2(addr2),
           .addr3(addr3),
           .data3(data3),
           .data1(data1),
           .data2(data2)
       );

    assign op = instruction[15:12];
    assign addr1 = instruction[11:10];
    assign addr2 = instruction[9:8];
    assign addr3 = instruction[7:6];
    assign aluinput1 = data1;
    assign aluinput2 = data2;
    assign data3 = aluresult;
    assign write_enable = write;

    assign readdata1 = data1;

endmodule
