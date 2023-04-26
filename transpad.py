#!/usr/bin/env python3
import siliconcompiler                            # import python package

def main():
    chip = siliconcompiler.Chip('transpad')       # create chip object
    chip.input('register.v')	                  # set input files
    chip.input('counter.v')
    chip.input('mux4g.v')
    chip.input('decoder4.v')
    chip.input('decoder8.v')
    chip.input('transpad_dp.v')
    chip.input('transpad_cu.v')
    chip.input('transpad.v')
    chip.clock('clk', period=1.0)                 # set clock period
    chip.load_target('freepdk45_demo')            # load predefined target
    chip.write_flowgraph("transpad.png")
    chip.write_manifest("transpad.tcl")
    chip.set('option', 'nodisplay', True)
    chip.set('option', 'novercheck', True)
    chip.run()                                    # run compilation
    chip.summary()                                # print results summary

if __name__ == '__main__':
    main()

