#include "rescue.h"
#include <stdlib.h>
#include <string.h>

blst_fr RESCUE_ARK[NB_CONSTANTS];
blst_fr RESCUE_MDS[WIDTH][WIDTH];

byte ALPHA_INV_BYTES[32] = {
    205, 204, 204, 204, 50,  51, 51, 51,  153, 241, 152, 153, 103, 14, 127, 33,
    2,   240, 115, 157, 105, 86, 74, 225, 28,  50,  114, 221, 186, 15, 95,  46};

int ALPHA_INV_NB_BITS = 254;

int rescue_constants_init(blst_fr *ark, blst_fr **mds, int ark_len,
                          int mds_nb_rows, int mds_nb_cols) {
  if (NB_CONSTANTS != ark_len || mds_nb_rows != WIDTH || mds_nb_cols != WIDTH) {
    return 1;
  }

  for (int i = 0; i < NB_CONSTANTS; i++) {
    memcpy(RESCUE_ARK + i, ark + i, sizeof(blst_fr));
  }

  for (int i = 0; i < WIDTH; i++) {
    for (int j = 0; j < WIDTH; j++) {
      memcpy(&RESCUE_MDS[i][j], &mds[i][j], sizeof(blst_fr));
    }
  }
  return 0;
}

void rescue_init(rescue_ctxt_t *ctxt, blst_fr *a, blst_fr *b, blst_fr *c) {
  memcpy(&ctxt->s[0], a, sizeof(blst_fr));
  memcpy(&ctxt->s[1], b, sizeof(blst_fr));
  memcpy(&ctxt->s[2], c, sizeof(blst_fr));
}

void marvellous_apply_nonlinear_alpha(rescue_ctxt_t *ctxt) {
  blst_fr buffer;
  for (int i = 0; i < WIDTH; i++) {
    // x * (x^2)^2
    blst_fr_sqr(&buffer, &ctxt->s[i]);
    blst_fr_sqr(&buffer, &buffer);
    blst_fr_mul(&ctxt->s[i], &buffer, &ctxt->s[i]);
  }
}

void marvellous_apply_nonlinear_alphainv(rescue_ctxt_t *ctxt) {
  blst_fr buffer;
  for (int i = 0; i < WIDTH; i++) {
    blst_fr_pow(&buffer, &ctxt->s[i], ALPHA_INV_BYTES, ALPHA_INV_NB_BITS);
    memcpy(&ctxt->s[i], &buffer, sizeof(blst_fr));
  }
}

void marvellous_apply_linear(rescue_ctxt_t *ctxt) {
  blst_fr buffer;
  blst_fr res[WIDTH];
  uint64_t zero[4] = {0, 0, 0, 0};
  for (int i = 0; i < WIDTH; i++) {
    blst_fr_from_uint64(res + i, zero);
    for (int j = 0; j < WIDTH; j++) {
      blst_fr_mul(&buffer, &RESCUE_MDS[i][j], &ctxt->s[j]);
      blst_fr_add(res + i, res + i, &buffer);
    }
  }
  for (int i = 0; i < WIDTH; i++) {
    memcpy(&ctxt->s[i], res + i, sizeof(blst_fr));
  }
}

void marvellous_apply_cst(rescue_ctxt_t *ctxt) {
  for (int i = 0; i < WIDTH; i++) {
    blst_fr_add(&ctxt->s[i], &ctxt->s[i], RESCUE_ARK + ctxt->i_round_key);
    ctxt->i_round_key++;
  }
}

void marvellous_apply_perm(rescue_ctxt_t *ctxt) {
  ctxt->i_round_key = 0;
  for (int i = 0; i < NB_ROUNDS; i++) {
    marvellous_apply_nonlinear_alpha(ctxt);
    marvellous_apply_linear(ctxt);
    marvellous_apply_cst(ctxt);
    marvellous_apply_nonlinear_alphainv(ctxt);
    marvellous_apply_linear(ctxt);
    marvellous_apply_cst(ctxt);
  }
}

void rescue_get_state(blst_fr *a, blst_fr *b, blst_fr *c, rescue_ctxt_t *ctxt) {
  memcpy(a, &ctxt->s[0], sizeof(blst_fr));
  memcpy(b, &ctxt->s[1], sizeof(blst_fr));
  memcpy(c, &ctxt->s[2], sizeof(blst_fr));
}
