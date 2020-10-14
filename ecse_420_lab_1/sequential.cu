#include <stdio.h>
#include <stdlib.h>

#define AND 0
#define OR 1
#define NAND 2
#define NOR 3
#define XOR 4
#define XNOR 5

int gate(int a, int b, int type) {
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

void simulate_gates(int* output, const int* input, int len) {
  for (int i = 0; i < len; i++) {
    output[i] = gate(input[i * 3], input[i * 3 + 1], input[i * 3 + 2]);
  }
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
