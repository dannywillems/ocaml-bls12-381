#include "blst.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

size_t blst_scalar_sizeof() { return sizeof(blst_scalar); }

size_t blst_fr_sizeof() { return sizeof(blst_fr); }

// Additional functions for Fr.eq, Fr.is_zero and Fr.is_one
bool blst_fr_is_equal(blst_fr *x, blst_fr *y) {
  uint64_t x_uint_64[4];
  blst_uint64_from_fr(x_uint_64, x);

  uint64_t y_uint_64[4];
  blst_uint64_from_fr(y_uint_64, y);
  bool is_equal =
      ((y_uint_64[0] == x_uint_64[0])) && ((y_uint_64[1] == x_uint_64[1])) &&
      ((y_uint_64[2] == x_uint_64[2])) && ((y_uint_64[3] == x_uint_64[3]));
  return (is_equal);
}

bool blst_fr_is_zero(blst_fr *x) {
  uint64_t x_uint_64[4];
  blst_uint64_from_fr(x_uint_64, x);
  bool is_zero = (x_uint_64[0] == 0lu) && (x_uint_64[1] == 0lu) &&
                 (x_uint_64[2] == 0lu) && (x_uint_64[3] == 0lu);
  return (is_zero);
}

bool blst_fr_is_one(blst_fr *x) {
  uint64_t x_uint_64[4];
  blst_uint64_from_fr(x_uint_64, x);
  bool is_one = (x_uint_64[0] == 1lu) && (x_uint_64[1] == 0lu) &&
                (x_uint_64[2] == 0lu) && (x_uint_64[3] == 0lu);
  return (is_one);
}

bool blst_fr_from_lendian(blst_fr *x, byte b[32]) {
  blst_scalar *s = (blst_scalar *)calloc(1, sizeof(blst_scalar));
  blst_scalar_from_lendian(s, b);
  bool is_ok = blst_scalar_fr_check(s);
  if (is_ok) {
    blst_fr_from_scalar(x, s);
  }
  free(s);
  return (is_ok);
}

void blst_lendian_from_fr(byte b[32], blst_fr *x) {
  blst_scalar *s = (blst_scalar *)calloc(1, sizeof(blst_scalar));
  blst_scalar_from_fr(s, x);
  blst_lendian_from_scalar(b, s);
  free(s);
}

void set_fr_to_one(blst_fr *x) {
  uint64_t x_uint_64[4];
  x_uint_64[0] = 1lu;
  x_uint_64[1] = 0lu;
  x_uint_64[2] = 0lu;
  x_uint_64[3] = 0lu;
  blst_fr_from_uint64(x, x_uint_64);
}

void blst_fr_pow(blst_fr *out, blst_fr *x, byte *exp, int exp_nb_bits) {
  // Set output buffer to Fr.one
  memset(out, 0, sizeof(blst_scalar));
  set_fr_to_one(out);

  // Square and multiply
  for (int i = exp_nb_bits - 1; i >= 0; i--) {
    blst_fr_sqr(out, out);
    if (exp[i / 8] & (1 << (i % 8)))
      blst_fr_mul(out, out, x);
  }
}

size_t blst_fp_sizeof() { return sizeof(blst_fp); }

size_t blst_fp2_sizeof() { return sizeof(blst_fp2); }

void blst_fp2_assign(blst_fp2 *p_c, blst_fp *x1_c, blst_fp *x2_c) {
  (p_c->fp[0]).l[0] = x1_c->l[0];
  (p_c->fp[0]).l[1] = x1_c->l[1];
  (p_c->fp[0]).l[2] = x1_c->l[2];
  (p_c->fp[0]).l[3] = x1_c->l[3];
  (p_c->fp[1]).l[0] = x2_c->l[0];
  (p_c->fp[1]).l[1] = x2_c->l[1];
  (p_c->fp[1]).l[2] = x2_c->l[2];
  (p_c->fp[1]).l[3] = x2_c->l[3];
}

void blst_fp2_zero(blst_fp2 *buffer_c) {
  byte zero_bytes[48] = {0};
  blst_fp_from_lendian(&buffer_c->fp[0], zero_bytes);
  blst_fp_from_lendian(&buffer_c->fp[1], zero_bytes);
}

void blst_fp2_set_one(blst_fp2 *buffer_c) {
  byte bytes[48] = {0};
  blst_fp_from_lendian(&buffer_c->fp[0], bytes);
  bytes[0] = 1;
  blst_fp_from_lendian(&buffer_c->fp[1], bytes);
}

void blst_fp2_of_bytes_components(blst_fp2 *buffer_c, byte *x1, byte *x2) {
  // FIXME: add a check on the length
  blst_fp_from_lendian(&buffer_c->fp[0], x1);
  blst_fp_from_lendian(&buffer_c->fp[1], x2);
}

void blst_fp2_to_bytes(byte *out, blst_fp2 *p_c) {
  blst_lendian_from_fp(out, &p_c->fp[0]);
  blst_lendian_from_fp(out + 48, &p_c->fp[1]);
}

size_t blst_fp12_sizeof() { return sizeof(blst_fp12); }

void blst_fp12_set_one(blst_fp12 *buffer_c) {
  // Set all coordinates to 0. If allocated with allocate_fp12_stubs it's
  // normally fine, but doing it just in case...
  memset(buffer_c, 0, sizeof(blst_fp12));
  // And override for 1.
  byte out[48] = {0};
  out[0] = 1;
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[0].fp[0]), out);
}

void blst_fp12_to_bytes(byte *buffer, blst_fp12 *p_c) {
  // FIXME: add a check on the length
  blst_lendian_from_fp(buffer, &(p_c->fp6[0].fp2[0].fp[0]));
  blst_lendian_from_fp(buffer + 1 * 48, &(p_c->fp6[0].fp2[0].fp[1]));
  blst_lendian_from_fp(buffer + 2 * 48, &(p_c->fp6[0].fp2[1].fp[0]));
  blst_lendian_from_fp(buffer + 3 * 48, &(p_c->fp6[0].fp2[1].fp[1]));
  blst_lendian_from_fp(buffer + 4 * 48, &(p_c->fp6[0].fp2[2].fp[0]));
  blst_lendian_from_fp(buffer + 5 * 48, &(p_c->fp6[0].fp2[2].fp[1]));
  blst_lendian_from_fp(buffer + 6 * 48, &(p_c->fp6[1].fp2[0].fp[0]));
  blst_lendian_from_fp(buffer + 7 * 48, &(p_c->fp6[1].fp2[0].fp[1]));
  blst_lendian_from_fp(buffer + 8 * 48, &(p_c->fp6[1].fp2[1].fp[0]));
  blst_lendian_from_fp(buffer + 9 * 48, &(p_c->fp6[1].fp2[1].fp[1]));
  blst_lendian_from_fp(buffer + 10 * 48, &(p_c->fp6[1].fp2[2].fp[0]));
  blst_lendian_from_fp(buffer + 11 * 48, &(p_c->fp6[1].fp2[2].fp[1]));
}

void blst_fp12_of_bytes(blst_fp12 *buffer_c, byte *p) {
  // FIXME: add a check on the length
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[0].fp[0]), p);
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[0].fp[1]), p + 48);
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[1].fp[0]), p + 2 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[1].fp[1]), p + 3 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[2].fp[0]), p + 4 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[2].fp[1]), p + 5 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[0].fp[0]), p + 6 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[0].fp[1]), p + 7 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[1].fp[0]), p + 8 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[1].fp[1]), p + 9 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[2].fp[0]), p + 10 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[2].fp[1]), p + 11 * 48);
}

size_t blst_p1_sizeof() { return sizeof(blst_p1); }

size_t blst_p1_affine_sizeof() { return sizeof(blst_p1_affine); }

void blst_p1_set_coordinates(blst_p1 *buffer_c, blst_fp *x_c, blst_fp *y_c) {
  buffer_c->x = *x_c;
  buffer_c->y = *y_c;
}

size_t blst_p2_sizeof() { return sizeof(blst_p2); }

size_t blst_p2_affine_sizeof() { return sizeof(blst_p2_affine); }

void blst_p2_set_coordinates(blst_p2 *buffer_c, blst_fp2 *x_c, blst_fp2 *y_c) {
  byte out[96];

  blst_lendian_from_fp(out, &x_c->fp[0]);
  blst_lendian_from_fp(out + 48, &x_c->fp[1]);
  blst_fp_from_lendian(&buffer_c->x.fp[0], out);
  blst_fp_from_lendian(&buffer_c->x.fp[1], out + 48);

  blst_lendian_from_fp(out, &y_c->fp[0]);
  blst_lendian_from_fp(out + 48, &y_c->fp[1]);
  blst_fp_from_lendian(&buffer_c->y.fp[0], out);
  blst_fp_from_lendian(&buffer_c->y.fp[1], out + 48);
}