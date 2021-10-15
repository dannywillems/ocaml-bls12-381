#ifndef FFT_H
#define FFT_H

#include "blst.h"
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <stdlib.h>
#include <string.h>
#include "ocaml_integers.h"

// From ocaml-ctypes:
// https://github.com/ocamllabs/ocaml-ctypes/blob/9048ac78b885cc3debeeb020c56ea91f459a4d33/src/ctypes/ctypes_primitives.h#L110
#if SIZE_MAX == UINT16_MAX
#define ctypes_size_t_val Uint16_val
#define ctypes_copy_size_t Integers_val_uint16
#elif SIZE_MAX == UINT32_MAX
#define ctypes_size_t_val Uint32_val
#define ctypes_copy_size_t integers_copy_uint32
#elif SIZE_MAX == UINT64_MAX
#define ctypes_size_t_val Uint64_val
#define ctypes_copy_size_t integers_copy_uint64
#else
#error "No suitable OCaml type available for representing size_t values"
#endif


int bitreverse(int, int);

#define Blst_fr_val(v) (*((blst_fr **)Data_custom_val(v)))

#define Blst_g1_val(v) (*((blst_p1 **)Data_custom_val(v)))

#define Blst_g2_val(v) (*((blst_p2 **)Data_custom_val(v)))

#define Fr_val_k(v, k) Blst_fr_val(Field(v, k))

#define G1_val_k(v, k) Blst_g1_val(Field(v, k))

#define G2_val_k(v, k) Blst_g2_val(Field(v, k))

// H: domain_size = polynomial degree
// Implementation with side effect. The FFT will be inplace, i.e. the array is
// going to be modified.
void fft_fr_inplace(value coefficients, value domain, int log_domain_size);

void mul_map_fr_inplace(value coefficients, value factor, int log_domain_size);

void fft_g1_inplace(value coefficients, value domain, int log_domain_size);

void mul_map_g1_inplace(value coefficients, value factor, int log_domain_size);

void fft_g2_inplace(value coefficients, value domain, int log_domain_size);

void mul_map_g2_inplace(value coefficients, value factor, int log_domain_size);


// Fr
#define Blst_fr_array_val(v) (*((blst_fr **)Data_custom_val(v)))

static void finalize_free_fr_array(value v) { free(Blst_fr_array_val(v)); }

static struct custom_operations blst_fr_array_ops = {"blst_fr_array",
  finalize_free_fr_array,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default,
  custom_fixed_length_default};

#endif
