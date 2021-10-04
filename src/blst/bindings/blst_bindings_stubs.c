#include "blst.h"
#define CAML_NAME_SPACE
#include "ocaml_integers.h"
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// From ocaml-ctypes:
// https://github.com/ocamllabs/ocaml-ctypes/blob/9048ac78b885cc3debeeb020c56ea91f459a4d33/src/ctypes/ctypes_primitives.h#L110
#if SIZE_MAX == UINT16_MAX
#define ctypes_size_t_val Uint16_val
#define ctypes_copy_size_t Integers_val_uint16
#elif SIZE_MAX == UINT32_MAX
#define ctypes_size_t_val Uint32_val
#define ctypes_copy_size_t integers_copy_uint32
#elif SIZE_MAX == UINT64_MAX
#define ctypes_size_t_val Uint64_val
#define ctypes_copy_size_t integers_copy_uint64
#else
#error "No suitable OCaml type available for representing size_t values"
#endif

// From ocaml/ocaml
// https://github.com/ocaml/ocaml/blob/aca84729327d327eaf6e82f3ae15d0a63953288e/runtime/caml/mlvalues.h#L401
#define Val_none Val_int(0)
#define Some_val(v) Field(v, 0)
#define Tag_some 0
#define Is_none(v) ((v) == Val_none)
#define Is_some(v) Is_block(v)

// Fr
#define Blst_fr_val(v) (*((blst_fr **)Data_custom_val(v)))

static void finalize_free_fr(value v) { free(Blst_fr_val(v)); }

static struct custom_operations blst_fr_ops = {"blst_fr",
                                               finalize_free_fr,
                                               custom_compare_default,
                                               custom_hash_default,
                                               custom_serialize_default,
                                               custom_deserialize_default,
                                               custom_compare_ext_default,
                                               custom_fixed_length_default};

#define Blst_scalar_val(v) (*((blst_scalar **)Data_custom_val(v)))

static void finalize_free_scalar(value v) { free(Blst_scalar_val(v)); }

static struct custom_operations blst_scalar_ops = {"blst_scalar",
                                                   finalize_free_scalar,
                                                   custom_compare_default,
                                                   custom_hash_default,
                                                   custom_serialize_default,
                                                   custom_deserialize_default,
                                                   custom_compare_ext_default,
                                                   custom_fixed_length_default};

CAMLprim value allocate_scalar_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block = caml_alloc_custom(&blst_scalar_ops, sizeof(blst_scalar *), 0, 1);
  void *p = calloc(1, sizeof(blst_scalar));
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_scalar **d = (blst_scalar **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value allocate_fr_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block = caml_alloc_custom(&blst_fr_ops, sizeof(blst_fr *), 0, 1);
  void *p = calloc(1, sizeof(blst_fr));
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_fr **d = (blst_fr **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value caml_blst_fr_add_stubs(value ret, value p1, value p2) {
  CAMLparam3(ret, p1, p2);
  blst_fr_add(Blst_fr_val(ret), Blst_fr_val(p1), Blst_fr_val(p2));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fr_mul_stubs(value ret, value p1, value p2) {
  CAMLparam3(ret, p1, p2);
  blst_fr_mul(Blst_fr_val(ret), Blst_fr_val(p1), Blst_fr_val(p2));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fr_sqr_stubs(value ret, value p1) {
  CAMLparam2(ret, p1);
  blst_fr_sqr(Blst_fr_val(ret), Blst_fr_val(p1));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fr_eucl_inverse_stubs(value ret, value p1) {
  CAMLparam2(ret, p1);
  blst_fr_eucl_inverse(Blst_fr_val(ret), Blst_fr_val(p1));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fr_sub_stubs(value ret, value p1, value p2) {
  CAMLparam3(ret, p1, p2);
  blst_fr_sub(Blst_fr_val(ret), Blst_fr_val(p1), Blst_fr_val(p2));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_scalar_from_fr_stubs(value ret, value p1) {
  CAMLparam2(ret, p1);
  blst_scalar_from_fr(Blst_scalar_val(ret), Blst_fr_val(p1));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fr_from_scalar_stubs(value ret, value p1) {
  CAMLparam2(ret, p1);
  blst_fr_from_scalar(Blst_fr_val(ret), Blst_scalar_val(p1));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_scalar_to_bytes_stubs(value ret, value p1) {
  CAMLparam2(ret, p1);
  blst_lendian_from_scalar(Bytes_val(ret), Blst_scalar_val(p1));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_scalar_of_bytes_stubs(value ret, value p1) {
  CAMLparam2(ret, p1);
  blst_scalar_from_lendian(Blst_scalar_val(ret), Bytes_val(p1));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_check_scalar_stubs(value p1) {
  CAMLparam1(p1);
  bool r = blst_scalar_fr_check(Blst_scalar_val(p1));
  CAMLreturn(Val_bool(r));
}

CAMLprim value caml_blst_fr_memcpy_stubs(value dst, value src) {
  CAMLparam2(dst, src);
  memcpy(Blst_fr_val(dst), Blst_fr_val(src), sizeof(blst_fr));
  CAMLreturn(Val_unit);
}

// Fq
#define Blst_fp_val(v) (*((blst_fp **)Data_custom_val(v)))

static void finalize_free_fp(value v) { free(Blst_fp_val(v)); }

static struct custom_operations blst_fp_ops = {"blst_fp",
                                               finalize_free_fp,
                                               custom_compare_default,
                                               custom_hash_default,
                                               custom_serialize_default,
                                               custom_deserialize_default,
                                               custom_compare_ext_default,
                                               custom_fixed_length_default};

CAMLprim value allocate_fp_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block = caml_alloc_custom(&blst_fp_ops, sizeof(blst_fp *), 0, 1);
  void *p = calloc(1, sizeof(blst_fp));
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_fp **d = (blst_fp **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value caml_blst_fp_of_bytes_stubs(value ret, value p1) {
  CAMLparam2(ret, p1);
  blst_fp_from_lendian(Blst_fp_val(ret), Bytes_val(p1));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp_to_bytes_stubs(value ret, value p1) {
  CAMLparam2(ret, p1);
  blst_lendian_from_fp(Bytes_val(ret), Blst_fp_val(p1));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp_add_stubs(value ret, value p1, value p2) {
  CAMLparam3(ret, p1, p2);
  blst_fp_add(Blst_fp_val(ret), Blst_fp_val(p1), Blst_fp_val(p2));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp_mul_stubs(value ret, value p1, value p2) {
  CAMLparam3(ret, p1, p2);
  blst_fp_mul(Blst_fp_val(ret), Blst_fp_val(p1), Blst_fp_val(p2));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp_sqrt_stubs(value ret, value p1) {
  CAMLparam2(ret, p1);
  bool r = blst_fp_sqrt(Blst_fp_val(ret), Blst_fp_val(p1));
  CAMLreturn(Val_bool(r));
}

CAMLprim value caml_blst_fp_cneg_stubs(value buffer, value p, value b) {
  CAMLparam3(buffer, p, b);
  blst_fp_cneg(Blst_fp_val(buffer), Blst_fp_val(p), Bool_val(b));
  CAMLreturn(Val_unit);
}

// Fq2
#define Blst_fp2_val(v) (*((blst_fp2 **)Data_custom_val(v)))

static void finalize_free_fp2(value v) { free(Blst_fp2_val(v)); }

static struct custom_operations blst_fp2_ops = {"blst_fp2",
                                                finalize_free_fp2,
                                                custom_compare_default,
                                                custom_hash_default,
                                                custom_serialize_default,
                                                custom_deserialize_default,
                                                custom_compare_ext_default,
                                                custom_fixed_length_default};

CAMLprim value allocate_fp2_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block = caml_alloc_custom(&blst_fp2_ops, sizeof(blst_fp2 *), 0, 1);
  void *p = calloc(1, sizeof(blst_fp2));
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_fp2 **d = (blst_fp2 **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value caml_blst_fp2_add_stubs(value buffer, value p, value q) {
  CAMLparam3(buffer, p, q);
  blst_fp2_add(Blst_fp2_val(buffer), Blst_fp2_val(p), Blst_fp2_val(q));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp2_mul_stubs(value buffer, value p, value q) {
  CAMLparam3(buffer, p, q);
  blst_fp2_mul(Blst_fp2_val(buffer), Blst_fp2_val(p), Blst_fp2_val(q));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp2_sqrt_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  bool r = blst_fp2_sqrt(Blst_fp2_val(buffer), Blst_fp2_val(p));
  CAMLreturn(Val_bool(r));
}

CAMLprim value caml_blst_fp2_cneg_stubs(value buffer, value p, value b) {
  CAMLparam3(buffer, p, b);
  blst_fp2_cneg(Blst_fp2_val(buffer), Blst_fp2_val(p), Bool_val(b));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp2_assign_stubs(value p, value x1, value x2) {
  CAMLparam3(p, x1, x2);
  blst_fp2 *p_c = Blst_fp2_val(p);
  blst_fp *x1_c = Blst_fp_val(x1);
  blst_fp *x2_c = Blst_fp_val(x2);
  (p_c->fp[0]).l[0] = x1_c->l[0];
  (p_c->fp[0]).l[1] = x1_c->l[1];
  (p_c->fp[0]).l[2] = x1_c->l[2];
  (p_c->fp[0]).l[3] = x1_c->l[3];
  (p_c->fp[1]).l[0] = x2_c->l[0];
  (p_c->fp[1]).l[1] = x2_c->l[1];
  (p_c->fp[1]).l[2] = x2_c->l[2];
  (p_c->fp[1]).l[3] = x2_c->l[3];
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp2_zero_stubs(value buffer) {
  CAMLparam1(buffer);
  byte zero_bytes[32] = {0};
  blst_fp2 *buffer_c = Blst_fp2_val(buffer);
  blst_fp_from_lendian(&buffer_c->fp[0], zero_bytes);
  blst_fp_from_lendian(&buffer_c->fp[1], zero_bytes);
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp2_one_stubs(value buffer) {
  CAMLparam1(buffer);
  byte bytes[32] = {0};
  blst_fp2 *buffer_c = Blst_fp2_val(buffer);
  blst_fp_from_lendian(&buffer_c->fp[0], bytes);
  bytes[0] = 1;
  blst_fp_from_lendian(&buffer_c->fp[1], bytes);
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp2_of_bytes_components_stubs(value buffer, value x1,
                                                       value x2) {
  CAMLparam3(buffer, x1, x2);
  blst_fp2 *buffer_c = Blst_fp2_val(buffer);
  // FIXME: add a check on the length
  blst_fp_from_lendian(&buffer_c->fp[0], Bytes_val(x1));
  blst_fp_from_lendian(&buffer_c->fp[1], Bytes_val(x2));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp2_to_bytes_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_fp2 *p_c = Blst_fp2_val(p);
  // FIXME: add a check on the length
  byte *out = Bytes_val(buffer);
  blst_lendian_from_fp(out, &p_c->fp[0]);
  blst_lendian_from_fp(out + 48, &p_c->fp[1]);
  CAMLreturn(Val_unit);
}

// Fq12

#define Blst_fp12_val(v) (*((blst_fp12 **)Data_custom_val(v)))

static void finalize_free_fp12(value v) { free(Blst_fp12_val(v)); }

static struct custom_operations blst_fp12_ops = {"blst_fp12",
                                                 finalize_free_fp12,
                                                 custom_compare_default,
                                                 custom_hash_default,
                                                 custom_serialize_default,
                                                 custom_deserialize_default,
                                                 custom_compare_ext_default,
                                                 custom_fixed_length_default};

CAMLprim value allocate_fp12_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block = caml_alloc_custom(&blst_fp12_ops, sizeof(blst_fp12 *), 0, 1);
  void *p = calloc(1, sizeof(blst_fp12));
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_fp12 **d = (blst_fp12 **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value caml_blst_fp12_mul_stubs(value buffer, value p, value q) {
  CAMLparam3(buffer, p, q);
  blst_fp12_mul(Blst_fp12_val(buffer), Blst_fp12_val(p), Blst_fp12_val(q));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp12_is_equal_stubs(value p, value q) {
  CAMLparam2(p, q);
  bool b = blst_fp12_is_equal(Blst_fp12_val(p), Blst_fp12_val(q));
  CAMLreturn(Val_bool(b));
}

CAMLprim value caml_blst_fp12_is_one_stubs(value p) {
  CAMLparam1(p);
  bool b = blst_fp12_is_one(Blst_fp12_val(p));
  CAMLreturn(Val_bool(b));
}

CAMLprim value caml_blst_fp12_inverse_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_fp12_inverse(Blst_fp12_val(buffer), Blst_fp12_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp12_sqr_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_fp12_sqr(Blst_fp12_val(buffer), Blst_fp12_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp12_one_stubs(value buffer) {
  CAMLparam1(buffer);
  blst_fp12 *buffer_c = Blst_fp12_val(buffer);
  byte out[48] = {0};
  out[0] = 1;
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[0].fp[0]), Bytes_val(out));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp12_to_bytes_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_fp12 *p_c = Blst_fp12_val(p);
  // FIXME: add a check on the length
  blst_lendian_from_fp(Bytes_val(buffer), &(p_c->fp6[0].fp2[0].fp[0]));
  blst_lendian_from_fp(Bytes_val(buffer) + 1 * 48, &(p_c->fp6[0].fp2[0].fp[1]));
  blst_lendian_from_fp(Bytes_val(buffer) + 2 * 48, &(p_c->fp6[0].fp2[1].fp[0]));
  blst_lendian_from_fp(Bytes_val(buffer) + 3 * 48, &(p_c->fp6[0].fp2[1].fp[1]));
  blst_lendian_from_fp(Bytes_val(buffer) + 4 * 48, &(p_c->fp6[0].fp2[2].fp[0]));
  blst_lendian_from_fp(Bytes_val(buffer) + 5 * 48, &(p_c->fp6[0].fp2[2].fp[1]));
  blst_lendian_from_fp(Bytes_val(buffer) + 6 * 48, &(p_c->fp6[1].fp2[0].fp[0]));
  blst_lendian_from_fp(Bytes_val(buffer) + 7 * 48, &(p_c->fp6[1].fp2[0].fp[1]));
  blst_lendian_from_fp(Bytes_val(buffer) + 8 * 48, &(p_c->fp6[1].fp2[1].fp[0]));
  blst_lendian_from_fp(Bytes_val(buffer) + 9 * 48, &(p_c->fp6[1].fp2[1].fp[1]));
  blst_lendian_from_fp(Bytes_val(buffer) + 10 * 48,
                       &(p_c->fp6[1].fp2[2].fp[0]));
  blst_lendian_from_fp(Bytes_val(buffer) + 11 * 48,
                       &(p_c->fp6[1].fp2[2].fp[1]));

  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_fp12_of_bytes_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_fp12 *buffer_c = Blst_fp12_val(buffer);
  // FIXME: add a check on the length
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[0].fp[0]), Bytes_val(p));
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[0].fp[1]), Bytes_val(p) + 48);
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[1].fp[0]), Bytes_val(p) + 2 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[1].fp[1]), Bytes_val(p) + 3 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[2].fp[0]), Bytes_val(p) + 4 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[0].fp2[2].fp[1]), Bytes_val(p) + 5 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[0].fp[0]), Bytes_val(p) + 6 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[0].fp[1]), Bytes_val(p) + 7 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[1].fp[0]), Bytes_val(p) + 8 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[1].fp[1]), Bytes_val(p) + 9 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[2].fp[0]),
                       Bytes_val(p) + 10 * 48);
  blst_fp_from_lendian(&(buffer_c->fp6[1].fp2[2].fp[1]),
                       Bytes_val(p) + 11 * 48);

  CAMLreturn(Val_unit);
}

// P1

#define Blst_p1_val(v) (*((blst_p1 **)Data_custom_val(v)))

#define Blst_p1_affine_val(v) (*((blst_p1_affine **)Data_custom_val(v)))

static void finalize_free_p1(value v) { free(Blst_p1_val(v)); }

static void finalize_free_p1_affine(value v) { free(Blst_p1_affine_val(v)); }

static struct custom_operations blst_p1_ops = {"blst_p1",
                                               finalize_free_p1,
                                               custom_compare_default,
                                               custom_hash_default,
                                               custom_serialize_default,
                                               custom_deserialize_default,
                                               custom_compare_ext_default,
                                               custom_fixed_length_default};

static struct custom_operations blst_p1_affine_ops = {
    "blst_p1_affine",           finalize_free_p1_affine,
    custom_compare_default,     custom_hash_default,
    custom_serialize_default,   custom_deserialize_default,
    custom_compare_ext_default, custom_fixed_length_default};

CAMLprim value allocate_p1_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block = caml_alloc_custom(&blst_p1_ops, sizeof(blst_p1 *), 0, 1);
  void *p = calloc(1, sizeof(blst_p1));
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_p1 **d = (blst_p1 **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value allocate_p1_affine_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block =
      caml_alloc_custom(&blst_p1_affine_ops, sizeof(blst_p1_affine *), 0, 1);
  void *p = calloc(1, sizeof(blst_p1_affine));
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_p1_affine **d = (blst_p1_affine **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value caml_blst_p1_to_affine_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_p1_to_affine(Blst_p1_affine_val(buffer), Blst_p1_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p1_from_affine_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_p1_from_affine(Blst_p1_val(buffer), Blst_p1_affine_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p1_double_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_p1_double(Blst_p1_val(buffer), Blst_p1_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p1_add_or_double_stubs(value buffer, value p,
                                                value q) {
  CAMLparam3(buffer, p, q);
  blst_p1_add_or_double(Blst_p1_val(buffer), Blst_p1_val(p), Blst_p1_val(q));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p1_is_inf_stubs(value p) {
  CAMLparam1(p);
  bool r = blst_p1_is_inf(Blst_p1_val(p));
  CAMLreturn(Val_bool(r));
}

CAMLprim value caml_blst_p1_in_g1_stubs(value p) {
  CAMLparam1(p);
  bool r = blst_p1_in_g1(Blst_p1_val(p));
  CAMLreturn(Val_bool(r));
}

CAMLprim value caml_blst_p1_equal_stubs(value p, value q) {
  CAMLparam2(p, q);
  bool r = blst_p1_is_equal(Blst_p1_val(p), Blst_p1_val(q));
  CAMLreturn(Val_bool(r));
}

CAMLprim value caml_blst_p1_cneg_stubs(value p, value b) {
  CAMLparam2(p, b);
  blst_p1_cneg(Blst_p1_val(p), Bool_val(b));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p1_mult_stubs(value buffer, value p, value n,
                                       value size) {
  CAMLparam4(buffer, p, n, size);
  blst_p1_mult(Blst_p1_val(buffer), Blst_p1_val(p), Bytes_val(n),
               ctypes_size_t_val(size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p1_serialize_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_p1_serialize(Bytes_val(buffer), Blst_p1_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p1_compress_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_p1_compress(Bytes_val(buffer), Blst_p1_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p1_deserialize_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  int r = blst_p1_deserialize(Blst_p1_affine_val(buffer), Bytes_val(p));
  CAMLreturn(Val_int(r));
}

CAMLprim value caml_blst_p1_uncompress_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  int r = blst_p1_uncompress(Blst_p1_affine_val(buffer), Bytes_val(p));
  CAMLreturn(Val_int(r));
}

CAMLprim value caml_blst_p1_hash_to_curve_stubs(value buffer, value msg,
                                                value msg_length, value dst,
                                                value dst_length, value aug,
                                                value aug_length) {
  CAMLparam5(buffer, msg, msg_length, dst, dst_length);
  CAMLxparam2(aug, aug_length);
  blst_hash_to_g1(Blst_p1_val(buffer), Bytes_val(msg),
                  ctypes_size_t_val(msg_length), Bytes_val(dst),
                  ctypes_size_t_val(dst_length), Bytes_val(aug),
                  ctypes_size_t_val(aug_length));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p1_hash_to_curve_stubs_bytecode(value *argv,
                                                         int argn) {
  return caml_blst_p1_hash_to_curve_stubs(argv[0], argv[1], argv[2], argv[3],
                                          argv[4], argv[5], argv[6]);
}

CAMLprim value caml_blst_p1_memcpy_stubs(value dst, value src) {
  CAMLparam2(dst, src);
  memcpy(Blst_p1_val(dst), Blst_p1_val(src), sizeof(blst_p1));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p1_set_coordinates_stubs(value buffer, value x,
                                                  value y) {
  CAMLparam3(buffer, x, y);
  blst_p1 *buffer_c = Blst_p1_val(buffer);
  blst_fp *x_c = Blst_fp_val(x);
  blst_fp *y_c = Blst_fp_val(y);
  buffer_c->x = *x_c;
  buffer_c->y = *y_c;
  CAMLreturn(Val_unit);
}

// P2

#define Blst_p2_val(v) (*((blst_p2 **)Data_custom_val(v)))

#define Blst_p2_affine_val(v) (*((blst_p2_affine **)Data_custom_val(v)))

static void finalize_free_p2(value v) { free(Blst_p2_val(v)); }

static void finalize_free_p2_affine(value v) { free(Blst_p2_affine_val(v)); }

static struct custom_operations blst_p2_ops = {"blst_p2",
                                               finalize_free_p2,
                                               custom_compare_default,
                                               custom_hash_default,
                                               custom_serialize_default,
                                               custom_deserialize_default,
                                               custom_compare_ext_default,
                                               custom_fixed_length_default};

static struct custom_operations blst_p2_affine_ops = {
    "blst_p2_affine",           finalize_free_p2_affine,
    custom_compare_default,     custom_hash_default,
    custom_serialize_default,   custom_deserialize_default,
    custom_compare_ext_default, custom_fixed_length_default};

CAMLprim value allocate_p2_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block = caml_alloc_custom(&blst_p2_ops, sizeof(blst_p2 *), 0, 1);
  void *p = calloc(1, sizeof(blst_p2));
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_p2 **d = (blst_p2 **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value allocate_p2_affine_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block =
      caml_alloc_custom(&blst_p2_affine_ops, sizeof(blst_p2_affine *), 0, 1);
  void *p = calloc(1, sizeof(blst_p2_affine));
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_p2_affine **d = (blst_p2_affine **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value caml_blst_p2_to_affine_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_p2_to_affine(Blst_p2_affine_val(buffer), Blst_p2_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p2_from_affine_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_p2_from_affine(Blst_p2_val(buffer), Blst_p2_affine_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p2_double_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_p2_double(Blst_p2_val(buffer), Blst_p2_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p2_add_or_double_stubs(value buffer, value p,
                                                value q) {
  CAMLparam3(buffer, p, q);
  blst_p2_add_or_double(Blst_p2_val(buffer), Blst_p2_val(p), Blst_p2_val(q));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p2_is_inf_stubs(value p) {
  CAMLparam1(p);
  bool r = blst_p2_is_inf(Blst_p2_val(p));
  CAMLreturn(Val_bool(r));
}

CAMLprim value caml_blst_p2_in_g2_stubs(value p) {
  CAMLparam1(p);
  bool r = blst_p2_in_g2(Blst_p2_val(p));
  CAMLreturn(Val_bool(r));
}

CAMLprim value caml_blst_p2_equal_stubs(value p, value q) {
  CAMLparam2(p, q);
  bool r = blst_p2_is_equal(Blst_p2_val(p), Blst_p2_val(q));
  CAMLreturn(Val_bool(r));
}

CAMLprim value caml_blst_p2_cneg_stubs(value p, value b) {
  CAMLparam2(p, b);
  blst_p2_cneg(Blst_p2_val(p), Bool_val(b));
  CAMLreturn(Val_unit);
}
CAMLprim value caml_blst_p2_mult_stubs(value buffer, value p, value n,
                                       value size) {
  CAMLparam4(buffer, p, n, size);
  blst_p2_mult(Blst_p2_val(buffer), Blst_p2_val(p), Bytes_val(n),
               ctypes_size_t_val(size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p2_serialize_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_p2_serialize(Bytes_val(buffer), Blst_p2_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p2_compress_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_p2_compress(Bytes_val(buffer), Blst_p2_val(p));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p2_deserialize_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  int r = blst_p2_deserialize(Blst_p2_affine_val(buffer), Bytes_val(p));
  CAMLreturn(Val_int(r));
}

CAMLprim value caml_blst_p2_uncompress_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  int r = blst_p2_uncompress(Blst_p2_affine_val(buffer), Bytes_val(p));
  CAMLreturn(Val_int(r));
}

CAMLprim value caml_blst_p2_hash_to_curve_stubs(value buffer, value msg,
                                                value msg_length, value dst,
                                                value dst_length, value aug,
                                                value aug_length) {
  CAMLparam5(buffer, msg, msg_length, dst, dst_length);
  CAMLxparam2(aug, aug_length);
  blst_hash_to_g2(Blst_p2_val(buffer), Bytes_val(msg),
                  ctypes_size_t_val(msg_length), Bytes_val(dst),
                  ctypes_size_t_val(dst_length), Bytes_val(aug),
                  ctypes_size_t_val(aug_length));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p2_hash_to_curve_stubs_bytecode(value *argv,
                                                         int argn) {
  return caml_blst_p2_hash_to_curve_stubs(argv[0], argv[1], argv[2], argv[3],
                                          argv[4], argv[5], argv[6]);
}

CAMLprim value caml_blst_p2_memcpy_stubs(value dst, value src) {
  CAMLparam2(dst, src);
  memcpy(Blst_p2_val(dst), Blst_p2_val(src), sizeof(blst_p2));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_p2_set_coordinates_stubs(value buffer, value x,
                                                  value y) {
  CAMLparam3(buffer, x, y);
  blst_p2 *buffer_c = Blst_p2_val(buffer);
  blst_fp2 *x_c = Blst_fp2_val(x);
  blst_fp2 *y_c = Blst_fp2_val(y);
  byte out[96];

  blst_lendian_from_fp(out, &x_c->fp[0]);
  blst_lendian_from_fp(out + 48, &x_c->fp[1]);
  blst_fp_from_lendian(&buffer_c->x.fp[0], out);
  blst_fp_from_lendian(&buffer_c->x.fp[1], out + 48);

  blst_lendian_from_fp(out, &y_c->fp[0]);
  blst_lendian_from_fp(out + 48, &y_c->fp[1]);
  blst_fp_from_lendian(&buffer_c->y.fp[0], out);
  blst_fp_from_lendian(&buffer_c->y.fp[1], out + 48);

  CAMLreturn(Val_unit);
}

// Pairing

CAMLprim value caml_blst_miller_loop_stubs(value buffer, value g2, value g1) {
  CAMLparam3(buffer, g2, g1);
  blst_miller_loop(Blst_fp12_val(buffer), Blst_p2_affine_val(g2),
                   Blst_p1_affine_val(g1));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_final_exponentiation_stubs(value buffer, value p) {
  CAMLparam2(buffer, p);
  blst_final_exp(Blst_fp12_val(buffer), Blst_fp12_val(p));
  CAMLreturn(Val_unit);
}

// Signature

// Fr
#define Blst_pairing_val(v) (*((blst_pairing **)Data_custom_val(v)))

static void finalize_free_pairing(value v) { free(Blst_pairing_val(v)); }

static struct custom_operations blst_pairing_ops = {
    "blst_pairing",
    finalize_free_pairing,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
    custom_fixed_length_default};

CAMLprim value allocate_pairing_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block = caml_alloc_custom(&blst_fp12_ops, sizeof(blst_pairing *), 0, 1);
  void *p = calloc(1, blst_pairing_sizeof());
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_pairing **d = (blst_pairing **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

/* CAMLprim value caml_return_null_g2_affine(value unit) { */
/*   CAMLparam1(unit); */
/*   CAMLreturn(Blst_p2_affine_val(NULL)); */
/* }; */

CAMLprim value caml_blst_sk_to_pk_in_g1_stubs(value buffer, value scalar) {
  CAMLparam2(buffer, scalar);
  blst_sk_to_pk_in_g1(Blst_p1_val(buffer), Blst_scalar_val(scalar));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_sign_pk_in_g1_stubs(value buffer, value p, value s) {
  CAMLparam3(buffer, p, s);
  blst_sign_pk_in_g1(Blst_p2_val(buffer), Blst_p2_val(p), Blst_scalar_val(s));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_pairing_init_stubs(value buffer, value check,
                                            value dst, value dst_length) {
  CAMLparam4(buffer, check, dst, dst_length);
  blst_pairing_init(Blst_pairing_val(buffer), Bool_val(check), Bytes_val(dst),
                    ctypes_size_t_val(dst_length));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_aggregate_signature_stubs(value buffer, value g1,
                                                   value g2, value msg,
                                                   value msg_length, value aug,
                                                   value aug_length) {
  CAMLparam5(buffer, g1, g2, msg, msg_length);
  CAMLxparam2(aug, aug_length);
  int r = blst_pairing_aggregate_pk_in_g1(
      Blst_pairing_val(buffer), Blst_p1_affine_val(g1), Blst_p2_affine_val(g2),
      Bytes_val(msg), ctypes_size_t_val(msg_length), Bytes_val(aug),
      ctypes_size_t_val(aug_length));
  CAMLreturn(Val_int(r));
}

CAMLprim value caml_blst_aggregate_signature_stubs_bytecode(value *argv,
                                                            int argn) {
  return caml_blst_aggregate_signature_stubs(argv[0], argv[1], argv[2], argv[3],
                                             argv[4], argv[5], argv[6]);
}
CAMLprim value caml_blst_pairing_commit_stubs(value buffer) {
  CAMLparam1(buffer);
  blst_pairing_commit(Blst_pairing_val(buffer));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_blst_pairing_finalverify_stubs(value buffer) {
  CAMLparam1(buffer);
  bool r = blst_pairing_finalverify(Blst_pairing_val(buffer), NULL);
  CAMLreturn(Val_bool(r));
}

CAMLprim value caml_blst_pairing_chk_n_mul_n_aggr_pk_in_g1_stubs(
    value buffer, value pk, value check_pk, value signature,
    value check_signature, value scalar, value nbits, value msg,
    value msg_length, value aug, value aug_length) {
  CAMLparam5(buffer, pk, check_pk, signature, check_signature);
  CAMLxparam5(scalar, nbits, msg, msg_length, aug);
  CAMLxparam1(aug_length);
  blst_p2_affine *signature_c;
  if (Is_none(signature)) {
    signature_c = NULL;
  } else {
    signature_c = Blst_p2_affine_val(Some_val(signature));
  }
  int r = blst_pairing_chk_n_mul_n_aggr_pk_in_g1(
      Blst_pairing_val(buffer), Blst_p1_affine_val(pk), Bool_val(check_pk),
      signature_c, Bool_val(check_signature), Bytes_val(scalar),
      ctypes_size_t_val(nbits), Bytes_val(msg), ctypes_size_t_val(msg_length),
      Bytes_val(aug), ctypes_size_t_val(aug_length));
  CAMLreturn(Val_int(r));
}

CAMLprim value caml_blst_pairing_chk_n_mul_n_aggr_pk_in_g1_stubs_bytecode(
    value *argv, int argn) {
  return caml_blst_pairing_chk_n_mul_n_aggr_pk_in_g1_stubs(
      argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7],
      argv[8], argv[9], argv[10]);
}
CAMLprim value caml_blst_signature_keygen_stubs(value buffer, value ikm,
                                                value ikm_length,
                                                value key_info,
                                                value key_info_length) {
  CAMLparam5(buffer, ikm, ikm_length, key_info, key_info_length);
  blst_keygen(Blst_scalar_val(buffer), Bytes_val(ikm),
              ctypes_size_t_val(ikm_length), Bytes_val(key_info),
              ctypes_size_t_val(key_info_length));
  CAMLreturn(Val_unit);
}
