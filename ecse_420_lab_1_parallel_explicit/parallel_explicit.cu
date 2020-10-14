#include <stdio.h>
#include <stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define AND 0
#define OR 1
#define NAND 2
#define NOR 3
#define XOR 4
#define XNOR 5

__device__ int gate_gpu(int a, int b, int type) {
  switch (type) {
  case AND: return a & b;
  case OR: return a | b;
  case NAND: return !(a & b);
  case NOR: return !(a | b);
  case XOR: return a ^ b;
  case XNOR: return !(a ^ b);
  default: return -1;
  }
}

__global__ void simulate_gates_gpu(int* output, const int* input, int len) {
  int i = blockIdx.x;
  if (i >= len)
    return;
  output[i] = gate_gpu(input[i * 3], input[i * 3 + 1], input[i * 3 + 2]);
}

void simulate_gates(int* output, const int* input, int len) {
  int * d_input, * d_output;
  cudaMalloc(&d_input, (long long)3 * len * sizeof(int));
  cudaMalloc(&d_output,  len * sizeof(int));

  // record time taken to transfer data to device and run the kernel.
  //start timer
  float memsettime;
  cudaEvent_t start, stop;
  cudaEventCreate(&start); cudaEventCreate(&stop);
  cudaEventRecord(start, 0);

  cudaMemcpy(d_input, input, (long long)3 * len * sizeof(int), cudaMemcpyHostToDevice);
  simulate_gates_gpu<<<len,1>>>(d_output, d_input, len);

  //stop timer
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&memsettime, start, stop);
  printf("Kernel execution time: %f\n", memsettime);
  cudaEventDestroy(start); cudaEventDestroy(stop);

  cudaMemcpy(output, d_output, len * sizeof(int), cudaMemcpyDeviceToHost);
  cudaFree(d_input);
  cudaFree(d_output);
}

int main(int argc, char* argv[]) {
  if (argc != 4) {
    printf("Invalid number of program arguments");
    exit(EXIT_FAILURE);
  }

  char* input_path = argv[1];
  int input_len = atoi(argv[2]);
  char* output_path = argv[3];
  if (input_len <= 0) {
    printf("Invalid input length");
    exit(EXIT_FAILURE);
  }


  int* inputs = (int*)malloc((long long)3 * input_len * sizeof(int));
  int* outputs = (int*)malloc(input_len * sizeof(int));
  if (inputs == NULL || outputs == NULL) {
    printf("Could not allocate memory for gate simulation");
    exit(EXIT_FAILURE);
  }

  FILE* input = fopen(input_path, "r");
  FILE* output = fopen(output_path, "w");
  if (input == NULL || output == NULL) {
    printf("Could not open files for reading or writing");
    exit(EXIT_FAILURE);
  }

  for (int i = 0; i < input_len; i++) {
    char buf[7];
    fgets(buf, 7, input);
    inputs[i * 3] = (int)(buf[0] - '0');
    inputs[i * 3 + 1] = (int)(buf[2] - '0');
    inputs[i * 3 + 2] = (int)(buf[4] - '0');
  }

  simulate_gates(outputs, inputs, input_len);

  for (int i = 0; i < input_len; i++) {
    char line[] = {outputs[i] + '0', '\n', '\0'};
    fputs(line, output);
  }

  free(inputs);
  free(outputs);

  fclose(input);
  fclose(output);
  
  return 0;
}
