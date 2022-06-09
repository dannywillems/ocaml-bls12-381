### Unreleased

#### API changes

- Fr: change API of inplace operators

#### New features

- Blst: modify pippenger to work with contiguous arrays of byte sequences and
  affine points (3c8ae8a3c2e8735101c71dbbdcaa3c853e30b891).
- `Bls12_381.G1.pippenger_with_affine_array` and
  `Bls12_381.G2.pippenger_with_affine_array` works with the contiguous version
  from blst (a37c1b2ba95a807544b739ade0edf334f4de2c7d).
- Move some auxiliaries C functions into blst (`blst_fr_is_equal`,
  `blst_fr_is_zero`, `blst_fr_is_one`, `blst_fp12_is_zero`,
  `blst_fp12_set_to_one`, `blst_fp2_set_to_one`, `blst_fr_set_to_zero`,
  `blst_fr_set_to_one`) and use fastest routines provided by blst internals
  (f914a4a20f53274182767b23ce8e67de59dfef2e).
- Poseidon: implement a generic version of Poseidon, including optimisations
  from https://eprint.iacr.org/2022/462
  (dd070dde05204a04f2ad0c4ac3e4576d93deaa3e,
  fa4b9418e1a2052ffca22287fd036f73e33b99a5,
  e9c33636b6bbc0e1f94d84b1841cc25fcfcce3f4,
  a577ea393431abd7c0b8d840574b6e145934d6cd,
  1bdf228111fa7e81e445e4450939ca20ade40949,
  48cbc33a7dca01f6e6493c8a7edb1edfc74dcb77)
- Publish NPM package automatically in the CI when a tag is created
  (1fc351fada8e1cca5beb022cad0a694b2d0d1c5f,
  128d090c5ba72b48061831812330c22823fc646a,
  2dd4863705b0608831892b61e109521c9d80b46f)
- Upgrade blst to 0.3.7
- Fr: use `blst_fr_cneg` instead of `blst_fr_sub`  for `Fr.neg`
- Fr: use `blst_fr_sqr` instead of `blst_fr_mul`  for `Fr.square_inplace`

#### Performance improvements

- Remove some extra allocations performed on the heap when not required
  (e3fac8159bb39af8d877ad8e23f7db74e19ee2cb)
- `blst_fp12_pow`: moving checks if the exponent is one or zero in the C code
  (ce2a3429d86506d8d17c5be27334bbd82e8f9e9a)

#### Bugfix

- `Fp12.one` was set to a generator of the prime subgroup.
- Signature: copy dst before calling blst_pairing_init. Bug
  https://gitlab.com/dannywillems/ocaml-bls12-381/-/issues/63 reintroduced in
  https://gitlab.com/dannywillems/ocaml-bls12-381/-/commit/bb1d1c5123ec66f5e2ac34b4c91e2baadf9b05c4
  and wrong custom block structured used (blst_fp12_ops instead of
  blst_pairing_ops) introduced in
  https://gitlab.com/dannywillems/ocaml-bls12-381/-/commit/aa6c9566386c03bde0028fe64fb8c599a41f403f
  which causes memleaks because a pointer is not free correctly.

### 3.0.2

- OPAM: remove JS stubs while running tests are not required
  (68584de662650923864c16ab2699af3b62ff07bf)

### 3.0.1

#### Bugfix

- Fix `Bls12_381.built_with_blst_portable`. Detect using `Sys.getenv_opt` was not
  a working solution. Projects relying on the value must update the library.
- Fix `GT.check_bytes`, see https://github.com/supranational/blst/issues/108 and
  https://github.com/dannywillems/ocaml-bls12-381/pull/4

#### MISC

- Replace `GT.one` with the hexadecimal representation of the generator, instead
  of computing using `Pairing.pairing`

### 0.4.0

#### Changes

+ Split packages in bls12-381-gen, bls12-381, bls12-381-unix, bls12-381-js,
  bls12-381-js-gen. bls12-381 is a virtual package and
  bls12-381-unix/bls12-381-js are the actual implementation for respectively the
  UNIX and JavaScript versions. bls12-381-gen and bls12-381-js-gen are helpers.
- Remove version field in opam files.
- Update to ff-sig.0.6.1, ff.0.6.1 and ff-pbt.0.6.1
