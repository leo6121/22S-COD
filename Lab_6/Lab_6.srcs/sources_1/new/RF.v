//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/03/15 12:35:44
// Design Name:
// Module Name: RTL
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


module RF(clk, reset_n, write, addr1, addr2, addr3, data3, data1, data2);
    input clk;
    input reset_n;
    input write;
    input [1:0] addr1, addr2, addr3;
    input [15:0] data3;
    output reg [15:0] data1, data2;

    reg [15:0] data[3:0];

    always @(*) begin
        data1 = data[addr1];
        data2 = data[addr2];
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data[0] <= 16'h0000;
            data[1] <= 16'h0000;
            data[2] <= 16'h0000;
            data[3] <= 16'h0000;
        end
        else if(write) begin
            data[addr3] = data3;
        end
    end
endmodule