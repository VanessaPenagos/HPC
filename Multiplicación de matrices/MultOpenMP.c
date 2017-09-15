#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "omp.h"

float** LlenaMatriz(int fila,int columna, FILE *archivo, float **matriz){

	for (int i = 0; i < fila; i++) {
		matriz[i] = malloc(columna*sizeof(float));
	}

	for (int i = 0; i < fila; i++) {
  		for (int j = 0; j < columna; j++) {
    		fscanf(archivo,"%f,",&matriz[i][j]);
  		}
	}
	return matriz;
}

void MultiplicarMatrices(int fila1, int fila2, int columna2, float **matriz1, float **matriz2){

	FILE *resultado;
	int i,j,k;
	float **matrizr,resultadop = 0,a;
	resultado = fopen("resultado","w");

	matrizr = malloc(fila1*sizeof(float*));
	for (int i = 0; i < fila1; i++) {
		matrizr[i] = malloc(columna2*sizeof(float));
	}
	
	fprintf(resultado,"%d \n",fila1);
   	fprintf(resultado,"%d \n",columna2);

   	#pragma omp parallel private(resultadop,i,j,k)
   	{
		#pragma omp for schedule(static)
		for (k = 0; k < fila1; k++){
			for (i = 0; i < columna2; i++) {
		 		resultadop = 0;
		 		for (j = 0; j < fila2; j++) {
		   			resultadop = resultadop + (matriz1[k][j]*matriz2[j][i]);
		 		}
		 		matrizr[k][i] =  resultadop;
			}
		}
	}

	for (i = 0; i < fila1; i++) {
  		for (j = 0; j < columna2; j++) {
  			if (j == columna2-1) {
		   		fprintf(resultado,"%.1f",matrizr[i][j]);
		 	}
		 	else{
		   		fprintf(resultado,"%.1f,",matrizr[i][j]);
		 	}
  		}
  		fprintf(resultado,"\n");
  	}

	fclose(resultado);
	free(matrizr);
}

int main(int argc, char const *argv[]) {

	FILE *archivo1;
	FILE *archivo2;
	int fila1, columna1, fila2, columna2,tid;
	float **matriz2, **matriz1, resultadop = 0;


	archivo1 = fopen(argv[1],"r");
	archivo2 = fopen(argv[2],"r");

	if (archivo1 != NULL && archivo2 != NULL) {
		fscanf(archivo1,"%d",&fila1);
		fscanf(archivo1,"%d",&columna1);
		fscanf(archivo2,"%d",&fila2);
		fscanf(archivo2,"%d",&columna2);

		if (columna1 == fila2) {
			// Se llena matriz 1x
			matriz1 = malloc(fila1*sizeof(float*));
			matriz1 = LlenaMatriz(fila1,columna1,archivo1,matriz1);

			// Se llena matriz 2
			matriz2 = malloc(fila2*sizeof(float*));
			matriz2 = LlenaMatriz(fila2,columna2,archivo2,matriz2);

			// Multiplicación de matrices
			MultiplicarMatrices(fila1,fila2,columna2,matriz1,matriz2);
		}
	}

	fclose(archivo1);
	fclose(archivo2);
	free(matriz1);
	free(matriz2);

	return 0;
}
