FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic

LABEL maintainer="xthursdayx"

ARG YACR_VERSION="9.8.1"
ENV APPNAME="YACReaderLibraryServer"
ENV HOME="/config"

WORKDIR /src/git

# install built & runtime packages
RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
       cmake \
       git \
       qt5-default \
       libpoppler-qt5-dev \
       libqt5core5a \
       libqt5gui5 \
       libqt5multimedia5 \
       libqt5opengl5 \
       libqt5network5 \
       libqt5qml5 \
       libqt5quickcontrols2-5 \
       libqt5script5 \
       libqt5sql5-sqlite \
       libqt5sql5 \
       libqt5svg5 \
       libwebp6 \
       zlib1g-dev \
       libbz2-dev \
       liblzma-dev \
       qt5-image-formats-plugins \
       qtdeclarative5-dev \
       qtmultimedia5-dev \
       sqlite3 \
       build-essential \
       binutils

# fetch yacreader source
RUN \
    git clone -b master --single-branch https://github.com/YACReader/yacreader.git . && \
    git checkout $YACR_VERSION

# install unarr libraries
RUN \
    cd /tmp && \
    git clone -b master --single-branch https://github.com/selmf/unarr.git ./unarr && \
    cd unarr && \
    mkdir -p build && \
    cd build && \
    cmake -DENABLE_7Z=ON .. && \
    make && \
    make install

# build yacreaderlibraryserver
RUN \
    cd /src/git/YACReaderLibraryServer && \
    qmake PREFIX=/app "CONFIG+=unarr server_standalone" YACReaderLibraryServer.pro && \
    make  && \
    make install

# cleanup
RUN \
    cd / && \
    apt-get clean && \
    apt-get autoremove && \
    apt-get purge -y cmake git wget build-essential binutils && \
    apt-get -y autoremove && \
    rm -rf \
       /src \
       /var/cache/apt \
       /var/lib/apt/lists/*

# set ENV
ENV LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    PATH="/app/bin/:${PATH}"

COPY root/ /

EXPOSE 8080

VOLUME /config /comics
