# split.sh

This is simple bash script that takes an image and a set of offset+sizes and splits the contents using GNU dd.

## Usage

$ `./split.sh PARTITION_LIST_FILE IMAGE_FILE`

The `PARTITION_LIST_FILE` must contain one partition per line.
Offsets must be provided in hexadecimal.
`START_OFFSET` `END_OFFSET` `PARTITION_NAME`

ie:
```
0x00000000 0x00020000 bootloader
0x00030000 0x000f0000 kernel
```

Sizes (end offset - start offset) should be greater than zero, but there are no additional checks for overlapping, etc.

WARNING: output files will be named `IMAGE_FILE-PARTITION_NAME`
and will be **OVERWRITTEN.**
