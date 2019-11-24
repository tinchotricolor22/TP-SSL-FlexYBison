%{
#include <stdio.h>
#include "scanner.h"
#define YYERROR_VERBOSE
#define YYSTYPE char*
void yyerror(const char *);

void comenzar(void);
void terminar(void);
void asignar(const char *, const char *);
void leer_id(const char *);
char *chequear(const char *);
void escribir_exp(const char *);
char *gen_infijo(const char *, const char, const char *);
char *invertir(const char *);

void yyerror(const char *s);
%}

%define "parser.h"
%output = "parser.c"
%token ID CONSTANTE INICIO FIN LEER ESCRIBIR NEG
%right ASIGNACION
%left '-' '+'
%left '*' '/'

%%

programa	: { comenzar(); } INICIO listaSentencias FIN { terminar();}
			;
listaSentencias		: sentencia
			| listaSentencias sentencia
			;
sentencia	: identificador ASIGNACION identificador ';' { asignar($1, $3); }
			| LEER '(' listaIdentificadores ')' ';'
			| error ';' { yyerrok; }
			;
listaIdentificadores	: ID { leer_id($1); }
			| listaIdentificadores ',' ID { leer_id($3); }
			;
identificador		: ID { chequear($1); $$ = $1; }

%%

struct definiciones {
	char **vars;
	int v_size;
	int t_size;
} defs;

char *declarar_temporal() {
	char *t_str = malloc(12);
	defs.t_size++;
	printf("Declare Temp&%d,Integer,\n", defs.t_size);
    
	sprintf(t_str, "Temp&%d", defs.t_size);
	return t_str;
}

const char *declarar_variable(const char *id) {
	char **new_vars = realloc(defs.vars, (defs.v_size + 1) * sizeof id);

	if(new_vars != NULL) {
		new_vars[defs.v_size] = (char *) malloc(sizeof id);
		sprintf(new_vars[defs.v_size], id, sizeof id);
		defs.vars = new_vars;
		defs.v_size++;
	}

	printf("Declare %s,Integer,\n", id);

	return id;
}

void escribir_exp(const char *val) {
	printf("Write %s,Integer,\n", val);
}

void leer_id(const char *val) {
	printf("Read %s,Integer,\n", val);
}

void asignar(const char *val1, const char *val2) {
	printf("Storing...\n");
	printf("Store %s,%s,\n", val2, val1);
}

char *gen_infijo(const char *val1, const char op, const char *val2) {
	char *temp = declarar_temporal();
	char *op_str = malloc(4);

	switch(op) {
	case '-':
		strncpy(op_str, "SUBS", 4);
	break;
	case '*':
		strncpy(op_str, "MULT", 4);
	break;
	case '/':
		strncpy(op_str, "DIV", 4);
	break;
	case '+':
		strncpy(op_str, "ADD", 4);
	break;
	}
	
	printf("%s %s,%s,%s\n", op_str, val1, val2, temp);
	return temp;
}

char *invertir(const char *val) {
	char *temp = declarar_temporal();

	printf("INV %s,,%s\n", val, temp);

	return temp;
}

char *chequear(const char *id) {
	printf("ID %s",id);
}

void terminar(void) {
	puts("Stop ,,");
}

void comenzar(void) {
	puts("Load rtlib,,");
}

int main(int argc, char *argv[]) {
	int value = yyparse();

	switch( value ){
	case 0:
		puts("Compilación terminada con éxito");
		break;
	case 1:
		puts("Errores de compilación");
		break;
	case 2:
		puts("Memoria insuficiente");
		break;
	}

	printf("Errores sintácticos: %d", yynerrs);
	return 0;
}

void yyerror(const char *s){
	printf("línea #%d - %s\n", yylineno, s);
	return;
}