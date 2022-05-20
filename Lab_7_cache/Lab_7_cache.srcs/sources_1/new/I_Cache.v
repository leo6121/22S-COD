`define CACHE_SIZE 4

module I_Cache(clk, reset_n, pc, i_data, exmem_flush, i_readM, i_cache_data);
    input clk;
    input reset_n;
    input [15:0] pc;
    inout [63:0] i_data;
    input exmem_flush;

    output i_readM;//read signal for cache
    output reg [15:0] i_cache_data;

    reg [11:0] tag_bank [`CACHE_SIZE-1:0];
    reg cache_valid [`CACHE_SIZE-1:0];
    reg [63:0] data_bank [`CACHE_SIZE-1:0];//4 words
    reg [2:0] cache_counter;

    wire [1:0] bo;
    wire [1:0] index;
    wire hit, miss;

    assign bo = pc[1:0];
    assign index = pc[3:2];

    assign hit = (pc[15:4] == tag_bank[index]) && cache_valid[index];
    assign miss = (pc[15:4] != tag_bank[index]) || !cache_valid[index];

    assign i_readM = (!reset_n || hit) ? 1'b0 : 1'b1;

    //i_cache_data assign
    always @(*) begin
        case (bo)
            2'b00 : begin
                i_cache_data = (hit) ? data_bank[index][63:48] :
                               (miss && cache_counter == 3'd0) ? i_data[63:48] : 16'b0;
            end
            2'b01 : begin
                i_cache_data = (hit) ? data_bank[index][47:32] :
                               (miss && cache_counter == 3'd0) ? i_data[47:32] : 16'b0;
            end
            2'b10 : begin
                i_cache_data = (hit) ? data_bank[index][31:16] :
                               (miss && cache_counter == 3'd0) ? i_data[31:16] : 16'b0;
            end
            2'b11 : begin
                i_cache_data = (hit) ? data_bank[index][15:0] :
                               (miss && cache_counter == 3'd0) ? i_data[15:0] : 16'b0;
            end
        endcase
    end

    integer i;

    //cache update
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            for (i = 0 ; i < `CACHE_SIZE ; i=i+1) begin
                tag_bank [i] <= 0;
                cache_valid [i] <= 0;
                data_bank [i] <= 0;
            end
        end
        else if(miss) begin
            if(cache_counter == 3'd0) begin
                tag_bank[index] <= pc[15:4];
                cache_valid[index] <= 1;
                data_bank[index] <= i_data;
            end
        end
    end

    //cache counter update
    always @(negedge clk) begin
        if(!reset_n) begin
            cache_counter <= 3'd7;
        end
        else if(i_readM) begin
            cache_counter <=(cache_counter == 3'd7) ? 3'd1 : 
                            (cache_counter == 3'd3) ? 3'd0 : cache_counter+1;
        end
    end
endmodule
