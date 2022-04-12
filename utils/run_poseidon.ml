let run () =
  let nb_partial_rounds = 59 in
  let batch_size = 6 in
  let nb_full_rounds = 8 in
  let width = 5 in
  let ark_length = width * (nb_full_rounds + nb_partial_rounds) in
  let ark = Array.init ark_length (fun _ -> Bls12_381.Fr.random ()) in
  let mds =
    Array.init width (fun _ ->
        Array.init width (fun _ -> Bls12_381.Fr.random ()))
  in
  let inputs = Array.init width (fun _ -> Bls12_381.Fr.random ()) in
  let module BaseParameters = struct
    let nb_full_rounds = nb_full_rounds

    let nb_partial_rounds = nb_partial_rounds

    let width = width

    let ark = ark

    let mds = mds
  end in
        let module Parameters = struct
          include BaseParameters

          let batch_size = batch_size
        end in
        let module Poseidon = Bls12_381.Poseidon.Make (Parameters) in
        let ctxt = Poseidon.init inputs in
        let name =
          Printf.sprintf
            "Benchmark Poseidon: width = %d, batch size = %d, partial rounds = %d"
            width
            batch_size
            nb_partial_rounds
        in
        print_endline name;
            Poseidon.apply_permutation ctxt

let () = run ()
