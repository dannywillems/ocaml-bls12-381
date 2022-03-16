#include "poseidon.h"
#include <stdio.h>

int poseidon_compute_number_of_constants(poseidon_ctxt_t *ctxt) {
  int nb_tmp_var = ctxt->batch_size - 1;
  int nb_batched_partial_rounds = ctxt->nb_partial_rounds / ctxt->batch_size;
  int nb_unbatched_partial_rounds = ctxt->nb_partial_rounds % ctxt->batch_size;
  int nb_constants_full_rounds = ctxt->nb_full_rounds * ctxt->width;
  int nb_constants_unbatched_partial_rounds =
      nb_unbatched_partial_rounds * ctxt->width;
  int nb_constants_per_batched_partial_rounds_tmp_var =
      nb_tmp_var + ctxt->width * nb_tmp_var +
      (nb_tmp_var * (nb_tmp_var - 1) / 2);
  int nb_constants_per_batched_partial_rounds_final_computation =
      (nb_tmp_var + ctxt->width) * ctxt->width + ctxt->width;
  int nb_constants_per_batched_partial_rounds =
      nb_constants_per_batched_partial_rounds_tmp_var +
      nb_constants_per_batched_partial_rounds_final_computation;
  int nb_constants_batched_partial_rounds =
      nb_batched_partial_rounds * nb_constants_per_batched_partial_rounds;
  // we add width zero's at the end
  int nb_constants = nb_constants_full_rounds +
                     nb_constants_batched_partial_rounds +
                     nb_constants_unbatched_partial_rounds + ctxt->width;
  return (nb_constants);
}

void poseidon_apply_sbox(poseidon_ctxt_t *ctxt, int full) {
  blst_fr buffer;
  int begin_idx = full ? 0 : ctxt->partial_round_idx_sbox;
  int end_idx = full ? ctxt->width : ctxt->partial_round_idx_sbox + 1;
  for (int i = begin_idx; i < end_idx; i++) {
    // x * (x^2)^2
    blst_fr_sqr(&buffer, &ctxt->s[i]);
    blst_fr_sqr(&buffer, &buffer);
    blst_fr_mul(&ctxt->s[i], &buffer, &ctxt->s[i]);
  }
}

void poseidon_apply_matrix_multiplication(poseidon_ctxt_t *ctxt) {
  blst_fr buffer;
  blst_fr res[ctxt->width];
  for (int i = 0; i < ctxt->width; i++) {
    for (int j = 0; j < ctxt->width; j++) {
      if (j == 0) {
        blst_fr_mul(res + i, &ctxt->mds[i][j], &ctxt->s[j]);
      } else {
        blst_fr_mul(&buffer, &ctxt->mds[i][j], &ctxt->s[j]);
        blst_fr_add(res + i, res + i, &buffer);
      }
    }
  }
  for (int i = 0; i < ctxt->width; i++) {
    memcpy(&ctxt->s[i], res + i, sizeof(blst_fr));
  }
}

blst_fr *poseidon_get_next_round_key(poseidon_ctxt_t *ctxt) {
  return (ctxt->ark + ctxt->i_round_key++);
}

void poseidon_apply_cst(poseidon_ctxt_t *ctxt) {
  for (int i = 0; i < ctxt->width; i++) {
    blst_fr_add(&ctxt->s[i], &ctxt->s[i], poseidon_get_next_round_key(ctxt));
  }
}

void poseidon_apply_batched_partial_round(poseidon_ctxt_t *ctxt) {
  // FIXME: if batch_size is 0, fails
  int nb_tmp_var = ctxt->batch_size - 1;
  blst_fr buffer;
  blst_fr intermediary_state[ctxt->width + nb_tmp_var];
  for (int i = 0; i < ctxt->width; i++) {
    memcpy(intermediary_state + i, &ctxt->s[i], sizeof(blst_fr));
  }

  // Apply sbox on the last element of the state
  blst_fr_sqr(&buffer, intermediary_state + ctxt->width - 1);
  blst_fr_sqr(&buffer, &buffer);
  blst_fr_mul(intermediary_state + ctxt->width - 1, &buffer,
              intermediary_state + ctxt->width - 1);

  // Computing the temporary variables
  for (int i = 0; i < nb_tmp_var; i++) {
    // we start with the first element
    blst_fr_mul(intermediary_state + ctxt->width + i,
                poseidon_get_next_round_key(ctxt), intermediary_state);
    for (int j = 1; j < ctxt->width + i; j++) {
      blst_fr_mul(&buffer, poseidon_get_next_round_key(ctxt),
                  intermediary_state + j);
      blst_fr_add(intermediary_state + ctxt->width + i,
                  intermediary_state + ctxt->width + i, &buffer);
    }
    // We add the constant
    blst_fr_add(intermediary_state + ctxt->width + i,
                intermediary_state + ctxt->width + i,
                poseidon_get_next_round_key(ctxt));

    // Applying sbox
    blst_fr_sqr(&buffer, intermediary_state + i + ctxt->width);
    blst_fr_sqr(&buffer, &buffer);
    blst_fr_mul(intermediary_state + i + ctxt->width, &buffer,
                intermediary_state + i + ctxt->width);
  }

  // Computing the final state
  for (int i = 0; i < ctxt->width; i++) {
    blst_fr_mul(&ctxt->s[i], poseidon_get_next_round_key(ctxt),
                intermediary_state);
    for (int j = 1; j < ctxt->width + nb_tmp_var; j++) {
      blst_fr_mul(&buffer, intermediary_state + j,
                  poseidon_get_next_round_key(ctxt));
      blst_fr_add(&ctxt->s[i], &buffer, &ctxt->s[i]);
    }
    blst_fr_add(&ctxt->s[i], &ctxt->s[i], poseidon_get_next_round_key(ctxt));
  }
}

void poseidon_apply_perm(poseidon_ctxt_t *ctxt) {
  int nb_batched_partial_rounds = ctxt->nb_partial_rounds / ctxt->batch_size;
  int nb_unbatched_partial_rounds = ctxt->nb_partial_rounds % ctxt->batch_size;
  ctxt->i_round_key = 0;
  poseidon_apply_cst(ctxt);
  for (int i = 0; i < ctxt->nb_full_rounds / 2; i++) {
    poseidon_apply_sbox(ctxt, 1);
    poseidon_apply_matrix_multiplication(ctxt);
    poseidon_apply_cst(ctxt);
  }
  for (int i = 0; i < nb_batched_partial_rounds; i++) {
    poseidon_apply_batched_partial_round(ctxt);
  }
  for (int i = 0; i < nb_unbatched_partial_rounds; i++) {
    poseidon_apply_sbox(ctxt, 0);
    poseidon_apply_matrix_multiplication(ctxt);
    poseidon_apply_cst(ctxt);
  }
  for (int i = 0; i < ctxt->nb_full_rounds / 2; i++) {
    poseidon_apply_sbox(ctxt, 1);
    poseidon_apply_matrix_multiplication(ctxt);
    poseidon_apply_cst(ctxt);
  }
}
