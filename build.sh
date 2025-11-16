#!/bin/bash

export ANDROID_NDK_PATH=$ANDROID_HOME/ndk/28.0.13004108
[[ ! -d "$ANDROID_NDK_PATH" ]] && echo "No NDK found, quitting…" && exit 1

export ANDROIDX_MEDIA_ROOT="${PWD}/media"
export FFMPEG_MOD_PATH="${ANDROIDX_MEDIA_ROOT}/libraries/decoder_ffmpeg/src/main"
export FFMPEG_PATH="${PWD}/ffmpeg"

# Updated decoders list (your request)
export ENABLED_DECODERS=(flac alac pcm_mulaw pcm_alaw pcm_s16le pcm_s16be pcm_f32le mp3 aac ac3 eac3 dca mlp truehd opus vorbis)

# Create softlink to ffmpeg
ln -sf "${FFMPEG_PATH}" "${FFMPEG_MOD_PATH}/jni/ffmpeg"

cd "${FFMPEG_MOD_PATH}/jni"

# ---------------------------------------------
# MINIMAL ADDITION: BUILD FOR ANDROID ABI
# ---------------------------------------------

ABI=arm64-v8a
API=21

export TOOLCHAIN=$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64
export CC=$TOOLCHAIN/bin/aarch64-linux-android$API-clang
export CXX=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++

OUT_DIR=ffmpeg/android-libs/$ABI
mkdir -p $OUT_DIR

cd ffmpeg

./configure \
    --prefix=$OUT_DIR \
    --target-os=android \
    --arch=aarch64 \
    --cpu=armv8-a \
    --cc=$CC \
    --cxx=$CXX \
    --enable-cross-compile \
    --disable-static \
    --enable-shared \
    --disable-programs \
    --disable-doc \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-swresample \
    --enable-swscale \
    $(printf -- "--enable-decoder=%s " "${ENABLED_DECODERS[@]}")

make -j$(nproc)
make install
