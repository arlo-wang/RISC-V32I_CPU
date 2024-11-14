module Instruction_Memory (
    input logic [31:0] addr,          // Address (Program Counter)
    output logic [31:0] instruction   // Fetched instruction
);

    // Memory array 
    logic [31:0] mem [0:255];

    // Initialize mem
    initial begin
        $readmemh("instructions.hex", mem); 
    end

    // Fetch instruction
    assign instruction = mem[addr >> 2]; 
endmodule
