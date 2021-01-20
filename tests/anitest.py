#!/usr/bin/env python3
#
# Copyright (c) 2020 Erik Bosman <erik@minemu.org>
#
# Permission  is  hereby  granted,  free  of  charge,  to  any  person
# obtaining  a copy  of  this  software  and  associated documentation
# files (the "Software"),  to deal in the Software without restriction,
# including  without  limitation  the  rights  to  use,  copy,  modify,
# merge, publish, distribute, sublicense, and/or sell copies of the
# Software,  and to permit persons to whom the Software is furnished to
# do so, subject to the following conditions:
#
# The  above  copyright  notice  and this  permission  notice  shall be
# included  in  all  copies  or  substantial portions  of the Software.
#
# THE SOFTWARE  IS  PROVIDED  "AS IS", WITHOUT WARRANTY  OF ANY KIND,
# EXPRESS OR IMPLIED,  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY,  FITNESS  FOR  A  PARTICULAR  PURPOSE  AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT,  TORT OR OTHERWISE,  ARISING FROM, OUT OF OR IN
# CONNECTION  WITH THE SOFTWARE  OR THE USE  OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# (http://opensource.org/licenses/mit-license.html)
#

import sys

import intelhex, pdk

PIN = 0

def frame_timing(frame, idle_cycles, frame_cycles):
    print()
    print('cycles/frame+pause: {:d}, idle time: {:d}'.format(frame_cycles, idle_cycles))

def byte_hex(byte):
    print ('{:02x} '.format(byte), end='')

def frame_stdout(frame, idle_cycles, frame_cycles):
    sys.stdout.buffer.write(bytes(frame))
    sys.stdout.flush()


def wave_func(pin, byte_func=None, frame_func=None):

    last_up=-1
    last_frame=-1
    byte=0
    bits=0
    frame = []
    ts=0
    old = 0

    def func(new):
        nonlocal last_up, last_frame, bits, byte, frame, ts, old
        new = new>>pin &1
        if old ^ new:
            d = ts-last_up
            if new:
                if d == 10:
                    pass
                elif last_frame >= 0 and d < 2400:
                    raise ValueError("wrong timing: timeout too short? "+str(d))
                elif bits != 0:
                    raise ValueError("incomplete byte")
                else:
                    if last_frame >= 0:
                        if frame_func:
                            frame_func(frame, ts-last_up-10, ts-last_frame)
                        frame = []
                    last_frame = ts

                last_up=ts
                first = False
            elif old:
                if d not in (3,7):
                    raise ValueError("wrong timing: "+str(d))
                byte = byte<<1 | int( d == 7 )
                bits += 1
                if bits == 8:
                    if byte_func:
                        byte_func(byte)
                    frame.append(byte)
                    byte = 0
                    bits = 0
        old = new
        ts += 1
    return func


if __name__ == '__main__':

    if sys.argv[1:2] == ['-out']:
        func = wave_func(PIN, None, frame_stdout)
    elif sys.argv[1:2] == ['-timing']:
        func = wave_func(PIN, byte_hex, frame_timing)
    else:
        print ("Usage: {} -out|-timing hexfile".format(sys.argv[0]), file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[2]) as f:
        program = pdk.parse_program(f.read(), arch='pdk14')

    ctx = pdk.new_ctx()

    last = -1
    lastcount = 0

    while True:
        pa   = pdk.read_io_raw(ctx, 0x10)
        func(pa)
        pdk.step(program, ctx)

