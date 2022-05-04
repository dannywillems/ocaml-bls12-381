let () = Memtrace.trace_if_requested ~context:"Test" ()

let rec repeat n f () =
  if n > 0 then (
    f () ;
    repeat (n - 1) f ())

let f () =
  let generate_random_byte () = char_of_int (Random.int 256) in

  let generate_random_bytes size =
    Bytes.init size (fun _ -> generate_random_byte ())
  in

  let ikm = generate_random_bytes 32 in
  let msg = generate_random_bytes 32 in
  let sk = Bls12_381.Signature.generate_sk ikm in
  let pk = Bls12_381.Signature.MinPk.derive_pk sk in
  let signature = Bls12_381.Signature.MinPk.Basic.sign sk msg in
  assert (Bls12_381.Signature.MinPk.Basic.verify pk msg signature)

let () = repeat 10_000 f ()
