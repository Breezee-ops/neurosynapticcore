module router(
    input  logic         clk,
    input  logic         rst
    //below signals to be commented in when making all the connections

    input  logic [1:0]   core_id,
    
    input  logic [33:0]  recieve_packet_east,
    input  logic [33:0]  recieve_packet_west,
    input  logic [33:0]  recieve_packet_north,
    input  logic [33:0]  recieve_packet_south,
    
    input  logic         recieve_east_ack,
    input  logic         recieve_west_ack,
    input  logic         recieve_north_ack,
    input  logic         recieve_south_ack,

    output  logic        send_east_ack,
    output  logic        send_west_ack,
    output  logic        send_north_ack,
    output  logic        send_south_ack,
    
    output logic [31:0]  send_packet_east,
    output logic [31:0]  send_packet_west,
    output logic [31:0]  send_packet_north,
    output logic [31:0]  send_packet_south,

    output logic         send_east_req,
    output logic         send_west_req,
    output logic         send_north_req,
    output logic         send_south_req,

    output logic [31:0]  send_scheduler
); 

    // Basically, recieve incoming packets from four directions, following a fully-connected apology, using metadata from the packet decide the direction,
    // select the correct direction of the packet or send it to the scheduler. Once determined the direction, keep sending out the req to 
    // that direction, until you recieve an ack from that direction, after which you can discard that and move to the next 

    //Challenges: Need a flip flop to store the packet to be forwarded, calculation of the coordinates for south and north transactions
    //

    logic [1:0]   direction_route;
    logic [31:0]  packet_to_send

    always_comb begin 
        if(recieve_packet_east) begin
            send_east_ack = 1'b1;
            direction_route = recieve_packet_east[33:31]
            packet_to_send = recieve_packet_east;
         end
        else if(recieve_packet_west) begin
            send_west_ack = 1'b1;
            direction_route = recieve_packet_west[33:31]
            packet_to_send = recieve_packet_west;
         end
        else if(recieve_packet_north) begin
            send_north_ack = 1'b1;
            direction_route = recieve_packet_north[33:31]
            packet_to_send = recieve_packet_north;
         end
        else if(recieve_packet_south) begin
            send_south_ack = 1'b1;
            direction_route = recieve_packet_south[33:31]
            packet_to_send = recieve_packet_south;
        end
    end

    always_comb begin 
        if ((direction_route) == core_id) begin 
            send_scheduler = packet_to_send;
        end 
        else if (direction_route > core_id) begin 
            send_east_req = 1'b1;
            send_packet_east = packet_to_send;
        end 
        else begin 
            send_west_ack = 1'b1;
            send_packet_west = packet_to_send;
        end
    end

endmodule : router 