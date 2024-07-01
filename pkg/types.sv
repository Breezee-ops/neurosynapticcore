package data_types;
    // yoinked from V's implementation
    localparam N_COUNT = 256;
    localparam GRANULARITY = 4;
    localparam PKT_SIZE = 32;
    localparam SRAM_ADDR_SIZE = $clog2(N_COUNT);
    // # of bits to use for the fp precision of weights
    localparam V_PRECISION = 4;

    typedef struct packed {
        logic [V_PRECISION-1:0] A;
        logic [V_PRECISION-1:0] B;
        logic [V_PRECISION-1:0] C;
        logic [V_PRECISION-1:0] vthresh;
        logic [N_COUNT-1:0] connections;
        logic [V_PRECISION-1:0] membrane_potential;
    } sram_data_t;
endpackage