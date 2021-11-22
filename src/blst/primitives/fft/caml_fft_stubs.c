#include "blst.h"
#include "fft.h"

CAMLprim value caml_fft_fr_inplace_stubs(value coefficients, value domain,
                                         value log_domain_size) {

  CAMLparam3(coefficients, domain, log_domain_size);
  ocaml_bls12_381_fft_fr_inplace(coefficients, domain,
                                 Int_val(log_domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_mul_map_fr_inplace_stubs(value coefficients, value factor,
                                             value domain_size) {
  CAMLparam3(coefficients, factor, domain_size);
  ocaml_bls12_381_mul_map_fr_inplace(coefficients, factor,
                                     Int_val(domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_fft_g1_inplace_stubs(value coefficients, value domain,
                                         value log_domain_size) {

  CAMLparam3(coefficients, domain, log_domain_size);
  ocaml_bls12_381_fft_g1_inplace(coefficients, domain,
                                 Int_val(log_domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_mul_map_g1_inplace_stubs(value coefficients, value factor,
                                             value domain_size) {
  CAMLparam3(coefficients, factor, domain_size);
  ocaml_bls12_381_mul_map_g1_inplace(coefficients, factor,
                                     Int_val(domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_fft_g2_inplace_stubs(value coefficients, value domain,
                                         value log_domain_size) {

  CAMLparam3(coefficients, domain, log_domain_size);
  ocaml_bls12_381_fft_g2_inplace(coefficients, domain,
                                 Int_val(log_domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_mul_map_g2_inplace_stubs(value coefficients, value factor,
                                             value domain_size) {
  CAMLparam3(coefficients, factor, domain_size);
  ocaml_bls12_381_mul_map_g2_inplace(coefficients, factor,
                                     Int_val(domain_size));
  CAMLreturn(Val_unit);
}
