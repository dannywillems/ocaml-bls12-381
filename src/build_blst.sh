#!/bin/sh -e

# Modifying `libblst/build.sh` is avoided because we want to keep the fork
# clean.

# If you update the build.sh flags, you must also update
# .github/workflows/build-blst-on-macos accordingly

# Adding -Wno-missing-braces for clang-11 (and also should be for clang-10, but clang 10
# is not officially supported). See .github/workflows/build-blst-on-macos for the reason

# Use BLST_PORTABLE environment variable to overwrite the check in
# libblst/build.sh to use ADX instructions. build.sh uses /proc/cpuinfo to
# decide to use ADX or not. Useful if you build binaries for archs not
# supporting ADX on a arch supporting ADX.
cd libblst
if [ $(uname --machine) = "s390x" ]; then
    echo "(-DCAML_INTERNALS)" > ../c_flags_blst.sexp
    ./build.sh -shared -Wno-missing-braces -D__BLST_NO_ASM__
elif [ -n "${BLST_PORTABLE}" ]; then
    echo "(-D__BLST_PORTABLE__ -DCAML_INTERNALS)" > ../c_flags_blst.sexp
    ./build.sh -shared -Wno-missing-braces -D__BLST_PORTABLE__
else
    echo "(-DCAML_INTERNALS)" > ../c_flags_blst.sexp
    ./build.sh -shared -Wno-missing-braces
fi
