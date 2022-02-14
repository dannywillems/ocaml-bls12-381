//Provides: Rescue_ctxt_val
function Rescue_ctxt_val(v) {
  return v.v;
}

//Provides: rescue_ctxt_sizeof
//Requires: wasm_call
function rescue_ctxt_sizeof() {
  return wasm_call('_rescue_ctxt_sizeof');
}

//Provides: Rescue_ctxt
//Requires: rescue_ctxt_sizeof
function Rescue_ctxt() {
  this.v = new globalThis.Uint8Array(rescue_ctxt_sizeof());
}

//Provides: caml_rescue_allocate_ctxt_stubs
//Requires: Rescue_ctxt
function caml_rescue_allocate_ctxt_stubs(unit) {
  return new Rescue_ctxt();
}

//Provides: caml_rescue_constants_init_stubs
//Requires: blst_fr_sizeof, Blst_fr_val
//Requires: wasm_call
function caml_rescue_constants_init_stubs(
    vark,
    vmds,
    ark_len,
    mds_nb_rows,
    mds_nb_cols
) {
  var fr_len = blst_fr_sizeof();
  var ark = new globalThis.Uint8Array(ark_len * fr_len);
  var mds = new Array(mds_nb_rows);
  for (var i = 0; i < mds_nb_rows; i++) {
    mds[i] = new globalThis.Uint8Array(mds_nb_cols * fr_len);
    for (var j = 0; j < mds_nb_cols; j++) {
      mds[i].set(Blst_fr_val(vmds[i + 1][j + 1]), fr_len * j);
    }
  }

  for (var i = 0; i < ark_len; i++) {
    ark.set(Blst_fr_val(vark[i + 1]), fr_len * i);
  }

  var res = wasm_call(
      '_rescue_constants_init',
      ark,
      mds,
      ark_len,
      mds_nb_rows,
      mds_nb_cols
  );

  return res;
}

//Provides: caml_rescue_init_stubs
//Requires: Rescue_ctxt_val, Blst_fr_val, wasm_call
function caml_rescue_init_stubs(ctxt, a, b, c) {
  wasm_call(
      '_rescue_init',
      Rescue_ctxt_val(ctxt),
      Blst_fr_val(a),
      Blst_fr_val(b),
      Blst_fr_val(c)
  );
  return 0;
}

//Provides: caml_rescue_apply_perm_stubs
//Requires: Rescue_ctxt_val, wasm_call
function caml_rescue_apply_perm_stubs(ctxt) {
  wasm_call('_marvellous_apply_perm', Rescue_ctxt_val(ctxt));
  return 0;
}

//Provides: caml_rescue_get_state_stubs
//Requires: Blst_fr_val, Rescue_ctxt_val, wasm_call
function caml_rescue_get_state_stubs(a, b, c, ctxt) {
  wasm_call(
      '_rescue_get_state',
      Blst_fr_val(a),
      Blst_fr_val(b),
      Blst_fr_val(c),
      Rescue_ctxt_val(ctxt)
  );
  return 0;
}
