open Core_bench

let () =
  Bls12_381.Hash.Poseidon128.constants_init Poseidon128_ark.v Poseidon128_mds.v

let t1 =
  let a, b, c =
    (Bls12_381.Fr.random (), Bls12_381.Fr.random (), Bls12_381.Fr.random ())
  in
  let name = "Benchmark one permutation of Poseidon128" in
  Bench.Test.create ~name (fun () ->
      let ctxt = Bls12_381.Hash.Poseidon128.init a b c in
      let () = Bls12_381.Hash.Poseidon128.apply_permutation ctxt in
      let _v = Bls12_381.Hash.Poseidon128.get ctxt in
      ())

let command = Bench.make_command [t1]

let () = Core.Command.run command
