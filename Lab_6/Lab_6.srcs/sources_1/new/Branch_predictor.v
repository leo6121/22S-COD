`define MEMORY_SIZE 256	//	size of memory is 2^8 words (reduced size)
`define WORD_SIZE 16	//	instead of 2^16 words to reduce memory

module Branch_predictor(clk, reset_n, pc, mem_signal, wb_signal, exmem_nextpc, exmem_targetaddr, exmem_mem_signal, predicted_pc);
    input clk;
    input reset_n;
    input [15:0] pc;
    input [4:0] mem_signal;
    input [5:0] wb_signal;
    input [15:0] exmem_nextpc;
    input [15:0] exmem_targetaddr;
    input [4:0] exmem_mem_signal;

    output [15:0] predicted_pc;

    reg [1:0] counter;

    wire [15:0] exmem_pc;
    wire [7:0] index, exmem_index;//8bit because BTB entry is 256
    wire exmem_branch;
    reg [7:0] BTB [`MEMORY_SIZE-1:0];
    reg Vaild [`MEMORY_SIZE-1:0];    

    assign exmem_pc = exmem_nextpc-1;
    assign index = pc[7:0];
    assign exmem_index = exmem_pc[7:0];
    assign exmem_jump = exmem_mem_signal[3:2];
    assign exmem_branch = exmem_mem_signal[4];

    assign predicted_pc = (Vaild[index]) ? BTB[index] : pc+1;

    integer i;

    //BTB update
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            for (i = 0 ; i < `MEMORY_SIZE ; i = i+1) begin
                Vaild [i] <= 0;
                BTB [i] <= 0;
            end
        end
        //branch, jump instruction
        else if(exmem_branch || exmem_jump) begin
            Vaild[exmem_index] <= 1;
            BTB[exmem_index] <= exmem_targetaddr;
        end
    end
endmodule
