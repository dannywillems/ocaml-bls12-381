#include <benchmark/benchmark.h>
#include "blst.h"
#include <stdlib.h>

void generate_random_fr(blst_fr *output) {
  blst_scalar output_scalar;
  byte output_bytes[32] = {0};
  for (int i = 0; i < 32; i++) {
    output_bytes[i] = rand() % 256;
  }
  blst_scalar_from_lendian(&output_scalar, output_bytes);
  blst_fr_from_scalar(output, &output_scalar);
}

void bench_addition(benchmark::State& state) {
  blst_fr a, b, result;

  generate_random_fr(&a);
  generate_random_fr(&b);

  for(auto _: state) {
    blst_fr_add(&result, &a, &b);
  }
}

void bench_multiplication(benchmark::State& state) {
  blst_fr a, b, result;

  generate_random_fr(&a);
  generate_random_fr(&b);
  for(auto _: state) {
    blst_fr_mul(&result, &a, &b);
  }
}

void bench_substraction(benchmark::State& state) {
  blst_fr a, b, result;

  generate_random_fr(&a);
  generate_random_fr(&b);
  for(auto _: state) {
    blst_fr_sub(&result, &a, &b);
  }
}

void bench_negate(benchmark::State& state) {
  blst_fr a, result;

  generate_random_fr(&a);
  for(auto _: state) {
    blst_fr_cneg(&result, &a, true);
  }
}

void bench_square(benchmark::State& state) {
  blst_fr a, result;

  generate_random_fr(&a);
  for(auto _: state) {
    blst_fr_sqr(&result, &a);
  }
}

void bench_inverse(benchmark::State& state) {
  blst_fr a, result;

  generate_random_fr(&a);
  for(auto _: state) {
    blst_fr_eucl_inverse(&result, &a);
  }
}


BENCHMARK(bench_addition);
BENCHMARK(bench_multiplication);
BENCHMARK(bench_substraction);
BENCHMARK(bench_negate);
BENCHMARK(bench_square);
BENCHMARK(bench_inverse);
BENCHMARK_MAIN();
