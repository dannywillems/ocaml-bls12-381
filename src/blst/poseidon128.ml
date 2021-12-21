module Stubs = struct
  type ctxt

  external allocate_ctxt : unit -> ctxt = "caml_poseidon128_allocate_ctxt_stubs"

  external constants_init :
    Fr.t array -> Fr.t array array -> int -> int -> int -> int
    = "caml_poseidon128_constants_init_stubs"

  external init : ctxt -> Fr.t -> Fr.t -> Fr.t -> unit
    = "caml_poseidon128_init_stubs"

  external apply_perm : ctxt -> unit = "caml_poseidon128_apply_perm_stubs"

  external get_state : Fr.t -> Fr.t -> Fr.t -> ctxt -> unit
    = "caml_poseidon128_get_state_stubs"
end

type ctxt = Stubs.ctxt

let constants_init ark mds =
  let ark_len = Array.length ark in
  let mds_nb_rows = Array.length mds in
  assert (mds_nb_rows > 0) ;
  let mds_nb_cols = Array.length mds.(0) in
  assert (0 = Stubs.constants_init ark mds ark_len mds_nb_rows mds_nb_cols)

let init s =
  let ctxt = Stubs.allocate_ctxt () in
  Stubs.init ctxt s.(0) s.(1) s.(2) ;
  ctxt

let apply_perm ctxt = Stubs.apply_perm ctxt

let get ctxt =
  let a = Fr.Stubs.mallocate_fr () in
  let b = Fr.Stubs.mallocate_fr () in
  let c = Fr.Stubs.mallocate_fr () in
  Stubs.get_state a b c ctxt ;
  [| a; b; c |]
