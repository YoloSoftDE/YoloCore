#!/bin/bash

chr() {
  printf \\$(printf '%03o' $1)
}

echo -ne "\xFF\x00\x81\x01\x47\x21\xE0\x01" #0x00 - 0x07
for i in {8..127}; do
	chr $i
done

#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x08 - 0x0f
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x10 - 0x17
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x18 - 0x1f
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x20 - 0x27
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x28 - 0x2f
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x30 - 0x37
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x38 - 0x3f
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x40 - 0x47
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x48 - 0x4f
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x50 - 0x57
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x58 - 0x5f
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x60 - 0x67
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x68 - 0x6f
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x70 - 0x77
#echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" #0x78 - 0x7f



