module Stubs = Blst_bindings.StubsPairing (Blst_stubs)
module StubsG1 = Blst_bindings.StubsG1 (Blst_stubs)
module StubsG2 = Blst_bindings.StubsG2 (Blst_stubs)
module StubsFq12 = Blst_bindings.StubsFq12 (Blst_stubs)

exception FailToComputeFinalExponentiation of Fq12.t

let miller_loop_simple g1 g2 =
  let buffer = Blst_bindings.Types.allocate_fq12 () in
  let g1_affine = Blst_bindings.Types.allocate_g1_affine () in
  let g2_affine = Blst_bindings.Types.allocate_g2_affine () in
  StubsG1.to_affine g1_affine g1 ;
  StubsG2.to_affine g2_affine g2 ;
  Stubs.miller_loop buffer g2_affine g1_affine ;
  buffer

let miller_loop l =
  let rec aux acc ps =
    match ps with
    | [] -> acc
    | (g1, g2) :: ps ->
        let acc = Fq12.(mul acc (miller_loop_simple g1 g2)) in
        aux acc ps
  in
  aux Fq12.one l

let final_exponentiation_opt x =
  if Fq12.is_zero x then None
  else
    let buffer = Blst_bindings.Types.allocate_fq12 () in
    Stubs.final_exponentiation buffer x ;
    Some buffer

let final_exponentiation_exn x =
  if Fq12.is_zero x then raise (FailToComputeFinalExponentiation x)
  else
    let buffer = Blst_bindings.Types.allocate_fq12 () in
    Stubs.final_exponentiation buffer x ;
    buffer

let pairing g1 g2 =
  let ml = miller_loop_simple g1 g2 in
  final_exponentiation_exn ml
