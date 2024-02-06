FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# package versions
ARG YACR_VERSION="9.14.1"

# env variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV APPNAME="YACReaderLibraryServer"
ENV HOME="/config"
LABEL maintainer="xthursdayx"

# install build & runtime packages
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
       build-essential \
       cmake \
       desktop-file-utils \
       gcc \
       g++ \
       git \
       qtchooser \
       qt6-tools-dev \
       qt6-base-dev-tools \
       qmake6 \
       qmake6-bin \
       qt6-base-dev \
       qt6-multimedia-dev \
       qt6-tools-dev-tools \
       libgl-dev \
       qt6-l10n-tools \
       libqt6opengl6-dev \
       libunarr-dev \
       qt6-declarative-dev \
       libqt6svg6-dev \
       libqt6core5compat6-dev \
### added
       libbz2-dev \
       libglu1-mesa-dev \
       liblzma-dev \
       libqt6gui6 \
       libqt6multimedia6 \
       libqt6network6 \
       libqt6qml6 \
       libqt6quickcontrols2-6 \
       qt6-image-formats-plugins \
       libqt6sql6 \
       libqt6sql6-sqlite \
       make \
       p7zip-full \
       sqlite3 \
       libsqlite3-dev \
       unzip \
       wget \
       zlib1g-dev && \
# install unarr libraries
    git clone -b master --single-branch https://github.com/selmf/unarr.git /tmp/unarr && \
    cd /tmp/unarr && \
    mkdir -p build && \
    cd build && \
    cmake -DENABLE_7Z=ON .. && \
    make && \
    make install && \
# build yacreaderlibraryserver
    git clone -b master --single-branch https://github.com/YACReader/yacreader.git /src/git && \
    cd /src/git && \
    git checkout $YACR_VERSION && \
    cd /src/git/YACReaderLibraryServer && \
    qtchooser -list-versions && \
    qmake6 PREFIX=/app CONFIG+="unarr no_pdf server_standalone" YACReaderLibraryServer.pro && \
    qmake6 -v && \
    make  && \
    make install && \
# fix QT6 bug https://askubuntu.com/questions/1034313/ubuntu-18-4-libqt5core-so-5-cannot-open-shared-object-file-no-such-file-or-dir
#    strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt6Core5Compat.so.6 && \
# clean up
    cd / && \
    apt-get clean && \
    apt-get purge -y build-essential cmake g++ git make qmake6 unzip wget && \
    apt-get -y autoremove && \
    apt-get install -y --no-install-recommends \
       libqt6core5compat6-dev && \
    rm -rf \
       /src \
       /tmp/* \
       /var/cache/apt \
       /var/lib/apt/lists/*

# set ENV
ENV LC_ALL="en_US.UTF-8" \
    PATH="/app/bin:${PATH}"

# copy files
COPY root/ /

# ports and volumes
EXPOSE 8080
VOLUME ["/config", "/comics"]
