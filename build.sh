#!/bin/bash

export ANDROID_NDK_PATH=$ANDROID_HOME/ndk/28.0.13004108

[[ ! -d "$ANDROID_NDK_PATH" ]] && echo "No NDK found, quitting…" && exit 1

# Setup environment
export ANDROIDX_MEDIA_ROOT="${PWD}/media"
export FFMPEG_MOD_PATH="${ANDROIDX_MEDIA_ROOT}/libraries/decoder_ffmpeg/src/main"
export FFMPEG_PATH="${PWD}/ffmpeg"
export ENABLED_DECODERS=(vorbis opus flac alac pcm_mulaw pcm_alaw mp3 amrnb amrwb aac ac3 eac3 dca mlp truehd)

# Create softlink to ffmpeg
ln -sf "${FFMPEG_PATH}" "${FFMPEG_MOD_PATH}/jni/ffmpeg"

# Start build
cd "${FFMPEG_MOD_PATH}/jni"
./build_ffmpeg.sh "${FFMPEG_MOD_PATH}" "${ANDROID_NDK_PATH}" "linux-x86_64" 21 "${ENABLED_DECODERS[@]}"
