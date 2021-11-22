#ifndef FFT_H
#define FFT_H

#include "blst.h"
#include <caml/custom.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <stdlib.h>
#include <string.h>

#define Caml_blst_fr_val(v) (*((blst_fr **)Data_custom_val(v)))

#define Caml_blst_g1_val(v) (*((blst_p1 **)Data_custom_val(v)))

#define Caml_blst_g2_val(v) (*((blst_p2 **)Data_custom_val(v)))

#define Caml_blst_fr_val_k(v, k) Caml_blst_fr_val(Field(v, k))

#define Caml_blst_g1_val_k(v, k) Caml_blst_g1_val(Field(v, k))

#define Caml_blst_g2_val_k(v, k) Caml_blst_g2_val(Field(v, k))

// H: domain_size = polynomial degree
// Implementation with side effect. The FFT will be inplace, i.e. the array is
// going to be modified.
void ocaml_bls12_381_fft_fr_inplace(value coefficients, value domain,
                                    int log_domain_size);

void ocaml_bls12_381_mul_map_fr_inplace(value coefficients, value factor,
                                        int log_domain_size);

void ocaml_bls12_381_fft_g1_inplace(value coefficients, value domain,
                                    int log_domain_size);

void ocaml_bls12_381_mul_map_g1_inplace(value coefficients, value factor,
                                        int log_domain_size);

void ocaml_bls12_381_fft_g2_inplace(value coefficients, value domain,
                                    int log_domain_size);

void ocaml_bls12_381_mul_map_g2_inplace(value coefficients, value factor,
                                        int log_domain_size);

#endif
