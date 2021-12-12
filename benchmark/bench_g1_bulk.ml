let () =
  let open Bls12_381 in
  let n = 1 lsl 16 in
  let xs = List.init n (fun _ -> G1.random ()) in
  let bulk_start_time = Sys.time () in
  ignore @@ G1.add_bulk xs ;
  let bulk_end_time = Sys.time () in
  let sequential_start_time = Sys.time () in
  ignore @@ List.fold_left G1.add G1.zero xs ;
  let sequential_end_time = Sys.time () in
  let res_bulk = (bulk_end_time -. bulk_start_time) *. 1000. in
  let res_sequential =
    (sequential_end_time -. sequential_start_time) *. 1000.
  in
  let ratio = res_bulk /. res_sequential in
  Printf.printf
    "Add %d elements of G1: bulk %f ms and %f ms (sequential)\n\
     It is a gain of %f pcts\n"
    n
    res_bulk
    res_sequential
    (1. -. ratio)

let () =
  let open Bls12_381 in
  let n = 1 lsl 16 in
  let ps = Array.init n (fun _ -> G1.random ()) in
  let ss = Array.init n (fun _ -> G1.Scalar.random ()) in
  let pippenger_start_time = Sys.time () in
  ignore @@ G1.pippenger ps ss ;
  let pippenger_end_time = Sys.time () in
  let sequential_start_time = Sys.time () in
  let xs = List.init n (fun i -> (ps.(i), ss.(i))) in
  ignore
  @@ List.fold_left (fun acc (g, s) -> G1.add (G1.mul g s) acc) G1.zero xs ;
  let sequential_end_time = Sys.time () in
  let res_pippenger = (pippenger_end_time -. pippenger_start_time) *. 1000. in
  let res_sequential =
    (sequential_end_time -. sequential_start_time) *. 1000.
  in
  let ratio = res_pippenger /. res_sequential in
  Printf.printf
    "Naive multi scalar exponentiation with %d elements in G1: %f ms. \
     Pippenger = %fms.\n\
     It is a gain of %f pcts\n"
    n
    res_sequential
    res_pippenger
    (1. -. ratio)

let () =
  let open Bls12_381 in
  let n = 1 lsl 16 in
  let ps = Array.init n (fun _ -> G1.random ()) in
  let ss = Array.init n (fun _ -> G1.Scalar.random ()) in
  let ps_contiguous = G1.to_affine_array ps in
  let pippenger_start_time = Sys.time () in
  ignore @@ G1.pippenger_with_affine_array ps_contiguous ss ;
  let pippenger_end_time = Sys.time () in
  let sequential_start_time = Sys.time () in
  let xs = List.init n (fun i -> (ps.(i), ss.(i))) in
  ignore
  @@ List.fold_left (fun acc (g, s) -> G1.add (G1.mul g s) acc) G1.zero xs ;
  let sequential_end_time = Sys.time () in
  let res_pippenger = (pippenger_end_time -. pippenger_start_time) *. 1000. in
  let res_sequential =
    (sequential_end_time -. sequential_start_time) *. 1000.
  in
  let ratio = res_pippenger /. res_sequential in
  Printf.printf
    "Naive multi scalar exponentiation with %d elements in G1: %f ms. \
     Pippenger with contiguous array = %fms.\n\
     It is a gain of %f pcts\n"
    n
    res_sequential
    res_pippenger
    (1. -. ratio)
