module MEM #( 
	parameter ADDR_W = 64,
	parameter INST_W = 32,
	parameter DATA_W = 64
)(
    input                   i_clk,
    input                   i_rst_n,
    input [DATA_W-1 : 0] i_addr,
    input [DATA_W-1 : 0] i_data,
    input [4 : 0]          i_rd_id,
    input [1 : 0]          i_type,
    input                  i_valid,
    output [DATA_W-1 : 0] o_data,
    output [4 : 0]        o_rd_id,
    output [1 : 0]        o_type,
    output                  o_valid,
    output [DATA_W-1 : 0] o_d_w_data,
    output [ADDR_W-1 : 0] o_d_r_addr,
    output [ADDR_W-1 : 0] o_d_w_addr,
    output              o_d_MemRead,
    output              o_d_MemWrite
);

    reg [DATA_W-1 : 0] o_data_r, o_data_w;
    reg [4 : 0]          o_rd_id_r, o_rd_id_w;
    reg                  o_valid_r, o_valid_w;
    reg [1 : 0]          o_type_r, o_type_w;
    reg [DATA_W-1 : 0]    o_d_w_data_r, o_d_w_data_w;
    reg [ADDR_W-1 : 0]    o_d_r_addr_r, o_d_r_addr_w;
    reg [ADDR_W-1 : 0]    o_d_w_addr_r, o_d_w_addr_w;
    reg                 o_d_MemRead_r, o_d_MemRead_w;
    reg                 o_d_MemWrite_r, o_d_MemWrite_w;

    reg [1 : 0]           cs, ns;

    assign o_data = o_data_r;
    assign o_rd_id = o_rd_id_r;
    assign o_valid = o_valid_r;
    assign o_type = o_type_r;
    assign o_d_w_data = o_d_w_data_r;
    assign o_d_r_addr = o_d_r_addr_r;
    assign o_d_w_addr = o_d_w_addr_r;
    assign o_d_MemRead = o_d_MemRead_r;
    assign o_d_MemWrite = o_d_MemWrite_r;

    // integer i;
    always @(*) begin
        if(i_valid && cs == 0) begin
            if(i_type == 0) begin
                o_d_w_data_w = 0;
                o_d_r_addr_w = i_addr;
                o_d_w_addr_w = 0;
                o_d_MemRead_w = 1;
                o_d_MemWrite_w = 0;
            end else if(i_type == 1) begin
                o_d_w_data_w = i_data;
                o_d_r_addr_w = 0;
                o_d_w_addr_w = i_addr;
                o_d_MemRead_w = 0;
                o_d_MemWrite_w = 1;
            end else begin
                o_d_w_data_w = 0;
                o_d_r_addr_w = 0;
                o_d_w_addr_w = 0;
                o_d_MemRead_w = 0;
                o_d_MemWrite_w = 0;
            end
            o_data_w = i_addr;
            o_rd_id_w = i_rd_id;
            o_type_w = i_type;
            o_valid_w = 0;
        end else if(cs == 2) begin
            o_d_w_data_w = o_d_w_data_r;
            o_d_r_addr_w = o_d_r_addr_r;
            o_d_w_addr_w = o_d_w_addr_r;
            o_d_MemRead_w = 0;
            o_d_MemWrite_w = 0;
            o_data_w = o_data_r;
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_valid_w = 1;
        end else begin
            o_d_w_data_w = o_d_w_data_r;
            o_d_r_addr_w = o_d_r_addr_r;
            o_d_w_addr_w = o_d_w_addr_r;
            o_d_MemRead_w = 0;
            o_d_MemWrite_w = 0;
            o_data_w = o_data_r;
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_valid_w = 0;
        end
    end

    always @(*) begin
        case (cs)
        	0: ns = (i_valid) ? 1 : 0;
        	1: ns = 2;
        	2: ns = 0;
            default: ns = 0;
        endcase
    end

    // sequential part
    always @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            o_data_r <= 0;
            o_rd_id_r <= 0;
            o_valid_r <= 0;
            o_type_r <= 0;
            o_d_w_data_r <= 0;
            o_d_r_addr_r <= 0;
            o_d_w_addr_r <= 0;
            o_d_MemRead_r <= 0;
            o_d_MemWrite_r <= 0;
            cs <= 0;            
        end else begin
            o_data_r <= o_data_w;
            o_rd_id_r <= o_rd_id_w;
            o_valid_r <= o_valid_w;
            o_type_r <= o_type_w;
            o_d_w_data_r <= o_d_w_data_w;
            o_d_r_addr_r <= o_d_r_addr_w;
            o_d_w_addr_r <= o_d_w_addr_w;
            o_d_MemRead_r <= o_d_MemRead_w;
            o_d_MemWrite_r <= o_d_MemWrite_w;
            cs <= ns;
        end
    end

endmodule
