#!/bin/bash

rm -fR build interprete

mkdir build

flex scanner.l
bison -d parser.y
gcc -o interprete parser.tab.c scanner.yy.c

mv scanner.yy.c build
mv scanner.yy.h build
mv parser.tab.c build
mv parser.tab.h build