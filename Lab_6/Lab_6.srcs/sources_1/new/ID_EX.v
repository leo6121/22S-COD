module ID_EX (clk, reset_n, ifid_instruction, ifid_nextpc, idex_flush, ex_signal, mem_signal, wb_signal, regdata1, regdata2, sign_extend, idex_instruction, idex_ex_signal, idex_mem_signal, idex_wb_signal, idex_nextpc, idex_regdata1, idex_regdata2, idex_signextend);
    input clk;
    input reset_n;
    input [15:0] ifid_instruction;
    input [15:0] ifid_nextpc;
    input idex_flush;
    input [6:0] ex_signal;//{Regdst, ALUOp, ALUSrc}
    input [4:0] mem_signal;//{Branch, Jump, Memread, Memwrite}
    input [5:0] wb_signal;//{MemtoReg, Regwrite, WWD, HLT, numinst_cond}
    input [15:0] regdata1;
    input [15:0] regdata2;
    input [15:0] sign_extend;

    output reg [15:0] idex_instruction;
    output reg [6:0] idex_ex_signal;
    output reg [4:0] idex_mem_signal;
    output reg [5:0] idex_wb_signal;
    output reg [15:0] idex_nextpc;
    output reg [15:0] idex_regdata1;
    output reg [15:0] idex_regdata2;
    output reg [15:0] idex_signextend;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            idex_instruction <= 16'hb000;
            idex_ex_signal <= 0;
            idex_mem_signal <= 0;
            idex_wb_signal <= 0;
            idex_nextpc <= 0;
            idex_regdata1 <= 0;
            idex_regdata2 <= 0;
            idex_signextend <= 0;
        end
        else if(idex_flush) begin//reset except nextpc
            idex_instruction <= 16'hb000;
            idex_ex_signal <= 0;
            idex_mem_signal <= 0;
            idex_wb_signal <= 0;
            idex_regdata1 <= 0;
            idex_regdata2 <= 0;
            idex_signextend <= 0;
        end
        else begin
            idex_instruction <= ifid_instruction;
            idex_ex_signal <= ex_signal;
            idex_mem_signal <= mem_signal;
            idex_wb_signal <= wb_signal;
            idex_nextpc <= ifid_nextpc;
            idex_regdata1 <= regdata1;
            idex_regdata2 <= regdata2;
            idex_signextend <= sign_extend;
        end

    end
endmodule