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

// P1

static struct custom_operations blst_p1_ops = {"blst_p1",
                                               custom_finalize_default,
                                               custom_compare_default,
                                               custom_hash_default,
                                               custom_serialize_default,
                                               custom_deserialize_default,
                                               custom_compare_ext_default,
                                               custom_fixed_length_default};

#define Blst_p1_val(v) (*((blst_p1 **)Data_custom_val(v)))

static struct custom_operations blst_p1_affine_ops = {
    "blst_p1_affine",           custom_finalize_default,
    custom_compare_default,     custom_hash_default,
    custom_serialize_default,   custom_deserialize_default,
    custom_compare_ext_default, custom_fixed_length_default};

#define Blst_p1_affine_val(v) (*((blst_p1_affine **)Data_custom_val(v)))

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

// Signature
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
