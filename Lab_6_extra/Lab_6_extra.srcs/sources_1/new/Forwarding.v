
module Forwarding(ifid_instruction, idex_instruction, idex_ex_signal, idex_wb_signal, exmem_wb_signal, exmem_writeaddr, memwb_wb_signal, memwb_writeaddr, forwardA, forwardB);
    input [15:0] ifid_instruction;
    input [15:0] idex_instruction;
    input [6:0] idex_ex_signal;//{Regdst, ALUOp, ALUSrc}
    input [5:0] idex_wb_signal;//{MemtoReg, Regwrite, WWD, HLT, numinst_cond}
    input [5:0] exmem_wb_signal;
    input [1:0] exmem_writeaddr;
    input [5:0] memwb_wb_signal;
    input [1:0] memwb_writeaddr;

    output reg [1:0] forwardA;//0 for no forward, 1 for forward from ex stage, 2 for forward from mem stage, 3 for forward from wb stage
    output reg [1:0] forwardB;//0 for no forward, 1 for forward from ex stage, 2 for forward from mem stage, 3 for forward from wb stage

    wire [1:0] ifid_rs, ifid_rt, idex_writeaddr;

    assign ifid_rs = ifid_instruction[11:10];
    assign ifid_rt = ifid_instruction[9:8];
    assign idex_writeaddr = (idex_ex_signal[6:5] == 2'd0) ? idex_instruction[9:8] :
                            (idex_ex_signal[6:5] == 2'd1) ? idex_instruction[7:6] :
                            (idex_ex_signal[6:5] == 2'd2) ? 2'd2 : idex_instruction[9:8];

    always @(*) begin
        //forwardA
        if ((ifid_rs == idex_writeaddr) && idex_wb_signal[3]) begin
            forwardA = 2'd1;
        end
        else if((ifid_rs == exmem_writeaddr) && exmem_wb_signal[3]) begin
            forwardA = 2'd2;
        end
        else if((ifid_rs == memwb_writeaddr) && memwb_wb_signal[3]) begin
            forwardA = 2'd3;
        end
        else begin
            forwardA = 2'd0;
        end
        
        //forwardB
        if ((ifid_rt == idex_writeaddr) && idex_wb_signal[3]) begin
            forwardB = 2'd1;
        end
        else if((ifid_rt == exmem_writeaddr) && exmem_wb_signal[3]) begin
            forwardB = 2'd2;
        end
        else if((ifid_rt == memwb_writeaddr) && memwb_wb_signal[3]) begin
            forwardB = 2'd3;
        end
        else begin
            forwardB = 2'd0;
        end
    end    
endmodule
