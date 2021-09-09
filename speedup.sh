#!/bin/bash

################ ERRORS ################
function throwError
{
    case $1 in
        0 )
            echo -e "\e[1;31mspeedup error: \e[0mWrong params"
        ;;
        1 )
            echo -e "\e[1;31mspeedup error: \e[0mWrong Flags"
        ;;
		2 )
			echo -e "\e[1;31mdoubleRunPar error: \e[1;0mParallel program not compiled"
		;;
		3 )
			echo -e "\e[1;31mdoubleRunPar error: \e[1;0mSequential program not compiled"
		;;
        #4 )
            #....
        #;;
        #....
    esac

    echo ""
    echo "Usage: speedup [ FLAGS ] numAsteroids numIterations numPlanets seed"
    echo "FLAGS:  -i number     sets the number of executions (default=10)"
    echo "        -v            Shows values for each execution"
    exit
}

################ FLAGS ################
#Default value for flags
PRINTITERATIONS=0
NUMEXECUTIONS=10
#....

#Param container
PARAMS=""

while [ $# -gt 0 ]; do
    case $1 in
        -v )
            PRINTITERATIONS=1
        ;;
        -i )
            shift
            NUMEXECUTIONS=$1
        ;;
        *)
            PARAMS="$PARAMS $1"
        ;;
    esac

    shift
done

#Param re-set
eval set - "$PARAMS"

################ PARAMS ################
if [ $# -ne 4 ]; then
    throwError 0
fi

if [ ! -f Par/nasteroids-par ]; then
	throwError 2
fi

if [ ! -f Seq/nasteroids-seq ]; then
	throwError 3
fi

#Aditional param check

################ SECUENTIAL ################
I=0
SUMAPARSEQ=0

while [ $I -lt $NUMEXECUTIONS ];do
    ITERATION=$(Seq/nasteroids-seq $1 $2 $3 $4 | cut -d ":" -f2)

    SUMAPARSEQ=$(($SUMAPARSEQ + $ITERATION))

    if [ $PRINTITERATIONS -eq 1 ]; then
        echo -e "\e[1;35m############### SECUENTIAL $I RUN ###############\e[0m"
        echo -e "Microsegundos empleados:"$ITERATION"\n"
    fi

    I=$(($I + 1))
done

MEDIASEQ=$(($SUMAPARSEQ / $NUMEXECUTIONS))
echo -e "\e[1;33m############### AVERAGE SEQUENTIAL TIME ###############\e[0m"
echo -e $MEDIASEQ"\n"


################ PARALEL ################
I=0
SUMAPAR=0

while [ $I -lt $NUMEXECUTIONS ];do
    ITERATION=$(Par/nasteroids-par $1 $2 $3 $4 | cut -d ":" -f2)

    SUMAPAR=$(($SUMAPAR + $ITERATION))

    if [ $PRINTITERATIONS -eq 1 ]; then
        echo -e "\e[1;35m############### PARALLEL $I RUN ###############\e[0m"
        echo -e "Microsegundos empleados:"$ITERATION"\n"
    fi

    I=$(($I + 1))
done

MEDIAPAR=$(($SUMAPAR / $NUMEXECUTIONS))
echo -e "\e[1;33m############### AVERAGE PARALLEL TIME ###############\e[0m"
echo -e $MEDIAPAR"\n"


################ SPEEDUP ################

SPEEDUP=$(echo "scale=2; $MEDIASEQ/$MEDIAPAR" | bc)

if [ "$(expr substr $SPEEDUP 1 1)" == "." ]; then
    #Red
	COLOR="\e[1;31m"
else
    #Green
	COLOR="\e[1;32m"
fi

echo -e $COLOR"############### SPEEDUP ###############\e[0m"
echo -e $SPEEDUP"\n"
