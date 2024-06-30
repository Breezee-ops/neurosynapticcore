module dadda_multiplier
// import rv32i_types::*;
(
    input logic clk,
    input logic rst,
    input logic start,
    input logic [1:0] mul_type,

    input logic[31:0] a_multiply,
    input logic[31:0] b_multiply,

    output logic[31:0] answer,
    output logic mul_done,

    output logic        multiplier_ready
);

`define UNSIGNED_UNSIGNED_MUL 2'b00
`define SIGNED_SIGNED_MUL     2'b01
`define SIGNED_UNSIGNED_MUL   2'b10

logic multiplication_done;
logic [63:0] p;
logic [31:0] a_reg;
logic [31:0] b_reg;
logic [63:0] product1;
logic [63:0] product2;
logic [63:0] product3;
logic [63:0] product4;
logic [63:0] product5;
logic [63:0] product6;
logic [63:0] product7;
logic [63:0] product8;
logic [63:0] product9;
logic [63:0] product10;
logic        neg_result;

enum int unsigned {s_idle, s_comp, s_done_1, s_done_2, s_done_3, s_done_4, s_done_5, s_done_6, s_done_7, s_done_8, s_done_9, s_done_10, s_finally_done} state, next_state;

 always_ff @ (posedge clk) begin
    if (rst)
    begin
        state <= s_idle;
        a_reg <= '0;
        b_reg <= '0;
        product1 <= '0;
        product2 <= '0;
        product3 <= '0;
        product4 <= '0;
        product4 <= '0;
        product5 <= '0;
        product6 <= '0;
        product7 <= '0;
        product8 <= '0;
        product9 <= '0;
        product10 <= '0;
    end

    if(start) begin

        unique case(mul_type)
            `UNSIGNED_UNSIGNED_MUL: begin
                neg_result <= '0;
                a_reg <= {{32{1'b0}}, a_multiply};
                b_reg <= b_multiply;
            end
            `SIGNED_SIGNED_MUL: begin
                neg_result <= (a_multiply[31] ^ b_multiply[31]) && ((a_multiply != '0) && (b_multiply != '0));
                a_reg <= (a_multiply[31]) ? {32*{1'b0}, (~a_multiply + 1'b1)} : a_multiply;
                b_reg <= (b_multiply[31]) ? {(~b_multiply + 1'b1)} : b_multiply;
            end
            `SIGNED_UNSIGNED_MUL: begin
                neg_result <= a_multiply[31];
                a_reg <= (a_multiply[31]) ? {32*{1'b0}, (~a_multiply + 1'b1)} : a_multiply;
                b_reg <= b_multiply;
            end
            default: begin end
        endcase
    end

    state <= next_state;
    product1 <= p;
    product2 <= product1;
    product3 <= product2;
    product4 <= product3;
    product5 <= product4;
    product6 <= product5;
    product7 <= product6;
    product8 <= product7;
    product9 <= product8;
    product10 <= product9;
    answer <= product10;
end

always_comb begin
    mul_done = '0;
    multiplier_ready = '0;
    multiplication_done = '0;
    next_state = state;

    unique case(state)
    s_idle: begin
        next_state = s_idle;
        multiplier_ready = 1'b1;
        if(start) next_state = s_comp;
    end

    s_finally_done: begin
        mul_done = 1'b1;
        next_state = s_idle;
    end
    s_comp: begin
        next_state = s_done_1;
        multiplication_done = 1'b1;
    end

    s_done_1: next_state = s_done_2;
    s_done_2: next_state = s_done_3;
    s_done_3: next_state = s_done_4;
    s_done_4: next_state = s_done_5;
    s_done_5: next_state = s_done_6;
    s_done_6: next_state = s_done_7;
    s_done_7: next_state = s_done_8;
    s_done_8: next_state = s_done_9;
    s_done_9: next_state = s_done_10;
    s_done_10: next_state = s_finally_done;
    default begin end

    endcase
end

dadda mult(.a(rs1_local), .b(rs2_local), .p(p));

endmodule : dadda_multiplier