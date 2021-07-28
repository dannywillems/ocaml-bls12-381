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

module Fq12 : Bls12_381_gen.Fq12.T

module Fr : Bls12_381_gen.Fr.T

module G1 : Bls12_381_gen.G1.T with type Scalar.t = Fr.t

module G2 : Bls12_381_gen.G2.T with type Scalar.t = Fr.t

module Pairing : sig
  exception FailToComputeFinalExponentiation of Fq12.t

  val miller_loop : (G1.t * G2.t) list -> Fq12.t

  (** Compute the miller loop on a single tuple of point *)
  val miller_loop_simple : G1.t -> G2.t -> Fq12.t

  (** Compute a pairing result of a list of points *)
  val pairing : G1.t -> G2.t -> Fq12.t

  (** Compute the final exponentiation of the given point. Returns a [None] if
        the point is null *)
  val final_exponentiation_opt : Fq12.t -> Fq12.t option

  (** Compute the final exponentiation of the given point. Raise
        [FailToComputeFinalExponentiation] if the point is null *)
  val final_exponentiation_exn : Fq12.t -> Fq12.t
end

(** Follow https://tools.ietf.org/pdf/draft-irtf-cfrg-bls-signature-04.pdf *)
module Signature : sig
  (** Type of the secret keys. *)
  type sk

  (** Type of the public keys *)
  type pk

  (* Not abstracting the type to avoid to write (de)serialisation routines *)
  type signature = Bytes.t

  (** [sk_of_bytes_exn bs] attempts to deserialize [bs] into a secret key. [bs]
      must be the little endian representation of the secret key.
      In this case, secret keys are scalars of BLS12-381 and are encoded on 32
      bytes. The bytes sequence might be less of 32 bytes and in this case, the
      bytes sequence is padded on the right by 0's. If the bytes sequence is
      longer than 32 bytes, raise [Invalid_argument].
  *)
  val sk_of_bytes_exn : Bytes.t -> sk

  (** [sk_to_bytes sk] serialises the secret key into the little endian
      representation.
  *)
  val sk_to_bytes : sk -> Bytes.t

  val unsafe_pk_of_bytes : Bytes.t -> pk

  val pk_of_bytes_exn : Bytes.t -> pk

  val pk_of_bytes_opt : Bytes.t -> pk option

  val pk_to_bytes : pk -> Bytes.t

  (** [generate_sk ?key_info ikm] generates a new (random) secret key. [ikm]
       must be at least 32 bytes (otherwise, raise [Invalid_argument]). The
       default value of [key_info] is the empty bytes sequence.
  *)
  val generate_sk : ?key_info:Bytes.t -> Bytes.t -> sk

  (** [derive_pk sk] derives the corresponding public key of [sk]. *)
  val derive_pk : sk -> pk

  (** [aggregate_signature_opt signatures] aggregates the signatures [signatures], following
      https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-2.8.
      Return [None] if [INVALID] is expected in the specification
  *)
  val aggregate_signature_opt : Bytes.t list -> Bytes.t option

  (**
    https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.1

    In a basic scheme, rogue key attacks are handled by requiring all
    messages signed by an aggregate signature to be distinct.  This
    requirement is enforced in the definition of AggregateVerify.

    The Sign and Verify functions are identical to CoreSign and
    CoreVerify (Section 2), respectively.
  *)
  module Basic : sig
    val sign : sk -> Bytes.t -> signature

    val verify : pk -> Bytes.t -> signature -> bool

    (** raise [Invalid_argument] if the messages are not distinct *)
    val aggregate_verify : (pk * Bytes.t) list -> signature -> bool
  end

  (**
    https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.2

    In a message augmentation scheme, signatures are generated over the
    concatenation of the public key and the message, ensuring that
    messages signed by different public keys are distinct.
  *)
  module Aug : sig
    val sign : sk -> Bytes.t -> signature

    val verify : pk -> Bytes.t -> signature -> bool

    val aggregate_verify : (pk * Bytes.t) list -> signature -> bool
  end

  (**
     https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3

     A proof of possession scheme uses a separate public key validation
     step, called a proof of possession, to defend against rogue key
     attacks.  This enables an optimization to aggregate signature
     verification for the case that all signatures are on the same
     message.
  *)

  module Pop : sig
    type proof = Bytes.t

    (** Equivalent to [core_sign] with the DST given in the specification
        https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-4.2.3
    *)
    val sign : sk -> Bytes.t -> signature

    (** Equivalent to [core_verify] with the DST given in the specification
        https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-4.2.3
    *)
    val verify : pk -> Bytes.t -> signature -> bool

    (** [pop_proof sk] implements
         https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3.2
    *)
    val pop_prove : sk -> proof

    (** [pop_verify pk signature] implements
        https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3.3
    *)
    val pop_verify : pk -> proof -> bool

    (**
      [aggregate_verify pks msg aggregated_signature] performs a aggregate
      signature verification. It supposes the same message [msg] has been
      signed.
    *)
    val aggregate_verify : (pk * proof) list -> Bytes.t -> signature -> bool
  end
end
