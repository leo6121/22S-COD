`timescale 100ps / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/03/21 12:39:07
// Design Name:
// Module Name: vending_machine_def
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

// Title         : vending_machine_def.v
// Author      : Hunjun Lee (hunjunlee7515@snu.ac.kr), Suheon Bae (suheon.bae@snu.ac.kr)

// Macro constants (prefix k & CamelCase)


module vending_machine_def;
`define kTotalBits 32

`define kItemBits 8
    `define kNumItems 4

`define kCoinBits 8
    `define kNumCoins 3
    `define kReturnCoins 10

`define kWaitTime 10
endmodule
