

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <cassert>
#include <iostream>

using std::cout;

// CUDA kernel for vector addition
__global__ void vectorAdd(int* a, int* b, int* c, int N) {
	// Calculate global thread thread ID
	int tid = (blockDim.x * blockIdx.x) + threadIdx.x;

	// Boundary check
	if (tid < N) {
		c[tid] = a[tid] + b[tid];
	}
}

extern "C" __declspec(dllexport) void GETRANDOMARRAYSUM(int c[], int N ) {

	int *a, *b, *d;
	size_t bytes = N * sizeof(int);

	// Allocation memory for these pointers
	cudaMallocManaged(&a, bytes);
	cudaMallocManaged(&b, bytes);
	cudaMallocManaged(&d, bytes);

	// Get the device ID for prefetching calls
	int id = cudaGetDevice(&id);

	// Set some hints about the data and do some prefetching
	cudaMemPrefetchAsync(d, bytes, id);

	for (int i = 0; i < N; i++) {
		a[i] = i+1;
		b[i] = i+1;
	}

	// Pre-fetch 'a' and 'b' arrays to the specified device (GPU)
	cudaMemAdvise(a, bytes, cudaMemAdviseSetReadMostly, id);
	cudaMemAdvise(b, bytes, cudaMemAdviseSetReadMostly, id);
	cudaMemPrefetchAsync(a, bytes, id);
	cudaMemPrefetchAsync(b, bytes, id);

	// Threads per CTA (1024 threads per CTA)
	int BLOCK_SIZE = 1 << 10;

	// CTAs per Grid
	int GRID_SIZE = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;

	// Call CUDA kernel
	vectorAdd << <GRID_SIZE, BLOCK_SIZE >> > (a, b, d, N);

	cudaDeviceSynchronize();

	// Prefetch to the host (CPU)
	cudaMemPrefetchAsync(a, bytes, cudaCpuDeviceId);
	cudaMemPrefetchAsync(b, bytes, cudaCpuDeviceId);
	cudaMemPrefetchAsync(d, bytes, cudaCpuDeviceId);

	for (int i = 0; i < N; i++)
	{
		c[i] = a[i] + b[i];
	}


	// Free unified memory (same as memory allocated with cudaMalloc)
	cudaFree(a);
	cudaFree(b);
	cudaFree(d);

}