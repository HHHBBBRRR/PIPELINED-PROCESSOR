module hazard (
    input  wire [4 : 0]           Rs1D,
    input  wire [4 : 0]           Rs2D,
    input  wire [4 : 0]           Rs1E,
    input  wire [4 : 0]           Rs2E,
    input  wire [4 : 0]            RdE,
    input  wire [4 : 0]            RdM,
    input  wire [4 : 0]            RdW,
    input  wire                pc_srcE,
    input  wire [1 : 0]    result_srcE,
    input  wire             reg_writeM,
    input  wire             reg_writeW,
    output reg  [1 : 0]     forward_AE,
    output reg  [1 : 0]     forward_BE,
    output wire                 stallF,
    output wire                 stallD,
    output wire                 flushD,
    output wire                 flushE
);
    wire load_stallD;    

    always @(*) begin
        forward_AE = 2'b00;
        forward_BE = 2'b00;
        if (Rs1E != 5'b0) begin
            if ((Rs1E == RdM) & reg_writeM) begin
                forward_AE = 2'b10;
            end
            else if ((Rs1E == RdW) & reg_writeW) begin
                forward_AE = 2'b01;
            end
        end
        if (Rs2E != 5'b0) begin
            if ((Rs2E == RdM) & reg_writeM) begin
                forward_BE = 2'b10;
            end
            else if ((Rs2E == RdW) & reg_writeW) begin
                forward_BE = 2'b01;
            end
        end
    end

    assign load_stallD = (result_srcE == 2'b01) & ((Rs1D == RdE) | (Rs2D == RdE));
    assign stallF = load_stallD;
    assign stallD = load_stallD;

    assign flushD = pc_srcE;
    assign flushE = pc_srcE | load_stallD;
    
endmodule