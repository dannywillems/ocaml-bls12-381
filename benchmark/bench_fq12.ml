open Core_bench

module MakeBenchBlst = struct
  let test_addition =
    let e1 = Bls12_381.Fq12.random () in
    let e2 = Bls12_381.Fq12.random () in
    Bench.Test.create ~name:"Addition on Fq12" (fun () ->
        ignore (Bls12_381.Fq12.mul e1 e2))

  let test_multiplication =
    let p = Bls12_381.Fq12.random () in
    let exp = Bls12_381.Fr.random () |> Bls12_381.Fr.to_z in
    Bench.Test.create ~name:"Multiplication on Fq12" (fun () ->
        ignore (Bls12_381.Fq12.pow p exp))

  let get_benches () = [test_addition; test_multiplication]
end

let () =
  let commands = List.concat [MakeBenchBlst.get_benches ()] in
  Command_unix.run (Core_bench.Bench.make_command commands)
