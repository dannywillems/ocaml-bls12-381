open Core_bench

let () = Bls12_381.Rescue.constants_init Rescue_ark.v Rescue_mds.v

let t1 =
  let a, b, c =
    (Bls12_381.Fr.random (), Bls12_381.Fr.random (), Bls12_381.Fr.random ())
  in
  let name = "Benchmark one permutation of Rescue" in
  Bench.Test.create ~name (fun () ->
      let ctxt = Bls12_381.Rescue.init a b c in
      let () = Bls12_381.Rescue.apply_permutation ctxt in
      let _v = Bls12_381.Rescue.get ctxt in
      ())

let command = Bench.make_command [t1]

let () = Core.Command.run command
