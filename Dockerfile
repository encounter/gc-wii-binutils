# Build stage
ARG ALPINE_VERSION=3.19.1
FROM alpine:${ALPINE_VERSION} AS build

# Install dependencies
RUN apk add --no-cache binutils file gcc make musl-dev

# Install zig
ARG ZIG_VERSION=0.11.0
RUN mkdir /zig && \
    wget -qO- "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-`uname -m`-${ZIG_VERSION}.tar.xz" | \
    tar -xJ -C /zig --strip-components=1
ENV PATH="/zig:$PATH"

# Download binutils
ARG BINUTILS_VERSION=2.42
RUN wget -q https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz

# Build host binutils
ARG GNU_TRIPLE
RUN mkdir /binutils-host && \
    tar -xf /binutils-${BINUTILS_VERSION}.tar.xz -C /binutils-host --strip-components=1 && \
    cd /binutils-host && \
    ./configure --target=${GNU_TRIPLE} --prefix=/usr/local \
    --disable-nls --disable-shared --disable-gprofng --disable-ld --disable-gold && \
    make -j$(nproc) && \
    make install-strip

# Build target binutils
ARG ZIG_TRIPLE
RUN mkdir /binutils && \
    tar -xf /binutils-${BINUTILS_VERSION}.tar.xz -C /binutils --strip-components=1 && \
    cd /binutils && \
    CC="zig cc -target ${ZIG_TRIPLE}" \
    ./configure --host=${GNU_TRIPLE} --target=powerpc-eabi --prefix=/target \
    --disable-nls --disable-shared --disable-gprof --without-zstd && \
    make -j$(nproc) && \
    make install-strip

# Export binary (usage: docker build --target export --output build .)
FROM scratch AS export
COPY --from=build /target .
