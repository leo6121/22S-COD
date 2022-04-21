`include "opcodes.v"
`include "constants.v"

module Control (clk, reset_n, instruction, PCWriteCond, PCWrite, Memaddr, MemRead, MemWrite, Writedata, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst, wwd, hlt, num_inst);
    input clk;
    input reset_n;
    input [`WORD_SIZE-1:0] instruction;
    
    output PCWriteCond;//1 for branch instruction
    output PCWrite;//1 for update pc 
    output Memaddr;//o for pc, 1 for aluout
    output MemRead;//1 for load instruction
    output MemWrite;//1 for store instruction
    output Writedata;//0 for aluout, 1 for Memory data
    output IRWrite;// 1 for instruction fetching
    output [1:0] PCSource;//0 for aluresult, 1 for pc[15:12]+target[11:0], 2 for regdata1
    output [3:0] ALUOp;//ALU opcode
    output [1:0] ALUSrcA;// 0 for regdata1, 1 for pc, 2 for aluout
    output [1:0] ALUSrcB;// 0 for regdata2, 1 for 1(use when pc <= pc+1 and JAL inst), 2 for sign-extend
    output RegWrite;//1 for RF write_enable
    output [1:0] RegDst;//0 for rt, 1 for rd, 2 for $2
    output wwd;//1 for wwd instruction
    output hlt;//1 for hlt instruction
    output reg [`WORD_SIZE-1:0] num_inst;


    wire [3:0] op;
    wire [5:0] func;
    reg [24:0] control_signal;
    reg [2:0] stage; // state machine for control unit
    wire [2:0] next_stage;

    assign op = instruction[15:12];
    assign func = instruction[5:0];

    assign {next_stage, PCWriteCond, PCWrite, Memaddr, MemRead, MemWrite, Writedata, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst, wwd, hlt} = control_signal;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            stage <= `EX_STAGE;
        end
        else begin
            stage <= next_stage;
        end
    end

    always @(*) begin
        case (stage)
            `IF_STAGE: 
            control_signal = {`ID_STAGE, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'd0, `OP_ADD, 2'd1, 2'd1, 1'b0, 2'd0, 1'b0, 1'b0};
            //use alu for pc = pc+1
            `ID_STAGE: 
            case (op)
                `OPCODE_JMP://pc <= pc[15:12] + target[11:0]
                control_signal = {`IF_STAGE, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd1, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_JAL://$2 <= pc+1, pc <= pc[15:12] + target[11:0]
                control_signal = {`IF_STAGE, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd1, `OP_ADD, 2'd0, 2'd0, 1'b1, 2'd2, 1'b0, 1'b0};
                `OPCODE_BEQ, `OPCODE_BNE, `OPCODE_BGZ, `OPCODE_BLZ://use alu for (pc+1(aluout))+offset
                control_signal = {`EX_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd2, 2'd2, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_ADI, `OPCODE_ORI, `OPCODE_LHI:
                control_signal = {`EX_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 1'b0, 2'd0, 1'b0};
                `OPCODE_LWD:
                control_signal = {`EX_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_SWD:
                control_signal = {`EX_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_R:
                case (func)
                    `FUNC_ADD, `FUNC_SUB, `FUNC_AND, `FUNC_ORR, `FUNC_NOT, `FUNC_TCP, `FUNC_SHL, `FUNC_SHR:
                    control_signal = {`EX_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                    `FUNC_JPR://pc <= $rs
                    control_signal = {`IF_STAGE, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd2, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                    `FUNC_JRL://pc <= $rs, 2$ <= pc+1
                    control_signal = {`IF_STAGE, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd2, `OP_ADD, 2'd0, 2'd0, 1'b1, 2'd2, 1'b0, 1'b0};
                    `FUNC_WWD:
                    control_signal = {`IF_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b1, 1'b0};
                    `FUNC_HLT:
                    control_signal = {`IF_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b1};
                    default:
                    control_signal = {`ERR, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                endcase
                default:
                control_signal = {`ERR, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};                
            endcase
            `EX_STAGE:
            case (op)
                `OPCODE_BEQ:
                control_signal = {`IF_STAGE, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_EQ, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_BNE:
                control_signal = {`IF_STAGE, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_NE, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_BGZ:
                control_signal = {`IF_STAGE, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_GZ, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_BLZ:
                control_signal = {`IF_STAGE, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_LZ, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_ADI:
                control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd2, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_ORI:
                control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_OR, 2'd0, 2'd2, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_LHI:
                control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_IDB, 2'd0, 2'd2, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_LWD:
                control_signal = {`MEM_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd2, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_SWD:
                control_signal = {`MEM_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd2, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_R:
                case (func)
                    `FUNC_ADD:
                    control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd1, 1'b0, 1'b0};
                    `FUNC_SUB:
                    control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_SUB, 2'd0, 2'd0, 1'b0, 2'd1, 1'b0, 1'b0};
                    `FUNC_AND:
                    control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_AND, 2'd0, 2'd0, 1'b0, 2'd1, 1'b0, 1'b0};
                    `FUNC_ORR:
                    control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_OR, 2'd0, 2'd0, 1'b0, 2'd1, 1'b0, 1'b0};
                    `FUNC_NOT:
                    control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_NOT, 2'd0, 2'd0, 1'b0, 2'd1, 1'b0, 1'b0};
                    `FUNC_TCP:
                    control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_TCP, 2'd0, 2'd0, 1'b0, 2'd1, 1'b0, 1'b0};
                    `FUNC_SHL:
                    control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_LLS, 2'd0, 2'd0, 1'b0, 2'd1, 1'b0, 1'b0};
                    `FUNC_SHR:
                    control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_LRS, 2'd0, 2'd0, 1'b0, 2'd1, 1'b0, 1'b0};
                    default:
                    control_signal = {`ERR, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                endcase
                default:
                control_signal = {`ERR, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};            
            endcase
            `MEM_STAGE:
            case (op)
                `OPCODE_LWD:
                control_signal = {`WB_STAGE, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                `OPCODE_SWD:
                control_signal = {`IF_STAGE, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                default: 
                control_signal = {`ERR, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
            endcase
            `WB_STAGE:
            case (op)
                `OPCODE_ADI, `OPCODE_ORI, `OPCODE_LHI:
                control_signal = {`IF_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b1, 2'd0, 1'b0, 1'b0};
                `OPCODE_LWD:
                control_signal = {`IF_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b1, 2'd0, 1'b0, 1'b0};
                `OPCODE_R:
                case (func)
                    `FUNC_ADD, `FUNC_SUB, `FUNC_AND, `FUNC_ORR, `FUNC_NOT, `FUNC_TCP, `FUNC_SHL, `FUNC_SHR:
                    control_signal = {`IF_STAGE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b1, 2'd1, 1'b0, 1'b0};
                    default: 
                    control_signal = {`ERR, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
                endcase
                default: 
                control_signal = {`ERR, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
            endcase
            default:
            control_signal = {`ERR, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, `OP_ADD, 2'd0, 2'd0, 1'b0, 2'd0, 1'b0, 1'b0};
        endcase
    end



    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            num_inst <= -`WORD_SIZE'b1;
        end
        else if(stage == `IF_STAGE) begin
            num_inst <= num_inst + `WORD_SIZE'b1;
        end
    end
endmodule