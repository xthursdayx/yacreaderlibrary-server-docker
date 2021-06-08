FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic

LABEL maintainer="xthursdayx"

ARG YACR_TAG="9.8.1"
ENV APPNAME="YACReaderLibraryServer"
ENV HOME="/config"

# install built & runtime packages
ARG DEBIAN_FRONTEND=noninteractive
RUN \
 apt-get update && \
 apt-get install -y \
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
 mkdir -p /yacr/build && \
 cd /yacr/build && \
 git clone -b master --single-branch https://github.com/YACReader/yacreader.git . && \
 git checkout $YACR_TAG

 # install unarr libraries
RUN \
 cd /yacr/build/compressed_archive/unarr/ && \
 wget https://github.com/selmf/unarr/archive/master.zip && \
 unzip master.zip && \
 rm master.zip && \
 cd unarr-master/lzmasdk && \
 ln -s 7zTypes.h Types.h

 # build yacreaderlibraryserver
RUN \
 cd /yacr/build/YACReaderLibraryServer && \
 mkdir -p /YACReaderLibraryServer && \
 qmake PREFIX=/YACReaderLibraryServer "CONFIG+=server_standalone" YACReaderLibraryServer.pro && \
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
    /yacr \
    /var/lib/apt/lists/* \
    /var/tmp/*

ENV LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF8" \
    LANG="en_US.UTF-8" \
    PATH="/YACReaderLibraryServer/bin/:${PATH}"

RUN echo "export PATH=$PATH" > /etc/environment

COPY root/ /

EXPOSE 8080

VOLUME /config /comics
