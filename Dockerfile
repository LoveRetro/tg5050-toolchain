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
#	libsdl2-dev \
#	libsdl2-image-dev \
#	libsdl2-ttf-dev \
    libsamplerate0-dev \
    libzip-dev \
    libsqlite3-dev \
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

# HACK TIME
# Extract aarch64 libs from the tsps buildroot
ENV SDK_TAR=sdk_tg5050_linux_v1.0.0.tgz
ENV SDK_URL=https://github.com/LoveRetro/tg5050-toolchain/releases/download/20251208/${SDK_TAR}

RUN mkdir -p /sdk
RUN wget -q ${SDK_URL} -O /tmp/${SDK_TAR} && \
tar -xzf /tmp/${SDK_TAR} -C /sdk --strip-components=2
#RUN rm /tmp/${SDK_TAR}
# manually copy the bits into place to not mess up our environment completely
# sdl2
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/SDL2/. /usr/include/SDL2/
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libSDL* /usr/lib/aarch64-linux-gnu/
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/sdl2.pc /usr/lib/aarch64-linux-gnu/pkgconfig/
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/SDL2*.pc /usr/lib/aarch64-linux-gnu/pkgconfig/
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/bin/sdl* /usr/bin/
# glesv2
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/GLES2 /usr/include/
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libGLES* /usr/lib/aarch64-linux-gnu/
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libmali* /usr/lib/aarch64-linux-gnu/
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libdrm* /usr/lib/aarch64-linux-gnu/
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libharfbuzz* /usr/lib/aarch64-linux-gnu/
RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/glesv2.pc /usr/lib/aarch64-linux-gnu/pkgconfig/
#RUN rm -rf /sdk
# END OF HACK TIME

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