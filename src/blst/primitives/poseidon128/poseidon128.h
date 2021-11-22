#ifndef POSEIDON128_H
#define POSEIDON128_H

#include "blst.h"

#define WIDTH 3
#define NB_FULL_ROUNDS 8
#define NB_PARTIAL_ROUNDS 58
#define PARTIAL_ROUND_IDX_SBOX 0
#define NB_CONSTANTS ((NB_FULL_ROUNDS + NB_PARTIAL_ROUNDS) * 3)

typedef struct ocaml_bls12_381_poseidon128_ctxt_s {
  blst_fr s[WIDTH];
  int i_round_key;
} ocaml_bls12_381_poseidon128_ctxt_t;

void ocaml_bls12_381_poseidon128_constants_init(void);
void ocaml_bls12_381_poseidon128_finalize(void);
void ocaml_bls12_381_poseidon128_init(ocaml_bls12_381_poseidon128_ctxt_t *ctxt,
                                      blst_fr *a, blst_fr *b, blst_fr *c);
void ocaml_bls12_381_poseidon128_apply_perm(
    ocaml_bls12_381_poseidon128_ctxt_t *ctxt);
void ocaml_bls12_381_poseidon128_get_state(
    blst_fr *a, blst_fr *b, blst_fr *c,
    ocaml_bls12_381_poseidon128_ctxt_t *ctxt);
#endif
