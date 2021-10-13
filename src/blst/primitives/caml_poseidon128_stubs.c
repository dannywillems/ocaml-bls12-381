#include "blst.h"
#include "poseidon128.h"
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <stdlib.h>
#include <string.h>

#define Poseidon128_ctxt_val(v) (*((poseidon128_ctxt_t **)Data_custom_val(v)))

#define Blst_fr_val(v) (*((blst_fr **)Data_custom_val(v)))

static void finalize_free_poseidon128_ctxt(value v) {
  free(Poseidon128_ctxt_val(v));
}

static struct custom_operations poseidon128_ctxt_ops = {
    "poseidon_128_ctxt_t",      finalize_free_poseidon128_ctxt,
    custom_compare_default,     custom_hash_default,
    custom_serialize_default,   custom_deserialize_default,
    custom_compare_ext_default, custom_fixed_length_default};

CAMLprim value caml_poseidon128_allocate_ctxt_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block = caml_alloc_custom(&poseidon128_ctxt_ops, sizeof(poseidon128_ctxt_t *),
                            0, 1);
  void *p = calloc(1, sizeof(poseidon128_ctxt_t));
  if (p == NULL)
    caml_raise_out_of_memory();
  poseidon128_ctxt_t **d = (poseidon128_ctxt_t **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value caml_poseidon128_constants_init_stubs(value unit) {
  CAMLparam1(unit);
  poseidon128_constants_init();
  CAMLreturn(Val_unit);
}

CAMLprim value caml_poseidon128_finalize_stubs(value unit) {
  CAMLparam1(unit);
  poseidon128_finalize();
  CAMLreturn(Val_unit);
}

CAMLprim value caml_poseidon128_init_stubs(value ctxt, value a, value b,
                                           value c) {
  CAMLparam4(ctxt, a, b, c);
  poseidon128_init(Poseidon128_ctxt_val(ctxt), Blst_fr_val(a), Blst_fr_val(b),
                   Blst_fr_val(c));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_poseidon128_apply_perm_stubs(value ctxt) {
  CAMLparam1(ctxt);
  poseidon128_apply_perm(Poseidon128_ctxt_val(ctxt));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_poseidon128_get_state_stubs(value a, value b, value c,
                                                value ctxt) {
  CAMLparam4(a, b, c, ctxt);
  poseidon128_get_state(Blst_fr_val(a), Blst_fr_val(b), Blst_fr_val(c),
                        Poseidon128_ctxt_val(ctxt));
  CAMLreturn(Val_unit);
}
