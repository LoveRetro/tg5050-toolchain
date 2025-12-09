FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base build tools and dependencies
RUN apt-get update && apt-get install -y \
    make \
    build-essential \
    cmake \
    ninja-build \
    autotools-dev \
    autoconf \
    automake \
    autopoint \
    libtool \
    po4a \
    m4 \
    pkg-config \
    unzip \
    wget \
    git \
    python3 \
    ca-certificates \
    gettext \
    vim \
	libsdl-ttf2.0-dev \
	libsdl2-dev \
	libsdl2-image-dev \
	libsdl2-ttf-dev \
    libsamplerate0-dev \
    #libzip-dev \
# 5.2 or newer for lzma/xz in libzip
    liblzma-dev \ 
# zstd support for libzip
    libzstd-dev \
# bz2 support for libzip
    libbz2-dev \
# zlib for libzip
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/workspace
WORKDIR /root

# stuff
COPY support .

#RUN ./setup-toolchain.sh

# build newer libzip from source
#RUN mkdir -p /root/builds
#RUN ./build-libzip.sh > /root/builds/libzip.log

# build autotools (for bluez)
#RUN ./build-autotools.sh > /root/builds/autotools.log
#RUN ./build-bluez.sh > /root/builds/bluez.log

RUN cat setup-env.sh >> .bashrc

VOLUME /root/workspace
WORKDIR /root/workspace

CMD ["/bin/bash"]