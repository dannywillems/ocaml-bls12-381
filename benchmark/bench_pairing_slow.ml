open Bls12_381

let with_time_ms f =
  let start_time = Sys.time () in
  let res = f () in
  let end_time = Sys.time () in
  (res, (end_time -. start_time) *. 1_000.)

let () =
  let n = 1 lsl 15 in
  let points = List.init n (fun _ -> (G1.random (), G2.random ())) in
  let _, time_pairing =
    with_time_ms (fun () ->
        List.fold_left
          (fun acc (g1, g2) -> GT.add acc (Pairing.pairing g1 g2))
          GT.zero
          points)
  in
  let _, time_miller_loop =
    with_time_ms (fun () ->
        Pairing.final_exponentiation_exn (Pairing.miller_loop points))
  in
  Printf.printf
    "Pairing: %fms, miller loop: %fms\n"
    time_pairing
    time_miller_loop
