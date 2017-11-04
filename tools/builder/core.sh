#!/bin/sh

set -e

[ -n "$BASH_VERSION" ] && set -o posix

BUILD_ROOT=${BUILD_ROOT:-$HOME/vbam-build}
TAR=${TAR:-tar --force-local}
PERL_MAKE=${PERL_MAKE:-make}

[ -n "$BUILD_ENV" ] && eval "$BUILD_ENV"

BUILD_ENV=$BUILD_ENV$(cat <<EOF
export BUILD_ROOT="$BUILD_ROOT"

export CC="${CC:-gcc}"
export CXX="${CXX:-g++}"

if [ -z "\$CCACHE" ] && command -v ccache >/dev/null; then
    export CC="ccache \$CC"
    export CXX="ccache \$CXX"
    export CCACHE=1
fi

export CFLAGS="$CFLAGS -I$BUILD_ROOT/root/include -L$BUILD_ROOT/root/lib"
export CPPFLAGS="$CPPFLAGS -I$BUILD_ROOT/root/include"
export CXXFLAGS="$CXXFLAGS -I$BUILD_ROOT/root/include -L$BUILD_ROOT/root/lib -std=gnu++11"
export OBJCXXFLAGS="$OBJCXXFLAGS -I$BUILD_ROOT/root/include -L$BUILD_ROOT/root/lib -std=gnu++11"
export LDFLAGS="$LDFLAGS -L$BUILD_ROOT/root/lib"
export CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:-$BUILD_ROOT/root}"
export PKG_CONFIG_PATH="$BUILD_ROOT/root/lib/pkgconfig"

export PERL_MM_USE_DEFAULT=1
export PERL_EXTUTILS_AUTOINSTALL="--defaultdeps"

if command -v cygpath >/dev/null; then
    export PERL_MB_OPT='--install_base $(cygpath -u "$BUILD_ROOT/root/perl5")'
    export PERL_MM_OPT='INSTALL_BASE=$(cygpath -u "$BUILD_ROOT/root/perl5")'
    export PERL5LIB='$(cygpath -u "$BUILD_ROOT/root/perl5/lib/perl5")'
    export PERL_LOCAL_LIB_ROOT='$(cygpath -u "$BUILD_ROOT/root/perl5")'

    export PATH="$(cygpath -u "$BUILD_ROOT/root/bin"):$(cygpath -u "$BUILD_ROOT/root/perl5/bin"):$PATH"
else
    export PERL_MB_OPT='--install_base $BUILD_ROOT/root/perl5'
    export PERL_MM_OPT='INSTALL_BASE=$BUILD_ROOT/root/perl5'
    export PERL5LIB="$BUILD_ROOT/root/perl5/lib/perl5"
    export PERL_LOCAL_LIB_ROOT="$BUILD_ROOT/root/perl5"

    export PATH="$BUILD_ROOT/root/bin:$BUILD_ROOT/root/perl5/bin:$PATH"
fi
EOF
)

eval "$BUILD_ENV"

PRE_BUILD_DISTS="$PRE_BUILD_DISTS bzip2 xz unzip"

DISTS=$DISTS'
    bzip2           http://bzip.org/1.0.6/bzip2-1.0.6.tar.gz                                                    lib/libbz2.a
    xz              https://tukaani.org/xz/xz-5.2.3.tar.gz                                                      lib/liblzma.a
    unzip           https://downloads.sourceforge.net/project/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz     bin/unzip
    cmake           https://cmake.org/files/v3.10/cmake-3.10.0-rc3.tar.gz                                       bin/cmake
    zlib            https://zlib.net/zlib-1.2.11.tar.gz                                                         lib/libz.a
    autoconf        https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz                                       bin/autoconf
    automake        https://ftp.gnu.org/gnu/automake/automake-1.15.1.tar.xz                                     bin/automake
    help2man        https://ftp.gnu.org/gnu/help2man/help2man-1.47.5.tar.xz                                     bin/help2man
    libtool         https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz                                        bin/libtool
    gperf           http://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz                                           bin/gperf
    pkgconfig       https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz                         bin/pkg-config
    nasm            http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.xz                       bin/nasm
    yasm            http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz                             bin/yasm
    pcre            https://ftp.pcre.org/pub/pcre/pcre-8.41.tar.bz2                                             lib/libpcre.a
    libffi          ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz                                         lib/libffi.a
    libiconv        https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz                                   lib/libiconv.a
    libxml2         ftp://xmlsoft.org/libxml2/libxml2-2.9.6.tar.gz                                              lib/libxml2.a
    libxslt         https://git.gnome.org/browse/libxslt/snapshot/libxslt-1.1.32-rc1.tar.xz                     lib/libxslt.a
    gettext         http://ftp.gnu.org/pub/gnu/gettext/gettext-0.19.8.1.tar.xz                                  lib/libintl.a
    glib            http://mirror.umd.edu/gnome/sources/glib/2.54/glib-2.54.1.tar.xz                            lib/libglib-2.0.a
    openssl         https://www.openssl.org/source/openssl-1.0.2l.tar.gz                                        lib/libssl.a
    libpng          https://download.sourceforge.net/libpng/libpng-1.6.32.tar.xz                                lib/libpng.a
    libjpeg-turbo   https://github.com/libjpeg-turbo/libjpeg-turbo/archive/1.5.2.tar.gz                         lib/libjpeg.a
    libtiff         http://dl.maptools.org/dl/libtiff/tiff-3.8.2.tar.gz                                         lib/libtiff.a
    sdl2            https://www.libsdl.org/release/SDL2-2.0.7.tar.gz                                            lib/libSDL2.a
    flac            https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.3.2.tar.xz                             lib/libFLAC.a
    libogg          http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.xz                                  lib/libogg.a
    libvorbis       https://github.com/xiph/vorbis/archive/v1.3.5.tar.gz                                        lib/libvorbis.a
    freetype        http://download.savannah.gnu.org/releases/freetype/freetype-2.8.tar.bz2                     lib/libfreetype.a
    harfbuzz        https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-1.6.0.tar.bz2                lib/libharfbuzz.a
    sfml            https://github.com/SFML/SFML/archive/013d053277c980946bc7761a2a088f1cbb788f8c.tar.gz        lib/libsfml-system-s.a
    wxwidgets       https://github.com/wxWidgets/wxWidgets/releases/download/v3.0.3/wxWidgets-3.0.3.tar.bz2     lib/libwx_baseu-3.0.a
    XML-NamespaceSupport https://cpan.metacpan.org/authors/id/P/PE/PERIGRIN/XML-NamespaceSupport-1.12.tar.gz    perl5/lib/perl5/XML/NamespaceSupport.pm
    XML-SAX-Base    https://cpan.metacpan.org/authors/id/G/GR/GRANTM/XML-SAX-Base-1.09.tar.gz                   perl5/lib/perl5/XML/SAX/Base.pm
    XML-SAX         https://cpan.metacpan.org/authors/id/G/GR/GRANTM/XML-SAX-0.99.tar.gz                        perl5/lib/perl5/XML/SAX.pm
    docbook2x       https://downloads.sourceforge.net/project/docbook2x/docbook2x/0.8.8/docbook2X-0.8.8.tar.gz  bin/docbook2man
    expat           https://github.com/libexpat/libexpat/archive/R_2_2_4.tar.gz                                 lib/libexpat.a
    graphite2       https://github.com/silnrsi/graphite/releases/download/1.3.10/graphite2-1.3.10.tgz           lib/libgraphite2.a
    fontconfig      https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.12.6.tar.bz2           lib/libfontconfig.a
    xvidcore        http://downloads.xvid.org/downloads/xvidcore-1.3.4.tar.bz2                                  lib/libxvidcore.a
    fribidi         http://fribidi.org/download/fribidi-0.19.7.tar.bz2                                          lib/libfribidi.a
    libgsm          http://www.quut.com/gsm/gsm-1.0.17.tar.gz                                                   lib/libgsm.a
    libmodplug      https://github.com/Konstanty/libmodplug/archive/5a39f5913d07ba3e61d8d5afdba00b70165da81d.tar.gz lib/libmodplug.a
    libopencore-amrnb https://downloads.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.5.tar.gz lib/libopencore-amrnb.a
    opus            https://archive.mozilla.org/pub/opus/opus-1.2.1.tar.gz                                      lib/libopus.a
    snappy          https://github.com/google/snappy/archive/1.1.7.tar.gz                                       lib/libsnappy.a
    libsoxr         https://downloads.sourceforge.net/project/soxr/soxr-0.1.2-Source.tar.xz                     lib/libsoxr.a
    speex           http://downloads.us.xiph.org/releases/speex/speex-1.2.0.tar.gz                              lib/libspeex.a
    libtheora       https://github.com/Distrotech/libtheora/archive/17b02c8c564475bb812e540b551219fc42b1f75f.tar.gz lib/libtheora.a
    vidstab         https://github.com/georgmartius/vid.stab/archive/v1.1.0.tar.gz                              lib/libvidstab.a
    libvo-amrwbenc  https://github.com/mstorsjo/vo-amrwbenc/archive/v0.1.3.tar.gz                               lib/libvo-amrwbenc.a
    mp3lame         https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz                 lib/libmp3lame.a
    libass          https://github.com/libass/libass/releases/download/0.13.7/libass-0.13.7.tar.xz              lib/libass.a
    libbluray       ftp://ftp.videolan.org/pub/videolan/libbluray/1.0.0/libbluray-1.0.0.tar.bz2                 lib/libbluray.a
    libvpx          http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-1.6.1.tar.bz2  lib/libvpx.a
    libwavpack      http://www.wavpack.com/wavpack-5.1.0.tar.bz2                                                lib/libwavpack.a
    libx264         ftp://ftp.videolan.org/pub/videolan/x264/snapshots/last_stable_x264.tar.bz2                 lib/libx264.a
    libx265         https://bitbucket.org/multicoreware/x265/downloads/x265_2.5.tar.gz                          lib/libx265.a
    libxavs         https://github.com/Distrotech/xavs/archive/distrotech-xavs-git.tar.gz                       lib/libxavs.a
    libzmq          https://github.com/zeromq/libzmq/releases/download/v4.2.2/zeromq-4.2.2.tar.gz               lib/libzmq.a
#    libzvbi         https://downloads.sourceforge.net/project/zapping/zvbi/0.2.35/zvbi-0.2.35.tar.bz2           lib/libzvbi.a
    ffmpeg          http://ffmpeg.org/releases/ffmpeg-3.3.4.tar.xz                                              lib/libavformat.a
'

CONFIGURE_ARGS="$CONFIGURE_ARGS --disable-shared --enable-static --prefix=\$BUILD_ROOT/root"

CMAKE_BASE_ARGS="$CMAKE_BASE_ARGS -DBUILD_SHARED_LIBS=NO -DENABLE_SHARED=NO -DCMAKE_PREFIX_PATH=\"\$CMAKE_PREFIX_PATH\" -DCMAKE_BUILD_TYPE=Release"

CMAKE_ARGS="$CMAKE_BASE_ARGS $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=\$BUILD_ROOT/root"

DIST_PATCHES=$DIST_PATCHES'
    docbook2x       https://sourceforge.net/p/docbook2x/bugs/_discuss/thread/0cfa4055/f6a5/attachment/docbook2x.patch
    graphite2       https://gist.githubusercontent.com/rkitover/418600634d7cf19e2bf1c3708b50c042/raw/b5e9ee6c237a588157a754de6705a56fc315b00a/graphite2-static.patch
'

DIST_TAR_ARGS="$DIST_TAR_ARGS
"
# expat (below):
#                    sed -i.bak 's/^\\( *SUBDIRS *+= *.*\\)doc\\(.*\\)\$/\1\2/' Makefile.am; \

DIST_PRE_BUILD="$DIST_PRE_BUILD
    unzip           rm -f unix/Contents; ln -sf \$(find unix -mindepth 1 -maxdepth 1) .;
    expat           cd expat; \
                    sed -i.bak 's/cp \\\$</mv \$</' doc/doc.mk;
    xvidcore        cd build/generic; \
                    sed -i.bak '/^all:/{ s/ *\\\$(SHARED_LIB)//; }; \
                                /^install:/{ s, *\\\$(BUILD_DIR)/\\\$(SHARED_LIB),,; }; \
                                s/\\\$(INSTALL).*\\\$(SHARED_LIB).*/:/; \
                                s/\\\$(LN_S).*\\\$(SHARED_LIB).*/:/; \
                                s/@echo.*\\\$(SHARED_LIB).*/@:/; \
                    ' Makefile;
    libx265         cd source;
    XML-SAX         sed -i.bak 's/-MXML::SAX/-Mblib -MXML::SAX/' Makefile.PL
    docbook2x       if [ -e ./configure ]; then mv configure configure.bak; fi; \
                    sed -i.bak 's/^\\( *SUBDIRS *= *.*\\)doc\\(.*\\)\$/\1\2/'           Makefile.am; \
                    sed -i.bak 's/^\\( *SUBDIRS *= *.*\\)documentation\\(.*\\)\$/\1\2/' xslt/Makefile.am;
"

DIST_POST_CONFIGURE="$DIST_POST_CONFIGURE
"

DIST_CONFIGURE_OVERRIDES="$DIST_CONFIGURE_OVERRIDES
    unzip       ./configure
    cmake       ./configure --prefix=\$BUILD_ROOT/root
    zlib        ./configure --static --prefix=\$BUILD_ROOT/root
    XML-SAX     echo no | PERL_MM_USE_DEFAULT=0 perl Makefile.PL
"

DIST_UNKNOWN_TYPE_MAKE_INSTALL_ARGS='prefix="$BUILD_ROOT/root" PREFIX="$BUILD_ROOT/root" INSTALL_ROOT="$BUILD_ROOT/root"'

DIST_ARGS="$DIST_ARGS
    gettext     --with-included-gettext --with-included-glib --with-included-libcroco --with-included-libunistring --with-included-libxml CPPFLAGS=\"\$CPPFLAGS -DLIBXML_STATIC\"
    pkgconfig   --with-internal-glib
    pcre        --enable-utf8 --enable-pcre8 --enable-pcre16 --enable-pcre32 --enable-unicode-properties --enable-pcregrep-libz --enable-pcregrep-libbz2 --enable-jit
    sfml        -DSFML_USE_SYSTEM_DEPS=TRUE
    freetype    --with-harfbuzz=no
    harfbuzz    --with-cairo=no
    libvpx      --disable-unit-tests --disable-tools --disable-docs --disable-examples
    libxavs     --disable-asm
    libzvbi     --without-x --without-doxygen
    libxml2     --without-python
    wxwidgets   --enable-stl --disable-precomp-headers
    libbluray   --disable-bdjava
    libopencore-amrnb   --disable-compile-c
    vidstab     -DUSE_OMP=NO
    libx265     -DHIGH_BIT_DEPTH=ON -DENABLE_ASSEMBLY=OFF -DENABLE_CLI=OFF
    ffmpeg      --pkg-config-flags=--static --enable-nonfree --extra-version=tessus --enable-avisynth --enable-fontconfig --enable-gpl --enable-version3 --enable-libass --enable-libbluray --enable-libfreetype --enable-libgsm --enable-libmodplug --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopus --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libtheora --enable-libvidstab --enable-libvo-amrwbenc --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libx264 --enable-libx265 --enable-libxavs --enable-libxvid --enable-libzmq --enable-openssl --enable-lzma --extra-cflags='-DMODPLUG_STATIC -DZMQ_STATIC' --extra-ldflags='-Wl,-allow-multiple-definition'
#
# TODO: add these if possible (from brew) --enable-indev=qtkit --enable-securetransport --enable-chromaprint --enable-ffplay --enable-frei0r --enable-libbs2b --enable-libcaca --enable-libfdk-aac --enable-libgme --enable-libgsm --enable-librtmp --enable-librubberband --enable-libssh --enable-libtesseract --enable-libtwolame --enable-webp --enable-libzimg
#
# Possibly also: --enable-libzvbi
#   I could not get libzvbi to build
#
# these require > 10.7:
#   --enable-opencl       # requires 10.8
#   --enable-videotoolbox # requires 10.8
"

DIST_MAKE_ARGS="$DIST_MAKE_ARGS
    unzip       generic2
    expat       DOCBOOK_TO_MAN=docbook2man
"

DIST_MAKE_INSTALL_ARGS="$DIST_MAKE_INSTALL_ARGS
"

DIST_POST_BUILD="$DIST_POST_BUILD
    harfbuzz    build_dist freetype --with-harfbuzz=yes
"

DIST_EXTRA_LDFLAGS="$DIST_EXTRA_LDFLAGS
"

builder() {
    setup
    read_command_line "$@"
    install_core_deps
    delete_outdated_dists
    build_prerequisites
    download_dists
    build_dists
    build_project
}

read_command_line() {
    case "$1" in
        --env)
            echo "$BUILD_ENV"
            exit 0
            ;;
    esac
}

setup() {
    detect_os

    mkdir -p "$BUILD_ROOT/root/include"
    [ -e "$BUILD_ROOT/root/inc" ] || ln -s "$BUILD_ROOT/root/include" "$BUILD_ROOT/root/inc"

    DIST_NAMES=$(  table_column DISTS 0 3)
    DIST_URLS=$(   table_column DISTS 1 3)
    DIST_TARGETS=$(table_column DISTS 2 3)

    DISTS_NUM=$(table_rows DISTS)

    NUM_CPUS=$(num_cpus)

    BUILD_ENV="$BUILD_ENV
export MAKEFLAGS=-j$NUM_CPUS
"
    eval "$BUILD_ENV"

    CHECKOUT=$(find_checkout)

    TMP_DIR=${TMP_DIR:-/tmp/builder-$$}

    setup_tmp_dir

    UNPACK_DIR="$TMP_DIR/unpack"
    mkdir "$UNPACK_DIR"

    DISTS_DIR="$BUILD_ROOT/dists"
    mkdir -p "$DISTS_DIR"
}

num_cpus() {
    if command -v nproc >/dev/null; then
        nproc
        return $?
    fi

    if [ -e /proc/cpuinfo ]; then
        set -- $(grep '^processor		*:' /proc/cpuinfo | wc -l)
        echo $1
        return 0
    fi

    if command -v sysctl >/dev/null; then
        sysctl -n hw.ncpu
        return 0
    fi

    warn 'cannot determine number of CPU threads, using a default of [1;31m2[0m'

    echo 2
}

install_core_deps() {
    ${os}_install_core_deps

    # things like ccache may have been installed, re-eval build env
    eval "$BUILD_ENV"
}

installing_core_deps() {
    echo "\n[32mInstalling core dependencies for your OS...[0m\n"
}

done_msg() {
    echo "\n[32mDone!!![0m\n"
}

unknown_install_core_deps() {
    :
}

linux_install_core_deps() {
    # detect host architecture
    case "$(uname -a)" in
        *x86_64*)
            amd64=1
            ;;
        *i686*)
            i686=1
            ;;
    esac

    if [ -f /etc/debian_version ]; then
        debian_install_core_deps
    elif [ -f /etc/fedora-release ]; then
        fedora_install_core_deps
    elif [ -f /etc/arch-release ]; then
        archlinux_install_core_deps
    elif [ -f /etc/solus-release ]; then
        solus_install_core_deps
    fi
}

debian_install_core_deps() {
    installing_core_deps

    sudo apt-get -qq update || :
    sudo apt-get -qy install build-essential g++ curl

    done_msg
}

fedora_install_core_deps() {
    installing_core_deps

    sudo dnf -y --nogpgcheck --best --allowerasing install gcc gcc-c++ make redhat-rpm-config curl
}

archlinux_install_core_deps() {
    installing_core_deps

    # check for gcc-multilib
    gcc_pkg=gcc
    if sudo pacman -Q gcc-multilib >/dev/null 2>&1; then
        gcc_pkg=gcc-multilib
    fi

    # update catalogs
    sudo pacman -Sy

    # not using the base-devel group because it can break gcc-multilib
    sudo pacman --noconfirm --needed -S $gcc_pkg binutils file grep gawk gzip make patch sed util-linux curl

    done_msg
}

solus_install_core_deps() {
    installing_core_deps

    sudo eopkg -y update-repo
    sudo eopkg -y install -c system.devel curl

    done_msg
}

windows_install_core_deps() {
    if [ -n "$msys2" ]; then
        msys2_install_core_deps
    elif [ -n "$cygwin" ]; then
        cygwin_install_core_deps
    fi
}

cygwin_install_core_deps() {
    :
}

msys2_install_core_deps() {
    case "$MSYSTEM" in
        MINGW32)
            target='mingw-w64-i686'
            ;;
        *)
            target='mingw-w64-x86_64'
            ;;
    esac

    installing_core_deps

    # update catalogs
    pacman -Sy

    set --
    for p in binutils curl crt-git gcc gcc-libs gdb headers-git tools-git windows-default-manifest libmangle-git; do
        set -- "$@" "${target}-${p}"
    done

    # install
    # TODO: remove zip and add to dists
    pacman --noconfirm --needed -S make tar patch diffutils ccache zip perl m4 "$@"

    # activate ccache
    eval "$BUILD_ENV"

    done_msg
}

mac_install_core_deps() {
    if ! xcode-select -p >/dev/null 2>&1 && \
       ! pkgutil --pkg-info=com.apple.pkg.CLTools_Executables >/dev/null 2>&1 && \
       ! pkgutil --pkg-info=com.apple.pkg.DeveloperToolsCLI >/dev/null 2>&1; then

        error 'Please install XCode and the XCode Command Line Tools, then run this script again. On newer systems this can be done with: [35m;xcode-select --install[0m'
    fi
}

setup_tmp_dir() {
    # mkdir -m doesn't work on some versions of msys and similar
    rm -rf "$TMP_DIR"
    if ! ( mkdir -m 700 "$TMP_DIR" 2>/dev/null || mkdir "$TMP_DIR" 2>/dev/null || [ -d "$TMP_DIR" ] ); then
        die "Failed to create temporary directory: '[1;35m$TMP_DIR[0m"
    fi

    chmod 700 "$TMP_DIR" 2>/dev/null || :

    trap 'quit $?' EXIT PIPE HUP INT QUIT ILL TRAP KILL BUS TERM
}

quit() {
    cd "$HOME" || :
    rm -rf "$TMP_DIR" || :
    exit "${1:-0}"
}

detect_os() {
    case "$(uname -s)" in
        Linux)
            os=linux
            ;;
        Darwin)
            os=mac
            ;;
        MINGW*|MSYS*)
            os=windows
            msys2=1

            # adjust for windows native perl
            #BUILD_ENV=$(echo "$BUILD_ENV" | sed 's,^\(export PERL[^/]*\)/c/\(.*\),\1c:/\2,')
            #eval "$BUILD_ENV"
            ;;
        CYGWIN*)
            os=windows
            cygwin=1
            ;;
        *)
            os=unknown
            ;;
    esac
}

delete_outdated_dists() {
    [ ! -d "$BUILD_ROOT/downloads" ] && return 0

    files=
    i=0
    for dist in $DIST_NAMES; do
        dist_url=$(list_get $i $DIST_URLS)
        dist_file="$BUILD_ROOT/downloads/$dist-${dist_url##*/}"

        files="$files $dist_file"

        i=$((i + 1))
    done

    OLDIFS=$IFS
    IFS='
';  find "$BUILD_ROOT/downloads" -maxdepth 1 -type f -not -name '.*' | \
    while read -r file; do
        IFS=$OLDIFS
        if ! list_contains "$file" $files; then
            echo "\n[32mDeleting outdated dist: [1;34m$file[0m\n"
            rm -f "$file"
        fi
    done
    IFS=$OLDIFS
}

build_prerequisites() {
    dists_are_installed $PRE_BUILD_DISTS && return 0

    echo "\n[32mFetching and building prerequisites...[0m\n"

    for dist in $PRE_BUILD_DISTS; do
        download_dist $dist
        build_dist_if_needed $dist
    done

    echo "\n[32mDone with prerequisites.[0m\n"
}

dists_are_installed() {
    for _dist; do
        if [ ! -e "$(install_artifact $_dist)" ]; then
            return 1
        fi
    done
}

download_dists() {
    running_jobs=
    max_jobs=$((NUM_CPUS * 2))
    mkdir -p "$TMP_DIR/job_status" "$TMP_DIR/job_output"
    for dist in $DIST_NAMES; do
        (
            job_pid=$(exec sh -c 'echo $PPID')
            echo "dist_name=$dist" > "$TMP_DIR/job_status/$job_pid"
            {
                download_dist $dist
                echo "job_exited=$?" >> "$TMP_DIR/job_status/$job_pid"
            } 2>&1 | tee "$TMP_DIR/job_output/$job_pid"
        ) &
        running_jobs="$running_jobs $!"

        while [ "$(list_length $running_jobs)" -ge $max_jobs ]; do
            sleep 1
            check_jobs running_jobs
        done
    done

    # wait for pending jobs to finish
    while [ "$(list_length $running_jobs)" -ne 0 ]; do
        sleep 1
        check_jobs running_jobs
    done
}

download_dist() {
    dist_name=$1
    [ -n "$dist_name" ] || die 'download_dist: dist name required'

    dist_idx=$(list_index $dist_name $DIST_NAMES)
    dist_url=$( list_get $dist_idx $DIST_URLS)
    orig_dist_file="$BUILD_ROOT/downloads/${dist_url##*/}"
    dist_file="$BUILD_ROOT/downloads/$dist_name-${dist_url##*/}"
    dist_dir="$DISTS_DIR/$dist_name"

    mkdir -p "$BUILD_ROOT/downloads"
    cd "$BUILD_ROOT/downloads"

    if [ ! -e "$dist_file" ]; then
        echo "\n[32mFetching [1;35m$dist_name[0m: [1;34m$dist_url[0m\n"
        curl -SsLO "$dist_url"

        mv -f "$orig_dist_file" "$dist_file"

        # force rebuild for new dist file
        rm  -f "$BUILD_ROOT/root/$(list_get $dist_idx $DIST_TARGETS)"
        rm -rf "$dist_dir"
    fi

    if [ ! -d "$dist_dir" ]; then
        echo "\n[32mUnpacking [1;35m$dist_name[0m\n"
        mkdir "$dist_dir"

        unpack_dir="$UNPACK_DIR/$dist_name-$$"
        mkdir "$unpack_dir"
        cd "$unpack_dir"

        eval "set -- $(dist_tar_args "$dist_name")"

        case "$dist_file" in
            *.tar)
                $TAR $@ -xf "$dist_file"
                ;;
            *.tar.gz|*.tgz)
                $TAR $@ -zxf "$dist_file"
                ;;
            *.tar.xz)
                xzcat "$dist_file" | $TAR $@ -xf -
                ;;
            *.tar.bz2)
                bzcat "$dist_file" | $TAR $@ -xf -
                ;;
            *.zip)
                unzip -q "$dist_file"
                ;;
        esac

        for archive_dir in *; do
            cd "$archive_dir"
            $TAR -cf - . | (cd "$dist_dir"; $TAR -xf -)
        done
        cd "$TMP_DIR"
        rm -rf "$unpack_dir"

        # force rebuild if dist dir was deleted
        rm -f "$BUILD_ROOT/root/$(list_get $dist_idx $DIST_TARGETS)"
    fi
}

running_jobs() {
    alive_list_var=$1
    [ -n "$alive_list_var" ] || die 'running_jobs: alive list variable name required'
    reaped_list_var=$2
    [ -n "$reaped_list_var" ] || die 'running_jobs: reaped list variable name required'

    jobs_file="$TMP_DIR/jobs_list.txt"

    jobs -l > "$jobs_file"

    eval "$alive_list_var="
    eval "$reaped_list_var="
    OLDIFS=$IFS
    IFS='
'
    # will get pair: <PID> <state>
    for job in $(sed <"$jobs_file" -n 's/^\[[0-9]\{1,\}\] *[-+]\{0,1\}  *\([0-9][0-9]*\)  *\([A-Za-z]\{1,\}\).*/\1 \2/p'); do
        IFS=$OLDIFS
        set -- $job
        pid=$1 state=$2
        
        case "$state" in
            Stopped)
                kill $pid 2>/dev/null || :
                eval "$reaped_list_var=\"\$$reaped_list_var $pid\""
                ;;
            Running)
                eval "$alive_list_var=\"\$$alive_list_var $pid\""
                ;;
        esac
    done
    IFS=$OLDIFS

    rm -f "$jobs_file"
}

check_jobs() {
    jobs_list_var=$1
    [ -n "$jobs_list_var" ] || die 'check_jobs: jobs list variable name required'

    running_jobs alive reaped

    new_jobs=
    for job in $(eval echo \$$jobs_list_var); do
        if list_contains $job $alive; then
            new_jobs="$new_jobs $job"
        else
            job_status_file="$TMP_DIR/job_status/$job"
            job_output_file="$TMP_DIR/job_output/$job"

            if [ -e "$job_status_file" ]; then
                job_exited= dist_name=
                eval "$(cat "$job_status_file")"

                if [ -n "$job_exited" ] && [ "$job_exited" -eq 0 ]; then
                    rm "$job_status_file" "$job_output_file"
                else
                    error "Fetch/unpack process failed, winding down pending processes..."

                    while [ "$(list_length $alive)" -ne 0 ]; do
                        for pid in $alive; do
                            if ! list_contains $pid $last_alive; then
                                kill $pid 2>/dev/null || :
                            else
                                kill -9 $pid 2>/dev/null || :
                            fi
                        done

                        last_alive=$alive

                        sleep 0.2

                        running_jobs alive reaped
                    done

                    if [ "$os" != windows ]; then
                        sleep 30
                    else
                        # this is painfully slow on msys2/cygwin
                        warn 'Please wait, this will take a while...'

                        # don't want signals to interrupt sleep
                        trap - PIPE HUP ALRM

                        sleep 330 || :
                    fi

                    error "Fetching/unpacking $dist_name failed, check the URL:\n\n$(cat "$job_output_file")"

                    rm -rf "$DISTS_DIR"

                    exit 1
                fi
            fi
        fi
    done

    eval "$jobs_list_var=\$new_jobs"
}

# fall back to 1 second sleeps if fractional sleep is not supported
sleep() {
    if ! command sleep "$@" 2>/dev/null; then
        sleep_secs=${1%%.*}
        shift
        if [ -z "$sleep_secs" ] || [ "$sleep_secs" -lt 1 ]; then
            sleep_secs=1
        fi
        command sleep $sleep_secs "$@"
    fi
}

build_dists() {
    for dist in $DIST_NAMES; do
        build_dist_if_needed $dist
    done
}

build_dist_if_needed() {
    dist_name=$1
    [ -n "$dist_name" ] || die 'build_dist_if_needed: dist name required'
    shift

    if [ ! -e "$(install_artifact $dist_name)" ]; then
        build_dist $dist_name "$@"
    fi
}

build_dist() {
    dist=$1
    [ -n "$dist" ] || die 'build_dist: dist name required'
    shift
    extra_dist_args=$@

    cd "$DISTS_DIR/$dist"

    echo "\n[32mBuilding [1;35m$dist[0m\n"

    ORIG_LDFLAGS=$LDFLAGS

    # have to make sure C++ flags are passed when linking, but only for C++ and **NOT** C
    # this fails if there are any .c files in the project
    if [ "$(find . -name '*.cpp' -o -name '*.cc' | wc -l)" -ne 0 -a "$(find . -name '*.c' | wc -l)" -eq 0 ]; then
        export LDFLAGS="$CXXFLAGS $LDFLAGS"
    fi

    export LDFLAGS="$LDFLAGS $(dist_extra_ldflags "$dist")"

    dist_patch "$dist"
    dist_pre_build "$dist"

    dist_configure_override=$(dist_configure_override "$dist")

    if [ -e configure -o -e configure.ac -o -e configure.in -o -e Makefile.am ]; then
        if [ ! -e configure ]; then
            if [ -e autogen.sh ]; then
                echo_run sh autogen.sh
            elif [ -e buildconf.sh ]; then
                echo_run sh buildconf.sh
            else
                if [ -d m4 ]; then
                    echo_run aclocal -I m4
                else
                    echo_run aclocal
                fi

                if command -v glibtoolize >/dev/null; then
                    echo_run glibtoolize
                else
                    echo_run libtoolize
                fi

                echo_run autoheader || :
                echo_run autoconf
                [ -e Makefile.am ] && echo_run automake --add-missing
            fi
        fi

        if [ -n "$dist_configure_override" ]; then
            eval "set -- $extra_dist_args"
            eval "echo_run $dist_configure_override $@"
        else
            eval "set -- $(dist_args "$dist" autoconf) $extra_dist_args"
            echo_run ./configure "$@"
        fi
        dist_post_configure "$dist"
        eval "set -- $(dist_make_args "$dist")"
        echo_run make -j$NUM_CPUS "$@"
        eval "set -- $(dist_make_install_args "$dist")"
        echo_run make "$@" install prefix=$BUILD_ROOT/root || [ -e "$(install_artifact $dist)" ]
    elif [ -e CMakeLists.txt ]; then
        mkdir -p build
        cd build

        if [ -n "$dist_configure_override" ]; then
            eval "set -- $extra_dist_args"
            eval "echo_run $dist_configure_override $@"
        else
            eval "set -- $(dist_args "$dist" cmake) $extra_dist_args"
            echo_run cmake .. "$@"
        fi
        dist_post_configure "$dist"
        eval "set -- $(dist_make_args "$dist")"
        echo_run make -j$NUM_CPUS "$@"
        rm -rf destdir
        mkdir destdir
        eval "set -- $(dist_make_install_args "$dist")"
        echo_run make "$@" install DESTDIR="$PWD/destdir" || [ -e "destdir/$(remove_drive_prefix "$(install_artifact "$dist")")" ]

        cd "destdir/$(remove_drive_prefix $BUILD_ROOT)/root"
        OLDPWD=$PWD
        find . ! -type d | (cd "$BUILD_ROOT/root";IFS='
';              while read f; do
            if [ ! -d "${f%/*}" ]; then
                echo_run mkdir -p "${f%/*}"
            fi
            echo_run cp -a "$OLDPWD/$f" "$f"
        done)

        [ -e "$(install_artifact $dist)" ]
    elif [ -e Makefile.PL ]; then
        if [ -n "$dist_configure_override" ]; then
            eval "set -- $extra_dist_args"
            eval "echo_run $dist_configure_override $@"
        else
            eval "set -- $(dist_args "$dist" perl) $extra_dist_args"
            echo_run perl Makefile.PL "$@"
        fi
        dist_post_configure "$dist"
        eval "set -- $(dist_make_args "$dist")"
        echo_run $PERL_MAKE "$@" # dmake doesn't understand -j
        eval "set -- $(dist_make_install_args "$dist")"
        echo_run $PERL_MAKE "$@" install || [ -e "$(install_artifact $dist)" ]
    elif [ -e Makefile -o -e makefile ]; then
        eval "set -- $(dist_make_args "$dist")"
        echo_run make -j$NUM_CPUS "$@"
        eval "set -- $(dist_make_install_args "$dist") $DIST_UNKNOWN_TYPE_MAKE_INSTALL_ARGS"
        echo_run make "$@" install || [ -e "$(install_artifact $dist)" ]
    else
        die "don't know how to build [1;35m$dist[0m"
    fi

    dist_post_build "$dist"

    export LDFLAGS=$ORIG_LDFLAGS

    done_msg
}

echo_run() {
    echo "[32mExecuting[0m[35m:[0m $(cmd_with_quoted_args "$@")"
    "$@"
}

cmd_with_quoted_args() {
    [ -n "$1" ] || error 'cmd_with_quoted_args: command required'
    res="$1 "
    shift
    for arg; do
        res="$res '$arg'"
    done
    echo "$res"
}

remove_drive_prefix() {
    path=$1
    [ -n "$path" ] || die 'remove_drive_prefix: path required'

    if [ -n "$msys2" ]; then
        path=${path#/[a-zA-Z]/}
    elif [ -n "$cygwin" ]; then
        path=${path#/cygdrive/[a-zA-Z]/}
    fi

    # remove windows drive prefixes such as c:
    path=${path#[a-zA-Z]:}

    # remove all but one slash at the beginning (double slashes have special meaning on windows)
    while :; do
        case "$path" in
            /*)
                path=${path#/}
                ;;
            *)
                break
                ;;
        esac
    done

    echo "/$path"
}

list_get() {
    pos=$1
    [ -n "$pos" ] || die 'list_pos: position to retrieve required'
    shift

    i=0
    for item; do
        if [ $i -eq $pos ]; then
            echo "$item"
            return 0
        fi

        i=$((i + 1))
    done
}

list_index() {
    item=$1
    [ -n "$item" ] || die 'list_index: item to find required'
    shift

    i=0
    for element; do
        if [ "$element" = "$item" ]; then
            echo $i
            return 0
        fi

        i=$((i + 1))
    done

    return 1
}

dist_args() {
    dist=$1
    [ -n "$dist" ] || die 'dist_args: dist name required'
    buildsys=$2

    case "$buildsys" in
        autoconf)
            echo "$CONFIGURE_ARGS $(table_line DIST_ARGS $dist)" || :
            ;;
        cmake)
            echo "$CMAKE_ARGS $(table_line DIST_ARGS $dist)" || :
            ;;
        perl)
            echo "$(table_line DIST_ARGS $dist)" || :
            ;;
        *)
            die "dist_args: buildsystem type required, must be 'autoconf', 'cmake' or 'perl'"
            ;;
    esac
}

dist_tar_args() {
    _dist=$1
    [ -n "$_dist" ] || die 'dist_tar_args: dist name required'

    echo "$(table_line DIST_TAR_ARGS $_dist)" || :
}

dist_configure_override() {
    _dist=$1
    [ -n "$_dist" ] || die 'dist_configure_override: dist name required'

    echo "$(table_line DIST_CONFIGURE_OVERRIDES $_dist)" || :
}

dist_make_args() {
    dist=$1
    [ -n "$dist" ] || die 'dist_make_args: dist name required'

    echo "$(table_line DIST_MAKE_ARGS $dist)" || :
}

dist_make_install_args() {
    dist=$1
    [ -n "$dist" ] || die 'dist_make_install_args: dist name required'

    echo "$(table_line DIST_MAKE_INSTALL_ARGS $dist)" || :
}

dist_extra_ldflags() {
    dist=$1
    [ -n "$dist" ] || die 'dist_extra_ldflags: dist name required'

    echo "$(table_line DIST_EXTRA_LDFLAGS $dist)" || :
}

dist_patch() {
    _dist_name=$1
    [ -n "$_dist_name" ] || die 'dist_patch: dist name required'

    for _patch_url in $(table_line DIST_PATCHES $_dist_name); do
        echo "\n[32mApplying patch [1;34m$_patch_url[0m to [1;35m$_dist_name[0m\n"

        _patch_file=${_patch_url##*/}
        _patch_file=${_patch_file%%\?*}

        curl -SsL "$_patch_url" -o "$_patch_file"
        patch -p1 < "$_patch_file"

        done_msg
    done
}

dist_pre_build() {
    _dist_name=$1
    [ -n "$_dist_name" ] || die 'dist_pre_build: dist name required'

    if _cmd=$(table_line DIST_PRE_BUILD $_dist_name); then
        echo "\n[32mRunning pre-build for: [1;35m$_dist_name[0m:\n$_cmd\n"

        eval "$_cmd"
    fi
}

dist_post_configure() {
    _dist_name=$1
    [ -n "$_dist_name" ] || die 'dist_post_configure: dist name required'

    if _cmd=$(table_line DIST_POST_CONFIGURE $_dist_name); then
        echo "\n[32mRunning post-configure for: [1;35m$_dist_name[0m:\n$_cmd\n"

        eval "$_cmd"
    fi
}

dist_post_build() {
    _dist_name=$1
    [ -n "$_dist_name" ] || die 'dist_post_build: dist name required'

    if _cmd=$(table_line DIST_POST_BUILD $_dist_name); then
        if [ -z "$IN_DIST_POST_BUILD" ]; then
            IN_DIST_POST_BUILD=1

            echo "\n[32mRunning post-build for: [1;35m$_dist_name[0m:\n$_cmd\n"

            eval "$_cmd"

            IN_DIST_POST_BUILD=
        fi
    fi
}

table_line() {
    table=$1
    [ -n "$table" ] || die 'table_line: table name required'
    name=$2
    [ -n "$name" ]  || die 'table_line: item name required'

    table=$(table_contents $table)

    OLDIFS=$IFS
    IFS='
'
    for line in $table; do
        IFS=$OLDIFS
        set -- $line
        if [ "$1" = "$name" ]; then
            shift
            echo "$@"
            return 0
        fi
    done
    IFS=$OLDIFS

    return 1
}

table_line_append() {
    table=$1
    [ -n "$table" ]      || die 'table_line_append: table name required'
    name=$2
    [ -n "$name" ]       || die 'table_line_append: item name required'
    append_str=$3
    [ -n "$append_str" ] || die 'table_line_append: string to append required'

    table_name=$table
    table=$(table_contents $table)

    new_table=
    line_appended=
    OLDIFS=$IFS
    IFS='
'
    for line in $table; do
        IFS=$OLDIFS
        set -- $line
        if [ "$1" = "$name" ]; then
            new_table=$new_table"     $@ $append_str\n"
            line_appended=1
        else
            new_table=$new_table"$@\n"
        fi
    done
    IFS=$OLDIFS

    if [ -z "$line_appended" ]; then
        # make new entry
        new_table=$new_table"    $name    $append_str\n"
    fi

    eval "$table_name=\$new_table"
}

table_line_replace() {
    table=$1
    [ -n "$table" ]   || die 'table_line_replace: table name required'
    name=$2
    [ -n "$name" ]    || die 'table_line_replace: item name required'
    set_str=$3
    [ -n "$set_str" ] || die 'table_line_replace: string to set required'

    table_name=$table
    table=$(table_contents $table)

    new_table=
    line_found=
    OLDIFS=$IFS
    IFS='
'
    for line in $table; do
        IFS=$OLDIFS
        set -- $line
        if [ "$1" = "$name" ]; then
            new_table=$new_table"    $1    $set_str\n"
            line_found=1
        else
            new_table=$new_table"$@\n"
        fi
    done
    IFS=$OLDIFS

    if [ -z "$line_found" ]; then
        # make new entry
        new_table=$new_table"    $name    $set_str\n"
    fi

    eval "$table_name=\$new_table"
}

table_insert_after() {
    table=$1
    [ -n "$table" ]   || die 'table_insert_after: table name required'
    name=$2
    [ -n "$name" ]    || die 'table_insert_after: item name to insert after required'
    new_line=$3
    [ -n "$new_line" ] || die 'table_insert_after: new line required'

    table_name=$table
    table=$(table_contents $table)

    new_table=
    line_found=
    OLDIFS=$IFS
    IFS='
'
    for line in $table; do
        IFS=$OLDIFS
        set -- $line
        new_table=$new_table"$@\n"

        if [ "$1" = "$name" ]; then
            new_table="${new_table}${new_line}\n"
            line_found=1
        fi
    done
    IFS=$OLDIFS

    [ -n "$line_found" ] || error 'table_insert_after: item to insert after not found'

    eval "$table_name=\$new_table"
}

table_insert_before() {
    table=$1
    [ -n "$table" ]   || die 'table_insert_before: table name required'
    name=$2
    [ -n "$name" ]    || die 'table_insert_before: item name to insert before required'
    new_line=$3
    [ -n "$new_line" ] || die 'table_insert_before: new line required'

    table_name=$table
    table=$(table_contents $table)

    new_table=
    line_found=
    OLDIFS=$IFS
    IFS='
'
    for line in $table; do
        IFS=$OLDIFS
        set -- $line

        if [ "$1" = "$name" ]; then
            new_table="${new_table}${new_line}\n"
            line_found=1
        fi

        new_table=$new_table"$@\n"
    done
    IFS=$OLDIFS

    [ -n "$line_found" ] || error 'table_insert_before: item to insert before not found'

    eval "$table_name=\$new_table"
}

table_line_remove() {
    table=$1
    [ -n "$table" ]      || die 'table_line_remove: table name required'
    name=$2
    [ -n "$name" ]       || die 'table_line_remove: item name required'

    table_name=$table
    table=$(table_contents $table)

    new_table=
    OLDIFS=$IFS
    IFS='
'
    for line in $table; do
        IFS=$OLDIFS
        set -- $line
        if [ "$1" != "$name" ]; then
            new_table=$new_table"$@\n"
        fi
    done
    IFS=$OLDIFS

    eval "$table_name=\$new_table"
}

find_checkout() {
    (
        cd "$(dirname "$0")"
        while [ "$PWD" != / ]; do
            if [ -e src/version.h.in ]; then
                echo "$PWD"
                exit 0
            fi

            cd ..
        done
        exit 1
    ) || die 'cannot find project checkout'
}

error() {
    echo >&2 "\n[31mERROR[0m: $@\n\n"
}

warn() {
    echo >&2 "\n[35mWARNING[0m: $@\n\n"
}

die() {
    error "$@"
    exit 1
}

build_project() {
    echo "\n[32mBuilding project: [1;34m$CHECKOUT[0m\n"

    mkdir -p "$BUILD_ROOT/project"
    cd "$BUILD_ROOT/project"

    eval "set -- $CMAKE_BASE_ARGS"
    echo_run cmake "$CHECKOUT" "$@" -DVBAM_STATIC=ON -DENABLE_FFMPEG=ON
    echo_run make -j$NUM_CPUS

    if [ "$os" = mac ]; then
        codesign -s "Developer ID Application" --deep ./visualboyadvance-m.app || :

        rm -f ./visualboyadvance-m-Mac.zip
        zip -9r ./visualboyadvance-m-Mac.zip ./visualboyadvance-m.app
    fi

    echo "\n[32mBuild Successful!!![0m\n\nBuild results can be found in: [1;34m$BUILD_ROOT/project[0m\n"
}

table_column() {
    table=$1
    [ -n "$table" ]    || die 'table_column: table name required'
    col=$2
    [ -n "$col" ]      || die 'table_column: column required'
    row_size=$3
    [ -n "$row_size" ] || die 'table_column: row_size required'

    table=$(table_contents $table)

    i=0
    res=
    for item in $table; do
        if [ $((i % row_size)) -eq "$col" ]; then
            res="$res $item"
        fi
        i=$((i + 1))
    done

    echo "$res"
}

table_rows() {
    table=$1
    [ -n "$table" ] || die 'table_rows: table name required'

    table=$(table_contents $table)

    i=0
    OLDIFS=$IFS
    IFS='
';  for line in $table; do
        i=$((i + 1))
    done
    IFS=$OLDIFS

    echo $i
}

table_contents() {
    table=$1
    [ -n "$table" ] || die 'table_contents: table name required'

    # filter comments and blank lines
    eval echo "\"\$$table\"" | grep -Ev '^ *(#|$)' || :
}

list_contains() {
    _item=$1
    [ -n "$_item" ] || die 'list_contains: item required'
    shift

    for _pos; do
        [ "$_item" = "$_pos" ] && return 0
    done

    return 1
}

list_length() {
    echo $#
}

install_artifact() {
    dist=$1
    [ -n "$dist" ] || die 'install_artifact: dist name required'

    set -- $(table_line DISTS $dist)

    eval echo "'$BUILD_ROOT/root/'"\"\$$#\"
}

echo() {
    if [ -n "$BASH_VERSION" ]; then
        command echo -e "$@"
    else
        command echo "$@"
    fi
}
