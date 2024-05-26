module alu (
    input  wire [31 : 0]            a,
    input  wire [31 : 0]            b,
    input  wire [3 : 0]   alu_control,
    output  reg [31 : 0]       result,
    output wire [3 : 0]         flags
);
    wire [31 : 0]  inv_b;
    wire [31 : 0]    sum;
    wire            cout;
    wire       is_add_sub;
    wire               v;
    wire               c;
    wire               n;
    wire               z;

    assign flags = {v, c, n, z};
    assign inv_b = alu_control[0] ? ~b : b;
    assign {cout, sum} = a + inv_b + alu_control[0];
    assign is_add_sub = (~alu_control[3] & ~alu_control[2] & ~alu_control[1]) |
                        (~alu_control[3] & ~alu_control[1] & alu_control[0]);
    assign z = (result == 32'b0);
    assign n = result[31];
    assign c = cout & is_add_sub;
    assign v = ~(alu_control[0] ^ a[31] ^b[31]) & (a[31] ^ sum[31]) & is_add_sub;
                        
    always @(*) begin
        case (alu_control)
            4'b0000: result = sum;
            4'b0001: result = sum;
            4'b0010: result = a & b;
            4'b0011: result = a | b;
            4'b0100: result = a ^ b;
            4'b0101: result = sum[31] ^ v;
            4'b0110: result = a << b[4:0];
            4'b0111: result = a >> b[4:0];
            4'b1000: result = $signed(a) >>> b[4:0];
            default: result = 32'bx;
        endcase
    end

endmodule