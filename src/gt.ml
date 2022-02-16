(* Wrapper over Fq12, implementing the group in additive notation *)

module Stubs = struct
  type t = Fq12.Stubs.fp12

  external is_in_group : t -> bool = "caml_blst_fp12_in_group_stubs"
end

module GT = struct
  type t = Stubs.t

  let check_bytes b =
    let x = Fq12.of_bytes_opt b in
    match x with None -> false | Some x -> Stubs.is_in_group x

  exception Not_in_group of Bytes.t

  let order = Fr.order

  let zero = Fq12.one

  let one = Pairing.pairing G1.one G2.one

  let size_in_memory = Obj.reachable_words (Obj.magic zero) * 8

  let size_in_bytes = Fq12.size_in_bytes

  let eq = Fq12.eq

  let is_zero x = eq x zero

  let is_one x = eq x one

  let add = Fq12.mul

  let negate = Fq12.inverse_exn

  let mul x n = Fq12.pow x (Fr.to_z n)

  let to_bytes = Fq12.to_bytes

  let of_bytes_opt b =
    let x = Fq12.of_bytes_opt b in
    match x with
    | None -> None
    | Some x -> if Stubs.is_in_group x then Some x else None

  let of_bytes_exn b =
    match of_bytes_opt b with None -> raise (Not_in_group b) | Some x -> x

  let random ?state () =
    let r = Fr.random ?state () in
    mul one r
end

include GT
