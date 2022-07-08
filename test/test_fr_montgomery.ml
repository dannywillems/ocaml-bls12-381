open Utils

module MontomeryRepresentation = struct
  let test_vectors () =
    let vs =
      [ ( "27368034540955591518185075247638312229509481411752400387472688330662143761856",
          ( "12556763614456052216",
            "4846531363285607673",
            "9570646181038305840",
            "2847381310287810155" ) );
        ( "19540886853600136773806888540031779652697522926951761090609474934921975120659",
          ( "16356568069283571160",
            "3158185229537327398",
            "13231279043486022624",
            "2138904314225674037" ) );
        ( "26220624956959285725992525915931330099055855809419283071707941601749666540606",
          ( "16724695089070207236",
            "6845644775493772465",
            "1982900623927383657",
            "766359963364495501" ) );
        ( "42808036164195249275280963312025828986508786508614910971333518929197538998773",
          ( "7022144140278981437",
            "15609630405403011585",
            "13978270928068646135",
            "3704473409123206699" ) ) ]
    in
    List.iter
      (fun (input, (exp_x0, exp_x1, exp_x2, exp_x3)) ->
        let input = Bls12_381.Fr.of_string input in
        let exp_x0 = Unsigned.UInt64.of_string exp_x0 in
        let exp_x1 = Unsigned.UInt64.of_string exp_x1 in
        let exp_x2 = Unsigned.UInt64.of_string exp_x2 in
        let exp_x3 = Unsigned.UInt64.of_string exp_x3 in
        let x0, x1, x2, x3 = Bls12_381.Fr.to_montgomery_le input in
        let is_correct =
          Unsigned.UInt64.equal exp_x0 x0
          && Unsigned.UInt64.equal exp_x1 x1
          && Unsigned.UInt64.equal exp_x2 x2
          && Unsigned.UInt64.equal exp_x3 x3
        in
        if not is_correct then
          Alcotest.failf
            "exp x0 = %s, x0 = %s\n\
             exp x1 = %s, x1 = %s\n\
             exp x2 = %s, x2 = %s\n\
             exp x3 = %s, x3 = %s\n"
            (Unsigned.UInt64.to_string exp_x0)
            (Unsigned.UInt64.to_string x0)
            (Unsigned.UInt64.to_string exp_x1)
            (Unsigned.UInt64.to_string x1)
            (Unsigned.UInt64.to_string exp_x2)
            (Unsigned.UInt64.to_string x2)
            (Unsigned.UInt64.to_string exp_x3)
            (Unsigned.UInt64.to_string x3))
      vs

  let test_of_and_to_montgomery_le_are_inverse () =
    let x0, x1, x2, x3 =
      ( Unsigned.UInt64.of_int @@ Random.int 1_000_000_000,
        Unsigned.UInt64.of_int @@ Random.int 1_000_000_000,
        Unsigned.UInt64.of_int @@ Random.int 1_000_000_000,
        Unsigned.UInt64.of_int @@ Random.int 1_000_000_000 )
    in
    let r = Bls12_381.Fr.of_montgomery_le (x0, x1, x2, x3) in
    let x0', x1', x2', x3' = Bls12_381.Fr.to_montgomery_le r in
    assert (
      Unsigned.UInt64.equal x0' x0
      && Unsigned.UInt64.equal x1' x1
      && Unsigned.UInt64.equal x2' x2
      && Unsigned.UInt64.equal x3' x3) ;
    let r = Bls12_381.Fr.random () in
    let r' = Bls12_381.Fr.(of_montgomery_le (to_montgomery_le r)) in
    assert (Bls12_381.Fr.eq r r')

  let get_tests () =
    let open Alcotest in
    ( "Montgomery representation",
      [ test_case "test_vectors" `Quick test_vectors;
        test_case
          "of and to montgomery le are inverse"
          `Quick
          (repeat 100 test_of_and_to_montgomery_le_are_inverse) ] )
end

let () =
  let open Alcotest in
  run "Fr" [MontomeryRepresentation.get_tests ()]
