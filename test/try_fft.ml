let g_2_32 =
  Bls12_381.Fr.of_string
    "21584124886548760190346392867028830688912556631271990304491841940743921295609"

let g_2_16 =
  Bls12_381.Fr.of_string
    "45578933624873246016802258050230213493140367389966312656957679049059636081617"

let g_2_8 =
  Bls12_381.Fr.of_string
    "27611812781829920551290133267575249478648871281233506899293410857719571783635"

let g_2_4 =
  Bls12_381.Fr.of_string
    "16624801632831727463500847948913128838752380757508923660793891075002624508302"

let g_2_2 = Bls12_381.Fr.pow g_2_4 (Z.of_int 4)


let get_generator i =
  if i > 32 then
    raise (Invalid_argument "Fr_generation.get_generator : i > 32.")
  else if i > 16 then Bls12_381.Fr.pow g_2_32 (Z.of_int (Int.shift_left 1 (32 - i)))
  else if i > 8 then Bls12_381.Fr.pow g_2_16 (Z.of_int (Int.shift_left 1 (16 - i)))
  else if i > 4 then Bls12_381.Fr.pow g_2_8 (Z.of_int (Int.shift_left 1 (8 - i)))
  else if i > 2 then Bls12_381.Fr.pow g_2_4 (Z.of_int (Int.shift_left 1 (4 - i)))
  else g_2_2

let powers size x =
  let xi = ref Bls12_381.Fr.one in
  Array.init size (fun _ ->
      let i = !xi in
      (xi := Bls12_381.Fr.(x * !xi)) ;
      i)

let build_domain i =
  let g = get_generator i in
  powers (1 lsl i) g


let main () =
  (* let vectors = [Vector_fft.vector] in *)
  let vectors = Vectors_fft.vectors in

  List.iter
    (fun (points, expected_fft_results, root, _n) ->
       let _root = Bls12_381.Fr.of_string root in
       let points = Array.map Bls12_381.Fr.of_string points in
       let expected_fft_results =
         Array.map Bls12_381.Fr.of_string expected_fft_results
       in
       let domain = build_domain 16
         (* Array.init n (fun i -> Bls12_381.Fr.pow root (Z.of_int i)) *)
       in
       let fft_results = Bls12_381.Fr.fft ~domain ~points in
       Array.iter2
         (fun p1 p2 ->
            if not (Bls12_381.Fr.eq p1 p2) then
              failwith (Printf.sprintf
                "Expected FFT result %s\nbut the computed value is %s\n"
                (Bls12_381.Fr.to_string p1)
                (Bls12_381.Fr.to_string p2)))
         expected_fft_results
         fft_results
    ) vectors

let _ =
  main ()
