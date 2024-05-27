module zeroextend (
    input  wire [7 : 0]           a,
    output wire [31 : 0] zeroimmext
);
    assign zeroimmext = { 24'b0, a };
    
endmodule