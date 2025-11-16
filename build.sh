#!/bin/bash

# Ensure NDK is available
export ANDROID_NDK_PATH=$ANDROID_HOME/ndk/28.0.13004108

[[ ! -d "$ANDROID_NDK_PATH" ]] && echo "No NDK found, quitting…" && exit 1

# Setup environment
export ANDROIDX_MEDIA_ROOT="${PWD}/media"
export FFMPEG_MOD_PATH="${ANDROIDX_MEDIA_ROOT}/libraries/decoder_ffmpeg/src/main"
export FFMPEG_PATH="${PWD}/ffmpeg"
export ENABLED_DECODERS=(flac alac pcm_mulaw pcm_alaw mp3 aac ac3 eac3 dca mlp truehd)

# Create softlink to ffmpeg
ln -sf "${FFMPEG_PATH}" "${FFMPEG_MOD_PATH}/jni/ffmpeg"

# Start build
cd "${FFMPEG_MOD_PATH}/jni"

# -------------------------------
# ADD THE ACTUAL FFMPEG BUILD HERE
# -------------------------------

# Build output
PREFIX=$(pwd)/ffmpeg-build

mkdir -p $PREFIX

# Configure FFmpeg with required decoders & demuxers
./ffmpeg/configure \
    --prefix=$PREFIX \
    --enable-shared \
    --disable-static \
    --disable-programs \
    --disable-doc \
    --disable-postproc \
    --disable-avdevice \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-swresample \
    --enable-swscale \
    --enable-decoder=flac \
    --enable-decoder=alac \
    --enable-decoder=pcm_mulaw \
    --enable-decoder=pcm_alaw \
    --enable-decoder=pcm_s16le \
    --enable-decoder=pcm_s16be \
    --enable-decoder=pcm_f32le \
    --enable-decoder=mp3 \
    --enable-decoder=aac \
    --enable-decoder=ac3 \
    --enable-decoder=eac3 \
    --enable-decoder=dca \
    --enable-decoder=mlp \
    --enable-decoder=truehd \
    --enable-decoder=opus \
    --enable-decoder=vorbis \
    --enable-decoder=h264 \
    --enable-decoder=hevc \
    --enable-decoder=mpeg4 \
    --enable-decoder=mpeg2video \
    --enable-decoder=vp8 \
    --enable-decoder=vp9 \
    --enable-demuxer=matroska \
    --enable-demuxer=mov \
    --enable-demuxer=mp3 \
    --enable-demuxer=wav \
    --enable-demuxer=ogg \
    --enable-demuxer=mpegts \
    --enable-demuxer=flv \
    --enable-demuxer=webm \
    --enable-demuxer=mp4 \
    --enable-parser=aac \
    --enable-parser=ac3 \
    --enable-parser=eac3 \
    --enable-parser=h264 \
    --enable-parser=hevc \
    --enable-parser=mpeg4video

# Build for host (Media3 JNI loads them)
make -j$(nproc)
make install
