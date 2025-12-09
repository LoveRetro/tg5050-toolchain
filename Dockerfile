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
    && rm -rf /var/lib/apt/lists/*

COPY support /root/support

ENV CROSS_TRIPLE=aarch64-none-linux-gnu
ENV TOOLCHAIN_DIR=/opt/ext-toolchain
ENV CROSS_ROOT=${TOOLCHAIN_DIR}
ENV SYSROOT=${CROSS_ROOT}/${CROSS_TRIPLE}/libc

# Download and extract the SDK sysroot and toolchain
ENV SDK_TAR=sdk_tg5050_linux_v1.0.0.tgz
ENV SDK_URL=https://github.com/LoveRetro/tg5050-toolchain/releases/download/20251208/${SDK_TAR}

RUN mkdir -p /sdk
RUN wget -q ${SDK_URL} -O /tmp/${SDK_TAR} && \
tar -xzf /tmp/${SDK_TAR} -C /sdk --strip-components=2
RUN rm /tmp/${SDK_TAR}
# manually copy the sdk into place to not mess up our environment
RUN cp -r /sdk/aarch64-buildroot-linux-gnu /aarch64-buildroot-linux-gnu
RUN cp -r /sdk/bin/. /usr/bin
RUN cp -r /sdk/doc/. /usr/share/doc
RUN cp -r /sdk/etc/. /etc
RUN cp -r /sdk/include/. /usr/include
RUN cp -r /sdk/lib/. /usr/lib
RUN cp -r /sdk/libexec/. /usr/libexec
RUN cp -r /sdk/man/. /usr/share/man
RUN cp -r /sdk/opt/. /opt
RUN cp -r /sdk/sbin/. /usr/sbin
RUN cp -r /sdk/share/. /usr/share
RUN rm -rf /sdk

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
#RUN ./build-libzip.sh
#RUN ./build-bluez.sh
#RUN ./build-libsamplerate.sh


ENV UNION_PLATFORM=tg5050
# do we still need this?
ENV PREFIX_LOCAL=/opt/nextui

# just to make sure
RUN mkdir -p ${PREFIX_LOCAL}/include
RUN mkdir -p ${PREFIX_LOCAL}/lib

VOLUME /root/workspace
WORKDIR /workspace

CMD ["/bin/bash"]
