`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

`include "opcodes.v"

module cpu(
        input clk, 
        input reset_n, 

	// Instruction memory interface
        output i_readM, 
        output i_writeM, 
        output [`WORD_SIZE-1:0] i_address, 
        inout [63:0] i_data, 

	// Data memory interface
        output d_readM, 
        output d_writeM, 
        output [`WORD_SIZE-1:0] d_address, 
        inout [63:0] d_data, 

        output [`WORD_SIZE-1:0] num_inst, 
        output [`WORD_SIZE-1:0] output_port, 
        output is_halted
);

	// TODO : Implement your multi-cycle CPU!
        wire [6:0] ex_signal;
        wire [4:0] mem_signal;
        wire [5:0] wb_signal;
        wire [15:0] instruction;
        wire use_rs, use_rt;

        Datapath datapath(
                .clk(clk),
                .reset_n(reset_n),
                .i_data(i_data),
                .d_data(d_data),
                .ex_signal(ex_signal),
                .mem_signal(mem_signal),
                .wb_signal(wb_signal),
                .use_rs(use_rs),
                .use_rt(use_rt),
                .instruction(instruction),
                .d_address(d_address),
                .i_address(i_address),
                .output_port(output_port),
                .num_inst(num_inst),
                .is_halted(is_halted),
                .i_readM(i_readM),
                .d_readM(d_readM),
                .d_writeM(d_writeM)
        );

        Control control(
                .clk(clk),
                .reset_n(reset_n),
                .instruction(instruction),
                .ex_signal(ex_signal),
                .mem_signal(mem_signal),
                .wb_signal(wb_signal),
                .use_rs(use_rs),
                .use_rt(use_rt)
        );

        assign i_writeM = 0;

        


endmodule
