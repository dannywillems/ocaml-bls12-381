open Core
open Core_bench

let t1 =
  let open Bls12_381_unix_blst in
  let s = G1.Scalar.random () in
  let p = G1.random () in
  Bench.Test.create ~name:"Multiplication on G1 with blst" (fun () ->
      ignore (G1.mul p s))

let t2 =
  let open Bls12_381 in
  let s = G1.Scalar.random () in
  let p = G1.random () in
  Bench.Test.create ~name:"Multiplication on G1 with Rust" (fun () ->
      ignore (G1.mul p s))

let t3 =
  let open Bls12_381_unix_blst in
  let p1 = G1.random () in
  let p2 = G1.random () in
  Bench.Test.create ~name:"Addition on G1 with blst" (fun () ->
      ignore (G1.add p1 p2))

let t4 =
  let open Bls12_381 in
  let p1 = G1.random () in
  let p2 = G1.random () in
  Bench.Test.create ~name:"Addition on G1 with Rust" (fun () ->
      ignore (G1.add p1 p2))

let command = Bench.make_command [t1; t2; t3; t4]

let () = Core.Command.run command
