`include "opcodes.v"

module Control (clk, reset_n, instruction, ex_signal, mem_signal, wb_signal, use_rs, use_rt);
    input clk;
    input reset_n;
    input [15:0] instruction;

    output [6:0] ex_signal;//{Regdst, ALUOp, ALUSrc}
    output [4:0] mem_signal;//{Branch, Jump, Memread, Memwrite}
    output [5:0] wb_signal;//{MemtoReg, Regwrite, WWD, HLT, numinst_cond}
    output use_rs;
    output use_rt;


    wire [1:0] Regdst;//0 for $rt, 1 for $rd, 2 for $2
    wire [1:0] Jump;//0 for no jump, 1 for jump pc=next_pc+target_address, 2 for jump pc=$rs
    wire Branch;//for branch inst
    wire Memread;//for load inst
    wire Memwrite;//for store inst
    wire [1:0] MemtoReg;//0 for aluout, 1 for memory_data, 2 for nextpc
    wire [3:0] ALUOp;
    wire ALUSrc;//0 for regdata2, 1 for sign_extend
    wire Regwrite;
    wire WWD;//for wwd inst
    wire HLT;//for hlt inst
    wire numinst_cond;//numinst condition, 0 for flush

    reg [19:0] control_signal;    

    assign {Regdst, Jump, Branch, Memread, Memwrite, MemtoReg, ALUOp, ALUSrc, use_rs, use_rt, Regwrite, WWD, HLT, numinst_cond} = control_signal;
    assign ex_signal = {Regdst, ALUOp, ALUSrc};
    assign mem_signal = {Branch, Jump, Memread, Memwrite};
    assign wb_signal = {MemtoReg, Regwrite, WWD, HLT, numinst_cond};
    
    wire [3:0] op;
    wire [5:0] func;

    assign op = instruction[15:12];
    assign func = instruction[5:0];

    always @(*) begin
        case (op) 
            `OPCODE_BEQ : control_signal = {2'd0, 2'd0, 1'b1, 1'b0, 1'b0, 2'd0, `OP_EQ, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1};
            `OPCODE_BNE : control_signal = {2'd0, 2'd0, 1'b1, 1'b0, 1'b0, 2'd0, `OP_NE, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1};
            `OPCODE_BGZ : control_signal = {2'd0, 2'd0, 1'b1, 1'b0, 1'b0, 2'd0, `OP_GZ, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
            `OPCODE_BLZ : control_signal = {2'd0, 2'd0, 1'b1, 1'b0, 1'b0, 2'd0, `OP_LZ, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
            `OPCODE_JMP : control_signal = {2'd0, 2'd1, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
            `OPCODE_JAL : control_signal = {2'd2, 2'd1, 1'b0, 1'b0, 1'b0, 2'd2, `OP_ADD, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1};
            `OPCODE_ADI : control_signal = {2'd0, 2'd0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1};
            `OPCODE_ORI : control_signal = {2'd0, 2'd0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_OR, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1};
            `OPCODE_LHI : control_signal = {2'd0, 2'd0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_IDB, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1};
            `OPCODE_LWD : control_signal = {2'd0, 2'd0, 1'b0, 1'b1, 1'b0, 2'd1, `OP_ADD, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1};
            `OPCODE_SWD : control_signal = {2'd0, 2'd0, 1'b0, 1'b0, 1'b1, 2'd0, `OP_ADD, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1};
            `OPCODE_R :
            case (func)
                `FUNC_ADD : control_signal = {2'd1, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_ADD, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1};
                `FUNC_SUB : control_signal = {2'd1, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_SUB, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1};
                `FUNC_AND : control_signal = {2'd1, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_AND, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1};
                `FUNC_ORR : control_signal = {2'd1, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_OR, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1};
                `FUNC_NOT : control_signal = {2'd1, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_NOT, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1};
                `FUNC_TCP : control_signal = {2'd1, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_TCP, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1};
                `FUNC_SHL : control_signal = {2'd1, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_LLS, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1};
                `FUNC_SHR : control_signal = {2'd1, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_LRS, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1};
                `FUNC_WWD : control_signal = {2'd0, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_ADD, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1};
                `FUNC_JPR : control_signal = {2'd0, 2'd2, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_IDA, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
                `FUNC_JRL : control_signal = {2'd2, 2'd2, 1'b0 ,1'b0, 1'b0, 2'd2, `OP_IDA, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1};
                `FUNC_HLT : control_signal = {2'd0, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_ADD, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1};
                default : control_signal = {2'd0, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_ADD, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
            endcase
            default : control_signal = {2'd0, 2'd0, 1'b0 ,1'b0, 1'b0, 2'd0, `OP_ADD, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
        endcase                
    end






endmodule