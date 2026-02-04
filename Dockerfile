FROM docker.io/library/ubuntu:24.04

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
    wget -qO - $TOOLCHAIN_URL | tar -xJ -C ${TOOLCHAIN_DIR} --strip-components=2

ENV CROSS_TRIPLE=aarch64-nextui-linux-gnu
ENV CROSS_ROOT=${TOOLCHAIN_DIR}
ENV SYSROOT=${CROSS_ROOT}/${CROSS_TRIPLE}/libc

# Download and extract the pre-packaged NextUI SDK
# This contains only the necessary libraries from the TG5050 buildroot SDK
ENV SDK_URL=https://github.com/LoveRetro/tg5050-toolchain/releases/download/sdk-20260122-164101/sdk_tg5050_nextui.tgz
RUN mkdir -p ${SYSROOT} && wget -qO - ${SDK_URL} | tar -xzC ${SYSROOT}

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
ENV ARCH=aarch64

# CMake toolchain
ENV CMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/Toolchain.cmake
COPY toolchain-aarch64.cmake ${CROSS_ROOT}/Toolchain.cmake

#ENV PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig
ENV PKG_CONFIG_SYSROOT_DIR=${SYSROOT}
ENV PKG_CONFIG_PATH=${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig

# stuff and extra libs
COPY support /root/support
RUN /root/support/build-libzip.sh
#RUN /root/support/build-bluez.sh
RUN /root/support/build-libsamplerate.sh

ENV UNION_PLATFORM=tg5050
ENV PREFIX_LOCAL=/opt/nextui

# just to make sure
RUN mkdir -p ${PREFIX_LOCAL}/include ${PREFIX_LOCAL}/lib

VOLUME /root/workspace
WORKDIR /root/workspace
