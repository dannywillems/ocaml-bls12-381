module Stubs = struct
  external anemoi_jive128_1_compress : Fr.t -> Fr.t -> Fr.t -> unit
    = "caml_anemoi_jive128_1_compress_stubs"
end

let jive128_1_compress x y =
  let res = Fr.(copy zero) in
  Stubs.anemoi_jive128_1_compress res x y ;
  res
