let order =
  let fq_order =
    Z.of_string
      "4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787"
  in
  Z.pow fq_order 12

let pow_zero_on_one_equals_one () =
  assert (
    Bls12_381.Fq12.eq
      (Bls12_381.Fq12.pow Bls12_381.Fq12.one Z.zero)
      Bls12_381.Fq12.one)

let pow_one_on_random_element_equals_the_random_element () =
  let e = Bls12_381.Fq12.random () in
  assert (Bls12_381.Fq12.eq (Bls12_381.Fq12.pow e Z.one) e)

let pow_two_on_random_element_equals_the_square () =
  let e = Bls12_381.Fq12.random () in
  assert (
    Bls12_381.Fq12.eq
      (Bls12_381.Fq12.pow e (Z.succ Z.one))
      (Bls12_381.Fq12.mul e e))

(** x**(-n) = x**(g - 1 - n) where g is the order of the additive group *)
let pow_to_negative_exponent () =
  let x = Bls12_381.Fq12.random () in
  let n = Z.of_int (Random.int 1_000_000_000) in
  assert (
    Bls12_381.Fq12.eq
      (Bls12_381.Fq12.pow x (Z.neg n))
      (Bls12_381.Fq12.pow x (Z.sub (Z.pred order) n)))

let pow_addition_property () =
  let g = Bls12_381.Fq12.random () in
  let x = Z.of_int (Random.int 1_000_000_000) in
  let y = Z.of_int (Random.int 1_000_000_000) in
  assert (
    Bls12_381.Fq12.eq
      (Bls12_381.Fq12.pow g (Z.add x y))
      (Bls12_381.Fq12.mul (Bls12_381.Fq12.pow g x) (Bls12_381.Fq12.pow g y)))

(** x**g = x where g = |(F, +, 0)| *)
let pow_to_the_additive_group_order_equals_same_element () =
  let x = Bls12_381.Fq12.random () in
  assert (Bls12_381.Fq12.eq (Bls12_381.Fq12.pow x order) x)

(** x**g = 1 where g = |(F, *, 1)| *)
let rec pow_to_the_multiplicative_group_order_equals_one () =
  let x = Bls12_381.Fq12.random () in
  if Bls12_381.Fq12.is_zero x then
    pow_to_the_multiplicative_group_order_equals_one ()
  else
    assert (
      Bls12_381.Fq12.eq (Bls12_381.Fq12.pow x (Z.pred order)) Bls12_381.Fq12.one)

(** x**(n + g) = x**n where g = |(F, *, 1)| *)
let pow_add_multiplicative_group_order_to_a_random_power () =
  let x = Bls12_381.Fq12.random () in
  let n = Z.of_int (Random.int 1_000_000_000) in
  let order = Z.pred order in
  assert (
    Bls12_381.Fq12.eq
      (Bls12_381.Fq12.pow x (Z.add n order))
      (Bls12_381.Fq12.pow x n))

let () =
  let open Alcotest in
  run
    "Fq12"
    [ ( "Properties",
        [ test_case
            "pow one on random element equals the same element"
            `Quick
            (Test_ec_make.repeat
               100
               pow_one_on_random_element_equals_the_random_element);
          test_case
            "pow two on random element equals the square"
            `Quick
            (Test_ec_make.repeat
               100
               pow_one_on_random_element_equals_the_random_element);
          test_case
            "pow element to the additive group order"
            `Quick
            (Test_ec_make.repeat
               100
               pow_to_the_additive_group_order_equals_same_element);
          test_case
            "pow element to the multiplicative group order"
            `Quick
            (Test_ec_make.repeat
               100
               pow_to_the_multiplicative_group_order_equals_one);
          test_case
            "pow element to a random power plus the additive group order"
            `Quick
            (Test_ec_make.repeat
               100
               pow_add_multiplicative_group_order_to_a_random_power);
          test_case
            "pow to negative exponent"
            `Quick
            (Test_ec_make.repeat 100 pow_to_negative_exponent) ] ) ]
