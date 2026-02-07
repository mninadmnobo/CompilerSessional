yacc --yacc -d -Wcounterexamples 2005080.y -o y.tab.cpp
echo 'step-1: y.tab.cpp and y.tab.hpp created'
flex -o 2005080.cpp 2005080.l
echo 'step-2: scanner created'
g++ -w *.cpp
echo 'step-3: a.out created'
rm 2005080.cpp y.tab.cpp y.tab.hpp
./a.out  input.c -Wconflicts-sr
rm input_parsetree.txt input_log.txt input_error.txt
rm a.out 
