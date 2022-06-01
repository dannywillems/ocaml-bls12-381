open Bls12_381
module StringMap = Map.Make (String)

let results : (Bls12_381.G1.t * float) StringMap.t = StringMap.empty

(* Configuration for the bench *)
let power = int_of_string Sys.argv.(1)

let n = 1 lsl power

let ss = Array.init n (fun _ -> G1.Scalar.random ())

let ps = Array.init n (fun _ -> G1.random ())

(* Verifying no zero has been sampled because pippenger does have unexpected
   behavior in this case. *)
let () =
  assert (Array.for_all (fun x -> not (G1.is_zero x)) ps) ;
  assert (Array.for_all (fun x -> not (Fr.is_zero x)) ss)

let with_time f =
  let () = Gc.full_major () in
  let start_time = Sys.time () in
  let res = f () in
  let end_time = Sys.time () in
  (res, (end_time -. start_time) *. 1_000.)

let results =
  let f () = G1.pippenger ps ss in
  StringMap.add "Single core pippenger" (with_time f) results

let results =
  let ps = Carray.of_array ps in
  let ss = Carray.of_array ss in
  let f () = G1.pippenger_carray ps ss in
  StringMap.add "Single core pippenger carray" (with_time f) results

(* let results = *)
(*   let ps_contiguous = G1.to_affine_array ps in *)
(*   let f () = G1.pippenger_with_affine_array ps_contiguous ss in *)
(*   StringMap.add "Single core pippenger, contiguous array" (with_time f) results *)

(* let results = *)
(*   let ps_contiguous = G1.to_affine_array ps in *)
(*   let chunk_size = n / nb_chunks in *)
(*   let rest = n mod nb_chunks in *)
(*   let f () = *)
(*     let rec aux i acc = *)
(*       if i = nb_chunks then *)
(*         if rest <> 0 then *)
(*           let start = i * chunk_size in *)
(*           let len = rest in *)
(*           let res = *)
(*             G1.pippenger_with_affine_array ~start ~len ps_contiguous ss *)
(*           in *)
(*           res :: acc *)
(*         else acc *)
(*       else *)
(*         let start = i * chunk_size in *)
(*         let len = chunk_size in *)
(*         let res = G1.pippenger_with_affine_array ~start ~len ps_contiguous ss in *)
(*         let acc = res :: acc in *)
(*         aux (i + 1) acc *)
(*     in *)
(*     let l = aux 0 [] in *)
(*     List.fold_left G1.add G1.zero l *)
(*   in *)
(*   StringMap.add *)
(*     "Single core pippenger, contiguous array splitted in chunks" *)
(*     (with_time f) *)
(*     results *)

let () =
  let values = List.map fst (List.map snd (StringMap.bindings results)) in
  assert (List.length values >= 1) ;
  let exp_res = List.hd values in
  assert (List.for_all (fun x -> G1.eq exp_res x) values) ;
  Printf.printf "Number of elements: %d (2^%d)." n power ;
  StringMap.iter
    (fun desc (_res, time) -> Printf.printf "%s: %fms\n" desc time)
    results
