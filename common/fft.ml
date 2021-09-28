module type C = sig
  type group

  type scalar

  val zero : group

  val mul : group -> scalar -> group

  val mul_noalloc : group -> group -> scalar -> unit

  val add : group -> group -> group

  val add_noalloc : group -> group -> group -> unit

  val sub : group -> group -> group

  val sub_noalloc : group -> group -> group -> unit

  val inverse_exn_scalar : scalar -> scalar

  val scalar_of_z : Z.t -> scalar
end

let bitreverse n l =
  let r = ref 0 in
  let n = ref n in
  for _i = 0 to l - 1 do
    r := (!r lsl 1) lor (!n land 1) ;
    n := !n lsr 1
  done ;
  !r

let fft (type a b) (module G : C with type group = a and type scalar = b)
    ~domain ~points =
  (* USE WITH PRECAUTION on groups
     See
      https://en.wikipedia.org/wiki/Pontryagin_dual
     inspried by
      https://github.com/ethereum/research/blob/master/kzg_data_availability/kzg_proofs.py
      https://github.com/ethereum/research/blob/master/kzg_data_availability/fk20_single.py#L53
     More generally, see
      https://gitlab.com/dannywillems/ocaml-polynomial/-/blob/8351c266c4eae185823ab87d74ecb34c0ce70afe/src/polynomial.ml#L428
  *)
  let reorg_coefficients n logn coefficients =
    for i = 0 to n - 1 do
      let reverse_i = bitreverse i logn in
      if i < reverse_i then (
        let a_i = coefficients.(i) in
        let a_ri = coefficients.(reverse_i) in
        coefficients.(i) <- a_ri ;
        coefficients.(reverse_i) <- a_i )
    done
  in
  let n = Array.length domain in
  let logn = Z.log2 (Z.of_int n) in
  let len_points = Array.length points in
  let output =
    if n > len_points then
      Array.append points (Array.make (n - len_points) G.zero)
    else (
      assert (n = len_points) ;
      Array.copy points )
  in
  reorg_coefficients n logn output ;

  (* noalloc + copy *)
  let _fft_inplace ~domain output =
    let copy_val = G.add G.zero in
    let dst1 = copy_val G.zero in
    let dst2 = copy_val G.zero in
    let m = ref 1 in
    for _i = 0 to logn - 1 do
      let exponent = n / (2 * !m) in
      let k = ref 0 in
      while !k < n do
        for j = 0 to !m - 1 do
          let w = domain.(exponent * j) in
          (* odd *)
          G.mul_noalloc dst1 output.(!k + j + !m) w ;
          G.sub_noalloc dst2 output.(!k + j) dst1;
          output.(!k + j + !m) <- copy_val dst2 ;
          G.add_noalloc dst2 output.(!k + j) dst1 ;
          output.(!k + j) <- copy_val dst2
          (* output.(!k + j + !m) <- G.sub output.(!k + j) dst1 ;
           * output.(!k + j) <- G.add output.(!k + j) dst1 *)
        done ;
        k := !k + (!m * 2)
      done ;
      m := !m * 2
    done ;
    ()
  in

  (* noalloc *)
  let _fft_inplace ~domain output =
    let copy_val = G.add G.zero in
    let dst1 = copy_val G.zero in
    let m = ref 1 in
    for _i = 0 to logn - 1 do
      let exponent = n / (2 * !m) in
      let k = ref 0 in
      while !k < n do
        for j = 0 to !m - 1 do
          let w = domain.(exponent * j) in
          (* odd *)
          G.mul_noalloc dst1 output.(!k + j + !m) w ;
          output.(!k + j + !m) <- G.sub output.(!k + j) dst1 ;
          output.(!k + j) <- G.add output.(!k + j) dst1
        done ;
        k := !k + (!m * 2)
      done ;
      m := !m * 2
    done ;
    ()
  in

  (* noalloc in array *)
  let _fft_inplace ~domain output =
    let copy_val = G.add G.zero in
    let dst1 = copy_val G.zero in
    let m = ref 1 in
    for _i = 0 to logn - 1 do
      let exponent = n / (2 * !m) in
      let k = ref 0 in
      while !k < n do
        for j = 0 to !m - 1 do
          let w = domain.(exponent * j) in
          (* odd *)
          G.mul_noalloc dst1 output.(!k + j + !m) w ;
          G.sub_noalloc output.(!k + j + !m) output.(!k + j) dst1 ;
          G.add_noalloc output.(!k + j) output.(!k + j) dst1
        done ;
        k := !k + (!m * 2)
      done ;
      m := !m * 2
    done ;
    ()
  in

  (* original *)
  let fft_inplace ~domain output =
    let m = ref 1 in
    for _i = 0 to logn - 1 do
      let exponent = n / (2 * !m) in
      let k = ref 0 in
      while !k < n do
        for j = 0 to !m - 1 do
          let w = domain.(exponent * j) in
          (* odd *)
          let right = G.mul output.(!k + j + !m) w in (* Printf.printf "mul: %s\n" (Hex.show (Hex.of_bytes (Obj.magic right))); *)
          output.(!k + j + !m) <- G.sub output.(!k + j) right ; (* Printf.printf "sub: %s\n" (Hex.show (Hex.of_bytes (Obj.magic output.(!k + j + !m)))); *)
          output.(!k + j) <- G.add output.(!k + j) right; (* Printf.printf "add: %s\n" (Hex.show (Hex.of_bytes (Obj.magic output.(!k + j)))); *)
        done ;
        k := !k + (!m * 2)
      done ;
      m := !m * 2
    done ;
    ()
  in

  (* fft_inplace_noalloc ~domain output ; *)
  fft_inplace ~domain output ;
  output

let ifft (type a b) (module G : C with type group = a and type scalar = b)
    ~domain ~points =
  let power = Array.length domain in
  assert (power = Array.length points) ;
  let points = fft (module G) ~domain ~points in
  let power_inv = G.inverse_exn_scalar (G.scalar_of_z (Z.of_int power)) in
  Array.map (fun g -> G.mul g power_inv) points
