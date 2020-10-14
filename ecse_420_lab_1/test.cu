#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void hi() {
  printf("Hello from the gpu!\n");
}

void sayhi() {
  hi <<<1, 1>>> ();
}