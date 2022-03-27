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
    wire [31:0] inputtotal, selecttotal;
    reg [`kItemBits-1:0] num_items [`kNumItems-1:0]; //use if needed
    reg [`kCoinBits-1:0] num_coins [`kNumCoins-1:0]; //use if needed


    // Combinational circuit for the next states

    // Combinational circuit for the output

    assign inputtotal = i_input_coin[0]*kkCoinValue[0] + i_input_coin[1]*kkCoinValue[1] + i_input_coin[2]*kkCoinValue[2];
    assign selecttotal = i_select_item[0]*kkItemPrice[0] + i_select_item[1]*kkItemPrice[1] + i_select_item[2]*kkItemPrice[2] + i_select_item[3]*kkItemPrice[3];

    // Sequential circuit to reset or update the states
    always @(posedge clk) begin
        if (!reset_n) begin
            // TODO: reset all states.
            o_current_total <= 0;
            o_available_item <= 4'b0000;
            o_output_item <= 4'b0000;
            o_return_coin <= 0;
            num_coins[0] <= 0;
            num_coins[1] <= 0;
            num_coins[2] <= 0;
        end
        else begin
            if(!i_trigger_return) begin
                o_return_coin <= 0;
                o_output_item <= i_select_item & o_available_item;
                if(i_input_coin) begin//input
                    o_current_total <= o_current_total + inputtotal;
                    o_available_item = (o_current_total + inputtotal >= kkItemPrice[3]) ? 4'b1111 :
                                     (o_current_total + inputtotal >= kkItemPrice[2]) ? 4'b0111 :
                                     (o_current_total + inputtotal >= kkItemPrice[1]) ? 4'b0011 :
                                     (o_current_total + inputtotal >= kkItemPrice[0]) ? 4'b0001 : 4'b0000;
                    case (i_input_coin)
                        3'b001:
                            if (!num_coins[1] & num_coins[0] == 4) begin//100-500
                                num_coins[0] <= num_coins[0] - 4;
                                num_coins[1] <= num_coins[1] + 1;
                            end
                            else if (num_coins[1] & num_coins[0] == 4) begin//100-1000
                                num_coins[0] <= num_coins[0] - 4;
                                num_coins[1] <= num_coins[1] - 1;
                                num_coins[2] <= num_coins[2] + 1;
                            end
                            else begin
                                num_coins[0] <= num_coins[0] + 1;
                            end
                        3'b010:
                            if (num_coins[1]) begin//500-1000
                                num_coins[1] <= num_coins[1] - 1;
                                num_coins[2] <= num_coins[2] + 1;
                            end
                            else begin
                                num_coins[1] <= num_coins[1] + 1;
                            end
                        3'b100:
                            num_coins[2] <= num_coins[2] + 1;
                    endcase
                end
                else if (i_select_item) begin//select
                    if (o_current_total >= selecttotal) begin
                        o_current_total <= o_current_total - selecttotal;
                        o_available_item = (o_current_total - selecttotal >= kkItemPrice[3]) ? 4'b1111 :
                                         (o_current_total - selecttotal >= kkItemPrice[2]) ? 4'b0111 :
                                         (o_current_total - selecttotal >= kkItemPrice[1]) ? 4'b0011 :
                                         (o_current_total - selecttotal >= kkItemPrice[0]) ? 4'b0001 : 4'b0000;
                        case (i_select_item)
                            4'b0001:
                                if (num_coins[0] == 4) begin
                                    num_coins[0] <= num_coins[0] - 4;
                                end
                                else begin
                                    if(num_coins[1]) begin//100-500
                                        num_coins[0] <= num_coins[0] + 1;
                                        num_coins[1] <= num_coins[1] - 1;
                                    end
                                    else begin //500-1000
                                        num_coins[0] <= num_coins[0] + 1;
                                        num_coins[1] <= num_coins[1] + 1;
                                        num_coins[2] <= num_coins[2] - 1;
                                    end
                                end
                            4'b0010:
                                if (!num_coins[1]) begin//500-1000
                                    num_coins[1] <= num_coins[1] + 1;
                                    num_coins[2] <= num_coins[2] - 1;
                                end
                                else begin
                                    num_coins[1] <= num_coins[1] - 1;
                                end
                            4'b0100:
                                num_coins[2] <= num_coins[2] - 1;
                            4'b1000:
                                num_coins[2] <= num_coins[2] - 2;
                        endcase
                    end
                    else begin
                        o_output_item <= 4'b0000;
                        o_available_item = (o_current_total >= kkItemPrice[3]) ? 4'b1111 :
                                         (o_current_total>= kkItemPrice[2]) ? 4'b0111 :
                                         (o_current_total>= kkItemPrice[1]) ? 4'b0011 :
                                         (o_current_total>= kkItemPrice[0]) ? 4'b0001 : 4'b0000;
                    end
                end
            end
            else begin
                o_current_total <= 0;
                o_output_item <= 4'b0000;
                o_available_item <= 4'b0000;
                o_return_coin <= num_coins[2]+num_coins[1]+num_coins[0];
            end
        end
    end
endmodule
