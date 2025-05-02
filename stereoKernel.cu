#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>
#include <limits.h>

// may need later
//  int diffThresh = windowWidth * windowWidth * 255 * 255;
//  double baseLine = 60.0;
//  double focalLength = 560.0;
//  double maxDisparity = 200;
//  double distance;

// minIntensity = (double)(left[row*cols+col]);
// maxIntensity = minIntensity;

__global__ void stereoKernel(unsigned char *left, unsigned char *right, unsigned char *disparity,
							 double maxDisparity, int rows, int cols)
{

	// compute the row and col of the pixel to be processed
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	int row = blockIdx.y * blockDim.y + threadIdx.y;

	// define search params
	int disparityStep = 2;
	int windowStep = 2;
	const int windowWidth = 13;
	const int halfWindow = (widnowWidth - 1) / 2;
	double contrastThreshold = 10;

	unsigned char leftPixel;
	unsigned char rightPixel;
	unsigned char centerPixel;
	int disp = 0;
	int sumSqDiff;
	int minSumSqDiff = (double)INT_MAX * (double)INT_MAX;
	double diff;
	double leftSumSqDiff;
	double leftDiff;
	int count = 0;

	// make sure the pixel is with the image border
	if (row < halfWindow || row > rows - halfWindow ||
		col < halfWindow || col > cols - halfWindow)
		return;

	/*
	// compute the contrast for the left window
	// if contrast too low return
	centerPixel = left[row * cols + col];
	leftSumSqDiff = 0.0;
	count = 0;

	// //compute the sums within the windows in each image
	for (int i = -halfWindow; i < halfwindow + 1; i = i + windowStep)
	{
		for (int j = -halfWindow; j < halfWindow + 1; j = j + windowStep)
		{
			count++;
			leftPixel = left[(row+i)*cols+(col+j)];
			leftDiff = (double) leftPixel -(double)centerPixel;
			leftSumSqDiff+= fabs(leftDiff);
		}
	}
	if(count == 0 || leftSumSqDiff/count < contrastthreshold) return;
*/

	//-------11:21-------// //16:57//
	for (int k = 0; k < maxDisparity; k = k + disparityStep)
	{
		sumSqDiff = 0.0;
		// compute the sums whithin the windows in each image
		for (int i = -halfWindow; i < halfWindow + 1; i = i + windowStep)
		{
			for (int j = -halfWindow; j < halfWindow + 1; j = j + windowStep)
			{
				if (row + i < rows && col + j < cols &&
					0 <= col + j - k && col + j - k < cols)
				{
					leftPixel = left[(row + i) * cols + (col + j)];
					rightPixel = right[(row + i) * cols + (col + j - k)];
					diff = (double)leftPixel - (double)rightPixel;
					sumSqDiff += fabs(diff);
				}
			}
		}

		// compute min sum square diff
		if (sumSqDiff < minSumSqDiff)
		{
			minSumSqDiff = sumSqDiff;
			disp = k;
		}
	}

	//-------13:10------//
	// if(disp > 0){
	disparity[row * cols + col] = (unsigned char)(disp);
	// }else{
	// disparity[row * cols + col] = (unsigned char)(0);
}

//-----------probs don't need------------//
// 	// compute the sumSqDiff of each shifted window
// 	for (int k = 0; k < maxDisparity; k++)
// 	{
// 		sumSqDiff = 0;

// 		// compute the sume w/i the windows in each image
// 		for (int i = -halfWindow; i < halfWindow + 1; i++)
// 		{
// 			for (int j = -halfWindow; j < halfWindow + 1; j++)
// 			{
// 				leftPixel = left[(row + i) * cols + (col + j)];
// 				rightPixel = right[(row + i) * cols + (col + j - k)];
// 				diff = leftPixel - rightPixel;
// 				sumSqDiff += diff * diff;
// 			}
// 		}
// 		// compute min sumSqDiff
// 		if (sumSqDiff < minSumSqDiff)
// 		{
// 			minSumSqDiff = sumSqDiff;
// 			disparity = k;
// 		}
// 	}
// 	// if valid disp, compute dist and save
// 	if (disparity > 0 && sumSqDiff < diffThresh)
// 	{
// 		distance = baseLine * focalLength / disparity;
// 		if (distance < maxDistance)
// 			depth[row * cols + col] = (unsigned char)(255.0 * distance / maxDistance);
// 		else
// 			depth[row * cols + col] = 255;
// 	}

// 	else
// 	{
// 		depth[row * cols + col] = 255;
// 	}
// }
