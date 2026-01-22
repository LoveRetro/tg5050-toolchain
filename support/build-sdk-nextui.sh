#!/bin/bash
set -e

# Build a custom SDK package with only the libraries we need for NextUI toolchain
# This downloads the TG5050 buildroot SDK and extracts only the necessary components

SDK_TAR=sdk_tg5050_linux_v1.0.0.tgz
SDK_URL=https://github.com/LoveRetro/tg5050-toolchain/releases/download/20251208/${SDK_TAR}
OUTPUT_DIR=${OUTPUT_DIR:-/tmp/sdk_nextui}
OUTPUT_TAR=${OUTPUT_TAR:-sdk_tg5050_nextui.tgz}

echo "Downloading SDK from ${SDK_URL}..."
mkdir -p /tmp/sdk
wget -q ${SDK_URL} -O /tmp/${SDK_TAR}

echo "Extracting SDK..."
tar -xzf /tmp/${SDK_TAR} -C /tmp/sdk --strip-components=2
rm /tmp/${SDK_TAR}

echo "Creating output directory structure..."
mkdir -p ${OUTPUT_DIR}/usr/include
mkdir -p ${OUTPUT_DIR}/usr/lib
mkdir -p ${OUTPUT_DIR}/usr/lib/pkgconfig
mkdir -p ${OUTPUT_DIR}/usr/bin
mkdir -p ${OUTPUT_DIR}/lib

SDK_SYSROOT=/tmp/sdk/aarch64-buildroot-linux-gnu/sysroot

echo "Copying libraries and headers..."

# sdl2
echo "  - SDL2"
cp -r ${SDK_SYSROOT}/usr/include/SDL2/. ${OUTPUT_DIR}/usr/include/SDL2/
cp -r ${SDK_SYSROOT}/usr/lib/libSDL* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/sdl2.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/SDL2*.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/
cp -r ${SDK_SYSROOT}/usr/bin/sdl* ${OUTPUT_DIR}/usr/bin/

# glesv2
echo "  - GLESv2"
cp -r ${SDK_SYSROOT}/usr/include/GLES2 ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/libGLES* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/libmali* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/libdrm* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/libharfbuzz* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/glesv2.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# zlib
echo "  - zlib"
cp -r ${SDK_SYSROOT}/usr/include/zlib.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/include/zconf.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/libz* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/zlib.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# freetype
echo "  - freetype"
cp -r ${SDK_SYSROOT}/usr/include/freetype2/. ${OUTPUT_DIR}/usr/include/freetype2/
cp -r ${SDK_SYSROOT}/usr/lib/libfreetype* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/freetype2.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# libpng
echo "  - libpng"
cp -r ${SDK_SYSROOT}/usr/include/png.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/libpng* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/libpng.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# libbz2
echo "  - libbz2"
cp -r ${SDK_SYSROOT}/usr/include/bzlib.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/libbz2* ${OUTPUT_DIR}/usr/lib/

# liblz4
echo "  - liblz4"
cp -r ${SDK_SYSROOT}/usr/include/lz4.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/include/lz4frame.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/include/lz4hc.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/liblz4* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/liblz4.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# harfbuzz
echo "  - harfbuzz"
cp -r ${SDK_SYSROOT}/usr/include/harfbuzz/. ${OUTPUT_DIR}/usr/include/harfbuzz/
cp -r ${SDK_SYSROOT}/usr/lib/libharfbuzz* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/harfbuzz.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# glib
echo "  - glib"
cp -r ${SDK_SYSROOT}/usr/include/glib-2.0/. ${OUTPUT_DIR}/usr/include/glib-2.0/
mkdir -p ${OUTPUT_DIR}/usr/lib/glib-2.0/include/
cp -r ${SDK_SYSROOT}/usr/lib/glib-2.0/include/. ${OUTPUT_DIR}/usr/lib/glib-2.0/include/
cp -r ${SDK_SYSROOT}/usr/lib/libglib-2.0* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/glib-2.0.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# gobject-2.0
echo "  - gobject-2.0"
cp -r ${SDK_SYSROOT}/usr/lib/libgobject-2.0* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/gobject-2.0.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# gmodule-2.0
echo "  - gmodule-2.0"
cp -r ${SDK_SYSROOT}/usr/lib/libgmodule-2.0* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/gmodule-2.0.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/gmodule-export-2.0.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/gmodule-no-export-2.0.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# gio-2.0
echo "  - gio-2.0"
cp -r ${SDK_SYSROOT}/usr/include/gio-unix-2.0/. ${OUTPUT_DIR}/usr/include/gio-unix-2.0/
cp -r ${SDK_SYSROOT}/usr/lib/libgio-2.0* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/gio-2.0.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# libffi (gobject dependency)
echo "  - libffi"
cp -r ${SDK_SYSROOT}/usr/include/ffi.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/libffi* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/libffi.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# libmount (gio dependency)
echo "  - libmount"
cp -r ${SDK_SYSROOT}/usr/include/mntent.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/libmount* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/lib/libmount* ${OUTPUT_DIR}/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/mount.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# blkid
echo "  - blkid"
mkdir -p ${OUTPUT_DIR}/usr/include/blkid
cp -r ${SDK_SYSROOT}/usr/include/blkid/ ${OUTPUT_DIR}/usr/include/blkid/
cp -r ${SDK_SYSROOT}/usr/lib/libblkid* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/lib/libblkid* ${OUTPUT_DIR}/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/blkid.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# libpcre
echo "  - libpcre"
cp -r ${SDK_SYSROOT}/usr/include/pcre.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/libpcre* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/libpcre.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# sqlite3
echo "  - sqlite3"
cp -r ${SDK_SYSROOT}/usr/include/sqlite3.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/libsqlite3* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/sqlite3.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# alsa
echo "  - alsa"
cp -r ${SDK_SYSROOT}/usr/include/alsa/. ${OUTPUT_DIR}/usr/include/alsa/
cp -r ${SDK_SYSROOT}/usr/lib/libasound* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/alsa.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# tinyalsa
echo "  - tinyalsa"
cp -r ${SDK_SYSROOT}/usr/include/tinyalsa/. ${OUTPUT_DIR}/usr/include/tinyalsa/
cp -r ${SDK_SYSROOT}/usr/lib/libtinyalsa* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/tinyalsa.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# drm
echo "  - drm"
cp -r ${SDK_SYSROOT}/usr/include/drm/. ${OUTPUT_DIR}/usr/include/drm/
cp -r ${SDK_SYSROOT}/usr/include/xf86drmMode.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/include/xf86drm.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/libdrm* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/libdrm.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# dbus
echo "  - dbus"
cp -r ${SDK_SYSROOT}/usr/include/dbus-1.0/. ${OUTPUT_DIR}/usr/include/dbus-1.0/
mkdir -p ${OUTPUT_DIR}/usr/lib/dbus-1.0/include/
cp -r ${SDK_SYSROOT}/usr/lib/dbus-1.0/include/. ${OUTPUT_DIR}/usr/lib/dbus-1.0/include/
cp -r ${SDK_SYSROOT}/usr/lib/libdbus-1* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/dbus-1.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

# udev
echo "  - udev"
cp -r ${SDK_SYSROOT}/usr/include/libudev.h ${OUTPUT_DIR}/usr/include/
cp -r ${SDK_SYSROOT}/usr/lib/libudev* ${OUTPUT_DIR}/usr/lib/
cp -r ${SDK_SYSROOT}/lib/libudev* ${OUTPUT_DIR}/lib/
cp -r ${SDK_SYSROOT}/usr/lib/pkgconfig/libudev.pc ${OUTPUT_DIR}/usr/lib/pkgconfig/

echo "Cleaning up temporary SDK download..."
rm -rf /tmp/sdk

echo "Creating compressed archive ${OUTPUT_TAR}..."
tar -czf ${OUTPUT_TAR} -C ${OUTPUT_DIR} .

echo "Done! Created ${OUTPUT_TAR}"
echo "Archive size: $(du -h ${OUTPUT_TAR} | cut -f1)"
