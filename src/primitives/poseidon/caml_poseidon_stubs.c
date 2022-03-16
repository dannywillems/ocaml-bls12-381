#include "blst.h"
#include "blst_misc.h"

#define CAML_NAME_SPACE
#include "caml_bls12_381_stubs.h"
#include "ocaml_integers.h"
#include "poseidon.h"
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <stdlib.h>
#include <string.h>

#define Poseidon_ctxt_val(v) (*((poseidon_ctxt_t **)Data_custom_val(v)))

static void finalize_free_poseidon_ctxt(value ctxt) {
  poseidon_ctxt_t *ctxt_c = Poseidon_ctxt_val(ctxt);
  // free state
  if (ctxt_c->s != NULL) {
    free(ctxt_c->s);
  }
  // free ark
  if (ctxt_c->ark != NULL) {
    free(ctxt_c->ark);
  }
  // free mds, line by line
  if (ctxt_c->mds != NULL) {
    for (int i = 0; i < ctxt_c->width; i++) {
      if (ctxt_c->mds[i] != NULL) {
        free(ctxt_c->mds[i]);
      }
    }
    free(ctxt_c->mds);
  }
  free(ctxt_c);
}

static struct custom_operations poseidon_ctxt_ops = {
    "poseidon_ctxt_t",          finalize_free_poseidon_ctxt,
    custom_compare_default,     custom_hash_default,
    custom_serialize_default,   custom_deserialize_default,
    custom_compare_ext_default, custom_fixed_length_default};

CAMLprim value caml_poseidon_allocate_ctxt_stubs(value width,
                                                 value nb_full_rounds,
                                                 value nb_partial_rounds,
                                                 value batch_size, value ark,
                                                 value mds) {
  // ark and mds are of correct size. We do not perform any check
  CAMLparam5(width, nb_full_rounds, nb_partial_rounds, batch_size, ark);
  CAMLxparam1(mds);
  CAMLlocal1(block);
  block =
      caml_alloc_custom(&poseidon_ctxt_ops, sizeof(poseidon_ctxt_t *), 0, 1);
  void *p = calloc(1, sizeof(poseidon_ctxt_t));
  if (p == NULL)
    caml_raise_out_of_memory();
  poseidon_ctxt_t **d = (poseidon_ctxt_t **)Data_custom_val(block);
  *d = p;
  int width_c = Int_val(width);
  int nb_full_rounds_c = Int_val(nb_full_rounds);
  int nb_partial_rounds_c = Int_val(nb_partial_rounds);
  int batch_size_c = Int_val(batch_size);
  (*d)->nb_partial_rounds = nb_partial_rounds_c;
  (*d)->nb_full_rounds = nb_full_rounds_c;
  (*d)->batch_size = batch_size_c;
  (*d)->width = width_c;
  // always the last element. The optimisation is only implemented when the
  // partial rounds are applied on the last element of the state.
  (*d)->partial_round_idx_sbox = width_c - 1;
  // we allocate the state
  (*d)->s = calloc(width_c, sizeof(blst_fr));
  if ((*d)->s == NULL) {
    caml_raise_out_of_memory();
  }
  // we allocate the MDS
  (*d)->mds = calloc(width_c, sizeof(blst_fr *));
  if ((*d)->mds == NULL) {
    caml_raise_out_of_memory();
  }
  for (int i = 0; i < width_c; i++) {
    (*d)->mds[i] = calloc(width_c, sizeof(blst_fr));
    if ((*d)->mds[i] == NULL) {
      caml_raise_out_of_memory();
    }
  }
  // we allocate the ark
  int nb_constants = poseidon_compute_number_of_constants((*d));
  (*d)->ark = calloc(nb_constants, sizeof(blst_fr));
  if ((*d)->ark == NULL) {
    caml_raise_out_of_memory();
  }
  // Copying ark
  for (int i = 0; i < nb_constants; i++) {
    memcpy((*d)->ark + i, Fr_val_k(ark, i), sizeof(blst_fr));
  }
  // Copying MDS
  for (int i = 0; i < width_c; i++) {
    for (int j = 0; j < width_c; j++) {
      memcpy(&((*d)->mds[i][j]), Fr_val_ij(mds, i, j), sizeof(blst_fr));
    }
  }
  CAMLreturn(block);
}

CAMLprim value caml_poseidon_allocate_ctxt_stubs_bytecode(value *argv,
                                                          value argc) {
  return caml_poseidon_allocate_ctxt_stubs(argv[0], argv[1], argv[2], argv[3],
                                           argv[4], argv[5]);
}

CAMLprim value caml_poseidon_init_stubs(value ctxt, value inputs) {
  CAMLparam2(ctxt, inputs);
  poseidon_ctxt_t *ctxt_c = Poseidon_ctxt_val(ctxt);
  for (int i = 0; i < ctxt_c->width; i++) {
    memcpy(ctxt_c->s + i, Fr_val_k(inputs, i), sizeof(blst_fr));
  }
  CAMLreturn(Val_unit);
}

CAMLprim value caml_poseidon_apply_perm_stubs(value ctxt) {
  CAMLparam1(ctxt);
  poseidon_apply_perm(Poseidon_ctxt_val(ctxt));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_poseidon_get_state_stubs(value buffer, value ctxt) {
  CAMLparam2(buffer, ctxt);
  poseidon_ctxt_t *ctxt_c = Poseidon_ctxt_val(ctxt);
  for (int i = 0; i < ctxt_c->width; i++) {
    memcpy(Fr_val_k(buffer, i), ctxt_c->s + i, sizeof(blst_fr));
  }
  CAMLreturn(Val_unit);
}
