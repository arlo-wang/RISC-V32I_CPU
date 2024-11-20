module alu (
    input logic [31:0] a, b, 
    input logic [3:0] alu_ctrl,
    output logic [31:0] result,
    output logic zero 
);
    // ALU operation logic
    always_comb begin
        case (alu_ctrl)
            4'b0000: result = a + b;    // addition
            4'b0001: result = a - b;    // subtraction
            4'b0010: result = a & b;    // bitwise AND
            4'b0011: result = a | b;    // bitwise OR
            4'b0100: result = a ^ b;    // bitwise XOR
            4'b0101: result = a << b[4:0];  // logic left shift by the value in b[4:0]
            4'b0110: result = a >> b[4:0];  // logic right shift by the value in b[4:0]
            default: result = 0;    // set default result to 0
        endcase 
        // set the zero flag
        zero = (result == 0);
    end
endmodule
