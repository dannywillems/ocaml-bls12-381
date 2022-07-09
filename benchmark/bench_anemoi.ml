open Core_bench

let t1 =
  let a, b = (Bls12_381.Fr.random (), Bls12_381.Fr.random ()) in
  let name = "Benchmark AnemoiJive" in
  Bench.Test.create ~name (fun () ->
      ignore @@ Bls12_381.Anemoi.jive128_1_compress a b)

let command = Bench.make_command [t1]

let () = Core.Command.run command
