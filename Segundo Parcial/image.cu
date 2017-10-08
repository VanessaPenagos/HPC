#include "opencv2/opencv.hpp"
#include <cuda.h>
#include <stdio.h>

using namespace cv;


__global__void sobelFilter(unsigned char * d_imagegray, unsigned char *d_imagefiltered, int width, int height){

	int row = blockIdx.y*blockDim.y+threadIdx.y;
    int col = blockIdx.x*blockDim.x+threadIdx.x;
    int limitRow = height - 1, limitCol = width - 1, *sobelMaskRow, *sobelMaskCol;
    
    sobelMaskRow= (int*)malloc(9*sizeof(int));
    sobelMaskCol = (int*)malloc(9*sizeof(int));

    sobelMaskRow[0] = 1; sobelMaskRow[1] = 0; sobelMaskRow[2] = -1;
    sobelMaskRow[3] = 2; sobelMaskRow[4] = 0; sobelMaskRow[5] = -2;
    sobelMaskRow[6] = 1; sobelMaskRow[7] = 0; sobelMaskRow[8] = -1;

    sobelMaskCol[0] = -1; sobelMaskCol[0] = -2; sobelMaskCol[0] = -1;
    sobelMaskCol[0] = 0; sobelMaskCol[0] = 1; sobelMaskCol[0] = 0;
    sobelMaskCol[0] = 1; sobelMaskCol[0] = 2; sobelMaskCol[0] = 1;

    for (int i = 0; i < 3; ++i){
        for (int i = 0; i < count; ++i){
            if (limitCol >= 0 && limitRow >= 0 && limitRow < height && limitCol < width){

            }
        }
    }
}

__global__ void imgGray(unsigned char * d_image, unsigned char* d_imagegray, int width, int height){
    
    int row = blockIdx.y*blockDim.y+threadIdx.y;
    int col = blockIdx.x*blockDim.x+threadIdx.x;

    if ((width > col) && (height > row)){
        d_imagegray[row*width+col]=d_image[(row*width+col)*3+2]*0.3+d_image[(row*width+col)*3+1]*0.6+d_image[(row*width+col)*3]*0.2;
    }
}

int main(int argc, char const *argv[])
{
    uchar *h_image, *d_image, *h_imagegray, *d_imagegray, *h_imagefiltered, *d_imagefiltered;

    Mat image = imread(argv[1],1);
    Size s = image.size();
    int sizeRGB = s.width*s.height*image.channels()*sizeof(unsigned char);
    int sizeGray = s.width*s.height*sizeof(unsigned char);
    int blockSize = 32;
    printf("%d , %d \n",sizeRGB, sizeGray);
    if (image.empty()){
        printf("Not found the image \n");
    }

    h_imagegray = (unsigned char*)malloc(sizeGray);
    cudaMalloc((void**)&d_image,sizeRGB);
    cudaMalloc((void**)&d_imagegray,sizeGray);

    h_image = image.data;

    cudaMemcpy(d_image,h_image,sizeRGB,cudaMemcpyHostToDevice);
    dim3 dimBlock(blockSize,blockSize,1);
    dim3 dimTrheads(ceil(s.width/float(blockSize)),ceil(s.height/float(blockSize)),1);
    imgGray<<<dimTrheads,dimBlock>>>(d_image,d_imagegray,s.width,s.height);
    cudaDeviceSynchronize();
    cudaMemcpy(h_imagegray,d_imagegray,sizeGray,cudaMemcpyDeviceToHost);

    Mat imageGray;
    imageGray.create(s.height,s.width,CV_8UC1);
    imageGray.data = h_imagegray;
    imwrite("./ImageG.jpg",imageGray);

    return 0;
}

