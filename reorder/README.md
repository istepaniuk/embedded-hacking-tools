# reorder

Simple script to reorder bytes in an image file.

Useful to process some lame obfuscations.


If you just need to fix an image that was mangled by endianness conversions use:
```
$ objcopy -I binary -O binary --reverse-bytes=4 inputfile outputfile
```
(Or 8 for 16bits.)


