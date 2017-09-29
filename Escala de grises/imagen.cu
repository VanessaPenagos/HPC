#include <cv.h>
#include <cuda.h>

using namespace cv;

__global__ void imgchange(){

	int col = blockIdx.x*blockDim.x+threadIdx.x;
	int row = blockIdx.y*blockDim.y+threadIdx.y;
}

int main(int argc, char const *argv[])
{
	char *h_image, *d_image, *h_imagechange, *d_imagechange;

	Mat image = imread(argv[1],0);

	if (image.empty()){
		printf("No se puede cargar la imagen \n");
	}

	//h_image = (unsigned char*)malloc();

	Size s = image.size();
	namedWindow(argv[1], WINDOW_AUTOSIZE);
	imshow(argv[1],image);
	return 0;
}

