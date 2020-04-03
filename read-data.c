#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

struct brukerkonto {
	char brukernavn[100];
	char fornavn   [250]; // alle navn bortsett fra etternavn
	char etternavn [100]; // det siste navnet
};

typedef struct brukerkonto konto_t;

void les_data   (konto_t *brukertabell);
void skriv_data (konto_t *brukertabell, int argc, char *argv[]);
void lese_og_skrive_eksempel();

int main(int argc, char *argv[]) {

	konto_t brukertabell[200];

	//lese_og_skrive_eksempel();
	les_data  (brukertabell);
	skriv_data(brukertabell, argc, argv);

	return 0;
}


void les_data   (konto_t *brukertabell) {

	FILE *passwd = fopen( "/etc/passwd", "r" );
	if ( !passwd ) {

		printf( "Could not retrieve passwd" );
	}

	char  *saveptr = NULL;
	char  *txt = NULL;
	size_t len = 0;

	konto_t bruker;
	char *bn, *p;
	char navn[350], fn[250], en[100];
	char navnListe[5][150];
	int i, j, k, uid;
	for ( i = 0; i < 200 && ( -1 != ( len=getline( &txt, &len, passwd ) ) ); i++) {

		saveptr = NULL;
		bn = strtok_r( txt, ":", &saveptr );
		strtok_r( NULL, ":", &saveptr );
		sscanf( strtok_r( NULL, ":", &saveptr ), "%d", &uid );

		if( uid < 1000 ) {

			i--;
		}
		else {

			strcpy( brukertabell[i].brukernavn, bn );

			strtok_r( NULL, ":", &saveptr );
			strcpy( navn, strtok_r( NULL, ",:", &saveptr ) );
			saveptr = NULL;

			p = strtok_r( navn, " ", &saveptr );
			j = 0;
			while( p != NULL )
			{

				strcpy( navnListe[j++], p );
				p = strtok_r( NULL, " ", &saveptr );
			}
			if ( j == 1 ) {

				strcpy( fn, navnListe[j - 1] );
			}
			else {

				strcpy( fn, "" );
				for( k = 0; k < j - 1; k++ ) {

					strcat( fn, navnListe[k] );
					if ( k < j - 2 ) {

						strcat( fn, " " );
					}
				}
				strcpy( en, navnListe[k] );
			}

			strcpy( brukertabell[i].fornavn, fn );
			strcpy( brukertabell[i].etternavn, en );
		}
	}
	strcpy( brukertabell[i].brukernavn, "");
	strcpy( brukertabell[i].fornavn, "");
	strcpy( brukertabell[i].etternavn, "");
	fclose( passwd );
}

void skriv_data (konto_t *brukertabell, int argc, char *argv[]) {

	int i;
	int arg = 0;
	char argStr[11];

	if ( argc > 1 ) {

		strcpy( argStr, argv[1] );
	}
	if ( !strcmp( argStr, "brukernavn" ) ) {

		arg = 1;
	}
	else if ( !strcmp( argStr, "fornavn" ) ) {

		arg = 2;
	}
	else if ( !strcmp( argStr, "etternavn" ) ) {

		arg = 3;
	}

	if ( arg == 0 ) {
		if( getenv( "forst" ) ) {

			strcpy( argStr, getenv( "forst" ) );
		}
		if ( !strcmp( argStr, "brukernavn" ) ) {

			arg = 1;
		}
		else if ( !strcmp( argStr, "fornavn" ) ) {

			arg = 2;
		}
		else if ( !strcmp( argStr, "etternavn" ) ) {

			arg = 3;
		}
	}

	if ( arg == 0 ) {

		printf( "Program krever argument eller miljøvariabel \"forst\": lik enten \"brukernavn\", \"fornavn\" eller \"etternavn\"" );
	}

	if ( !strcmp( argStr, "brukernavn" ) ) {

		for ( i = 0; i < 200; i++ ) {

			if ( strcmp( brukertabell[i].brukernavn, "" ) == 0 ) {

				break;
			}
			printf( "%s:%s:%s\n",
				brukertabell[i].brukernavn,
				brukertabell[i].etternavn,
				brukertabell[i].fornavn );
		}
	}
	else if ( !strcmp( argStr, "fornavn" ) ) {

		for ( i = 0; i < 200; i++ ) {

			if ( strcmp( brukertabell[i].brukernavn, "" ) == 0 ) {

				break;
			}
			printf( "%s:%s:%s\n",
				brukertabell[i].fornavn,
				brukertabell[i].etternavn,
				brukertabell[i].brukernavn );
		}
	}
	else if ( !strcmp( argStr, "etternavn" ) ) {

		for ( i = 0; i < 200; i++ ) {

			if ( strcmp( brukertabell[i].brukernavn, "" ) == 0 ) {

				break;
			}
			printf( "%s:%s:%s\n",
				brukertabell[i].etternavn,
				brukertabell[i].fornavn,
				brukertabell[i].brukernavn );
		}
	}
}


void lese_og_skrive_eksempel() {

	/*
	Leser fra standard inngang, og
	skriver til standard utgang -- som cat(1)
	Introduserer:
	- getline(3)
	*/

	char  *txt = NULL; // peker til lagerplass for innlest linje
	size_t len = 0;    // lengde på innlest linje

	while ( -1 != ( len=getline( &txt, &len, stdin ) ) )
		printf("%s", txt);

}
