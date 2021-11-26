(*****************************************************************************)
(*                                                                           *)
(* Copyright (c) 2020-2021 Danny Willems <be.danny.willems@gmail.com>        *)
(*                                                                           *)
(* Permission is hereby granted, free of charge, to any person obtaining a   *)
(* copy of this software and associated documentation files (the "Software"),*)
(* to deal in the Software without restriction, including without limitation *)
(* the rights to use, copy, modify, merge, publish, distribute, sublicense,  *)
(* and/or sell copies of the Software, and to permit persons to whom the     *)
(* Software is furnished to do so, subject to the following conditions:      *)
(*                                                                           *)
(* The above copyright notice and this permission notice shall be included   *)
(* in all copies or substantial portions of the Software.                    *)
(*                                                                           *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*)
(* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  *)
(* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL   *)
(* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*)
(* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING   *)
(* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER       *)
(* DEALINGS IN THE SOFTWARE.                                                 *)
(*                                                                           *)
(*****************************************************************************)

module Stubs = struct
  type affine

  type jacobian

  external allocate_g2 : unit -> jacobian = "allocate_p2_stubs"

  external allocate_g2_affine : unit -> affine = "allocate_p2_affine_stubs"

  external from_affine : jacobian -> affine -> unit
    = "caml_blst_p2_from_affine_stubs"

  external to_affine : affine -> jacobian -> unit
    = "caml_blst_p2_to_affine_stubs"

  external double : jacobian -> jacobian -> unit = "caml_blst_p2_double_stubs"

  external dadd : jacobian -> jacobian -> jacobian -> unit
    = "caml_blst_p2_add_or_double_stubs"

  external is_zero : jacobian -> bool = "caml_blst_p2_is_inf_stubs"

  external in_g2 : jacobian -> bool = "caml_blst_p2_in_g2_stubs"

  external equal : jacobian -> jacobian -> bool = "caml_blst_p2_equal_stubs"

  external cneg : jacobian -> bool -> unit = "caml_blst_p2_cneg_stubs"

  external mult : jacobian -> jacobian -> Bytes.t -> Unsigned.Size_t.t -> unit
    = "caml_blst_p2_mult_stubs"

  external deserialize : affine -> Bytes.t -> int
    = "caml_blst_p2_deserialize_stubs"

  external serialize : Bytes.t -> jacobian -> unit
    = "caml_blst_p2_serialize_stubs"

  external compress : Bytes.t -> jacobian -> unit
    = "caml_blst_p2_compress_stubs"

  external uncompress : affine -> Bytes.t -> int
    = "caml_blst_p2_uncompress_stubs"

  external hash_to_curve :
    jacobian ->
    Bytes.t ->
    Unsigned.Size_t.t ->
    Bytes.t ->
    Unsigned.Size_t.t ->
    Bytes.t ->
    Unsigned.Size_t.t ->
    unit
    = "caml_blst_p2_hash_to_curve_stubs_bytecode" "caml_blst_p2_hash_to_curve_stubs"

  external memcpy : jacobian -> jacobian -> unit = "caml_blst_p2_memcpy_stubs"

  external set_affine_coordinates : affine -> Fq2.t -> Fq2.t -> unit
    = "caml_blst_p2_set_coordinates_stubs"

  external fft_inplace : jacobian array -> Fr.Stubs.fr array -> int -> unit
    = "caml_fft_g2_inplace_stubs"

  external pippenger :
    jacobian -> jacobian array -> Unsigned.Size_t.t -> Fr.t array -> unit
    = "caml_blst_g2_pippenger"

  external mul_map_inplace : jacobian array -> Fr.Stubs.fr -> int -> unit
    = "caml_mul_map_g2_inplace_stubs"
end

module G2 = struct
  type t = Stubs.jacobian

  exception Not_on_curve of Bytes.t

  let size_in_bytes = 192

  let memcpy dst src = Stubs.memcpy dst src

  let copy src =
    let dst = Stubs.allocate_g2 () in
    memcpy dst src ;
    dst

  let global_buffer = Stubs.allocate_g2 ()

  module Scalar = Fr

  let empty () = Stubs.allocate_g2 ()

  let check_bytes bs =
    let buffer = Stubs.allocate_g2_affine () in
    Stubs.deserialize buffer bs = 0

  let of_bytes_opt bs =
    let buffer_affine = Stubs.allocate_g2_affine () in
    if Bytes.length bs <> size_in_bytes then None
    else
      let res = Stubs.deserialize buffer_affine bs in
      if res = 0 then (
        let buffer = Stubs.allocate_g2 () in
        Stubs.from_affine buffer buffer_affine ;
        let is_in_prime_subgroup = Stubs.in_g2 buffer in
        if is_in_prime_subgroup then Some buffer else None )
      else None

  let of_bytes_exn bs =
    match of_bytes_opt bs with None -> raise (Not_on_curve bs) | Some p -> p

  let of_compressed_bytes_opt bs =
    let buffer_affine = Stubs.allocate_g2_affine () in
    let res = Stubs.uncompress buffer_affine bs in
    if res = 0 then (
      let buffer = Stubs.allocate_g2 () in
      Stubs.from_affine buffer buffer_affine ;
      let is_in_prime_subgroup = Stubs.in_g2 buffer in
      if is_in_prime_subgroup then Some buffer else None )
    else None

  let of_compressed_bytes_exn bs =
    match of_compressed_bytes_opt bs with
    | None -> raise (Not_on_curve bs)
    | Some p -> p

  let zero =
    let bytes =
      Bytes.of_string
        "\192\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"
    in
    of_compressed_bytes_exn bytes

  let one =
    let bytes =
      Bytes.of_string
        "\147\224+`Rq\159`}\172\211\160\136'OeYk\208\208\153 \
         \182\026\181\218a\187\220\127PI3L\241\018\019\148]W\229\172}\005]\004+~\002J\162\178\240\143\n\
         \145&\b\005'-\197\016Q\198\228z\212\250@;\
         \002\180Q\011dz\227\209w\011\172\003&\168\005\187\239\212\128V\200\193!\189\184"
    in
    of_compressed_bytes_exn bytes

  let size_in_memory = Obj.reachable_words (Obj.magic one) * 8

  let to_bytes p =
    let buffer = Bytes.make size_in_bytes '\000' in
    Stubs.serialize buffer p ;
    buffer

  let to_compressed_bytes p =
    let buffer = Bytes.make (size_in_bytes / 2) '\000' in
    Stubs.compress buffer p ;
    buffer

  let add x y =
    (* dadd must be used to be complete. add does not work when it is the same
       point
    *)
    let buffer = Stubs.allocate_g2 () in
    Stubs.dadd buffer x y ;
    buffer

  let add_inplace x y =
    Stubs.dadd global_buffer x y ;
    memcpy x global_buffer

  let add_bulk xs =
    let buffer = Stubs.allocate_g2 () in
    List.iter (fun x -> Stubs.dadd buffer buffer x) xs ;
    buffer

  let double x =
    let buffer = Stubs.allocate_g2 () in
    Stubs.double buffer x ;
    buffer

  let mul_bits g bytes =
    let buffer = Stubs.allocate_g2 () in
    Stubs.mult buffer g bytes (Unsigned.Size_t.of_int (Bytes.length bytes * 8)) ;
    buffer

  let mul g n =
    let bytes = Fr.to_bytes n in
    mul_bits g bytes

  let mul_inplace g n =
    let bytes = Fr.to_bytes n in
    Stubs.mult
      global_buffer
      g
      bytes
      (Unsigned.Size_t.of_int (Bytes.length bytes * 8)) ;
    memcpy g global_buffer

  let b =
    let buffer = Fq2.Stubs.allocate_fp2 () in
    let fq_four = Fq.(one + one + one + one) in
    let bytes = Fq.to_bytes fq_four in
    Fq2.Stubs.of_bytes_components buffer bytes bytes ;
    buffer

  let clear_cofactor p =
    let bytes =
      Z.of_string_base
        16
        "5d543a95414e7f1091d50792876a202cd91de4547085abaa68a205b2e5a7ddfa628f1cb4d9e82ef21537e293a6691ae1616ec6e786f0c70cf1c38e31c7238e5"
    in
    let bytes = Bytes.of_string (Z.to_bits bytes) in
    let res = mul_bits p bytes in
    res

  let rec random ?state () =
    (match state with None -> () | Some state -> Random.set_state state) ;
    let x = Fq2.random () in
    let xx = Fq2.(x * x) in
    let xxx = Fq2.(x * xx) in
    let xxx_plus_b = Fq2.(xxx + b) in
    let y_opt = Fq2.sqrt_opt xxx_plus_b in
    match y_opt with
    | None -> random ()
    | Some y ->
        let y = if Random.bool () then y else Fq2.negate y in
        (* Printf.printf *)
        (*   "x = %s\ny = %s\n" *)
        (*   Hex.(show (Hex.of_bytes (Fq2.to_bytes x))) *)
        (*   Hex.(show (Hex.of_bytes (Fq2.to_bytes y))) ; *)
        let p_affine = Stubs.allocate_g2_affine () in
        Stubs.set_affine_coordinates p_affine x y ;
        let p = Stubs.allocate_g2 () in
        Stubs.from_affine p p_affine ;
        (* Printf.printf "Serialized: %s\n" (Hex.show (Hex.of_bytes (to_bytes p))) ; *)
        let p = clear_cofactor p in
        p

  let eq g1 g2 = Stubs.equal g1 g2

  let is_zero x = eq x zero

  let order_minus_one = Scalar.(negate one)

  let negate g =
    let buffer = copy g in
    Stubs.cneg buffer true ;
    buffer

  let of_z_opt ~x ~y =
    let (x1, x2) = x in
    let (y1, y2) = y in
    let x1_bytes = Bytes.of_string (Z.to_bits x1) in
    let x2_bytes = Bytes.of_string (Z.to_bits x2) in
    let y1_bytes = Bytes.of_string (Z.to_bits y1) in
    let y2_bytes = Bytes.of_string (Z.to_bits y2) in
    let x = Fq2.Stubs.allocate_fp2 () in
    let y = Fq2.Stubs.allocate_fp2 () in
    Fq2.Stubs.of_bytes_components x x1_bytes x2_bytes ;
    Fq2.Stubs.of_bytes_components y y1_bytes y2_bytes ;
    let p_affine = Stubs.allocate_g2_affine () in
    Stubs.set_affine_coordinates p_affine x y ;
    let p = Stubs.allocate_g2 () in
    Stubs.from_affine p p_affine ;
    let is_ok = Stubs.in_g2 p in
    if is_ok then Some p else None

  module M = struct
    type group = t

    type scalar = Scalar.t

    let zero = zero

    let inverse_exn_scalar = Scalar.inverse_exn

    let scalar_of_z = Scalar.of_z

    let fft_inplace = Stubs.fft_inplace

    let mul_map_inplace = Stubs.mul_map_inplace

    let copy = copy
  end

  let fft ~domain ~points = Fft.fft (module M) ~domain ~points

  let ifft ~domain ~points = Fft.ifft (module M) ~domain ~points

  let fft_inplace ~domain ~points =
    let logn = Z.log2 (Z.of_int (Array.length points)) in
    Stubs.fft_inplace points domain logn

  let ifft_inplace ~domain ~points =
    let n = Array.length points in
    let logn = Z.log2 (Z.of_int n) in
    let n_inv = Fr.inverse_exn (Fr.of_z (Z.of_int n)) in
    Stubs.fft_inplace points domain logn ;
    Stubs.mul_map_inplace points n_inv n

  let hash_to_curve message dst =
    let message_length = Bytes.length message in
    let dst_length = Bytes.length dst in
    let buffer = Stubs.allocate_g2 () in
    Stubs.hash_to_curve
      buffer
      message
      (Unsigned.Size_t.of_int message_length)
      dst
      (Unsigned.Size_t.of_int dst_length)
      Bytes.empty
      Unsigned.Size_t.zero ;
    buffer

  let pippenger ps ss =
    let n = Array.length ps in
    if n = 1 then mul ps.(0) ss.(0)
    else
      let buffer = Stubs.allocate_g2 () in
      Stubs.pippenger buffer ps (Unsigned.Size_t.of_int n) ss ;
      buffer
end

include G2
