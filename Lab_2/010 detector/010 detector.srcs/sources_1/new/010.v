`timescale 100ps / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/15 11:54:49
// Design Name: 
// Module Name: detecter
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


module detector(clk, reset_n, in, out);
    input clk;
    input reset_n;
    input in;
    output out;
    reg out;
    reg [1:0] state;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            out <= 0;
            state <= 2'b00;
        end

        if (in) begin
            state <= (state == 2'b00) ? 2'b01 : 2'b11;
            out <= 0;
        end
        else begin
        state <= 2'b00;
        out <= (state == 2'b01) ? 1 : 0;
        end
    end
   
endmodule

