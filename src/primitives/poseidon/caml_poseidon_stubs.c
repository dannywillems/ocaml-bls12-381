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

/*
  A context is a contiguous C piece of memory containing the state, the ark and
  the MDS in the following way:

  | state[0] | state[1] | ... | state[W - 1] | ark[0] | ark[1] ... | ark[N] |
    MDS[0][0] | MDS[0][1] | ... | MDS[0][W - 1] | ... | MDS[W - 1][W - 1] |

  The goal is to use the CPU cache and use the instance parameters as values on
  the stack
  */
CAMLprim value caml_poseidon_allocate_ctxt_stubs(value width,
                                                 value nb_full_rounds,
                                                 value nb_partial_rounds,
                                                 value batch_size, value ark,
                                                 value mds) {
  // ark and mds are of correct size. We do not perform any check
  CAMLparam5(width, nb_full_rounds, nb_partial_rounds, batch_size, ark);
  CAMLxparam1(mds);
  CAMLlocal1(block);
  int width_c = Int_val(width);
  int nb_full_rounds_c = Int_val(nb_full_rounds);
  int nb_partial_rounds_c = Int_val(nb_partial_rounds);
  int batch_size_c = Int_val(batch_size);
  int nb_constants = poseidon_compute_number_of_constants(
      batch_size_c, nb_partial_rounds_c, nb_full_rounds_c, width_c);
  // state + ark length + MDS
  int nb_blst_fr_elem = width + nb_constants + width * width;
  block =
      caml_alloc_custom(&blst_fr_ops, sizeof(blst_fr) * nb_blst_fr_elem, 0, 1);
  blst_fr *ctxt = Blst_fr_val(block);
  blst_fr *ctxt_ark = ctxt + width_c;
  blst_fr *ctxt_mds = ctxt + width_c + nb_constants;
  // Copying ark
  for (int i = 0; i < nb_constants; i++) {
    memcpy(ctxt_ark + i, Fr_val_k(ark, i), sizeof(blst_fr));
  }
  // Copying MDS
  for (int i = 0; i < width_c; i++) {
    for (int j = 0; j < width_c; j++) {
      memcpy(ctxt_mds + i * width_c + j, Fr_val_ij(mds, i, j), sizeof(blst_fr));
    }
  }
  CAMLreturn(block);
}

CAMLprim value caml_poseidon_allocate_ctxt_stubs_bytecode(value *argv,
                                                          value argc) {
  return caml_poseidon_allocate_ctxt_stubs(argv[0], argv[1], argv[2], argv[3],
                                           argv[4], argv[5]);
}

CAMLprim value caml_poseidon_init_stubs(value ctxt, value width, value inputs) {
  CAMLparam3(ctxt, width, inputs);
  blst_fr *ctxt_c = Blst_fr_val(ctxt);
  int width_c = Int_val(width);
  for (int i = 0; i < width_c; i++) {
    memcpy(ctxt_c + i, Fr_val_k(inputs, i), sizeof(blst_fr));
  }
  CAMLreturn(Val_unit);
}

CAMLprim value caml_poseidon_apply_perm_stubs(value ctxt, value width,
                                              value nb_full_rounds,
                                              value nb_partial_rounds,
                                              value batch_size) {
  CAMLparam5(ctxt, width, nb_full_rounds, nb_partial_rounds, batch_size);
  poseidon_apply_perm(Blst_fr_val(ctxt), Int_val(width),
                      Int_val(nb_full_rounds), Int_val(nb_partial_rounds),
                      Int_val(batch_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_poseidon_get_state_stubs(value buffer, value ctxt,
                                             value width) {
  CAMLparam3(buffer, ctxt, width);
  int width_c = Int_val(width);
  blst_fr *ctxt_c = Blst_fr_val(ctxt);
  for (int i = 0; i < width_c; i++) {
    memcpy(Fr_val_k(buffer, i), ctxt_c + i, sizeof(blst_fr));
  }
  CAMLreturn(Val_unit);
}
