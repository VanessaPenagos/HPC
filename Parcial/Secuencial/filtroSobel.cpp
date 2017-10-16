#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

using namespace cv;

int main(int argc, char **argv){
  clock_t start, end; // Medir tiempos
  int scale = 1;
  int delta = 0;
  int ddepth = CV_16S;

  Mat image = imread(argv[1],1);
  Size s = image.size();

  if (image.empty()){
      printf("Not found the image \n");
  }

  Mat gray_image_opencv, grad_x, grad_y, grad, abs_grad_x,abs_grad_y;

  start = clock(); //Inicia reloj
  cvtColor(image, gray_image_opencv, CV_BGR2GRAY);

  Sobel( gray_image_opencv, grad_x, ddepth, 1, 0, 3, scale, delta, BORDER_DEFAULT );
  convertScaleAbs( grad_x, abs_grad_x );

  Sobel( gray_image_opencv, grad_y, ddepth, 0, 1, 3, scale, delta, BORDER_DEFAULT );
  convertScaleAbs( grad_y, abs_grad_y );

  addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, grad );
  end = clock(); //Finaliza reloj

  imwrite("./Sobel_Image.jpg", grad);

  double time = ((double)(end-start))/CLOCKS_PER_SEC;
  printf("Tiempo: %lf", time);

  return 0;
}
