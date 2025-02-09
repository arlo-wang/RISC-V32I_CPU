module pipeline_reg_e_m #(
    parameter WIDTH = 32
)(
    input logic clk_i,

    // control unit
    input logic reg_wr_en_e_i,
    input logic result_src_e_i,
    input logic mem_wr_en_e_i,
    input logic [3:0] mem_byte_en_e_i,
    input logic data_mem_or_pc_mem_sel_e_i,

    output logic reg_wr_en_m_o,
    output logic result_src_m_o,
    output logic mem_wr_en_m_o,
    output logic [3:0] mem_byte_en_m_o,
    output logic data_mem_or_pc_mem_sel_m_o,

    // data path
    input logic [WIDTH - 1:0] alu_result_e_i,
    input logic [WIDTH - 1:0] rd_data2_e_i, // RD2_E in lecture
    input logic [4:0] wr_addr_e_i, // writen address, A3 in lecture
    input logic [WIDTH - 1:0] pc_plus_4_e_i,

    output logic [WIDTH - 1:0] alu_result_m_o,
    output logic [WIDTH - 1:0] rd_data2_m_o,
    output logic [4:0] wr_addr_m_o,
    output logic [WIDTH - 1:0] pc_plus_4_m_o

    
);

always_ff @(posedge clk_i) begin

    // control unit
    reg_wr_en_m_o <= reg_wr_en_e_i;
    result_src_m_o <= result_src_e_i;
    mem_wr_en_m_o <= mem_wr_en_e_i;
    mem_byte_en_m_o <= mem_byte_en_e_i;
    data_mem_or_pc_mem_sel_m_o <= data_mem_or_pc_mem_sel_e_i;

    // data path
    alu_result_m_o <= alu_result_e_i;
    rd_data2_m_o <= rd_data2_e_i;
    wr_addr_m_o <= wr_addr_e_i;
    pc_plus_4_m_o <= pc_plus_4_e_i;

end

endmodule
