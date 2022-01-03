#ifndef BLST_FR_MISC
#define BLST_FR_MISC

#include "blst.h"

#define CAML_BLS12_381_OUTPUT_SUCCESS Val_int(0)
#define CAML_BLS12_381_OUTPUT_OUT_OF_MEMORY Val_int(1)

bool blst_fr_is_one(blst_fr *x);
bool blst_fr_is_zero(blst_fr *x);
bool blst_fr_is_equal(blst_fr *x, blst_fr *y);
bool blst_fr_from_lendian(blst_fr *x, byte b[32]);
void blst_lendian_from_fr(byte b[32], blst_fr *x);

#endif
