module bu (
    input  wire             branch,
    input  wire [3 : 0]      flags,
    input  wire [2 : 0]     funct3,
    output reg               taken
);
    wire v;
    wire c;
    wire n;
    wire z;
    wire cond;

    assign {v, c, n, z} = flags;
    assign taken = branch & cond;

    always @(*) begin
        case (funct3)
            3'b000: cond = z; 
            3'b001: cond = ~z;
            3'b100: cond = (n ^ v);
            3'b101: cond = ~(n ^ v);
            3'b110: cond = ~c;
            3'b111: cond = c;
            default:cond = 1'b0; 
        endcase
    end
    
endmodule