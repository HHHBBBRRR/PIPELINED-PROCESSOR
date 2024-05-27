module lsu (
    input  wire [2 : 0]     funct3,
    output reg  [1 : 0]  load_tyep,
    output reg          store_type
);
    always @(*) begin
        case (funct3)
            3'b000: begin
                load_tyep = 2'b10;
                store_type = 1'b1;
            end
            3'b010: begin
                load_tyep = 2'b00;
                store_type = 1'b0;
            end
            3'b100: begin
                load_tyep = 2'b01;
                store_type = 1'bx;
            end 
            default: begin
                load_tyep = 2'bx;
                store_type = 1'bx;
            end
        endcase
    end
    
endmodule