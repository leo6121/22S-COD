module MEM_WB (clk, reset_n, exmem_wb_signal, d_data, exmem_nextpc, exmem_aluout, exmem_regdata1, exmem_writedata, exmem_writeaddr, memwb_wb_signal, memwb_nextpc, memwb_data, memwb_aluout, memwb_regdata1, memwb_writedata, memwb_writeaddr);
    input clk;
    input reset_n;
    input [5:0] exmem_wb_signal;//{MemtoReg, Regwrite, WWD, HLT, numinst_cond}
    input [15:0] d_data;
    input [15:0] exmem_nextpc;
    input [15:0] exmem_aluout;
    input [15:0] exmem_regdata1;
    input [15:0] exmem_writedata;
    input [1:0] exmem_writeaddr;

    output reg [5:0] memwb_wb_signal;//{MemtoReg, Regwrite, WWD, HLT, numinst_cond}
    output reg [15:0] memwb_nextpc;
    output reg [15:0] memwb_data;
    output reg [15:0] memwb_aluout;
    output reg [15:0] memwb_regdata1;
    output reg [15:0] memwb_writedata;
    output reg [1:0] memwb_writeaddr;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            memwb_wb_signal <= 0;
            memwb_nextpc <= 0;
            memwb_data <= 0;
            memwb_aluout <= 0;
            memwb_regdata1 <= 0;
            memwb_writedata <= 0;
            memwb_writeaddr <= 0;
        end
        else begin
            memwb_wb_signal <= exmem_wb_signal;
            memwb_nextpc <= exmem_nextpc;
            memwb_data <= d_data;
            memwb_aluout <= exmem_aluout;
            memwb_regdata1 <= exmem_regdata1;
            memwb_writedata <= exmem_writedata;
            memwb_writeaddr <= exmem_writeaddr;
        end
    end
endmodule