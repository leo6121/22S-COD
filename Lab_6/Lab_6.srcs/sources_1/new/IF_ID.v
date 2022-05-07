`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/26 22:11:31
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(clk, reset_n, i_data, nextpc, predicted_pc, ifid_stall, ifid_flush, ifid_instruction, ifid_nextpc, ifid_predictpc);
    input clk;
    input reset_n;
    input [15:0] i_data;
    input [15:0] nextpc;
    input [15:0] predicted_pc;
    input ifid_stall;
    input ifid_flush;

    output reg [15:0] ifid_instruction;
    output reg [15:0] ifid_nextpc;
    output reg [15:0] ifid_predictpc;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n || ifid_flush) begin
            ifid_instruction <= 16'hb000;
            ifid_nextpc <= 0;
            ifid_predictpc <= 0;
        end
        else if(!ifid_stall) begin
            ifid_instruction <= i_data;
            ifid_nextpc <= nextpc;
            ifid_predictpc <= predicted_pc;
        end
    end
endmodule
