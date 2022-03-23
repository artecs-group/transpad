import siliconcompiler                            # import python package

def main():
    chip = siliconcompiler.Chip()                 # create chip object
    chip.set('source', ['register.v',
                        'counter.v',
                        'mux4g.v',
                        'decoder4.v',
                        'decoder8.v',
                        'transpad_dp.v',
                        'transpad_cu.v',
                        'transpad.v'])
    chip.set('design', 'transpad')                # set top module
    chip.set('constraint', 'transpad.sdc')        # set constraints file
    chip.set('pdk', 'wafersize', 300)
    chip.load_target('freepdk45_demo')            # load predefined target
    chip.write_flowgraph("transpad.png")
    chip.write_manifest("transpad.tcl")
    chip.run()                                    # run compilation
    chip.summary()                                # print results summary
    chip.show()                                   # show layout file

if __name__ == '__main__':
    main()

