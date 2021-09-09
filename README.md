# N-Asteroids

This program simulates the movement of some asteroids in a rectangular space. In this space there are also planets, that does not move.

There are two versions of the program: one sequential and one parallel. The sequential part makes all the iterations one after another, and the sequential part folds some parts using OpenMP

## Usage
```
./Seq/nasteroids-seq <asteroidNumber> <iterationNumber> <planetNumber> <seed>
./Par/nasteroids-par <asteroidNumber> <iterationNumber> <planetNumber> <seed>
```

Where:
- `asteroidNumber` is the number of asteroids in the space
- `iterationNumber` is the number of simulation steps that will be calculated
- `planetNumber` is the number of planets in the space
- `seed` is a number used as the seed for all the random number generation inside the program. This grants that the output of the program ONLY depends on the input

## Output
The program prints on screen how much time in microseconds the program was running, and produces two output files:
- `init_conf.txt` contains the arguments passed to the progran, and one line for each asteroid, that contain the X position, the Y position and the mass of the asteroid, calculated randomly
- `out.txt` contains the final position of the asteroids, after running the simulation. Each line contains the X position, the Y position, the X velocity, the Y velocity and the mass of each asteroid

## Compilation

All the compilation is done using the `make` command.
To compile only the sequential part, run `make seq`
To compile also the parallel part, run `make par`

To delete all the binary files and the output files, run `make clean`

## Helper scripts
There are also some helper scripts.

- `average.sh` runs the program 30 times and calculates the average run time
- `doubleRunSeq` and `doubleRunPar` run the sequential or parallel programs respectively, as well as the sample program, under `reference/`
- `speedup.sh` calculates how much faster the paralell version of the code runs relative to the sequential version.
