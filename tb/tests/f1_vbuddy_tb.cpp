#include "Vtop.h"

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../vbuddy.cpp"

#define MAX_SIM_CYC 100000

int main(int argc, char **argv, char **env)
{
    int simcyc;     // simulation clock count
    int tick;       // each clk cycle has two ticks for two edges
    int lights = 0; // state to toggle LED lights

    Verilated::commandArgs(argc, argv);
    // init top verilog instance
    Vtop *top = new Vtop;
    // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("top.vcd");

    // init Vbuddy
    if (vbdOpen() != 1)
        return (-1);
    vbdHeader("F1 vbuddy tests");
    vbdSetMode(1); // Flag mode set to one-shot

    // initialize simulation inputs
    top->clk = 0;
    top->rst = 0;
    top->trigger = 0;
    top->a0 

    // run simulation for MAX_SIM_CYC clock cycles
    for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++)
    {
        // dump variables into VCD file and toggle clock
        for (tick = 0; tick < 2; tick++)
        {
            tfp->dump(2 * simcyc + tick);
            top->clk = !top->clk;
            top->eval();
        }

        // Display toggle neopixel
        if (top->trigger)
        {
            vbdBar(lights);
            lights = lights ^ 0xFF;
        }

        // set up input singals of testbench
        top->rst = (simcyc < 2) ? 1 : 0; // reset active for first 2 cycles
        top->trigger = (simcyc >2) ? 1 : 0; // trigger active after 2 cycles
        
        vbdCycle(simcyc);

        if (Verilated::gotFinish() || vbdGetkey() == 'q')
            exit(0);
    }

    vbdClose();
    tfp->close();
    exit(0);
}
