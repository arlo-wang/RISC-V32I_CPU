module control_unit (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic funct7_5,
    input logic zero,
    output logic reg_wr_en,
    output logic mem_wr_en,
    output logic [2:0] imm_src,
    output logic alu_src,
    output logic result_src,
    output logic [2:0] alu_control,
    output logic pc_src
);

    logic [1:0] alu_op;
    logic branch;
    
    // Instantiate Main Decoder
    main_decoder main_dec (
        .opcode(opcode),
        .reg_wr_en(reg_wr_en),
        .mem_wr_en(mem_wr_en),
        .imm_src(imm_src),
        .alu_src(alu_src),
        .branch(branch),
        .result_src(result_src),
        .alu_op(alu_op)
    );

    // Instantiate ALU Decoder
    alu_decoder alu_dec (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .alu_control(alu_control)
    );

    // Branch decision
    assign pc_src = branch & zero;
endmodule
