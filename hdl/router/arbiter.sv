module arbiter_mem_access
import rv32i_types::*;
(
    input logic               clk,
    input logic               rst,
    input logic               spec_req,
    input logic               load_req,
    input logic               store_req,
    input logic               flush_pipeline,
    input logic     [63:0]    flush_order,

    input load_store_queue_t  lq_spec_register,
    input load_store_queue_t  lq_register,
    input load_store_queue_t  sq_register,

    input   logic   [31:0]    dmem_rdata,
    input   logic             dmem_resp,
    output  logic   [31:0]    dmem_addr,
    output  logic   [3:0]     dmem_rmask,
    output  logic   [3:0]     dmem_wmask,
    output  logic   [31:0]    dmem_wdata,

    output logic              flush_load,
    output logic   [2:0]      flush_rob_id_load,
    output logic   [63:0]     flush_order_load,
    output logic   [31:0]     jump_pc_load,

    output logic              spec_ack,
    output logic              load_ack,
    output logic              store_ack,

    output logic              lq_re_write_enable,
    output logic   [63:0]     lsq_register_order,

    output common_data_bus_t  common_data_bus_spec_load,
    output common_data_bus_t  common_data_bus_load,
    output common_data_bus_t  common_data_bus_store
);

logic             recieved_ack;
logic             override;
common_data_bus_t common_data_bus_load_store;
load_store_queue_t lsq_register;
logic [1:0] sent; //1 means spec, 2 means reexecute, 3 means store

always_comb begin
    dmem_addr = '0;
    dmem_rmask = '0;
    dmem_wmask = '0;
    dmem_wdata = '0;

    if((load_req) && (!override)) begin
        dmem_addr = lq_register.addr;
        dmem_rmask = lq_register.rmask;
    end
    else if((store_req) && (!override)) begin
        dmem_addr = sq_register.addr;
        dmem_wmask = sq_register.wmask;
        dmem_wdata = sq_register.mem_wdata;
    end
    else if((spec_req) && (!override)) begin
        dmem_addr = lq_spec_register.addr;
        dmem_rmask = lq_spec_register.rmask;
    end
end

always_ff @(posedge clk) begin
    if(rst) begin
        lsq_register <= '0;
        sent <= '0;
        override <= '0;

    end
    else begin
        if((load_req) && (!override) && (lq_register.valid)) begin
            override <= 1'b1;
            lsq_register <= lq_register;
            lsq_register.valid <= 1'b1;
            lsq_register.data_available <= 1'b0;
            lsq_register.types <= 2'b10;
            sent <= 2'b10;
        end
        else if((store_req) && (!override) && (sq_register.valid)) begin
            override <= 1'b1;
            lsq_register <= sq_register;
            lsq_register.valid <= 1'b1;
            lsq_register.data_available <= 1'b0;
            lsq_register.types <= 2'b11;
            sent <= 2'b11;
        end
        else if((spec_req) && (!override) && (lq_spec_register.valid)) begin
            override <= 1'b1;
            lsq_register <= lq_spec_register;
            lsq_register.valid <= 1'b1;
            lsq_register.data_available <= 1'b0;
            lsq_register.types <= 2'b01;
            sent <= 2'b01;
        end
        if(lsq_register.valid && dmem_resp) begin
            lsq_register.data_available <= 1'b1;
            lsq_register.rd_v <= dmem_rdata;
        end
        if(recieved_ack) begin
            lsq_register <= '0;
            override <= 1'b0;
        end
        if (flush_pipeline && (lsq_register.order > flush_order) && lsq_register.valid) begin
            lsq_register <= '0;
            override <= '0;
        end 
    end
end

always_comb begin
    lq_re_write_enable = '0;
    recieved_ack = '0;
    spec_ack = '0;
    load_ack = '0;
    store_ack = '0;
    common_data_bus_spec_load = '0;
    common_data_bus_load = '0;
    common_data_bus_store = '0;
    flush_load = '0;
    flush_rob_id_load = '0;
    flush_order_load = '0;
    jump_pc_load = '0;
    common_data_bus_load_store = '0;
    lsq_register_order = lsq_register.order;
    if ((lsq_register.data_available) && (lsq_register.valid)) begin
        recieved_ack = 1'b1;
        if(lsq_register.types < 2'b11) begin
            unique case (lsq_register.funct3)
                lb : common_data_bus_load_store.rd_v = {{24{lsq_register.rd_v[7 +8 *lsq_register.addr[1:0]]}}, lsq_register.rd_v[8 *lsq_register.addr[1:0] +: 8 ]};
                lbu: common_data_bus_load_store.rd_v = {{24{1'b0}}                          , lsq_register.rd_v[8 *lsq_register.addr[1:0] +: 8 ]};
                lh : common_data_bus_load_store.rd_v = {{16{lsq_register.rd_v[15+16*lsq_register.addr[1]  ]}}, lsq_register.rd_v[16*lsq_register.addr[1]   +: 16]};
                lhu: common_data_bus_load_store.rd_v = {{16{1'b0}}                          , lsq_register.rd_v[16*lsq_register.addr[1]   +: 16]};
                lw : common_data_bus_load_store.rd_v = lsq_register.rd_v;
                default: common_data_bus_load_store.rd_v = 'x;
            endcase
        end
        common_data_bus_load_store.order = lsq_register.order;
        common_data_bus_load_store.funct3 = lsq_register.funct3;
        common_data_bus_load_store.rob_id = lsq_register.rob_id;
        common_data_bus_load_store.valid = 1'b1;
        common_data_bus_load_store.rs1_v = lsq_register.rs1_v;
        common_data_bus_load_store.rs2_v = lsq_register.rs2_v;
        common_data_bus_load_store.pc_next = lsq_register.pc_next;
        common_data_bus_load_store.dmem_addr = lsq_register.addr;
        if(lsq_register.types < 2'b11) begin
            common_data_bus_load_store.dmem_rdata = lsq_register.rd_v;
            common_data_bus_load_store.dmem_rmask = lsq_register.rmask;
            common_data_bus_load_store.dmem_wdata = '0;
            common_data_bus_load_store.dmem_wmask = '0;
        end
        else begin
            common_data_bus_load_store.dmem_rdata = '0;
            common_data_bus_load_store.dmem_rmask = '0;
            common_data_bus_load_store.dmem_wdata = lsq_register.mem_wdata;
            common_data_bus_load_store.dmem_wmask = lsq_register.wmask;
        end

        if(lsq_register.types == 2'b10) begin
            if(lsq_register.pred_rd_v != common_data_bus_load_store.rd_v) begin
                flush_load = 1'b1;
                jump_pc_load = lsq_register.pc_next;
                flush_order_load = lsq_register.order;
                flush_rob_id_load = lsq_register.rob_id;
            end
        end

    unique case(lsq_register.types)
        2'b01: begin common_data_bus_spec_load = common_data_bus_load_store; spec_ack = 1'b1; lq_re_write_enable = 1'b1; end
        2'b10: begin common_data_bus_load = common_data_bus_load_store; load_ack = 1'b1; end
        2'b11: begin common_data_bus_store = common_data_bus_load_store; store_ack = 1'b1; end
        default: common_data_bus_load_store = '0;
    endcase

    if(flush_pipeline) begin 
        if(flush_order < common_data_bus_load_store.order) begin 
            lq_re_write_enable = '0;
            common_data_bus_load_store = '0;
            common_data_bus_load = '0;
            common_data_bus_store = '0;
            common_data_bus_spec_load = '0;
        end
    end
    end

end

endmodule : arbiter_mem_access