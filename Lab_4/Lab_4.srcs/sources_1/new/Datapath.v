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


module Datapath(data, clk, reset_n, inputReady, regdst, jump, aluop, alusrc, regwrite, wwd, readM, instruction, output_port, pc);
    input [15:0] data;
    input clk;
    input reset_n;
    input inputReady;
    input regdst;
    input jump;
    input [3:0] aluop;
    input [1:0] alusrc;
    input regwrite;
    input wwd;
    output reg readM;
    output reg [15:0] instruction;
    output reg [15:0] output_port;
    output reg [15:0] pc;


    wire [15:0] regdata1, regdata2, writedata;
    wire [1:0] rs, rd, rt, writeregaddr;

    assign rs = instruction[11:10];
    assign rd = instruction[9:8];
    assign rt = instruction[7:6];
    assign writeregaddr = (regdst) ? rd : rt;

    RF rf(
           .clk(clk),
           .reset_n(reset_n),
           .write(regwrite),
           .addr1(rs),
           .addr2(rd),
           .addr3(writeregaddr),
           .data3(writedata),
           .data1(regdata1),
           .data2(regdata2)
       );

    wire cout;
    wire [15:0] aluinput1, aluinput2;
    assign aluinput1 = regdata1;
    assign aluinput2 = (alusrc == 2'd1) ? {{8{instruction[7]}}, instruction[7:0]} :
           (alusrc == 2'd2) ? {instruction[7:0], 8'b0} : regdata2;

    ALU alu(
            .OP(aluop),
            .A(aluinput1),
            .B(aluinput2),
            .Cin(1'b0),
            .C(writedata),
            .Cout(cout)
        );

    //instruction fetch
    always @(posedge clk or negedge reset_n or posedge inputReady) begin
        if(!reset_n) begin
            instruction <= `WORD_SIZE'b0;
            readM <= 1'b0;
        end
        else if(inputReady) begin
            instruction <= data;
            readM <= 1'b0;
        end
        else begin
            instruction <= `WORD_SIZE'b0;
            readM <= 1'b1;
        end

    end

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            pc <= 0;
            output_port <= 0;
        end
        else begin
            pc <= (jump) ? {pc[15:12], instruction[11:0]} : pc+1;
            output_port <= (wwd) ? regdata1 : 0;
        end
    end
endmodule
