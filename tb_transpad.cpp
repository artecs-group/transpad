#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtranspad.h"

#define MAX_SIM_TIME 200
#define START_CYCLE  10

vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

void dut_reset (Vtranspad *dut, vluint64_t &posedge_cnt){
    dut->rstn = 1;
    if (posedge_cnt >= 1 && posedge_cnt < 4) {
       dut->rstn = 0;
       dut->data = 0;
       dut->cmd  = 0;
       dut->rdy  = 0;
    }
}

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vtranspad *dut = new Vtranspad;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    while (sim_time < MAX_SIM_TIME) {
	dut_reset(dut, posedge_cnt);

	dut->clk ^= 1;
        dut->eval();

	if (dut->clk == 1) {
            posedge_cnt++;        // Increment posedge counter if clk is 1
            
	    if (posedge_cnt >= START_CYCLE) {
	        switch (posedge_cnt - START_CYCLE) {
                  case 0:
	            // Configure start address
	            dut->cmd  = 0b000;
	            dut->data = 0x0000000000ff;
	            dut->rdy  = 0b1;
	          break;
                  case 1:
	            // Configure stride
	            dut->cmd  = 0b001;
	            dut->data = 0x000400000000;  // stride 4
	            dut->rdy  = 0b1;
                  break;
	          case 2:
	            // Configure interval length
	            dut->cmd  = 0b100;
	            dut->data = 0x0000000c000f;  // sequential, 15 samples
	            dut->rdy  = 0b1;
	          break;
	          case 3:
	            dut->cmd  = 0b111;
	            dut->data = 0x0000000000a5;  // start signal
	            dut->rdy  = 0b1;
	          break;
	          case 8:
	            dut->data = 0x0000000000fa;  // first attempt, not mapped
		    dut->rdy  = 0b1;
		  break;
		  case 12:
		    dut->data = 0x0000000000ff;  // second attempt, mapped
		    dut->rdy  = 0b1;
	          break;
		  default:
	            dut->data = 0x000000000000;
		    dut->cmd  = 0b000;
	            dut->rdy  = 0b0;
	          break;
	        }
	    }
	}

        m_trace->dump(sim_time);  // Dump to waveform.vcd
        sim_time++;               // Advance simulation time
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}

