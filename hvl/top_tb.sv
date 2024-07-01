import "DPI-C" function string getenv(input string env_name);

module top_tb;

    timeunit 1ps;
    timeprecision 1ps;

    int clock_half_period_ps = 5;

    bit clk;
    always #(clock_half_period_ps) clk = ~clk;

    bit reset;
    logic tick;
    logic [PKT_SIZE-1:0] from_sched;
    logic flag_from_sched;
    logic [V_PRECISION-1:0] I;
    logic sram_resp;
    logic [SRAM_ADDR_SIZE-1:0] sram_addr;
    sram_data_t sram_rd;
    logic [SRAM_ADDR_SIZE-1:0] curr_neuron;
    sram_data_t to_nblock;
    logic [N_COUNT-1:0] neuron_clk;
    logic [V_PRECISION-1:0] new_membrane_pot;
    logic dropped_packet;

    int timeout = 10000000; // in cycles, change according to your needs

    neuron_controller dut(.*);

    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, "+all");
        reset = 1'b1;
        tick = 1'b0;
        sram_resp = 1'b0;
        I = '0;
        from_sched = '0;
        flag_from_sched = '0;
        sram_rd = '0;

        repeat (2) @(posedge clk);
        reset <= 1'b0;

        repeat (1) @(posedge clk);
        flag_from_sched = '1;
        
        repeat (1) @(posedge clk);
        flag_from_sched = '0;
        sram_resp = '1;
        sram_rd.connections = 256'd8;
        I = 4'd2;
        sram_rd.A = 4'd1;
        sram_rd.B = 4'd1;
        sram_rd.C = 4'd1;
        sram_rd.vthresh = 4'd3;
        sram_rd.membrane_potential = 4'd5;

        repeat (256) @(posedge clk);

        repeat (50) @(posedge clk);
        $finish;
    end

    always @(posedge clk) begin
        timeout <= timeout - 1;
    end

endmodule