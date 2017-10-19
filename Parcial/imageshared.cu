#include "opencv2/opencv.hpp"
#include <cuda.h>
#include <stdio.h>
#include <math.h>

using namespace cv;

__constant__ char MaskRow[9];
__constant__ char MaskCol[9];


__device__ unsigned char clamp(int value){
    if(value < 0)
        value = 0;
    else
        if(value > 255)
            value = 255;
    return (unsigned char)value;
}


__global__ void sobelFilter(unsigned char * d_imagegray, unsigned char *d_imagefiltered, int width, int height){


    int row = blockIdx.y*blockDim.y+threadIdx.y;
    int col = blockIdx.x*blockDim.x+threadIdx.x;

    __shared__ unsigned char window[34][34];

if ((width > col) && (height > row)){
//llenar Linea Superior con 0
    if(row == 0){
            if(col == 0 ){
                window[0][0]=0;
                window[1][0]=0;
            }else if (col > 0 && threadIdx.x == 0 ){
                window[0][0]=0;
                window[1][0]=d_imagegray[row*width+((blockIdx.x-1)*blockDim.x+31)];
            }

            if(col == (width-1)){
                window[0][33]=0;
                window[1][33]=0;
            }else if(threadIdx.x == 31){
                window[0][33]=0;
                window[1][33]=d_imagegray[row*width+((blockIdx.x+1)*blockDim.x)];
            }
            window[threadIdx.y][threadIdx.x+1]=0;
            window[threadIdx.y+1][threadIdx.x+1]=d_imagegray[row*width+col];
    }

//Llenar linea inferior con  0
    if(row == (height-1)){
            if(col == 0 ){
                window[32][0]=0;
                window[33][0]=0;
            }else if (col > 0 && threadIdx.x == 0 ){
                window[32][0]=d_imagegray[row*width+((blockIdx.x-1)*blockDim.x+31)];
                window[33][0]=0;
            }

            if(col == (width-1)){
                window[32][threadIdx.x+2]=0;
                window[33][threadIdx.x+2]=0;
            }else if(threadIdx.x == 31){
                window[33][33]=0;
                window[32][33]=d_imagegray[row*width+((blockIdx.x+1)*blockDim.x)];
            }
            window[threadIdx.y+2][threadIdx.x+1]=0;
            window[threadIdx.y+1][threadIdx.x+1]=d_imagegray[row*width+col];
    }


//Llenar lineas interio	|res
    else if(row > 0 && row < height){
            if(col == 0 ){
                window[threadIdx.y+1][0]=0;
            }else if (col > 0 && threadIdx.x == 0 ){
                window[threadIdx.y+1][0]=d_imagegray[row*width+((blockIdx.x-1)*blockDim.x+31)];
            }
    if(col > 0 && col < width){
            if(col == (width-1)){
                window[threadIdx.y+1][threadIdx.x+2]=0;
            }else if(threadIdx.x == 31){
                window[threadIdx.y+1][threadIdx.x+2]=d_imagegray[row*width+((blockIdx.x+1)*blockDim.x)];
            }

            if (threadIdx.y == 0){
                window[threadIdx.y][threadIdx.x+1]=d_imagegray[((blockIdx.y-1)*blockDim.y+31)*width+col];

            }

	    if (threadIdx.y == 0 && threadIdx.x == 0){
                window[threadIdx.y][threadIdx.x]=d_imagegray[((blockIdx.y-1)*blockDim.y+31)*width+((blockIdx.x-1)*blockDim.x+31)];
            }

            if (threadIdx.y == 31){
                window[threadIdx.y][threadIdx.x+1]=d_imagegray[((blockIdx.y+1)*blockDim.y)*width+col];
            }

	    if (threadIdx.y == 0 && threadIdx.x == 31){
                window[threadIdx.y][threadIdx.x+2]=d_imagegray[((blockIdx.y-1)*blockDim.y+31)*width+((blockIdx.x+1)*blockDim.x)];
            }

	    if (threadIdx.y == 31 && threadIdx.x == 0){
                window[threadIdx.y+2][threadIdx.x]=d_imagegray[((blockIdx.y+1)*blockDim.y)*width+((blockIdx.x-1)*blockDim.x+31)];
            }

	    if (threadIdx.y == 31 && threadIdx.x == 31){
                window[threadIdx.y+2][threadIdx.x]=d_imagegray[((blockIdx.y+1)*blockDim.y)*width+((blockIdx.x+1)*blockDim.x)];
            }
	}
            window[threadIdx.y+1][threadIdx.x+1]=d_imagegray[row*width+col];

    }
}

__syncthreads();

    float tmpR,tmpC;
    int trow = threadIdx.y+1;
    int tcol = threadIdx.x+1;

    int aux_row = trow - 1, aux_col = tcol - 1;

    for (int i = 0; i < 3; ++i){
        for (int j = 0; j < 3; ++j){
            tmpR += (window[aux_row][aux_col])*MaskRow[(i*3)+j];
            aux_col += 1;
        }

        aux_row += 1;
        aux_col = tcol - 1 ;

    }



    aux_row = trow - 1, aux_col = tcol - 1;

    for (int i = 0; i < 3; ++i){
        for (int j = 0; j < 3; ++j){
                tmpC += window[aux_row][aux_col]*MaskCol[(i*3)+j];
                aux_col += 1;
        }
	if(col== 0 &&  row == 0){
		printf(" %d %d " , aux_row , aux_col);
	}
        aux_row += 1;
        aux_col = tcol - 1 ;
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

    char h_sobelMaskRow[] = { 1 ,0, -1, 2, 0, -2, 1, 0, -1 };
    char h_sobelMaskCol[] = { -1 , -2, -1, 0, 1, 0, 1, 1, 1};
    for(int i =0 ; i<sizeGray/2 ; i++){
      printf("pos %d %d\n",i, h_imagegray[i]);
    }

    cudaMalloc((void**)&d_imagefiltered,sizeGray);

    cudaMemcpyToSymbol(MaskRow,h_sobelMaskRow,sizeof(char)*9);
    cudaMemcpyToSymbol(MaskCol,h_sobelMaskCol,sizeof(char)*9);

    sobelFilter<<<dimTrheads,dimBlock>>>(d_imagegray,d_imagefiltered,s.width,s.height);
    cudaDeviceSynchronize();
    h_imagefiltered = (unsigned char*)malloc(sizeGray);
    cudaMemcpy(h_imagefiltered,d_imagefiltered,sizeGray,cudaMemcpyDeviceToHost);

    Mat imageGray;
    imageGray.create(s.height,s.width,CV_8UC1);
    imageGray.data = h_imagegray;
    imwrite("./ImageG.jpg",imageGray);

    Mat imageSobel;
    imageSobel.create(s.height,s.width,CV_8UC1);
    imageSobel.data = h_imagefiltered;
    imwrite("./ImageS.jpg",imageSobel);

 //liberar memoria 
    return 0;
}
