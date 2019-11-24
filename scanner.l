%{
#include <stdio.h>
#include <strings.h>
#include "parser.h"

inline int yywrap(void) { return 1; };
%}
%option header-file="scanner.h"
%option outfile="scanner.c"
%option yylineno

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
{letra}({letra}|{digito})+			{ yylval = strdup(yytext); return ID; }
{digito}+							{ yylval = strdup(yytext);  return CONSTANTE; }
":="								{ return ASIGNACION; }
-									{ return '-'; }
\+									{ return '+'; }
\*									{ return '*'; }
\/									{ return '/'; }
\(									{ return '('; }
\)									{ return ')'; }
,									{ return ','; }
;									{ return ';'; }
{err_id}							{ yyerror("ID incorrecto inválido"); }
{err_cons}							{ yyerror("Constante inválida"); }
{err_cad}							{ yyerror("Cadena inválida"); }
.|\n								|
"//".*								;
%%