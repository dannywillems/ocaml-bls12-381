#ifndef CAML_BLS12_381_STUBS
#define CAML_BLS12_381_STUBS

#include "blst.h"

#define Blst_fr_val(v) ((blst_fr *)Data_custom_val(v))

#define Blst_scalar_val(v) ((blst_scalar *)Data_custom_val(v))

#define Blst_fp_val(v) ((blst_fp *)Data_custom_val(v))

#define Blst_fp2_val(v) ((blst_fp2 *)Data_custom_val(v))

#define Blst_fp12_val(v) ((blst_fp12 *)Data_custom_val(v))

#define Blst_p1_val(v) ((blst_p1 *)Data_custom_val(v))

#define Blst_p1_affine_val(v) ((blst_p1_affine *)Data_custom_val(v))

#define Blst_p2_val(v) ((blst_p2 *)Data_custom_val(v))

#define Blst_p2_affine_val(v) ((blst_p2_affine *)Data_custom_val(v))

#define Blst_pairing_val(v) ((blst_pairing *)Data_custom_val(v))

#define Fr_val_k(v, k) (Blst_fr_val(Field(v, k)))

#define G1_val_k(v, k) (Blst_p1_val(Field(v, k)))

#define G2_val_k(v, k) (Blst_p2_val(Field(v, k)))

#endif
