%{
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "parser.tab.h"

inline int yywrap(void) { return 1; };
%}
%option header-file="scanner.yy.h"
%option outfile="scanner.yy.c"
%pointer

digito [0-9]
letra [a-zA-Z]
err_id [a-zA-Z][a-zA-Z0-9]*[@#]+[a-zA-Z0-9]*
err_cad [@#]+
err_cons [0-9][a-zA-Z0-9]+
%%
"inicio"							{ return INICIO; }
"fin"								{ return FIN; }
"leer"								{ return LEER; }
"escribir"							{ return ESCRIBIR; }
"fdt"								{ return FDT; }
{letra}({letra}|{digito}){0,31}		{ strcpy(yylval.string,yytext); return ID; }
-?{digito}+							{ yylval.integer = atoi(yytext); return CONSTANTE; }
":="								{ return ASIGNACION; }
-									{ yylval.character = '-'; return RESTA; }
\+									{ yylval.character = '+'; return SUMA; }
\(									{ return PARENIZQUIERDO; }
\)									{ return PARENDERECHO; }
,									{ return COMA; }
;									{ return PUNTOYCOMA; }
{err_id}							{ yyerror("ID incorrecto inválido"); }
{err_cons}							{ yyerror("Constante inválida"); }
{err_cad}							{ yyerror("Cadena inválida"); }
.|\n								|
%%