`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/05 21:18:12
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

`include "opcodes.v"
`include "constants.v"

module Datapath(clk, reset_n, data, inputReady, PCWriteCond, PCWrite, Memaddr, MemRead, MemWrite, Writedata, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst, wwd, address, output_port, instruction);
    input clk;
    input reset_n;
    inout [15:0] data;
    input inputReady;

    input PCWriteCond;//1 for branch instruction
    input PCWrite;//1 for update pc 
    input Memaddr;//o for pc, 1 for aluout
    input MemRead;//1 for load instruction
    input MemWrite;//1 for store instruction
    input Writedata;//0 for aluout, 1 for Memory data
    input IRWrite;// 1 for instruction fetching
    input [1:0] PCSource;//0 for aluresult, 1 for pc[15:12]+target[11:0], 2 for regdata1
    input [3:0] ALUOp;//ALU opcode
    input [1:0] ALUSrcA;// 0 for regdata1, 1 for pc, 2 for aluout
    input [1:0] ALUSrcB;// 0 for regdata2, 1 for 1(use when pc <= pc+1 and JAL inst), 2 for sign-extend
    input RegWrite;//1 for RF write_enable
    input [1:0] RegDst;//0 for rt, 1 for rd, 2 for $2
    input wwd;//1 for wwd instruction
    
    output [`WORD_SIZE-1:0] address;
    output reg [`WORD_SIZE-1:0] output_port;
    output reg [`WORD_SIZE-1:0] instruction;
    
    reg [`WORD_SIZE-1:0] pc;
    reg [`WORD_SIZE-1:0] aluout_buffer, memorydata, pc_buffer;
    wire [`WORD_SIZE-1:0] regdata1, regdata2, writedata, aluout;
    wire [1:0] rs, rt, rd, regdst;
    wire branch;

    assign address = (Memaddr) ? aluout_buffer : pc;

    assign rs = instruction[11:10];
    assign rt = instruction[9:8];
    assign rd = instruction[7:6];
    assign regdst = (RegDst == 2'd2) ? 2'd2 :
                    (RegDst == 2'd1) ? rd :
                    (RegDst == 2'd0) ? rt : rt;
    assign writedata = (Writedata) ? memorydata : aluout_buffer;

    RF rf (
        .clk(clk),
        .reset_n(reset_n),
        .write(RegWrite),
        .addr1(rs),
        .addr2(rt),
        .addr3(regdst),
        .data3(writedata),
        .data1(regdata1),
        .data2(regdata2)
    );
    
    wire [`WORD_SIZE-1:0] signextend;

    assign signextend = (instruction[15:12] == `OPCODE_LHI) ? {instruction[7:0], 8'b0} :
                         (instruction[15:12] == `OPCODE_ORI) ? {8'b0, instruction[7:0]} : {{8{instruction[7]}}, instruction[7:0]};
 
    wire [`WORD_SIZE-1:0] aluinput1, aluinput2;
    assign aluinput1 = (ALUSrcA == 2'd0) ? regdata1 :
                       (ALUSrcA == 2'd1) ? pc :
                       (ALUSrcA == 2'd2) ? aluout_buffer : regdata1;
    assign aluinput2 = (ALUSrcB == 2'd0) ? regdata2 :
                       (ALUSrcB == 2'd1) ? 16'b1 :
                       (ALUSrcB == 2'd2) ? signextend : regdata2;

    ALU alu (
        .OP(ALUOp),
        .A(aluinput1),
        .B(aluinput2),
        .C(aluout),
        .branchcond(branch)
    );

    assign data = (MemWrite) ? regdata2 : `WORD_SIZE'bz;
    //instruction fetching
    always @(posedge inputReady or negedge reset_n) begin
        if (!reset_n) begin
            instruction <= `WORD_SIZE'b0;
        end
        else if(IRWrite) begin
            instruction <= data;
        end
    end
    //aluout_buffer
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            aluout_buffer <= `WORD_SIZE'b0;     
        end
        else begin
           aluout_buffer <= aluout;
        end
    end

    //memorydata
    always @(posedge inputReady or negedge reset_n) begin
        if(!reset_n) begin
            memorydata <= `WORD_SIZE'b0;
        end
        else begin
           memorydata <= data; 
        end
    end
    //PC
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc <= `WORD_SIZE'b0;
        end
        else if(PCWrite) begin
            pc <= (PCSource == 2'd0) ? aluout :
                  (PCSource == 2'd1) ? {pc[15:12], instruction[11:0]} :
                  (PCSource == 2'd2) ? regdata1 : pc;
        end
        else if(branch && PCWriteCond) begin
            pc <= (PCSource == 2'd0) ? aluout_buffer :
                  (PCSource == 2'd1) ? {pc[15:12], instruction[11:0]} :
                  (PCSource == 2'd2) ? regdata1 : pc;
        end
    end

    //output_port
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            output_port <= `WORD_SIZE'b0;
        end
        else if(wwd) begin
            output_port <= regdata1;
        end
    end
    

endmodule
