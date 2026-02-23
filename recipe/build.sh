#!/bin/bash

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

./configure --help

./configure "${CONFIGURE_ARGS[@]}"

make -j${CPU_COUNT}

make -j${CPU_COUNT} install

# Shell completions
# Bash completions
mkdir -p "${PREFIX}"/share/bash-completion/completions
cp ./bin/yoda-completion "${PREFIX}"/share/bash-completion/completions/yoda

# ZSH completions
mkdir -p "${PREFIX}"/share/zsh/site-functions
cp ./bin/yoda-completion "${PREFIX}"/share/zsh/site-functions/_yoda
