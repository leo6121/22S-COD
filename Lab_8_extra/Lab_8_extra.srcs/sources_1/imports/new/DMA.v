`define WORD_SIZE 16
/*************************************************
* DMA module (DMA.v)
* input: clock (CLK), bus request (BR) signal, 
*        data from the device (edata), and DMA command (cmd)
* output: bus grant (BG) signal 
*         READ signal
*         memory address (addr) to be written by the device, 
*         offset device offset (0 - 2)
*         data that will be written to the memory
*         interrupt to notify DMA is end
* You should NOT change the name of the I/O ports and the module name
* You can (or may have to) change the type and length of I/O ports 
* (e.g., wire -> reg) if you want 
* Do not add more ports! 
*************************************************/

module DMA (
    input CLK, BG,
    input [4 * `WORD_SIZE - 1 : 0] edata,
    input cmd,
    output reg BR, READ,
    output [`WORD_SIZE - 1 : 0] addr, 
    output [4 * `WORD_SIZE - 1 : 0] data,
    output reg [1:0] offset,
    output reg interrupt);

    /* Implement your own logic */
    reg [2:0] dma_counter;


    assign addr = 16'h1f4 + offset * 4;
    assign data = edata;

    //dma_counter update
    always @(posedge CLK) begin
        if(BG) dma_counter <= (dma_counter == 3'd3) ? 3'd0 : dma_counter+1;
        else dma_counter =3'd0; 
    end

    //offset update
    always @(posedge cmd) begin
        offset <= 2'd0;
    end
    always @(posedge CLK) begin
        if(BG && dma_counter == 3'd3) offset <= (offset == 2'd2) ? 2'd0 : offset+1;
    end

    //READ update
    always @(posedge BG) begin
        READ <= 1;
    end
    always @(posedge CLK) begin
        if(!BG) READ <= 0;
    end

    //BR update
    always @(posedge cmd) begin
        BR <= 1;
    end
    always @(posedge CLK) begin
        if(dma_counter == 3'd3) BR <= 0;
        else if(offset != 2'd0) BR <= 1;
    end

    //interrupt update
    always @(negedge BG) begin
        interrupt <= 1;
    end
    always @(posedge CLK) begin
        interrupt <= 0;
    end



endmodule


