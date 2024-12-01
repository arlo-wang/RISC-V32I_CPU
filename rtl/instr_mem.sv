module instr_mem (
    input  logic [31:0] addr_i,   // Address (Program Counter)
    output logic [31:0] instr_o   // Fetched instruction
);

    localparam        MEM_SIZE  = 4 * 1024;      // Memory size in bytes (0xBFC00000 to 0xBFC00FFF -> 4KB)
    localparam [31:0] BASE_ADDR = 32'hBFC00000;  // Base address of instruction memory
    localparam [31:0] TOP_ADDR  = 32'hBFC00FFF;  // Top address of instruction memory

    // 4 x 1024 bytes memory
    logic [7:0] mem [MEM_SIZE-1:0];

    // Internal signal for address error detection
    logic addr_error;

    // Initialize memory
    initial begin
        $display("LOADING INSTRUCTION MEMORY...");
        
        // The default path when running the simulation is the tests directory
        // Read memory file with byte-level storage
        $readmemh("/root/Documents/Group-9-RISC-V/tb/test_out/4_jal_ret/program.hex", mem); 
    end
    logic [31:0] actual_addr;

    // Address error detection logic
    always_comb begin
        addr_error = 1'b0; // Default: no error
        actual_addr = addr_i + BASE_ADDR;

        // Address alignment and range checking
        if (actual_addr < BASE_ADDR || actual_addr > TOP_ADDR) begin
            addr_error = 1'b1;
            $display("Warning: Address out of range: %h.", addr_i);
        end 
        else if (actual_addr[1:0] != 2'b00) begin
            addr_error = 1'b1;
            $display("Warning: Unaligned address detected: %h.", addr_i);
        end
    end

    // Read logic: fetch instruction
    always_comb begin
        if (addr_error) begin
            // Return error value if address is invalid
            instr_o = 32'hDEADBEEF; 
        end 
        else begin
            // Calculate local memory address offset by subtracting BASE_ADDR
            logic [11:0] local_addr = actual_addr[11:0];  // addr_i - BASE_ADDR assumes addr_i is within valid range
            instr_o = {mem[local_addr + 3], mem[local_addr + 2], mem[local_addr + 1], mem[local_addr]};
        end
    end 
endmodule
