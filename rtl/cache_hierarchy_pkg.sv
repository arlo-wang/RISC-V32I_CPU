package cache_hierarchy_pkg;
    import cache_common_pkg::*;

    // L1 Cache
    parameter int L1_NUM_SETS = 256;  // 4KB
    parameter int L1_NUM_WAYS = 4;
    parameter int L1_SETS_INDEX_BITS = $clog2(L1_NUM_SETS);
    parameter int L1_TAG_BITS = ADDR_WIDTH - L1_SETS_INDEX_BITS - BYTE_OFFSET_BITS;

    // L2 Cache
    parameter int L2_NUM_SETS = 256;  // 4KB
    parameter int L2_NUM_WAYS = 4;
    parameter int L2_SETS_INDEX_BITS = $clog2(L2_NUM_SETS);
    parameter int L2_TAG_BITS = ADDR_WIDTH - L2_SETS_INDEX_BITS - BYTE_OFFSET_BITS;

    // L3 Cache
    parameter int L3_NUM_SETS = 256;  // 8KB
    parameter int L3_NUM_WAYS = 8;
    parameter int L3_SETS_INDEX_BITS = $clog2(L3_NUM_SETS);
    parameter int L3_TAG_BITS = ADDR_WIDTH - L3_SETS_INDEX_BITS - BYTE_OFFSET_BITS;

    // L1 Cache
    typedef struct packed {
        logic [L1_TAG_BITS-1:0]         tag;
        logic [L1_SETS_INDEX_BITS-1:0]  set_index;
        logic [BYTE_OFFSET_BITS-1:0]    byte_offset;
    } l1_addr_t;

    typedef struct packed {
        logic                    valid;
        cache_state_t           state;
        logic [L1_TAG_BITS-1:0] tag;
        logic [DATA_WIDTH-1:0]  data;
        logic [2:0]             lru;
    } l1_cache_line_t;

    // L2 Cache
    typedef struct packed {
        logic [L2_TAG_BITS-1:0]         tag;
        logic [L2_SETS_INDEX_BITS-1:0]  set_index;
        logic [BYTE_OFFSET_BITS-1:0]    byte_offset;
    } l2_addr_t;

    typedef struct packed {
        logic                    valid;
        cache_state_t           state;
        logic [L2_TAG_BITS-1:0] tag;
        logic [DATA_WIDTH-1:0]  data;
        logic [2:0]             lru;
    } l2_cache_line_t;

    // L3 Cache
    typedef struct packed {
        logic [L3_TAG_BITS-1:0]         tag;
        logic [L3_SETS_INDEX_BITS-1:0]  set_index;
        logic [BYTE_OFFSET_BITS-1:0]    byte_offset;
    } l3_addr_t;

    typedef struct packed {
        logic                    valid;
        cache_state_t           state;
        logic [L3_TAG_BITS-1:0] tag;
        logic [DATA_WIDTH-1:0]  data;
        logic [2:0]             lru;
    } l3_cache_line_t;

    // Cache request and response
    typedef struct packed {
        cache_operation_t        operation;
        logic [ADDR_WIDTH-1:0]  addr;
        logic [DATA_WIDTH-1:0]  data;
        logic [3:0]             byte_enable;
    } cache_request_t;

    typedef struct packed {
        logic                   hit;
        logic                   valid;
        logic [DATA_WIDTH-1:0]  data;
        cache_state_t           state;
    } cache_response_t;
endpackage