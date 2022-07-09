#include "blst.h"
#include "blst_misc.h"

#include "anemoi.h"
#include "caml_bls12_381_stubs.h"

#include <caml/memory.h>
#include <caml/mlvalues.h>

value caml_anemoi_jive128_1_compress_stubs(value vres, value vx, value vy) {
  CAMLparam3(vres, vx, vy);
  anemoi_jive128_1_compress(Blst_fr_val(vres), Blst_fr_val(vx),
                            Blst_fr_val(vy));
  CAMLreturn(Val_unit);
}
