module hazard_unit (
    // extra signal used to detect lw for stall
    input logic [4:0] rd_addr1_d_i,
    input logic [4:0] rd_addr2_d_i,
    input logic [4:0] wr_addr_e_i, // RdE
    input logic mem_byte_en_e_i,
    
    // d
    input logic [4:0] rd_addr1_e_i, // Rs1E
    input logic [4:0] rd_addr2_e_i, // Rs2E
    input logic [4:0] wr_addr_m_i, // RdM
    input logic [4:0] wr_addr_w_i, // RdW
    input logic reg_wr_en_m_i,
    input logic reg_wr_en_w_i,
    input logic branch_i, // or pr_scr

    output logic [1:0] forward_a_e_o,
    output logic [1:0] forward_b_e_o,
    output logic stall_o,
    output logic flush_o

);

    always_comb begin

        stall_o = 1'b0;
        flush_o = 1'b0;
        forward_a_e_o = 2'b00;
        forward_b_e_o = 2'b00;

        // MUX for forward_a_e_o
            // 00 : rd_addr1_e : same as no pipeline
            // 01 : result_w : forwarding from W state after a MUX in lecture slides(after data memory)
            // 10 : alu_result_m : forwarding from M state(after ALU)

        if (reg_wr_en_m_i && (wr_addr_m_i != 0) && (wr_addr_m_i == rd_addr1_e_i)) begin
            forward_a_e_o = 2'b10;
        end 
        else if (reg_wr_en_w_i && (wr_addr_w_i != 0) && (wr_addr_w_i == rd_addr1_e_i)) begin
            forward_a_e_o = 2'b01;
        end 
        else begin
            forward_a_e_o = 2'b00;
        end

        // MUX for forward_b_e_o
            // 00 : rd_addr2_e : same as no pipeline
            // 01 : result_w : forwarding from W state after a MUX in lecture slides(after data memory)
            // 10 : alu_result_m : forwarding from M state(after ALU)

        if (reg_wr_en_m_i && (wr_addr_m_i != 0) && (wr_addr_m_i == rd_addr2_e_i)) begin
            forward_b_e_o = 2'b10;
        end 
        else if (reg_wr_en_w_i && (wr_addr_w_i != 0) && (wr_addr_w_i == rd_addr2_e_i)) begin
            forward_b_e_o = 2'b01;
        end 
        else begin
            forward_b_e_o = 2'b00;
        end


        // For B-type / J-type hazard --> flush
        // use branch signal or some specific pc_scr value to assign flush when branch/jump
        if (branch_i) begin // or specific pc_scr
            flush_o = 1;
        end

        // Load Instruction --> Stall
        // When both 1: There is Load Instruction in the Execution stage
        //           2: Register used to write at Execution stage Overlapped with one of register are used in Decoding Stage

        if (MemRead_E && ((Rd_E == Rs1_D) || (Rd_E == Rs2_D))) begin
            stall_o = 1'b1;
        end 
        else begin
            stall_o = 1'b0;
        end


    end
     

endmodule