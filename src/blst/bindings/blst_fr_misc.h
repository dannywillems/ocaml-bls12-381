#ifndef BLST_FR_MISC
#define BLST_FR_MISC

#include "blst.h"

bool blst_fr_is_one(blst_fr *x);
bool blst_fr_is_zero(blst_fr *x);
bool blst_fr_is_equal(blst_fr *x, blst_fr *y);
bool blst_fr_from_lendian(blst_fr *x, byte b[32]);
void blst_lendian_from_fr(byte b[32], blst_fr *x);

#endif
