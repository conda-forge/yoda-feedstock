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

# The configure-time value of CXXFLAGS, which contains
# -fdebug-prefix-map=<build work dir>=... flags, gets baked into the
# installed yoda-config script, leaking build machine paths that conda prefix
# relocation does not rewrite. Strip the flags and guard against any build
# machine path surviving. The recorded compiler is intentionally left as the
# activation's bare name (e.g. x86_64-conda-linux-gnu-c++), which the
# minimally activated compilers resolve from PATH in end-user environments.
sed -i -E 's@(^|[[:space:]"])-f[a-z-]+-prefix-map=[^[:space:]"]*@\1@g' "${PREFIX}/bin/yoda-config"
# Fail loudly if the guard variables are unset: grep -F -e "" matches every line
: "${BUILD_PREFIX:?}" "${SRC_DIR:?}"
if grep -E 'prefix-map=' "${PREFIX}/bin/yoda-config" \
    || grep -F -e "${BUILD_PREFIX}" -e "${SRC_DIR}" "${PREFIX}/bin/yoda-config"; then
    echo "ERROR: build machine paths leaked into ${PREFIX}/bin/yoda-config" >&2
    exit 1
fi

# Shell completions
# Bash completions
mkdir -p "${PREFIX}"/share/bash-completion/completions
cp ./bin/yoda-completion "${PREFIX}"/share/bash-completion/completions/yoda

# ZSH completions
mkdir -p "${PREFIX}"/share/zsh/site-functions
cp ./bin/yoda-completion "${PREFIX}"/share/zsh/site-functions/_yoda
