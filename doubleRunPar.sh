#!/bin/bash

if [ ! -f Par/nasteroids-par ]; then
	echo -e "\e[1;31mdoubleRunPar error: \e[1;0mNo se ha compilado el programa paralelo."
	exit
fi

if [ ! -f Seq/nasteroids-seq ]; then
	echo -e "\e[1;31mdoubleRunPar error: \e[1;0mNo se ha compilado el programa secuencial."
	exit
fi

if [ $# -ne 4 ]; then
	echo -e "\e[1;31mdoubleRunPar error: \e[1;0mParametros erroneos."
	exit
fi

ARGS=""

while [ $# -gt 0 ]; do
	ARGS=$ARGS$1" "
	shift
done

#Ejecutar el secuencial
cd Seq

rm *.txt
./nasteroids-seq $ARGS
echo -e "\e[1;33m############### SECUENCIAL EJECUTADO ###############\e[1;0m\n"

cd ..

rm *.txt
mv Seq/out.txt prog_seq_out.txt

#Ejecutar el programa
cd Par
./nasteroids-par $ARGS
echo -e "\e[1;33m############### PARALELO EJECUTADO ###############\e[1;0m\n"
cd ..

mv Par/out.txt .
