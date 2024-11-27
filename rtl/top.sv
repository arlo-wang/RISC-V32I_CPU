module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,                  // clock signal
    input   logic rst,                  // reset signal
    output  logic [DATA_WIDTH-1:0] a0,   // register 11 output
    output logic [31:0] instruction
);

/// /// BLOCK 1: Program counter and related adders /// ///
// internal signals
logic [DATA_WIDTH-1:0] pc, inc_pc, imm_op, branch_pc, next_pc;
logic pc_src;

// adder used to add PC and ImmOp
adder branch_pc_adder(
    .in1 (pc),
    .in2 (imm_op),
    
    .out (branch_pc)
);

// adder used to +4
adder inc_pc_adder(
    .in1 (pc), 
    .in2 (32'd4),

    .out (inc_pc)
);

// mux used to select between branch_pc and inc_pc
mux pc_mux(
    .in0(inc_pc),
    .in1(branch_pc),
    .sel(pc_src),

    .out(next_pc)
);

// program counter
pc_reg pc_reg(
    .clk     (clk),
    .rst     (rst),
    .next_pc (next_pc),
    
    .pc      (pc)
);


/// /// BLOCK 2: The Register File, ALU and the related MUX /// ///
// Instruction & fields
//logic [DATA_WIDTH-1:0] instruction;
/* verilator lint_off UNUSED */
logic [24:0] instruction31_7 = instruction[31:7];
/* verilator lint_on UNUSED */

logic [6:0] opcode = instruction[6:0];
logic [2:0] funct3 = instruction[14:12];
logic funct7_5 = instruction[30];

// Control signals
logic alu_src, reg_wr_en;

/* verilator lint_off UNUSED */
logic mem_wr_en, result_src;
/* verilator lint_on UNUSED */

logic [2:0] imm_src;
logic [3:0] alu_control;

// Register data 
logic [4:0] rs1 = instruction[19:15]; // rs1: instruction[19:15]
logic [4:0] rs2 = instruction[24:20]; // rs2: instruction[24:20]
logic [4:0] rd  = instruction[11:7];  // rd: instruction[11:7]

// Instantiate Instruction Memory
instruction_memory imem (
    .addr(pc),
    .instruction(instruction)
);

// Instantiate Control Unit
control_unit ctrl (
    .opcode(opcode),
    .funct3(funct3),
    .funct7_5(funct7_5),
    .zero(eq),

    .pc_src(pc_src),
    .result_src(result_src),
    .mem_wr_en(mem_wr_en),
    .alu_control(alu_control),
    .alu_src(alu_src),
    .imm_src(imm_src),
    .reg_wr_en(reg_wr_en)
);

// Instantiate Sign-Extension Unit
sign_exten sext (
    .instr_31_7(instruction31_7),
    .imm_src(imm_src),
    .imm_ext(imm_op)
);


/// /// BLOCK 3: Control Unit, the Sign-extension Unit and the instruction memory  /// ///
//Register_file signals

logic [DATA_WIDTH-1:0] rd2, alu_op1, alu_op2, alu_out;
logic eq;

register_file reg_file_inst (
    .clk(clk),
    .ad1(rs1),
    .ad2(rs2),
    .ad3(rd),
    .wd3(alu_out),
    .we3(reg_wr_en),

    .rd1(alu_op1),
    .rd2(rd2),
    .a0(a0) //register 10
);
mux alu_mux_inst(
    .in0(rd2),
    .in1(imm_op),
    .sel(alu_src),
    .out(alu_op2)
);

alu alu_inst(
    .src_a(alu_op1),
    .src_b(alu_op2),
    .alu_control(alu_control),
    .alu_result(alu_out),
    .zero(eq)
);

// initial begin
//     we3 =1;
//     rs1 = 5'd1;
//     rs2 = 5'd2;
//     rd = 5'd3;
//     alu_ctrl = 4'b0000;
//     alu_src = 1;
// end

endmodule
