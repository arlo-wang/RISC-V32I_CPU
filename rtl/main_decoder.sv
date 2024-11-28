module main_decoder (
    input logic [6:0] opcode_i,    // Opcode from instruction
    input logic [2:0] funct3_i,   // funct3 field from instruction

    output logic reg_wr_en_o,      // Register Write Enable
    output logic mem_wr_en_o,      // Memory Write Enable
    output logic [2:0] imm_src_o,  // Immediate source control
    output logic alu_src_o,        // ALU source (register or immediate)
    output logic branch_o,         // Branch control
    output logic result_src_o,     // Result source (ALU or memory)
    output logic [1:0] alu_op_o,   // ALU Operation control
    output logic [3:0] byte_en_o   // Byte enable
);

    always_comb begin
        // Opcode decoding
        case (opcode_i)
            // I-type op = 3 
            // Load instructions
            7'b0000011: begin
                reg_wr_en_o = 1;     // Write to register
                mem_wr_en_o = 0;     // Don't write to memory

                imm_src_o = 3'b000;  // // // // // zero extends needs to be implemented
                
                alu_src_o = 1;       // ALU source is immediate

                branch_o = 0;
                result_src_o = 1;
                alu_op_o = 2'b00;

                case (funct3_i) //// lbu & lhu needs zero-extended haven't been implemented
                    3'b000: begin
                        byte_en_o = 4'b0001; // LB
                    end
                    3'b001: begin
                        byte_en_o = 4'b0011; // LH
                    end
                    3'b010: begin
                        byte_en_o = 4'b1111; // LW
                    end
                    3'b100: begin
                        byte_en_o = 4'b0001; // LBU
                    end
                    3'b101: begin
                        byte_en_o = 4'b0011; // LHU
                    end
                    default: begin
                        byte_en_o = 4'b0000; //default case
                    end
                endcase
            end

            // I-type op = 19
            // Arithmetic Instruction with immediate 
            7'b0010011: begin
                reg_wr_en_o = 1;
                mem_wr_en_o = 0;
                alu_src_o = 1;
                alu_op_o = 2'b10;

                case (funct3_i)
                    // SLLI
                    3'b001:  imm_src_o = 3'b101;
                    // SRLI/SRAI
                    3'b101:  imm_src_o = 3'b101;

                    default: imm_src_o = 3'b000;
                endcase
            end

            // S-type, op = 35
            // Store instructions
            7'b0100011: begin
                reg_wr_en_o = 0;
                mem_wr_en_o = 1;
                imm_src_o   = 3'b001;
                alu_src_o   = 1;
                alu_op_o    = 2'b00;

                case (funct3_i)
                    3'b000: begin
                        byte_en_o = 4'b0001; // Store byte (sb)
                    end
                    3'b001: begin
                        byte_en_o = 4'b0011; // Store half (sh)
                    end
                    3'b010: begin
                        byte_en_o = 4'b1111; // Store word (sw)
                    end
                    default: begin
                        byte_en_o = 4'b0000; //default case
                    end
                endcase
            end

            // R-type, op = 51
            // Arithmetic instructions
            7'b0110011: begin
                reg_wr_en_o = 1;
                mem_wr_en_o = 0;
                alu_src_o = 0;
                alu_op_o = 2'b10;
            end

            // B-type, op = 99
            // Branch instructions
            7'b1100011: begin
                reg_wr_en_o = 0;
                mem_wr_en_o = 0;

                case (funct3_i)
                    3'b110: begin
                        imm_src_o = 3'b111;
                    end
                    3'b111: begin
                        imm_src_o = 3'b111;
                    end
                    default: imm_src_o = 3'b010;
                endcase

                alu_src_o   = 0;
                branch_o    = 1;
                alu_op_o    = 2'b01;
            end

            // J-type, op = 111
            // JAL instruction
            7'b1101111: begin
                branch_o = 1;
                imm_src_o = 3'b100;
                alu_src_o = 1;
                reg_wr_en_o = 1;
                result_src_o = 1;
            end

            // J-type op = 103
            // JALR instruction
            7'b1100111: begin
                branch_o = 1;
                imm_src_o = 3'b100;
                alu_src_o = 1;
                reg_wr_en_o = 1;
                result_src_o = 1;
            end

            // U type op = 55
            // LUI instruction
            7'b0110111: begin
                alu_src_o = 1;
                reg_wr_en_o = 1;
                alu_op_o = 2'b11; // Only use src_b_i in the ALU
            end

            // U type op = 23
            // AUIPC instruction
            7'b0010111: begin
                alu_src_o = 1;
                reg_wr_en_o = 1;
                alu_op_o = 2'b11; // Only use src_b_i in the ALU
            end

            default: begin
                reg_wr_en_o = 0;
                mem_wr_en_o = 0;
                imm_src_o = 3'b000;
                alu_src_o = 0;
                branch_o = 0;
                result_src_o = 0;
                alu_op_o = 2'b00;
                byte_en_o = 4'b0000;
            end
        endcase
    end
endmodule
