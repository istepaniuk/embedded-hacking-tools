import sys

chunk_len = 4
keep_reading = True

while keep_reading:
    data = sys.stdin.read(chunk_len)
    if len(data) < chunk_len:
        if len(data) > 0:
            raise IOError("Short read. Size is not multiple of %s" % chunk_len)
        keep_reading = False
    else:
        reordered_chunk = bytearray([
            data[3],
            data[2],
            data[1],
            data[0],
        ])
        sys.stdout.write(reordered_chunk)
