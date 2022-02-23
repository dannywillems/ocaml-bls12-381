# OCaml implementation of BLS12-381

This library provides a fast implementation of:
- operations over the scalar field, including (i)FFT.
- operations over the groups G1 and G2, including EC-FFT, hash_to_curve as
  described [in this
  specification](https://datatracker.ietf.org/doc/draft-irtf-cfrg-hash-to-curve/)
  and the pippenger algorithm for fast multi scalar exponentiation.
- operations over the target group of the pairing (GT), written additively.
- pairing from G1 x G2 to GT
- BLS signatures described in [this
  specification](https://tools.ietf.org/pdf/draft-irtf-cfrg-bls-signature-04.pdf).
  Both instantiations, i.e. the one minimizing the public key size and the one
  minimizing the signature size, are provided.
- an instantiation of
  [Poseidon](https://eprint.iacr.org/2019/458.pdf) providing a security of
  128 bits. See [the
  documentation](https://dannywillems.gitlab.io/ocaml-bls12-381/bls12-381/Bls12_381/Poseidon128/index.html)
  for more information on the used parameters.
- an instantiation of
  [Rescue](https://eprint.iacr.org/2019/426.pdf) providing a security of
  128 bits. See [the
  documentation](https://dannywillems.gitlab.io/ocaml-bls12-381/bls12-381/Bls12_381/Rescue/index.html)
  for more information on the used parameters.

## Encoding

### Scalar

The scalar field is `Fr = GF(0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001)`, encoded on 32 bytes in little endian.

### Groups

For G1, the base field is `Fq:
GF(0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab`)
and `E(Fq) := y^2 = x^3 + 4`. An element of the base field can be encoded on 48 bytes (using only
381 bits, leaving 3 bits unused).

For G2, the base field is `Fq2 := Fq[Z]/(X^2 + 1)` and `E(Fq2) := y^2 = x^3 + 4
(Z + 1)`. An element of the base field can be encoded on 2 * 48 bytes
representing each coefficient of the polynomial. 3 bits of each coefficient
encoding are unused.

The « uncompressed » form `(x, y)` of G1 and G2 is the concatenation of the elements `x` and `y` encoded in big endian.

The « compressed » form uses the first 3 most significant (and unused) bits of
the coordinate `x`.
- the first most significant bit is always set to `1` to carry the information it
is the compressed encoding of a point.
- the second most significant bit is set to `1` if the element is the identity of the curve.
- the third most significant bit is the sign of `y`. It is set to `1` if `y` is
  lexicographically larger than `-y`.

## Install


```shell
opam install bls12-381
```

By default, if the architecture supports ADX, `bls12-381` with be compiled using ADX
opcodes (giving optimisations up to 20% for some arithmetic operations). If you
don't want to build using ADX, you can add the environment variable
`BLST_PORTABLE` and set it to any value.
For instance,
```
BLST_PORTABLE=y opam install bls12-381
```
will instruct to build bls12-381 without ADX. This might be useful if you
build docker images on ADX machines but you need the image to be portable on
architecture not supporting ADX.

If the architecture does not support ADX, `bls12-381` will be compiled without ADX opcodes.

## Run tests

```
dune runtest
```

To get the coverage:
```
dune runtest --instrument-with bisect_ppx --force
bisect-ppx-report html
```

## Run the benchmarks

Install `core_bench`:

```
opam install core_bench
```

See files listed in the directory `benchmark` and execute it with `dune exec`. For instance:
```
dune exec ./benchmark/bench_fr.exe
```

## Documentation

```
opam install odoc
dune build @doc
```
