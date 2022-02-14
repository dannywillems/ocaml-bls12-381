//Provides: bitreverse
function bitreverse(n, l) {
  var r = 0;
  while (l-- > 0) {
    r = (r << 1) | (n & 1);
    n = n >> 1;
  }
  return r;
}

// Fr
//Provides: reorg_fr_coefficients
//Requires: bitreverse
//Requires: blst_fr_sizeof, Blst_fr_val, caml_blst_memcpy
function reorg_fr_coefficients(n, logn, coefficients, buffer) {
  var fr_len = blst_fr_sizeof();
  for (var i = 0; i < n; i++) {
    var reverse_i = bitreverse(i, logn);
    if (i < reverse_i) {
      caml_blst_memcpy(buffer, Blst_fr_val(coefficients[i + 1]), fr_len);
      caml_blst_memcpy(
          Blst_fr_val(coefficients[i + 1]),
          Blst_fr_val(coefficients[reverse_i + 1]),
          fr_len
      );
      caml_blst_memcpy(
          Blst_fr_val(coefficients[reverse_i + 1]),
          buffer,
          fr_len
      );
    }
  }
}

//Provides: caml_fft_fr_inplace_stubs
//Requires: reorg_fr_coefficients
//Requires: Blst_scalar
//Requires: wasm_call
//Requires: Blst_fr_val
function caml_fft_fr_inplace_stubs(coefficients, domain, log_domain_size) {
  var buffer = Blst_fr_val(new Blst_scalar());
  var domain_size = 1 << log_domain_size;
  var m = 1;
  reorg_fr_coefficients(domain_size, log_domain_size, coefficients, buffer);

  for (var i = 0; i < log_domain_size; i++) {
    var exponent = domain_size / (2 * m);
    var k = 0;
    while (k < domain_size) {
      for (var j = 0; j < m; j++) {
        wasm_call(
            '_blst_fr_mul',
            buffer,
            Blst_fr_val(coefficients[k + j + m + 1]),
            Blst_fr_val(domain[exponent * j + 1])
        );
        wasm_call(
            '_blst_fr_sub',
            Blst_fr_val(coefficients[k + j + m + 1]),
            Blst_fr_val(coefficients[k + j + 1]),
            buffer
        );
        wasm_call(
            '_blst_fr_add',
            Blst_fr_val(coefficients[k + j + 1]),
            Blst_fr_val(coefficients[k + j + 1]),
            buffer
        );
      }
      k = k + 2 * m;
    }
    m = 2 * m;
  }
}

//Provides: caml_mul_map_fr_inplace_stubs
//Requires: wasm_call
//Requires: Blst_fr_val
function caml_mul_map_fr_inplace_stubs(coefficients, factor, domain_size) {
  for (var i = 0; i < domain_size; i++) {
    wasm_call(
        '_blst_fr_mul',
        Blst_fr_val(coefficients[i + 1]),
        Blst_fr_val(coefficients[i + 1]),
        Blst_fr_val(factor)
    );
  }
}

//Provides: reorg_g1_coefficients
//Requires: bitreverse
//Requires: blst_p1_sizeof, Blst_p1_val, caml_blst_memcpy
function reorg_g1_coefficients(n, logn, coefficients, buffer) {
  var p1_len = blst_p1_sizeof();
  for (var i = 0; i < n; i++) {
    var reverse_i = bitreverse(i, logn);
    if (i < reverse_i) {
      caml_blst_memcpy(buffer, Blst_p1_val(coefficients[i + 1]), p1_len);
      caml_blst_memcpy(
          Blst_p1_val(coefficients[i + 1]),
          Blst_p1_val(coefficients[reverse_i + 1]),
          p1_len
      );
      caml_blst_memcpy(
          Blst_p1_val(coefficients[reverse_i + 1]),
          buffer,
          p1_len
      );
    }
  }
}

//Provides: caml_fft_g1_inplace_stubs
//Requires: Blst_p1, Blst_scalar, reorg_g1_coefficients
//Requires: wasm_call
//Requires: Blst_p1_val, Blst_fr_val, Blst_scalar_val
//Requires: caml_blst_memcpy, blst_p1_sizeof
function caml_fft_g1_inplace_stubs(coefficients, domain, log_domain_size) {
  var buffer = Blst_p1_val(new Blst_p1());
  var buffer_neg = Blst_p1_val(new Blst_p1());
  var scalar = Blst_scalar_val(new Blst_scalar());
  var le_scalar = new globalThis.Uint8Array(32);

  var domain_size = 1 << log_domain_size;
  var m = 1;
  reorg_g1_coefficients(domain_size, log_domain_size, coefficients, buffer);

  for (var i = 0; i < log_domain_size; i++) {
    var exponent = domain_size / (2 * m);
    var k = 0;
    while (k < domain_size) {
      for (var j = 0; j < m; j++) {
        wasm_call(
            '_blst_scalar_from_fr',
            scalar,
            Blst_fr_val(domain[exponent * j + 1])
        );
        wasm_call('_blst_lendian_from_scalar', le_scalar, scalar);
        wasm_call(
            '_blst_p1_mult',
            buffer,
            Blst_p1_val(coefficients[k + j + m + 1]),
            le_scalar,
            256
        );
        caml_blst_memcpy(buffer_neg, buffer, blst_p1_sizeof());
        wasm_call('_blst_p1_cneg', buffer_neg, 1);
        wasm_call(
            '_blst_p1_add_or_double',
            Blst_p1_val(coefficients[k + j + m + 1]),
            Blst_p1_val(coefficients[k + j + 1]),
            buffer_neg
        );

        wasm_call(
            '_blst_p1_add_or_double',
            Blst_p1_val(coefficients[k + j + 1]),
            Blst_p1_val(coefficients[k + j + 1]),
            buffer
        );
      }
      k = k + 2 * m;
    }
    m = 2 * m;
  }
}

//Provides: caml_mul_map_g1_inplace_stubs
//Requires: wasm_call
//Requires: Blst_scalar, Blst_scalar_val, Blst_fr_val, Blst_p2_val, Blst_p1_val
function caml_mul_map_g1_inplace_stubs(coefficients, factor, domain_size) {
  var scalar = Blst_scalar_val(new Blst_scalar());
  var le_scalar = new globalThis.Uint8Array(32);
  wasm_call('_blst_scalar_from_fr', scalar, Blst_fr_val(factor));
  wasm_call('_blst_lendian_from_scalar', le_scalar, scalar);

  for (var i = 0; i < domain_size; i++) {
    wasm_call(
        '_blst_p1_mult',
        Blst_p1_val(coefficients[i + 1]),
        Blst_p1_val(coefficients[i + 1]),
        le_scalar,
        256
    );
  }
}

//Provides: reorg_g2_coefficients
//Requires: bitreverse
//Requires: blst_p2_sizeof, Blst_p2_val, caml_blst_memcpy
function reorg_g2_coefficients(n, logn, coefficients, buffer) {
  var p2_len = blst_p2_sizeof();
  for (var i = 0; i < n; i++) {
    var reverse_i = bitreverse(i, logn);
    if (i < reverse_i) {
      caml_blst_memcpy(buffer, Blst_p2_val(coefficients[i + 1]), p2_len);
      caml_blst_memcpy(
          Blst_p2_val(coefficients[i + 1]),
          Blst_p2_val(coefficients[reverse_i + 1]),
          p2_len
      );
      caml_blst_memcpy(
          Blst_p2_val(coefficients[reverse_i + 1]),
          buffer,
          p2_len
      );
    }
  }
}

//Provides: caml_fft_g2_inplace_stubs
//Requires: Blst_p2, Blst_scalar, reorg_g2_coefficients
//Requires: wasm_call
//Requires: Blst_p2_val, Blst_fr_val, Blst_scalar_val
//Requires: caml_blst_memcpy, blst_p2_sizeof
function caml_fft_g2_inplace_stubs(coefficients, domain, log_domain_size) {
  var buffer = Blst_p2_val(new Blst_p2());
  var buffer_neg = Blst_p2_val(new Blst_p2());
  var scalar = Blst_scalar_val(new Blst_scalar());
  var le_scalar = new globalThis.Uint8Array(32);

  var domain_size = 1 << log_domain_size;
  var m = 1;
  reorg_g2_coefficients(domain_size, log_domain_size, coefficients, buffer);

  for (var i = 0; i < log_domain_size; i++) {
    var exponent = domain_size / (2 * m);
    var k = 0;
    while (k < domain_size) {
      for (var j = 0; j < m; j++) {
        wasm_call(
            '_blst_scalar_from_fr',
            scalar,
            Blst_fr_val(domain[exponent * j + 1])
        );
        wasm_call('_blst_lendian_from_scalar', le_scalar, scalar);
        wasm_call(
            '_blst_p2_mult',
            buffer,
            Blst_p2_val(coefficients[k + j + m + 1]),
            le_scalar,
            256
        );
        caml_blst_memcpy(buffer_neg, buffer, blst_p2_sizeof());
        wasm_call('_blst_p2_cneg', buffer_neg, 1);
        wasm_call(
            '_blst_p2_add_or_double',
            Blst_p2_val(coefficients[k + j + m + 1]),
            Blst_p2_val(coefficients[k + j + 1]),
            buffer_neg
        );

        wasm_call(
            '_blst_p2_add_or_double',
            Blst_p2_val(coefficients[k + j + 1]),
            Blst_p2_val(coefficients[k + j + 1]),
            buffer
        );
      }
      k = k + 2 * m;
    }
    m = 2 * m;
  }
}

//Provides: caml_mul_map_g2_inplace_stubs
//Requires: wasm_call
//Requires: Blst_scalar, Blst_scalar_val, Blst_fr_val, Blst_p2_val
function caml_mul_map_g2_inplace_stubs(coefficients, factor, domain_size) {
  var scalar = Blst_scalar_val(new Blst_scalar());
  var le_scalar = new globalThis.Uint8Array(32);
  wasm_call('_blst_scalar_from_fr', scalar, Blst_fr_val(factor));
  wasm_call('_blst_lendian_from_scalar', le_scalar, scalar);

  for (var i = 0; i < domain_size; i++) {
    wasm_call(
        '_blst_p2_mult',
        Blst_p2_val(coefficients[i + 1]),
        Blst_p2_val(coefficients[i + 1]),
        le_scalar,
        256
    );
  }
}
