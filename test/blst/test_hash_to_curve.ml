let read_file filename =
  let lines = ref [] in
  let chan = open_in filename in
  try
    while true do
      lines := input_line chan :: !lines
    done ;
    !lines
  with End_of_file ->
    close_in chan ;
    List.rev !lines

let test_vectors_g1_from_bls_sigs_ref_files () =
  let aux filename =
    let contents = read_file filename in
    let ciphersuite = Bytes.make 1 (char_of_int 1) in
    List.iter
      (fun content ->
        let contents = String.split_on_char ' ' content in
        let (msg_str, expected_result_str) =
          (List.nth contents 0, List.nth contents 2)
        in
        let msg = Hex.(to_bytes (`Hex msg_str)) in
        let res = Bls12_381.G1.hash_to_curve msg ciphersuite in
        let expected_result =
          Bls12_381.G1.of_compressed_bytes_exn
            Hex.(to_bytes (`Hex expected_result_str))
        in
        if not @@ Bls12_381.G1.eq res expected_result then
          Alcotest.failf
            "Expected result is %s on input %s, but computed %s"
            Hex.(show (of_bytes (Bls12_381.G1.to_bytes expected_result)))
            msg_str
            Hex.(show (of_bytes (Bls12_381.G1.to_bytes res))))
      contents
  in
  aux "g1_fips_186_3_B233" ;
  aux "g1_fips_186_3_B283" ;
  aux "g1_fips_186_3_B409" ;
  aux "g1_fips_186_3_B571" ;
  aux "g1_fips_186_3_K233" ;
  aux "g1_fips_186_3_K409" ;
  aux "g1_fips_186_3_K571" ;
  aux "g1_fips_186_3_P224" ;
  aux "g1_fips_186_3_P256" ;
  aux "g1_fips_186_3_P384" ;
  aux "g1_fips_186_3_P521" ;
  aux "g1_rfc6979"

let test_vectors_g2_from_bls_sigs_ref_files () =
  let aux filename =
    let contents = read_file filename in
    let ciphersuite = Bytes.make 1 (char_of_int 2) in
    List.iter
      (fun content ->
        let contents = String.split_on_char ' ' content in
        let (msg_str, expected_result_str) =
          (List.nth contents 0, List.nth contents 2)
        in
        let msg = Hex.(to_bytes (`Hex msg_str)) in
        let res = Bls12_381.G2.hash_to_curve msg ciphersuite in
        print_endline "hello" ;
        let expected_result =
          Bls12_381.G2.of_compressed_bytes_exn
            Hex.(to_bytes (`Hex expected_result_str))
        in
        print_endline "hello" ;
        if not @@ Bls12_381.G2.eq res expected_result then
          Alcotest.failf
            "Expected result is %s on input %s, but computed %s"
            Hex.(show (of_bytes (Bls12_381.G2.to_bytes expected_result)))
            msg_str
            Hex.(show (of_bytes (Bls12_381.G2.to_bytes res))))
      contents
  in
  aux "g2_fips_186_3_B233" ;
  aux "g2_fips_186_3_B283" ;
  aux "g2_fips_186_3_B409" ;
  aux "g2_fips_186_3_B571" ;
  aux "g2_fips_186_3_K233" ;
  aux "g2_fips_186_3_K409" ;
  aux "g2_fips_186_3_K571" ;
  aux "g2_fips_186_3_P224" ;
  aux "g2_fips_186_3_P256" ;
  aux "g2_fips_186_3_P384" ;
  aux "g2_fips_186_3_P521" ;
  aux "g2_rfc6979"

let () =
  let open Alcotest in
  run
    "hash_to_curve"
    [ ( "From bls_sigs_ref",
        [ test_case "G1" `Quick test_vectors_g1_from_bls_sigs_ref_files;
          test_case "G2" `Quick test_vectors_g2_from_bls_sigs_ref_files ] ) ]
