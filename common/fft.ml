module type C = sig
  type group

  type scalar

  val zero : group

  val copy : group -> group

  val inverse_exn_scalar : scalar -> scalar

  val scalar_of_z : Z.t -> scalar

  val fft_inplace : group array -> scalar array -> int -> int

  val mul_map_inplace : group array -> scalar -> int -> int
end

let fft (type a b) (module G : C with type group = a and type scalar = b)
    ~domain ~points =
  (* USE WITH PRECAUTION on groups See
     https://en.wikipedia.org/wiki/Pontryagin_dual inspried by
     https://github.com/ethereum/research/blob/master/kzg_data_availability/kzg_proofs.py
     https://github.com/ethereum/research/blob/master/kzg_data_availability/fk20_single.py#L53
     More generally, see
     https://gitlab.com/dannywillems/ocaml-polynomial/-/blob/8351c266c4eae185823ab87d74ecb34c0ce70afe/src/polynomial.ml#L428 *)
  let n = Array.length domain in
  let logn = Z.log2 (Z.of_int n) in
  let len_points = Array.length points in
  let points = Array.map G.copy points in
  let output =
    if n > len_points then
      Array.append points (Array.init (n - len_points) (fun _ -> G.copy G.zero))
    else (
      assert (n = len_points) ;
      points)
  in
  ignore @@ G.fft_inplace output domain logn ;
  output

let ifft (type a b) (module G : C with type group = a and type scalar = b)
    ~domain ~points =
  let power = Array.length domain in
  assert (power = Array.length points) ;
  let points = fft (module G) ~domain ~points in
  let power_inv = G.inverse_exn_scalar (G.scalar_of_z (Z.of_int power)) in
  ignore @@ G.mul_map_inplace points power_inv power ;
  points
