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

endmodule : cpu