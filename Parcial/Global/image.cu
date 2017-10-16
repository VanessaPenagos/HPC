#include "opencv2/opencv.hpp"
#include <cuda.h>
#include <stdio.h>
#include <math.h>

using namespace cv;

__device__ unsigned char clamp(int value){
    if(value < 0)
        value = 0;
    else
        if(value > 255)
            value = 255;
    return (unsigned char)value;
}


__global__ void sobelFilter(unsigned char * d_imagegray, unsigned char *d_imagefiltered, int width, int height, char* MaskRow, char * MaskCol){

    int row = blockIdx.y*blockDim.y+threadIdx.y;
    int col = blockIdx.x*blockDim.x+threadIdx.x;
    int limitRow = height - 1, limitCol = width - 1;
    float tmpR,tmpC;
    int aux_row = row - 1, aux_col = col - 1; 
    
    for (int i = 0; i < 3; ++i){
        for (int j = 0; j < 3; ++j){
            if (limitCol >= 0 && limitRow >= 0 && limitRow < height && limitCol < width){
                tmpR += d_imagegray[aux_row*width + aux_col]*MaskRow[(i*3)+j];
                aux_col += 1;
            }
            aux_row += 1;
            aux_col = col - 1 ;
        }
    }

    aux_row = row - 1, aux_col = col - 1; 
    
    for (int i = 0; i < 3; ++i){
        for (int j = 0; j < 3; ++j){
            if (limitCol >= 0 && limitRow >= 0 && limitRow < height && limitCol < width){
                tmpC += d_imagegray[aux_row*width + aux_col]*MaskCol[(i*3)+j];
                aux_col += 1;
            }
            aux_row += 1;
            aux_col = col - 1 ;
        }
    }
        
    d_imagefiltered[(row * width) + col] = clamp(sqrt(pow(tmpC,2) + pow(tmpR , 2)));
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
    clock_t start, end; // Medir tiempos

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
    h_imagefiltered = (unsigned char*)malloc(sizeGray);
    cudaMalloc((void**)&d_image,sizeRGB);
    cudaMalloc((void**)&d_imagegray,sizeGray);

    h_image = image.data;

    cudaMemcpy(d_image,h_image,sizeRGB,cudaMemcpyHostToDevice);
    dim3 dimBlock(blockSize,blockSize,1);
    dim3 dimTrheads(ceil(s.width/float(blockSize)),ceil(s.height/float(blockSize)),1);

    char h_sobelMaskRow[] = { 1 ,0, -1, 2, 0, -2, 1, 0, -1 };
    char h_sobelMaskCol[] = { -1 , -2, -1, 0, 1, 0, 1, 1, 1};

    char *d_sobelMaskRow;
    char *d_sobelMaskCol;

    cudaMalloc((char**)&d_sobelMaskRow,sizeof(char)*9);
    cudaMalloc((char**)&d_sobelMaskCol,sizeof(char)*9);
    cudaMalloc((void**)&d_imagefiltered,sizeGray);

    cudaMemcpy(d_sobelMaskRow,h_sobelMaskRow,sizeof(char)*9,cudaMemcpyHostToDevice);
    cudaMemcpy(d_sobelMaskCol,h_sobelMaskCol,sizeof(char)*9,cudaMemcpyHostToDevice);

    start = clock(); //Inicia reloj
    imgGray<<<dimTrheads,dimBlock>>>(d_image,d_imagegray,s.width,s.height);
    cudaDeviceSynchronize();
    cudaMemcpy(h_imagegray,d_imagegray,sizeGray,cudaMemcpyDeviceToHost);

    sobelFilter<<<dimTrheads,dimBlock>>>(d_imagegray,d_imagefiltered,s.width,s.height,d_sobelMaskRow,d_sobelMaskCol);
    cudaDeviceSynchronize();
    cudaMemcpy(h_imagefiltered,d_imagefiltered,sizeGray,cudaMemcpyDeviceToHost);
    end = clock(); //Finaliza reloj

    Mat imageGray;
    imageGray.create(s.height,s.width,CV_8UC1);
    imageGray.data = h_imagegray;
    imwrite("./ImageG.jpg",imageGray);

    Mat imageSobel;
    imageSobel.create(s.height,s.width,CV_8UC1);
    imageSobel.data = h_imagefiltered;
    imwrite("./ImageS.jpg",imageSobel);

    cout <<"Tiempo:"<<((double)(end-start))/CLOCKS_PER_SEC<<endl;

    return 0;
}

