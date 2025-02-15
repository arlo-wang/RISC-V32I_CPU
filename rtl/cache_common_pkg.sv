package cache_common_pkg;

    parameter int ADDR_WIDTH = 32;
    parameter int DATA_WIDTH = 32;
    parameter int BYTE_OFFSET_BITS = 2;

    // // cache operation
    // typedef enum logic [2:0] {
    //     CACHE_READ,
    //     CACHE_WRITE,
    //     CACHE_FLUSH,
    //     CACHE_INVALIDATE
    // } cache_operation_t;

    // // Cache state
    // typedef enum logic [1:0] {
    //     INVALID  = 2'b00,
    //     SHARED   = 2'b01,
    //     MODIFIED = 2'b11
    // } cache_state_t;

    // Cache line interface
    interface cache_line_if #(
        parameter TAG_BITS = 32,
        parameter LRU_BITS = 3
    );
        logic                    valid;
        cache_state_t           state;
        logic [TAG_BITS-1:0]    tag;
        logic [DATA_WIDTH-1:0]  data;
        logic [LRU_BITS-1:0]    lru;
    endinterface

    // get_lru_way function
    function automatic int get_lru_way(
        input logic [2:0] lru_bits[],
        input int NUM_WAYS
    );
        logic [2:0] max_lru = lru_bits[0];
        int evict_way = 0;
        
        for (int i = 1; i < NUM_WAYS; i++) begin
            if (lru_bits[i] > max_lru) begin
                max_lru = lru_bits[i];
                evict_way = i;
            end
        end
        return evict_way;
    endfunction

    // Update LRU bits
    task automatic update_lru_bits(
        ref logic [2:0] lru_bits[],
        input int accessed_way,
        input int NUM_WAYS
    );
        for (int i = 0; i < NUM_WAYS; i++) begin
            if (i == accessed_way)
                lru_bits[i] = '0;
            else if (lru_bits[i] < (NUM_WAYS-1))
                lru_bits[i] = lru_bits[i] + 1;
        end
    endtask
endpackage