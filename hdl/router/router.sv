module router(
    input  logic         clk,
    input  logic         rst,

    input  logic [1:0]   core_id,

    input  logic [33:0]  recieve_packet_east,
    input  logic [33:0]  recieve_packet_west,

    output logic [33:0]  send_packet_east,
    output logic [33:0]  send_packet_west,
    output logic [33:0]  send_scheduler
);

    logic [1:0]   direction_route;
    logic [33:0]  packet_to_send;

    always_comb begin
        packet_to_send = '0;
        if(recieve_packet_east) begin
            packet_to_send = recieve_packet_east;
         end
        else if(recieve_packet_west) begin
            packet_to_send = recieve_packet_west;
         end
    end

    always_comb begin
        send_packet_east = '0;
        send_packet_west = '0;
        send_scheduler = '0;
        
        if ((direction_route) == core_id) send_scheduler = packet_to_send;
        else if (direction_route > core_id) send_packet_east = packet_to_send;
        else  send_packet_west = packet_to_send;
    end

    assign direction_route = packet_to_send[33:31];

endmodule : router
