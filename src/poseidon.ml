open Poseidon_utils

module Stubs = struct
  type ctxt

  external allocate_ctxt :
    width:int ->
    nb_full_rounds:int ->
    nb_partial_rounds:int ->
    batch_size:int ->
    ark:Fr.t array ->
    mds:Fr.t array array ->
    ctxt
    = "caml_poseidon_allocate_ctxt_stubs_bytecode" "caml_poseidon_allocate_ctxt_stubs"

  external init : ctxt -> width:int -> Fr.t array -> unit
    = "caml_poseidon_init_stubs"

  external apply_perm :
    ctxt ->
    width:int ->
    nb_full_rounds:int ->
    nb_partial_rounds:int ->
    batch_size:int ->
    unit = "caml_poseidon_apply_perm_stubs"

  external get_state : Fr.t array -> ctxt -> int -> unit
    = "caml_poseidon_get_state_stubs"
end

module Make (Parameters : sig
  val nb_full_rounds : int

  val nb_partial_rounds : int

  val batch_size : int

  val width : int

  val ark : Fr.t array

  val mds : Fr.t array array
end) =
struct
  open Parameters

  type ctxt = Stubs.ctxt

  let init inputs =
    if Array.length inputs <> width then
      failwith (Printf.sprintf "The inputs must be of size %d" width) ;
    let modified_ark =
      let ( arc_full_round_start_with_first_partial,
            arc_intermediate_state,
            arc_unbatched,
            arc_full_round_end ) =
        compute_updated_constants
          nb_partial_rounds
          nb_full_rounds
          width
          batch_size
          ark
          mds
      in
      Array.concat
        [ arc_full_round_start_with_first_partial;
          arc_intermediate_state;
          arc_unbatched;
          arc_full_round_end;
          (* Adding dummy constants, zeroes, for the last round as we apply the
             round key at the end of a full round. *)
          Array.init width (fun _ -> Fr.(copy zero)) ]
    in
    let mds_nb_rows = Array.length mds in
    let mds_nb_cols = Array.length mds.(0) in
    if mds_nb_cols <> mds_nb_rows then
      failwith "The parameter MDS must be a square matrix" ;
    let ctxt =
      Stubs.allocate_ctxt
        ~width
        ~nb_full_rounds
        ~nb_partial_rounds
        ~batch_size
        ~ark:modified_ark
        ~mds
    in
    Stubs.init ctxt ~width inputs ;
    ctxt

  let apply_permutation ctxt =
    Stubs.apply_perm ctxt ~width ~nb_full_rounds ~nb_partial_rounds ~batch_size

  let get ctxt =
    let res = Array.init width (fun _ -> Fr.(copy zero)) in
    Stubs.get_state res ctxt width ;
    res
end
