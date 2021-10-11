let test_consistent_with_mec () =
  let test_vectors =
    [ ( [| "26220624956959285725992525915931330099055855809419283071707941601749666540606";
           "19540886853600136773806888540031779652697522926951761090609474934921975120659";
           "27368034540955591518185075247638312229509481411752400387472688330662143761856"
        |],
        [| "43511205630611772907305808512474102611984131203421236810515704700152949047224";
           "48404483885061725830813593552683405158426386147903191267014379564309723030569";
           "45455508345790033836828236232648857503212460606281822240719783924973985954240"
        |] ) ]
  in
  List.iter
    (fun (inputs, expected_output) ->
      let inputs = Array.map Bls12_381.Fr.of_string inputs in
      let expected_output = Array.map Bls12_381.Fr.of_string expected_output in
      let ctxt = Bls12_381.Poseidon128.init inputs in
      let () = Bls12_381.Poseidon128.apply_perm ctxt in
      let output = Bls12_381.Poseidon128.get ctxt in
      Array.iter2
        (fun a b ->
          if not (Bls12_381.Fr.eq a b) then
            Alcotest.failf
              "Expected output is %s, computed %s\n"
              (Bls12_381.Fr.to_string a)
              (Bls12_381.Fr.to_string b))
        expected_output
        output)
    test_vectors

let () =
  let open Alcotest in
  run
    "Poseidon128"
    [ ( "Consistency with MEC",
        [test_case "vectors" `Quick test_consistent_with_mec] ) ]

let () = Bls12_381.Poseidon128.finalize ()
