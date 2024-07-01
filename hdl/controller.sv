import data_types::*;
module neuron_controller
(
    input logic clk,
    input logic reset,
    input logic tick,

    // information packet from scheduler
    input logic [PKT_SIZE - 1:0] from_sched,
    // something to compute
    input logic flag_from_sched,
    // input current. More details to resolve this...
    input logic [V_PRECISION-1:0] I,

    // stuff out to SRAM
    // rough idea is that we store the weights in SRAM
    // neuron block is responsible for updating those
    // I will do the updated potential calculations and pass the updated potentials along.
    input logic sram_resp,
    output logic [SRAM_ADDR_SIZE-1:0] sram_addr,
    input sram_data_t sram_rd,

    // To neuron block: I send the current neuron's index and all its associated data
    // neuron_clk goes high whenever it should calculate
    // also send along new membrane potential; the old pre-spike one may be needed for one reason or another
    output [SRAM_ADDR_SIZE-1:0] curr_neuron,
    output sram_data_t to_nblock,
    output logic [N_COUNT-1:0] neuron_clk,
    output logic [V_PRECISION-1:0] new_membrane_pot,
    
    output logic dropped_packet
);
    // 2D array of memory dictating the connections of the dendrites fanning out from all neuron in the block to the others
    // request axon status from scheduler
    // go through every neuron
        // for each neuron, access each of its dendrites
            // if they are connected and there's a spike (from where?) send a compute instruction to that index
        // apply leak, check threshold, reset membrane potential, send a spike if needed to router, writeback new potential to SRAM and move to next row

    // what neuron model? (Leaky Integrate-And-Fire is default, but how to do in digital domain? analog models exist but mixed-signal verif is not something I wanna do)
    
    // some stuff to help with CDC signals since I assume an internal clock much faster
    // than tick...not sure how else otherwise to do this purely combinationally with multiple
    // reads/writes needed to SRAM
    logic exec;
    logic [SRAM_ADDR_SIZE-1:0] sram_addr_n;

    
    always_comb begin
        sram_addr_n = sram_addr;
        if(sram_addr == 8'd255)
            sram_addr_n = '0;
        else if(exec && sram_resp)
            sram_addr_n = sram_addr + 1'b1;
    end

    always_ff @(posedge clk) begin
        sram_addr <= sram_addr_n;
        if(reset) begin
            sram_addr <= '0;
            exec <= '0;
        end else if(sram_addr == 8'd255) begin
            exec <= '0;
        end else if(flag_from_sched) begin
            exec <= '1;
        end
    end

    assign curr_neuron = sram_addr;
    always_comb begin
        // combinational iteration
        neuron_clk = '0;
        if(sram_rd.connections[curr_neuron]) begin
            neuron_clk[curr_neuron] = '1;
        end
        // update potential per LIF equation
        // I have no idea how to get our input current at this point in time
        if(sram_rd.membrane_potential < sram_rd.vthresh)
            new_membrane_pot = I + sram_rd.A - sram_rd.B * sram_rd.membrane_potential;
        else
            new_membrane_pot = sram_rd.C;

        to_nblock = sram_rd;
        
    end
    
endmodule   :   neuron_controller