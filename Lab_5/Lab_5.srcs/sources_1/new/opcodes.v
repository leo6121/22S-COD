`ifndef OPCODES_V
`define OPCODES_V

`define FUNC_ADD 6'd0
`define FUNC_SUB 6'd1
`define FUNC_AND 6'd2
`define FUNC_ORR 6'd3
`define FUNC_NOT 6'd4
`define FUNC_TCP 6'd5
`define FUNC_SHL 6'd6
`define FUNC_SHR 6'd7
`define FUNC_WWD 6'd28
`define FUNC_JPR 6'd25
`define FUNC_JRL 6'd26
`define FUNC_HLT 6'd29

`define OPCODE_ADI 4'd4
`define OPCODE_ORI 4'd5
`define OPCODE_LHI 4'd6
`define OPCODE_LWD 4'd7
`define OPCODE_SWD 4'd8
`define OPCODE_BNE 4'd0
`define OPCODE_BEQ 4'd1
`define OPCODE_BGZ 4'd2
`define OPCODE_BLZ 4'd3
`define OPCODE_JMP 4'd9
`define OPCODE_JAL 4'd10
`define OPCODE_R 4'd15



// >>> ALU >>>
`define	OP_ADD	4'b0000
`define	OP_SUB	4'b0001
`define	OP_IDA	4'b0010
`define	OP_IDB	4'b0011
`define	OP_LLS  4'b0100
`define	OP_XNOR	4'b0101
`define	OP_NOT	4'b0110
`define	OP_AND	4'b0111
`define	OP_OR	4'b1000
`define	OP_XOR	4'b1001
`define	OP_LRS	4'b1010
`define	OP_TCP	4'b1011
`define	OP_EQ	4'b1100
`define	OP_GZ	4'b1101
`define	OP_LZ	4'b1110
`define	OP_NE	4'b1111
// <<< ALU <<<

`define IF_STAGE 3'd0
`define ID_STAGE 3'd1
`define EX_STAGE 3'd2
`define MEM_STAGE 3'd3
`define WB_STAGE 3'd4
`define ERR     3'd7

`endif