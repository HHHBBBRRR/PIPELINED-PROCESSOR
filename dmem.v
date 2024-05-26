module dmem (
    input  wire                clk,
    input  wire                 we,
    input  wire [31 : 0]         a,
    input  wire [31 : 0]        wd,
    output wire [31 : 0]        rd
);
    reg [31 : 0 ] RAM[127 : 0];

    assign rd = RAM[a[31 : 2]];

    always @( posedge clk ) begin
        if (we) begin
            RAM[a[31 : 2]] <= wd;
        end
    end

endmodule