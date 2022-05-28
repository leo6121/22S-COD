`define CACHE_SIZE 4

module D_Cache(clk, reset_n, d_address, d_data, exmem_mem_signal, BR, d_readM, d_writeM, d_cache_data, BG, cache_miss);
    input clk;
    input reset_n;
    input [15:0] d_address;
    inout [63:0] d_data;
    input [4:0] exmem_mem_signal;//{Branch, Jump, Memread, Memwrite}
    input BR;

    output d_readM;//read signal for d_cache
    output d_writeM;//write signal for d_cache
    output reg [15:0] d_cache_data;
    output reg BG;
    output cache_miss;//signal for block mem stage while dma operating

    reg [11:0] d_tag_bank [`CACHE_SIZE-1:0];
    reg d_cache_valid [`CACHE_SIZE-1:0];
    reg [63:0] d_data_bank [`CACHE_SIZE-1:0];//4 words
    reg [2:0] d_cache_counter;
    wire use_dmem;//1 for accessing data memory

    wire [1:0] bo;
    wire [1:0] index;
    wire hit, miss;

    assign bo = d_address[1:0];
    assign index = d_address[3:2];

    assign hit = (d_address[15:4] == d_tag_bank[index]) && d_cache_valid[index] && exmem_mem_signal[1:0] != 2'd0;
    assign miss = ((d_address[15:4] != d_tag_bank[index]) || !d_cache_valid[index]) && exmem_mem_signal[1:0] != 2'd0;

    assign d_readM = (!reset_n || (exmem_mem_signal[1] && hit) || BG) ? 1'b0 :
                     (exmem_mem_signal[1] && miss) ? 1'b1 : 1'b0;
    assign d_writeM = (!reset_n || BG) ? 1'b0 : 
                      (exmem_mem_signal[0]) ? 1'b1 : 1'b0;

    assign use_dmem = (d_cache_counter != 3'd0 && d_cache_counter != 3'd7) || d_readM || d_writeM;

    assign cache_miss = (exmem_mem_signal[0] || (exmem_mem_signal[1] && miss)) && BG;

    always @(posedge clk or negedge reset_n or negedge BR) begin
        if(!reset_n) BG <= 0;
        else if(!use_dmem && BR) BG <= 1;
        else BG <= 0;
    end

    //d_cache_data assign
    always @(*) begin
        case (bo)
            2'b00 : begin
                d_cache_data = (exmem_mem_signal[1] && hit) ? d_data_bank[index][63:48] :
                               (exmem_mem_signal[1] && miss && d_cache_counter == 3'd0) ? d_data[63:48] : 16'b0;
            end
            2'b01 : begin
                d_cache_data = (exmem_mem_signal[1] && hit) ? d_data_bank[index][47:32] :
                               (exmem_mem_signal[1] && miss && d_cache_counter == 3'd0) ? d_data[47:32] : 16'b0;
            end
            2'b10 : begin
                d_cache_data = (exmem_mem_signal[1] && hit) ? d_data_bank[index][31:16] :
                               (exmem_mem_signal[1] && miss && d_cache_counter == 3'd0) ? d_data[31:16] : 16'b0;
            end
            2'b11 : begin
                d_cache_data = (exmem_mem_signal[1] && hit) ? d_data_bank[index][15:0] :
                               (exmem_mem_signal[1] && miss && d_cache_counter == 3'd0) ? d_data[15:0] : 16'b0;
            end
        endcase
    end

    integer i;

    //cache update
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            for (i = 0 ; i < `CACHE_SIZE ; i=i+1) begin
                d_tag_bank [i] <= 0;
                d_cache_valid [i] <= 0;
                d_data_bank [i] <= 0;
            end
        end
        //Load
        else if(exmem_mem_signal[1]) begin
            if(miss) begin
                if(d_cache_counter == 3'd0) begin
                    d_tag_bank[index] <= d_address[15:4];
                    d_cache_valid[index] <= 1;
                    d_data_bank[index] <= d_data;
                end
            end
        end
        //Store with write-through & write-no-allocate
        else if(exmem_mem_signal[0]) begin
            if(hit) begin
                case (bo)
                    2'b00 : d_data_bank[index][63:48] <= d_data[63:48];
                    2'b01 : d_data_bank[index][47:32] <= d_data[63:48];
                    2'b10 : d_data_bank[index][31:16] <= d_data[63:48];
                    2'b11 : d_data_bank[index][15:0] <= d_data[63:48];
                endcase
            end
        end
        
    end

    //cache counter update
    always @(negedge clk) begin
        if(!reset_n) begin
            d_cache_counter <= 3'd7;
        end
        else if(d_readM || d_writeM) begin
            d_cache_counter <=(d_cache_counter == 3'd7) ? 3'd1 :
                              (d_cache_counter == 3'd3) ? 3'd0 : d_cache_counter+1;
        end
    end
endmodule
