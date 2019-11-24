%{
#include <stdio.h>
#include "scanner.yy.h"
#define YYERROR_VERBOSE
void yyerror(const char *);

void inicio(void);
void fin(void);
void asignar(const char *, const int);
void leer_id(const char *);
int valor_id(const char *);
void escribir_exp(const int val);
int operacionAditiva(const int, const char, const int);
int negativo(const char operador, const int val);

void yyerror(const char *s);
%}

%union{
	char string[100];
	char character;
	int integer;
}

%define "parser.tab.h"
%output = "parser.tab.c"
%token <string> ID INICIO FIN FDT LEER ESCRIBIR PARENIZQUIERDO PARENDERECHO COMA PUNTOYCOMA
%token <character> SUMA
%token <character> RESTA
%token <integer> CONSTANTE
%right ASIGNACION
%left RESTA SUMA

%type<integer> primaria expresion
%type<character>  operadorAditivo


%%
objetivo : { inicio(); } programa FDT { fin();}

programa	:  INICIO listaSentencias FIN
			;

listaSentencias		: sentencia
					| listaSentencias sentencia
					;

sentencia	: ID ASIGNACION expresion PUNTOYCOMA { printf("$1=%s,$3=%d\n",$1,$3);asignar($1,$3);}
			| LEER PARENIZQUIERDO listaIdentificadores PARENDERECHO PUNTOYCOMA
			| ESCRIBIR PARENIZQUIERDO listaExpresiones PARENDERECHO PUNTOYCOMA
			;

listaIdentificadores	: ID {leer_id($1);}
			| listaIdentificadores COMA ID {leer_id($3);}
			;

listaExpresiones	: expresion {escribir_exp($1);}
			| listaExpresiones COMA expresion {escribir_exp($3);}
			;

expresion	: primaria
			| operadorAditivo primaria { $$ = negativo($1,$2);}
			| expresion operadorAditivo primaria { printf("operador: %c\n",$2);$$ = operacionAditiva($1,$2,$3);}
			;

primaria 	: ID {$$ = valor_id($1)}
			| CONSTANTE
			| PARENIZQUIERDO expresion PARENDERECHO { $$ = $2;}
			;

operadorAditivo : SUMA
				| RESTA
				;

%%

struct id {
	char **id_nombres;
	int *ids;
	int id_nombres_size;
	int ids_size;
} ids;

const char *declarar_nombre(const char *id) {
	char **id_nombres_nuevo = realloc(ids.id_nombres, (ids.id_nombres_size + 1) * sizeof id);
	if(id_nombres_nuevo != NULL) {
		id_nombres_nuevo[ids.id_nombres_size] = (char *) malloc(sizeof id);
		sprintf(id_nombres_nuevo[ids.id_nombres_size], id, sizeof id);
		ids.id_nombres = id_nombres_nuevo;
		ids.id_nombres_size++;
	}

	return id;
}

const int declarar_valor(const int valor) {
	int *ids_nuevo = realloc(ids.ids, (ids.ids_size + 1) * sizeof valor);

	if(ids_nuevo != NULL) {
		ids_nuevo[ids.ids_size] = (int) malloc(sizeof valor);
		ids_nuevo[ids.ids_size] = valor;
		ids.ids = ids_nuevo;
		ids.ids_size++;
	}
	
	return valor;
}

const int declarar_valor_en_pos(const int valor, const int pos) {
	ids.ids[pos] = valor;	
	return valor;
}

void escribir_exp(const int val) {
	printf("Valor de la expresion: %d\n", val);
}

int operacionAditiva(const int val1, const char operadorAditivo, const int val2){
	switch(operadorAditivo){
		case '+':
			return val1 + val2;
		case '-':
			return val1 - val2;
	}
	return 0;
}

int negativo(const char operador, const int val){
	if (operador == '-'){
			return -val;
	}
	return val;
}

void leer_id(const char *id) {
	printf("Valor de %s=%d\n",id,valor_id(id));
}

int valor_id(const char *id){
	if(ids.ids_size > 0){
		for(int i = 0;i <ids.ids_size; i++){
			printf("nombre == ID?: %s,%s\n", ids.id_nombres[i],id);

			if (!strcmp(id,ids.id_nombres[i])){
				printf("Son iguales. Valor a mostrar:%d\n",ids.ids[i]);
				return ids.ids[i];
			}
		}
	}
	return 0;
}

int existe_en_pos(const char *id){
	if(ids.ids_size > 0){
		for(int i = 0;i <ids.ids_size; i++){
			if (!strcmp(id,ids.id_nombres[i])){
				return i;
			}
		}
	}
	return -1;
}


void asignar(const char *id, const int valor) {
	int pos = existe_en_pos(id);
	if(pos == -1){
		declarar_nombre(id);
		declarar_valor(valor);
	} else {
		declarar_valor_en_pos(valor,pos);
	}
}

void inicio(void) {
	printf("COMPILADOR CON FLEX Y BISON. Ingrese la secuencia de sentencias a evaluar:\n");
	ids.ids_size = 0;
}

void fin(void) {
	printf("Compilación terminada.\n");
}

int main(void) {
	yyparse();
}

void yyerror(const char *s){
	printf("línea #%d - %s\n", yylineno, s);
	return;
}