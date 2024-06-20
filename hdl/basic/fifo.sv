module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input logic clk, 
    input logic [WIDTH - 1 : 0] in,
    input logic wr_en,
    input logic rd_en, 

    output logic full, 
    output logic empty,
    output logic [WIDTH - 1 : 0] out
);

localparam PTR_WIDTH = unsigned'( $clog2(DEPTH) );

logic [PTR_WIDTH : 0] wr_ptr;
logic [PTR_WIDTH : 0] rd_ptr;

logic [WIDTH - 1 : 0] buf [DEPTH];

/*
Paramter meanings: 
    WIDTH -> how large the inputs and outputs of the fifo are in bits
    DEPTH -> how deep the fifo is -> number of slots for data in the fifo -> DEPTH = 8 means only 8 items can be stored at a time

Port meanings: 
    inputs:
    clk -> local clk
    in -> input to the fifo
    wr_en -> write enable -> data can only enter the fifo if this signal is enabled
    rd_en -> read enable -> data can only exit the fifo is this signal is enabled

    outputs: 
    full -> the fifo is full -> there is no room for more data, derived from read and write pointers
    empty -> the fifo is empty -> the fifo hungers, derived from read and write pointers
    out -> output of the fifo

localparam meanings:
    PTR_WIDTH -> one less that the width of read and write pointers in bits, derived from DEPTH
    
internal signal meanings: 
    wr_ptr -> the write pointer -> pointer to the location in the fifo where data can be entered
    rd_ptr -> the read pointer -> pointer to the location in the fifo where data can be read from
    buf -> buffer that holds the data of our fifo of WIDTH bits and is DEPTH entries 
*/


always_ff @( posedge clk ) begin : ptr_inc
    if(rst) begin
        wr_ptr <= '0;
        rd_ptr <= '0;
    end
    else begin
        if(wr_en && !full) begin
            if(wr_ptr[PTR_WIDTH-1:0] == unsigned'(PTR_WIDTH'(DEPTH-1))) begin
                wr_ptr[PTR_WIDTH - 1:0] <= '0;
                wr_ptr[PTR_WIDTH] <= ~wr_ptr[PTR_WIDTH];
            end
            else begin
                wr_ptr <= wr_ptr + 1'b1;
            end
        end

        if(rd_en && !empty) begin
            if(rd_ptr[PTR_WIDTH-1:0] == unsigned'(PTR_WIDTH'(DEPTH-1))) begin
                rd_ptr[PTR_WIDTH-1:0] <= '0;
                rd_ptr[PTR_WIDTH] <= ~rd_ptr[PTR_WIDTH];
            end
            else begin
                rd_ptr <= rd_ptr + 1'b1;
            end
        end
    end
end

always_ff @( posedge clk ) begin : write
    if(wr_en && !full) begin
        buf[wr_ptr[PTR_WIDTH-1:0]] <= in;
    end
end

always_comb begin : read
    if(rd_en && !empty) begin
        out = buf[rd_ptr];
    end
    else begin
        out = '0;   //don't think verilator supports x's so changed to '0
    end
end

assign full = (wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]) && (wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]);
assign empty = (wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]) && (wr_ptr[PTR_WIDTH] == rd_ptr[PTR_WIDTH]);


endmodule