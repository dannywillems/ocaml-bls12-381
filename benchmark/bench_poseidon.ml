open Core_bench

module Parameters = struct
  let nb_full_rounds = 8

  let nb_partial_rounds = 56

  let batch_size = 3

  let width = 3

  let ark = Poseidon128_ark.v

  let mds = Poseidon128_mds.v
end

module NPoseidon128 = Bls12_381.Poseidon.Make (Parameters)

let () =
  Bls12_381.Poseidon128.constants_init Poseidon128_ark.v Poseidon128_mds.v

let a, b, c =
  (Bls12_381.Fr.random (), Bls12_381.Fr.random (), Bls12_381.Fr.random ())

let t1 =
  let name = "Benchmark one permutation of Poseidon128 from the library" in
  let ctxt = Bls12_381.Poseidon128.init a b c in
  Bench.Test.create ~name (fun () ->
      let () = Bls12_381.Poseidon128.apply_permutation ctxt in
      ())

let t2 =
  let name =
    "Benchmark one permutation of Poseidon128 instantiate with \
     Bls12_381.Poseidon.Make"
  in
  let ctxt = NPoseidon128.init [| a; b; c |] in
  Bench.Test.create ~name (fun () ->
      let () = NPoseidon128.apply_permutation ctxt in
      ())

let command = Bench.make_command [t1; t2]

let () = Core.Command.run command
