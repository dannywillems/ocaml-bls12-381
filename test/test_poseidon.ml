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

let () =
  let open Alcotest in
  run
    "Poseidon"
    [ ( "Instantiate correctly with some known instances",
        [test_case "Poseidon128" `Quick test_instantiate_correctly_poseidon128]
      ) ]
