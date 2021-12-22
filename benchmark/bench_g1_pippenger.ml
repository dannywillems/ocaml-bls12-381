open Bls12_381
module StringMap = Map.Make (String)

(* Fix the seed to avoid getting benches dependending on the inputs. We want to
   bench the different implementation, not the algorithm *)
let state = Random.State.make [| 42 |]

let results : (Bls12_381.G1.t * float) StringMap.t = StringMap.empty

(* Configuration for the bench *)
let power = int_of_string Sys.argv.(1)

let n = 1 lsl power

let nb_tasks = int_of_string Sys.argv.(2)

let nb_domains = int_of_string Sys.argv.(3)

let nb_chunks = int_of_string Sys.argv.(4)

let ss = Array.init n (fun _ -> G1.Scalar.random ~state ())

let () =
  assert (
    Fr.to_string ss.(0)
    = "14994049377928826363495223704381650737411020059923663878974688106580230994440")

let ps = Array.init n (fun _ -> G1.random ~state ())

(* Verifying no zero has been sampled because pippenger does have unexpected
   behavior in this case. *)
let () =
  assert (Array.for_all (fun x -> not (G1.is_zero x)) ps) ;
  assert (Array.for_all (fun x -> not (Fr.is_zero x)) ss)

let with_time f =
  (* let () = Gc.full_major () in *)
  let start_time = Sys.time () in
  let res = f () in
  let end_time = Sys.time () in
  (res, (end_time -. start_time) *. 1_000.)

let with_pool f =
  let pool =
    Domainslib.Task.setup_pool
      ~num_additional_domains:(nb_domains - 1)
      ~name:"pool"
      ()
  in
  let res = Domainslib.Task.run pool (fun _ -> f pool) in
  Domainslib.Task.teardown_pool pool ;
  res

(* let () = *)
(*   let xs = List.init n (fun i -> (ps.(i), ss.(i))) in *)
(*   let f () = *)
(*     List.fold_left (fun acc (g, s) -> G1.add (G1.mul g s) acc) G1.zero xs *)
(*   in *)
(*   let _res, time = with_time f in *)
(*   Printf.printf *)
(*     "Naive multi scalar exponentiation with %d elements in G1: %f ms.\n" *)
(*     n *)
(*     time *)

let results =
  let f () = G1.pippenger ps ss in
  StringMap.add "Single core pippenger" (with_time f) results

let results =
  let ps_contiguous = G1.to_affine_array ps in
  let f () = G1.pippenger_with_affine_array ps_contiguous ss in
  StringMap.add "Single core pippenger, contiguous array" (with_time f) results

let results =
  let ps_contiguous = G1.to_affine_array ps in
  let chunk_size = n / nb_chunks in
  let rest = n mod nb_chunks in
  let f () =
    let rec aux i acc =
      if i = nb_chunks then
        if rest <> 0 then
          let start = i * chunk_size in
          let len = rest in
          let res =
            G1.pippenger_with_affine_array ~start ~len ps_contiguous ss
          in
          res :: acc
        else acc
      else
        let start = i * chunk_size in
        let len = chunk_size in
        let res = G1.pippenger_with_affine_array ~start ~len ps_contiguous ss in
        let acc = res :: acc in
        aux (i + 1) acc
    in
    let l = aux 0 [] in
    List.fold_left G1.add G1.zero l
  in
  StringMap.add
    "Single core pippenger, contiguous array splitted in chunks"
    (with_time f)
    results

let results =
  let open Domainslib in
  let ps_contiguous = G1.to_affine_array ps in
  let res, time =
    with_pool (fun pool ->
        let chunk_size = n / nb_tasks in
        assert (n >= chunk_size) ;
        let rest = n mod nb_tasks in
        let f () =
          let rec aux i_task acc =
            if i_task < 0 then acc
            else
              let start = i_task * chunk_size in
              let len =
                if i_task = nb_tasks - 1 then chunk_size + rest else chunk_size
              in
              let task =
                Task.async pool (fun _ ->
                    G1.pippenger_with_affine_array ~start ~len ps_contiguous ss)
              in
              aux (i_task - 1) (task :: acc)
          in
          let ps = aux (nb_tasks - 1) [] in
          let l = List.map (Task.await pool) ps in
          List.fold_left G1.add G1.zero l
        in
        with_time f)
  in
  StringMap.add "Multi core pippenger, contiguous array" (res, time) results

let () =
  let values = List.map fst (List.map snd (StringMap.bindings results)) in
  assert (List.length values >= 1) ;
  let exp_res = List.hd values in
  assert (List.for_all (fun x -> G1.eq exp_res x) values) ;
  Printf.printf
    "Number of elements: %d (2^%d). Num domains = %d and num task = %d, num \
     chunk = %d\n"
    n
    power
    nb_domains
    nb_tasks
    nb_chunks ;
  StringMap.iter
    (fun desc (_res, time) -> Printf.printf "%s: %fms\n" desc time)
    results
