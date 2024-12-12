module control_unit (
    input logic [6:0] opcode_i,               // Opcode from instruction
    input logic [2:0] funct3_i,               // funct3 field from instruction
    input logic [6:0] funct7_i,               // funct7_5 (bit 5 of funct7, from instrution bit 30)
    input logic zero_i,                       // Zero flag
    input logic signed [31:0] alu_result_i,   // result from ALU

    output logic reg_wr_en_o,                 // Register Write Enable
    output logic mem_wr_en_o,                 // Memory Write Enable
    output logic [2:0] imm_src_o,             // Immediate source control
    output logic alu_src_o,                   // ALU source (register or immediate)
    output logic result_src_o,                // Result source (ALU or memory)
    output logic [3:0] alu_control_o,         // ALU Operation control (updated to 4 bits)
    output logic pc_src_o,                    // Program counter source (branch decision)
    output logic [3:0] byte_en_o,              // Byte enable for memory access
    output logic alu_src_a_sel_o,
    output logic signed_o
);

    logic [1:0] alu_op;                  // ALU operation control signal
    logic branch;                        // Branch control signal
    logic branch_condition;              // Branch condition signal

    // Instantiate Main Decoder
    main_decoder main_dec (
        .opcode_i(opcode_i),             // Connect opcode
        .funct3_i(funct3_i),             // Connect funct3 to funct_3_i

        .reg_wr_en_o(reg_wr_en_o),       // Connect Register Write Enable
        .mem_wr_en_o(mem_wr_en_o),       // Connect Memory Write Enable
        .imm_src_o(imm_src_o),           // Connect Immediate source
        .alu_src_o(alu_src_o),           // Connect ALU source
        .branch_o(branch),               // Connect Branch control
        .result_src_o(result_src_o),     // Connect Result source
        .alu_op_o(alu_op),               // Connect ALU operation control
        .byte_en_o(byte_en_o),            // Connect byte enable
        .alu_src_a_sel_o(alu_src_a_sel_o),
        .signed_o(signed_o)
    );

    // Instantiate ALU Decoder
    alu_decoder alu_dec (
        .alu_op_i(alu_op),               // Connect ALU operation
        .funct3_i(funct3_i),             // Connect funct3 field
        .funct7_i(funct7_i),             // Connect funct7_5 bit

        .alu_control_o(alu_control_o)    // Connect ALU control output
    );

    // Compute Branch Condition
    always_comb begin
        case (funct3_i)
            3'b000: branch_condition = zero_i;                      // beq: branch if zero is set
            3'b001: branch_condition = ~zero_i;                     // bne: branch if zero is not set
            3'b100: branch_condition = ($signed(alu_result_i) < 0);          // blt
            3'b101: branch_condition = zero_i | ($signed(alu_result_i) > 0); // bge
            /* verilator lint_off UNSIGNED */
            3'b110: branch_condition = (alu_result_i < 0);           //bltu 
            /* verilator lint_on UNSIGNED */
            3'b111: branch_condition = zero_i | (alu_result_i > 0);  //bgeu
            default: branch_condition = 1'b0;                       // Other branch types not implemented here
        endcase
    end

    // Compute Program Counter Source
    always_comb begin
        case (opcode_i)
            7'b1100111: pc_src_o = branch;
            7'b1101111: pc_src_o = branch;
            default: pc_src_o = branch & branch_condition;
        endcase
    end

endmodule
