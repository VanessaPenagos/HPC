#include "opencv2/opencv.hpp"
#include <cuda.h>
#include <stdio.h>

using namespace cv;

__global__ void imgGray(unsigned char * d_image, unsigned char* d_imagegray, int width, int height){
    int row = blockIdx.y*blockDim.y+threadIdx.y;
    int col = blockIdx.x*blockDim.x+threadIdx.x;

    if ((width > col) && (height > row)){
        d_imagegray[row*width+col]=d_image[(row*width+col)*3+2]*0.3+d_image[(row*width+col)*3+1]*0.6+d_image[(row*width+col)*3]*0.2;
    }
}

int main(int argc, char const *argv[])
{
    uchar *h_image, *d_image, *h_imagegray, *d_imagegray;

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

