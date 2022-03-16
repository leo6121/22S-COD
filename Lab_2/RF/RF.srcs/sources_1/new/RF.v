`timescale 100ps / 100ps
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
    
    always @(posedge clk) begin
        data1 <= data[addr1];
        data2 <= data[addr2];
        
        if(write == 1) begin
            data[addr3] <= data3;
        end
        
        if (reset_n == 0) begin
            data[0] = 0;
            data[1] = 0;
            data[2] = 0;
            data[3] = 0;
        end    
    end    
endmodule
