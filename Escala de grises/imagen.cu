#include <cv.h>
#include <cuda.h>

using namespace cv;

__global__ void imgGray(unsigned char * d_image, unsigned char* d_imagegray, int width, int height){
    int row = blockIdx.y*blockDim.y+threadIdx.y;
    int col = blockIdx.x*blockDim.x+threadIdx.x;

    if (width > col && height > row){
        d_imagegray[row*width+col]=d_imagegray[(row*width+col)*3+2]*0.21+d_imagegray[(row*width+col)*3+1]*0.71+d_imagegray[(row*width+col)*3]*0.07;
    }
}

int main(int argc, char const *argv[])
{
    char *h_image, *d_image, *h_imagegray, *d_imagegray;

    Mat image = imread(argv[1],0);
    Size s = image.size();
    int sizeRGB = s.width*s.height*image.channels(); 
    int sizeGray = s.width*s.height;
    int blocksize = 32;

    if (image.empty()){
        printf("Not found the image \n");
    }

    h_image = (unsigned char*)malloc(sizeRGB);
    h_imagegray = (unsigned char*)malloc(sizeGray);
    cudaMalloc((void**)&d_image,sizeRGB);
    cudaMalloc((void**)&d_imagegray,sizeGray);

    h_image = image.data;

    dim3 dimBlock(blockSize,blockSize,1);
    dim3 dimTrheads(ceil(s.width/float(blockSize)),ceil(s.height/float(blockSize)),1);
    imgGray<<<dimBlock,dimTrheads>>>(d_image,d_imagegray,s.width,s.height);
    cudaDeviceSynchronize();
    cudaMemcpy(h_imagegray,d_imagegray,sizeGray,cudaMemcpyDeviceToHost);

    Mat imageGray;
    imageGray.create(height,width,CV_8UC1);
    imageGray.data = h_imagegray;

    namedWindow("Gray image", WINDOW_AUTOSIZE);
    imshow(argv[1],image);
    return 0;
}

