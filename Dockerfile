FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic

LABEL maintainer="xthursdayx"

# package versions
ARG YACR_VERSION="9.8.2.2106204"

# env variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV APPNAME="YACReaderLibraryServer"
ENV HOME="/config"

# install build & runtime packages
RUN \
    apt-get update && \
    apt-get install -y \
       cmake \
       git \
       qt5-default \
       libbz2-dev \
       liblzma-dev \
       libpoppler-qt5-dev \
       libpoppler-qt5-1 \
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
       qt5-image-formats-plugins \
       qt5-qmake \
       qtdeclarative5-dev \
       qtmultimedia5-dev \
       sqlite3 \
       unzip \
       wget \
       zlib1g-dev \
       build-essential \
       binutils && \
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
    cd /src/git/ && \
    git checkout $YACR_VERSION && \
    cd /src/git/YACReaderLibraryServer && \
    qmake PREFIX=/app "CONFIG+=unarr server_standalone" YACReaderLibraryServer.pro && \
    make  && \
    make install && \
    cd / && \
# clean up
    apt-get clean && \
    apt-get autoremove && \
    apt-get purge -y cmake git wget build-essential binutils && \
    apt-get -y autoremove && \
    rm -rf \
       /src \
       /tmp/* \
       /var/cache/apt \
       /var/lib/apt/lists/*

ENV LC_ALL="en_US.UTF-8" \
    PATH="/app/bin:$PATH"

# copy files
COPY root/ /

# ports and volumes
EXPOSE 8080
VOLUME /config /comics
