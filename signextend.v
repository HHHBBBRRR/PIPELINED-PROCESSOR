module signextend (
    input  wire [7 : 0]           a,
    output wire [31 : 0]    signext
);
    assign signext = { {24{a[7]}}, a };
    
endmodule