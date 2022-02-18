#ifndef POSEIDON128_H
#define POSEIDON128_H

#include "blst.h"

#define WIDTH 3
#define NB_FULL_ROUNDS 8
#define NB_PARTIAL_ROUNDS 56
#define BATCH_SIZE 3
#define PARTIAL_ROUND_IDX_SBOX 2
#define NB_TMP_VAR ((BATCH_SIZE - 1))
#define NB_BATCHED_PARTIAL_ROUNDS ((NB_PARTIAL_ROUNDS / BATCH_SIZE))
#define NB_UNBATCHED_PARTIAL_ROUNDS ((NB_PARTIAL_ROUNDS % BATCH_SIZE))
#define NB_CONSTANTS_FULL_ROUNDS ((NB_FULL_ROUNDS * WIDTH))
#define NB_CONSTANTS_UNBATCHED_PARTIAL_ROUNDS                                  \
  ((NB_UNBATCHED_PARTIAL_ROUNDS * WIDTH))
#define NB_CONSTANTS_PER_BATCHED_PARTIAL_ROUNDS_TMP_VAR                        \
  (NB_TMP_VAR + WIDTH * NB_TMP_VAR + (NB_TMP_VAR * (NB_TMP_VAR - 1) / 2))
#define NB_CONSTANTS_PER_BATCHED_PARTIAL_ROUNDS_FINAL_COMPUTATION              \
  ((NB_TMP_VAR + WIDTH) * WIDTH + WIDTH)
#define NB_CONSTANTS_PER_BATCHED_PARTIAL_ROUNDS                                \
  ((NB_CONSTANTS_PER_BATCHED_PARTIAL_ROUNDS_TMP_VAR +                          \
    NB_CONSTANTS_PER_BATCHED_PARTIAL_ROUNDS_FINAL_COMPUTATION))
#define NB_CONSTANTS_BATCHED_PARTIAL_ROUNDS                                    \
  ((NB_BATCHED_PARTIAL_ROUNDS * NB_CONSTANTS_PER_BATCHED_PARTIAL_ROUNDS))
// We add WIDTH zero's at the end
#define NB_CONSTANTS                                                           \
  (NB_CONSTANTS_FULL_ROUNDS + NB_CONSTANTS_BATCHED_PARTIAL_ROUNDS +            \
   NB_CONSTANTS_UNBATCHED_PARTIAL_ROUNDS + WIDTH)

typedef struct poseidon128_ctxt_s {
  blst_fr s[WIDTH];
  int i_round_key;
} poseidon128_ctxt_t;

int poseidon128_constants_init(blst_fr *akr, blst_fr **mds, int ark_len,
                               int mds_nb_rows, int mds_nb_cols);
size_t poseidon128_ctxt_sizeof();
void poseidon128_init(poseidon128_ctxt_t *ctxt, blst_fr *a, blst_fr *b,
                      blst_fr *c);
void poseidon128_apply_perm(poseidon128_ctxt_t *ctxt);
void poseidon128_get_state(blst_fr *a, blst_fr *b, blst_fr *c,
                           poseidon128_ctxt_t *ctxt);
#endif
