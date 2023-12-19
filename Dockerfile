# Build stage
FROM alpine:3.19.0 AS build

# Install dependencies
RUN apk add --no-cache gcc musl-dev make

# Download and extract source
RUN wget -qO- https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz | tar -xJ

# Build binutils
WORKDIR /binutils-2.41
RUN ./configure --target=powerpc-unknown-eabi --prefix=/target --disable-nls --disable-shared \
    && make -j$(nproc) configure-host \
    && make -j$(nproc) LDFLAGS=-all-static \
    && make install-strip

# Export binary (usage: docker build --target export --output build .)
FROM scratch AS export
COPY --from=build /target/bin/* .
