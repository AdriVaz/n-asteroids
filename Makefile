RM = rm -rf

par: seq
	g++ Par/nasteroids-par.cpp -o Par/nasteroids-par -lstdc++ -std=c++14 -Wall -Wno-deprecated -Werror -pedantic -pedantic-errors -O3 -DNDEBUG -lm -fopenmp

seq:
	g++ Seq/nasteroids-seq.cpp -o Seq/nasteroids-seq -lstdc++ -Wall -Wno-deprecated -Werror -pedantic -pedantic-errors -O3 -DNDEBUG -lm

clean:
	$(RM) *.txt

	$(RM) Par/nasteroids-par
	$(RM) Par/*.txt

	$(RM) Seq/nasteroids-seq
	$(RM) Seq/*.txt

	$(RM) *.txt

	$(RM) nasteroids-seq.o
	$(RM) nasteroids-par.o
