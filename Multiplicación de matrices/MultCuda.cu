#include <stdio.h>
#include <stdlib.h>


float* LlenaMatriz(int fila,int columna, FILE *archivo, float *matriz){

	for (int i = 0; i < fila; i++) {
		fscanf(archivo,"%f,",&matriz[i]);
	}
	return matriz;
}

int main(int argc, char const *argv[])
{
	FILE *archivo1;
	FILE *archivo2;
	int fila1, columna1, fila2, columna2, blockSize, gridSize;
	float resultadop = 0;

	// Matrices entrada Host
    float *h_m1, *h_m2;
    // Matriz salida Host
    float *h_mr;
 
    // Matrices entrada Device
    float *d_m1, *d_m2;
    // Matriz de salida Device
    float *d_mr;

	archivo1 = fopen(argv[1],"r");
	archivo2 = fopen(argv[2],"r");

	if (archivo1 != NULL && archivo2 != NULL) {
		fscanf(archivo1,"%d",&fila1);
		fscanf(archivo1,"%d",&columna1);
		fscanf(archivo2,"%d",&fila2);
		fscanf(archivo2,"%d",&columna2);

		if (columna1 == fila2) {

			// Reservando y llenado de la matriz 2
			h_m1 = malloc((fila1*columna1)*sizeof(float*)); // Reserva memoria en el host
			cudaMalloc(&d_m1, (fila1*columna1)); // Reserva memoria en el device
			h_m1 = LlenaMatriz(fila1,columna1,archivo1,h_m1); // Llena vector-matriz en el host
			cudaMemcpy( d_m1, h_m1, (fila1*columna1), cudaMemcpyHostToDevice); // Llenar vector-matriz en el device

			// Reservando y llenado de la matriz 2
			h_m2 = malloc((fila2*columna2)*sizeof(float*)); // Reserva memoria en el host
			cudaMalloc(&d_m2, (fila2*columna2)); // Reserva memoria en el device
			h_m2 = LlenaMatriz(fila2,columna2,archivo2,h_m2); // Llnea vector-matriz en el host
			cudaMemcpy( d_m2, h_m2, (fila2*columna2), cudaMemcpyHostToDevice); // Llenar vector-matriz en el device
  
			// Multiplicación de matrices
			//MultiplicarMatrices(fila1,fila2,columna2,matriz1,matriz2);
		}
	}
}