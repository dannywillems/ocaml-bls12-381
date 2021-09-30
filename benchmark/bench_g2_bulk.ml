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
    "Add %d elements of G2: bulk %f ms and sequential %f ms \n\
     It is a gain of %f pcts"
    n
    res_bulk
    res_sequential
    (1. -. ratio)

let () =
  let open Bls12_381 in
  let n = 100_000 in
  let gs = List.init n (fun _ -> G2.random ()) in
  let ss = List.init n (fun _ -> G2.Scalar.random ()) in
  let sequential_start_time = Sys.time () in
  ignore
  @@ List.fold_left2 (fun acc g n -> G2.add acc (G2.mul g n)) G2.zero gs ss ;
  let sequential_end_time = Sys.time () in
  let bulk_start_time = Sys.time () in
  List.iter2 (fun g n -> G2.mul_inplace g n) gs ss ;
  ignore @@ G2.add_bulk gs ;
  let bulk_end_time = Sys.time () in
  let res_bulk = (bulk_end_time -. bulk_start_time) *. 1000. in
  let res_sequential =
    (sequential_end_time -. sequential_start_time) *. 1000.
  in
  let ratio = res_bulk /. res_sequential in
  Printf.printf
    "Sum of scalar multiplications of %d elements of G2: bulk %f ms and \
     sequential %f ms \n\
     It is a gain of %f pcts"
    n
    res_bulk
    res_sequential
    (1. -. ratio)

let () =
  let open Bls12_381 in
  let n = 100_000 in
  let gs = List.init n (fun _ -> G2.random ()) in
  let ss = List.init n (fun _ -> G2.Scalar.random ()) in
  let sequential_start_time = Sys.time () in
  ignore
  @@ List.fold_left2 (fun acc g n -> G2.add acc (G2.mul g n)) G2.zero gs ss ;
  let sequential_end_time = Sys.time () in
  let bulk_start_time = Sys.time () in
  List.iter2 (fun g n -> G2.mul_inplace g n) gs ss ;
  ignore @@ G2.add_bulk gs ;
  let bulk_end_time = Sys.time () in
  let res_bulk = (bulk_end_time -. bulk_start_time) *. 1000. in
  let res_sequential =
    (sequential_end_time -. sequential_start_time) *. 1000.
  in
  let ratio = res_bulk /. res_sequential in
  Printf.printf
    "Sum of scalar multiplication of %d elements of G2: with add_bulk and \
     mul_inplace %f ms and %f ms (sequential)\n\
     It is a gain of %f pcts"
    n
    res_bulk
    res_sequential
    (1. -. ratio)
