module scheduler #(
    parameter N_COUNT = 256,
    parameter GRANULARITY = 4,
    parameter PKT_SIZE = 32
) 
(
    input logic clk,    //local
    input logic tick,   //global
    input logic [PKT_SIZE-1:0] router_packet, //r2s
    input logic router_packet_recieve,  //r2s
    input logic dropped_c2r,    //c2r

    output logic [(PKT_SIZE - GRANULARITY) - 1:0] send_to_controller, //r2s
    output logic send_to_controller_flag
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
logic send_next;

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
    send_to_controller_flag -> flag to let controller know that we are sending it a packet

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
    send_next -> signal to send the next packet to the controller, triggered by either a dropped packet or the instruction counter reaching zero

instantiated modules: 
    r_fifo -> the rotating fifos for the "scheduling"
*/

generate  
    for ( genvar i = 0; i < GRANULARITY; i++ ) begin
        fifo #(.WIDTH(PKT_SIZE), .DEPTH(N_COUNT)) r_fifo (.clk(clk), .rst(1'b0), .in(r_in[i]), .wr_en(r_wr_en[i]), .rd_en(r_rd_en[i]), .full(r_full[i]), .empty(r_empty[i]), .out(r_stc_out[i]));
    end
endgenerate


//AOI2?    
assign send_next = (dropped_c2r || (inst_counter == '0)) && ~(r_empty[tick_ptr]);    

always_ff @( posedge tick ) begin : update_tick
    tick_ptr <= tick_ptr + 1'b1;
end

always_ff @( posedge clk ) begin : let_values_in
    for (int i = 0; i < GRANULARITY; i++) begin
        r_wr_en[i] <= 1'b0;
    end

    if(router_packet_recieve) begin
        r_in[router_packet[PKT_SIZE-1 : (PKT_SIZE - GRANULARITY)]] <= router_packet;
        r_wr_en[router_packet[PKT_SIZE-1 : (PKT_SIZE - GRANULARITY)]] <= 1'b1;
    end
end

always_ff @( posedge clk ) begin : update_rotated_fifo_rd_en
    for (int i = 0; i < GRANULARITY; i++) begin //should unroll? pls define default values pls
        r_rd_en[i] <= 1'b0;
    end

    if(send_next) begin
        r_rd_en[tick_ptr] <= 1'b1;
    end
end

always_ff @( posedge clk ) begin : to_controller_update_counter
    if(send_next) begin
        send_to_controller <= r_stc_out[tick_ptr][(PKT_SIZE - GRANULARITY) - 1:0];
        inst_counter <= r_stc_out[tick_ptr][7:0]; //eventually parameterize?
        send_to_controller_flag <= 1'b1;
    end 
    else begin
        send_to_controller <= '0;
        inst_counter <= inst_counter - 1'b1;
        send_to_controller_flag <= 1'b0;
    end
end

    
endmodule