module EX #( 
	parameter ADDR_W = 64,
	parameter INST_W = 32,
	parameter DATA_W = 64

)(
    input                   i_clk,
    input                   i_rst_n,
    input                  i_id_valid,
    input [DATA_W-1 : 0] i_rs1,
    input [DATA_W-1 : 0] i_rs2,
    input [4 : 0]          i_rd,
    input [DATA_W-1 : 0] i_imm,
    input [3 : 0]          i_op,
    input [DATA_W-1 : 0] i_pc,
    input                  i_if_valid,
    output [DATA_W-1 : 0] o_addr,
    output [DATA_W-1 : 0] o_data,
    output [4 : 0]          o_rd_id,
    output [1 : 0]          o_type,
    output                  o_mem_valid,
    output [DATA_W-1:0]     o_new_pc,
    output                  o_if_valid

);
    parameter LD = 0;
    parameter SD = 1;
    parameter BEQ = 2;
    parameter BNE = 3;
    parameter ADDI = 4;
    parameter XORI = 5;
    parameter ORI = 6;
    parameter ANDI = 7;
    parameter SLLI = 8;
    parameter SRLI = 9;
    parameter ADD = 10;
    parameter SUB = 11;
    parameter XOR = 12;
    parameter OR = 13;
    parameter AND = 14;

    reg [DATA_W-1 : 0] o_addr_r, o_addr_w;
    reg [DATA_W-1 : 0] o_data_r, o_data_w;
    reg [4 : 0]          o_rd_id_r, o_rd_id_w;
    reg [1 : 0]          o_type_r, o_type_w;
    reg                  o_mem_valid_r, o_mem_valid_w;
    reg [DATA_W-1 : 0]     o_new_pc_r, o_new_pc_w;
    reg                  o_if_valid_r, o_if_valid_w;
    
    reg [3 : 0] cs, ns;
    reg [DATA_W-1 : 0] rs2_r, rs2_w;
    reg [4 : 0]          rd_r, rd_w;
    reg [3 : 0]          op_r, op_w;
    reg [DATA_W-1 : 0]  tmp_r, tmp_w;
    reg                  carry_r, carry_w;
    reg                  cont_r, cont_w;

    assign o_addr = o_addr_r;
    assign o_data = o_data_r;
    assign o_rd_id = o_rd_id_r;
    assign o_type = o_type_r;
    assign o_mem_valid = o_mem_valid_r;
    assign o_new_pc = o_new_pc_r;
    assign o_if_valid = o_if_valid_r;

    integer i;
    always @(*) begin
        if(i_id_valid && cs == 0) begin
            // $display("ex_start");
            rs2_w = i_rs2;
            rd_w = i_rd;
            op_w = i_op;
            case (i_op)
                LD: begin
                    tmp_w = i_rs1;
                    o_addr_w = 0;
                    o_data_w = i_imm;
                    carry_w = 0;
                    o_type_w = 0;
                    cont_w = 1;
                end
                SD: begin
                    tmp_w = i_rs1;
                    o_addr_w = 0;
                    o_data_w = i_imm;
                    carry_w = 0;
                    o_type_w = 1;
                    cont_w = 1;
                end
                BEQ: begin
                    // $display("branch");
                    if(i_rs1 == i_rs2) begin
                        tmp_w = i_imm << 1;
                        // $display("branch 1");
                    end else begin
                        tmp_w = 4;
                    end
                    o_addr_w = 0;
                    o_data_w = i_pc;
                    carry_w = 0;
                    o_type_w = 2;
                    cont_w = 1;
                    // $display("i_imm:\n%b\n tmp_w,o_data_w:\n%b\n%b",i_imm, tmp_w, o_data_w);
                end
                BNE: begin
                    // $display("branch");
                    if(i_rs1 != i_rs2) begin
                        tmp_w = i_imm << 1;
                        // $display("branch 1");
                    end else begin
                        tmp_w = 4;
                    end
                    o_addr_w = 0;
                    o_data_w = i_pc;
                    carry_w = 0;
                    o_type_w = 2;
                    cont_w = 1;
                    // $display("i_imm:\n%b\n tmp_w,o_data_w:\n%b\n%b",i_imm, tmp_w, o_data_w);
                end
                ADDI: begin
                    tmp_w = i_rs1;
                    o_addr_w = 0;
                    o_data_w = i_imm;
                    carry_w = 0;
                    o_type_w = 3;
                    cont_w = 1;
                end
                XORI: begin
                    tmp_w = i_rs1;
                    o_addr_w = i_rs1 ^ i_imm;
                    o_data_w = 0;
                    carry_w = 0;
                    o_type_w = 3;
                    cont_w = 0;
                end
                ORI: begin
                    tmp_w = i_rs1;
                    o_addr_w = i_rs1 | i_imm;
                    o_data_w = 0;
                    carry_w = 0;
                    o_type_w = 3;
                    cont_w = 0;
                end
                ANDI: begin
                    tmp_w = i_rs1;
                    o_addr_w = i_rs1 & i_imm;
                    o_data_w = 0;
                    carry_w = 0;
                    o_type_w = 3;
                    cont_w = 0;
                end
                SLLI: begin
                    tmp_w = i_rs1;
                    i = (i_imm[0])? 1 : 0;
                    i = i + ((i_imm[2])? 4 : 0);
                    o_addr_w = i_rs1 << i[3 : 0];
                    o_data_w = 0;
                    carry_w = 0;
                    o_type_w = 3;
                    cont_w = 0;
                end
                SRLI: begin
                    tmp_w = i_rs1;
                    o_addr_w = i_rs1 >> 1;
                    o_data_w = 0;
                    carry_w = 0;
                    o_type_w = 3;
                    cont_w = 0;
                end
                ADD: begin
                    tmp_w = i_rs1;
                    o_addr_w = 0;
                    o_data_w = i_rs2;
                    carry_w = 0;
                    o_type_w = 3;
                    cont_w = 1;
                end
                SUB: begin
                    tmp_w = i_rs1;
                    o_addr_w = 0;
                    o_data_w = ~i_rs2;
                    carry_w = 1;
                    o_type_w = 3;
                    cont_w = 1;
                end
                XOR: begin
                    tmp_w = i_rs1;
                    o_addr_w = i_rs1 ^ i_rs2;
                    o_data_w = 0;
                    carry_w = 0;
                    o_type_w = 3;
                    cont_w = 0;
                end
                OR: begin
                    tmp_w = i_rs1;
                    o_addr_w = i_rs1 | i_rs2;
                    o_data_w = 0;
                    carry_w = 0;
                    o_type_w = 3;
                    cont_w = 0;
                end
                AND: begin
                    tmp_w = i_rs1;
                    o_addr_w = i_rs1 & i_rs2;
                    o_data_w = 0;
                    carry_w = 0;
                    o_type_w = 3;
                    cont_w = 0;
                end
                default: begin
                    tmp_w = i_rs1;
                    o_addr_w = 0;
                    o_data_w = 0;
                    carry_w = 0;
                    o_type_w = 0;
                    cont_w = 0;
                end
            endcase
            o_rd_id_w = o_rd_id_r;
            o_mem_valid_w = 0;
            o_new_pc_w = o_new_pc_r;
            o_if_valid_w = 0;
            // $display("op: %d(beq2,bne3), imm: %d", i_op, tmp_w);
        end else if (cs == 1 && cont_r) begin
            // $display("tmp_r:%d, o_data_r: %d",tmp_r, o_data_r);
            {carry_w, tmp_w[7 : 0]} =  tmp_r[7 : 0] + o_data_r[7 : 0] + carry_r;
            tmp_w[63 : 8] = tmp_r[63 : 8];
            o_addr_w = o_addr_r;
            o_data_w = o_data_r;  
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_mem_valid_w = 0;
            o_new_pc_w = o_new_pc_r;
            o_if_valid_w = 0;
            rs2_w = rs2_r;
            rd_w = rd_r;
            op_w = op_r;
            cont_w = cont_r;
        end else if (cs == 2 && cont_r) begin
            {carry_w, tmp_w[15 : 8]} =  tmp_r[15 : 8] + o_data_r[15 : 8] + carry_r;
            tmp_w[7 : 0] = tmp_r[7 : 0];
            tmp_w[63 : 16] = tmp_r[63 : 16];
            o_addr_w = o_addr_r;
            o_data_w = o_data_r;  
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_mem_valid_w = 0;
            o_new_pc_w = o_new_pc_r;
            o_if_valid_w = 0;
            rs2_w = rs2_r;
            rd_w = rd_r;
            op_w = op_r;
            cont_w = cont_r;
        end else if (cs == 3 && cont_r) begin
            {carry_w, tmp_w[23 : 16]} =  tmp_r[23 : 16] + o_data_r[23 : 16] + carry_r;
            tmp_w[15 : 0] = tmp_r[15 : 0];
            tmp_w[63 : 24] = tmp_r[63 : 24];
            o_addr_w = o_addr_r;
            o_data_w = o_data_r;  
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_mem_valid_w = 0;
            o_new_pc_w = o_new_pc_r;
            o_if_valid_w = 0;
            rs2_w = rs2_r;
            rd_w = rd_r;
            op_w = op_r;
            cont_w = cont_r;
        end else if (cs == 4 && cont_r) begin
            {carry_w, tmp_w[31 : 24]} =  tmp_r[31 : 24] + o_data_r[31 : 24] + carry_r;
            tmp_w[23 : 0] = tmp_r[23 : 0];
            tmp_w[63 : 32] = tmp_r[63 : 32];
            o_addr_w = o_addr_r;
            o_data_w = o_data_r;  
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_mem_valid_w = 0;
            o_new_pc_w = o_new_pc_r;
            o_if_valid_w = 0;
            rs2_w = rs2_r;
            rd_w = rd_r;
            op_w = op_r;
            cont_w = cont_r;
        end else if (cs == 5 && cont_r) begin
            {carry_w, tmp_w[39 : 32]} =  tmp_r[39 : 32] + o_data_r[39 : 32] + carry_r;
            tmp_w[31 : 0] = tmp_r[31 : 0];
            tmp_w[63 : 40] = tmp_r[63 : 40];
            o_addr_w = o_addr_r;
            o_data_w = o_data_r;  
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_mem_valid_w = 0;
            o_new_pc_w = o_new_pc_r;
            o_if_valid_w = 0;
            rs2_w = rs2_r;
            rd_w = rd_r;
            op_w = op_r;
            cont_w = cont_r;
        end else if (cs == 6 && cont_r) begin
            {carry_w, tmp_w[47 : 40]} =  tmp_r[47 : 40] + o_data_r[47 : 40] + carry_r;
            tmp_w[39 : 0] = tmp_r[39 : 0];
            tmp_w[63 : 48] = tmp_r[63 : 48];
            o_addr_w = o_addr_r;
            o_data_w = o_data_r;  
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_mem_valid_w = 0;
            o_new_pc_w = o_new_pc_r;
            o_if_valid_w = 0;
            rs2_w = rs2_r;
            rd_w = rd_r;
            op_w = op_r;
            cont_w = cont_r;
        end else if (cs == 7 && cont_r) begin
            {carry_w, tmp_w[55 : 48]} =  tmp_r[55 : 48] + o_data_r[55 : 48] + carry_r;
            tmp_w[47 : 0] = tmp_r[47 : 0];
            tmp_w[63 : 56] = tmp_r[63 : 56];
            o_addr_w = o_addr_r;
            o_data_w = o_data_r;  
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_mem_valid_w = 0;
            o_new_pc_w = o_new_pc_r;
            o_if_valid_w = 0;
            rs2_w = rs2_r;
            rd_w = rd_r;
            op_w = op_r;
            cont_w = cont_r;
        end else if (cs == 8 && cont_r) begin
            {carry_w, tmp_w[63 : 56]} =  tmp_r[63 : 56] + o_data_r[63 : 56] + carry_r;
            tmp_w[55 : 0] = tmp_r[55 : 0];
            o_addr_w = o_addr_r;
            o_data_w = o_data_r;  
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_mem_valid_w = 0;
            o_new_pc_w = o_new_pc_r;
            o_if_valid_w = 0;
            rs2_w = rs2_r;
            rd_w = rd_r;
            op_w = op_r;
            cont_w = cont_r;
        end else if (cs == 9) begin
            if(cont_r) begin
                o_addr_w = tmp_r;
            end else begin
                o_addr_w = o_addr_r;
            end
            o_data_w = rs2_r;
            o_rd_id_w = rd_r;
            o_type_w = o_type_r;
            o_mem_valid_w = 1;
            if(o_type_w == 2) begin
                o_new_pc_w = tmp_r;
                o_if_valid_w = 1;
                // $display("o_new_pc_w:\n%b\n%b", tmp_r, tmp_w);
            end else begin
                o_new_pc_w = 0;
                o_if_valid_w = 0;
            end
            rs2_w = rs2_r;
            rd_w = rd_r;
            op_w = op_r;
            tmp_w = tmp_r;
            carry_w = carry_r;
            cont_w = cont_r;
            // $display("tmp_r:%d, new_pc_w: %d, new_pc_r: %d",tmp_r, o_new_pc_w, o_new_pc_r);
        end else begin
            o_addr_w = o_addr_r;
            o_data_w = o_data_r;  
            o_rd_id_w = o_rd_id_r;
            o_type_w = o_type_r;
            o_mem_valid_w = 0;
            o_new_pc_w = o_new_pc_r;
            o_if_valid_w = 0;
            rs2_w = rs2_r;
            rd_w = rd_r;
            op_w = op_r;
            tmp_w = tmp_r;
            carry_w = carry_r;
            cont_w = cont_r;
        end
    end

    always @(*) begin
        case (cs)
            0: ns = (i_id_valid) ? 1 : 0;
        	1: ns = 2;
        	2: ns = 3;
        	3: ns = 4;
            4: ns = 5;
            5: ns = 6;
            6: ns = 7;
            7: ns = 8;
            8: ns = 9;
            9: ns = 0;
            default: ns = 0;
        endcase
    end

    // sequential part
    always @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            o_addr_r <= 0;
            o_data_r <= 0;
            o_rd_id_r <= 0;
            o_type_r <= 0;
            o_mem_valid_r <= 0;
            o_new_pc_r <= 0;
            o_if_valid_r <= 0;
            cs <= 0;
            rs2_r <= 0;
            rd_r <= 0;
            op_r <= 0;
            tmp_r <= 0;
            carry_r <= 0;
            cont_r <= 0;
        end else begin
            o_addr_r <= o_addr_w;
            o_data_r <= o_data_w;
            o_rd_id_r <= o_rd_id_w;
            o_type_r <= o_type_w;
            o_mem_valid_r <= o_mem_valid_w;
            o_new_pc_r <= o_new_pc_w;
            o_if_valid_r <= o_if_valid_w;
            cs <= ns;
            rs2_r <= rs2_w;
            rd_r <= rd_w;
            op_r <= op_w;
            tmp_r <= tmp_w;
            carry_r <= carry_w;
            cont_r <= cont_w;
        end
    end

endmodule
