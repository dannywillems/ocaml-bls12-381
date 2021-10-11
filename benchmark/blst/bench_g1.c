void generate_random_g1(blst_fr *output) {
  blst_p1 *output_p1 = (blst_p1 *)malloc(sizeof(blst_p1));
  blst_fp *x_fp = (blst_fp *)malloc(sizeof(blst_fp));
  blst_fp *y_fp = (blst_fp *)malloc(sizeof(blst_fp));
  byte output_bytes[32] = {0};
  for (int i = 0; i < 32; i++) {
    output_bytes[i] = rand() % 256;
  }
  blst_scalar_from_lendian(output_scalar, output_bytes);
  blst_fr_from_scalar(output, output_scalar);
  free(output_scalar);
}
