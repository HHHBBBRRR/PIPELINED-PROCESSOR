module maindec (
    input  wire [6 : 0]             op,
    output wire [1 : 0]     result_src,
    output wire              mem_write,
    output wire          pc_target_src,
    output wire              ALU_src_A,
    output wire              ALU_src_B,
    output wire [2 : 0]        imm_src,
    output wire [1 : 0]         alu_op,
    output wire              reg_write,
    output wire                 branch,
    output wire                   jump
);
    reg [13 : 0] controls;

    assign {
        reg_write,
        imm_src,
        ALU_src_A,
        ALU_src_B,
        mem_write,
        result_src,
        branch,
        alu_op,
        jump,
        pc_target_src
    } = controls;
    
    always @(*) begin
        case (op)
            7'b0000011 : controls = 14'b1_000_0_1_0_01_0_00_0_x;
            7'b0100011 : controls = 14'b0_001_0_1_1_00_0_00_0_x;
            7'b0110011 : controls = 14'b1_xxx_0_0_0_00_0_10_0_x;
            7'b1100011 : controls = 14'b0_010_0_0_0_00_1_01_0_0;
            7'b0010011 : controls = 14'b1_000_0_1_0_00_0_10_0_x;
            7'b1101111 : controls = 14'b1_100_1_1_0_00_0_00_0_x;
            7'b1100111 : controls = 14'b1_000_0_1_0_10_0_00_1_1;
            7'b0010111 : controls = 14'b1_100_x_x_0_11_0_xx_0_0;
            default    : controls = 14'bx_xxx_x_x_x_xx_x_xx_x_x;
        endcase
    end

endmodule