#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Intra Handover Flowgraph
# GNU Radio version: 3.8.1.0

from distutils.version import StrictVersion

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print("Warning: failed to XInitThreads()")

from gnuradio import blocks
from gnuradio import gr
from gnuradio.filter import firdes
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import zeromq
import threading
import time

class intra_enb(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Intra Handover Flowgraph")


        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 1.92e6
        self.cell_gain1 = cell_gain1 = 0
        self.cell_gain0 = cell_gain0 = 1

        def _variable_function_probe_0_probe():
            while True:
                print("test1")
                time.sleep(95.0)
                try:
                    print("test2")
                    if self.cell_gain1 == 0:
                        self.set_cell_gain1(0.2)
                        self.set_cell_gain0(0.8)
                        time.sleep(4.0)
                        self.set_cell_gain1(0.4)
                        self.set_cell_gain0(0.6)
                        time.sleep(4.0)
                        self.set_cell_gain1(0.6)
                        self.set_cell_gain0(0.5)
                        time.sleep(8.0)
                        self.set_cell_gain1(0.8)
                        self.set_cell_gain0(0.5)
                        time.sleep(9.0)
                        self.set_cell_gain1(1)
                        self.set_cell_gain0(0.5)
                        time.sleep(19.0)
                        self.set_cell_gain1(1)
                        self.set_cell_gain0(0)
                    else:
                        self.set_cell_gain1(0.8)
                        self.set_cell_gain0(0.2)
                        time.sleep(4.0)
                        self.set_cell_gain1(0.6)
                        self.set_cell_gain0(0.4)
                        time.sleep(4.0)
                        self.set_cell_gain1(0.5)
                        self.set_cell_gain0(0.6)
                        time.sleep(8.0)
                        self.set_cell_gain1(0.5)
                        self.set_cell_gain0(0.8)
                        time.sleep(9.0)
                        self.set_cell_gain1(0.5)
                        self.set_cell_gain0(1)
                        time.sleep(19.0)
                        self.set_cell_gain1(0)
                        self.set_cell_gain0(1)
                except AttributeError:
                    pass
        _variable_function_probe_0_thread = threading.Thread(target=_variable_function_probe_0_probe)
        _variable_function_probe_0_thread.daemon = True
        _variable_function_probe_0_thread.start()

        ##################################################
        # Blocks
        ##################################################
        self.zeromq_req_source_1 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:2001', 100, False, -1)
        self.zeromq_req_source_0_0 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:2201', 100, False, -1)
        self.zeromq_req_source_0 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:2101', 100, False, -1)
        self.zeromq_rep_sink_1_0 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:2200', 100, False, -1)
        self.zeromq_rep_sink_1 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:2100', 100, False, -1)
        self.zeromq_rep_sink_0 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:2000', 100, False, -1)
        self.blocks_throttle_0 = blocks.throttle(gr.sizeof_gr_complex*1, samp_rate,True)
        self.blocks_multiply_const_vxx_0_0 = blocks.multiply_const_cc(cell_gain1)
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_cc(cell_gain0)
        self.blocks_add_xx_0 = blocks.add_vcc(1)



        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_add_xx_0, 0), (self.zeromq_rep_sink_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_add_xx_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0_0, 0), (self.blocks_add_xx_0, 1))
        self.connect((self.blocks_throttle_0, 0), (self.zeromq_rep_sink_1, 0))
        self.connect((self.blocks_throttle_0, 0), (self.zeromq_rep_sink_1_0, 0))
        self.connect((self.zeromq_req_source_0, 0), (self.blocks_multiply_const_vxx_0, 0))
        self.connect((self.zeromq_req_source_0_0, 0), (self.blocks_multiply_const_vxx_0_0, 0))
        self.connect((self.zeromq_req_source_1, 0), (self.blocks_throttle_0, 0))

    def set_cell_gain1(self, cell_gain1):
        self.cell_gain1 = cell_gain1
        self.blocks_multiply_const_vxx_0_0.set_k(self.cell_gain1)

    def set_cell_gain0(self, cell_gain0):
        self.cell_gain0 = cell_gain0
        self.blocks_multiply_const_vxx_0.set_k(self.cell_gain0)



def main(top_block_cls=intra_enb, options=None):


    tb = top_block_cls()
    tb.run()



if __name__ == '__main__':
    main()
