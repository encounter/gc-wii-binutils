#!/bin/bash -ex
PREFIX="$(pwd)/build"
wget -qO- https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz | tar -xJ
cd binutils-2.41
./configure --target=powerpc-eabi --prefix="$PREFIX" --disable-nls --disable-shared
make -j$(nproc) configure-host
make -j$(nproc)
make install-strip
