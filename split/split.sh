#!/bin/bash

PARTS=$1
IMAGE=$2

if [ ! -f "$IMAGE" ] || [ ! -f $PARTS ] ; then

    cat << EOF
Usage: $0 PARTITION_LIST_FILE IMAGE_FILE

The PARTITION_LIST_FILE must contain, one partition per line,
offsets must be provided in hexadecimal:
START_OFFSET END_OFFSET PARTITION_NAME

ie:
0x00000000 0x00020000 bootloader
0x00030000 0x000f0000 kernel

WARNING: output files will be named IMAGE_FILE-PARTITION_NAME
and will be OVERWRITTEN.
EOF
    exit
fi

IMAGE_BASENAME=$(basename $IMAGE)

while read line; do
    offset=$(echo $line|cut -d' ' -f1)
    end=$(echo $line|cut -d' ' -f2)
    name=$(echo $line|cut -d' ' -f3)
    size=$(($end - $offset))
    if [[ size -le 0 ]]; then
        echo "ERROR: Negative or null size for partition: $line"
        exit 1
    fi
    echo "Extracting partition '$name' [$offset:$end] ($size bytes)"
    dd iflag=skip_bytes,count_bytes if="$IMAGE" bs=1M \
        of="$IMAGE_BASENAME-$name" skip=$(($offset)) count=$size
done < $PARTS
