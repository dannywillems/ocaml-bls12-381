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

let test_instantiate_correctly_poseidon128 () =
  let inputs = Array.init Parameters.width (fun _ -> Bls12_381.Fr.random ()) in
  let n_ctxt = NPoseidon128.init inputs in
  let () = NPoseidon128.apply_permutation n_ctxt in
  let n_output = NPoseidon128.get n_ctxt in
  let ctxt = Bls12_381.Poseidon128.init inputs.(0) inputs.(1) inputs.(2) in
  let () = Bls12_381.Poseidon128.apply_permutation ctxt in
  let a, b, c = Bls12_381.Poseidon128.get ctxt in
  let output = [| a; b; c |] in
  Array.iter2
    (fun a b ->
      if not (Bls12_381.Fr.eq a b) then
        Alcotest.failf
          "Expected output is %s, computed %s\n"
          (Bls12_381.Fr.to_string a)
          (Bls12_381.Fr.to_string b))
    output
    n_output

let test_poseidon128_with_different_batch_size () =
  let width = 3 in
  let inputs = Array.init width (fun _ -> Bls12_381.Fr.random ()) in
  let compute_output () =
    let module Parameters = struct
      let nb_full_rounds = 8

      let nb_partial_rounds = 56

      let width = width

      let batch_size = 2 + Random.int nb_partial_rounds

      let ark = Poseidon128_ark.v

      let mds = Poseidon128_mds.v
    end in
    let module NPoseidon128 = Bls12_381.Poseidon.Make (Parameters) in
    let ctxt = NPoseidon128.init inputs in
    let () = NPoseidon128.apply_permutation ctxt in
    NPoseidon128.get ctxt
  in
  let output = compute_output () in
  let output' = compute_output () in
  Array.iter2
    (fun a b ->
      if not (Bls12_381.Fr.eq a b) then
        Alcotest.failf
          "Output is %s, output' is %s\n"
          (Bls12_381.Fr.to_string a)
          (Bls12_381.Fr.to_string b))
    output
    output'

let test_random_instanciations_of_poseidon_with_different_batch_size () =
  let width = 1 + Random.int 10 in
  let nb_full_rounds = (1 + Random.int 10) * 2 in
  let nb_partial_rounds = 2 + Random.int 100 in
  let ark_length = width * (nb_full_rounds + nb_partial_rounds) in
  let ark = Array.init ark_length (fun _ -> Bls12_381.Fr.random ()) in
  let mds =
    Array.init width (fun _ ->
        Array.init width (fun _ -> Bls12_381.Fr.random ()))
  in
  let inputs = Array.init width (fun _ -> Bls12_381.Fr.random ()) in
  let compute_output () =
    let module Parameters = struct
      let nb_full_rounds = nb_full_rounds

      let nb_partial_rounds = nb_partial_rounds

      let width = width

      let batch_size = 1 + Random.int nb_partial_rounds

      let ark = ark

      let mds = mds
    end in
    let module NPoseidon128 = Bls12_381.Poseidon.Make (Parameters) in
    let ctxt = NPoseidon128.init inputs in
    let () = NPoseidon128.apply_permutation ctxt in
    NPoseidon128.get ctxt
  in
  let output = compute_output () in
  let output' = compute_output () in
  Array.iter2
    (fun a b ->
      if not (Bls12_381.Fr.eq a b) then
        Alcotest.failf
          "Output is %s, output' is %s\n"
          (Bls12_381.Fr.to_string a)
          (Bls12_381.Fr.to_string b))
    output
    output'

let () =
  let open Alcotest in
  run
    "Poseidon"
    [ ( "Instantiate correctly with some known instances",
        [test_case "Poseidon128" `Quick test_instantiate_correctly_poseidon128]
      );
      ( "Batch size consistency",
        [ test_case
            "Poseidon128 with random batch sizes"
            `Quick
            test_poseidon128_with_different_batch_size;
          test_case
            "Random instance of Poseidon"
            `Quick
            test_random_instanciations_of_poseidon_with_different_batch_size ]
      ) ]
