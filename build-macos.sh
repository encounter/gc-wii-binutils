#!/bin/bash -ex
PREFIX="$(pwd)/build"
mkdir source
wget -qO- https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz | tar -xJ -C source --strip-components=1
cd source
for patch in ../*.patch; do
  patch -N -p1 -i "$patch"
done
export CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.11"
if command -v nproc >/dev/null 2>&1; then
  JOBS="$(nproc)"
else
  JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"
fi
case "$JOBS" in
  ''|*[!0-9]*) JOBS=4 ;;
esac

./configure --target=powerpc-eabi --prefix="$PREFIX" --disable-nls --disable-shared --disable-gprof --without-zstd --with-system-zlib
make -j"$JOBS" configure-host
make -j"$JOBS"
make install-strip
