FROM ubuntu:24.04

# Install base build tools and dependencies
RUN apt-get update && apt-get install -y \
    make \
    #    build-essential \
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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY support /root/support

ENV TOOLCHAIN_DIR=/opt/aarch64-nextui-linux-gnu

# Download the appropriate cross toolchain based on host arch
RUN mkdir -p ${TOOLCHAIN_DIR} && \
    ARCH=$(uname -m) && \
    TOOLCHAIN_REPO=https://github.com/LoveRetro/gcc-arm-10.3-aarch64-tg5050 && \
    TOOLCHAIN_BUILD=v10.3.0-20251210-234416-816e71bd && \
    if [ "$ARCH" = "x86_64" ]; then \
        TOOLCHAIN_ARCHIVE=gcc-10.3.0-aarch64-nextui-linux-gnu-x86_64-host.tar.xz; \
    elif [ "$ARCH" = "aarch64" ]; then \
        TOOLCHAIN_ARCHIVE=gcc-10.3.0-aarch64-nextui-linux-gnu-arm64-host.tar.xz; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    TOOLCHAIN_URL=${TOOLCHAIN_REPO}/releases/download/${TOOLCHAIN_BUILD}/${TOOLCHAIN_ARCHIVE}; \
    wget -q $TOOLCHAIN_URL -O /tmp/toolchain.tar.xz
RUN tar -xf /tmp/toolchain.tar.xz -C ${TOOLCHAIN_DIR} --strip-components=2 && \
    rm /tmp/toolchain.tar.xz

ENV CROSS_TRIPLE=aarch64-nextui-linux-gnu
ENV CROSS_ROOT=${TOOLCHAIN_DIR}
ENV SYSROOT=${CROSS_ROOT}/${CROSS_TRIPLE}/libc

# Download and extract the SDK sysroot
#ENV SDK_TAR=sdk_tg5050_linux_v1.0.0.tgz
#ENV SDK_URL=https://github.com/LoveRetro/tg5050-toolchain/releases/download/20251208/${SDK_TAR}
#
#RUN mkdir -p ${SYSROOT} && \
#    wget -q ${SDK_URL} -O /tmp/${SDK_TAR} && \
#    tar -xvzf /tmp/${SDK_TAR} -C ${SYSROOT} \
#        sdk_tg5050_linux_v1.0.0/host/aarch64-buildroot-linux-gnu/sysroot/usr \
#        --strip-components=6 && \
#    rm /tmp/${SDK_TAR}

#ENV SDK_TAR=SDK_usr_tg5050_a523.zip
#ENV SDK_URL=https://github.com/LoveRetro/tg5050-toolchain/releases/download/20251208/${SDK_TAR}
#
#RUN mkdir -p ${SYSROOT}
#RUN wget -q ${SDK_URL} -O /tmp/${SDK_TAR}
#RUN unzip -q /tmp/${SDK_TAR} -d ${SYSROOT}
#RUN rm /tmp/${SDK_TAR}

#wget -q https://github.com/LoveRetro/tg5050-toolchain/releases/download/20251208/sdk_tg5050_linux_v1.0.0.tgz -O /tmp/sdk_tg5050_linux_v1.0.0.tgz
#tar -xvzf /tmp/sdk_tg5050_linux_v1.0.0.tgz -C ${SYSROOT}

# HACK TIME
# Extract aarch64 libs from the tsps buildroot
ENV SDK_TAR=sdk_tg5050_linux_v1.0.0.tgz
ENV SDK_URL=https://github.com/LoveRetro/tg5050-toolchain/releases/download/20251208/${SDK_TAR}

RUN mkdir -p /sdk && \
wget -q ${SDK_URL} -O /tmp/${SDK_TAR} && \
tar -xzf /tmp/${SDK_TAR} -C /sdk --strip-components=2 && \
rm /tmp/${SDK_TAR} && \
# manually copy the bits into place to not mess up our environment completely
# sdl2
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/SDL2/. ${SYSROOT}/usr/include/SDL2/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libSDL* ${SYSROOT}/usr/lib/ && \
mkdir -p ${SYSROOT}/usr/lib/pkgconfig/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/sdl2.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/SDL2*.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/bin/sdl* ${SYSROOT}/usr/bin/ && \
# glesv2
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/GLES2 ${SYSROOT}/usr/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libGLES* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libmali* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libdrm* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libharfbuzz* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/glesv2.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# zlib (why is it not part of the 10.3 toolchain?)
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/zlib.h ${SYSROOT}/usr/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/zconf.h ${SYSROOT}/usr/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libz* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/zlib.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# freetype
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/freetype2/. ${SYSROOT}/usr/include/freetype2/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libfreetype* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/freetype2.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# libpng
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/png.h ${SYSROOT}/usr/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libpng* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/libpng.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# libbz2
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/bzlib.h ${SYSROOT}/usr/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libbz2* ${SYSROOT}/usr/lib/ && \
#RUN cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/bzip2.pc ${SYSROOT}/usr/lib/pkgconfig/
# harfbuzz
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/harfbuzz/. ${SYSROOT}/usr/include/harfbuzz/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libharfbuzz* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/harfbuzz.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# glib
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/glib-2.0/. ${SYSROOT}/usr/include/glib-2.0/ && \
mkdir -p ${SYSROOT}/usr/lib/glib-2.0/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/glib-2.0/include/. ${SYSROOT}/usr/lib/glib-2.0/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libglib-2.0* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/glib-2.0.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# libpcre
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/pcre.h ${SYSROOT}/usr/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libpcre* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/libpcre.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# sqlite3
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/sqlite3.h ${SYSROOT}/usr/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libsqlite3* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/sqlite3.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# alsa
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/alsa/. ${SYSROOT}/usr/include/alsa/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libasound* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/alsa.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# tinyalsa
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/tinyalsa/. ${SYSROOT}/usr/include/tinyalsa/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libtinyalsa* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/tinyalsa.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# drm
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/drm/. ${SYSROOT}/usr/include/drm/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/xf86drmMode.h ${SYSROOT}/usr/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/include/xf86drm.h ${SYSROOT}/usr/include/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/libdrm* ${SYSROOT}/usr/lib/ && \
cp -r /sdk/aarch64-buildroot-linux-gnu/sysroot/usr/lib/pkgconfig/libdrm.pc ${SYSROOT}/usr/lib/pkgconfig/ && \
# pixman
# done
rm -rf /sdk
# END OF HACK TIME

ENV AS=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-as \
    AR=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ar \
    CC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-gcc \
    CPP=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-cpp \
    CXX=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-g++ \
    LD=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ld

# Linux kernel cross compilation variables
ENV PATH=${CROSS_ROOT}/bin:${PATH}
ENV CROSS_COMPILE=${CROSS_TRIPLE}-
ENV PREFIX=${SYSROOT}/usr
ENV ARCH=arm64

# qemu, anyone?
#ENV QEMU_LD_PREFIX="${CROSS_ROOT}/${CROSS_TRIPLE}/sysroot"
#ENV QEMU_SET_ENV="LD_LIBRARY_PATH=${CROSS_ROOT}/lib:${QEMU_LD_PREFIX}"

# CMake toolchain
COPY toolchain-aarch64.cmake ${CROSS_ROOT}/Toolchain.cmake
ENV CMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/Toolchain.cmake

#ENV PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig
ENV PKG_CONFIG_SYSROOT_DIR=${SYSROOT}
ENV PKG_CONFIG_PATH=${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig

# for c
#ENV CFLAGS="--sysroot=${SYSROOT} -I\"$SYSROOT/libc/usr/include\""
#ENV CXXFLAGS="--sysroot=$SYSROOT -I\"$SYSROOT/include/c++/8.3.0\" -I\"$SYSROOT/include/c++/8.3.0/aarch64-nextui-linux-gnu\" -I\"$SYSROOT/libc/usr/include\""
#ENV LDFLAGS="--sysroot=${SYSROOT} -L\"$SYSROOT/lib\" -L\"$SYSROOT/libc/usr/lib\""

# stuff and extra libs
COPY support .
RUN ./build-libzip.sh
#RUN ./build-bluez.sh
RUN ./build-libsamplerate.sh


ENV UNION_PLATFORM=tg5050
# do we still need this?
ENV PREFIX_LOCAL=/opt/nextui

# just to make sure
RUN mkdir -p ${PREFIX_LOCAL}/include
RUN mkdir -p ${PREFIX_LOCAL}/lib

VOLUME /root/workspace
WORKDIR /workspace

CMD ["/bin/bash"]
