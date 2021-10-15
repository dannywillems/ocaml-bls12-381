#include "blst.h"
#include "fft.h"

CAMLprim value caml_fft_fr_inplace_stubs(value coefficients, value domain,
                                         value log_domain_size) {

  CAMLparam3(coefficients, domain, log_domain_size);
  fft_fr_inplace(coefficients, domain, Int_val(log_domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_mul_map_fr_inplace_stubs(value coefficients, value factor,
                                             value domain_size) {
  CAMLparam3(coefficients, factor, domain_size);
  mul_map_fr_inplace(coefficients, factor, Int_val(domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_fft_g1_inplace_stubs(value coefficients, value domain,
                                         value log_domain_size) {

  CAMLparam3(coefficients, domain, log_domain_size);
  fft_g1_inplace(coefficients, domain, Int_val(log_domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_mul_map_g1_inplace_stubs(value coefficients, value factor,
                                             value domain_size) {
  CAMLparam3(coefficients, factor, domain_size);
  mul_map_g1_inplace(coefficients, factor, Int_val(domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_fft_g2_inplace_stubs(value coefficients, value domain,
                                         value log_domain_size) {

  CAMLparam3(coefficients, domain, log_domain_size);
  fft_g2_inplace(coefficients, domain, Int_val(log_domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_mul_map_g2_inplace_stubs(value coefficients, value factor,
                                             value domain_size) {
  CAMLparam3(coefficients, factor, domain_size);
  mul_map_g2_inplace(coefficients, factor, Int_val(domain_size));
  CAMLreturn(Val_unit);
}

CAMLprim value caml_allocate_fr_array_stubs(value n) {
  CAMLparam1(n);
  CAMLlocal1(block);
  block = caml_alloc_custom(&blst_fr_array_ops, sizeof(blst_fr *), 0, 1);
  void *p = calloc(ctypes_size_t_val(n), sizeof(blst_fr));
  if (p == NULL)
    caml_raise_out_of_memory();
  blst_fr **d = (blst_fr**)Data_custom_val(block);
  *d = p;
  CAMLreturn(block);
}


CAMLprim value caml_to_fr_array_stubs(value buffer, value vs, value n) {
  // NB - H: vs and buffer are of size n
  CAMLparam3(buffer, vs, n);

  blst_fr *buffer_c = Blst_fr_array_val(buffer);
  size_t buffer_size = ctypes_size_t_val(n);
  for(size_t i = 0; i < buffer_size; i++) {
    memcpy(buffer_c + i, Fr_val_k(vs, i), sizeof(blst_fr));
  }
  CAMLreturn(Val_unit);
}

CAMLprim value caml_of_fr_array_stubs(value buffer, value vs, value n) {
  // NB - H: vs and buffer are of size n
  CAMLparam3(buffer, vs, n);

  blst_fr *vs_c = Blst_fr_array_val(vs);
  size_t buffer_size = ctypes_size_t_val(n);
  for(size_t i = 0; i < buffer_size; i++) {
    memcpy(Fr_val_k(buffer, i), vs_c + i, sizeof(blst_fr));
  }
  CAMLreturn(Val_unit);
}


void reorg_fr_array_coefficients(int n, int logn, blst_fr *coefficients,
                                blst_fr *buffer) {
  for (int i = 0; i < n; i++) {
    int reverse_i = bitreverse(i, logn);
    if (i < reverse_i) {
      memcpy(buffer, coefficients + i, sizeof(blst_fr));
      memcpy(coefficients + i, coefficients + reverse_i, sizeof(blst_fr));
      memcpy(coefficients + reverse_i, buffer, sizeof(blst_fr));
    }
  }
}

CAMLprim value caml_blst_fft_on_fr_array_stubs(value coefficients, value domain, value log_domain_size) {
  // FIXME: add a check on the domain_size to avoid ariane crash
  CAMLparam3(coefficients, domain, log_domain_size);
  blst_fr *buffer = (blst_fr *)calloc(1, sizeof(blst_fr));

  int log_domain_size_c = Int_val(log_domain_size);
  blst_fr *domain_c = Blst_fr_array_val(domain);
  blst_fr *coefficients_c = Blst_fr_array_val(coefficients);
  int domain_size = 1 << log_domain_size_c;
  int m = 1;
  reorg_fr_array_coefficients(domain_size, log_domain_size_c, coefficients_c, buffer);

  for (int i = 0; i < log_domain_size_c; i++) {
    int exponent = domain_size / (2 * m);
    int k = 0;
    while (k < domain_size) {
      for (int j = 0; j < m; j++) {
        blst_fr_mul(buffer, coefficients_c + (k + j + m),
                    domain_c + (exponent * j));
        blst_fr_sub(coefficients_c + (k + j + m),
                    coefficients_c + (k + j), buffer);
        blst_fr_add(coefficients_c + (k + j),
                    coefficients_c + (k + j), buffer);
      }
      k = k + (2 * m);
    }
    m = 2 * m;
  }
  CAMLreturn(Val_unit);
}

// mul by coeff !!
