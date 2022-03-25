open Core
open Core_bench

let generate_random_byte () = char_of_int (Random.int 256)

let generate_random_bytes size =
  Bytes.init size ~f:(fun _ -> generate_random_byte ())

module type SIGNATURE_INSTANTIATION = module type of Bls12_381.Signature.MinPk

module MakeBenches (SignatureM : sig
  include SIGNATURE_INSTANTIATION

  val name : string
end) =
struct
  let t1 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let name =
      Printf.sprintf
        "%s -\nSign on random message of random size - Basic scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () -> ignore @@ SignatureM.Basic.sign sk msg)

  let t2 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    Bench.Test.create
      ~name:"Sign on random message of random size - Aug scheme"
      (fun () -> ignore @@ SignatureM.Aug.sign sk msg)

  let t3 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let name =
      Printf.sprintf
        "%s -\nSign on random message of random size - Pop scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () -> ignore @@ SignatureM.Pop.sign sk msg)

  let t4 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let pk = SignatureM.derive_pk sk in
    let signature = SignatureM.Basic.sign sk msg in
    let name =
      Printf.sprintf
        "%s - Verify correct signature with correct pk - Basic Scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () ->
        ignore @@ SignatureM.Basic.verify pk msg signature)

  let t5 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let pk = SignatureM.derive_pk sk in
    let signature = SignatureM.Aug.sign sk msg in
    let name =
      Printf.sprintf
        "%s - \nVerify correct signature with correct pk - Aug Scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () ->
        ignore @@ SignatureM.Aug.verify pk msg signature)

  let t6 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let pk = SignatureM.derive_pk sk in
    let signature = SignatureM.Aug.sign sk msg in
    let name =
      Printf.sprintf
        "%s - \nVerify correct signature with correct pk - Pop Scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () ->
        ignore @@ SignatureM.Pop.verify pk msg signature)

  let t7 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let ikm' = generate_random_bytes 32 in
    let sk' = Bls12_381.Signature.generate_sk ikm' in
    let pk' = SignatureM.derive_pk sk' in
    let signature = SignatureM.Basic.sign sk msg in
    let name =
      Printf.sprintf
        "%s - \nVerify correct signature with incorrect pk - Basic Scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () ->
        ignore @@ SignatureM.Basic.verify pk' msg signature)

  let t8 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let ikm' = generate_random_bytes 32 in
    let sk' = Bls12_381.Signature.generate_sk ikm' in
    let pk' = SignatureM.derive_pk sk' in
    let signature = SignatureM.Aug.sign sk msg in
    let name =
      Printf.sprintf
        "%s - \nVerify correct signature with incorrect pk - Aug Scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () ->
        ignore @@ SignatureM.Aug.verify pk' msg signature)

  let t9 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let ikm' = generate_random_bytes 32 in
    let sk' = Bls12_381.Signature.generate_sk ikm' in
    let pk' = SignatureM.derive_pk sk' in
    let signature = SignatureM.Pop.sign sk msg in
    let name =
      Printf.sprintf
        "%s -\nVerify correct signature with incorrect pk - Pop Scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () ->
        ignore @@ SignatureM.Pop.verify pk' msg signature)

  let t10 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let msg' = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let pk = SignatureM.derive_pk sk in
    let signature = SignatureM.Basic.sign sk msg in
    let name =
      Printf.sprintf
        "%s - \nVerify incorrect message with correct pk - Basic Scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () ->
        ignore @@ SignatureM.Basic.verify pk msg' signature)

  let t11 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let msg' = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let pk = SignatureM.derive_pk sk in
    let signature = SignatureM.Aug.sign sk msg in
    let name =
      Printf.sprintf
        "%s - \nVerify incorrect message with correct pk - Aug Scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () ->
        ignore @@ SignatureM.Aug.verify pk msg' signature)

  let t12 =
    let ikm = generate_random_bytes 32 in
    let msg = generate_random_bytes (1 + Random.int 512) in
    let msg' = generate_random_bytes (1 + Random.int 512) in
    let sk = Bls12_381.Signature.generate_sk ikm in
    let pk = SignatureM.derive_pk sk in
    let signature = SignatureM.Pop.sign sk msg in
    let name =
      Printf.sprintf
        "%s - \nVerify incorrect message with correct pk - Pop Scheme"
        SignatureM.name
    in
    Bench.Test.create ~name (fun () ->
        ignore @@ SignatureM.Pop.verify pk msg' signature)

  let t13 =
    let name = Printf.sprintf "%s - \nGenerate public keys" SignatureM.name in
    Bench.Test.create ~name (fun () ->
        let ikm = generate_random_bytes 32 in
        let sk = Bls12_381.Signature.generate_sk ikm in
        let pk = SignatureM.derive_pk sk in
        ignore pk)

  let benches = [t1; t2; t3; t4; t5; t6; t7; t8; t9; t10; t11; t12; t13]
end

module MinPkBenches = MakeBenches (struct
  let name = "minPk"

  include Bls12_381.Signature.MinPk
end)

module MinSigBenches = MakeBenches (struct
  let name = "minSig"

  include Bls12_381.Signature.MinSig
end)

let () =
  let commands = List.concat [MinPkBenches.benches; MinSigBenches.benches] in
  Core.Command.run (Bench.make_command commands)
