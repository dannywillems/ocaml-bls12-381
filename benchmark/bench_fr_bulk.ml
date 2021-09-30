let () =
  let open Bls12_381 in
  let n = 100_000 in
  let xs = List.init n (fun _ -> Fr.random ()) in
  let bulk_start_time = Sys.time () in
  ignore @@ Fr.add_bulk xs ;
  let bulk_end_time = Sys.time () in
  let sequential_start_time = Sys.time () in
  ignore @@ List.fold_left Fr.add Fr.zero xs ;
  let sequential_end_time = Sys.time () in
  let res_bulk = (bulk_end_time -. bulk_start_time) *. 1000. in
  let res_sequential =
    (sequential_end_time -. sequential_start_time) *. 1000.
  in
  let ratio = res_bulk /. res_sequential in
  Printf.printf
    "Addition %d elements of Fr: bulk %f ms and %f ms (sequential)\n\
     It is a gain of %f pcts\n"
    n
    res_bulk
    res_sequential
    (1. -. ratio)

let () =
  let open Bls12_381 in
  let n = 100_000 in
  let xs = List.init n (fun _ -> Fr.random ()) in
  let bulk_start_time = Sys.time () in
  ignore @@ Fr.mul_bulk xs ;
  let bulk_end_time = Sys.time () in
  let sequential_start_time = Sys.time () in
  ignore @@ List.fold_left Fr.mul Fr.one xs ;
  let sequential_end_time = Sys.time () in
  let res_bulk = (bulk_end_time -. bulk_start_time) *. 1000. in
  let res_sequential =
    (sequential_end_time -. sequential_start_time) *. 1000.
  in
  let ratio = res_bulk /. res_sequential in
  Printf.printf
    "Multiply %d elements of Fr: bulk %f ms and %f ms (sequential)\n\
     It is a gain of %f pcts\n"
    n
    res_bulk
    res_sequential
    (1. -. ratio)
