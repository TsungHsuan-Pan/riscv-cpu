module cpu #( // Do not modify interface
	parameter ADDR_W = 64,
	parameter INST_W = 32,
	parameter DATA_W = 64
)(
    input                   i_clk,
    input                   i_rst_n,
    input                   i_i_valid_inst, // from instruction memory
    input  [ INST_W-1 : 0 ] i_i_inst,       // from instruction memory
    input                   i_d_valid_data, // from data memory
    input  [ DATA_W-1 : 0 ] i_d_data,       // from data memory
    output                  o_i_valid_addr, // to instruction memory
    output [ ADDR_W-1 : 0 ] o_i_addr,       // to instruction memory
    output [ DATA_W-1 : 0 ] o_d_w_data,     // to data memory
    output [ ADDR_W-1 : 0 ] o_d_w_addr,     // to data memory
    output [ ADDR_W-1 : 0 ] o_d_r_addr,     // to data memory
    output                  o_d_MemRead,    // to data memory
    output                  o_d_MemWrite,   // to data memory
    output                  o_finish
);  
    // if exe
    wire  [DATA_W-1 : 0]  if_exe_pc;
    wire                    if_exe_valid;
    // id exe
    wire   [DATA_W-1 : 0] id_exe_imm;
    wire   [DATA_W-1 : 0] id_exe_rs1;
    wire   [DATA_W-1 : 0] id_exe_rs2;
    wire   [4 : 0 ]        id_exe_rd_id;
    wire   [3 : 0 ]        id_exe_op;
    wire                    id_exe_valid;
    // exe mem
    wire   [DATA_W-1 : 0] exe_mem_addr;
    wire   [DATA_W-1 : 0] exe_mem_data;
    wire   [4 : 0]        exe_mem_rd_id;
    wire   [1 : 0]        exe_mem_type;
    wire                    exe_mem_valid;
    // mem wb
    wire   [DATA_W-1 : 0] mem_wb_data;
    wire   [4 : 0]        mem_wb_rd_id;
    wire   [1 : 0]        mem_wb_type;
    wire                    mem_wb_valid;
    // wb id
    wire   [DATA_W-1 : 0] wb_id_data;
    wire   [4 : 0]        wb_id_rd_id;
    wire                    wb_id_valid;
    // exe if
    wire   [DATA_W-1 : 0] exe_if_new_pc;
    wire                    exe_if_valid;

    IF #(
        .INST_W(INST_W),
        .DATA_W(DATA_W),
        .ADDR_W(ADDR_W)
    ) u_if (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_new_pc(exe_if_new_pc),
        .i_valid(exe_if_valid),
        .o_i_valid_addr(o_i_valid_addr),
        .o_i_addr(o_i_addr),
        .o_pc(if_exe_pc),
        .o_valid(if_exe_valid)

    );

    ID #(
        .INST_W(INST_W),
        .DATA_W(DATA_W),
        .ADDR_W(ADDR_W)
    ) u_id (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_i_valid_inst(i_i_valid_inst),
        .i_i_inst(i_i_inst),
        .i_data(wb_id_data),
        .i_rd_id(wb_id_rd_id),
        .i_valid(wb_id_valid),
        .o_finish(o_finish),
        .o_op(id_exe_op),
        .o_rs1(id_exe_rs1),
        .o_rs2(id_exe_rs2),
        .o_rd_id(id_exe_rd_id),
        .o_imm(id_exe_imm),
        .o_valid(id_exe_valid)
    );

    EX #(
        .INST_W(INST_W),
        .DATA_W(DATA_W),
        .ADDR_W(ADDR_W)
    ) u_exe (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_id_valid(id_exe_valid),
        .i_rs1(id_exe_rs1),
        .i_rs2(id_exe_rs2),
        .i_rd(id_exe_rd_id),
        .i_imm(id_exe_imm),
        .i_op(id_exe_op),
        .i_pc(if_exe_pc),
        .i_if_valid(if_exe_valid),
        .o_addr(exe_mem_addr),
        .o_data(exe_mem_data),
        .o_rd_id(exe_mem_rd_id),
        .o_type(exe_mem_type),
        .o_mem_valid(exe_mem_valid),
        .o_new_pc(exe_if_new_pc),
        .o_if_valid(exe_if_valid)
    );

    MEM #(
        .INST_W(INST_W),
        .DATA_W(DATA_W),
        .ADDR_W(ADDR_W)
    ) u_mem (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_addr(exe_mem_addr),
        .i_data(exe_mem_data),
        .i_rd_id(exe_mem_rd_id),
        .i_type(exe_mem_type),
        .i_valid(exe_mem_valid),
        .o_data(mem_wb_data),
        .o_rd_id(mem_wb_rd_id),
        .o_type(mem_wb_type),
        .o_valid(mem_wb_valid),
        .o_d_w_data(o_d_w_data),
        .o_d_r_addr(o_d_r_addr),
        .o_d_w_addr(o_d_w_addr),
        .o_d_MemRead(o_d_MemRead),
        .o_d_MemWrite(o_d_MemWrite)
    );

    WB #(
        .INST_W(INST_W),
        .DATA_W(DATA_W),
        .ADDR_W(ADDR_W)
    ) u_wb (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_data(mem_wb_data),
        .i_rd_id(mem_wb_rd_id),
        .i_type(mem_wb_type),
        .i_valid(mem_wb_valid),
        .i_d_valid_data(i_d_valid_data),
        .i_d_data(i_d_data),
        .o_data(wb_id_data),
        .o_rd_id(wb_id_rd_id),
        .o_valid(wb_id_valid)
    );

endmodule
