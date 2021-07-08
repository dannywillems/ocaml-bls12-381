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

module Stubs = Blst_bindings.StubsG2 (Blst_stubs)

module G2 = struct
  type t = Blst_bindings.Types.blst_g2_t Ctypes.ptr

  exception Not_on_curve of Bytes.t

  let size_in_bytes = 192

  module Scalar = Fr

  let empty () = Blst_bindings.Types.allocate_g2 ()

  let check_bytes bs =
    let buffer = Blst_bindings.Types.allocate_g2_affine () in
    Stubs.deserialize buffer (Ctypes.ocaml_bytes_start bs) = 0

  let of_bytes_opt bs =
    let buffer_affine = Blst_bindings.Types.allocate_g2_affine () in
    let res = Stubs.deserialize buffer_affine (Ctypes.ocaml_bytes_start bs) in
    if res = 0 then (
      let buffer = Blst_bindings.Types.allocate_g2 () in
      Stubs.from_affine buffer buffer_affine ;
      Some buffer )
    else None

  let of_bytes_exn bs =
    match of_bytes_opt bs with None -> raise (Not_on_curve bs) | Some p -> p

  let zero =
    let bytes =
      Hex.to_bytes
        (`Hex
          "c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    in
    of_bytes_exn bytes

  let one =
    let bytes =
      Hex.to_bytes
        (`Hex
          "93e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8")
    in
    of_bytes_exn bytes

  let of_compressed_bytes_opt bs =
    let buffer_affine = Blst_bindings.Types.allocate_g2_affine () in
    let res = Stubs.uncompress buffer_affine (Ctypes.ocaml_bytes_start bs) in
    if res = 0 then (
      let buffer = Blst_bindings.Types.allocate_g2 () in
      Stubs.from_affine buffer buffer_affine ;
      Some buffer )
    else None

  let of_compressed_bytes_exn bs =
    match of_compressed_bytes_opt bs with
    | None -> raise (Not_on_curve bs)
    | Some p -> p

  let to_bytes p =
    let buffer = Bytes.make size_in_bytes '\000' in
    Stubs.serialize (Ctypes.ocaml_bytes_start buffer) p ;
    buffer

  let to_compressed_bytes p =
    let buffer = Bytes.make (size_in_bytes / 2) '\000' in
    Stubs.compress (Ctypes.ocaml_bytes_start buffer) p ;
    buffer

  let add x y =
    let buffer = Blst_bindings.Types.allocate_g2 () in
    Stubs.add buffer x y ;
    buffer

  let double x =
    (* FIXME: I don't know why but double or dadd doesn't work. As it is just a
       PoC, I leave it like this. Addition is complete
    *)
    (* let buffer = Blst_bindings.Types.allocate_g2 () in
     * Stubs.dadd buffer x x ;
     * buffer *)
    add x x

  let mul_bits g bytes =
    let buffer = Blst_bindings.Types.allocate_g2 () in
    Stubs.mult
      buffer
      g
      (Ctypes.ocaml_bytes_start bytes)
      (Unsigned.Size_t.of_int (Bytes.length bytes * 8)) ;
    buffer

  let mul g n =
    let bytes = Fr.to_bytes n in
    mul_bits g bytes

  let b =
    let buffer = Blst_bindings.Types.allocate_fq2 () in
    let fq_four = Fq.(one + one + one + one) in
    Blst_bindings.Types.fq2_assign buffer fq_four fq_four ;
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
        let p_affine = Blst_bindings.Types.allocate_g2_affine () in
        Blst_bindings.Types.g2_affine_set_x p_affine x ;
        Blst_bindings.Types.g2_affine_set_y p_affine y ;
        let p = Blst_bindings.Types.allocate_g2 () in
        Stubs.from_affine p p_affine ;
        clear_cofactor p

  let eq g1 g2 = Stubs.equal g1 g2

  let is_zero x = eq x zero

  let order_minus_one = Scalar.(negate one)

  let negate g =
    let buffer = Blst_bindings.Types.g2_copy g in
    Stubs.cneg buffer true ;
    buffer

  let of_z_opt ~x ~y =
    let (x1, x2) = x in
    let (y1, y2) = y in
    let p_affine = Blst_bindings.Types.allocate_g2_affine () in
    let x1 = Fq.of_z x1 in
    let x2 = Fq.of_z x2 in
    let y1 = Fq.of_z y1 in
    let y2 = Fq.of_z y2 in
    let x = Blst_bindings.Types.allocate_fq2 () in
    let y = Blst_bindings.Types.allocate_fq2 () in
    Blst_bindings.Types.fq2_assign x x1 x2 ;
    Blst_bindings.Types.fq2_assign y y1 y2 ;
    Blst_bindings.Types.g2_affine_set_x p_affine x ;
    Blst_bindings.Types.g2_affine_set_y p_affine y ;
    let p = Blst_bindings.Types.allocate_g2 () in
    Stubs.from_affine p p_affine ;
    let is_ok = Stubs.in_g2 p in
    if is_ok then Some p else None

  let fft ~domain ~points =
    let module M = struct
      type group = t

      type scalar = Scalar.t

      let zero = zero

      let mul = mul

      let add = add

      let sub x y = add x (negate y)

      let inverse_exn_scalar = Scalar.inverse_exn

      let scalar_of_z = Scalar.of_z
    end in
    Bls12_381_gen.Fft.fft (module M) ~domain ~points

  let ifft ~domain ~points =
    let module M = struct
      type group = t

      type scalar = Scalar.t

      let zero = zero

      let mul = mul

      let add = add

      let sub x y = add x (negate y)

      let inverse_exn_scalar = Scalar.inverse_exn

      let scalar_of_z = Scalar.of_z
    end in
    Bls12_381_gen.Fft.ifft (module M) ~domain ~points
end

include G2
