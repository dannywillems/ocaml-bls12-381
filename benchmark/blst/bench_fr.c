#include "blst.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <chrono>

#define NB_RUN 10000000

void generate_random_fr(blst_fr *output) {
  blst_scalar *output_scalar = (blst_scalar *)malloc(sizeof(blst_scalar));
  byte output_bytes[32] = {0};
  for (int i = 0; i < 32; i++) {
    output_bytes[i] = rand() % 256;
  }
  blst_scalar_from_lendian(output_scalar, output_bytes);
  blst_fr_from_scalar(output, output_scalar);
  free(output_scalar);
}

void bench_addition(void) {
  blst_fr *a = (blst_fr *)malloc(sizeof(blst_fr));
  blst_fr *b = (blst_fr *)malloc(sizeof(blst_fr));

  long int total_elapsed;

  for (int i = 0; i < NB_RUN; i++) {
    generate_random_fr(a);
    generate_random_fr(b);

    auto begin = std::chrono::high_resolution_clock::now();
    blst_fr *result = (blst_fr *)malloc(sizeof(blst_fr));
    blst_fr_add(result, a, b);
    auto end = std::chrono::high_resolution_clock::now();
    free(result);
    auto elapsed =
        std::chrono::duration_cast<std::chrono::nanoseconds>(end - begin);
    total_elapsed += elapsed.count();
  }
  free(a);
  free(b);

  printf("Fr addition: %ld ns\n", total_elapsed / NB_RUN);
}

void bench_multiplication(void) {
  blst_fr *a = (blst_fr *)malloc(sizeof(blst_fr));
  blst_fr *b = (blst_fr *)malloc(sizeof(blst_fr));

  long int total_elapsed;

  for (int i = 0; i < NB_RUN; i++) {
    generate_random_fr(a);
    generate_random_fr(b);

    auto begin = std::chrono::high_resolution_clock::now();
    blst_fr *result = (blst_fr *)malloc(sizeof(blst_fr));
    blst_fr_mul(result, a, b);
    auto end = std::chrono::high_resolution_clock::now();
    free(result);
    auto elapsed =
        std::chrono::duration_cast<std::chrono::nanoseconds>(end - begin);
    total_elapsed += elapsed.count();
  }
  free(a);
  free(b);

  printf("Fr multiplication: %ld ns\n", total_elapsed / NB_RUN);
}

void bench_substraction(void) {
  blst_fr *a = (blst_fr *)malloc(sizeof(blst_fr));
  blst_fr *b = (blst_fr *)malloc(sizeof(blst_fr));

  long int total_elapsed;

  for (int i = 0; i < NB_RUN; i++) {
    generate_random_fr(a);
    generate_random_fr(b);

    auto begin = std::chrono::high_resolution_clock::now();
    blst_fr *result = (blst_fr *)malloc(sizeof(blst_fr));
    blst_fr_sub(result, a, b);
    auto end = std::chrono::high_resolution_clock::now();
    free(result);
    auto elapsed =
        std::chrono::duration_cast<std::chrono::nanoseconds>(end - begin);
    total_elapsed += elapsed.count();
  }
  free(a);
  free(b);

  printf("Fr substraction: %ld ns\n", total_elapsed / NB_RUN);
}

int main(void) {
  srand(time(NULL));
  bench_addition();
  bench_multiplication();
  bench_substraction();
}
