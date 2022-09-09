open Core_bench

module MakeBenchBlst = struct
  module F = Bls12_381.Fr

  let test_addition =
    let e1 = F.random () in
    let e2 = F.random () in
    Bench.Test.create ~name:"Addition Fr" (fun () -> ignore (F.add e1 e2))

  let test_addition_inplace =
    let e1 = F.random () in
    let e2 = F.random () in
    let res = F.(copy one) in
    Bench.Test.create
      ~name:"Addition inplace Fr (save an allocation)"
      (fun () -> ignore (F.add_inplace res e1 e2))

  let test_multiplication =
    let e1 = F.random () in
    let e2 = F.random () in
    Bench.Test.create ~name:"Multiplication Fr" (fun () -> ignore (F.mul e1 e2))

  let test_multiplication_inplace =
    let e1 = F.random () in
    let e2 = F.random () in
    let res = F.(copy one) in
    Bench.Test.create
      ~name:"Multiplication inplace Fr (save an allocation)"
      (fun () -> ignore (F.mul_inplace res e1 e2))

  let test_sub =
    let e1 = F.random () in
    let e2 = F.random () in
    Bench.Test.create ~name:"Substraction Fr" (fun () -> ignore (F.sub e1 e2))

  let test_sub_inplace =
    let e1 = F.random () in
    let e2 = F.random () in
    let res = F.(copy one) in
    Bench.Test.create
      ~name:"Substraction inplace Fr (save an allocation)"
      (fun () -> ignore (F.sub_inplace res e1 e2))

  let test_negate =
    let e1 = F.random () in
    Bench.Test.create ~name:"Opposite Fr" (fun () -> ignore (F.negate e1))

  let test_negate_inplace =
    let e1 = F.random () in
    let res = F.(copy one) in
    Bench.Test.create
      ~name:"Negation inplace Fr (save an allocation)"
      (fun () -> ignore (F.negate_inplace res e1))

  let test_square =
    let e1 = F.random () in
    Bench.Test.create ~name:"Square Fr" (fun () -> ignore (F.square e1))

  let test_square_inplace =
    let e1 = F.random () in
    let res = F.(copy one) in
    Bench.Test.create ~name:"Square inplace Fr (save an allocation)" (fun () ->
        ignore (F.square_inplace res e1))

  let test_double =
    let e1 = F.random () in
    Bench.Test.create ~name:"Double Fr" (fun () -> ignore (F.double e1))

  let test_double_inplace =
    let e1 = F.random () in
    let res = F.(copy one) in
    Bench.Test.create ~name:"Double inplace Fr (save an allocation)" (fun () ->
        ignore (F.double_inplace res e1))

  let test_inverse =
    let e1 = F.random () in
    Bench.Test.create ~name:"Inverse Fr" (fun () -> ignore (F.inverse_exn e1))

  let test_inverse_inplace =
    let e1 = F.random () in
    let res = F.(copy one) in
    Bench.Test.create ~name:"Inverse inplace Fr (save an allocation)" (fun () ->
        ignore (F.inverse_exn_inplace res e1))

  let test_pow =
    let e1 = F.random () in
    let n = F.(to_z (random ())) in
    Bench.Test.create ~name:"Pow Fr" (fun () -> ignore (F.pow e1 n))

  let test_of_bytes_exn =
    let e = F.random () in
    let e_bytes = F.to_bytes e in
    Bench.Test.create ~name:"of_bytes_exn Fr" (fun () ->
        ignore (F.of_bytes_exn e_bytes))

  let test_to_bytes =
    let e = F.random () in
    Bench.Test.create ~name:"to_bytes Fr" (fun () -> ignore (F.to_bytes e))

  let test_sqrt_opt =
    let e = F.random () in
    let ee = F.square e in
    Bench.Test.create ~name:"square root when exists" (fun () ->
        ignore (F.sqrt_opt ee))

  let test_copy =
    Bench.Test.create
      ~name:"Copy zero, equivalent to a new allocation"
      (fun () -> ignore F.(copy zero))

  let get_benches () =
    [ test_addition;
      test_addition_inplace;
      test_multiplication;
      test_multiplication_inplace;
      test_negate;
      test_negate_inplace;
      test_sub;
      test_sub_inplace;
      test_square;
      test_square_inplace;
      test_inverse;
      test_inverse_inplace;
      test_pow;
      test_double;
      test_double_inplace;
      test_of_bytes_exn;
      test_to_bytes;
      test_sqrt_opt;
      test_copy ]
end

let () =
  let commands = List.concat [MakeBenchBlst.get_benches ()] in
  Command_unix.run (Core_bench.Bench.make_command commands)
