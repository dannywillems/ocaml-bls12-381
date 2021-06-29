open Core_bench

module MakeBenchBlst = struct
  module F = Bls12_381_unix_blst.Fr

  let test_addition ff_name =
    let e1 = F.random () in
    let e2 = F.random () in
    Bench.Test.create
      ~name:(Printf.sprintf "Addition Fr using %s" ff_name)
      (fun () -> ignore (F.add e1 e2))

  let test_multiplication ff_name =
    let e1 = F.random () in
    let e2 = F.random () in
    Bench.Test.create
      ~name:(Printf.sprintf "Multiplication Fr using %s" ff_name)
      (fun () -> ignore (F.mul e1 e2))

  let get_benches ff_name = [test_addition ff_name; test_multiplication ff_name]
end

module MakeBenchFF = struct
  module F = Ff.MakeFp (struct
    let prime_order =
      Z.of_string
        "52435875175126190479447740508185965837690552500527637822603658699938581184513"
  end)

  let test_addition ff_name =
    let e1 = F.random () in
    let e2 = F.random () in
    Bench.Test.create
      ~name:(Printf.sprintf "Addition Fr using %s" ff_name)
      (fun () -> ignore (F.add e1 e2))

  let test_multiplication ff_name =
    let e1 = F.random () in
    let e2 = F.random () in
    Bench.Test.create
      ~name:(Printf.sprintf "Multiplication Fr using %s" ff_name)
      (fun () -> ignore (F.mul e1 e2))

  let get_benches ff_name = [test_addition ff_name; test_multiplication ff_name]
end

module MakeBenchRust = struct
  module F = Bls12_381.Fr

  let test_addition ff_name =
    let e1 = F.random () in
    let e2 = F.random () in
    Bench.Test.create
      ~name:(Printf.sprintf "Addition Fr using %s" ff_name)
      (fun () -> ignore (F.add e1 e2))

  let test_multiplication ff_name =
    let e1 = F.random () in
    let e2 = F.random () in
    Bench.Test.create
      ~name:(Printf.sprintf "Multiplication Fr using %s" ff_name)
      (fun () -> ignore (F.mul e1 e2))

  let get_benches ff_name = [test_addition ff_name; test_multiplication ff_name]
end

let () =
  let commands =
    List.concat
      [ MakeBenchBlst.get_benches "Blst";
        MakeBenchFF.get_benches "ocaml-ff";
        MakeBenchRust.get_benches "Rust" ]
  in
  Core.Command.run (Core_bench.Bench.make_command commands)
