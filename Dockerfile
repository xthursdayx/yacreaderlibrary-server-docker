# syntax=docker/dockerfile:1

# Single Dockerfile for every variant. Pick the archive backend at build time:
#   docker build --build-arg DECOMPRESSION_BACKEND=7zip .        (default)
#   docker build --build-arg DECOMPRESSION_BACKEND=libarchive .
# (unarr isn't offered: Ubuntu 26.04 no longer packages libunarr, and upstream
#  recommends libarchive over it anyway.)
ARG DECOMPRESSION_BACKEND="7zip"

# YACReader release tag (bumped automatically by the depup workflow)
ARG YACR_VERSION="10.4.0"

# YACReader 10.x needs CMake >= 3.25 and Qt >= 6.4 (server-only build), so Jammy
# no longer works. Resolute (26.04 LTS) is what upstream's own image uses.
FROM ghcr.io/linuxserver/baseimage-ubuntu:resolute AS base

# ---------------------------------------------------------------------------
# Build toolchain (shared by every variant)
# ---------------------------------------------------------------------------
FROM base AS build-env
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND="noninteractive"
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
       7zip \
       build-essential \
       ca-certificates \
       cmake \
       curl \
       git \
       libarchive-dev \
       libgl-dev \
       libpoppler-qt6-dev \
       ninja-build \
       qt6-5compat-dev \
       qt6-base-dev \
       qt6-base-dev-tools \
       qt6-l10n-tools \
       qt6-tools-dev \
       qt6-tools-dev-tools && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# YACReader source
# ---------------------------------------------------------------------------
FROM build-env AS source
ARG YACR_REPOSITORY="https://github.com/YACReader/yacreader.git"
ARG YACR_VERSION
RUN git clone --depth 1 --branch "${YACR_VERSION}" "${YACR_REPOSITORY}" /src

# ---------------------------------------------------------------------------
# Per-backend preparation. Only the stage matching DECOMPRESSION_BACKEND is built.
# ---------------------------------------------------------------------------
FROM source AS prep-7zip
# Same archive YACReader's CMake would FetchContent, but checksum-verified here.
# Dropping it into compressed_archive/lib7zip makes CMake skip its own download.
ARG SEVENZIP_SRC_URL="https://github.com/YACReader/yacreader-7z-deps/raw/main/7z2301-src.7z"
ARG SEVENZIP_SRC_SHA256="fc459c2314a032231c157fd3257906c070ceed11efd6ffa621c2dfebbbc31281"
RUN \
    curl -fsSL "${SEVENZIP_SRC_URL}" -o /tmp/7z-src.7z && \
    echo "${SEVENZIP_SRC_SHA256}  /tmp/7z-src.7z" | sha256sum -c - && \
    7z x -bd -y -o/src/compressed_archive/lib7zip /tmp/7z-src.7z > /dev/null && \
    rm /tmp/7z-src.7z && \
# The 7zip backend dlopen()s 7z.so at runtime from ${LIBDIR}/7zip/7z.so, and
# LIBDIR is /app/lib with the /app prefix. Build it for the target arch
# (Format7zF = all formats, including RAR/RAR5).
    make -C /src/compressed_archive/lib7zip/CPP/7zip/Bundles/Format7zF \
         -f makefile.gcc -j"$(nproc)" && \
    install -Dm755 \
       /src/compressed_archive/lib7zip/CPP/7zip/Bundles/Format7zF/_o/7z.so \
       /app/lib/7zip/7z.so

FROM source AS prep-libarchive

# ---------------------------------------------------------------------------
# Build YACReaderLibraryServer
# ---------------------------------------------------------------------------
FROM prep-${DECOMPRESSION_BACKEND} AS builder
ARG DECOMPRESSION_BACKEND
ARG PDF_BACKEND="poppler"
RUN \
    cmake -S /src -B /src/build -G Ninja \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_PREFIX=/app \
       -DBUILD_SERVER_STANDALONE=ON \
       -DBUILD_TESTS=OFF \
       -DDECOMPRESSION_BACKEND="${DECOMPRESSION_BACKEND}" \
       -DPDF_BACKEND="${PDF_BACKEND}" && \
    cmake --build /src/build --parallel && \
    cmake --install /src/build && \
    rm -rf /app/lib/systemd && \
# Work out exactly which distro packages the binaries need at runtime, so the
# runtime stage never drifts from what we actually linked against.
    find /app -type f \( -name YACReaderLibraryServer -o -name '*.so' \) -exec ldd {} + > /tmp/ldd.txt && \
    if grep -q "not found" /tmp/ldd.txt; then grep "not found" /tmp/ldd.txt; exit 1; fi && \
    awk '/=> \// {print $3}' /tmp/ldd.txt | sort -u | xargs -r realpath \
       | xargs -r dpkg -S | cut -d: -f1 | sort -u > /runtime-packages.txt && \
    echo "Runtime packages:" && cat /runtime-packages.txt

# ---------------------------------------------------------------------------
# Runtime image
# ---------------------------------------------------------------------------
FROM base AS runtime
ARG DEBIAN_FRONTEND="noninteractive"
ARG DECOMPRESSION_BACKEND
ARG YACR_VERSION

LABEL maintainer="xthursdayx" \
      org.opencontainers.image.title="YACReaderLibraryServer" \
      org.opencontainers.image.version="${YACR_VERSION}" \
      org.opencontainers.image.source="https://github.com/xthursdayx/yacreaderlibrary-server-docker" \
      com.xthursdayx.yacreader.decompression-backend="${DECOMPRESSION_BACKEND}"

# Linked libraries (from the builder) + things ldd can't see: Qt plugins
# (SQLite driver, image formats) and netcat for the s6 readiness check.
COPY --from=builder /runtime-packages.txt /tmp/runtime-packages.txt
RUN \
    apt-get update && \
    xargs -a /tmp/runtime-packages.txt apt-get install -y --no-install-recommends \
       kimageformat6-plugins \
       libqt6sql6-sqlite \
       netcat-openbsd \
       qt6-image-formats-plugins && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /app /app
COPY root/ /

ENV APPNAME="YACReaderLibraryServer" \
    HOME="/config" \
    LC_ALL="en_US.UTF-8" \
    PATH="/app/bin:${PATH}"

EXPOSE 8080
VOLUME ["/config", "/comics"]
