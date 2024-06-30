module cpu (
    input  logic               clk,
    input  logic               rst,
    output logic   [31:0]      bmem_addr,
    output logic               bmem_read,
    output logic               bmem_write,
    output logic   [63:0]      bmem_wdata,
    input  logic               bmem_ready,

    input  logic   [31:0]      bmem_raddr,
    input  logic   [63:0]      bmem_rdata,
    input  logic               bmem_rvalid
);

assign bmem_addr = '0;
assign bmem_read = '0;
assign bmem_write = '0;

logic [33:0] router_core_00_east_connection;
logic [33:0] router_core_00_west_connection;
logic [31:0] core_00_scheduler_packet;

logic [33:0] router_core_01_east_connection;
logic [33:0] router_core_01_west_connection;
logic [31:0] core_01_scheduler_packet;

logic [33:0] router_core_10_east_connection;
logic [33:0] router_core_10_west_connection;
logic [31:0] core_10_scheduler_packet;

logic [33:0] router_core_11_east_connection;
logic [33:0] router_core_11_west_connection;
logic [31:0] core_11_scheduler_packet;

router core_00(
    .core_id(2'b00),
    .recieve_packet_east(router_core_01_west_connection),
    .recieve_packet_west(router_core_11_east_connection),
    .send_packet_east(router_core_00_east_connection),
    .send_packet_west(router_core_00_west_connection),
    .send_scheduler(core_00_scheduler_packet)
);

router core_01(
    .core_id(2'b01),
    .recieve_packet_east(router_core_10_west_connection),
    .recieve_packet_west(router_core_00_east_connection),
    .send_packet_east(router_core_01_east_connection),
    .send_packet_west(router_core_01_west_connection),
    .send_scheduler(core_01_scheduler_packet)
);

router core_10(
    .core_id(2'b10),
    .recieve_packet_east(router_core_11_west_connection),
    .recieve_packet_west(router_core_01_east_connection),
    .send_packet_east(router_core_10_east_connection),
    .send_packet_west(router_core_10_west_connection),
    .send_scheduler(core_10_scheduler_packet)
);

router core_11(
    .core_id(2'b11),
    .recieve_packet_east(router_core_00_west_connection),
    .recieve_packet_west(router_core_10_east_connection),
    .send_packet_east(router_core_11_east_connection),
    .send_packet_west(router_core_11_west_connection),
    .send_scheduler(core_11_scheduler_packet)
);


endmodule : cpu