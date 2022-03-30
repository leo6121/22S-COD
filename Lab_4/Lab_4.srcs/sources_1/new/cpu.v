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
        output reg [`WORD_SIZE-1:0] address,    // current address for data
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
    wire [`WORD_SIZE-1:0] readdata1;

    reg [`WORD_SIZE-1:0] instruction;

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
                .RegWrite(regwrite)
            );

    Datapath dp(
                 .instruction(instruction),
                 .clk(clk),
                 .reset_n(reset_n),
                 .write(regwrite),
                 .readdata1(readdata1),
                 .fin(fin)
             );

    always @(*) begin
        if(!reset_n) begin
            readM = 0;
            instruction = 0;
        end
        else if (inputReady) begin
            readM = 0;
            instruction = data;
        end
        else begin
            readM
            end
        end


        always @(posedge clk) begin
            if(!reset_n) begin
                readM <= 1'b0;
                address <= `WORD_SIZE'b0;
                num_inst <= `WORD_SIZE'b0;
                output_port <= `WORD_SIZE'b0;
            end
            else begin
                $display("output_port : %b, data : %h, jump : %b, readdata1 : %b", output_port, data, jump, readdata1);

                if (inputReady) begin
                    readM <= 1'b0;
                    output_port <= (data[15:12] == 4'd15 && data[5:0] == 6'd28) ? readdata1 : `WORD_SIZE'b0;
                    if(jump) begin
                        address <= {address[15:12], data[11:0]};
                    end
                    else begin
                        address <= address + 1;
                    end
                end
                else begin
                    readM <= 1'b1;
                    num_inst <= num_inst + 1;
                end



                // if (fin) begin

                // end
                // else begin
                //     num_inst <= num_inst;
                //     readM <= 1'b0;
                // end
            end
        end

        // ... fill in the rest of the code

    endmodule
    //////////////////////////////////////////////////////////////////////////
