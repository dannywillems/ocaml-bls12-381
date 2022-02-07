#include "blst.h"
#include "rescue.h"
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <stdlib.h>
#include <string.h>

#include "caml_bls12_381_stubs.h"

#define Rescue_ctxt_val(v) (*((rescue_ctxt_t **)Data_custom_val(v)))

#define Fr_val_i(v, i) Blst_fr_val(Field(v, i))

#define Fr_val_ij(v, i, j) Blst_fr_val(Field(Field(v, i), j))

static void finalize_free_rescue_ctxt(value v) { free(Rescue_ctxt_val(v)); }

static struct custom_operations rescue_ctxt_ops = {"rescue_ctxt_t",
                                                   finalize_free_rescue_ctxt,
                                                   custom_compare_default,
                                                   custom_hash_default,
                                                   custom_serialize_default,
                                                   custom_deserialize_default,
                                                   custom_compare_ext_default,
                                                   custom_fixed_length_default};

CAMLprim value caml_rescue_allocate_ctxt_stubs(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(block);
  block = caml_alloc_custom(&rescue_ctxt_ops, sizeof(rescue_ctxt_t *), 0, 1);
  void *p = calloc(1, sizeof(rescue_ctxt_t));
  if (p == NULL)
    caml_raise_out_of_memory();
  rescue_ctxt_t **d = (rescue_ctxt_t **)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}

CAMLprim value caml_rescue_constants_init_stubs(value vark, value vmds,
                                                value vark_len,
                                                value vmds_nb_rows,
                                                value vmds_nb_cols) {

  CAMLparam5(vark, vmds, vark_len, vmds_nb_rows, vmds_nb_cols);
  int ark_len = Int_val(vark_len);
  int mds_nb_rows = Int_val(vmds_nb_rows);
  int mds_nb_cols = Int_val(vmds_nb_cols);

  blst_fr *ark = (blst_fr *)calloc(ark_len, sizeof(blst_fr));
  blst_fr **mds = (blst_fr **)calloc(mds_nb_rows, sizeof(blst_fr *));
  for (int i = 0; i < mds_nb_rows; i++) {
    mds[i] = (blst_fr *)calloc(mds_nb_cols, sizeof(blst_fr));
    for (int j = 0; j < mds_nb_cols; j++) {
      memcpy(&mds[i][j], Fr_val_ij(vmds, i, j), sizeof(blst_fr));
    }
  }

  for (int i = 0; i < ark_len; i++) {
    memcpy(ark + i, Fr_val_i(vark, i), sizeof(blst_fr));
  }

  int res = rescue_constants_init(ark, mds, ark_len, mds_nb_rows, mds_nb_cols);

  free(ark);
  for (int i = 0; i < mds_nb_rows; i++) {
    free(mds[i]);
  }
  free(mds);
  CAMLreturn(Val_int(res));
}

CAMLprim value caml_rescue_init_stubs(value ctxt, value a, value b, value c) {
  CAMLparam4(ctxt, a, b, c);
  rescue_init(Rescue_ctxt_val(ctxt), Blst_fr_val(a), Blst_fr_val(b),
              Blst_fr_val(c));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_rescue_apply_perm_stubs(value ctxt) {
  CAMLparam1(ctxt);
  marvellous_apply_perm(Rescue_ctxt_val(ctxt));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_rescue_get_state_stubs(value a, value b, value c,
                                           value ctxt) {
  CAMLparam4(a, b, c, ctxt);
  rescue_get_state(Blst_fr_val(a), Blst_fr_val(b), Blst_fr_val(c),
                   Rescue_ctxt_val(ctxt));
  CAMLreturn(Val_unit);
}
