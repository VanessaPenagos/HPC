#include <cv.h>
#include <cuda.h>

using namespace cv;

__global__ void imgGray(){

}

int main(int argc, char const *argv[])
{
	char *h_image, *d_image, *h_imagegray, *d_imagegray;

	Mat image = imread(argv[1],0);
	Size s = image.size();
	int sizeRGB = s.width*s.height*image.channels(); 
	int sizeGray = s.width*s.height;
	int blocksize = 32, gridSize = ;

	if (image.empty()){
		printf("Not found the image \n");
	}

	h_image = (unsigned char*)malloc(sizeRGB);
	h_imagegray = (unsigned char*)malloc(sizeGray);
	cudaMalloc((void**)&d_image,sizeRGB);
	cudaMalloc((void**)&d_imagegray,sizeGray);

	h_image = image.data;

	namedWindow("Gray image", WINDOW_AUTOSIZE);
	imshow(argv[1],image);
	return 0;
}

