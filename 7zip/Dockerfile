FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# package versions
ARG YACR_VERSION="9.14.2"

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
# clone yacreaderlibraryserver
    git clone -b master --single-branch https://github.com/YACReader/yacreader.git /src/git && \
    cd /src/git && \
    git checkout $YACR_VERSION && \
# install 7zip libraries
    cd /src/git/compressed_archive && \
    wget "https://github.com/xthursdayx/yacreader-7z-deps/blob/main/7z2301-amd64-src.7z?raw=true" -O /src/git/compressed_archive/7z2301-amd64-src.7z && \
    7z x /src/git/compressed_archive/7z2301-amd64-src.7z -o/src/git/compressed_archive/lib7zip && \
    apt-get remove -y \
        p7zip-full \
        p7zip && \
    #rm -rf /usr/bin/7zr && \
    #rm -rf /usr/lib/p7zip && \
    cp /src/git/compressed_archive/lib7zip/debian/7zip/usr/bin/7z.7zip /usr/bin/7z && \
    cp /src/git/compressed_archive/lib7zip/debian/7zip/usr/bin/7za.7zip /usr/bin/7za && \
    cp /src/git/compressed_archive/lib7zip/debian/7zip/usr/bin/7zr.7zip /usr/bin/7zr && \
    cp /src/git/compressed_archive/lib7zip/debian/7zip/usr/bin/7zz /usr/bin/7zz && \
    cp -r /src/git/compressed_archive/lib7zip/debian/7zip/usr/lib/7zip /usr/lib/ && \
# fix qtchooser qmake install - https://askubuntu.com/questions/1460242/ubuntu-22-04-with-qt6-qmake-could-not-find-a-qt-installation-of
    qtchooser -install qt6 $(which qmake6) && \
    export QT ELECT=qt6 && \
# build yacrederlibraryserver
    cd /src/git/YACReaderLibraryServer && \
    qtchooser -list-versions && \
    qmake6 PREFIX=/app CONFIG+="7zip no_pdf server_standalone" YACReaderLibraryServer.pro && \
    qmake6 -v && \
    make  && \
    make install && \
# clean up
    cd / && \
    apt-get clean && \
    apt-get purge -y build-essential g++ gcc git make qmake6 qtchooser unzip wget && \
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
