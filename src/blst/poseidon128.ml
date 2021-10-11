module Stubs = struct
  type ctxt

  external allocate_ctxt : unit -> ctxt = "caml_poseidon128_allocate_ctxt_stubs"

  external constants_init : unit -> unit
    = "caml_poseidon128_constants_init_stubs"

  external finalize : unit -> unit = "caml_poseidon128_finalize_stubs"

  external init : ctxt -> Fr.t -> Fr.t -> Fr.t -> unit
    = "caml_poseidon128_init_stubs"

  external apply_perm : ctxt -> unit = "caml_poseidon128_apply_perm_stubs"

  external get_state : Fr.t -> Fr.t -> Fr.t -> ctxt -> unit
    = "caml_poseidon128_get_state_stubs"
end

type ctxt = Stubs.ctxt

let () = Stubs.constants_init ()

let init s =
  let ctxt = Stubs.allocate_ctxt () in
  Stubs.init ctxt s.(0) s.(1) s.(2) ;
  ctxt

let apply_perm ctxt = Stubs.apply_perm ctxt

let get ctxt =
  let a = Fr.Stubs.allocate_fr () in
  let b = Fr.Stubs.allocate_fr () in
  let c = Fr.Stubs.allocate_fr () in
  Stubs.get_state a b c ctxt ;
  [| a; b; c |]

let finalize = Stubs.finalize
