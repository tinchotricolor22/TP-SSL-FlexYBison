%{
#include <stdio.h>
#include "scanner.yy.h"
#include <dirent.h>
#define YYERROR_VERBOSE //para mostrar más descripcion en los errores
void yyerror(const char *);

void inicio(void);
void fin(void);
void asignar(const char *, const int);
void leer_id(const char *);
int valor_id(const char *);
void escribir_exp(const int val);
int operacionAditiva(const int, const char, const int);
int negativo(const char operador, const int val);

//para ejecutar los tests y parsear archivos
void ejecutar_tests();
int parsear_archivo(const char* archivo);
int ends_with(const char *str, const char *suffix);
%}

%union{
	char string[100];
	char character;
	int integer;
}

%defines "parser.tab.h"
%output = "parser.tab.c"
%token <string> ID INICIO FIN FDT LEER ESCRIBIR PARENIZQUIERDO PARENDERECHO COMA PUNTOYCOMA
%token <character> SUMA
%token <character> RESTA
%token <integer> CONSTANTE
%right ASIGNACION
%left RESTA SUMA

%type<integer> primaria expresion //lo exige bison porque si no no sabe el tipo 
%type<character>  operadorAditivo //lo exige bison porque si no no sabe el tipo


%%
objetivo : { inicio(); } programa FDT { fin();}

programa	:  INICIO listaSentencias FIN
			;

listaSentencias		: sentencia
					| listaSentencias sentencia
					;

sentencia	: ID ASIGNACION expresion PUNTOYCOMA { asignar($1,$3);}
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
			| expresion operadorAditivo primaria { $$ = operacionAditiva($1,$2,$3);}
			;

primaria 	: ID {$$ = valor_id($1);}
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
			if (!strcmp(id,ids.id_nombres[i])){
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
	printf("Comienza a compilar:\n");
}

void fin(void) {
	printf("Compilación terminada.\n");
}

void yyerror(const char *s){
	printf("línea #%d - %s\n", yylineno, s);
	return;
}


/*Se ejecutan los casos de prueba que estan dentro de la carpeta "casos"
  Tener en cuenta que si bien se probo la asignación correcta y guardado en memoria,
  solo se evalua si se parsea bien o mal, dependiendo lo que pida el test.

  Para pasar un test:
  Si termina con "OK.test", esperamos que se parsee bien (yyparse() == 0)
  Si termina con "OtraCosa.test", esperamos que se parsee mal (yyparse() != 0)
*/
void ejecutar_tests() {
	printf("Ejecutando tests...");
	int testPass = 0;
	int testFail = 0;
	DIR *d;
    struct dirent *dir;
    d = opendir("casos");
    if (d)
    {
        while ((dir = readdir(d)) != NULL)
        {
        	if(ends_with(dir->d_name,".test")){
        		int mustPass = ends_with(dir->d_name,"OK.test"); //el result del parse debe dar 0 

        		char buf[300];
        		strcpy(buf,"casos/");
        		strcat(buf,dir->d_name);
        		int result = parsear_archivo(buf);
        		if (mustPass){
        			if (result == 0){
        				testPass++;	
        			}else{
        				testFail++;
        			}
        		}else{
        			if (result == 0){
        				testFail++;	
        			}else{
        				testPass++;
        			}
        		}
        	}
        }
        closedir(d);
    }
	printf("TOTAL DE TESTS CORRIDOS: %d\n", testPass + testFail);
	printf("Test que pasaron: %d\n", testPass);
	printf("Test que fallaron: %d\n", testFail);
}

int ends_with(const char *str, const char *suffix)
{
    if (!str || !suffix)
        return 0;
    size_t lenstr = strlen(str);
    size_t lensuffix = strlen(suffix);
    if (lensuffix >  lenstr)
        return 0;
    return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
}

int parsear_archivo(const char* archivo){
	printf("Interpretando el archivo %s\n", archivo);	
	yyin = fopen(archivo, "r");
	int result = yyparse();
	yyrestart(yyin);
	return result;
}

int main(int argc, char **argv) {
	ids.ids_size = 0;
	ids.id_nombres_size = 0;

	if(argc > 1){
		//se agrega la posibilidad de correr tests con el argumento
		if (!strcmp(argv[1],"-correr_tests")){
			ejecutar_tests();
		} else {
			/*en caso de que no este el argumento de correr_tests y haya varios argumentos,
			asumimos que son archivos que tenemos que parsear */
			for(int i = 1; i < argc ; i++){
				parsear_archivo(argv[i]);
			}
		}
	} else {
		//caso contrario, vamos por la consola
		yyparse(); // yyin = stdin
	}
}