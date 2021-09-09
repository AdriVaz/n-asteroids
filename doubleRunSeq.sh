#!/bin/bash

if [ ! -f Seq/nasteroids-seq ]; then
	echo -e "\e[1;31mdoubleRunSeq error: \e[1;0mProgram not compiled."
	exit
fi

if [ $# -ne 4 ]; then
	echo -e "\e[1;31mdoubleRunSeq error: \e[1;0mWrong arguments."
	exit
fi

ARGS=""

while [ $# -gt 0 ]; do
	ARGS=$ARGS$1" "
	shift
done

#Ejecutar el ejemplo
rm reference/*.txt

cd reference
./nasteroids2018-base_v2 $ARGS
echo -e "\e[1;33m############### REFERENCE EXECUTED ###############\e[1;0m\n"
cd ..

rm *.txt
mv reference/out.txt reference_out.txt

#Ejecutar el programa
cd Seq
./nasteroids-seq $ARGS
echo -e "\e[1;33m############### SEQUENTIAL EXECUTED ###############\e[1;0m\n"
cd ..

mv Seq/out.txt .
