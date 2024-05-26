module imem (
    input  wire [31 : 0]       a,
    output wire [31 : 0]       rd
);
    reg [31 : 0] ROM[127 : 0];

    assign rd = ROM[a[31 : 2]];
    
endmodule