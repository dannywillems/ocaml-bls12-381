module Parameters = struct
  let nb_full_rounds = 8

  let nb_partial_rounds = 56

  let batch_size = 3

  let width = 3

  let ark = Poseidon128_ark.v

  let mds = Poseidon128_mds.v
end

module NPoseidon128 = Bls12_381.Poseidon.Make (Parameters)

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

let test_regression_tests_for_poseidon252 () =
  let module Parameters = struct
    let nb_full_rounds = 8

    let nb_partial_rounds = 59

    let batch_size = 4

    let width = 5

    let ark = Poseidon252_ark.v

    let mds = Poseidon252_mds.v
  end in
  let vectors =
    [ ( Array.make Parameters.width (Bls12_381.Fr.of_string "19"),
        [| "2f26f38f20a624eb7ddc58a28f94a868824a320a64a05c7b028be716c3d47938";
           "577a6555ceb8acfcec1024f76a647a63bef97ef490fa875d5d8d640e9c477973";
           "d3c9f03664b22c12a49a428cd13bf60c397105ae18039208598f00270b71472f";
           "968c4eeb53cb2888a565bf27bc7eb23c648c05f595b1a39fbe11a7aaaba57c4a";
           "e6ddc232b1895b132931211f1052df5a9945ef7c62011a45c5509490cf8cb001"
        |] ) ]
  in
  let module Poseidon252 = Bls12_381.Poseidon.Make (Parameters) in
  List.iter
    (fun (inputs, expected_output) ->
      let expected_output =
        Array.map
          (fun x -> Bls12_381.Fr.of_bytes_exn (Hex.to_bytes (`Hex x)))
          expected_output
      in
      let ctxt = Poseidon252.init inputs in
      let () = Poseidon252.apply_permutation ctxt in
      let output = Poseidon252.get ctxt in
      Array.iter2
        (fun a b ->
          if not (Bls12_381.Fr.eq a b) then
            Alcotest.failf
              "Expected output is %s, computed is %s\n"
              (Bls12_381.Fr.to_string a)
              (Bls12_381.Fr.to_string b))
        expected_output
        output)
    vectors

let () =
  let open Alcotest in
  run
    "Poseidon"
    [ ( "Batch size consistency",
        [ test_case
            "Poseidon128 with random batch sizes"
            `Quick
            test_poseidon128_with_different_batch_size;
          test_case
            "Random instance of Poseidon"
            `Quick
            test_random_instanciations_of_poseidon_with_different_batch_size ]
      );
      ( "Test vectors",
        [ test_case
            "Poseidon252 (Dusk)"
            `Quick
            test_regression_tests_for_poseidon252 ] ) ]
