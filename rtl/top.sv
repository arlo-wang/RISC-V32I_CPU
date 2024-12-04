module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,     // clock signal
    input   logic trigger,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0
);

logic trigger_latched;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        // Set trigger_latched based on trigger during reset
        if (trigger) begin
            trigger_latched <= 1;
        end else begin
            trigger_latched <= 0;
        end
    end 
    else if (trigger) begin
        // Standard trigger logic after reset
        trigger_latched <= 1;
    end
end

// Stall & Flush
logic stall, flush;


// Stage 1 Fetch - f

/// /// BLOCK 1: instruction memory, pc_plus4_adder, pc_reg and pc_mux /// ///
logic [DATA_WIDTH-1:0] pc_f, pc_plus_4_f, pc_next_f; // block 1 internal signals
logic [DATA_WIDTH-1:0] pc_target_e; // pc target E
logic pc_src_e; // Control signal
logic [DATA_WIDTH-1:0] instr_f; // Instruction signal
logic [DATA_WIDTH-1:0] instr_d, pc_d, pc_plus_4_d; // output for decoding

// adder used to +4
adder pc_plus4_adder(
    .in1_i (pc_f), 
    .in2_i (32'd4),

    .out_o (pc_plus_4_f)
);

// mux used to select between pc_target and pc_plus_4
mux pc_mux(
    .in0_i(pc_plus_4_f), // PC += 4
    .in1_i(pc_target), // branch
    .sel_i(pc_src_e),

    .out_o(pc_next_f)
);

// Instantiate Instruction Memory
instr_mem instr_mem_inst (
    .addr_i(pc_f),
    .instr_o(instr_f)
);

pc_reg pc_reg_inst (
    .clk(clk & trigger_latched),
    .rst(rst),
    .pc_next_i(pc_next_f),

    .pc_o(pc_f)
);

pipeline_reg_f_d #(
    .WIDTH(DATA_WIDTH)
) (
    .clk_i(clk),
    .stall_i(stall),
    .flush_i(flush),
    .instr_f_i(instr_f),
    .pc_f_i(pc_f),
    .pc_plus_4_f_i(pc_plus_4_f),

    .instr_d_o(instr_d),
    .pc_d_o(pc_d),
    .pc_plus_4_d_o(pc_plus_4_d)
);



/// /// Stage 2 Decode - d


/// /// BLOCK 2: Register file, control unit, and extend /// ///

// // // control unit signals
// instr signal has been declared in block 1
logic [24:0] instr_31_7 = instr_d[31:7];
logic [6:0] op = instr_d[6:0];
logic [2:0] funct3 = instr_d[14:12];
logic [6:0] funct7 = instr_d[31:25];

logic pc_src_d, reg_wr_en_d, mem_wr_en_d, result_src_d, alu_src_d, alu_src_a_sel_d, signed_bit;
logic [2:0] imm_src_d;
logic [3:0] alu_control_d, mem_byte_en_d;



// // // Register signals
logic [4:0] rd_addr1_d = instr[19:15]; // rd_addr1: instr[19:15]
logic [4:0] rd_addr2_d = instr[24:20]; // rd_addr2: instr[24:20]
logic [4:0] wr_addr_d  = instr[11:7];  // wr_addr: instr[11:7]
logic [DATA_WIDTH-1:0] rd_data1_d, rd_data2_d;
logic [DATA_WIDTH-1:0] alu_result_e; // unsure to use e stage /m stage

// // // extend block signal
logic [DATA_WIDTH-1:0] imm_ext;

// Instantiate Control Unit
control_unit ctrl (
    .opcode_i(op),
    .funct3_i(funct3),
    .funct7_i(funct7),
    .zero_i(eq_e),
    .alu_result_i(alu_result_e), // unsure to use e stage /m stage

    .reg_wr_en_o(reg_wr_en_d),
    .mem_wr_en_o(mem_wr_en_d),
    .imm_src_o(imm_src_d),
    .alu_src_o(alu_src_d),  
    .result_src_o(result_src)_d,  
    .alu_control_o(alu_control_d),
    .pc_src_o(pc_src_d),
    .byte_en_o(mem_byte_en_d),
    .alu_src_a_sel_o(alu_src_a_sel_d),
    .signed_o(signed_bit)
);

// Instantiate Sign-Extension Unit
sign_exten sign_exten_inst (
    .instr_31_7_i(instr_31_7_d),
    .imm_src_i(imm_src_d),
    .signed_i(signed_bit),

    .imm_ext_o(imm_ext_d)
);

register_file reg_file_inst (
    .clk(clk),
    .rd_addr1_i(rd_addr1_d),
    .rd_addr2_i(rd_addr2_d),
    .wr_addr_i(wr_addr_d),
    .wr_data_i(result_w),
    .reg_wr_en_i(reg_wr_en_d),

    .rd_data1_o(rd_data1_d),
    .rd_data2_o(rd_data2_d),
    .a0(a0)
);

logic [DATA_WIDTH-1:0] option_d, option2_d; // for MUX in Execution stage

always_comb begin
    case (op)
        7'b0110111: option_d = 32'b0; // LUI
        default: option_d = pc_d; // AUIPC
    endcase
end

always_comb begin
    case (op)
        7'b1100111: begin //JAL
            option2_d = rd_data1_d;
        end
        default: option2_d = pc_d; // JALR stage for pc need defined for option2_d
    endcase
end

logic data_mem_or_pc_mem_sel_d;
always_comb begin
    case (op)
        7'b1101111: data_mem_or_pc_mem_sel_d = 1;
        7'b1100111: data_mem_or_pc_mem_sel_d = 1;
        default: data_mem_or_pc_mem_sel_d = 0;
    endcase
end

pipeline_reg_f_d #(
    .WIDTH(DATA_WIDTH)
) (

    .clk_i(clk),
    .flush_i(flush),
    .stall_i(stall),

    // Control Unit Signals
    .reg_wr_en_d_i(reg_wr_en_d),
    .result_src_d_i(result_src_d),
    .mem_wr_en_d_i(mem_wr_en_d),
    .mem_byte_en_d_i(mem_byte_en_d),
    .pc_src_d_i(pc_src_d),
    .alu_control_d_i(alu_control_d),
    .alu_src_d_i(alu_src_d),
    .alu_src_a_sel_d_i(alu_src_a_sel_d),
    .option_d_i(option_d),
    .option2_d_i(option2_d),
    .data_mem_or_pc_mem_sel_d_i(data_mem_or_pc_mem_sel_d),

    .reg_wr_en_e_o(reg_wr_en_e),
    .result_src_e_i(result_src_e),
    .mem_wr_en_e_o(mem_wr_en_e),
    .mem_byte_en_e_o(mem_byte_en_e),
    .pc_src_e_o(pc_src_e),
    .alu_control_e_o(alu_control_e),
    .alu_src_e_o(alu_src_e),
    .alu_src_a_sel_e_o(alu_src_a_sel_e),
    .option_e_o(option_e),
    .option2_e_o(option2_e),
    .data_mem_or_pc_mem_sel_e_o(data_mem_or_pc_mem_sel_e),

    // Data Path Signals
    .rd_data1_d_i(rd_data1_d),
    .rd_data2_d_i(rd_data2_d),
    .pc_d_i(pc_d),
    .rd_addr1_d_i(rd_addr1_d),
    .rd_addr2_d_i(rd_addr2_d),
    .wr_addr_d_i(wr_addr_d),
    .imm_ext_d_i(imm_ext_d),
    .pc_plus_4_d_i(pc_plus_4_d),

    .rd_data1_e_o(rd_data1_e),
    .rd_data2_e_o(rd_data2_e),
    .pc_e_o(pc_e),
    .rd_addr1_e_o(rd_addr1_e),
    .rd_addr2_e_o(rd_addr2_e),
    .wr_addr_e_o(wr_addr_e),
    .imm_ext_e_o(imm_ext_e),
    .pc_plus_4_e_o(pc_plus_4_e)
);


// Stage 3 Execution

/// /// BLOCK 3: Control Unit, the Sign-extension Unit and the instruction memory  /// ///
// pc_target has been declared in block 1
// // ALU signals
logic [DATA_WIDTH-1:0] src_a, src_b;
logic eq; // zero flag
logic [3:0] mem_byte_en_e;

// // data memory siganls 
logic [DATA_WIDTH-1:0] read_data;

// ALU unit
alu alu_inst(
    .src_a_i(src_a),
    .src_b_i(src_b),
    .alu_control_i(alu_control),

    .alu_result_o(alu_result),
    .zero_o(eq)
);


data_mem data_mem_inst(
    .clk(clk),
    .addr_i(alu_result),
    .wr_data_i(rd_data2),
    .wr_en_i(mem_wr_en),
    .byte_en_i(mem_byte_en),

    .rd_data_o(read_data)
);

logic [31:0] data_to_use;


mux data_mem_pc_next(
    .in0_i(read_data),
    .in1_i(pc_plus_4),
    .sel_i(data_mem_or_pc_mem_sel),

    .out_o(data_to_use)
);

//MUX for src_a (ALU first operand)
mux alu_src_a_mux(
    .in0_i(rd_data1),       // from reg_file (default operand)
    .in1_i(option), // only for LUi and AUIPC
    .sel_i(alu_src_a_sel),  // new control signal for src_a selection

    .out_o(src_a)
);

logic [DATA_WIDTH-1:0] result_w;

// MUX for src_b (ALU second operand)
mux alu_src_b_mux(
    .in0_i(rd_data2),         // From register file
    .in1_i(imm_ext),          // Immediate value
    .sel_i(alu_src),          // ALU source control signal

    .out_o(src_b)
);

// mux used for data memory
mux data_mem_mux(
    .in0_i(alu_result),
    .in1_i(data_to_use),
    .sel_i(result_src),

    .out_o(result) 
);

// adder used to add pc and imm_ext
adder alu_adder(
    .in1_i(option2),
    .in2_i(imm_ext),
    
    .out_o(pc_target)
);

endmodule
