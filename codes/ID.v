module ID #( 
	parameter ADDR_W = 64,
	parameter INST_W = 32,
	parameter DATA_W = 64
)(
    input                   i_clk,
    input                   i_rst_n,
    input                   i_i_valid_inst, // from instruction memory
    input  [ INST_W-1 : 0 ] i_i_inst,       // from instruction memory
    input [ DATA_W-1 : 0 ]  i_data,
    input [4 : 0]           i_rd_id,
    input                   i_valid,
    output                  o_finish,
    output [3 : 0]          o_op,
    output [ DATA_W-1 : 0 ] o_rs1,
    output [ DATA_W-1 : 0 ] o_rs2,
    output [4 : 0]          o_rd_id,
    output [ DATA_W-1 : 0 ] o_imm,
    output                  o_valid
);
    parameter LD = 10'b0110000011;
    parameter SD = 10'b0110100011;
    parameter BEQ = 10'b0001100011;
    parameter BNE = 10'b0011100011;
    parameter ADDI = 10'b0000010011;
    parameter XORI = 10'b1000010011;
    parameter ORI = 10'b1100010011;
    parameter ANDI = 10'b1110010011;
    parameter SLLI = 10'b0010010011;
    parameter SRLI = 10'b1010010011;
    parameter ADDorSUB = 10'b0000110011;
    parameter ADD = 7'b0000000;
    parameter SUB = 7'b0100000;
    parameter XOR = 10'b1000110011;
    parameter OR = 10'b1100110011;
    parameter AND = 10'b1110110011;
    parameter STOP = 10'b1111111111;

    reg [DATA_W-1 : 0] registers_r [0:31], registers_w [0:31];
    reg                  o_valid_r, o_valid_w; 
    reg [DATA_W-1 : 0] o_rs1_r, o_rs1_w; 
    reg [DATA_W-1 : 0] o_rs2_r, o_rs2_w; 
    reg      [4 : 0]     o_rd_id_r, o_rd_id_w; 
    reg                  o_finish_r, o_finish_w;
    reg [DATA_W-1 : 0] o_imm_r, o_imm_w;
    reg      [3 : 0]     o_op_r, o_op_w;

    reg [11 : 0] tmp_imm;
    reg [11 : 0] left_12;
    reg [4 : 0] rs1;
    reg [2 : 0] funct3;
    reg [4 : 0] rd;
    reg [6 : 0] op;
    reg [9 : 0] ins;

    // reg [9 : 0] cnt_r, cnt_w;

    assign o_valid = o_valid_r;
    assign o_rs1 = o_rs1_r;
    assign o_rs2 = o_rs2_r;
    assign o_rd_id = o_rd_id_r;
    assign o_finish = o_finish_r;
    assign o_imm = o_imm_r;
    assign o_op = o_op_r;

    integer i;

    always @(*) begin
        // cnt_w = cnt_r + 1;
        // $display("cnt: %d",cnt_r);
        if(i_i_valid_inst) begin
            // if(cnt_r < 2) begin
                // $display("cnt1: %d",cnt_r);
                {left_12, rs1, funct3, rd, op} = i_i_inst;
            // end else begin
            //     // $display("cnt2: %d",cnt_r);
            //     {left_12, rs1, funct3, rd, op} = 32'b111111111111111111111111111111111111111111111111;
            // end
            ins = {funct3, op};
            o_rs2_w = registers_r[left_12[4:0]];
            o_rs1_w = registers_r[rs1];
            o_rd_id_w = rd;
            case (ins)
                LD: begin
                    o_op_w = 0;
                    tmp_imm = left_12;
                end
                SD: begin
                    o_op_w = 1;
                    tmp_imm = {left_12[11:5], rd};
                end
                BEQ: begin
                    o_op_w = 2;
                    tmp_imm = {left_12[11], rd[0], left_12[10:5], rd[4:1]};
                end
                BNE: begin
                    o_op_w = 3;
                    tmp_imm = {left_12[11], rd[0], left_12[10:5], rd[4:1]};
                end
                ADDI: begin
                    o_op_w = 4;
                    tmp_imm = left_12;
                end
                XORI: begin
                    o_op_w = 5;
                    tmp_imm = left_12;
                end
                ORI: begin
                    o_op_w = 6;
                    tmp_imm = left_12;
                end
                ANDI: begin
                    o_op_w = 7;
                    tmp_imm = left_12;
                end
                SLLI: begin
                    o_op_w = 8;
                    tmp_imm = left_12;
                end
                SRLI: begin
                    o_op_w = 9;
                    tmp_imm = left_12;
                end
                ADDorSUB: begin
                    tmp_imm = 0;
                    case (left_12[11:5])
                        ADD: begin
                            o_op_w = 10;
                        end
                        SUB: begin
                            o_op_w = 11;
                        end
                        default: begin
                            o_op_w = 11;
                        end
                    endcase
                end
                XOR: begin
                    o_op_w = 12;
                    tmp_imm = 0;
                end
                OR: begin
                    o_op_w = 13;
                    tmp_imm = 0;
                end
                AND: begin
                    o_op_w = 14;
                    tmp_imm = 0;
                end
                STOP: begin
                    o_op_w = 0;
                    tmp_imm = 0;
                end
                default: begin
                    o_op_w = 0;
                    tmp_imm = 0;
                end
            endcase
            o_imm_w = {{52{tmp_imm[11]}}, tmp_imm};
            if(ins[9 : 0] == STOP) begin
                o_finish_w = 1;
                o_valid_w = 0;
            end else begin
                o_finish_w = 0;
                o_valid_w = 1;
            end

        end else begin
            o_valid_w = 0;
            o_rs1_w = 0;
            o_rs2_w = 0;
            o_rd_id_w = 0;
            o_finish_w = 0;
            o_imm_w = 0;
            o_op_w = 0;
            // cnt_w = cnt_r;
        end
    end
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            if (i_valid && i_rd_id == i) begin
                registers_w[i] = i_data;
            end else begin
                registers_w[i] = registers_r[i];
            end
        end
    end
    // sequential part
    always @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            o_valid_r <= 0;
            o_rs1_r <= 0;
            o_rs2_r <= 0;
            o_rd_id_r <= 0;
            o_finish_r <= 0;
            o_imm_r <= 0;
            o_op_r <= 0;
            // cnt_r <= 0;
            for (i = 0; i < 32; i = i + 1) begin
                registers_r[i] <= 0;
            end
        end else begin
            o_valid_r <= o_valid_w;
            o_rs1_r <= o_rs1_w;
            o_rs2_r <= o_rs2_w;
            o_rd_id_r <= o_rd_id_w;
            o_finish_r <= o_finish_w;
            o_imm_r <= o_imm_w;
            o_op_r <= o_op_w;
            // cnt_r <= cnt_w;
            for (i = 0; i < 32; i = i + 1) begin
                registers_r[i] <= registers_w[i];
            end
        end
    end


endmodule
