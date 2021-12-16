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
