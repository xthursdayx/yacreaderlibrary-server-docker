FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic

LABEL maintainer="xthursdayx"

ARG YACR_VERSION="9.8.1"
ENV APPNAME="YACReaderLibraryServer"
ENV HOME="/config"

# install built & runtime packages
RUN \
 apt-get update && \
 DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    qt5-default \
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
    p7zip-full \
    p7zip-rar \
    qt5-image-formats-plugins \
    qtdeclarative5-dev \
    qtmultimedia5-dev \
    sqlite3 \
    unzip \
    wget \
    build-essential \
    binutils

# fetch source
RUN \
 git clone -b master --single-branch https://github.com/YACReader/yacreader.git /src/git && \
 cd /src/git && \
 git checkout $YACR_VERSION

# install p7zip libraries
RUN \
 cd /src/git/compressed_archive && \
 wget "https://sourceforge.net/projects/p7zip/files/p7zip/16.02/p7zip_16.02_src_all.tar.bz2" && \
 tar xjf /src/git/compressed_archive/p7zip_16.02_src_all.tar.bz2 -C /src/git/compressed_archive && \
 mv /src/git/compressed_archive/p7zip_16.02 /src/git/compressed_archive/libp7zip
 
# build yacreaderlibraryserver
RUN \
 cd /src/git/YACReaderLibraryServer && \
 qmake PREFIX=/app "CONFIG+=7zip server_standalone" YACReaderLibraryServer.pro && \
 make  && \
 make install

# cleanup
RUN \
 cd / && \
 apt-get clean && \
 apt-get autoremove && \
 apt-get purge -y git wget build-essential binutils && \
 apt-get -y autoremove && \
 rm -rf \
    /src \
    /var/cache/apt \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# set ENV
ENV LC_ALL="en_US.UTF-8" \
    PATH="/YACReaderLibraryServer/bin/:${PATH}"

COPY root/ /

EXPOSE 8080

VOLUME /config /comics
