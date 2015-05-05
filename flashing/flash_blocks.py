#!/usr/bin/python -u

"""
Ugly hack to sequentially run urjtag once per flash erase-block to cope with
really unreliable boards that fail randomly.

... it was easier than fix urjtag segfaults and strange errors!
"""


import os
import sys
import tempfile
import argparse
import subprocess
import time

flash_block_size = 0x10000
flash_offset = 0x1e000000

template = """
cable ft2232 vid=0x0403 pid=0x8A98 driver=ftdi-mpsse
frequency 1000000
detect
detectflash %s
usleep 1000000
flashmem %s %s noverify
"""

parser = argparse.ArgumentParser()

parser.add_argument("image",
    help="The raw image you want to flash")
parser.add_argument("--write_offset", type=str, default="",
    help="Where to start writting relative to the start of the flash")
parser.add_argument("--skip", type=int, default=0,
    help="How many blocks to skip from the start")


def parse_int_or_hex_arg(arg, default=None):
    if not arg:
        return default
    arg = arg.lower()
    if arg.startswith('0x'):
        return int(arg, 16)
    return int(arg)

def pad_hex(n, w=8):
    return '0x' + hex(n)[2:].zfill(w)

def get_block_data(image, offset, size):
    with open(image) as f:
        f.seek(offset)
        return f.read(size)

def get_tmp_file_with(data):
    f = tempfile.NamedTemporaryFile('w+b', delete=False)
    f.write(data)
    f.close()
    return f.name


args = parser.parse_args()

flash_write_offset = parse_int_or_hex_arg(args.write_offset, 0)
image_size = os.path.getsize(args.image)
block_count = image_size // flash_block_size

block = args.skip
failcount = 0
while block < block_count:
    read_offset = block * flash_block_size
    write_offset = flash_offset + flash_write_offset + read_offset
    block_data = get_block_data(args.image, read_offset, flash_block_size)
    data_file = get_tmp_file_with(block_data)
    command_file = get_tmp_file_with(
        template % (pad_hex(flash_offset), pad_hex(write_offset), data_file))

    print "Flashing block %d..." % block

    jtag = "./runjtag.sh %s" % command_file
    result = os.system(jtag)
    #result = 0
    os.unlink(data_file)
    os.unlink(command_file)

    if result == 0:
        block += 1
        failcount = 0
        print "OK"
    else:
        failcount += 1
        print "FAILED (%s), will retry." % result

    time.sleep(0.5)
    if result != 2:
        time.sleep(failcount/2)
    if failcount > 10:
        raise Exception("Adios")

print "DONE."
