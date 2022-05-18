module Hazard (ifid_instruction, idex_instruction, use_rs, use_rt, idex_ex_signal, idex_wb_signal, exmem_branchcond, exmem_mem_signal, exmem_wb_signal, exmem_writeaddr, exmem_targetaddr, exmem_predictpc, exmem_nextpc, memwb_wb_signal, memwb_writeaddr, i_mem_counter, d_mem_counter, ifid_valid, idex_valid, pc_stall, ifid_stall, ifid_flush, idex_stall, idex_flush, exmem_stall, exmem_flush, memwb_flush, correctpc);
    input [15:0] ifid_instruction;
    input [15:0] idex_instruction;
    input use_rs;
    input use_rt;
    input [6:0] idex_ex_signal;//{Regdst, ALUOp, ALUSrc}
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
    input i_mem_counter;//1 for i_mem_hazard 1
    input d_mem_counter;//1 for d_mem_hazard 1
    input ifid_valid;
    input idex_valid;
    
    output reg pc_stall;
    output reg ifid_stall;
    output reg ifid_flush;
    output reg idex_stall;
    output reg idex_flush;
    output reg exmem_stall;
    output reg exmem_flush;
    output reg memwb_flush;
    output [15:0] correctpc;//for branch or jump misprediction
    
    wire [1:0] ifid_rs, ifid_rt, idex_writeaddr;
    assign ifid_rs = ifid_instruction[11:10];
    assign ifid_rt = ifid_instruction[9:8];
    assign idex_writeaddr = (idex_ex_signal[6:5] == 2'd0) ? idex_instruction[9:8] :
                            (idex_ex_signal[6:5] == 2'd1) ? idex_instruction[7:6] :
                            (idex_ex_signal[6:5] == 2'd2) ? 2'd2 : idex_instruction[9:8];

    wire i_mem_hazard, d_mem_hazard;
    assign i_mem_hazard = (i_mem_counter) ? 1 : 0;
    assign d_mem_hazard = (d_mem_counter) ? 1 : 0;

    wire data_hazard, control_hazard;
    assign data_hazard = (((ifid_rs == idex_writeaddr && use_rs) || (ifid_rt == idex_writeaddr && use_rt)) && idex_wb_signal[3]) ||//id-ex
                         (((ifid_rs == exmem_writeaddr && use_rs) || (ifid_rt == exmem_writeaddr && use_rt)) && exmem_wb_signal[3]) ||//id-mem
                         (((ifid_rs == memwb_writeaddr && use_rs) || (ifid_rt == memwb_writeaddr && use_rt)) && memwb_wb_signal[3]);//id-wb
    assign control_hazard = (exmem_mem_signal[3:2] != 2'd0 && exmem_predictpc != exmem_targetaddr) ||//jump
                            (exmem_mem_signal[4] && exmem_branchcond && exmem_predictpc != exmem_targetaddr) ||//branch taken
                            (exmem_mem_signal[4] && !exmem_branchcond && exmem_predictpc != exmem_nextpc);//branch not taken

    assign correctpc = (exmem_mem_signal[3:2] != 2'd0 && exmem_predictpc != exmem_targetaddr) ? exmem_targetaddr ://jump
                       (exmem_mem_signal[4] && exmem_branchcond && exmem_predictpc != exmem_targetaddr) ? exmem_targetaddr ://branch taken
                       (exmem_mem_signal[4] && !exmem_branchcond && exmem_predictpc != exmem_nextpc) ? exmem_nextpc : exmem_targetaddr;//branch not taken

    wire [3:0] hazard;

    assign hazard = {i_mem_hazard, d_mem_hazard, control_hazard, data_hazard};

    always @(*) begin
        case (hazard)
            4'b0001 : begin
                pc_stall = 1;
                ifid_stall = 1;
                ifid_flush = 0;
                idex_stall = 0;
                idex_flush = 1;
                exmem_stall = 0;
                exmem_flush = 0;
                memwb_flush = 0;
            end  
            4'b0010,
            4'b0011 : begin
                pc_stall = 0;
                ifid_stall = 0;
                ifid_flush = 1;
                idex_stall = 0;
                idex_flush = 1;
                exmem_stall = 0;
                exmem_flush = 1;
                memwb_flush = 0;
            end
            4'b0100 : begin
                ifid_flush = 0;
                idex_flush = 0;
                exmem_stall = 1;
                exmem_flush = 0;
                memwb_flush = 1;

                if (!ifid_valid) begin
                    if (!idex_valid) begin
                        pc_stall = 0;
                        ifid_stall = 0;
                        idex_stall = 0;
                    end
                    else begin
                        pc_stall = 0;
                        ifid_stall = 0;
                        idex_stall = 1;
                    end
                end
                else begin
                    if(!idex_valid) begin
                        pc_stall = 0;
                        ifid_stall = 0;
                        idex_stall = 0;
                    end
                    else begin
                        pc_stall = 1;
                        ifid_stall = 1;
                        idex_stall = 1;
                    end
                end
            end
            4'b0101 : begin
                pc_stall = 1;
                ifid_stall = 1;
                ifid_flush = 0;
                idex_stall = 1;
                idex_flush = 0;
                exmem_stall = 1;
                exmem_flush = 0;
                memwb_flush = 1;
            end
            4'b1000 : begin
                pc_stall = 1;
                ifid_stall = 0;
                ifid_flush = 1;
                idex_stall = 0;
                idex_flush = 0;
                exmem_stall = 0;
                exmem_flush = 0;
                memwb_flush = 0;
            end
            4'b1001 : begin
                pc_stall = 1;
                ifid_stall = 1;
                ifid_flush = 0;
                idex_stall = 0;
                idex_flush = 1;
                exmem_stall = 0;
                exmem_flush = 0;
                memwb_flush = 0;
            end
            4'b1010,
            4'b1011 : begin
                pc_stall = 1;
                ifid_stall = 1;
                ifid_flush = 0;
                idex_stall = 1;
                idex_flush = 0;
                exmem_stall = 1;
                exmem_flush = 0;
                memwb_flush = 1;
            end
            4'b1100 : begin
                pc_stall = 1;
                idex_flush = 0;
                exmem_stall = 1;
                exmem_flush = 0;
                memwb_flush = 1;

                if(ifid_valid) begin
                    if(!idex_valid) begin 
                       ifid_stall = 0;
                       ifid_flush = 1;
                       idex_stall = 0;
                    end
                    else begin
                       ifid_stall = 1;
                       ifid_flush = 0;
                       idex_stall = 1; 
                    end
                end
                else begin
                    ifid_stall = 1;
                    ifid_flush = 0;
                    idex_stall = 1;
                end
            end
            4'b1101 : begin
                pc_stall = 1;
                ifid_stall = 1;
                ifid_flush = 0;
                idex_stall = 1;
                idex_flush = 0;
                exmem_stall = 1;
                exmem_flush = 0;
                memwb_flush = 1;
            end
            default : begin
                pc_stall = 0;
                ifid_stall = 0;
                ifid_flush = 0;
                idex_stall = 0;
                idex_flush = 0;
                exmem_stall = 0;
                exmem_flush = 0;
                memwb_flush = 0;
            end
        endcase
    end

    // always @(*) begin
    //     //jump misprediction
    //     if(exmem_mem_signal[3:2] != 2'd0 && exmem_predictpc != exmem_targetaddr) begin
    //         pc_stall = 0;
    //         ifid_stall = 0;
    //         ifid_flush = 1;
    //         idex_flush = 1;
    //         exmem_flush = 1;
    //         correctpc = exmem_targetaddr;
    //     end
    //     //branch misprediction, branch is not taken or taken but predicted_pc is wrong
    //     else if(exmem_mem_signal[4] && exmem_branchcond && exmem_predictpc != exmem_targetaddr) begin
    //         pc_stall = 0;   
    //         ifid_stall = 0;
    //         ifid_flush = 1;
    //         idex_flush = 1;
    //         exmem_flush = 1;
    //         correctpc = exmem_targetaddr;
    //     end
    //     else if(exmem_mem_signal[4] && !exmem_branchcond && exmem_predictpc != exmem_nextpc) begin
    //         pc_stall = 0;
    //         ifid_stall = 0;
    //         ifid_flush = 1;
    //         idex_flush = 1;
    //         exmem_flush = 1;
    //         correctpc = exmem_nextpc;
    //     end
    //     //dependency on rs, rt
    //     else begin
    //         if() begin
    //             pc_stall = 1;
    //             ifid_stall = 1;
    //             ifid_flush = 0;
    //             idex_flush = 1;
    //             exmem_flush = 0;
    //             correctpc = 0;
    //         end
    //         else if begin
    //             pc_stall = 1;
    //             ifid_stall = 1;
    //             ifid_flush = 0;
    //             idex_flush = 1;
    //             exmem_flush = 0;
    //             correctpc = 0;
    //         end
    //         else if begin
    //             pc_stall = 1;
    //             ifid_stall = 1;
    //             ifid_flush = 0;
    //             idex_flush = 1;
    //             exmem_flush = 0;
    //             correctpc = 0;
    //         end
    //         else begin
    //             pc_stall = 0;
    //             ifid_stall = 0;
    //             ifid_flush = 0;
    //             idex_flush = 0;
    //             exmem_flush = 0;
    //             correctpc = 0;
    //         end
    //     end
    // end
endmodule