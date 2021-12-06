#ifndef FFT_H
#define FFT_H

#include "blst.h"
#include "caml_bls12_381_stubs.h"
#include <caml/custom.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <stdlib.h>
#include <string.h>

// H: domain_size = polynomial degree
// Implementation with side effect. The FFT will be inplace, i.e. the array is
// going to be modified.
void fft_fr_inplace(value coefficients, value domain, int log_domain_size);

void mul_map_fr_inplace(value coefficients, value factor, int log_domain_size);

void fft_g1_inplace(value coefficients, value domain, int log_domain_size);

void mul_map_g1_inplace(value coefficients, value factor, int log_domain_size);

void fft_g2_inplace(value coefficients, value domain, int log_domain_size);

void mul_map_g2_inplace(value coefficients, value factor, int log_domain_size);

#endif
