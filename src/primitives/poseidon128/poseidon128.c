#include "poseidon128.h"
#include <stdlib.h>
#include <string.h>

blst_fr POSEIDON128_ARK[NB_CONSTANTS];
blst_fr POSEIDON128_MDS[WIDTH][WIDTH];

size_t poseidon128_ctxt_sizeof() { return sizeof(poseidon128_ctxt_t); }

int poseidon128_constants_init(blst_fr *ark, blst_fr **mds, int ark_len,
                               int mds_nb_rows, int mds_nb_cols) {

  if (NB_CONSTANTS != ark_len || mds_nb_rows != WIDTH || mds_nb_cols != WIDTH) {
    return 1;
  }

  for (int i = 0; i < NB_CONSTANTS; i++) {
    memcpy(POSEIDON128_ARK + i, ark + i, sizeof(blst_fr));
  }

  for (int i = 0; i < WIDTH; i++) {
    for (int j = 0; j < WIDTH; j++) {
      memcpy(&POSEIDON128_MDS[i][j], &mds[i][j], sizeof(blst_fr));
    }
  }
  return 0;
}

void poseidon128_init(poseidon128_ctxt_t *ctxt, blst_fr *a, blst_fr *b,
                      blst_fr *c) {
  memcpy(&ctxt->s[0], a, sizeof(blst_fr));
  memcpy(&ctxt->s[1], b, sizeof(blst_fr));
  memcpy(&ctxt->s[2], c, sizeof(blst_fr));
}

void poseidon128_apply_sbox(poseidon128_ctxt_t *ctxt, int full) {
  blst_fr buffer;
  int begin_idx = full ? 0 : PARTIAL_ROUND_IDX_SBOX;
  int end_idx = full ? WIDTH : PARTIAL_ROUND_IDX_SBOX + 1;
  for (int i = begin_idx; i < end_idx; i++) {
    // x * (x^2)^2
    blst_fr_sqr(&buffer, &ctxt->s[i]);
    blst_fr_sqr(&buffer, &buffer);
    blst_fr_mul(&ctxt->s[i], &buffer, &ctxt->s[i]);
  }
}

void poseidon128_apply_matrix_multiplication(poseidon128_ctxt_t *ctxt) {
  blst_fr buffer;
  blst_fr res[WIDTH];
  for (int i = 0; i < WIDTH; i++) {
    for (int j = 0; j < WIDTH; j++) {
      if (j == 0) {
        blst_fr_mul(res + i, &POSEIDON128_MDS[i][j], &ctxt->s[j]);
      } else {
        blst_fr_mul(&buffer, &POSEIDON128_MDS[i][j], &ctxt->s[j]);
        blst_fr_add(res + i, res + i, &buffer);
      }
    }
  }
  for (int i = 0; i < WIDTH; i++) {
    memcpy(&ctxt->s[i], res + i, sizeof(blst_fr));
  }
}

blst_fr *poseidon128_get_next_round_key(poseidon128_ctxt_t *ctxt) {
  return (POSEIDON128_ARK + ctxt->i_round_key++);
}

void poseidon128_apply_cst(poseidon128_ctxt_t *ctxt) {
  for (int i = 0; i < WIDTH; i++) {
    blst_fr_add(&ctxt->s[i], &ctxt->s[i], poseidon128_get_next_round_key(ctxt));
  }
}

void poseidon128_apply_batched_partial_round(poseidon128_ctxt_t *ctxt) {
  blst_fr buffer;
  blst_fr intermediary_state[WIDTH + NB_TMP_VAR];
  for (int i = 0; i < WIDTH; i++) {
    memcpy(intermediary_state + i, &ctxt->s[i], sizeof(blst_fr));
  }

  // Apply sbox on the last element of the state
  blst_fr_sqr(&buffer, intermediary_state + WIDTH - 1);
  blst_fr_sqr(&buffer, &buffer);
  blst_fr_mul(intermediary_state + WIDTH - 1, &buffer,
              intermediary_state + WIDTH - 1);

  // Computing the temporary variables
  for (int i = 0; i < NB_TMP_VAR; i++) {
    // we start with the first element
    blst_fr_mul(intermediary_state + WIDTH + i,
                poseidon128_get_next_round_key(ctxt), intermediary_state);
    for (int j = 1; j < WIDTH + i; j++) {
      blst_fr_mul(&buffer, poseidon128_get_next_round_key(ctxt),
                  intermediary_state + j);
      blst_fr_add(intermediary_state + WIDTH + i,
                  intermediary_state + WIDTH + i, &buffer);
    }
    // We add the constant
    blst_fr_add(intermediary_state + WIDTH + i, intermediary_state + WIDTH + i,
                poseidon128_get_next_round_key(ctxt));

    // Applying sbox
    blst_fr_sqr(&buffer, intermediary_state + i + WIDTH);
    blst_fr_sqr(&buffer, &buffer);
    blst_fr_mul(intermediary_state + i + WIDTH, &buffer,
                intermediary_state + i + WIDTH);
  }

  // Computing the final state
  for (int i = 0; i < WIDTH; i++) {
    blst_fr_mul(&ctxt->s[i], poseidon128_get_next_round_key(ctxt),
                intermediary_state);
    for (int j = 1; j < WIDTH + NB_TMP_VAR; j++) {
      blst_fr_mul(&buffer, intermediary_state + j,
                  poseidon128_get_next_round_key(ctxt));
      blst_fr_add(&ctxt->s[i], &buffer, &ctxt->s[i]);
    }
    blst_fr_add(&ctxt->s[i], &ctxt->s[i], poseidon128_get_next_round_key(ctxt));
  }
}

void poseidon128_apply_perm(poseidon128_ctxt_t *ctxt) {
  ctxt->i_round_key = 0;
  poseidon128_apply_cst(ctxt);
  for (int i = 0; i < NB_FULL_ROUNDS / 2; i++) {
    poseidon128_apply_sbox(ctxt, 1);
    poseidon128_apply_matrix_multiplication(ctxt);
    poseidon128_apply_cst(ctxt);
  }
  for (int i = 0; i < NB_BATCHED_PARTIAL_ROUNDS; i++) {
    poseidon128_apply_batched_partial_round(ctxt);
  }
  for (int i = 0; i < NB_UNBATCHED_PARTIAL_ROUNDS; i++) {
    poseidon128_apply_sbox(ctxt, 0);
    poseidon128_apply_matrix_multiplication(ctxt);
    poseidon128_apply_cst(ctxt);
  }
  for (int i = 0; i < NB_FULL_ROUNDS / 2; i++) {
    poseidon128_apply_sbox(ctxt, 1);
    poseidon128_apply_matrix_multiplication(ctxt);
    poseidon128_apply_cst(ctxt);
  }
}

void poseidon128_get_state(blst_fr *a, blst_fr *b, blst_fr *c,
                           poseidon128_ctxt_t *ctxt) {
  memcpy(a, &ctxt->s[0], sizeof(blst_fr));
  memcpy(b, &ctxt->s[1], sizeof(blst_fr));
  memcpy(c, &ctxt->s[2], sizeof(blst_fr));
}
