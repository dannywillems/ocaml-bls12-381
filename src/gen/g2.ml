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

module type RAW = sig
  include Elliptic_curve_sig.RAW_BASE

  val build_from_components :
    Bytes.t -> Bytes.t -> Bytes.t -> Bytes.t -> Bytes.t option
end

module type T = sig
  include Elliptic_curve_sig.T

  (** Create a point from the coordinates. If the point is not on the curve,
      None is return. The points must be given modulo the order of Fq. The
      points are in the form (c0, c1) where x = c1 * X + c0 and y = c1 * X +
      c0. To create the point at infinity, use [zero ()] *)
  val of_z_opt : x:Z.t * Z.t -> y:Z.t * Z.t -> t option
end

module Make (Scalar : Fr.T) (Stubs : RAW) : T with module Scalar = Scalar =
struct
  exception Not_on_curve of Bytes.t

  type t = Bytes.t

  let size_in_bytes = Stubs.size_in_bytes

  module Scalar = Scalar

  let empty () = Bytes.make size_in_bytes '\000'

  let check_bytes bs =
    if Bytes.length bs = size_in_bytes then Stubs.check_bytes bs else false

  let of_bytes_opt bs = if check_bytes bs then Some (Bytes.copy bs) else None

  let of_bytes_exn (g : Bytes.t) : t =
    if check_bytes g then Bytes.copy g else raise (Not_on_curve g)

  let of_compressed_bytes_opt b =
    if Stubs.check_compressed_bytes b then
      let b = Stubs.uncompressed_of_compressed_unsafe b in
      Some b
    else None

  let of_compressed_bytes_exn b =
    if Stubs.check_compressed_bytes b then
      let b = Stubs.uncompressed_of_compressed_unsafe b in
      b
    else raise (Not_on_curve b)

  let to_bytes g = g

  let to_compressed_bytes b =
    let res = Stubs.compressed_of_uncompressed b in
    res

  let zero =
    let res = Stubs.zero () in
    res

  let one =
    let res = Stubs.one () in
    res

  let random ?state () =
    ignore state ;
    let res = Stubs.random () in
    res

  let add g1 g2 =
    assert (Bytes.length g1 = size_in_bytes) ;
    assert (Bytes.length g2 = size_in_bytes) ;
    let res = Stubs.add g1 g2 in
    assert (Bytes.length res = size_in_bytes) ;
    res

  let negate g =
    assert (Bytes.length g = size_in_bytes) ;
    let res = Stubs.negate g in
    assert (Bytes.length res = size_in_bytes) ;
    res

  let eq g1 g2 =
    assert (Bytes.length g1 = size_in_bytes) ;
    assert (Bytes.length g2 = size_in_bytes) ;
    Stubs.eq g1 g2

  let is_zero g =
    assert (Bytes.length g = size_in_bytes) ;
    Stubs.is_zero g

  let double g =
    assert (Bytes.length g = size_in_bytes) ;
    let res = Stubs.double g in
    assert (Bytes.length res = size_in_bytes) ;
    res

  let mul (g : t) (a : Scalar.t) : t =
    assert (Bytes.length g = size_in_bytes) ;
    assert (Bytes.length (Scalar.to_bytes a) = Scalar.size_in_bytes) ;
    let res = Stubs.mul g (Scalar.to_bytes a) in
    assert (Bytes.length res = size_in_bytes) ;
    res

  let fft ~domain ~points =
    let n = List.length domain in
    let m = List.length points in
    let points = Array.of_list points in
    (* Using Array to get a better complexity for `get` *)
    let domain = Array.of_list domain in
    (* height is the height in the rec call tree *)
    (* k is the starting index of the branch *)
    let rec inner height k number_p =
      let step = 1 lsl height in
      if number_p = 1 then Array.make (n / step) points.(k)
      else
        let q = number_p / 2 and r = number_p mod 2 in
        let odd_fft = inner (height + 1) (k + step) q in
        let even_fft = inner (height + 1) k (q + r) in
        let output_length = n lsr height in
        let output = Array.make output_length zero in
        let length_odd = n lsr (height + 1) in
        for i = 0 to length_odd - 1 do
          let x = even_fft.(i) in
          let y = odd_fft.(i) in
          (* most of the computation should be spent here *)
          let right = mul y domain.(i * step) in
          output.(i) <- add x right ;
          output.(i + length_odd) <- add x (negate right)
        done ;
        output
    in
    Array.to_list (inner 0 0 m)

  let ifft ~domain ~points =
    let power = List.length domain in
    assert (power = List.length points) ;
    let points = fft ~domain ~points in
    let power_inv = Scalar.inverse_exn (Scalar.of_z (Z.of_int power)) in
    List.map (fun g -> mul g power_inv) points

  let of_z_opt ~x ~y =
    let (x_1, x_2) = x in
    let (y_1, y_2) = y in
    let x_1_bytes = Bytes.make 48 '\000' in
    let x_1 = Bytes.of_string (Z.to_bits x_1) in
    Bytes.blit x_1 0 x_1_bytes 0 (min (Bytes.length x_1) 48) ;
    let x_2_bytes = Bytes.make 48 '\000' in
    let x_2 = Bytes.of_string (Z.to_bits x_2) in
    Bytes.blit x_2 0 x_2_bytes 0 (min (Bytes.length x_2) 48) ;
    let y_1_bytes = Bytes.make 48 '\000' in
    let y_1 = Bytes.of_string (Z.to_bits y_1) in
    Bytes.blit y_1 0 y_1_bytes 0 (min (Bytes.length y_1) 48) ;
    let y_2_bytes = Bytes.make 48 '\000' in
    let y_2 = Bytes.of_string (Z.to_bits y_2) in
    Bytes.blit y_2 0 y_2_bytes 0 (min (Bytes.length y_2) 48) ;
    let res =
      Stubs.build_from_components x_1_bytes x_2_bytes y_1_bytes y_2_bytes
    in
    match res with None -> None | Some res -> Some (of_bytes_exn res)
end
