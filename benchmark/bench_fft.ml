let logn = 16

let n = 1 lsl logn

let root =
  Bls12_381.Fr.of_string
    "45578933624873246016802258050230213493140367389966312656957679049059636081617"

let domain = Array.init n (fun i -> Bls12_381.Fr.pow root (Z.of_int i))

let t1 =
  let points = Array.init n (fun _ -> Bls12_381.Fr.random ()) in
  Core_bench.Bench.Test.create ~name:"FFT on Fr elements" (fun () ->
      ignore @@ Bls12_381.Fr.fft ~domain ~points)

let () = Core.Command.run (Core_bench.Bench.make_command [t1])
