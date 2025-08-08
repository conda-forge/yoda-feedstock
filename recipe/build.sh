#!/bin/bash

# See: https://github.com/prefix-dev/rattler-build/issues/1418
tar xvf YODA-*.tar.gz --strip-components=1
for patch_name in 0001-Fix-setting-rpath-when-installing-on-macOS.patch 0002-Support-overriding-install_name_tool.patch 0003-Do-not-link-against-libpython.patch; do
    patch --batch -p1 < "$RECIPE_DIR/${patch_name}"
done

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

# Regenerate the configure script
autoreconf -fvi

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
