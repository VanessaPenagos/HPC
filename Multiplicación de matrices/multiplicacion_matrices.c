#include <stdio.h>
#include <stdlib.h>

int main(int argc, char const *argv[]) {
  FILE *archivo1;
  FILE *archivo2;
  FILE *resultado;
  int fila1, columna1, fila2, columna2;
  float **matriz2, **matriz1, resultadop = 0;

  archivo1 = fopen(argv[1],"r");
  archivo2 = fopen(argv[2],"r");
  resultado = fopen("resultado","w");

  if (archivo1 != NULL && archivo2 != NULL) {
    fscanf(archivo1,"%d",&fila1);
    fscanf(archivo1,"%d",&columna1);
    fscanf(archivo2,"%d",&fila2);
    fscanf(archivo2,"%d",&columna2);

    fprintf(resultado,"%d \n",fila1);
    fprintf(resultado,"%d \n",columna2);
    if (columna1 == fila2) {
      // Se llena matriz 1
      matriz1 = malloc(fila1*sizeof(float*));
      for (int i = 0; i < fila1; i++) {
        matriz1[i] = malloc(columna1*sizeof(float));
      }
      for (int i = 0; i < fila1; i++) {
        for (int j = 0; j < columna1; j++) {
          fscanf(archivo1,"%f,",&matriz1[i][j]);
        }
      }

      // Se llena matriz 2
      matriz2 = malloc(fila2*sizeof(float*));
      for (int i = 0; i < fila2; i++) {
        matriz2[i] = malloc(columna2*sizeof(float));
      }
      for (int i = 0; i < fila2; i++) {
        for (int j = 0; j < columna2; j++) {
          fscanf(archivo2,"%f,",&matriz2[i][j]);
        }
      }

      for (int k = 0; k < fila1; k++){
        for (int i = 0; i < columna2; i++) {
          for (int j = 0; j < fila2; j++) {
            resultadop = resultadop + (matriz1[k][j]*matriz2[j][i]);
          }
          if (i == columna2-1) {
            fprintf(resultado,"%.1f",resultadop);
          }
          else{
            fprintf(resultado,"%.1f,",resultadop);
          }
          resultadop = 0;
        }
        fprintf(resultado,"\n");
      }
    }
  }

  fclose(archivo1);
  fclose(archivo2);
  fclose(resultado);
  free(matriz1);
  free(matriz2);

  return 0;
}
