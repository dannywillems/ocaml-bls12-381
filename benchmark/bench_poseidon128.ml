open Core
open Core_bench

let () =
  Bls12_381.Poseidon128.constants_init Poseidon128_ark.v Poseidon128_mds.v

let t1 =
  let n = 3 in
  let inputs = Array.init n ~f:(fun _i -> Bls12_381.Fr.random ()) in
  let name =
    Printf.sprintf
      "Benchmark one permutation of Poseidon128 with on an input of %d elements"
      n
  in
  Bench.Test.create ~name (fun () ->
      let ctxt = Bls12_381.Poseidon128.init inputs in
      let () = Bls12_381.Poseidon128.apply_perm ctxt in
      let _v = Bls12_381.Poseidon128.get ctxt in
      ())

let command = Bench.make_command [t1]

let () = Core.Command.run command
