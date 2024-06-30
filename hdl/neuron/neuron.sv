module neuron(
    input  logic         clk,
    input  logic         rst,
    input  logic [31:0]  value_a,
    input  logic [31:0]  value_b,
    output logic [31:0]  res
);

logic selector_bit;
logic [31:0] alu_out;
logic [31:0] mult_out;

assign selector_bit = 1'b0;
assign res = (selector_bit) ? alu_out : mult_out;

alu alu(
    .aluop('0),
    .a(value_a),
    .b(value_b),
    .f(alu_out)
);

dadda_multiplier dadda_multiplier(
    .clk(clk),
    .rst(rst),
    .start(start),
    .mul_type('0),
    .a_multiply(value_a),
    .b_multiply(value_b),
    .answer(mult_out),
    .mul_done(mul_done),
    .multiplier_ready(multiplier_ready)
);

endmodule : neuron