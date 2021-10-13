#include "blst.h"
#include "fft.h"

CAMLprim value caml_fft_fr_inplace_stubs(value coefficients, value domain,
                                         value log_domain_size) {

  CAMLparam3(coefficients, domain, log_domain_size);
  fft_fr_inplace(coefficients, domain, Int_val(log_domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_fft_g1_inplace_stubs(value coefficients, value domain,
                                         value log_domain_size) {

  CAMLparam3(coefficients, domain, log_domain_size);
  fft_g1_inplace(coefficients, domain, Int_val(log_domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_fft_g2_inplace_stubs(value coefficients, value domain,
                                         value log_domain_size) {

  CAMLparam3(coefficients, domain, log_domain_size);
  fft_g2_inplace(coefficients, domain, Int_val(log_domain_size));
  CAMLreturn(Val_unit);
}
