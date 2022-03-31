#include "hades.h"

int hades_compute_number_of_constants(int batch_size, int nb_partial_rounds,
                                         int nb_full_rounds, int width) {
  int nb_tmp_var = batch_size - 1;
  int nb_batched_partial_rounds = nb_partial_rounds / batch_size;
  int nb_unbatched_partial_rounds = nb_partial_rounds % batch_size;
  int nb_constants_full_rounds = nb_full_rounds * width;
  int nb_constants_unbatched_partial_rounds =
      nb_unbatched_partial_rounds * width;
  int nb_constants_per_batched_partial_rounds_tmp_var =
      nb_tmp_var + width * nb_tmp_var + (nb_tmp_var * (nb_tmp_var - 1) / 2);
  int nb_constants_per_batched_partial_rounds_final_computation =
      (nb_tmp_var + width) * width + width;
  int nb_constants_per_batched_partial_rounds =
      nb_constants_per_batched_partial_rounds_tmp_var +
      nb_constants_per_batched_partial_rounds_final_computation;
  int nb_constants_batched_partial_rounds =
      nb_batched_partial_rounds * nb_constants_per_batched_partial_rounds;
  // we add width zero's at the end
  int nb_constants = nb_constants_full_rounds +
                     nb_constants_batched_partial_rounds +
                     nb_constants_unbatched_partial_rounds + width;
  return (nb_constants);
}

void hades_apply_sbox(blst_fr *ctxt, int full, int width) {
  blst_fr buffer;
  int partial_round_idx_sbox = width - 1;
  int begin_idx = full ? 0 : partial_round_idx_sbox;
  int end_idx = width;
  for (int i = begin_idx; i < end_idx; i++) {
    // x * (x^2)^2
    blst_fr_sqr(&buffer, ctxt + i);
    blst_fr_sqr(&buffer, &buffer);
    blst_fr_mul(ctxt + i, &buffer, ctxt + i);
  }
}

void hades_apply_matrix_multiplication(blst_fr *ctxt, int width,
                                          int ark_len) {
  blst_fr buffer;
  blst_fr res[width];
  blst_fr *mds = ctxt + width + ark_len;
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < width; j++) {
      if (j == 0) {
        blst_fr_mul(res + i, mds + i * width + j, ctxt + j);
      } else {
        blst_fr_mul(&buffer, mds + i * width + j, ctxt + j);
        blst_fr_add(res + i, res + i, &buffer);
      }
    }
  }
  for (int i = 0; i < width; i++) {
    memcpy(ctxt + i, res + i, sizeof(blst_fr));
  }
}

int hades_apply_cst(blst_fr *ctxt, int width, int offset_ark) {
  for (int i = 0; i < width; i++) {
    blst_fr_add(ctxt + i, ctxt + i, ctxt + offset_ark + i);
  }
  return (offset_ark + width);
}

int hades_apply_batched_partial_round(blst_fr *ctxt, int batch_size,
                                         int width, int offset_ark) {
  // FIXME: if batch_size is 0, fails
  int nb_tmp_var = batch_size - 1;
  blst_fr buffer;
  blst_fr *ark = ctxt + offset_ark;
  blst_fr intermediary_state[width + nb_tmp_var];
  for (int i = 0; i < width; i++) {
    memcpy(intermediary_state + i, ctxt + i, sizeof(blst_fr));
  }

  // Apply sbox on the last element of the state
  blst_fr_sqr(&buffer, intermediary_state + width - 1);
  blst_fr_sqr(&buffer, &buffer);
  blst_fr_mul(intermediary_state + width - 1, &buffer,
              intermediary_state + width - 1);

  // Computing the temporary variables
  for (int i = 0; i < nb_tmp_var; i++) {
    // we start with the first element
    blst_fr_mul(intermediary_state + width + i, ark++, intermediary_state);
    for (int j = 1; j < width + i; j++) {
      blst_fr_mul(&buffer, ark++, intermediary_state + j);
      blst_fr_add(intermediary_state + width + i,
                  intermediary_state + width + i, &buffer);
    }
    // We add the constant
    blst_fr_add(intermediary_state + width + i, intermediary_state + width + i,
                ark++);

    // Applying sbox
    blst_fr_sqr(&buffer, intermediary_state + i + width);
    blst_fr_sqr(&buffer, &buffer);
    blst_fr_mul(intermediary_state + i + width, &buffer,
                intermediary_state + i + width);
  }

  // Computing the final state
  for (int i = 0; i < width; i++) {
    blst_fr_mul(ctxt + i, ark++, intermediary_state);
    for (int j = 1; j < width + nb_tmp_var; j++) {
      blst_fr_mul(&buffer, intermediary_state + j, ark++);
      blst_fr_add(ctxt + i, &buffer, ctxt + i);
    }
    blst_fr_add(ctxt + i, ctxt + i, ark++);
  }
  return ark - ctxt;
}

void hades_apply_perm(blst_fr *ctxt, int width, int nb_full_rounds,
                         int nb_partial_rounds, int batch_size) {
  int nb_batched_partial_rounds = nb_partial_rounds / batch_size;
  int nb_unbatched_partial_rounds = nb_partial_rounds % batch_size;
  int ark_len = hades_compute_number_of_constants(
      batch_size, nb_partial_rounds, nb_full_rounds, width);
  int offset_ark = width;
  offset_ark = hades_apply_cst(ctxt, width, offset_ark);
  for (int i = 0; i < nb_full_rounds / 2; i++) {
    hades_apply_sbox(ctxt, 1, width);
    hades_apply_matrix_multiplication(ctxt, width, ark_len);
    offset_ark = hades_apply_cst(ctxt, width, offset_ark);
  }
  for (int i = 0; i < nb_batched_partial_rounds; i++) {
    offset_ark = hades_apply_batched_partial_round(ctxt, batch_size, width,
                                                      offset_ark);
  }
  for (int i = 0; i < nb_unbatched_partial_rounds; i++) {
    hades_apply_sbox(ctxt, 0, width);
    hades_apply_matrix_multiplication(ctxt, width, ark_len);
    offset_ark = hades_apply_cst(ctxt, width, offset_ark);
  }
  for (int i = 0; i < nb_full_rounds / 2; i++) {
    hades_apply_sbox(ctxt, 1, width);
    hades_apply_matrix_multiplication(ctxt, width, ark_len);
    offset_ark = hades_apply_cst(ctxt, width, offset_ark);
  }
}
