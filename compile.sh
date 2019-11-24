#!/bin/bash

rm -f scanner.yy.c scanner.yy.h parser.tab.c parser.tab.h compiler

flex scanner.l
bison -d parser.y
gcc -o compiler parser.tab.c scanner.yy.c