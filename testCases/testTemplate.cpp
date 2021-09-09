#include <iostream>
#include <string.h>		//strcmp
#include <vector>
#include <random>		//Random distributions
#include <cmath>
#include <fstream>		//file management
#include <iomanip>		//setprecision
#include <chrono>
#include <omp.h>

const double gravity = 6.674e-5;
const double deltaTime = 0.1;
const double dmin = 2.0;
const double width = 200.0;
const double height = 200.0;
const int mass = 1000;
const int sdm = 50;

typedef struct
{
	double x;
	double y;
	double mass;

	double Fx;
	double Fy;

	double Vx;
	double Vy;
} asteroid;

typedef struct
{
	double x;
	double y;
	double mass;
} planet;

std::vector <asteroid> asteroids;
std::vector <planet> planets;

int main(int argc, char const *argv[])
{
	using namespace std;
	//omp_set_num_threads(@1);
	using clk = chrono::high_resolution_clock;

	vector <int> argvNum(argc - 1);

	//Comprobacion de parametros validos
	bool validParams = true;
	char* resto;

	if(argc != 5)
		validParams = false;

	for(int i = 1; i < argc && validParams; i++)
	{
		argvNum[i - 1] = strtol(argv[i], &resto, 10);

		if(strcmp(resto, ""))
			validParams = false;
	}

	if (!validParams)
	{
		cerr << "nasteroids-seq: Wrong arguments." << endl << "Correct use:" << endl << "nasteroids-seq num_asteroides num_iteraciones num_planetas semilla" << endl << endl;
		return -1;
	}

	// Random distributions
	default_random_engine re{(long unsigned int)argvNum[3]};
	uniform_real_distribution <double> xdist{0.0, std::nextafter(width, std::numeric_limits<double>::max())};
	uniform_real_distribution <double> ydist{0.0, std::nextafter(height, std::numeric_limits<double>::max())};
	normal_distribution <double> mdist{mass, sdm};

	//Crear las variables y matrices para calculos
	asteroids.resize(argvNum[0]);
	planets.resize(argvNum[2]);

	//Inicializar los asteroides
	for(unsigned int i = 0; i < asteroids.size(); i++)
	{
		asteroids[i].x = xdist(re);
		asteroids[i].y = ydist(re);
		asteroids[i].mass = mdist(re);
	}

	//Inicializar los planetas
	for(unsigned int i = 0; i < planets.size(); i++)
	{
		planets[i].x = i % 4 == 0 ? 0.0 : (i % 4 == 2 ? width : xdist(re));
		planets[i].y = i % 4 == 1 ? 0.0 : (i % 4 == 3 ? height : xdist(re));
		planets[i].mass = 10.0 * mdist(re);
	}

	//Crear el fichero init_conf.txt
	ofstream initFile("init_conf.txt");

	initFile << argvNum[0] << " " << argvNum[1] << " " << argvNum[2] << "  " << argvNum[3] << endl;

	for (unsigned int i = 0; i < asteroids.size(); ++i)
	{
		initFile << fixed << setprecision(3) << asteroids[i].x << " " << asteroids[i].y << " " << asteroids[i].mass << endl;
	}

	for (unsigned int i = 0; i < planets.size(); ++i)
	{
		initFile << fixed << setprecision(3) << planets[i].x << " " << planets[i].y << " " << planets[i].mass << endl;
	}

	initFile.close();

	//Fichero step_by_step.txt
	//ofstream fileout("step_by_step.txt");

	auto tiempoInicial = clk :: now();

	//Bucle principal
	for(int iterations = 0; iterations < argvNum[1];iterations++)
	{
		//Borrar las fuerzas de la iteracion anterior
		#pragma omp parallel for @2
		for (unsigned int i = 0; i < asteroids.size();++i)
		{
			asteroids[i].Fx = 0.0;
			asteroids[i].Fy = 0.0;
		}

		//Calculo de todas las fuerzas
		//fileout << "--- asteroids vs asteroids ---" << endl;

		#pragma omp parallel for @2
		for(unsigned int i = 0; i < asteroids.size(); i++)
		{
			//Asteroides con asteroides
			#pragma omp parallel for @2
			for(unsigned int j = i+1; j < asteroids.size(); j++)
			{
				double distance = sqrt(pow(asteroids[i].x - asteroids[j].x, 2) + pow(asteroids[i].y - asteroids[j].y, 2));

				if(distance > dmin)
				{
					double slope = (asteroids[i].y - asteroids[j].y)/(asteroids[i].x - asteroids[j].x);

					if(slope > 1 || slope < -1)
						slope -= static_cast <int> (slope / 1);

					double angle = atan(slope);

					double gravityMagnitude = (gravity*asteroids[i].mass*asteroids[j].mass)/(pow(distance, 2));
					double gravityX = (gravityMagnitude > 200) ? (200 * cos(angle)) : (gravityMagnitude * cos(angle));
					double gravityY = (gravityMagnitude > 200) ? (200 * sin(angle)) : (gravityMagnitude * sin(angle));

					#pragma omp atomic
					asteroids[i].Fx += gravityX;

					#pragma omp atomic
					asteroids[i].Fy += gravityY;


					#pragma omp atomic
					asteroids[j].Fx -= gravityX;

					#pragma omp atomic
					asteroids[j].Fy -= gravityY;

					//#pragma omp critical
					//fileout << i << " " << j << " " << gravityMagnitude << " " << angle << endl;

				}

			}
		//}

		//fileout << "--- asteroids vs planets ---" << endl;

		//#pragma omp parallel for
		//for(unsigned int i = 0; i < asteroids.size(); i++)
		//{
			//Asteroides con planetas
			#pragma omp parallel for @2
			for(unsigned int j = 0; j < planets.size(); j++)
			{
				double distance = sqrt(pow(asteroids[i].x - planets[j].x, 2) + pow(asteroids[i].y - planets[j].y, 2));

				if(distance > dmin)
				{
					double slope = (asteroids[i].y - planets[j].y)/(asteroids[i].x - planets[j].x);
					if(slope > 1 || slope < -1)
						slope = slope - (static_cast <int> (slope) / 1);

					double angle = atan(slope);

					double gravityMagnitude = (gravity*asteroids[i].mass*planets[j].mass)/(pow(distance, 2));
					double gravityX = (gravityMagnitude > 200.0) ? (200.0 * cos(angle)) : (gravityMagnitude * cos(angle));
					double gravityY = (gravityMagnitude > 200.0) ? (200.0 * sin(angle)) : (gravityMagnitude * sin(angle));

					#pragma omp atomic
					asteroids[i].Fx += gravityX;

					#pragma omp atomic
					asteroids[i].Fy += gravityY;

					//#pragma omp critical
					//fileout << j << " " << i << " " << gravityMagnitude << " " << angle << endl;

				}
			}
		}

		#pragma omp parallel for @2
		for(unsigned i = 0; i < asteroids.size(); i++)
		{
			//Calculo de las aceleraciones
			double accelX = asteroids[i].Fx / asteroids[i].mass;
			double accelY = asteroids[i].Fy / asteroids[i].mass;

			//Calculo de las velocidades
			asteroids[i].Vx += accelX * deltaTime;
			asteroids[i].Vy += accelY * deltaTime;

			//Calculo de las posiciones
			asteroids[i].x += asteroids[i].Vx * deltaTime;
			asteroids[i].y += asteroids[i].Vy * deltaTime;

		}

		//Calculo de los rebotes con los bordes
		#pragma omp parallel for @2
		for(unsigned int i = 0; i < asteroids.size();++i)
		{
			if(asteroids[i].x <= 0)
			{
				asteroids[i].x = 2;
				asteroids[i].Vx *= -1;
			}

			if(asteroids[i].y <= 0)
			{
				asteroids[i].y = 2;
				asteroids[i].Vy *= -1;
			}

			if(asteroids[i].x >= width)
			{
				asteroids[i].x = width-2;
				asteroids[i].Vx *= -1;
			}

			if(asteroids[i].y >= height)
			{
				asteroids[i].y = height-2;
				asteroids[i].Vy *= -1;
			}
		}

		//Calculo de los rebotes entre asteroides
		#pragma omp parallel for @2
		for(unsigned int i = 0; i < asteroids.size(); ++i)
		{
			vector <asteroid*> collide;

			#pragma omp parallel for ordered @2
			for(unsigned int j = i+1; j < asteroids.size(); ++j)
			{
				if(sqrt(pow(asteroids[i].x - asteroids[j].x, 2) + pow(asteroids[i].y - asteroids[j].y, 2)) <= 2)
				{
					#pragma omp ordered
					collide.push_back(&asteroids[j]);
				}
			}

			if(collide.size() > 0)
			{
				collide.insert(collide.begin(), &asteroids[i]);
				double auxVx = collide[0] -> Vx;
				double auxVy = collide[0] -> Vy;
				for(unsigned int j = 0; j < collide.size() - 1; ++j)
				{
					collide[j] -> Vx = collide[j + 1] -> Vx;
					collide[j] -> Vy = collide[j + 1] -> Vy;
				}
				collide.back() -> Vx = auxVx;
				collide.back() -> Vy = auxVy;
			}
		}

		//fileout << endl<< "******************** ITERATION *******************" << endl;

	}

	auto tiempoFinal = clk :: now();
	auto tiempo  = chrono::duration_cast<chrono::microseconds>(tiempoFinal - tiempoInicial);
	cout << "Microsegundos empleados: " << tiempo.count() << endl;

	//fileout.close();

	//Generar el fichero out.txt
	ofstream outFile("out.txt");
	for(unsigned int i = 0; i < asteroids.size(); ++i)
	{
		outFile << fixed << setprecision(3) << asteroids[i].x << " " << asteroids[i].y << " " << asteroids[i].Vx << " " << asteroids[i].Vy << " " << asteroids[i].mass << endl;
	}

	outFile.close();

	return 0;
}
