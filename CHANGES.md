### Unreleased

#### New features

- Blst: modify pippenger to work with contiguous arrays of byte sequences and
  affine points
- `Bls12_381.G1.pippenger_with_affine_array` and
  `Bls12_381.G2.pippenger_with_affine_array` works with the contiguous version
  from blst.

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
