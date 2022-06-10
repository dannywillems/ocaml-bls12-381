## Benchmark blst library directly

### Motivation

Compare with other libraries and also check the OCaml binding overhead

### Dependencies

[Google benchmark library](https://github.com/google/benchmark)
```bash=
# Check out the library.
git clone https://github.com/google/benchmark.git
# Go to the library root directory
cd benchmark
# Make a build directory to place the build output.
cmake -E make_directory "build"
# Generate build system files with cmake, and download any dependencies.
cmake -E chdir "build" cmake -DBENCHMARK_DOWNLOAD_DEPENDENCIES=on -DCMAKE_BUILD_TYPE=Release ../
# or, starting with CMake 3.13, use a simpler form:
# cmake -DCMAKE_BUILD_TYPE=Release -S . -B "build"
# Build the library.
cmake --build "build" --config Release
# If you want to install the library globally, also run
sudo cmake --build "build" --config Release --target install
```

```bash=
g++ \
  -O3 \ # https://www.rapidtables.com/code/linux/gcc/gcc-o.html
  -o main.exe \
  benchmark/blst/bench_fr.c \
  -lblst \
  -lbenchmark \
  -lpthread \
  -L_build/default/src/ \
  -I_build/default/src/bindings/ \
  -I_build/default/src/libblst/bindings
```
