let get_time () = Sys.time ()

let get_nth_root_of_unity i =
  let g_2_32 =
    Bls12_381.Fr.of_string
      "21584124886548760190346392867028830688912556631271990304491841940743921295609"
  in

  let g_2_16 =
    Bls12_381.Fr.of_string
      "45578933624873246016802258050230213493140367389966312656957679049059636081617"
  in

  let g_2_8 =
    Bls12_381.Fr.of_string
      "27611812781829920551290133267575249478648871281233506899293410857719571783635"
  in

  let g_2_4 =
    Bls12_381.Fr.of_string
      "16624801632831727463500847948913128838752380757508923660793891075002624508302"
  in
  let g_2_2 = Bls12_381.Fr.pow g_2_4 (Z.of_int 4) in
  let ( - ) = Int.sub in
  if i > 32 || i < 1 then failwith "Supported values are between 2 and 32"
  else if i > 16 then Bls12_381.Fr.pow g_2_32 (Z.of_int (1 lsl (32 - i)))
  else if i > 8 then Bls12_381.Fr.pow g_2_16 (Z.of_int (1 lsl (16 - i)))
  else if i > 4 then Bls12_381.Fr.pow g_2_8 (Z.of_int (1 lsl (8 - i)))
  else if i > 2 then Bls12_381.Fr.pow g_2_4 (Z.of_int (1 lsl (4 - i)))
  else g_2_2

let logn = 13

let n = 1 lsl logn

let () =
  let points = Array.init n (fun _ -> Bls12_381.G2.random ()) in
  let root = get_nth_root_of_unity logn in
  let domain = Array.init n (fun i -> Bls12_381.Fr.pow root (Z.of_int i)) in
  let start_time = get_time () in
  ignore @@ Bls12_381.G2.fft ~domain ~points ;
  let end_time = get_time () in
  Printf.printf
    "Benchmark for FFT inplace on %d points: %.2fs"
    n
    (end_time -. start_time)
