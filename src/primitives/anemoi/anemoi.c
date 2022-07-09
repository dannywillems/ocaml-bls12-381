#include "anemoi.h"
/* #include <inttypes.h> */
#include <stdlib.h>

/*
 * Anemoi context:

   X = x_0
   Y = y_0
   CONSTANTS = [
     c_x_0;    |
               |----> For the first round
     d_y_0;    |

     c_x_1;    |
               |----> For the second round
     d_y_1;    |
     ...
   ]

   We will concatenate them in a contiguous C array.
   As the number of rounds and the input size is already known, we preallocated
   the context and the constants
 */

void anemoi_jive128_1_apply_linear_layer(blst_fr *ctxt) {
  blst_fr tmp;

  // Compute g * y and save it in tmp.
  // multiply by 7
  // y + y
  blst_fr_add(&tmp, ctxt + 1, ctxt + 1);
  // 2y + y
  blst_fr_add(&tmp, &tmp, ctxt + 1);
  // 3y + 3y
  blst_fr_add(&tmp, &tmp, &tmp);
  // 6y + y
  blst_fr_add(&tmp, &tmp, ctxt + 1);
  // x += g * y. Inplace operation
  blst_fr_add(ctxt, ctxt, &tmp);
  // Compute "g * x' and save it in tmp.
  // multiply by 7
  // x + x
  blst_fr_add(&tmp, ctxt, ctxt);
  // 2x + x
  blst_fr_add(&tmp, &tmp, ctxt);
  // 3x + 3x
  blst_fr_add(&tmp, &tmp, &tmp);
  // 6x + x
  blst_fr_add(&tmp, &tmp, ctxt);

  blst_fr_add(ctxt + 1, ctxt + 1, &tmp);
}

void anemoi_jive128_1_apply_flystel(blst_fr *ctxt) {
  blst_fr tmp;
  // First we compute x_i = x_i - beta * y^2 = x_i - Q_i(y_i)
  // -- compute y^2
  blst_fr_sqr(&tmp, ctxt + 1);
  // -- Compute beta * y^2
  blst_fr_mul(&tmp, &tmp, &BETA);
  // -- Compute x = x - beta * y^2
  blst_fr_sub(ctxt, ctxt, &tmp);
  // Computing E(x)
  // -- Coppute x^alpha_inv and save it in tmp.
  // NB: this is the costly operation.
  // IMPROVEME: can be improved using addchain. Would be 21% faster (305 ops
  // instead of 384).
  // > addchain search
  // '20974350070050476191779096203274386335076221000211055129041463479975432473805'
  // > addition cost: 305
  blst_fr_pow(&tmp, ctxt, ALPHA_INV_BYTES, ALPHA_INV_NUMBITS);
  // -- Compute y_i = y_i - x^(alpha_inv) = y_i - E(x_i)
  blst_fr_sub(ctxt + 1, ctxt + 1, &tmp);
  // Computing x_i = x_i + (beta * y^2 + delta) = x_i + Q_f(x_i)
  // -- compute y^2
  blst_fr_sqr(&tmp, ctxt + 1);
  // -- compute beta * y^2
  blst_fr_mul(&tmp, &tmp, &BETA);
  // -- compute beta * y^2 + delta
  blst_fr_add(&tmp, &tmp, &DELTA);
  // -- compute x + x + beta * y^2 + delta
  blst_fr_add(ctxt, ctxt, &tmp);
}

int anemoi_jive128_1_add_constant(blst_fr *ctxt, int index_cst) {
  blst_fr_add(ctxt, ctxt,
              ANEMOI_JIVE_ROUND_CONSTANTS_128BITS_INPUT_SIZE_1 + index_cst++);
  blst_fr_add(ctxt + 1, ctxt + 1,
              ANEMOI_JIVE_ROUND_CONSTANTS_128BITS_INPUT_SIZE_1 + index_cst++);
  return (index_cst);
}

void anemoi_jive128_1_compress(blst_fr *res, blst_fr *x, blst_fr *y) {
  blst_fr *ctxt = (blst_fr *)(malloc(sizeof(blst_fr) * 2));

  int index_cst;

  index_cst = 0;
  memcpy(ctxt, x, sizeof(blst_fr));
  memcpy(ctxt + 1, y, sizeof(blst_fr));

  for (int i = 0; i < NB_ROUNDS_128BITS_INPUT_SIZE_1; i++) {
    // add cst
    index_cst = anemoi_jive128_1_add_constant(ctxt, index_cst);
    // apply linear layer
    anemoi_jive128_1_apply_linear_layer(ctxt);
    // apply sbox
    anemoi_jive128_1_apply_flystel(ctxt);
  }

  // Final call to linear layer. See page 15, High Level Algorithms
  anemoi_jive128_1_apply_linear_layer(ctxt);

  // Page 17 and page 7, figure 2-a
  // The result is x + y + P(x, y). We keep first the initial value.
  blst_fr_add(res, x, y);
  // The result is x + y + u + v
  blst_fr_add(res, res, ctxt);
  blst_fr_add(res, res, ctxt + 1);

  free(ctxt);
}
