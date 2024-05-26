module floprc #(
    parameter WIDTH = 32
) 
(
    input  wire                 clk,
    input  wire               reset,
    input  wire               clear,
    input  wire [WIDTH-1 : 0]     d,
    output reg  [WIDTH-1 : 0]     q
);
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end 
        else begin
            if (clear) begin
                q <= 0;
            end 
            else begin
                q <= d;
            end
        end
    end
    
endmodule