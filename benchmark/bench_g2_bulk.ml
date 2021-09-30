let () =
  let open Bls12_381 in
  let n = 100_000 in
  let xs = List.init n (fun _ -> G2.random ()) in
  let bulk_start_time = Sys.time () in
  ignore @@ G2.add_bulk xs ;
  let bulk_end_time = Sys.time () in
  let sequential_start_time = Sys.time () in
  ignore @@ List.fold_left G2.add G2.zero xs ;
  let sequential_end_time = Sys.time () in
  let res_bulk = (bulk_end_time -. bulk_start_time) *. 1000. in
  let res_sequential =
    (sequential_end_time -. sequential_start_time) *. 1000.
  in
  let ratio = res_bulk /. res_sequential in
  Printf.printf
    "Add %d elements of G2: bulk %f ms and %f ms (sequential)\n\
     It is a gain of %f pcts"
    n
    res_bulk
    res_sequential
    (1. -. ratio)

let () =
  let open Bls12_381 in
  let n = 100_000 in
  let xs = List.init n (fun _ -> (G2.random (), G2.Scalar.random ())) in
  let bulk_start_time = Sys.time () in
  ignore @@ G2.add_mul_bulk xs ;
  let bulk_end_time = Sys.time () in
  let sequential_start_time = Sys.time () in
  ignore
  @@ List.fold_left (fun acc (g, n) -> G2.add acc (G2.mul g n)) G2.zero xs ;
  let sequential_end_time = Sys.time () in
  let res_bulk = (bulk_end_time -. bulk_start_time) *. 1000. in
  let res_sequential =
    (sequential_end_time -. sequential_start_time) *. 1000.
  in
  let ratio = res_bulk /. res_sequential in
  Printf.printf
    "Add and mul of %d elements of G2: bulk %f ms and %f ms (sequential)\n\
     It is a gain of %f pcts"
    n
    res_bulk
    res_sequential
    (1. -. ratio)
