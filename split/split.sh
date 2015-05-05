PARTITIONS=$1
IMAGE=$2

cat $PARTITIONS | while read line; do
    start=$((`echo $line|cut -d' ' -f1`))
    end=$((`echo $line|cut -d' ' -f2`))
    name=$(basename $IMAGE)-$(echo $line|cut -d ' ' -f3)
    count=$(($end - $start))
    echo dd if=$IMAGE of=$name skip=$start count=$count bs=1024 iflag=skip_bytes,count_bytes
done
