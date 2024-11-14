module alu (
    input logic [31:0] a, b, 
    input logic [31:0] alu_ctrl,
    output logic [31:0] result,
    output logic zero 
);
    always_comb begin
        case (alu_ctrl)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = a & b;
            4'b0011: result = a | b;
            4'b0100: result = a ^ b;
            4'b0101: result = a << b[4:0];
            4'b0110: result = a >> b[4:0];
            default: result = 0;
        endcase 
        zero = (results == 0);
    end
endmodule
