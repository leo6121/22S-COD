module EX_MEM (clk, reset_n, exmem_stall, exmem_flush, idex_mem_signal, idex_wb_signal, idex_nextpc, idex_predictpc, targetaddr, branchcond, aluout, idex_regdata1, idex_regdata2, writeaddr, exmem_mem_signal, exmem_wb_signal, exmem_nextpc, exmem_predictpc, exmem_targetaddr, exmem_branchcond, exmem_aluout, exmem_regdata1, exmem_writedata, exmem_writeaddr);
    input clk;
    input reset_n;
    input exmem_stall;
    input exmem_flush;
    input [4:0] idex_mem_signal;//{Branch, Jump, Memread, Memwrite}
    input [5:0] idex_wb_signal;//{MemtoReg, Regwrite, WWD, HLT, numinst_cond}
    input [15:0] idex_nextpc;
    input [15:0] idex_predictpc;
    input [15:0] targetaddr;
    input branchcond;
    input [15:0] aluout;
    input [15:0] idex_regdata1;
    input [15:0] idex_regdata2;
    input [1:0] writeaddr;

    output reg [4:0] exmem_mem_signal;
    output reg [5:0] exmem_wb_signal;
    output reg [15:0] exmem_nextpc;
    output reg [15:0] exmem_predictpc;
    output reg [15:0] exmem_targetaddr;
    output reg exmem_branchcond;
    output reg [15:0] exmem_aluout;
    output reg [15:0] exmem_regdata1;
    output reg [15:0] exmem_writedata;
    output reg [1:0] exmem_writeaddr;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n || exmem_flush) begin
            exmem_mem_signal <= 0;
            exmem_wb_signal <= 0;
            exmem_nextpc <= 0;
            exmem_predictpc <= 0;
            exmem_targetaddr <= 0;
            exmem_branchcond <= 0;
            exmem_aluout <= 0;
            exmem_regdata1 <= 0;
            exmem_writedata <= 0;
            exmem_writeaddr <= 0;
        end
        else if(!exmem_stall) begin
            exmem_mem_signal <= idex_mem_signal;
            exmem_wb_signal <= idex_wb_signal;
            exmem_nextpc <= idex_nextpc;
            exmem_predictpc <= idex_predictpc;
            exmem_targetaddr <= targetaddr;
            exmem_branchcond <= branchcond;
            exmem_aluout <= aluout;
            exmem_regdata1 <= idex_regdata1;
            exmem_writedata <= idex_regdata2;
            exmem_writeaddr <= writeaddr;
        end
    end
endmodule