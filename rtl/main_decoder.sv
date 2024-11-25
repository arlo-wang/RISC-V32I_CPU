module main_decoder (
    input logic [6:0] opcode_i,    // Opcode from instruction
    output logic reg_wr_en_o,      // Register Write Enable
    output logic mem_wr_en_o,      // Memory Write Enable
    output logic [2:0] imm_src_o,  // Immediate source control
    output logic alu_src_o,        // ALU source (register or immediate)
    output logic branch_o,         // Branch control
    output logic result_src_o,     // Result source (ALU or memory)
    output logic [1:0] alu_op_o    // ALU Operation control
);

    always_comb begin
        // default values for all outputs
        reg_wr_en_o = 0;
        mem_wr_en_o = 0;
        imm_src_o = 3'b000;
        alu_src_o = 0;
        branch_o = 0;
        result_src_o = 0;
        alu_op_o = 2'b00;

        // opcode decoding
        case (opcode_i)
            // I-type op = 3 load instructions
            7'b0000011: begin
                reg_wr_en_o = 1;
                mem_wr_en_o = 0;
                imm_src_o = 3'b000;
                alu_src_o = 1;
                result_src_o = 1;
                alu_op_o = 2'b00;
            end

            // I-type op = 3 Arithmetic Instruction with immediate 
            7'b0010011: begin
                reg_wr_en_o = 1;
                mem_wr_en_o = 0;
                alu_src_o = 1;
                alu_op_o = 2'b10;

                case (funct_3_i)
                    // SLLI
                    3'b001: begin
                        imm_src_o = 3'b101;
                    end
                    // SRLI/SRAI
                    3'b101: begin
                        imm_src_o = 3'b101;
                    end
                    default:
                        imm_src_o = 3'b000;
            end

            // S-type, op = 35
            7'b0100011: begin
                reg_wr_en_o = 0;
                mem_wr_en_o = 1;
                imm_src_o = 3'b001;
                alu_src_o = 1;
                alu_op_o = 2'b00;
            end

            // R-type, op = 51
            7'b0110011: begin
                reg_wr_en_o = 1;
                mem_wr_en_o = 0;
                alu_src_o = 0;
                alu_op_o = 2'b10;
            end

            // B-type, op = 99
            7'b1100011: begin
                reg_wr_en_o = 0;
                mem_wr_en_o = 0;
                imm_src_o = 3'b010;
                alu_src_o = 0;
                branch_o = 1;
                alu_op_o = 2'b01;
            end
        endcase
    end
endmodule
