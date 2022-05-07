module MEM_WB (clk, reset_n, writedata, exmem_wb_signal, exmem_nextpc, exmem_forwardA, exmem_writeaddr, memwb_wb_signal, memwb_nextpc, memwb_forwardA, memwb_writedata, memwb_writeaddr);
    input clk;
    input reset_n;
    input [15:0] writedata;
    input [5:0] exmem_wb_signal;//{MemtoReg, Regwrite, WWD, HLT, numinst_cond}
    input [15:0] exmem_nextpc;
    input [15:0] exmem_forwardA;
    input [1:0] exmem_writeaddr;

    output reg [5:0] memwb_wb_signal;//{MemtoReg, Regwrite, WWD, HLT, numinst_cond}
    output reg [15:0] memwb_nextpc;
    output reg [15:0] memwb_forwardA;
    output reg [15:0] memwb_writedata;
    output reg [1:0] memwb_writeaddr;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            memwb_wb_signal <= 0;
            memwb_nextpc <= 0;
            memwb_forwardA <= 0;
            memwb_writedata <= 0;
            memwb_writeaddr <= 0;
        end
        else begin
            memwb_wb_signal <= exmem_wb_signal;
            memwb_nextpc <= exmem_nextpc;
            memwb_forwardA <= exmem_forwardA;
            memwb_writedata <= writedata;
            memwb_writeaddr <= exmem_writeaddr;
        end
    end
endmodule