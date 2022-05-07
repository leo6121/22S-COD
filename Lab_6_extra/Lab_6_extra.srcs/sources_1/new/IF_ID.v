module IF_ID(clk, reset_n, i_data, nextpc, ifid_stall, ifid_flush, ifid_instruction, ifid_nextpc);
    input clk;
    input reset_n;
    input [15:0] i_data;
    input [15:0] nextpc;
    input ifid_stall;
    input ifid_flush;

    output reg [15:0] ifid_instruction;
    output reg [15:0] ifid_nextpc;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n || ifid_flush) begin
            ifid_instruction <= 16'hb000;
            ifid_nextpc <= 0;
        end
        else if(ifid_stall == 0) begin
            ifid_instruction <= i_data;
            ifid_nextpc <= nextpc;
        end
    end
endmodule