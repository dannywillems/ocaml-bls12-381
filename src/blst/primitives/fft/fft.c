#include "fft.h"
#include <caml/custom.h>

// IMPROVEME: can be improve it with lookups?
int ocaml_bls12_381_bitreverse(int n, int l) {
  int r = 0;
  while (l-- > 0) {
    r = (r << 1) | (n & 1);
    n = n >> 1;
  }
  return r;
}

// Fr
void ocaml_bls12_381_reorg_fr_coefficients(int n, int logn, value coefficients,
                                           blst_fr *buffer) {
  for (int i = 0; i < n; i++) {
    int reverse_i = ocaml_bls12_381_bitreverse(i, logn);
    if (i < reverse_i) {
      memcpy(buffer, Caml_blst_fr_val_k(coefficients, i), sizeof(blst_fr));
      memcpy(Caml_blst_fr_val_k(coefficients, i),
             Caml_blst_fr_val_k(coefficients, reverse_i), sizeof(blst_fr));
      memcpy(Caml_blst_fr_val_k(coefficients, reverse_i), buffer,
             sizeof(blst_fr));
    }
  }
}

void ocaml_bls12_381_fft_fr_inplace(value coefficients, value domain,
                                    int log_domain_size) {
  // FIXME: add a check on the domain_size to avoid ariane crash
  blst_fr *buffer = (blst_fr *)calloc(1, sizeof(blst_fr));

  int domain_size = 1 << log_domain_size;
  int m = 1;
  ocaml_bls12_381_reorg_fr_coefficients(domain_size, log_domain_size,
                                        coefficients, buffer);

  for (int i = 0; i < log_domain_size; i++) {
    int exponent = domain_size / (2 * m);
    int k = 0;
    while (k < domain_size) {
      for (int j = 0; j < m; j++) {
        blst_fr_mul(buffer, Caml_blst_fr_val_k(coefficients, k + j + m),
                    Caml_blst_fr_val_k(domain, exponent * j));
        blst_fr_sub(Caml_blst_fr_val_k(coefficients, k + j + m),
                    Caml_blst_fr_val_k(coefficients, k + j), buffer);
        blst_fr_add(Caml_blst_fr_val_k(coefficients, k + j),
                    Caml_blst_fr_val_k(coefficients, k + j), buffer);
      }
      k = k + (2 * m);
    }
    m = 2 * m;
  }
  free(buffer);
}

void ocaml_bls12_381_mul_map_fr_inplace(value coefficients, value factor,
                                        int domain_size) {
  for (int i = 0; i < domain_size; i++) {
    blst_fr_mul(Caml_blst_fr_val_k(coefficients, i),
                Caml_blst_fr_val_k(coefficients, i), Caml_blst_fr_val(factor));
  }
}

// G1
void ocaml_bls12_381_reorg_g1_coefficients(int n, int logn, value coefficients,
                                           blst_p1 *buffer) {
  for (int i = 0; i < n; i++) {
    int reverse_i = ocaml_bls12_381_bitreverse(i, logn);
    if (i < reverse_i) {
      memcpy(buffer, Caml_blst_g1_val_k(coefficients, i), sizeof(blst_p1));
      memcpy(Caml_blst_g1_val_k(coefficients, i),
             Caml_blst_g1_val_k(coefficients, reverse_i), sizeof(blst_p1));
      memcpy(Caml_blst_g1_val_k(coefficients, reverse_i), buffer,
             sizeof(blst_p1));
    }
  }
}

void ocaml_bls12_381_fft_g1_inplace(value coefficients, value domain,
                                    int log_domain_size) {
  // FIXME: add a check on the domain_size to avoid ariane crash
  blst_p1 *buffer = (blst_p1 *)calloc(1, sizeof(blst_p1));
  blst_p1 *buffer_neg = (blst_p1 *)calloc(1, sizeof(blst_p1));
  blst_scalar *scalar = (blst_scalar *)calloc(1, sizeof(blst_scalar));
  byte le_scalar[32];

  int domain_size = 1 << log_domain_size;
  int m = 1;
  ocaml_bls12_381_reorg_g1_coefficients(domain_size, log_domain_size,
                                        coefficients, buffer);

  for (int i = 0; i < log_domain_size; i++) {
    int exponent = domain_size / (2 * m);
    int k = 0;
    while (k < domain_size) {
      for (int j = 0; j < m; j++) {
        blst_scalar_from_fr(scalar, Caml_blst_fr_val_k(domain, exponent * j));
        blst_lendian_from_scalar(le_scalar, scalar);
        blst_p1_mult(buffer, Caml_blst_g1_val_k(coefficients, k + j + m),
                     le_scalar, 256);

        memcpy(buffer_neg, buffer, sizeof(blst_p1));
        blst_p1_cneg(buffer_neg, 1);
        blst_p1_add_or_double(Caml_blst_g1_val_k(coefficients, k + j + m),
                              Caml_blst_g1_val_k(coefficients, k + j),
                              buffer_neg);

        blst_p1_add_or_double(Caml_blst_g1_val_k(coefficients, k + j),
                              Caml_blst_g1_val_k(coefficients, k + j), buffer);
      }
      k = k + (2 * m);
    }
    m = 2 * m;
  }
  free(buffer);
  free(buffer_neg);
  free(scalar);
}

void ocaml_bls12_381_mul_map_g1_inplace(value coefficients, value factor,
                                        int domain_size) {
  blst_scalar *scalar = (blst_scalar *)calloc(1, sizeof(blst_scalar));
  byte le_scalar[32];

  blst_scalar_from_fr(scalar, Caml_blst_fr_val(factor));
  blst_lendian_from_scalar(le_scalar, scalar);

  for (int i = 0; i < domain_size; i++) {
    blst_p1_mult(Caml_blst_g1_val_k(coefficients, i),
                 Caml_blst_g1_val_k(coefficients, i), le_scalar, 256);
  }
  free(scalar);
}

// G1
void ocaml_bls12_381_reorg_g2_coefficients(int n, int logn, value coefficients,
                                           blst_p2 *buffer) {
  for (int i = 0; i < n; i++) {
    int reverse_i = ocaml_bls12_381_bitreverse(i, logn);
    if (i < reverse_i) {
      memcpy(buffer, Caml_blst_g2_val_k(coefficients, i), sizeof(blst_p2));
      memcpy(Caml_blst_g2_val_k(coefficients, i),
             Caml_blst_g2_val_k(coefficients, reverse_i), sizeof(blst_p2));
      memcpy(Caml_blst_g2_val_k(coefficients, reverse_i), buffer,
             sizeof(blst_p2));
    }
  }
}

void ocaml_bls12_381_fft_g2_inplace(value coefficients, value domain,
                                    int log_domain_size) {
  // FIXME: add a check on the domain_size to avoid ariane crash
  blst_p2 *buffer = (blst_p2 *)calloc(1, sizeof(blst_p2));
  blst_p2 *buffer_neg = (blst_p2 *)calloc(1, sizeof(blst_p2));
  blst_scalar *scalar = (blst_scalar *)calloc(1, sizeof(blst_scalar));
  byte le_scalar[32];

  int domain_size = 1 << log_domain_size;
  int m = 1;
  ocaml_bls12_381_reorg_g2_coefficients(domain_size, log_domain_size,
                                        coefficients, buffer);

  for (int i = 0; i < log_domain_size; i++) {
    int exponent = domain_size / (2 * m);
    int k = 0;
    while (k < domain_size) {
      for (int j = 0; j < m; j++) {
        blst_scalar_from_fr(scalar, Caml_blst_fr_val_k(domain, exponent * j));
        blst_lendian_from_scalar(le_scalar, scalar);
        blst_p2_mult(buffer, Caml_blst_g2_val_k(coefficients, k + j + m),
                     le_scalar, 256);

        memcpy(buffer_neg, buffer, sizeof(blst_p2));
        blst_p2_cneg(buffer_neg, 1);
        blst_p2_add_or_double(Caml_blst_g2_val_k(coefficients, k + j + m),
                              Caml_blst_g2_val_k(coefficients, k + j),
                              buffer_neg);

        blst_p2_add_or_double(Caml_blst_g2_val_k(coefficients, k + j),
                              Caml_blst_g2_val_k(coefficients, k + j), buffer);
      }
      k = k + (2 * m);
    }
    m = 2 * m;
  }
  free(buffer);
  free(buffer_neg);
  free(scalar);
}

void ocaml_bls12_381_mul_map_g2_inplace(value coefficients, value factor,
                                        int domain_size) {
  blst_scalar *scalar = (blst_scalar *)calloc(1, sizeof(blst_scalar));
  byte le_scalar[32];

  blst_scalar_from_fr(scalar, Caml_blst_fr_val(factor));
  blst_lendian_from_scalar(le_scalar, scalar);

  for (int i = 0; i < domain_size; i++) {
    blst_p2_mult(Caml_blst_g2_val_k(coefficients, i),
                 Caml_blst_g2_val_k(coefficients, i), le_scalar, 256);
  }
  free(scalar);
}
