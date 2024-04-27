module WB #( 
	parameter ADDR_W = 64,
	parameter INST_W = 32,
	parameter DATA_W = 64
)(
    input                   i_clk,
    input                   i_rst_n,
    input [DATA_W-1 : 0]  i_data,
    input [4 : 0]         i_rd_id,
    input [1 : 0]         i_type,
    input                   i_valid,
    input                   i_d_valid_data,
    input [DATA_W-1 : 0]      i_d_data,
    output [DATA_W-1 : 0]     o_data,
    output [4 : 0]          o_rd_id,
    output                  o_valid
);

    reg [DATA_W-1 : 0]     o_data_r, o_data_w;
    reg [4 : 0]          o_rd_id_r, o_rd_id_w;
    reg                  o_valid_r, o_valid_w;

    assign o_data = o_data_r;
    assign o_rd_id = o_rd_id_r;
    assign o_valid = o_valid_r;

    // integer i;
    always @(*) begin
        if(i_valid || i_d_valid_data) begin
            if (i_type == 0) begin
                o_data_w = i_d_data;
                o_rd_id_w = i_rd_id;
                o_valid_w = 1;
            end else if (i_type == 3) begin
                o_data_w = i_data;
                o_rd_id_w = i_rd_id;
                o_valid_w = 1;
            end else begin
                o_data_w = 0;
                o_rd_id_w = 0;
                o_valid_w = 0;
            end
        end else begin
            o_data_w = 0;
            o_rd_id_w = 0;
            o_valid_w = 0;
        end
    end

    // sequential part
    always @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            o_data_r <= 0;
            o_rd_id_r <= 0;
            o_valid_r <= 0;
        end else begin
            o_data_r <= o_data_w;
            o_rd_id_r <= o_rd_id_w;
            o_valid_r <= o_valid_w;
        end
    end

endmodule
