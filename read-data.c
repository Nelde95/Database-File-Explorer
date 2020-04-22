#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <sqlite3.h>

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


void les_data   (konto_t *brukertabell)
{
	sqlite3* db;
	sqlite3_stmt* res;

	if(sqlite3_open("files.db", &db) != SQLITE_OK)
	{
		printf("could not open database \"files.db\"\n");
		exit(1);
	}
	
	if(sqlite3_prepare_v2(db,
		"SELECT uid, brukernavn, navn FROM Bruker",
		-1, &res, 0) != SQLITE_OK)
	{
		printf("could not prepare statement\n");
		exit(1);
	}
	
	int i;
	for(i = 0; (i < 200) && (sqlite3_step(res) == SQLITE_ROW); i++)
	{
		char  *saveptr = NULL;
		konto_t bruker;
		char *brukernavn, *p;
		char navn[350], fornavn[250], etternavn[100];
		char navnListe[5][150] = {"","","","",""};
		int j, k, uid;

		uid = sqlite3_column_int(res, 0);
		brukernavn = strdup(sqlite3_column_text(res, 1));
		strcpy(navn, sqlite3_column_text(res, 2));

		if(uid < 1000)
		{
			i--;
			continue;
		}

		//using strtok_r on the 'navn' string
		p = strtok_r( navn, " ", &saveptr );
		j = 0;
		while( p != NULL )
		{
			//copies each part of the name into 'navnListe[]'
			strcpy(navnListe[j++], p);
			p = strtok_r(NULL, " ", &saveptr);
		}
		if ( j <= 1 )
		{
			strcpy(etternavn, "");
			strcpy(fornavn, navnListe[0]);
		}
		else
		{
			strcpy(fornavn, "");
			for( k = 0; k < j - 1; k++ )
			{
				strcat( fornavn, navnListe[k] );
				if ( k < j - 2 )
				{
					strcat( fornavn, " " );
				}
			}
			strcpy(etternavn, navnListe[k]);
		}
		strcpy(brukertabell[i].brukernavn, brukernavn);
		strcpy(brukertabell[i].fornavn, fornavn);
		strcpy(brukertabell[i].etternavn, etternavn);
	}
	sqlite3_finalize(res);
	sqlite3_close_v2(db);

	strcpy(brukertabell[i].brukernavn, "");
	strcpy(brukertabell[i].fornavn, "");
	strcpy(brukertabell[i].etternavn, "");
	return;
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
