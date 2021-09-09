#!/bin/bash

I=0
SUM=0 # Param check
if [ $# -ne 1 ]; then
	echo "Usage: $0 [s|p]"
	exit
fi

# Program selection
if [ "$1" == "s" ]; then
	PROGRAM="Seq/nasteroids-seq"
elif [ "$1" == "p" ];then
	PROGRAM="Par/nasteroids-par"
fi

if [ ! -f $PROGRAM ]; then
	make
fi

# Run the program
while [ $I -lt 30 ];do
    ITERATION=$($PROGRAM 100 50 50 4000 | cut -d ":" -f2)
    echo "Elapsed microseconds:"$ITERATION
    sum=$(expr $sum + $ITERATION)
    echo -e "\e[1;33m############### ITERATION $I RUN ###############\e[1;0m\n"
    I=$(expr $I + 1)
done

echo $(expr $sum / 30)
echo -e "\e[1;36m############### AVERAGE RUN TIME ###############\e[1;0m\n"
