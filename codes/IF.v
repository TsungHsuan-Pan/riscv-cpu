module IF #( 
	parameter ADDR_W = 64,
	parameter INST_W = 32,
	parameter DATA_W = 64
)(
    input                   i_clk,
    input                   i_rst_n,
    input [ADDR_W-1 : 0]  i_new_pc,
    input                   i_valid,
    output                  o_i_valid_addr, // to instruction memory
    output [ADDR_W-1 : 0] o_i_addr,       // to instruction memory
    output [DATA_W-1 : 0] o_pc,
    output                  o_valid
);

    reg                  o_i_valid_addr_r, o_i_valid_addr_w; // to instruction memory
    reg [ADDR_W-1 : 0] o_i_addr_r, o_i_addr_w;       // to instruction memory
    reg [DATA_W-1 : 0] o_pc_r, o_pc_w;
    reg                  o_valid_r, o_valid_w;
    reg [DATA_W-1 : 0] pc_r, pc_w;
    reg        [4 : 0] cs, ns;

    assign o_i_valid_addr = o_i_valid_addr_r;
    assign o_i_addr = o_i_addr_r;
    assign o_pc = o_pc_r;
    assign o_valid = o_valid_r;

    // integer i;

    always @(*) begin
        // if(cs == 15) begin
        //     $display("pc: %d", pc_r);
        // end
        // $display("cs:%d, pc: %d", cs, pc_r);
        case (cs)
        	0: ns = (o_i_valid_addr) ? 1 : 0;
        	1: ns = 2;
        	2: ns = 3;
        	3: ns = 4;
            4: ns = 5;
            5: ns = 6;
            6: ns = 7;
            7: ns = 8;
            8: ns = 9;
            9: ns = 10;
            10: ns = 11;
            11: ns = 12;
            12: ns = 13;
            13: ns = 14;
            14: ns = 15;
            15: ns = 0;
            // 16;
            // 16: ns = 17;
            // 17: ns = 0;
            default: ns = 0;
        endcase
    end

    always @(*) begin
        if(cs == 3) begin
            o_valid_w = 1;
            o_pc_w = pc_r;
        end else begin
            o_valid_w = 0;
            o_pc_w = 0;
        end
        if(cs == 0) begin
            o_i_valid_addr_w = 1;
            o_i_addr_w = pc_r;
            pc_w = pc_r;
        end else if(cs == 13) begin
            o_i_valid_addr_w = 0;
            o_i_addr_w = 0;
            pc_w[8:0] = pc_r[8:0] + 4;
            pc_w[DATA_W-1:9] = pc_r[DATA_W-1:9];
        end else if(i_valid) begin
            // $display("cs: %d, new_pc: %d", cs, i_new_pc);
            o_i_valid_addr_w = 0;
            o_i_addr_w = i_new_pc;
            pc_w = i_new_pc;
        end else begin
            o_i_valid_addr_w = 0;
            o_i_addr_w = 0;
            pc_w = pc_r;
        end
    end

    // sequential part
    always @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            o_i_valid_addr_r <= 0;
            o_i_addr_r <= 0;
            o_pc_r <= 0;
            o_valid_r <= 0;            
            cs <= 0;
            pc_r <= 0;
        end else begin
            o_i_valid_addr_r <= o_i_valid_addr_w;
            o_i_addr_r <= o_i_addr_w;
            o_pc_r <= o_pc_w;
            o_valid_r <= o_valid_w;
            cs <= ns;
            pc_r <= pc_w;
        end
    end


endmodule
