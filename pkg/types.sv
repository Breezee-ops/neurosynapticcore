package data_types;
    // yoinked from V's implementation
    parameter N_COUNT = 256;
    parameter GRANULARITY = 4;
    parameter PKT_SIZE = 32;
    parameter SRAM_ADDR_SIZE = $clog2(N_COUNT);

    typedef struct packed {
        logic [V_PRECISION-1:0] A;
        logic [V_PRECISION-1:0] B;
        logic [V_PRECISION-1:0] C;
        logic [V_PRECISION-1:0] vthresh;
        logic [N_COUNT-1:0] connections;
        logic [V_PRECISION-1:0] membrane_potential;
    } sram_data_t;
endpackage