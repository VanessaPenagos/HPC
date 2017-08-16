#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char const *argv[]) {

  FILE *archivo1;
  FILE *archivo2;
  int fila1,columna1,fila2,columna2,i,j,max;

  srand(time(NULL));

  printf("# fila y columna de primera matriz: \n");
  scanf("%d %d",&fila1,&columna1);

  printf("# fila y columna de segunda matriz: \n");
  scanf("%d %d",&fila2,&columna2);

  printf("Limite de numeros generados: \n");
  scanf("%d",&max);


   if (columna1 == fila2){
   		archivo1 = fopen("matriz1.txt","w");
   		archivo2 = fopen("matriz2.txt","w");

   		//para archivo 1
   		fprintf(archivo1, "%d\n", fila1);
   		fprintf(archivo1, "%d\n", columna1);
   		for(i=0; i<fila1; i++){
   			for (j = 0; j < columna1; j++){
   				if(j == columna1-1)
   					fprintf(archivo1, "%d", rand()%max);
   				else
   					fprintf(archivo1, "%d,", rand()%max);
   			}
   			if(i != fila1-1)
   				fprintf(archivo1, "\n");
   		}
   		//Para archivo2
   		fprintf(archivo2, "%d\n", fila2);
   		fprintf(archivo2, "%d\n", columna2);
   		for(i=0; i<fila2; i++){
   			for (j = 0; j < columna2; j++){
   				if(j == columna2-1)
   					fprintf(archivo2, "%d", rand()%max);
   				else
   					fprintf(archivo2, "%d,", rand()%max);
   			}
   			if(i != fila2-1)
   				fprintf(archivo2, "\n");
   		}
      printf("xD\n");
   }
   else{
    printf("No se generará la matriz\n");
   }

   fclose(archivo1);
   fclose(archivo2);
  return 0;
}
