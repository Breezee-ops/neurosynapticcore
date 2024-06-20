module scheduler #(
    parameter N_COUNT = 256,
    parameter GRANULARITY = 4,
    parameter PKT_SIZE = 32
) 
(
    input logic clk,
    input logic tick,
    input logic [PKT_SIZE-1:0] router_packet,
    input logic router_packet_recieve,
    input logic dropped_c2r,

    output [(PKT_SIZE - GRANULARITY) - 1:0] send_to_controller
);

localparam n_count_clog2 = $clog2(N_COUNT);
localparam TICK_WIDTH = $clog2(GRANULARITY);

// identify which rotating fifo we wan look at for output
logic [TICK_WIDTH-1:0] tick_ptr;

// for fifos
logic [PKT_SIZE-1:0] r_in [GRANULARITY];
logic [PKT_SIZE-1:0] r_stc_out[GRANULARITY];
logic r_wr_en [GRANULARITY];
logic r_rd_en [GRANULARITY];
logic r_full[GRANULARITY];
logic r_empty[GRANULARITY];

logic [7:0] inst_counter;

/*
Edit History: 
- 6/19/24 V - make initial module

Notes: 
- This module assumes that all packets are sent in serially

Parameter meanings: 
    N_COUNT -> how many neurons exist in the total design
    GRANULARITY -> the number of ticks an operation is allowed to be in the future -> max number of ticks an operation can stay in the scheduler till being dropped or sent out
                -> this should (hopefully) always be a power of two for simplicity
    PKT_SIZE -> size of packet coming from router in bits

Port meanings:
    inputs:
    clk -> local clock 
    tick -> global tick
    router_packet -> packet that is being sent to the router to the scheduler
    router_packet_recieve -> router is telling scheduler that there is a packet to recieve -> basically a write enable
    dropped_c2r -> the controller requests that the next packet be given if it has dropped it's current instruction??? 
                  -> is this neccessary? 

    outputs: 
    send_to_controller -> packet that is being sent to controller

localparam meanings: 
    n_count_clog2 -> ceil(log2(N_COUNT)) -> ceiling of log base 2 of the number of neurons
    TICK_WIDTH -> ceil(log2(GRANULARITY)) -> ceiling of log base 2 of the tick granularity

internal signal meanings:
    tick_ptr -> what tick are we on -> we only keep track of the first couple of bits of the tick we are on, this allows us to rotate through the fifos
    r_in -> unpacked array that helps us input values into the rotating fifos
    r_wr_en -> unpacked array for wr_en for rotating fifos
    r_rd_en -> unpacked array for rd_en for rotating fifos
    r_stc_out -> unpacked array for full signal for rotating fifos
    r_empty -> unpacked array for empty signal for rotating fifos
    inst_counter -> counter for the number of clock cycles that an instruction should take, once it reaches zero the next packet is sent to the controller

instantiated modules: 
    r_fifo -> the rotating fifos for the "scheduling"
*/

// probably not completely correct at the moment, will fix soon I swear
generate : make_fifos   
    for ( genvar i = 0; i < GRANULARITY; i++ ) begin
        fifo r_fifo[i] #(PKT_SIZE, N_COUNT)
                        (.clk(clk), .in(r_in[i]), .wr_en(r_wr_en[i]), .rd_en(r_rd_en[i]), .full(r_full[i]), .empty(r_empty[i]), .out(r_stc_out[i]));
    end
endgenerate

always_ff @( posedge tick ) begin : update_tick
    tick_ptr <= tick_ptr + 1'b1;
end

always_ff @( posedge clk ) begin : update_rotated_fifo
    //update our read pointers here
end

/* send our packet (smaller?) to the controller */ 
always_ff @( posedge clk ) begin : to_controller
    if(send_next) begin
        rd_en <= 1'b1;
        send_to_controller <= r_stc_out[tick_ptr][(PKT_SIZE - GRANULARITY) - 1:0];
    end 
    else begin
        rd_en <= 1'b0;
        send_to_controller <= '0;
    end
end


    
endmodule