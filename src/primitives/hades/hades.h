#ifndef HADES_H
#define HADES_H

#include "blst.h"
#include <stdlib.h>
#include <string.h>

int hades_compute_number_of_constants(int batch_size, int nb_partial_rounds,
                                      int nb_full_rounds, int width);
void hades_apply_perm(blst_fr *ctxt, int width, int nb_full_rounds,
                      int nb_partial_rounds, int batch_size);

#endif
