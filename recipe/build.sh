#!/bin/bash

# See: https://github.com/prefix-dev/rattler-build/issues/1418
tar xvf YODA-*.tar.gz --strip-components=1
patch --batch -p1 < "$RECIPE_DIR/0001-Fix-setting-rpath-when-installing-on-macOS.patch"

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

# Regenerate the configure script
autoreconf -fvi

# Make sure the cython sources are recompiled
rm pyext/yoda/core.cpp pyext/yoda/util.cpp

declare -a CONFIGURE_ARGS
CONFIGURE_ARGS+=("--prefix=${PREFIX}")
CONFIGURE_ARGS+=("--libdir=${PREFIX}/lib")
CONFIGURE_ARGS+=("--with-zlib=${PREFIX}")

if [ "$build_platform" != "$target_platform" ]; then
    CONFIGURE_ARGS+=("ac_cv_file_pyext_yoda_core_cpp=no")
fi

./configure "${CONFIGURE_ARGS[@]}"

make -j${CPU_COUNT}

make -j${CPU_COUNT} install
