module aludec (
    input  wire                 opb5,
    input  wire               funct3,
    input  wire             funct7b5,
    input  wire [1 : 0]       alu_op,
    output reg  [3 : 0]  alu_control
);
    wire R_type_sub;
    
    assign R_type_sub = funct7b5 & opb5;

    always @(*) begin
        case (alu_op)
            2'b00 : alu_control = 4'b0000;
            2'b01 : alu_control = 4'b0001;
            default: 
                case (funct3)
                    3'b000 : begin
                        if (R_type_sub) begin
                            alu_control = 4'b0001;
                        end 
                        else begin
                            alu_control = 4'b0000;
                        end
                    end
                    3'b001 : alu_control = 4'b0110; 
                    3'b010 : alu_control = 4'b0101;
                    3'b100 : alu_control = 4'b0010;
                    3'b101 : begin
                        if (funct7b5) begin
                            alu_control = 4'b1000;
                        end 
                        else begin
                            alu_control = 4'b0111;
                        end
                    end
                    3'b110 : alu_control = 4'b0011;
                    3'b111 : alu_control = 4'b0010;
                    default: alu_control = 4'bx;
                endcase
        endcase
    end

endmodule