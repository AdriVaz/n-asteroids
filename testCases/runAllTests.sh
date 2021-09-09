#!/bin/bash

function insertTuple
{
    #$1 = numAsteroids
    #$2 = numIterations
    #$3 = numPlanets
    #$4 = numThreads
    #$5 = schedule
    #$6 = execTime
    echo "$1;$2;$3;$4;$5;$6" >> testResults.csv
    echo -e "\e[1;36mAverage execution time: $6\e[0m\n"
}

#Borra ficheros anteriores
rm -r tests/ 2> /dev/null
rm testResults.csv 2> /dev/null

mkdir tests

#Generar los ficheros de pruebas
echo -e "\e[1;33m############### GENERANDO FICHEROS DE PRUEBA ###############\e[0m"
echo -e "############### GENERANDO FICHEROS DE PRUEBA ###############" >> log.txt

MODES=('static' 'dynamic' 'guided')
for I in {1,2,4,8,16};do
    if [ $I -eq 4 ] || [ $I -eq 8 ]; then
        for J in "${MODES[@]}";do
            sed "s/@1/$I/g; s/@2/schedule($J)/g" testTemplate.cpp > tests/nasteroids-par_"$I"_"$J".cpp
            echo "nasteroids-par_"$I"_"$J".cpp"
            echo "nasteroids-par_"$I"_"$J".cpp" >> log.txt
        done
    else
        sed "s/@1/$I/g; s/@2//g" testTemplate.cpp > tests/nasteroids-par_"$I".cpp
        echo "nasteroids-par_"$I".cpp"
        echo "nasteroids-par_"$I".cpp" >> log.txt
    fi
done
cp ../Seq/nasteroids-seq.cpp tests
echo -e ""
echo -e "" >> log.txt

#Compilar los ficheros de pruebas
echo -e "\e[1;33m############### COMPILANDO PROGRAMAS DE PRUEBA ###############\e[0m"
echo -e "############### COMPILANDO PROGRAMAS DE PRUEBA ###############" >> log.txt
for I in tests/nasteroids*.cpp;do
    echo $I
    echo $I >> log.txt
    g++ $I -o $(echo $I | cut -d '.' -f1) -lstdc++ -std=c++14 -Wall -Wno-deprecated -Werror -pedantic -pedantic-errors -O3 -DNDEBUG -lm -fopenmp
done
echo -e ""
echo -e "" >> log.txt

#Ejecutar las pruebas
NUMREPETITIONS=10

SOURCE_PLAN=('static' 'dynamic' 'guided')
SOURCE_THREADS=('seq' '1' '2' '4' '8' '16')
SOURCE_ITERATIONS=(50 100 200)
SOURCE_NASTEROIDS=(50 125 200 125 250 400 250 500 750)
SOURCE_NPLANETS=(200 125 50 400 250 125 750 500 250)

#TIEMPODEUNO=0
SUMATIEMPO=0

for THREADS in "${SOURCE_THREADS[@]}";do
    #TIEMPODEUNO=0
    #SUMATIEMPO=0
    if [ $THREADS == "seq" ];then
        for ITERATIONS in "${SOURCE_ITERATIONS[@]}";do
            echo -e "\e[1;33m############### THREADS:$THREADS  ITERATIONS:$ITERATIONS ###############\e[0m"
            echo -e "############### THREADS:$THREADS  ITERATIONS:$ITERATIONS ###############" >> log.txt
            for NASTEROIDS in {0..8};do
                SUMATIEMPO=0
                for I in $(seq 1 $NUMREPETITIONS);do
                    echo -n "Execution $I: tests/nasteroids-seq ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} 3000  Time: "
                    echo -n "Execution $I: tests/nasteroids-seq ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} 3000  Time: " >> log.txt
                    TIEMPODEUNO=$(tests/nasteroids-seq ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} 3000 | cut -d ":" -f2)
                    echo $TIEMPODEUNO
                    echo $TIEMPODEUNO >> log.txt
                    SUMATIEMPO=$(( $SUMATIEMPO +  $TIEMPODEUNO ))
                done
                insertTuple ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} "seq" "no" $(( $SUMATIEMPO / $NUMREPETITIONS ))
            done
        done
    elif [ $THREADS -eq 4 ] || [ $THREADS -eq 8 ]; then
        for PLAN in "${SOURCE_PLAN[@]}";do
            for ITERATIONS in "${SOURCE_ITERATIONS[@]}";do
                echo -e "\e[1;33m############### THREADS:$THREADS  ITERATIONS:$ITERATIONS ###############\e[0m"
                echo -e "############### THREADS:$THREADS  ITERATIONS:$ITERATIONS ###############" >> log.txt
                for NASTEROIDS in {0..8};do
                    SUMATIEMPO=0
                    for I in $(seq 1 $NUMREPETITIONS);do
                        echo -n "Execution $I: tests/nasteroids-par_"$THREADS"_"$PLAN" ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} 3000  Time: "
                        echo -n "Execution $I: tests/nasteroids-par_"$THREADS"_"$PLAN" ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} 3000  Time: " >> log.txt
                        TIEMPODEUNO=$(tests/nasteroids-par_"$THREADS"_"$PLAN" ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} 3000 | cut -d ":" -f2)
                        echo $TIEMPODEUNO
                        echo $TIEMPODEUNO >> log.txt
                        SUMATIEMPO=$(( $SUMATIEMPO + $TIEMPODEUNO ))
                    done

                    insertTuple ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} $THREADS $PLAN $(( $SUMATIEMPO / $NUMREPETITIONS ))
                done
            done
        done
    else #1, 2, 16 hilos
        for ITERATIONS in "${SOURCE_ITERATIONS[@]}";do
            echo -e "\e[1;33m############### THREADS:$THREADS  ITERATIONS:$ITERATIONS ###############\e[0m"
            echo -e "############### THREADS:$THREADS  ITERATIONS:$ITERATIONS ###############" >> log.txt
            for NASTEROIDS in {0..8};do
                SUMATIEMPO=0
                for I in $(seq 1 $NUMREPETITIONS);do
                    echo -n "Execution $I: tests/nasteroids-par_"$THREADS" ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} 3000  Time: "
                    echo -n "Execution $I: tests/nasteroids-par_"$THREADS" ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} 3000  Time: " >> log.txt
                    TIEMPODEUNO=$(tests/nasteroids-par_"$THREADS" ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} 3000 | cut -d ":" -f2)
                    echo $TIEMPODEUNO
                    echo $TIEMPODEUNO >> log.txt
                    SUMATIEMPO=$(( $SUMATIEMPO + $TIEMPODEUNO ))
                done
                insertTuple ${SOURCE_NASTEROIDS[$NASTEROIDS]} $ITERATIONS ${SOURCE_NPLANETS[$NASTEROIDS]} $THREADS "no" $(( $SUMATIEMPO / $NUMREPETITIONS ))
            done
        done
    fi
done
