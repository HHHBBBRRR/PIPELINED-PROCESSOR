module wdunit (
    input  wire [31 : 0] rd2,
    input  wire [31 : 0] read_data,
    input  wire          store_type,
    input  wire [1 : 0]  byte_of_fset,
    output wire [31 : 0] write_data
);
    wire [31 : 0] storeb0;
    wire [31 : 0] storeb1;
    wire [31 : 0] storeb2;
    wire [31 : 0] storeb3;
    wire [31 : 0] sbword;

    assign storeb0 = {read_data[31 : 8], rd2[7 : 0]};
    assign storeb1 = {read_data[31 : 16], rd2[7 : 0], read_data[7 : 0]};
    assign storeb2 = {read_data[31 : 24], rd2[7 : 0], read_data[15 : 0]};
    assign storeb3 = {rd2[7 : 0], read_data[23 : 0]};

    mux4 #(32) sbmux (
        .d0(storeb0),
        .d1(storeb1),
        .d2(storeb2),
        .d3(storeb3),
        .s(byte_of_fset),
        .y(sbword)
    );

    mux2 #(32) wdmux (
        .d0(rd2),
        .d1(sbword),
        .s(store_type),
        .y(write_data)
    );
    
endmodule