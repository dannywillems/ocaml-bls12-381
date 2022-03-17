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

let create_bench nb_full_rounds nb_partial_rounds width batch_size =
  let ark_length = width * (nb_full_rounds + nb_partial_rounds) in
  let ark = Array.init ark_length (fun _ -> Bls12_381.Fr.random ()) in
  let mds =
    Array.init width (fun _ ->
        Array.init width (fun _ -> Bls12_381.Fr.random ()))
  in
  let inputs = Array.init width (fun _ -> Bls12_381.Fr.random ()) in
  let module Parameters = struct
    let nb_full_rounds = nb_full_rounds

    let nb_partial_rounds = nb_partial_rounds

    let batch_size = batch_size

    let width = width

    let ark = ark

    let mds = mds
  end in
  let module Poseidon = Bls12_381.Poseidon.Make (Parameters) in
  let ctxt = Poseidon.init inputs in
  let name =
    Printf.sprintf
      "Benchmark Poseidon: width = %d, partial = %d, full = %d, batch size = %d"
      width
      nb_partial_rounds
      nb_full_rounds
      batch_size
  in
  let t =
    Bench.Test.create ~name (fun () ->
        let () = Poseidon.apply_permutation ctxt in
        ())
  in
  t

let create_bench_different_batch_size_same_parameters_width width =
  let nb_full_rounds = 8 in
  let nb_partial_rounds = 56 in
  let ark_length = width * (nb_full_rounds + nb_partial_rounds) in
  let ark = Array.init ark_length (fun _ -> Bls12_381.Fr.random ()) in
  let mds =
    Array.init width (fun _ ->
        Array.init width (fun _ -> Bls12_381.Fr.random ()))
  in
  let inputs = Array.init width (fun _ -> Bls12_381.Fr.random ()) in
  let module BaseParameters = struct
    let nb_full_rounds = nb_full_rounds

    let nb_partial_rounds = nb_partial_rounds

    let width = width

    let ark = ark

    let mds = mds
  end in
  let batch_sizes = [1; 2; 3; 5; 7; 10; 15] in
  let benches =
    List.map
      (fun batch_size ->
        let module Parameters = struct
          include BaseParameters

          let batch_size = batch_size
        end in
        let module Poseidon = Bls12_381.Poseidon.Make (Parameters) in
        let ctxt = Poseidon.init inputs in
        let name =
          Printf.sprintf
            "Benchmark Poseidon: width = %d, batch size = %d"
            width
            batch_size
        in
        Bench.Test.create ~name (fun () ->
            let () = Poseidon.apply_permutation ctxt in
            ()))
      batch_sizes
  in
  benches

let bench_neptunus =
  let width = 5 in
  let nb_full_rounds = 60 in
  let nb_partial_rounds = 0 in
  let ark_length = width * (nb_full_rounds + nb_partial_rounds) in
  let ark = Array.init ark_length (fun _ -> Bls12_381.Fr.random ()) in
  let mds =
    Array.init width (fun _ ->
        Array.init width (fun _ -> Bls12_381.Fr.random ()))
  in
  let inputs = Array.init width (fun _ -> Bls12_381.Fr.random ()) in
  let module Parameters = struct
    let nb_full_rounds = nb_full_rounds

    let nb_partial_rounds = nb_partial_rounds

    let width = width

    let ark = ark

    let mds = mds

    let batch_size = 2
  end in
  let module Poseidon = Bls12_381.Poseidon.Make (Parameters) in
  let ctxt = Poseidon.init inputs in
  let name = "Benchmark Neptunus" in
  Bench.Test.create ~name (fun () ->
      let () = Poseidon.apply_permutation ctxt in
      ())

let command =
  Bench.make_command
    (t1 :: t2 :: bench_neptunus
    :: List.concat
         [ create_bench_different_batch_size_same_parameters_width 5;
           create_bench_different_batch_size_same_parameters_width 3 ])

let () = Core.Command.run command
