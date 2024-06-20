module scheduler #(
    parameter N_COUNT = 256,
    parameter GRANULARITY = 4,
    parameter PKT_SIZE = 32
) 
(
    input logic clk,
    input logic tick,
    input logic [PKT_SIZE-1:0] router_packet,

    output [(PKT_SIZE - GRANULARITY) - 1:0] send_to_controller
);

localparam n_count_clog2 = $clog2(N_COUNT);
localparam granulaity_clog2 = $clog2(GRANULARITY);


/*
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

    outputs: 
    send_to_controller -> packet that is being sent to controller

localparam meanings: 
    n_count_clog2 -> ceil(log2(N_COUNT)) -> ceiling of log base 2 of the number of neurons
    granularity_clog2 -> ceil(log2(GRANULARITY)) -> ceiling of log base 2 of the number of neurons

internal signal meanings:
*/



    generate
        for ( genvar i = 0; i < GRANULARITY; i++ ) begin
            fifo fifo[i]
            
        end
    endgenerate


    
endmodule