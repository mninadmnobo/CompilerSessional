#include "2005107_fileIo.h"
#include <fstream>
#include <string>
using namespace std;
string INPUT_FILE = "input.txt";
string OUTPUT_FILE = "output.txt";
int cmdCount = 0;
ifstream inFile(INPUT_FILE);
ofstream outFile(OUTPUT_FILE);