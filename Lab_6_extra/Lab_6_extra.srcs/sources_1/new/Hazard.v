module Hazard (ifid_instruction, idex_instruction, use_rs, use_rt, idex_ex_signal, idex_mem_signal, idex_wb_signal, exmem_branchcond, exmem_mem_signal, exmem_wb_signal, exmem_writeaddr, exmem_targetaddr, exmem_predictpc, exmem_nextpc, memwb_wb_signal, memwb_writeaddr, pc_stall, ifid_stall, ifid_flush, idex_flush, exmem_flush, correctpc);
    input [15:0] ifid_instruction;
    input [15:0] idex_instruction;
    input use_rs;
    input use_rt;
    input [6:0] idex_ex_signal;//{Regdst, ALUOp, ALUSrc}
    input [4:0] idex_mem_signal;
    input [5:0] idex_wb_signal;//{MemtoReg, Regwrite, WWD, HLT, numinst_cond}
    input exmem_branchcond;
    input [4:0] exmem_mem_signal;//{Branch, Jump, Memread, Memwrite}
    input [5:0] exmem_wb_signal;
    input [1:0] exmem_writeaddr;
    input [15:0] exmem_targetaddr;
    input [15:0] exmem_predictpc;
    input [15:0] exmem_nextpc;
    input [5:0] memwb_wb_signal;
    input [1:0] memwb_writeaddr;
    
    output reg pc_stall;
    output reg ifid_stall;
    output reg ifid_flush;
    output reg idex_flush;
    output reg exmem_flush;
    output reg [15:0] correctpc;//for branch or jump misprediction
    
    wire [1:0] ifid_rs, ifid_rt, idex_writeaddr;
    assign ifid_rs = ifid_instruction[11:10];
    assign ifid_rt = ifid_instruction[9:8];
    assign idex_writeaddr = (idex_ex_signal[6:5] == 2'd0) ? idex_instruction[9:8] :
                            (idex_ex_signal[6:5] == 2'd1) ? idex_instruction[7:6] :
                            (idex_ex_signal[6:5] == 2'd2) ? 2'd2 : idex_instruction[9:8];

    always @(*) begin
        //jump misprediction
        if(exmem_mem_signal[3:2] != 0 && exmem_predictpc != exmem_targetaddr) begin
            pc_stall = 0;
            ifid_stall = 0;
            ifid_flush = 1;
            idex_flush = 1;
            exmem_flush = 1;
            correctpc = exmem_targetaddr;
        end
        //branch misprediction, branch is not taken or taken but predicted_pc is wrong
        else if(exmem_mem_signal[4] && exmem_branchcond && exmem_predictpc != exmem_targetaddr) begin
            pc_stall = 0;   
            ifid_stall = 0;
            ifid_flush = 1;
            idex_flush = 1;
            exmem_flush = 1;
            correctpc = exmem_targetaddr;
        end
        else if(exmem_mem_signal[4] && !exmem_branchcond && exmem_predictpc != exmem_nextpc) begin
            pc_stall = 0;
            ifid_stall = 0;
            ifid_flush = 1;
            idex_flush = 1;
            exmem_flush = 1;
            correctpc = exmem_nextpc;
        end
        //stall for load instruction
        else if(((ifid_rs == idex_writeaddr && use_rs) || (ifid_rt == idex_writeaddr && use_rt)) && idex_mem_signal[1]) begin
            pc_stall = 1;
            ifid_stall = 1;
            ifid_flush = 0;
            idex_flush = 1;
            exmem_flush = 0;
            correctpc = 0;
        end
        else begin
            pc_stall = 0;
            ifid_stall = 0;
            ifid_flush = 0;
            idex_flush = 0;
            exmem_flush = 0;
            correctpc = 0;
        end
    end
endmodule