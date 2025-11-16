#!/bin/bash

# Ensure NDK is available
export ANDROID_NDK_PATH=$ANDROID_HOME/ndk/28.0.13004108
[[ ! -d "$ANDROID_NDK_PATH" ]] && echo "No NDK found, quitting…" && exit 1

export ANDROIDX_MEDIA_ROOT="${PWD}/media"
export FFMPEG_MOD_PATH="${ANDROIDX_MEDIA_ROOT}/libraries/decoder_ffmpeg/src/main"
export FFMPEG_PATH="${PWD}/ffmpeg"

# Create softlink
ln -sf "${FFMPEG_PATH}" "${FFMPEG_MOD_PATH}/jni/ffmpeg"

cd "${FFMPEG_MOD_PATH}/jni"

# ---------- CONFIG ----------
API=24      # Minimum Android API
FF_TARGETS=("arm64-v8a" "armeabi-v7a" "x86_64")

# Output directory
OUT_DIR=$(pwd)/ffmpeg-build
rm -rf $OUT_DIR
mkdir -p $OUT_DIR

# ---------- OPTIMIZED FLAGS ----------
COMMON_FLAGS="
    --enable-shared
    --disable-static
    --disable-doc
    --disable-programs
    --disable-avdevice
    --disable-postproc
    --disable-debug

    --enable-avcodec
    --enable-avformat
    --enable-avutil
    --enable-swresample
    --enable-swscale

    --target-os=android
    --enable-pic
    --enable-small

    --extra-cflags='-O3 -fPIC -fstack-protector-strong'
    --extra-ldflags='-Wl,--build-id=sha1'
"

# ---------- ENABLED DECODERS ----------
DECODERS="
    --enable-decoder=h264
    --enable-decoder=hevc
    --enable-decoder=mpeg4
    --enable-decoder=mpeg2video
    --enable-decoder=mjpeg
    --enable-decoder=mjpegb
    --enable-decoder=vp8
    --enable-decoder=vp9
    --enable-decoder=av1
    --enable-decoder=prores
    --enable-decoder=dnxhd
    --enable-decoder=theora
    --enable-decoder=h263
    --enable-decoder=rv10
    --enable-decoder=rv20
    --enable-decoder=wmv1
    --enable-decoder=wmv2
    --enable-decoder=vc1

    --enable-decoder=flac
    --enable-decoder=alac
    --enable-decoder=mp3
    --enable-decoder=aac
    --enable-decoder=ac3
    --enable-decoder=eac3
    --enable-decoder=dca
    --enable-decoder=truehd
    --enable-decoder=mlp
    --enable-decoder=opus
    --enable-decoder=vorbis

    --enable-decoder=pcm_s16le
    --enable-decoder=pcm_s16be
    --enable-decoder=pcm_f32le
    --enable-decoder=pcm_mulaw
    --enable-decoder=pcm_alaw
"

# ---------- ENABLED DEMUXERS ----------
DEMUXERS="
    --enable-demuxer=matroska
    --enable-demuxer=mov
    --enable-demuxer=webm
    --enable-demuxer=avi
    --enable-demuxer=mp3
    --enable-demuxer=ogg
    --enable-demuxer=mpegts
    --enable-demuxer=flv
    --enable-demuxer=wav
    --enable-demuxer=asf
"

# ---------- ENABLED PARSERS ----------
PARSERS="
    --enable-parser=aac
    --enable-parser=ac3
    --enable-parser=eac3
    --enable-parser=h264
    --enable-parser=hevc
    --enable-parser=mpeg4video
    --enable-parser=mpegaudio
    --enable-parser=vp8
    --enable-parser=vp9
    --enable-parser=av1
"

# ---------- START BUILD FOR EACH ABI ----------
for ABI in "${FF_TARGETS[@]}"; do
    echo "==== Building FFmpeg for $ABI ===="

    case $ABI in
        "arm64-v8a")
            ARCH="aarch64"
            CROSS_PREFIX="$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-"
            CC="$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android$API-clang"
            ;;
        "armeabi-v7a")
            ARCH="arm"
            CROSS_PREFIX="$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/arm-linux-androideabi-"
            CC="$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi$API-clang"
            EXTRA_FLAGS="--enable-neon"
            ;;
        "x86_64")
            ARCH="x86_64"
            CROSS_PREFIX="$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android-"
            CC="$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android$API-clang"
            ;;
    esac

    BUILD_DIR=$OUT_DIR/$ABI
    mkdir -p $BUILD_DIR

    ./ffmpeg/configure \
        --prefix=$BUILD_DIR \
        --arch=$ARCH \
        --cpu=$ARCH \
        --cross-prefix=$CROSS_PREFIX \
        --cc=$CC \
        $COMMON_FLAGS \
        $DECODERS \
        $DEMUXERS \
        $PARSERS \
        $EXTRA_FLAGS

    make -j$(nproc)
    make install
    make clean
done

echo "FFmpeg optimized build completed."

