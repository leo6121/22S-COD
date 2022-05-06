`define MEMORY_SIZE 256	//	size of memory is 2^8 words (reduced size)
`define WORD_SIZE 16	//	instead of 2^16 words to reduce memory

module Datapath (clk, reset_n, i_data, i_readM, d_data, ex_signal, mem_signal, wb_signal, use_rs, use_rt, instruction, d_address, i_address, output_port, num_inst, is_halted, d_readM, d_writeM);
    input clk;
    input reset_n;
    input [15:0] i_data;
    input i_readM;
    input [15:0] d_data;
    input [6:0] ex_signal;
    input [4:0] mem_signal;
    input [5:0] wb_signal;
    input use_rs;
    input use_rt;

    output [15:0] instruction;//ifid_instruction
    output [15:0] d_address;
    output [15:0] i_address;
    output reg [15:0] output_port;
    output reg [15:0] num_inst;
    output is_halted;
    output d_readM;
    output d_writeM;
    
    reg [15:0] pc;
    
    assign i_address = pc;
    assign instruction = ifid_instruction;

    wire [15:0] nextpc, correctpc;
    wire [15:0] ifid_instruction, ifid_nextpc;
    wire pc_stall, ifid_stall, ifid_flush, idex_flush, exmem_flush;

    wire [15:0] regdata1, regdata2;

    wire [15:0] sign_extend;

    wire [15:0] idex_instruction, idex_nextpc, idex_regdata1, idex_regdata2, idex_signextend;
    wire [6:0] idex_ex_signal;
    wire [4:0] idex_mem_signal;
    wire [5:0] idex_wb_signal;

    wire [15:0] aluinput1, aluinput2, aluout;
    wire branchcond;

    wire [1:0] writeaddr;
    wire [15:0] targetaddr;

    wire [15:0] exmem_nextpc, exmem_targetaddr, exmem_aluout, exmem_regdata1, exmem_writedata;
    wire [4:0] exmem_mem_signal;
    wire [5:0] exmem_wb_signal;
    wire [1:0] exmem_writeaddr;
    wire exmem_branchcond;

    wire [15:0] memwb_nextpc, memwb_data, memwb_aluout, memwb_regdata1, memwb_writedata;
    wire [5:0] memwb_wb_signal;
    wire [1:0] memwb_writeaddr;

    wire [15:0] writedata;

    wire [15:0] predicted_pc;

    Branch_predictor branch_predictor(
        .clk(clk),
        .reset_n(reset_n),
        .pc(pc),
        .mem_signal(mem_signal),
        .wb_signal(wb_signal),
        .exmem_nextpc(exmem_nextpc),
        .exmem_targetaddr(exmem_targetaddr),
        .exmem_mem_signal(exmem_mem_signal),
        .predicted_pc(predicted_pc)
        );

    Hazard hazard(
        .pc(pc),
        .ifid_instruction(ifid_instruction),
        .idex_instruction(idex_instruction),
        .use_rs(use_rs),
        .use_rt(use_rt),
        .idex_ex_signal(idex_ex_signal),
        .idex_wb_signal(idex_wb_signal),
        .exmem_branchcond(exmem_branchcond),
        .exmem_mem_signal(exmem_mem_signal),
        .exmem_wb_signal(exmem_wb_signal),
        .exmem_writeaddr(exmem_writeaddr),
        .memwb_wb_signal(memwb_wb_signal),
        .memwb_writeaddr(memwb_writeaddr),
        .exmem_targetaddr(exmem_targetaddr),
        .idex_nextpc(idex_nextpc),
        .exmem_nextpc(exmem_nextpc),
        .pc_stall(pc_stall),
        .ifid_stall(ifid_stall),
        .ifid_flush(ifid_flush),
        .idex_flush(idex_flush),
        .exmem_flush(exmem_flush),
        .correctpc(correctpc)
    );

    //pc
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            pc <= 0;
        end
        else if(ifid_flush) begin//branch misprediction
            pc <= correctpc;
        end
        else if(!pc_stall) begin
            pc <= predicted_pc;
        end
    end
    
    assign nextpc = pc+1;

    //ifid register for id stage
    IF_ID if_id(
        .clk(clk),
        .reset_n(reset_n), 
        .i_data(i_data),
        .nextpc(nextpc),
        .ifid_stall(ifid_stall),
        .ifid_flush(ifid_flush),
        .ifid_instruction(ifid_instruction), 
        .ifid_nextpc(ifid_nextpc)
    );

    RF rf(
        .clk(clk),
        .reset_n(reset_n),
        .write(memwb_wb_signal[3]),
        .addr1(ifid_instruction[11:10]),//rs
        .addr2(ifid_instruction[9:8]),//rt
        .addr3(memwb_writeaddr),
        .data3(writedata),
        .data1(regdata1),
        .data2(regdata2)
    );

    assign sign_extend = (ifid_instruction[15:12] == `OPCODE_LHI) ? {ifid_instruction[7:0], 8'b0} :
                         (ifid_instruction[15:12] == `OPCODE_ORI) ? {8'b0, ifid_instruction[7:0]} : {{8{ifid_instruction[7]}}, ifid_instruction[7:0]};

    //idex register for ex stage
    ID_EX id_ex(
        .clk(clk),
        .reset_n(reset_n),
        .ifid_instruction(ifid_instruction),
        .ifid_nextpc(ifid_nextpc),
        .idex_flush(idex_flush),
        .ex_signal(ex_signal),
        .mem_signal(mem_signal),
        .wb_signal(wb_signal),
        .regdata1(regdata1),
        .regdata2(regdata2),
        .sign_extend(sign_extend),
        .idex_instruction(idex_instruction),
        .idex_ex_signal(idex_ex_signal),//{Regdst, Jump, ALUOp, ALUSrc}
        .idex_mem_signal(idex_mem_signal),//{Branch, Memread, Memwrite}
        .idex_wb_signal(idex_wb_signal),//{MemtoReg, Regwrite}
        .idex_nextpc(idex_nextpc),
        .idex_regdata1(idex_regdata1),
        .idex_regdata2(idex_regdata2),
        .idex_signextend(idex_signextend)
    );

    assign aluinput1 = idex_regdata1;
    assign aluinput2 = (idex_ex_signal[0] == 1'b0) ? idex_regdata2 :
                       (idex_ex_signal[0] == 1'b1) ? idex_signextend : idex_regdata2;

    ALU alu(
        .OP(idex_ex_signal[4:1]),
        .A(aluinput1),
        .B(aluinput2),
        .C(aluout),
        .branchcond(branchcond)
    );
    
    assign writeaddr = (idex_ex_signal[6:5] == 2'd0) ? idex_instruction[9:8] :
                       (idex_ex_signal[6:5] == 2'd1) ? idex_instruction[7:6] :
                       (idex_ex_signal[6:5] == 2'd2) ? 2'd2 : idex_instruction[9:8];
    assign targetaddr = (idex_mem_signal[4]) ? idex_nextpc + idex_signextend ://branch
                        (idex_mem_signal[2]) ? {idex_nextpc[15:12], idex_instruction[11:0]} ://jmp,jal
                        (idex_mem_signal[3]) ? idex_regdata1 : idex_nextpc;//jpr,jrl

    EX_MEM ex_mem(
        .clk(clk),
        .reset_n(reset_n),
        .exmem_flush(exmem_flush),
        .idex_mem_signal(idex_mem_signal),
        .idex_wb_signal(idex_wb_signal),
        .idex_nextpc(idex_nextpc),
        .targetaddr(targetaddr),
        .branchcond(branchcond),
        .aluout(aluout),
        .idex_regdata1(idex_regdata1),
        .idex_regdata2(idex_regdata2),
        .writeaddr(writeaddr),
        .exmem_mem_signal(exmem_mem_signal),
        .exmem_wb_signal(exmem_wb_signal),
        .exmem_nextpc(exmem_nextpc),
        .exmem_targetaddr(exmem_targetaddr),
        .exmem_branchcond(exmem_branchcond),
        .exmem_aluout(exmem_aluout),
        .exmem_regdata1(exmem_regdata1),
        .exmem_writedata(exmem_writedata),
        .exmem_writeaddr(exmem_writeaddr)
    );

    assign d_data = (exmem_mem_signal[0]) ? exmem_writedata : 16'bz;//memwrite
    assign d_address = exmem_aluout;
    assign d_readM = exmem_mem_signal[1];
    assign d_writeM = exmem_mem_signal[0];

    MEM_WB mem_wb(
        .clk(clk),
        .reset_n(reset_n),
        .exmem_wb_signal(exmem_wb_signal),
        .d_data(d_data),
        .exmem_nextpc(exmem_nextpc),
        .exmem_aluout(exmem_aluout),
        .exmem_regdata1(exmem_regdata1),
        .exmem_writedata(exmem_writedata),
        .exmem_writeaddr(exmem_writeaddr),
        .memwb_wb_signal(memwb_wb_signal),
        .memwb_nextpc(memwb_nextpc),
        .memwb_data(memwb_data),
        .memwb_aluout(memwb_aluout),
        .memwb_regdata1(memwb_regdata1),
        .memwb_writedata(memwb_writedata),
        .memwb_writeaddr(memwb_writeaddr)
    );

    assign writedata = (memwb_wb_signal[5:4] == 2'd0) ? memwb_aluout : 
                       (memwb_wb_signal[5:4] == 2'd1) ? memwb_data :
                       (memwb_wb_signal[5:4] == 2'd2) ? memwb_nextpc : memwb_aluout;
    assign is_halted = memwb_wb_signal[1];

    //output_port
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            output_port <= 0;
        end
        else if(memwb_wb_signal[2]) begin
            output_port <= memwb_regdata1;
        end
    end

    //num_inst
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            num_inst <= 0;
        end
        else if(memwb_wb_signal[0]) begin
            num_inst <= num_inst+1;
        end
    end

endmodule