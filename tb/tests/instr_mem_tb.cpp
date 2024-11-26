#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class InstrMemTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->addr_i = 0;
    }
};

// first normal test case
TEST_F(InstrMemTestbench, InstrMemWorksTest1)
{
    top->addr_i = 0;
    top->eval();

    EXPECT_EQ(top->instr_o, 0x1303f00f);
}

// second normal test case
TEST_F(InstrMemTestbench, InstrMemWorksTest2)
{
    top->addr_i = 4;
    top->eval();

    EXPECT_EQ(top->instr_o, 0x13050000);
}

// third normal test case
TEST_F(InstrMemTestbench, InstrMemWorksTest3)
{
    top->addr_i = 8;
    top->eval();

    EXPECT_EQ(top->instr_o, 0x93050000);
}

// unaligned memory access test case
TEST_F(InstrMemTestbench, UnalignedMemAccessTest)
{
    top->addr_i = 2; // Unaligned address
    top->eval();
    
    // Expect a default instruction (0xDEADBEEF)
    EXPECT_EQ(top->instr_o, 0xDEADBEEF);
}

// out-of-range memory access test case
TEST_F(InstrMemTestbench, OutOfRangeMemAccessTest)
{
    // Set address to a value that exceeds MEM_SIZE
    top->addr_i = 256 * 4; // MEM_SIZE = 256, so this is out of range
    top->eval();
    
    // Expect the instruction to be 0xDEADBEEF
    EXPECT_EQ(top->instr_o, 0xDEADBEEF) << "Out-of-range memory access did not return the expected instruction.";
}

int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
