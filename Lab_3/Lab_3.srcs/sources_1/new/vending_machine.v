`timescale 100ps / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/03/21 12:37:06
// Design Name:
// Module Name: vending_machine
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

// Title         : vending_machine.v
// Author      : Hunjun Lee (hunjunlee7515@snu.ac.kr), Suheon Bae (suheon.bae@snu.ac.kr)

`include "vending_machine_def.v"

module vending_machine (clk, reset_n, i_input_coin, i_select_item, i_trigger_return, o_available_item, o_current_total, o_output_item, o_return_coin);

    // clk,					    	// Clock signal
    // reset_n,						// Reset signal (active-low)

    // i_input_coin,				// coin is inserted.
    // i_select_item,				// item is selected.
    // i_trigger_return,			// change-return is triggered

    // o_available_item,			// Sign of the item availability
    // o_output_item,			   // Sign of the item withdrawal
    // o_return_coin,			   // Sign of the coin return
    // o_current_total

    // Ports Declaration
    input clk;
    input reset_n;

    input [`kNumCoins-1:0] i_input_coin;
    input [`kNumItems-1:0] i_select_item;
    input i_trigger_return;

    output reg [`kNumItems-1:0] o_available_item;
    output reg [`kNumItems-1:0] o_output_item;
    output reg [`kReturnCoins-1:0] o_return_coin;
    output reg [`kTotalBits-1:0] o_current_total;

    // Net constant values (prefix kk & CamelCase)
    wire [31:0] kkItemPrice [`kNumItems-1:0];	// Price of each item
    wire [31:0] kkCoinValue [`kNumCoins-1:0];	// Value of each coin
    assign kkItemPrice[0] = 400;
    assign kkItemPrice[1] = 500;
    assign kkItemPrice[2] = 1000;
    assign kkItemPrice[3] = 2000;
    assign kkCoinValue[0] = 100;
    assign kkCoinValue[1] = 500;
    assign kkCoinValue[2] = 1000;

    // Internal states. You may add your own reg variables.
    reg [`kNumItems-1:0] available_item;
    reg [`kNumItems-1:0] output_item;
    reg [`kReturnCoins-1:0] return_coin;
    reg [`kTotalBits-1:0] current_total;
    wire [31:0] inputtotal, selecttotal;
    integer i;
    reg [`kItemBits-1:0] num_items [`kNumItems-1:0]; //use if needed
    reg [`kCoinBits-1:0] num_coins [`kNumCoins-1:0]; //use if needed


    // Combinational circuit for the next states

    // Combinational circuit for the output

    assign inputtotal = i_input_coin[0]*100 + i_input_coin[1]*500 + i_input_coin[2]*1000;
    assign selecttotal = i_select_item[0]*400 + i_select_item[1]*500 + i_select_item[2]*1000 + i_select_item[3]*2000;

    always @(*) begin

        if (i_input_coin != 4'b0000) begin
            current_total = current_total + inputtotal;
            output_item = i_select_item;

            if (current_total >= 2000) begin
                available_item = 4'b1111;
            end
            else if (current_total >= 1000) begin
                available_item = 4'b0111;
            end
            else if (current_total >= 500) begin
                available_item = 4'b0011;
            end
            else if (current_total >= 400) begin
                available_item = 4'b0001;
            end
            else begin
                available_item = 4'b0000;
            end

        end
        else if (i_select_item != 4'b0000) begin
            if (current_total >= selecttotal) begin
                current_total = current_total - selecttotal;
                output_item = i_select_item;
            end
            else begin
                output_item = 4'b0000;
            end

            if (current_total >= 2000) begin
                available_item = 4'b1111;
            end
            else if (current_total >= 1000) begin
                available_item = 4'b0111;
            end
            else if (current_total >= 500) begin
                available_item = 4'b0011;
            end
            else if (current_total >= 400) begin
                available_item = 4'b0001;
            end
            else begin
                available_item = 4'b0000;
            end
        end
        else if (i_trigger_return) begin
            for (i = 0; current_total >= 1000 ; i = i+1) begin
                current_total = current_total - 1000;
                return_coin = return_coin + 1;
            end
            for (i = 0; current_total >= 500 ; i = i+1) begin
                current_total = current_total - 500;
                return_coin = return_coin + 1;
            end
            for (i = 0; current_total >= 100 ; i = i+1) begin
                current_total = current_total - 100;
                return_coin = return_coin + 1;
            end
            available_item = 4'b0000;
            output_item = 4'b0000;
        end
    end

    // Sequential circuit to reset or update the states
    always @(posedge clk) begin
        if (!reset_n) begin
            // TODO: reset all states.
            current_total <= 0;
            available_item <= 0;
            output_item <= 0;
            return_coin <= 0;
        end
        else begin
            // TODO: update all states.
            o_available_item <= available_item;
            o_current_total <= current_total;
            o_output_item <= output_item;
            o_return_coin <= return_coin;
        end
    end
endmodule
