module sign_exten (
    input logic [31:0] instruction,  // instruction
    output logic [31:0] immediate    // extended immediate
);

    always_comb begin
        case (instruction[6:0])
            7'b0000011, 7'b0010011: // I
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            7'b0100011: // S
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: // B
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            default:
                immediate = 32'd0; 
        endcase
    end
endmodule
