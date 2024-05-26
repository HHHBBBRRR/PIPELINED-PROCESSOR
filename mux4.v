module mux4 #(
    parameter WIDTH = 32
) 
(
    input wire [WIDTH-1 : 0] d0,
    input wire [WIDTH-1 : 0] d1,
    input wire [WIDTH-1 : 0] d2,
    input wire [WIDTH-1 : 0] d3,
    input wire [1 : 0]        s,
    output reg [WIDTH-1 : 0]  y
);
    always @(*) begin
        case (s)
            2'b00 : y = d0;
            2'b01 : y = d1;
            2'b10 : y = d2;
            2'b11 : y = d3;
            default: y = 32'bx;
        endcase
    end
    
endmodule