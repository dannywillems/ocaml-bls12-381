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

module Fr : sig
  include Ff_sig.PRIME

  (** Actual number of bytes allocated for a value of type t *)
  val size_in_memory : int

  (** Check if a point, represented as a byte array, is in the field **)
  val check_bytes : Bytes.t -> bool

  (** [fft ~domain ~points] performs a Fourier transform on [points] using
      [domain] The domain should be of the form [w^{i}] where [w] is a principal
      root of unity. If the domain is of size [n], [w] must be a [n]-th
      principal root of unity. The number of points can be smaller than the
      domain size, but not larger. The complexity is in [O(n log(m))] where [n]
      is the domain size and [m] the number of points. A new array of size [n]
      is allocated and is returned. The parameters are not modified. *)
  val fft : domain:t array -> points:t array -> t array

  (** [fft_inplace ~domain ~points] performs a Fourier transform on [points]
      using [domain] The domain should be of the form [w^{i}] where [w] is a
      principal root of unity. If the domain is of size [n], [w] must be a
      [n]-th principal root of unity. The number of points must be in the same
      size than the domain. It does not return anything but modified the points
      directly. It does only perform one allocation of a scalar for the FFT. It
      is recommended to use this function if side-effect is acceptable. *)
  val fft_inplace : domain:t array -> points:t array -> unit

  (** [ifft ~domain ~points] performs an inverse Fourier transform on [points]
      using [domain]. The domain should be of the form [w^{-i}] (i.e the
      "inverse domain") where [w] is a principal root of unity. If the domain is
      of size [n], [w] must be a [n]-th principal root of unity. The domain size
      must be exactly the same than the number of points. The complexity is O(n
      log(n)) where [n] is the domain size. A new array of size [n] is allocated
      and is returned. The parameters are not modified. *)
  val ifft : domain:t array -> points:t array -> t array

  val ifft_inplace : domain:t array -> points:t array -> unit

  val add_inplace : t -> t -> unit

  val sub_inplace : t -> t -> unit

  val mul_inplace : t -> t -> unit

  val inverse_exn_inplace : t -> unit

  val double_inplace : t -> unit

  val square_inplace : t -> unit

  val negate_inplace : t -> unit

  (** [copy x] return a fresh copy of [x] *)
  val copy : t -> t

  val add_bulk : t list -> t

  val mul_bulk : t list -> t

  (** [compare a b] compares the elements [a] and [b] based on their bytes
      representation *)
  val compare : t -> t -> int

  (** [inner_product_exn a b] returns the inner product of [a] and [b], i.e.
      sum(a_i * b_i). Raise [Invalid_argument] if the arguments are not of the
      same length *)
  val inner_product_exn : t array -> t array -> t

  (** Same than {!inner_product_exn} but returns an option instead of raising an
      exception *)
  val inner_product_opt : t array -> t array -> t option

  (** [of_int x] is equivalent to [of_z (Z.of_int x)]. If [x] is is negative,
      returns the element [order - |x|]. *)
  val of_int : int -> t
end

module type CURVE = sig
  exception Not_on_curve of Bytes.t

  (** The type of the element on the curve and in the prime subgroup. The point
      is given in jacobian coordinates *)
  type t

  (** An element on the curve and in the prime subgroup, in affine coordinates *)
  type affine

  (** [affine_of_jacobian p] creates a new value of type [affine] representing
      the point [p] in affine coordinates *)
  val affine_of_jacobian : t -> affine

  (** [jacobian_of_affine p] creates a new value of type [t] representing the
      point [p] in jacobian coordinates *)
  val jacobian_of_affine : affine -> t

  (** Contiguous C array containing points in affine coordinates *)
  type affine_array

  (** [to_affine_array pts] builds a contiguous C array and populate it with the
      points [pts] in affine coordinates. Use it with
      {!pippenger_with_affine_array} to get better performance. *)
  val to_affine_array : t array -> affine_array

  (** Build a OCaml array of [t] values from the contiguous C array *)
  val of_affine_array : affine_array -> t array

  (** Return the number of elements in the array *)
  val size_of_affine_array : affine_array -> int

  (** Actual number of bytes allocated for a value of type t *)
  val size_in_memory : int

  (** The size of a point representation, in bytes *)
  val size_in_bytes : int

  module Scalar : Ff_sig.PRIME with type t = Fr.t

  (** Create an empty value to store an element of the curve.

      {b Warning} Do not use this to do computations with, undefined behaviors
      may happen *)
  val empty : unit -> t

  (** Check if a point, represented as a byte array, is on the curve **)
  val check_bytes : Bytes.t -> bool

  (** Attempt to construct a point from a byte array of length {!size_in_bytes}. *)
  val of_bytes_opt : Bytes.t -> t option

  (** Attempt to construct a point from a byte array of length {!size_in_bytes}.
      Raise {!Not_on_curve} if the point is not on the curve *)
  val of_bytes_exn : Bytes.t -> t

  (** Allocates a new point from a byte of length [size_in_bytes / 2] array
      representing a point in compressed form. *)
  val of_compressed_bytes_opt : Bytes.t -> t option

  (** Allocates a new point from a byte array of length [size_in_bytes / 2]
      representing a point in compressed form. Raise {!Not_on_curve} if the
      point is not on the curve. *)
  val of_compressed_bytes_exn : Bytes.t -> t

  (** Return a representation in bytes *)
  val to_bytes : t -> Bytes.t

  (** Return a compressed bytes representation *)
  val to_compressed_bytes : t -> Bytes.t

  (** Zero of the elliptic curve *)
  val zero : t

  (** A fixed generator of the elliptic curve *)
  val one : t

  (** Return [true] if the given element is zero *)
  val is_zero : t -> bool

  (** [copy x] return a fresh copy of [x] *)
  val copy : t -> t

  (** Generate a random element. The element is on the curve and in the prime
      subgroup. *)
  val random : ?state:Random.State.t -> unit -> t

  (** Return the addition of two element *)
  val add : t -> t -> t

  val add_inplace : t -> t -> unit

  val add_bulk : t list -> t

  (** [double g] returns [2g] *)
  val double : t -> t

  (** Return the opposite of the element *)
  val negate : t -> t

  (** Return [true] if the two elements are algebraically the same *)
  val eq : t -> t -> bool

  (** Multiply an element by a scalar *)
  val mul : t -> Scalar.t -> t

  val mul_inplace : t -> Scalar.t -> unit

  (** [fft ~domain ~points] performs a Fourier transform on [points] using
      [domain] The domain should be of the form [w^{i}] where [w] is a principal
      root of unity. If the domain is of size [n], [w] must be a [n]-th
      principal root of unity. The number of points can be smaller than the
      domain size, but not larger. The complexity is in [O(n log(m))] where [n]
      is the domain size and [m] the number of points. A new array of size [n]
      is allocated and is returned. The parameters are not modified. *)
  val fft : domain:Scalar.t array -> points:t array -> t array

  (** [fft_inplace ~domain ~points] performs a Fourier transform on [points]
      using [domain] The domain should be of the form [w^{i}] where [w] is a
      principal root of unity. If the domain is of size [n], [w] must be a
      [n]-th principal root of unity. The number of points must be in the same
      size than the domain. It does not return anything but modified the points
      directly. It does only perform one allocation of a scalar for the FFT. It
      is recommended to use this function if side-effect is acceptable. *)
  val fft_inplace : domain:Scalar.t array -> points:t array -> unit

  (** [ifft ~domain ~points] performs an inverse Fourier transform on [points]
      using [domain]. The domain should be of the form [w^{-i}] (i.e the
      "inverse domain") where [w] is a principal root of unity. If the domain is
      of size [n], [w] must be a [n]-th principal root of unity. The domain size
      must be exactly the same than the number of points. The complexity is O(n
      log(n)) where [n] is the domain size. A new array of size [n] is allocated
      and is returned. The parameters are not modified. *)
  val ifft : domain:Scalar.t array -> points:t array -> t array

  val ifft_inplace : domain:Scalar.t array -> points:t array -> unit

  val hash_to_curve : Bytes.t -> Bytes.t -> t

  (** [pippenger ?start ?len pts scalars] computes the multi scalar
      exponentiation/multiplication. The scalars are given in [scalars] and the
      points in [pts]. If [pts] and [scalars] are not of the same length,
      perform the computation on the first [n] points where [n] is the smallest
      size. Arguments [start] and [len] can be used to take advantages of
      multicore OCaml. Default value for [start] (resp. [len]) is [0] (resp. the
      length of the array [scalars]).

      @raise Invalid_argument if [start] or [len] would infer out of bounds
      array access.

      Perform allocations on the C heap to convert scalars to bytes and to
      convert the points [pts] in affine coordinates as values of type [t] are
      in jacobian coordinates.

      {b Warning.} Undefined behavior if the point to infinity is in the array *)
  val pippenger : ?start:int -> ?len:int -> t array -> Scalar.t array -> t

  (** [pippenger_with_affine_array ?start ?len pts scalars] computes the multi
      scalar exponentiation/multiplication. The scalars are given in [scalars]
      and the points in [pts]. If [pts] and [scalars] are not of the same
      length, perform the computation on the first [n] points where [n] is the
      smallest size. The differences with {!pippenger} are 1. the points are
      loaded in a contiguous C array to speed up the access to the elements by
      relying on the CPU cache 2. and the points are in affine coordinates, the
      form expected by the algorithm implementation, avoiding new allocations
      and field inversions required to convert from jacobian (representation of
      a points of type [t], as expected by {!pippenger}) to affine coordinates.
      Expect a speed improvement around 20% compared to {!pippenger}, and less
      allocation on the C heap. A value of [affine_array] can be built using
      {!to_affine_array}. Arguments [start] and [len] can be used to take
      advantages of multicore OCaml. Default value for [start] (resp. [len]) is
      [0] (resp. the length of the array [scalars]).

      @raise Invalid_argument if [start] or [len] would infer out of bounds
      array access.

      Perform allocations on the C heap to convert scalars to bytes.

      {b Warning.} Undefined behavior if the point to infinity is in the array *)
  val pippenger_with_affine_array :
    ?start:int -> ?len:int -> affine_array -> Scalar.t array -> t
end

module Fq12 : sig
  type t

  (** Minimal number of bytes required to encode a value of the group *)
  val size_in_bytes : int

  exception Not_in_field of Bytes.t

  (** The neutral element of the multiplicative subgroup *)
  val one : t

  (** [is_zero x] returns [true] if [x] is the neutral element of the additive
      subgroup *)
  val is_zero : t -> bool

  (** [is_one x] returns [true] if [x] is the neutral element for the
      multiplication *)
  val is_one : t -> bool

  val mul : t -> t -> t

  val inverse_opt : t -> t option

  val inverse_exn : t -> t

  val eq : t -> t -> bool

  val random : ?state:Random.State.t -> unit -> t

  val pow : t -> Z.t -> t

  val of_bytes_exn : Bytes.t -> t

  val of_bytes_opt : Bytes.t -> t option

  val to_bytes : t -> Bytes.t

  (** Construct an element of Fq12 based on the following pattern: Fq12 = Fq6 (
      Fq2(x: x0, y: x1)) Fq2(x: x2, y: x3)) Fq2(x: x4, y: x5)), Fq6 ( Fq2(x: x6,
      y: x7)) Fq2(x: x8, y: x9)) Fq2(x: x10, y: x11)) x0, ..., x11 are the
      parameters of the function. No check is applied.

      Example of usage (pairing result of the multiplicative neutre elements):
      Fq12.of_string
      "2819105605953691245277803056322684086884703000473961065716485506033588504203831029066448642358042597501014294104502"
      "1323968232986996742571315206151405965104242542339680722164220900812303524334628370163366153839984196298685227734799"
      "2987335049721312504428602988447616328830341722376962214011674875969052835043875658579425548512925634040144704192135"
      "3879723582452552452538684314479081967502111497413076598816163759028842927668327542875108457755966417881797966271311"
      "261508182517997003171385743374653339186059518494239543139839025878870012614975302676296704930880982238308326681253"
      "231488992246460459663813598342448669854473942105054381511346786719005883340876032043606739070883099647773793170614"
      "3993582095516422658773669068931361134188738159766715576187490305611759126554796569868053818105850661142222948198557"
      "1074773511698422344502264006159859710502164045911412750831641680783012525555872467108249271286757399121183508900634"
      "2727588299083545686739024317998512740561167011046940249988557419323068809019137624943703910267790601287073339193943"
      "493643299814437640914745677854369670041080344349607504656543355799077485536288866009245028091988146107059514546594"
      "734401332196641441839439105942623141234148957972407782257355060229193854324927417865401895596108124443575283868655"
      "2348330098288556420918672502923664952620152483128593484301759394583320358354186482723629999370241674973832318248497"
      (* source for the test vectors:
      https://docs.rs/crate/pairing/0.16.0/source/src/bls12_381/tests/mod.rs *)

      Undefined behaviours if the given elements are not in the field or any
      other representation than decimal is used. Use this function carefully.

      See https://docs.rs/crate/pairing/0.16.0/source/src/bls12_381/README.md
      for more information on the instances used by the library.

      FIXME: the function is not memory efficient because the elements are
      copied multiple times *)
  val of_string :
    String.t ->
    String.t ->
    String.t ->
    String.t ->
    String.t ->
    String.t ->
    String.t ->
    String.t ->
    String.t ->
    String.t ->
    String.t ->
    String.t ->
    t

  (** Same than [of_string], using Z.t elements FIXME: the function is not
      memory efficient because the elements are copied multiple times *)
  val of_z :
    Z.t ->
    Z.t ->
    Z.t ->
    Z.t ->
    Z.t ->
    Z.t ->
    Z.t ->
    Z.t ->
    Z.t ->
    Z.t ->
    Z.t ->
    Z.t ->
    t
end

module G1 : sig
  include CURVE

  (** Create a point from the coordinates. If the point is not on the curve,
      [None] is return. The points must be given modulo the order of Fq. To
      create the point at infinity, use [zero ()] *)
  val of_z_opt : x:Z.t -> y:Z.t -> t option
end

module G2 : sig
  include CURVE

  (** Create a point from the coordinates. If the point is not on the curve,
      None is return. The points must be given modulo the order of Fq. The
      points are in the form (c0, c1) where x = c1 * X + c0 and y = c1 * X + c0.
      To create the point at infinity, use [zero ()] *)
  val of_z_opt : x:Z.t * Z.t -> y:Z.t * Z.t -> t option
end

module GT : sig
  type t

  exception Not_in_group of Bytes.t

  val order : Z.t

  val size_in_memory : int

  val size_in_bytes : int

  val check_bytes : Bytes.t -> bool

  val of_bytes_exn : Bytes.t -> t

  val of_bytes_opt : Bytes.t -> t option

  val to_bytes : t -> Bytes.t

  val zero : t

  val is_zero : t -> bool

  val one : t

  val is_one : t -> bool

  val random : ?state:Random.State.t -> unit -> t

  val add : t -> t -> t

  val negate : t -> t

  val mul : t -> Fr.t -> t

  val eq : t -> t -> bool
end

module Pairing : sig
  exception FailToComputeFinalExponentiation of Fq12.t

  (** Compute the miller loop on a list of points. Return {!Fq12.one} if the list
      is empty *)
  val miller_loop : (G1.t * G2.t) list -> Fq12.t

  (** Compute the miller loop on a single tuple of point *)
  val miller_loop_simple : G1.t -> G2.t -> Fq12.t

  (** Compute a pairing result of a list of points *)
  val pairing : G1.t -> G2.t -> Fq12.t

  (** [pairing_check points] returns [true] if [pairing points = GT.one]. Return
      [true] if the empty list is given *)
  val pairing_check : (G1.t * G2.t) list -> bool

  (** Compute the final exponentiation of the given point. Returns a [None] if
      the point is null *)
  val final_exponentiation_opt : Fq12.t -> Fq12.t option

  (** Compute the final exponentiation of the given point.

      @raise FailToComputeFinalExponentiation if the point is null *)
  val final_exponentiation_exn : Fq12.t -> Fq12.t
end

(** Follow {{:https://tools.ietf.org/pdf/draft-irtf-cfrg-bls-signature-04.pdf}
    the BLS signature draft of CFRG, version 4} *)
module Signature : sig
  (** Type of the secret keys. *)
  type sk

  (** The size of a serialized value [sk] *)
  val sk_size_in_bytes : int

  (** [sk_of_bytes_exn bs] attempts to deserialize [bs] into a secret key. [bs]
      must be the little endian representation of the secret key. In this case,
      secret keys are scalars of BLS12-381 and are encoded on 32 bytes. The
      bytes sequence might be less of 32 bytes and in this case, the bytes
      sequence is padded on the right by 0's.

      @raise Invalid_argument if the bytes sequence is longer than 32 bytes *)
  val sk_of_bytes_exn : Bytes.t -> sk

  (** [sk_of_bytes_opt bs] is the same than {!sk_of_bytes_exn} but returns an
      option instead of an exception. *)
  val sk_of_bytes_opt : Bytes.t -> sk option

  (** [sk_to_bytes sk] serialises the secret key into the little endian
      representation. *)
  val sk_to_bytes : sk -> Bytes.t

  (** [generate_sk ?key_info ikm] generates a new (random) secret key. [ikm]
      must be at least 32 bytes (otherwise, raise [Invalid_argument]). The
      default value of [key_info] is the empty bytes sequence. *)
  val generate_sk : ?key_info:Bytes.t -> Bytes.t -> sk

  (** BLS signatures instantiation minimizing the size of the public keys (48
      bytes) but use longer signatures (96 bytes). *)
  module MinPk : sig
    (** Type of the public keys *)
    type pk

    (** The size of a serialized value [pk] *)
    val pk_size_in_bytes : int

    (** The size of a serialized value [signature] *)
    val signature_size_in_bytes : int

    (** Build a value of type {!pk} without performing any check on the input
        (hence the unsafe prefix because it might not give a correct
        inhabitant of the type [pk]).
        It is safe to use this function when verifying a signature as the
        signature function verifies if the point is in the prime subgroup. Using
        {!unsafe_pk_of_bytes} removes a verification performed twice when used
        {!pk_of_bytes_exn} or {!pk_of_bytes_opt}.

        The expected bytes format are the compressed form of a point on G1. *)
    val unsafe_pk_of_bytes : Bytes.t -> pk

    (** Build a value of type [pk] safely, i.e. the function checks the bytes
        given in parameters represents a point on the curve and in the prime
        subgroup. Raise [Invalid_argument] if the bytes are not in the correct
        format or does not represent a point in the prime subgroup.

        The expected bytes format are the compressed form of a point on G1. *)
    val pk_of_bytes_exn : Bytes.t -> pk

    (** Build a value of type {!pk} safely, i.e. the function checks the bytes
        given in parameters represents a point on the curve and in the prime
        subgroup. Return [None] if the bytes are not in the correct format or
        does not represent a point in the prime subgroup.

        The expected bytes format are the compressed form of a point on G1. *)
    val pk_of_bytes_opt : Bytes.t -> pk option

    (** Returns a bytes representation of a value of type {!pk}. The output is
        the compressed form of the point [G1.t] the [pk] represents. *)
    val pk_to_bytes : pk -> Bytes.t

    (** [derive_pk sk] derives the corresponding public key of [sk]. *)
    val derive_pk : sk -> pk

    (** Type of the signatures *)
    type signature

    (** Build a value of type {!signature} without performing any check on the
        input (hence the unsafe prefix because it might not give a correct
        inhabitant of the type [signature]).
        It is safe to use this function when verifying a signature as the
        signature function verifies if the point is in the prime subgroup. Using
        {!unsafe_signature_of_bytes} removes a verification performed twice when
        used {!signature_of_bytes_exn} or {!signature_of_bytes_opt}.

        The expected bytes format are the compressed form of a point on G2. *)
    val unsafe_signature_of_bytes : Bytes.t -> signature

    (** Build a value of type {!signature} safely, i.e. the function checks the
        bytes given in parameters represents a point on the curve and in the
        prime subgroup. Raise [Invalid_argument] if the bytes are not in the
        correct format or does not represent a point in the prime subgroup.

        The expected bytes format are the compressed form of a point on G2. *)
    val signature_of_bytes_exn : Bytes.t -> signature

    (** Build a value of type {!signature} safely, i.e. the function checks the
        bytes given in parameters represents a point on the curve and in the
        prime subgroup. Return [None] if the bytes are not in the correct format
        or does not represent a point in the prime subgroup.

        The expected bytes format are the compressed form of a point on G2. *)
    val signature_of_bytes_opt : Bytes.t -> signature option

    (** Returns a bytes representation of a value of type [signature]. The
        output is the compressed form of a point {!G2.t} the signature
        represents. *)
    val signature_to_bytes : signature -> Bytes.t

    (** [aggregate_signature_opt signatures] aggregates the signatures
        [signatures], following {{:
        https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-2.8
        } section 2.8}.
        Return [None] if [INVALID] is expected in the specification *)
    val aggregate_signature_opt : signature list -> signature option

    (** Basic scheme described in
        {{:https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.1}
        section 3.1}

        In a basic scheme, rogue key attacks are handled by requiring all
        messages signed by an aggregate signature to be distinct. This
        requirement is enforced in the definition of AggregateVerify.

        {!Basic.sign} and {!Basic.verify} implements the algorithms {{:
        https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-2.6
        } CoreSign} and {{:
        https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-2.7}
        CoreVerify}, respectively. *)
    module Basic : sig
      val sign : sk -> Bytes.t -> signature

      val verify : pk -> Bytes.t -> signature -> bool

      (** [aggregate_verify pks msg aggregated_signature] performs a aggregate
          signature verification.
          It implements the AggregateVerify algorithm specified in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.1.1
          } section 3.1.1 }. Raise [Invalid_argument] if the messages are not
          distinct. *)
      val aggregate_verify : (pk * Bytes.t) list -> signature -> bool
    end

    (** Augmentation scheme described in
        {{:https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.2}
        section 3.2}

        In a message augmentation scheme, signatures are generated over the
        concatenation of the public key and the message, ensuring that messages
        signed by different public keys are distinct. *)
    module Aug : sig
      (** [sign sk msg] implements the algorithm described in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.2.1
          } section 3.2.1 } *)
      val sign : sk -> Bytes.t -> signature

      (** [verify pk msg signature] implements the algorithm described in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.2.2
          } section 3.2.2 } *)
      val verify : pk -> Bytes.t -> signature -> bool

      (** [aggregate_verify pks msg aggregated_signature] performs a aggregate
          signature verification.
          It implements the AggregateVerify algorithm specified in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.2.3
          } section 3.2.3 }*)
      val aggregate_verify : (pk * Bytes.t) list -> signature -> bool
    end

    (** Proof of possession scheme described in
        {{:https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3}
        section 3.3}

        A proof of possession scheme uses a separate public key validation step,
        called a proof of possession, to defend against rogue key attacks. This
        enables an optimization to aggregate signature verification for the case
        that all signatures are on the same message. *)
    module Pop : sig
      type proof = Bytes.t

      (** Equivalent to [core_sign] with the DST given in the specification
          {{:https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-4.2.3}
          in section 4.2.3}. *)
      val sign : sk -> Bytes.t -> signature

      (** Equivalent to [core_verify] with the DST given in the specification
          {{:https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-4.2.3}
          in section 4.2.3}. *)
      val verify : pk -> Bytes.t -> signature -> bool

      (** [pop_proof sk] implements
          {{:https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3.2}
          section 3.3.2}. *)
      val pop_prove : sk -> proof

      (** [pop_verify pk signature] implements
          {{:https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3.3}
          section 3.3.3}. *)
      val pop_verify : pk -> proof -> bool

      (** [aggregate_verify pks msg aggregated_signature] performs a aggregate
          signature verification. It supposes the same message [msg] has been
          signed. It implements the FastAggregateVerify algorithm specified in
          {{:https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3.4}
          section 3.3.4}. *)
      val aggregate_verify : (pk * proof) list -> Bytes.t -> signature -> bool
    end
  end

  (** BLS signatures instantiation minimizing the size of the signatures (48
      bytes) but use longer public keys (96 bytes). *)
  module MinSig : sig
    (** Type of the public keys *)
    type pk

    (** The size of a serialized value [pk] *)
    val pk_size_in_bytes : int

    (** Build a value of type [pk] without performing any check on the input
        (hence the unsafe prefix because it might not give a correct inhabitant
        of the type [pk]).
        It is safe to use this function when verifying a signature as the
        signature function verifies if the point is in the prime subgroup. Using
        {!unsafe_pk_of_bytes} removes a verification performed twice when used
        {!pk_of_bytes_exn} or {!pk_of_bytes_opt}.

        The expected bytes format are the compressed form of a point on G2. *)
    val unsafe_pk_of_bytes : Bytes.t -> pk

    (** Build a value of type [pk] safely, i.e. the function checks the bytes
        given in parameters represents a point on the curve and in the prime
        subgroup. Raise [Invalid_argument] if the bytes are not in the correct
        format or does not represent a point in the prime subgroup.

        The expected bytes format are the compressed form of a point on G2. *)
    val pk_of_bytes_exn : Bytes.t -> pk

    (** Build a value of type [pk] safely, i.e. the function checks the bytes
        given in parameters represents a point on the curve and in the prime
        subgroup. Return [None] if the bytes are not in the correct format or
        does not represent a point in the prime subgroup.

        The expected bytes format are the compressed form of a point on G2. *)
    val pk_of_bytes_opt : Bytes.t -> pk option

    (** Returns a bytes representation of a value of type [pk]. The output is
        the compressed form of the point [G2.t] the [pk] represents. *)
    val pk_to_bytes : pk -> Bytes.t

    (** [derive_pk sk] derives the corresponding public key of [sk]. *)
    val derive_pk : sk -> pk

    (** Type of the signatures *)
    type signature

    (** The size of a serialized value [signature] *)
    val signature_size_in_bytes : int

    (** Build a value of type [signature] without performing any check on the
        input (hence the unsafe prefix because it might not give a correct
        inhabitant of the type [signature]).
        It is safe to use this function when verifying a signature as the
        signature function verifies if the point is
        in the prime subgroup. Using {!unsafe_signature_of_bytes} removes a
        verification performed twice when
        used {!signature_of_bytes_exn} or {!signature_of_bytes_opt}.

        The expected bytes format are the compressed form of a point on G1. *)
    val unsafe_signature_of_bytes : Bytes.t -> signature

    (** Build a value of type [signature] safely, i.e. the function checks the
        bytes given in parameters represents a point on the curve and in the
        prime subgroup. Raise [Invalid_argument] if the bytes are not in the
        correct format or does not represent a point in the prime subgroup.

        The expected bytes format are the compressed form of a point on G1. *)
    val signature_of_bytes_exn : Bytes.t -> signature

    (** Build a value of type [signature] safely, i.e. the function checks the
        bytes given in parameters represents a point on the curve and in the
        prime subgroup. Return [None] if the bytes are not in the correct format
        or does not represent a point in the prime subgroup.

        The expected bytes format are the compressed form of a point on G1. *)
    val signature_of_bytes_opt : Bytes.t -> signature option

    (** Returns a bytes representation of a value of type [signature]. The
        output is the compressed form a the point [G1.t] the [signature]
        represents. *)
    val signature_to_bytes : signature -> Bytes.t

    (** [aggregate_signature_opt signatures] aggregates the signatures
        [signatures], following {{:
        https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-2.8
        } section 2.8 }.
        Return [None] if [INVALID] is expected in the specification *)
    val aggregate_signature_opt : signature list -> signature option

    (** Basic scheme described in
        {{:https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.1}
        section 3.1}

        In a basic scheme, rogue key attacks are handled by requiring all
        messages signed by an aggregate signature to be distinct. This
        requirement is enforced in the definition of AggregateVerify.

        {!Basic.sign} and {!Basic.verify} implements the algorithms {{:
        https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-2.6
        } CoreSign} and {{:
        https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-2.7}
        CoreVerify}, respectively. *)
    module Basic : sig
      val sign : sk -> Bytes.t -> signature

      val verify : pk -> Bytes.t -> signature -> bool

      (** [aggregate_verify pks msg aggregated_signature] performs a aggregate
          signature verification.
          It implements the AggregateVerify algorithm specified in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.1.1
          } section 3.1.1 }. Raise [Invalid_argument] if the messages are not
          distinct. *)
      val aggregate_verify : (pk * Bytes.t) list -> signature -> bool
    end

    (** Augmentation scheme described in
        {{:https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.2}
        section 3.2}

        In a message augmentation scheme, signatures are generated over the
        concatenation of the public key and the message, ensuring that messages
        signed by different public keys are distinct. *)
    module Aug : sig
      (** [sign sk msg] implements the algorithm described in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.2.1
          } section 3.2.1 } *)
      val sign : sk -> Bytes.t -> signature

      (** [verify pk msg signature] implements the algorithm described in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.2.2
          } section 3.2.2 } *)
      val verify : pk -> Bytes.t -> signature -> bool

      (** [aggregate_verify pks msg aggregated_signature] performs a aggregate
          signature verification.
          It implements the FastAggregateVerify algorithm specified in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.2.3
          } section 3.2.3 }*)
      val aggregate_verify : (pk * Bytes.t) list -> signature -> bool
    end

    (** Follow {{:
        https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3
        } section 3.3 }.

        A proof of possession scheme uses a separate public key validation step,
        called a proof of possession, to defend against rogue key attacks. This
        enables an optimization to aggregate signature verification for the case
        that all signatures are on the same message. *)
    module Pop : sig
      type proof = Bytes.t

      (** Equivalent to [core_sign] with the DST given in the specification, {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-4.2.3}
          section 4.2.3 } *)
      val sign : sk -> Bytes.t -> signature

      (** Equivalent to [core_verify] with the DST given in the specification
          {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-4.2.3}
          section 4.2.3 } *)
      val verify : pk -> Bytes.t -> signature -> bool

      (** [pop_proof sk] implements the algorithm described in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3.2
          } section 3.3.2 } *)
      val pop_prove : sk -> proof

      (** [pop_verify pk proof] implements the algorithm described in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3.3
          } section 3.3.3 } *)
      val pop_verify : pk -> proof -> bool

      (** [aggregate_verify pks msg aggregated_signature] performs a aggregate
          signature verification. It supposes the same message [msg] has been
          signed. It implements the FastAggregateVerify algorithm specified in {{:
          https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-04#section-3.3.4
          } section 3.3.4 }*)
      val aggregate_verify : (pk * proof) list -> Bytes.t -> signature -> bool
    end
  end
end

(** Implementation of an instantiation of
    {{:https://eprint.iacr.org/2019/458.pdf} Poseidon} over the scalar field of
    BLS12-381 for a security of 128 bits and with the permutation [x^5]. The
    parameters of the instantiation are:
    - state size = 3
    - number of full rounds = 8
    - number partial rounds = 56
    - the partial rounds run the sbox on the last element of the state

    These parameters have been generated using {{:
    https://gitlab.com/dannywillems/ocaml-ec/-/tree/master/utils/poseidon-hash }
    security_parameters.ml from Mec }.

    The linear layer constants and the round keys can be generated using
    {{:
    https://gitlab.com/dannywillems/ocaml-ec/-/tree/master/utils/poseidon-hash }
    generate_ark.ml and generate_mds.sage from Mec }. The constants must be
    loaded at the top level using {!Poseidon128.constants_init}.

    {b The current implementation only provides the functions to run a
       permutation. The user is responsible to build a hash function on top of
       it. } *)
module Poseidon128 : sig
  (** Context of the permutation *)
  type ctxt

  (** [constants_init ark mds] initializes the constants for Poseidon.

      {b Warnings: }
         - The function does not verify the parameters are secured
         - This function must be called before calling {!init},
           {!apply_permutation} and {!get} *)
  val constants_init : Fr.t array -> Fr.t array array -> unit

  (** [init a b c] returns a new context with an initialised state with the
      value [[a, b, c]].
  *)
  val init : Fr.t -> Fr.t -> Fr.t -> ctxt

  (** [apply_permutation ctxt] applies a permutation on the state. The context
      is modified. *)
  val apply_permutation : ctxt -> unit

  (** [get ctxt] returns the state of the permutation *)
  val get : ctxt -> Fr.t * Fr.t * Fr.t
end

(** Implementation of an instantiation of {{: https://eprint.iacr.org/2019/426 }
    Rescue } over the scalar field of BLS12-381 for a security of 128 bits and
    with the permutation [x^5]. The parameters of the instantiation are:
    - state size = 3
    - number of rounds = 14

    These parameters have been generated using {{:
    https://github.com/KULeuven-COSIC/Marvellous/blob/0969ce8a5ebaa0bf45696b44e276d3dd81d2e455/rescue_prime.sage}
    this script}.
*)
module Rescue : sig
  (** Context of the permutation *)
  type ctxt

  (** [constants_init ark mds] initializes the constants for Poseidon.

      {b Warnings: }
      - The function does not verify the parameters are secured
      - This function must be called before calling {!init},
           {!apply_permutation} and {!get} *)
  val constants_init : Fr.t array -> Fr.t array array -> unit

  (** [init a b c] returns a new context with an initialised state with the
      value [[a, b, c]].
  *)
  val init : Fr.t -> Fr.t -> Fr.t -> ctxt

  (** [apply_permutation ctxt] applies a permutation on the state. The context
      is modified. *)
  val apply_permutation : ctxt -> unit

  (** [get ctxt] returns the state of the permutation *)
  val get : ctxt -> Fr.t * Fr.t * Fr.t
end

(** Return [true] if the environment variable `BLST_PORTABLE` was set when
    building the library, otherwise [false]. Can be used to detect if the
    backend blst has been optimised with ADX on ADX-supported platforms. *)
val built_with_blst_portable : bool
