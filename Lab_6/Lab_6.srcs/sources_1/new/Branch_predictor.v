`define MEMORY_SIZE 256	//	size of memory is 2^8 words (reduced size)
`define WORD_SIZE 16	//	instead of 2^16 words to reduce memory

module Branch_predictor(clk, reset_n, pc, ifid_nextpc, mem_signal, wb_signal, exmem_nextpc, exmem_targetaddr, exmem_mem_signal, predicted_pc, Vaild);
    input clk;
    input reset_n;
    input [15:0] pc;
    input [15:0] ifid_nextpc;
    input [4:0] mem_signal;
    input [5:0] wb_signal;
    input [15:0] exmem_nextpc;
    input [15:0] exmem_targetaddr;
    input [4:0] exmem_mem_signal;

    output [15:0] predicted_pc;
    output reg [`MEMORY_SIZE-1:0] Vaild;

    reg [1:0] counter;

    wire [15:0] ifid_pc, exmem_pc;
    wire [7:0] index, ifid_index, exmem_index;//8bit because BTB entry is 256
    wire [3:0] ifid_op;
    wire [1:0] ifid_jump, exmem_jump;
    wire ifid_branch, exmem_branch;
    reg [7:0] BTB [`MEMORY_SIZE-1:0];
    

    assign ifid_pc = ifid_nextpc-1;
    assign exmem_pc = exmem_nextpc-1;
    assign index = pc[7:0];
    assign ifid_index = ifid_pc[7:0];
    assign exmem_index = exmem_pc[7:0];
    assign ifid_jump = mem_signal[3:2];
    assign ifid_branch = mem_signal[4];
    assign exmem_jump = exmem_mem_signal[3:2];
    assign exmem_branch = exmem_mem_signal[4];


    assign predicted_pc = (Vaild[index]) ? BTB[index] : pc+1;

    integer i;
    //Vaild bit update
    always @(*) begin
        if(!reset_n) begin
            Vaild = 0;
            for (i = 0 ; i < `MEMORY_SIZE ; i = i+1) begin
                BTB [i] = 0;
            end
        end
        //instruction except branch, jump
        else if(ifid_jump == 2'd0 && !ifid_branch && wb_signal[0]) begin
            Vaild[ifid_index] = 1;
            BTB[ifid_index] = ifid_nextpc; 
        end 
        //branch, jump instruction
        else if(exmem_branch || exmem_jump) begin
            Vaild[exmem_index] = 1;
            BTB[exmem_index] = exmem_targetaddr;
        end
    end


    //BTB update
    //always @(posedge clk or negedge reset_n) begin
    //    if(!reset_n) begin
    //        
    //    end
    //    //instruction except branch, jump
    //    else if(ifid_jump == 2'd0 && !ifid_branch && wb_signal[0]) begin
    //    end 
    //    //branch, jump instruction
    //    else if(exmem_branch || exmem_jump) begin
    //    end
    //end
endmodule
