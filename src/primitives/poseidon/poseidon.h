#ifndef POSEIDON_H
#define POSEIDON_H

#include "blst.h"
#include <stdlib.h>
#include <string.h>

typedef struct poseidon_ctxt_s {
  int i_round_key;
  int nb_partial_rounds;
  int nb_full_rounds;
  int batch_size;
  int width;
  int partial_round_idx_sbox;
  blst_fr *ark;
  blst_fr **mds;
  blst_fr *s;
} poseidon_ctxt_t;

// size_t poseidon_ctxt_sizeof();
int poseidon_compute_number_of_constants(poseidon_ctxt_t *ctxt);
void poseidon_init(poseidon_ctxt_t *ctxt, blst_fr *inputs);
void poseidon_apply_perm(poseidon_ctxt_t *ctxt);
void poseidon_get_state(blst_fr *buffer, poseidon_ctxt_t *ctxt);

#endif
