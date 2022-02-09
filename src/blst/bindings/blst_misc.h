#ifndef BLST_MISC
#define BLST_MISC

#include "blst.h"

size_t blst_scalar_sizeof();

size_t blst_fr_sizeof();

bool blst_fr_is_equal(blst_fr *x, blst_fr *y);

int blst_fr_compare(blst_fr *x_c, blst_fr *y_c);

bool blst_fr_is_zero(blst_fr *x);

bool blst_fr_is_one(blst_fr *x);

bool blst_fr_from_lendian(blst_fr *x, byte b[32]);

void blst_lendian_from_fr(byte b[32], blst_fr *x);

void blst_fr_pow(blst_fr *out, blst_fr *x, byte *exp, int exp_nb_bits);

size_t blst_fp_sizeof();

size_t blst_fp2_sizeof();

void blst_fp2_assign(blst_fp2 *p_c, blst_fp *x1_c, blst_fp *x2_c);

void blst_fp2_zero(blst_fp2 *buffer_c);

void blst_fp2_set_one(blst_fp2 *buffer_c);

void blst_fp2_of_bytes_components(blst_fp2 *buffer, byte *x1, byte *x2);

void blst_fp2_to_bytes(byte *out, blst_fp2 *p_c);

size_t blst_fp12_sizeof();

void blst_fp12_set_one(blst_fp12 *buffer_c);

void blst_fp12_to_bytes(byte *buffer, blst_fp12 *p_c);

void blst_fp12_of_bytes(blst_fp12 *buffer_c, byte *p);

size_t blst_p1_sizeof();

size_t blst_p1_affine_sizeof();

void blst_p1_set_coordinates(blst_p1 *buffer_c, blst_fp *x_c, blst_fp *y_c);

size_t blst_p2_sizeof();

size_t blst_p2_affine_sizeof();

void blst_p2_set_coordinates(blst_p2 *buffer_c, blst_fp2 *x_c, blst_fp2 *y_c);

#endif
