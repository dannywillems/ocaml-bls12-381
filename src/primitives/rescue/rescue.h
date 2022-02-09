#ifndef RESCUE_H
#define RESCUE_H

#include "blst.h"
#include "blst_misc.h"

#define WIDTH 3
#define NB_ROUNDS 14
#define NB_CONSTANTS (NB_ROUNDS * WIDTH * 2)

typedef struct rescue_ctxt_s {
  blst_fr s[WIDTH];
  int i_round_key;
} rescue_ctxt_t;

int rescue_constants_init(blst_fr *akr, blst_fr **mds, int ark_len,
                          int mds_nb_rows, int mds_nb_cols);
void rescue_init(rescue_ctxt_t *ctxt, blst_fr *a, blst_fr *b, blst_fr *c);
void marvellous_apply_perm(rescue_ctxt_t *ctxt);
void rescue_get_state(blst_fr *a, blst_fr *b, blst_fr *c, rescue_ctxt_t *ctxt);
#endif
