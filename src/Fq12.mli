include Ff_sig.T

(** Construct an element of Fq12 based on the following pattern:
    Fq12 =
     Fq6 (
       Fq2(x: x0, y: x1))
       Fq2(x: x2, y: x3))
       Fq2(x: x4, y: x5)),
     Fq6 (
       Fq2(x: x6, y: x7))
       Fq2(x: x8, y: x9))
       Fq2(x: x10, y: x11))
    x0, ..., x11 are the parameters of the function.
    No check is applied.

    Example of usage (pairing result of the multiplicative neutre elements):
    Fq12.of_string
      "2819105605953691245277803056322684086884703000473961065716485506033588504203831029066448642358042597501014294104502"
      "1323968232986996742571315206151405965104242542339680722164220900812303524334628370163366153839984196298685227734799"
      "2987335049721312504428602988447616328830341722376962214011674875969052835043875658579425548512925634040144704192135"
      "3879723582452552452538684314479081967502111497413076598816163759028842927668327542875108457755966417881797966271311"
      "261508182517997003171385743374653339186059518494239543139839025878870012614975302676296704930880982238308326681253"
      "231488992246460459663813598342448669854473942105054381511346786719005883340876032043606739070883099647773793170614"
      "3993582095516422658773669068931361134188738159766715576187490305611759126554796569868053818105850661142222948198557"
      "1074773511698422344502264006159859710502164045911412750831641680783012525555872467108249271286757399121183508900634"
      "2727588299083545686739024317998512740561167011046940249988557419323068809019137624943703910267790601287073339193943"
      "493643299814437640914745677854369670041080344349607504656543355799077485536288866009245028091988146107059514546594"
      "734401332196641441839439105942623141234148957972407782257355060229193854324927417865401895596108124443575283868655"
      "2348330098288556420918672502923664952620152483128593484301759394583320358354186482723629999370241674973832318248497"
    (* source for the test vectors: https://docs.rs/crate/pairing/0.16.0/source/src/bls12_381/tests/mod.rs *)

    Undefined behaviours if the given elements are not in the field or any other
    representation than decimal is used. Use this function carefully.

    See https://docs.rs/crate/pairing/0.16.0/source/src/bls12_381/README.md for
    more information on the instances used by the library.
*)
val of_string :
  String.t ->
  String.t ->
  String.t ->
  String.t ->
  String.t ->
  String.t ->
  String.t ->
  String.t ->
  String.t ->
  String.t ->
  String.t ->
  String.t ->
  t

(** Same than [of_string], using Z.t elements *)
val of_z :
  Z.t ->
  Z.t ->
  Z.t ->
  Z.t ->
  Z.t ->
  Z.t ->
  Z.t ->
  Z.t ->
  Z.t ->
  Z.t ->
  Z.t ->
  Z.t ->
  t
