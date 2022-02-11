(*****************************************************************************)
(*                                                                           *)
(* Copyright (c) 2020-2021 Danny Willems <be.danny.willems@gmail.com>        *)
(*                                                                           *)
(* Permission is hereby granted, free of charge, to any person obtaining a   *)
(* copy of this software and associated documentation files (the "Software"),*)
(* to deal in the Software without restriction, including without limitation *)
(* the rights to use, copy, modify, merge, publish, distribute, sublicense,  *)
(* and/or sell copies of the Software, and to permit persons to whom the     *)
(* Software is furnished to do so, subject to the following conditions:      *)
(*                                                                           *)
(* The above copyright notice and this permission notice shall be included   *)
(* in all copies or substantial portions of the Software.                    *)
(*                                                                           *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*)
(* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  *)
(* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL   *)
(* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*)
(* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING   *)
(* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER       *)
(* DEALINGS IN THE SOFTWARE.                                                 *)
(*                                                                           *)
(*****************************************************************************)

let () = Random.self_init ()

(** The test vectors are generated using
    https://github.com/dannywillems/ocaml-ff *)
let test_vectors =
  [ "5241434266765085153989819426158356963249585137477420674959011812945457865191";
    "10839440052692226066497714164180551800338639216929046788248680350103009908352";
    "45771516566988367809715142190959127910391288669516577059039340716912455457131";
    "12909915968096385929046240252673624834885730199746273136167032454235900707423";
    "9906806778085203695146840231942453635945512651510460213691437498308396392030";
    "20451006147593515828371694915490427948041026610654337997907355913265840025855";
    "22753274685202779061111872324861161292260930710591061598808549358079414450472";
    "12823588949385074189879212809942339506958509313775057573450243545256259992541";
    "3453";
    "323580923485092809298430986453";
    "984305293863456098093285";
    "235234634090909863456";
    "24352346534563452436524356";
    "3836944629596737352";
    "65363576374567456780984059630856836098740965874094860978";
    "546574608450909809809809824360345639808560937" ]

let random_z () =
  let size = 1 + Random.int Bls12_381.Fr.size_in_bytes in
  let r = Bytes.init size (fun _ -> char_of_int (Random.int 256)) in
  Z.erem (Z.of_bits (Bytes.to_string r)) Bls12_381.Fr.order

module Tests = Ff_pbt.MakeAll (Bls12_381.Fr)

module Memory = struct
  let test_copy () =
    let x = Bls12_381.Fr.random () in
    let y = Bls12_381.Fr.copy x in
    assert (Bls12_381.Fr.eq x y)

  let test_size_in_memory () =
    match Sys.backend_type with
    | Native | Bytecode -> assert (Bls12_381.Fr.size_in_memory = 48)
    | Other _ ->
        (* Let's not make any assumption on other backends.*)
        (* With js_of_ocaml, [reachable_words] (used to compuite
           [size_in_memory]) always returns 0 *)
        ()

  let get_tests () =
    let txt = "Memory" in
    let open Alcotest in
    ( txt,
      [ test_case "copy" `Quick (Test_ec_make.repeat 100 test_copy);
        test_case "size in memory" `Quick test_size_in_memory ] )
end

module InplaceOperations = struct
  let test_add_inplace () =
    let x = Bls12_381.Fr.random () in
    let y = Bls12_381.Fr.random () in
    let res = Bls12_381.Fr.add x y in
    Bls12_381.Fr.add_inplace x y ;
    assert (Bls12_381.Fr.eq x res)

  let test_double_inplace () =
    let x = Bls12_381.Fr.random () in
    let res = Bls12_381.Fr.double x in
    Bls12_381.Fr.double_inplace x ;
    assert (Bls12_381.Fr.eq x res)

  let test_square_inplace () =
    let x = Bls12_381.Fr.random () in
    let res = Bls12_381.Fr.square x in
    Bls12_381.Fr.square_inplace x ;
    assert (Bls12_381.Fr.eq x res)

  let test_negate_inplace () =
    let x = Bls12_381.Fr.random () in
    let res = Bls12_381.Fr.negate x in
    Bls12_381.Fr.negate_inplace x ;
    assert (Bls12_381.Fr.eq x res)

  let test_inverse_inplace () =
    let x = Bls12_381.Fr.random () in
    let res = Bls12_381.Fr.inverse_exn x in
    Bls12_381.Fr.inverse_exn_inplace x ;
    assert (Bls12_381.Fr.eq x res)

  let test_add_inplace_with_same_value () =
    let x = Bls12_381.Fr.random () in
    let res = Bls12_381.Fr.add x x in
    Bls12_381.Fr.add_inplace x x ;
    assert (Bls12_381.Fr.eq x res)

  let test_sub_inplace () =
    let x = Bls12_381.Fr.random () in
    let y = Bls12_381.Fr.random () in
    let res = Bls12_381.Fr.sub x y in
    Bls12_381.Fr.sub_inplace x y ;
    assert (Bls12_381.Fr.eq x res)

  let test_sub_inplace_with_same_value () =
    let x = Bls12_381.Fr.random () in
    let res = Bls12_381.Fr.sub x x in
    Bls12_381.Fr.sub_inplace x x ;
    assert (Bls12_381.Fr.eq x res)

  let test_mul_inplace () =
    let x = Bls12_381.Fr.random () in
    let y = Bls12_381.Fr.random () in
    let res = Bls12_381.Fr.mul x y in
    Bls12_381.Fr.mul_inplace x y ;
    assert (Bls12_381.Fr.eq x res)

  let test_mul_inplace_with_same_value () =
    let x = Bls12_381.Fr.random () in
    let res = Bls12_381.Fr.mul x x in
    Bls12_381.Fr.mul_inplace x x ;
    assert (Bls12_381.Fr.eq x res)

  let get_tests () =
    let txt = "Inplace operations" in
    let open Alcotest in
    ( txt,
      [ test_case "add" `Quick (Test_ec_make.repeat 100 test_add_inplace);
        test_case
          "add with same value"
          `Quick
          (Test_ec_make.repeat 100 test_add_inplace_with_same_value);
        test_case "square" `Quick (Test_ec_make.repeat 100 test_square_inplace);
        test_case "negate" `Quick (Test_ec_make.repeat 100 test_negate_inplace);
        test_case "double" `Quick (Test_ec_make.repeat 100 test_double_inplace);
        test_case
          "inverse"
          `Quick
          (Test_ec_make.repeat 100 test_inverse_inplace);
        test_case
          "sub with same value"
          `Quick
          (Test_ec_make.repeat 100 test_sub_inplace_with_same_value);
        test_case
          "mul with same value"
          `Quick
          (Test_ec_make.repeat 100 test_mul_inplace_with_same_value);
        test_case "sub" `Quick (Test_ec_make.repeat 100 test_sub_inplace);
        test_case "mul" `Quick (Test_ec_make.repeat 100 test_mul_inplace) ] )
end

module StringRepresentation = struct
  let test_to_string_one () =
    assert (String.equal "1" (Bls12_381.Fr.to_string Bls12_381.Fr.one))

  let test_to_string_zero () =
    assert (String.equal "0" (Bls12_381.Fr.to_string Bls12_381.Fr.zero))

  let test_of_string_with_of_z () =
    List.iter
      (fun x ->
        assert (
          Bls12_381.Fr.eq
            (Bls12_381.Fr.of_string x)
            (Bls12_381.Fr.of_z (Z.of_string x))))
      test_vectors

  let test_of_string_to_string_consistency () =
    List.iter
      (fun x ->
        assert (
          String.equal (Bls12_381.Fr.to_string (Bls12_381.Fr.of_string x)) x))
      test_vectors

  let test_of_string_higher_than_the_modulus () =
    let x = random_z () in
    let x_str = Z.to_string x in
    let x_plus_order = Z.(add x Bls12_381.Fr.order) in
    let x_plus_order_str = Z.to_string x_plus_order in
    assert (Bls12_381.Fr.(eq (of_string x_str) (of_string x_plus_order_str)))

  let get_tests () =
    let open Alcotest in
    ( "String representation",
      [ test_case "one" `Quick test_to_string_one;
        test_case
          "consistency of_string with of_z with test vectors"
          `Quick
          test_of_string_with_of_z;
        test_case
          "of_string accepts elements higher than the modulus"
          `Quick
          test_of_string_higher_than_the_modulus;
        test_case
          "consistency of_string to_string with test vectors"
          `Quick
          test_of_string_to_string_consistency;
        test_case "zero" `Quick test_to_string_zero ] )
end

module ZRepresentation = struct
  let test_of_z_zero () =
    assert (Bls12_381.Fr.eq Bls12_381.Fr.zero (Bls12_381.Fr.of_z Z.zero))

  let test_of_z_one () =
    assert (
      Bls12_381.Fr.eq Bls12_381.Fr.one (Bls12_381.Fr.of_z (Z.of_string "1")))

  let test_random_of_z_and_to_z () =
    let x = Bls12_381.Fr.random () in
    assert (Bls12_381.Fr.eq x (Bls12_381.Fr.of_z (Bls12_381.Fr.to_z x)))

  let test_random_to_z_and_of_z () =
    let x = random_z () in
    assert (Z.equal (Bls12_381.Fr.to_z (Bls12_381.Fr.of_z x)) x)

  let test_random_of_z_higher_than_modulo () =
    (* Verify of_z uses the modulo of the parameter (and therefore accepts value
       higher than the order) *)
    let x = random_z () in
    let x_plus_order = Z.(add x Bls12_381.Fr.order) in
    assert (Bls12_381.Fr.(eq (of_z x) (of_z x_plus_order)))

  let test_vectors_to_z_and_of_z () =
    let test_vectors = List.map Z.of_string test_vectors in
    List.iter
      (fun x -> assert (Z.equal (Bls12_381.Fr.to_z (Bls12_381.Fr.of_z x)) x))
      test_vectors

  let get_tests () =
    let open Alcotest in
    ( "Z representation",
      [ test_case "one" `Quick test_of_z_one;
        test_case "zero" `Quick test_of_z_zero;
        test_case
          "of z and to z with random small numbers"
          `Quick
          (Test_ec_make.repeat 100 test_random_of_z_and_to_z);
        test_case
          "to z and of z with test vectors"
          `Quick
          test_vectors_to_z_and_of_z;
        test_case
          "of z accepts value greater than the modulo"
          `Quick
          (Test_ec_make.repeat 100 test_random_of_z_higher_than_modulo);
        test_case
          "to z and of z with random small numbers"
          `Quick
          (Test_ec_make.repeat 100 test_random_to_z_and_of_z) ] )
end

module BytesRepresentation = struct
  let test_bytes_repr_is_zarith_encoding_using_to_bits () =
    (* Pad zarith repr *)
    let r_z = random_z () in
    let bytes_z = Bytes.of_string (Z.to_bits r_z) in
    let bytes = Bytes.make Bls12_381.Fr.size_in_bytes '\000' in
    Bytes.blit bytes_z 0 bytes 0 (Bytes.length bytes_z) ;
    assert (
      Bls12_381.Fr.eq
        (Bls12_381.Fr.of_bytes_exn bytes)
        (Bls12_381.Fr.of_string (Z.to_string r_z))) ;
    let r = Bls12_381.Fr.random () in
    (* Use Fr repr *)
    let bytes_r = Bls12_381.Fr.to_bytes r in
    (* Use the Fr repr to convert in a Z element *)
    let z_r = Z.of_bits (Bytes.to_string bytes_r) in
    (* We should get the same value, using both ways *)
    assert (Z.equal z_r (Bls12_381.Fr.to_z r)) ;
    assert (Bls12_381.Fr.(eq (of_z z_r) r))

  let test_padding_is_done_automatically_with_of_bytes () =
    let z = Z.of_string "32343543534" in
    let z_bytes = Bytes.of_string (Z.to_bits z) in
    (* Checking we are in the case requiring a padding *)
    assert (Bytes.length z_bytes < Bls12_381.Fr.size_in_bytes) ;
    (* Should not raise an exception *)
    let e = Bls12_381.Fr.of_bytes_exn z_bytes in
    (* Should not be an option *)
    assert (Option.is_some (Bls12_381.Fr.of_bytes_opt z_bytes)) ;
    (* Equality in Fr should be fine (require to check to verify the internal
       representation is the same). In the current implementation, we verify the
       internal representation is the padded version. *)
    assert (Bls12_381.Fr.(eq (of_z z) e)) ;
    (* And as zarith elements, we also have the equality *)
    assert (Z.equal (Bls12_381.Fr.to_z e) z)

  let test_of_bytes_exn_accepts_elements_higher_than_the_modulus () =
    (* last byte of Bls12_381.Fr.order is 115 *)
    let r =
      Bytes.init 32 (fun i ->
          char_of_int
          @@ if i = 31 then 116 + Random.int (256 - 116) else Random.int 256)
    in
    assert (Option.is_none (Bls12_381.Fr.of_bytes_opt r)) ;
    try
      ignore @@ Bls12_381.Fr.of_bytes_exn r ;
      assert false
    with Bls12_381.Fr.Not_in_field _ -> ()

  let get_tests () =
    let open Alcotest in
    ( "Bytes representation",
      [ test_case
          "bytes representation is the same than zarith using Z.to_bits"
          `Quick
          (Test_ec_make.repeat
             10
             test_bytes_repr_is_zarith_encoding_using_to_bits);
        (* test_case *)
        (*   "of_bytes_[exn/opt] accepts elements higher than the modulus" *)
        (*   `Quick *)
        (* (Test_ec_make.repeat 10
           test_of_bytes_exn_accepts_elements_higher_than_the_modulus); *)
        test_case
          "Padding is done automatically with of_bytes"
          `Quick
          test_padding_is_done_automatically_with_of_bytes ] )
end

module TestVector = struct
  let test_inverse () =
    let test_vectors =
      [ ( "5241434266765085153989819426158356963249585137477420674959011812945457865191",
          "10839440052692226066497714164180551800338639216929046788248680350103009908352"
        );
        ( "45771516566988367809715142190959127910391288669516577059039340716912455457131",
          "45609475631078884634858595528211458305369692448866344559573507066772305338186"
        );
        ( "12909915968096385929046240252673624834885730199746273136167032454235900707423",
          "11000310335493461593980032382804784919007817741315871286620011674413549793814"
        );
        ( "9906806778085203695146840231942453635945512651510460213691437498308396392030",
          "14376170892131209521313997949250266279614396523892055155196474364730307649110"
        );
        ( "20451006147593515828371694915490427948041026610654337997907355913265840025855",
          "9251674366848220983783993301665718813823734287374642487691950418950023775049"
        );
        ( "22753274685202779061111872324861161292260930710591061598808549358079414450472",
          "5879182491359474138365930955028927605587956455972550635628359324770111549635"
        );
        ( "12823588949385074189879212809942339506958509313775057573450243545256259992541",
          "37176703988340956294235799427206509384158992510189606907136259793202107500314"
        ) ]
    in
    List.iter
      (fun (e, i) ->
        assert (
          Bls12_381.Fr.eq
            (Bls12_381.Fr.inverse_exn (Bls12_381.Fr.of_string e))
            (Bls12_381.Fr.of_string i)))
      test_vectors ;
    List.iter
      (fun (e, i) ->
        assert (
          Bls12_381.Fr.eq
            (Bls12_381.Fr.inverse_exn (Bls12_381.Fr.of_string i))
            (Bls12_381.Fr.of_string e)))
      test_vectors

  let test_add_bulk () =
    let n = 10 + Random.int 1_000 in
    let xs = List.init n (fun _ -> Bls12_381.Fr.random ()) in
    assert (
      Bls12_381.Fr.(
        eq
          (List.fold_left Bls12_381.Fr.add Bls12_381.Fr.zero xs)
          (Bls12_381.Fr.add_bulk xs)))

  let test_mul_bulk () =
    let n = 10 + Random.int 1_000 in
    let xs = List.init n (fun _ -> Bls12_381.Fr.random ()) in
    let left = List.fold_left Bls12_381.Fr.mul Bls12_381.Fr.one xs in
    let right = Bls12_381.Fr.mul_bulk xs in
    if not @@ Bls12_381.Fr.(eq left right) then
      Alcotest.failf
        "Expected result %s, computed %s\n"
        (Bls12_381.Fr.to_string left)
        (Bls12_381.Fr.to_string right)

  let test_add () =
    let test_vectors =
      [ ( "52078196679215712148218322720576334474579224383898730538745959257577939031988",
          "14304697501712570926435354702070278490052573047716755203338045808050772484669",
          "13947019005802092595205936914460647126941244931087847919480346365690130332144"
        );
        ( "19157304358764478240694328289471146271697961435094141547920922715555209453450",
          "11728945318991987128312512931314113966598035268029910445432277435051890961717",
          "30886249677756465369006841220785260238295996703124051993353200150607100415167"
        );
        ( "31296266781120594533063853258918717262467469319142606380721992558348378328397",
          "5820131821230508181650789592096633040648713066445785718497340531185653967933",
          "37116398602351102714714642851015350303116182385588392099219333089534032296330"
        );
        ( "39560938173284521169378001220360644956845338274621437250191508195058982219820",
          "38064607903920408690614292538356509340138834185257338707027916971694121463660",
          "25189670902078739380544553250531188459293619959351138134615766466814522498967"
        ) ]
    in
    List.iter
      (fun (e1, e2, expected_result) ->
        assert (
          Bls12_381.Fr.eq
            (Bls12_381.Fr.add
               (Bls12_381.Fr.of_string e1)
               (Bls12_381.Fr.of_string e2))
            (Bls12_381.Fr.of_string expected_result)))
      test_vectors ;
    List.iter
      (fun (e1, e2, expected_result) ->
        assert (
          Bls12_381.Fr.eq
            (Bls12_381.Fr.add
               (Bls12_381.Fr.of_string e2)
               (Bls12_381.Fr.of_string e1))
            (Bls12_381.Fr.of_string expected_result)))
      test_vectors

  let test_mul () =
    let test_vectors =
      [ ( "38060637728987323531851344110399976342797446962849502240683562298774992708830",
          "5512470721848092388961431210636327528269807331564913139270778763494220846493",
          "37668727721438606074520892100332665478321086205735021165111387339937557071514"
        );
        ( "8920353329234094921489611026184774357268414518382488349470656930013415883424",
          "49136653454012368208567167956110520759637791556856057105423947118262807325779",
          "15885623306930744461021285813204059242301068985087295733128928505332635787610"
        );
        ( "27505619973888738863986068934484781011766945824263356612923712981356457561202",
          "50243072596783212750626991643373709632302860135434554488507947926966036993873",
          "41343614115054986651575849604178072836351973556978705402848027675783507031010"
        );
        ( "22595773174612669619067973477148714090185633332320792125410903789347752011910",
          "52328732251934881978597625733405265672319639896554870653166667703616699256860",
          "40257812317025926695523520096471471069294532648049850170792668232075952784083"
        ) ]
    in
    List.iter
      (fun (e1, e2, expected_result) ->
        assert (
          Bls12_381.Fr.eq
            (Bls12_381.Fr.mul
               (Bls12_381.Fr.of_string e1)
               (Bls12_381.Fr.of_string e2))
            (Bls12_381.Fr.of_string expected_result)))
      test_vectors ;
    List.iter
      (fun (e1, e2, expected_result) ->
        assert (
          Bls12_381.Fr.eq
            (Bls12_381.Fr.mul
               (Bls12_381.Fr.of_string e2)
               (Bls12_381.Fr.of_string e1))
            (Bls12_381.Fr.of_string expected_result)))
      test_vectors

  let test_opposite () =
    let test_vectors =
      [ ( "41115813042790628185693779037818020465346656435243125143422155873970076434871",
          "11320062132335562293753961470367945372343896065284512679181502825968504749642"
        );
        ( "42018322502149629012634568822875196842144777572867508162082880801617895571737",
          "10417552672976561466813171685310768995545774927660129660520777898320685612776"
        );
        ( "34539139262525805815749017833342205015904514998269280061826808173178967747220",
          "17896735912600384663698722674843760821786037502258357760776850526759613437293"
        );
        ( "48147683698672565222275497827671970468018938121714425045755179114542522684737",
          "4288191476453625257172242680513995369671614378813212776848479585396058499776"
        ) ]
    in
    List.iter
      (fun (e1, expected_result) ->
        assert (
          Bls12_381.Fr.eq
            (Bls12_381.Fr.negate (Bls12_381.Fr.of_string e1))
            (Bls12_381.Fr.of_string expected_result)))
      test_vectors ;
    List.iter
      (fun (e1, expected_result) ->
        assert (
          Bls12_381.Fr.eq
            (Bls12_381.Fr.negate (Bls12_381.Fr.of_string expected_result))
            (Bls12_381.Fr.of_string e1)))
      test_vectors

  let test_pow () =
    let test_vectors =
      [ ( "19382565044794829105685946147333667407406947769919002500736830762980080217116",
          "48159949448997187908979844521309454081051202554580566653703924472697903187543",
          "51805065919052658973952545206023802114592698824188349145165662267033488307015"
        );
        ( "38434293760957543250833416278928537431247174199351417891430036507051711516795",
          "19350167110479287515066444930433610752856061045118438172892254847951537570134",
          "5638414748000331847846282606999064802458819295656595143203518899742396580213"
        );
        ( "49664271363539622878107770584406780589976347771473156015482691689195652813880",
          "19379581748332915194987329063856477906332155141792491408304078230104564222030",
          "30921874175813683797322233883008640815321607592610957475928976635504264297632"
        );
        ( "51734967732893479663302261399661867713222970046133566655959761380034878973281",
          "37560370265646062523028551976728263929547556442627149817510607017268305870511",
          "49814797937772261149726667662726741057831444313882786994092918399718266462922"
        ) ]
    in
    List.iter
      (fun (x, e, expected_result) ->
        assert (
          Bls12_381.Fr.eq
            (Bls12_381.Fr.pow (Bls12_381.Fr.of_string x) (Z.of_string e))
            (Bls12_381.Fr.of_string expected_result)))
      test_vectors

  let get_tests () =
    let open Alcotest in
    ( "Test vectors",
      [ test_case "inverse" `Quick test_inverse;
        test_case "add" `Quick test_add;
        test_case "add bulk" `Quick test_add_bulk;
        test_case "mul bulk" `Quick test_mul_bulk;
        test_case "opposite" `Quick test_opposite;
        test_case "pow" `Quick test_pow;
        test_case "multiplication" `Quick test_mul ] )
end

module FFT = struct
  (* Generated using https://github.com/dannywillems/ocaml-polynomial, commit
     8351c266c4eae185823ab87d74ecb34c0ce70afe with the following program: ```
     module Fr = Ff.MakeFp (struct let prime_order = Z.of_string
     "52435875175126190479447740508185965837690552500527637822603658699938581184513"
     end)

     module Poly = Polynomial.MakeUnivariate (Fr)

     let () = Random.self_init () ; let n = 16 in let root = Fr.of_string
     "16624801632831727463500847948913128838752380757508923660793891075002624508302"
     in let domain = Polynomial.generate_evaluation_domain (module Fr) n root in
     let coefficients = List.init n (fun i -> (Fr.random (), i)) in let
     result_fft = Poly.evaluation_fft ~domain (Poly.of_coefficients
     coefficients) in Printf.printf "Random generated points: [%s]\n"
     (String.concat "; " (List.map (fun s -> Printf.sprintf "\"%s\""
     (Fr.to_string s)) (List.map fst coefficients))) ; Printf.printf "Results
     FFT: [%s]\n" (String.concat "; " (List.map (fun s -> Printf.sprintf
     "\"%s\"" (Fr.to_string s)) result_fft)) ``` *)
  let test_fft_vectors () =
    let vectors =
      [ ( [| "27368034540955591518185075247638312229509481411752400387472688330662143761856";
             "19540886853600136773806888540031779652697522926951761090609474934921975120659";
             "26220624956959285725992525915931330099055855809419283071707941601749666540606";
             "35989465088288326521015971876164012326945860638993195438436634989311471699248";
             "40768987516446156628891831412618502769603720088125758542973088262778427031409";
             "37502582815775325591532709222383633732324588493894705918379415386493138186217";
             "36239410834198262339129557342130251912163884537720472258419319596614475181710";
             "30052101390787354520041305700295264045780224441445621717858661812094895346346";
             "21995102202891872269281007631877407834312363335297399149197261878759964569557";
             "2080131691710661742168916043433037277601198784836429928476841594059118749370";
             "42808036164195249275280963312025828986508786508614910971333518929197538998773";
             "5416726269860450738839660947415682809504169447200045382722531315472176837580";
             "35385358739760726215042915512119186540038118703012759099153921687310544107033";
             "27079498335589470388559429012071885383086029562052523482197446658383111072774";
             "14990895240018155420388973968063729735246061536340426651548494721699138380965";
             "44309562300548454609435401663522908994502966824080187553903158603409727800199"
          |],
          [| "28260403540575956442011209282235027627356413045516778063561130703408863908198";
             "17993250808843485497593981839623744555167943862527528485216257064528703538115";
             "28899493105874864372514833666497043025570659782554515014837391083549224357663";
             "51337256534645387155350783214024321835908156339022153213532792354442520429110";
             "36105366491256902485994568622814429160585987748654956293511966452904096000801";
             "43254842638818221613648051676914453096533481207151298911620538414624271037642";
             "30137483332361623247450591551673456707141812995305992129418088848770541392731";
             "51832887160148947731754609316481314302061191268958147833796630151024005898627";
             "43805495449265118506792567337086345883995710810828939619222069714626283759516";
             "43490811501888359185770575458084504215306703326085936961313644380351136142796";
             "45353492906491645466864766616545361422166823184893464158187486307135027299228";
             "25825572114166843629678422732449048165822431962411503253462472518376902250644";
             "26847540293236075734670790417576073958082755044059129980667062867535005919314";
             "27595037266661293341555794625370636649048746138720916959755452489901838331803";
             "50624068481465143084533854525326091050293490363529345388747088297570661644827";
             "43833176554968168233119024604069041530181053009400713400523917741660961832220"
          |],
          "16624801632831727463500847948913128838752380757508923660793891075002624508302",
          16 );
        ( [| "47158772775073549946552793332529610487862373214948589019241181027783090564927";
             "6969718530264830180568846645175610175808087246047159746318756753094302772749";
             "9686871355228041364920849477160310252453883661104177346095519526469628056477";
             "23701529205156171747824936169986903488212555374755529649712750610781499462060";
             "51871556544025649087958327041446036456025707894309969231504981069404849216674";
             "49777423642698315996233125696731960180992156573003897035030679033255179062106";
             "45193193026211585427447988721783950037458564208700328346100038403604928063434";
             "22127747185998681281737634883536464039523214813021737348626571438746574042602";
             "2436430336755214848244332120262587151205846315495966767110243193396303772169";
             "36030568404692126810397267528533249629542998741265626260816144992520627327404";
             "9733396005656647923887929901290339938184031472478829155648784527262943967802";
             "9232698019619721561468579430575787343679427145493378862256989115824088269321";
             "14667337314275170563143674471965744229406746565668692173766020639206764616232";
             "4730122363727714359627443666953284727545363839021842492384814113239394248107";
             "37600263337451873049904059627388200632297313939920669755923850829944793593331";
             "45293309035642456591052566417557511757964418893263771110015399573101864564094"
          |],
          [| "49159810856594417384836171575575789664328822394806699542327113948066763307898";
             "19513654523362036572945532378832190324412992065939315076003556719650225069528";
             "12400187722036186964464702144585831794106028402975104166770049464367024965836";
             "12729164750455352417868976767915518872789618782856391788646411468569638526867";
             "33894355416182050171353418403150653912631032966615091567798695189037336420208";
             "48124615888501419045682889152193022416530216136751831272743260607287479387889";
             "2671821870190640507797010788564244592122722767639756300432356882625084132990";
             "5747205261848282327286719985435091052484794664574217516630541561287563721611";
             "20484704306877713683149554254776007841626244646754279290228513586509772102603";
             "27810669340447093284494524394980216672115899286964546160004040217206390970278";
             "43245957846359230019664483425272837146730091593909167243373849997985752696625";
             "22694735552917590450918366121541571341777153373371464847736029264056462779996";
             "46382266250107013667570920582197666853273280950350971430513428795918673742221";
             "51480236715740128219868641008506780736289153092278122714177218949428874124399";
             "31214895100904294521197520923656651794655875018922463281556409805109003774848";
             "12370831947896207029058818364173897763780730291302175173295467787791916207957"
          |],
          "16624801632831727463500847948913128838752380757508923660793891075002624508302",
          16 ) ]
    in
    List.iter
      (fun (points, expected_fft_results, root, n) ->
        let root = Bls12_381.Fr.of_string root in
        let points = Array.map Bls12_381.Fr.of_string points in
        let copy_points = Array.map Bls12_381.Fr.copy points in
        let expected_fft_results =
          Array.map Bls12_381.Fr.of_string expected_fft_results
        in
        let domain =
          Array.init n (fun i -> Bls12_381.Fr.pow root (Z.of_int i))
        in
        let fft_results = Bls12_381.Fr.fft ~domain ~points in
        let () = Bls12_381.Fr.fft_inplace ~domain ~points:copy_points in
        Array.iter2
          (fun p1 p2 ->
            if not (Bls12_381.Fr.eq p1 p2) then
              Alcotest.failf
                "Expected FFT result %s\nbut the computed value is %s\n"
                (Bls12_381.Fr.to_string p1)
                (Bls12_381.Fr.to_string p2))
          expected_fft_results
          fft_results ;
        Array.iter2
          (fun p1 p2 ->
            if not (Bls12_381.Fr.eq p1 p2) then
              Alcotest.failf
                "Expected FFT result %s\nbut the computed value is %s\n"
                (Bls12_381.Fr.to_string p1)
                (Bls12_381.Fr.to_string p2))
          expected_fft_results
          copy_points ;
        let idomain =
          Array.init n (fun i -> if i = 0 then domain.(0) else domain.(n - i))
        in
        let ifft_results =
          Bls12_381.Fr.ifft ~domain:idomain ~points:fft_results
        in
        Array.iter2
          (fun p1 p2 ->
            if not (Bls12_381.Fr.eq p1 p2) then
              Alcotest.failf
                "Expected FFT result %s\nbut the computed value is %s\n"
                (Bls12_381.Fr.to_string p1)
                (Bls12_381.Fr.to_string p2))
          points
          ifft_results)
      vectors

  let test_fft_with_greater_domain_vectors () =
    (* Vectors generated with the following program: ``` module Poly =
       Polynomial.MakeUnivariate (Bls12_381.Fr) let fft_polynomial () =
       Random.self_init () ; let n = 16 in let root = Bls12_381.Fr.of_string
       "16624801632831727463500847948913128838752380757508923660793891075002624508302"
       in let domain = Array.init n (fun i -> Bls12_381.Fr.pow root (Z.of_int
       i)) in let pts = List.init (1 + Random.int (n - 1)) (fun _ ->
       Bls12_381.Fr.random ()) in let polynomial = Poly.of_coefficients
       (List.mapi (fun i a -> (a, i)) pts) in let result_fft =
       Poly.evaluation_fft ~domain polynomial in Printf.printf "Random generated
       points: [%s]\n" (String.concat "; " (List.map (fun s -> Printf.sprintf
       "\"%s\"" (Bls12_381.Fr.to_string s)) pts)) ; Printf.printf "Results FFT:
       [%s]\n" (String.concat "; " (List.map (fun s -> Printf.sprintf "\"%s\""
       (Bls12_381.Fr.to_string s)) result_fft)) ``` *)
    let vectors_for_fft_with_greater_domain =
      [ ( [| "9094991653442636551690401718409437467203667404120465574859260125376376539450";
             "36784955550505906583992321485589046801627651823699631865063763788121474956423";
             "23827544216835540859131494346185922491907194146637931126659231165131053381546";
             "10176016683576441255472989519285808950044942050632563738283008320151081557329";
             "41261344119924552928659481894133335263574984487635963901785259507577321585518";
             "28108264987024051584932616695427507902278417309474112669437967601423863612687";
             "21663005828102287486879023285429676198163987257708847741409763610604537443435";
             "18912970628341929012261641271508381962649936522242143993694370697397857088913";
             "33177098286124931552384105142324342074093558966750206832606157530164930555990";
             "41779089735219182784224021378358463745524240595217520312794088473702250244182";
             "24771759634084311767096550664156494017951139598922779731418065985892886762579";
             "18834636798335127532549678052953254168490017021191169393716309390907400251275";
             "37065057460533301959533800444892921530478486771898638531540967318564763301424";
             "18938863825307662380373110832265488863727283022825056414953618706445868152394"
          |],
          [| "49780348356600721362494793681804286411572191975791204892599880021830178326067";
             "8549591071530141239261747244017543764022520298682086923116546417177857002039";
             "35886012007479519208161417657801891880299072602521153742960206336995970034979";
             "36879757027451463267869158639366365984684566292751757860296441614566288944016";
             "25552627061385412172712093185426062975326634130990223990807408609971848562932";
             "40849721284704094903185176454822507982303428910642899972182407608731263436679";
             "40262217027396163892755703349196195510233017307031851974427648769362539590762";
             "4024657785152272655575160397887740541765239374805874835569295765424969048069";
             "17326002990737261971568478260144176649030530288392635052335578265162073706739";
             "47515927815717320642495388213183809977298704534265933353706448858555977417195";
             "52298143452904716702579823336245852729554594072189474112975263645940258094478";
             "38128262572060415006531869596459654355503839891826916597932054131315998785692";
             "22683861445494963106161608114363858441639566622753570669198100130199399042199";
             "42340678072800669141416985973284322598393757133909156380080108708870479614576";
             "41951631999415595936714396792701945895031651466767627001815596764929608220851";
             "8541552710134786973696810155146544642433231066298546595970787256557383095518"
          |],
          "16624801632831727463500847948913128838752380757508923660793891075002624508302",
          16 );
        ( [| "20366504166179122431562501467558245272875051944994165565786399718324788856679";
             "40707817767410470154858828539330531184811806360720222380433027956764139746466";
             "356740997816546714538836356735076115722082850319975887507567537568199256047";
             "48855616550298959913298962949425933402033459692306408089491507478720529722094";
             "50541121720442637012670577014433112674281325316959751220046011112849321159679";
             "23560938154727269982745286190878568921692353327526898815237861835948424192124";
             "30355630669939243314704291156412040070582169882207211757125280380204423737785";
             "15505400703222858077649159431058027041296078925582612030937675335604082942698";
             "9586508907273909539462890684309186991235869304827055764285226746962615270470";
             "21709482882717689551729218263314753077681455523073051228049601241465109175016"
          |],
          [| "51802261819523944775429590020711611401449443126406801448485524544657309321006";
             "29550508720460856371179136000468622846061053475009563533950956229272926799427";
             "34504932105265771677001237289210566670578056002926384303520505022799649248166";
             "4643308580964924754290358292327975630897331781437501325565301584135504508458";
             "17730606024639651178329906540477536898037036267737442452479452878455969345160";
             "24297582300913880282598264556022644683498819864163783595116300237736738839190";
             "45214789002547697621229629104795392415050372172770523100077751708945973280784";
             "38763628634933901441181735457381723197057249525798600597931200723695018553421";
             "13303125578400401812105381813625813334871897970626605473204470347345643686775";
             "32546955097754011854531536998637015836635047626862902049591688741227100748732";
             "43371134287888091869973665347576016158409006343795943923125773302177689132719";
             "977886516424948761804141006390103804220304457123540866565332209651749412953";
             "29397045052513916251128036257643354768448398900242489535886467742333654056319";
             "42811280985553165680233963683840751931239235399282560432833035292503761934416";
             "4300210716844780583005690840899166466043159214063580403793066175583344946263";
             "17520561584488394949873231287295559998885523992713701655662886152551750262101"
          |],
          "16624801632831727463500847948913128838752380757508923660793891075002624508302",
          16 );
        ( [| "32801662691963427514267894674769063086591208663284771582446704033458906830071";
             "24619295659426029871924262808019119093071500634075223399719630241414416329188";
             "30281390693300077132916380864478514127955276426883373365519750642923776606198";
             "18360093270499580872004343235099023022053747412073668894932667384067918433774";
             "29963087933945554223059107694526533492795491013596481736225165935107527885595";
             "11751763604609984739794412901449568244757509926148834238756168445779385705986";
             "12053604641353691632646194412265923075808946261200908259159925010321955112554";
             "18754076052090553735885674487706501053759862205295654431460792297041333363001";
             "47468650442554572799432426443366889486432535695490121813022148744472031223598";
             "14440572519495178160314880615884126543409017897541889779007038203125763034294"
          |],
          [| "30750696808733888764454616104821397875872886133480376209835356137958689786207";
             "49483516902638449411010713773222171172110676754879303430247846257920008023265";
             "50001076338014749759889979935035920868691846963545175128696820779919918368493";
             "29272587126301051909677034081892875172511198246651372545679439519796830186976";
             "47427833951319342460150948284104794355462688464805550185990729120932799600905";
             "49998526798262076618938116969936636882951238460630346414173801769033033742691";
             "25521743570973710093283381420987544378598602802917257652549357440730406563564";
             "45895319943762993960416590175848277115358075420167900587796337144240772114664";
             "12206720121869805442950689533062619474841267484792748189893739094916799607260";
             "21183683010445370049002762862965083896160882035130570824969727228122839130361";
             "33920383903205043356875140927108958078964986378193302844915854434108615373905";
             "31857510768286257012272964035049915872502891931888264780127736321339350249744";
             "35933102341174038602795018279545337530956784403240999005434298298714087655606";
             "14290588518514609077405374097049833967459854487008550973527796654640168619796";
             "39349821814970090673068610903119287156967024735530273188209056016596119181821";
             "7733491152943363036094373412554355586048433909694353357099368316372071075878"
          |],
          "16624801632831727463500847948913128838752380757508923660793891075002624508302",
          16 ) ]
    in
    List.iter
      (fun (points, expected_fft_results, root, n) ->
        let root = Bls12_381.Fr.of_string root in
        let points = Array.map Bls12_381.Fr.of_string points in
        let expected_fft_results =
          Array.map Bls12_381.Fr.of_string expected_fft_results
        in
        let domain =
          Array.init n (fun i -> Bls12_381.Fr.pow root (Z.of_int i))
        in
        let fft_results = Bls12_381.Fr.fft ~domain ~points in
        Array.iter2
          (fun p1 p2 ->
            if not (Bls12_381.Fr.eq p1 p2) then
              Alcotest.failf
                "Expected FFT result %s\nbut the computed value is %s\n"
                (Bls12_381.Fr.to_string p1)
                (Bls12_381.Fr.to_string p2))
          expected_fft_results
          fft_results)
      vectors_for_fft_with_greater_domain

  let get_tests () =
    let open Alcotest in
    ( "FFT with Fr",
      [ test_case "vectors" `Quick test_fft_vectors;
        test_case
          "vectors with greater domain"
          `Quick
          test_fft_with_greater_domain_vectors ] )
end

module OCamlComparisonOperators = struct
  let test_fr_equal_with_same_random_element () =
    let x = Bls12_381.Fr.random () in
    if not (x = x) then
      Alcotest.failf
        "(=) Expected comparison on the same random element must be true, got \
         false"

  let test_fr_equal_with_zero () =
    if not (Bls12_381.Fr.zero = Bls12_381.Fr.zero) then
      Alcotest.failf "(=) Expected comparison on zero must be true, got false"

  let test_fr_equal_with_one () =
    if not (Bls12_381.Fr.one = Bls12_381.Fr.one) then
      Alcotest.failf "(=) Expected comparison on one must be true, got false"

  let test_fr_not_equal_with_random () =
    let x = Bls12_381.Fr.random () in
    let y = Bls12_381.Fr.(x + one) in
    if not (x != y) then
      Alcotest.failf
        "(!=) Expected comparison on a random element and its successor must \
         be true, got false"

  let test_fr_equality_failing_test_with_random () =
    let x = Bls12_381.Fr.random () in
    let y = Bls12_381.Fr.(x + one) in
    if x = y then
      Alcotest.failf
        "(=) Expected comparison on a random element and its successor must be \
         false, got true"

  let test_fr_different_failing_test_with_same_random_element () =
    let x = Bls12_381.Fr.random () in
    if x != x then
      Alcotest.failf
        "(!=) Expected comparison on a random element must be false, got true"

  let test_fr_zero_is_smaller_than_one () =
    if not (Bls12_381.Fr.zero < Bls12_381.Fr.one) then
      Alcotest.failf "(<) zero is expected to be smaller than one"

  let test_fr_zero_is_not_greater_than_one () =
    if Bls12_381.Fr.zero > Bls12_381.Fr.one then
      Alcotest.failf "(>) zero is not expected to be greater than one"

  let test_fr_one_is_greater_than_zero () =
    if not (Bls12_381.Fr.one > Bls12_381.Fr.zero) then
      Alcotest.failf "(>) one is expected to be greater than zero"

  let test_fr_one_is_not_smaller_than_zero () =
    if Bls12_381.Fr.one < Bls12_381.Fr.zero then
      Alcotest.failf "(<) one is not expected to be smaller than zero"

  let test_fr_successor_is_greater () =
    let x = Bls12_381.Fr.random () in
    if not (Bls12_381.Fr.(x + one) > x) then
      Alcotest.failf "(>) the successor of an element is expected to be greater"

  let test_fr_random_element_is_smaller_than_its_successor () =
    let x = Bls12_381.Fr.random () in
    if not (x < Bls12_381.Fr.(x + one)) then
      Alcotest.failf
        "(<) a random element (when smaller than order - 1) is smaller than \
         its succesor"

  let get_tests () =
    let open Alcotest in
    ( "Test comparison operators",
      [ test_case
          "(=) operator on random element"
          `Quick
          (Test_ec_make.repeat 100 test_fr_equal_with_same_random_element);
        test_case
          "(=) operator on random element: failing test"
          `Quick
          (Test_ec_make.repeat 100 test_fr_equality_failing_test_with_random);
        test_case
          "(!=) operator on random element: failing test"
          `Quick
          (Test_ec_make.repeat
             100
             test_fr_different_failing_test_with_same_random_element);
        test_case "(=) operator on zero" `Quick test_fr_equal_with_zero;
        test_case "(=) operator on one" `Quick test_fr_equal_with_one;
        test_case "(<) 0 < 1" `Quick test_fr_zero_is_smaller_than_one;
        test_case
          "(>) 0 > 1: failing test"
          `Quick
          test_fr_zero_is_not_greater_than_one;
        test_case "(>) successor is greater" `Quick test_fr_successor_is_greater;
        test_case "(>) 1 > 0" `Quick test_fr_one_is_greater_than_zero;
        test_case
          "(<) 1 < 0: failing test"
          `Quick
          test_fr_one_is_not_smaller_than_zero;
        test_case
          "(<) x < x + 1"
          `Quick
          test_fr_random_element_is_smaller_than_its_successor;
        test_case "(=) operator on one" `Quick test_fr_equal_with_one ] )
end

module InnerProduct = struct
  let test_random_elements () =
    let n = 1 + Random.int 1000 in
    let a = Array.init n (fun _ -> Bls12_381.Fr.random ()) in
    let b = Array.init n (fun _ -> Bls12_381.Fr.random ()) in
    let exp_res =
      Array.fold_left
        Bls12_381.Fr.add
        Bls12_381.Fr.zero
        (Array.map2 Bls12_381.Fr.mul a b)
    in
    let res_exn = Bls12_381.Fr.inner_product_exn a b in
    let res_opt = Bls12_381.Fr.inner_product_opt a b in
    assert (Option.is_some res_opt) ;
    assert (Bls12_381.Fr.eq exp_res res_exn) ;
    assert (Bls12_381.Fr.eq exp_res (Option.get res_opt))

  let get_tests () =
    let open Alcotest in
    ( "Inner product",
      [ test_case
          "with random elements"
          `Quick
          (Test_ec_make.repeat 100 test_random_elements) ] )
end

module AdditionalConstructors = struct
  let test_positive_values_as_documented () =
    let n = Random.int 1_000_000 in
    let n_fr = Bls12_381.Fr.of_int n in
    assert (Bls12_381.Fr.(eq (of_z (Z.of_int n)) n_fr))

  let test_positive_values_use_decimal_representation () =
    let n = Random.int 1_000_000 in
    let n_fr = Bls12_381.Fr.of_int n in
    assert (String.equal (Bls12_381.Fr.to_string n_fr) (string_of_int n))

  let test_negative_values_as_documented () =
    let n = -Random.int 1_000_000 in
    let n_fr = Bls12_381.Fr.of_int n in
    assert (Bls12_381.Fr.(eq (of_z (Z.of_int n)) n_fr))

  let test_negative_values_use_decimal_representation () =
    let n = -Random.int 1_000_000 in
    let n_fr = Bls12_381.Fr.of_int n in
    let res = Bls12_381.Fr.to_string n_fr in
    let exp_res_z = Z.(add Bls12_381.Fr.order (of_int n)) in
    let exp_res = Bls12_381.Fr.(to_string (of_z exp_res_z)) in
    assert (String.equal res exp_res)

  let get_tests () =
    let open Alcotest in
    ( "Additional Constructors",
      [ test_case
          "with positive values as documented"
          `Quick
          (Test_ec_make.repeat 100 test_positive_values_as_documented);
        test_case
          "with positive values use decimal represntation"
          `Quick
          (Test_ec_make.repeat
             100
             test_positive_values_use_decimal_representation);
        test_case
          "with negative values as documented"
          `Quick
          (Test_ec_make.repeat 100 test_negative_values_as_documented);
        test_case
          "with negeative values use decimal represntation"
          `Quick
          (Test_ec_make.repeat
             100
             test_negative_values_use_decimal_representation) ] )
end

let () =
  let open Alcotest in
  run
    "Fr"
    (TestVector.get_tests ()
    :: ZRepresentation.get_tests ()
    :: Memory.get_tests ()
    :: AdditionalConstructors.get_tests ()
    :: InplaceOperations.get_tests ()
    :: BytesRepresentation.get_tests ()
    :: OCamlComparisonOperators.get_tests ()
    :: InnerProduct.get_tests ()
    :: StringRepresentation.get_tests ()
    :: FFT.get_tests () :: Tests.get_tests ())
