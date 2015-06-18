#!/usr/bin/env bash

# ================================================= LOG File =======================================================

# Our log file locations
LOG_FILE_CORE="./logs/log-stream-core.log"
LOG_FILE_FFMPEG="./logs/log-stream-ffmpeg.log"
# Check for the directory
mkdir -p "./logs/"
# Clear log files if they are there
rm -f $LOG_FILE_CORE
rm -f $LOG_FILE_FFMPEG

# ================================================ OPTIONS =====================================================

# Console info
echo "" 2>&1 | tee -a $LOG_FILE_CORE
echo "[Config] - Starting config configuration." 2>&1 | tee -a $LOG_FILE_CORE

# Find script name
SCRIPT_NAME=${0##*/}

# Find stream key
if [ -f ~/twitch-stream.config ]; then
  echo "[Config] - Using global stream configuration" 2>&1 | tee -a $LOG_FILE_CORE
  . ~/twitch-stream.config
else
  if [ -f ./configs/twitch-stream.config ]; then
    echo "[Config] - Using local stream configuration" 2>&1 | tee -a $LOG_FILE_CORE
    . ./configs/twitch-stream.config
  else
    echo "[Config] - Could not locate twitch-stream.config" 2>&1 | tee -a $LOG_FILE_CORE
    exit 1
  fi
fi

# ================================================= CHECKS =====================================================


# Check for webcam
if [ -z "$WEBCAM" ]; then
	echo "[Config] - Your webcam is mis-configured" 2>&1 | tee -a $LOG_FILE_CORE
  echo "[Config] - Please fix before starting" 2>&1 | tee -a $LOG_FILE_CORE
  exit 1
fi

# Check for webcam dimensions
if [ -z "$WEBCAM_WH" ]; then
  WEBCAM_WH="1280x720"
fi

# Check that our suppress is defined
if [ -z "$SUPPRESS_OUTPUT" ]; then
     SUPPRESS_OUTPUT=false
fi

# Suppress output for security purpose
if [ $SUPPRESS_OUTPUT = true ]; then
  LOGLEVEL_ARG="-loglevel 0"
else
  LOGLEVEL_ARG=""
fi

# Check output, default to 720p
if [ -z "$OUTRES" ]; then
  OUTRES="1280x720"
fi

# Check fps
if [ -z "$FPS" ]; then
  FPS="30"
  GOP="60"
  GOPMIN="30"
else
  GOP=$(($FPS*2))
  GOPMIN=$FPS
fi

# Check threads, default to threads
if [ -z "$THREADS" ]; then
  THREADS="4"
fi

# Check for quality setting
if [ -z "$QUALITY" ]; then
  QUALITY="fast"
fi

# Check the bitrate setting
if [ -z "$CBR" ]; then
  CBR="1000k"
fi

# Check the audio rate
if [ -z "$AUDIO_RATE" ]; then
  AUDIO_RATE="44100"
fi

# Check for rmtp server
if [ -z "$STREAM_RMTP" ]; then
  echo "[Config] - Rmtp server not set" 2>&1 | tee -a $LOG_FILE_CORE
  echo "[Config] - Aborting." 2>&1 | tee -a $LOG_FILE_CORE
  exit 1
else
  DOMAIN="$(echo $STREAM_RMTP | awk -F/ '{print $3}')"
fi

# Console info
echo "[Config] - Config Checks Done" 2>&1 | tee -a $LOG_FILE_CORE


# ================================================= DEBUG ======================================================


echo "" 2>&1 | tee -a $LOG_FILE_CORE
echo "================================" 2>&1 | tee -a $LOG_FILE_CORE
echo "Starting stream" 2>&1 | tee -a $LOG_FILE_CORE
echo "================================" 2>&1 | tee -a $LOG_FILE_CORE
echo "Path:     $FFMPEG_PATH" 2>&1 | tee -a $LOG_FILE_CORE
echo "Rmtp:     $DOMAIN"  2>&1 | tee -a $LOG_FILE_CORE
echo "FPS:      $FPS" 2>&1 | tee -a $LOG_FILE_CORE
echo "Webcam:   $WEBCAM" 2>&1 | tee -a $LOG_FILE_CORE
echo "WRatio:   $WEBCAM_WH" 2>&1 | tee -a $LOG_FILE_CORE
echo "ORatio:   $OUTRES" 2>&1 | tee -a $LOG_FILE_CORE
echo "CBR:      $CBR" 2>&1 | tee -a $LOG_FILE_CORE
echo "BUFFER:   $BUFFER" 2>&1 | tee -a $LOG_FILE_CORE
echo "Quality:  $QUALITY" 2>&1 | tee -a $LOG_FILE_CORE
echo "Audio:    $AUDIO_RATE" 2>&1 | tee -a $LOG_FILE_CORE
echo "Threads:  $THREADS" 2>&1 | tee -a $LOG_FILE_CORE
echo "Script:   $SCRIPT_NAME" 2>&1 | tee -a $LOG_FILE_CORE
echo "================================" 2>&1 | tee -a $LOG_FILE_CORE
echo "" 2>&1 | tee -a $LOG_FILE_CORE

# ================================================= CODE ========================================================

# Set the FFREPORT environment variable so ffmpeg output the file
# in the log location that we want
export "FFREPORT=file=$LOG_FILE_FFMPEG:level=32"

# Call our stream function
$FFMPEG_PATH -threads $THREADS \
-report \
-f alsa -i default \
-f video4linux2 -i $WEBCAM -s $OUTRES \
-vcodec libx264 -pix_fmt yuv420p -vb "$CBR" -preset $QUALITY \
-acodec libfaac -ac 2 -ar $AUDIO_RATE -ab 192k \
-f flv -framerate $FPS -strict normal -minrate $CBR -maxrate $CBR -bufsize $BUFFER -crf $CRF -force_key_frames "expr:gte(t,n_forced*$KEY_FRAME)" \
$LOGLEVEL_ARG $STREAM_RMTP


# Define the threads
# $FFMPEG_PATH -threads $THREADS \
# Tell ffmpeg to output a report
# -report \
# Use the linux audio manager, to select the default device
# -f alsa -i default \
# Get our webcam and define its ratio
# -f video4linux2 -i $WEBCAM -s $OUTRES  \
# Set our video codec, bitrate, and encoding type
# -vcodec libx264 -pix_fmt yuv420p -vb "$CBR" -preset $QUALITY \
# Set our audio codec and rate
# -acodec libfaac -ac 2 -ar $AUDIO_RATE -ab 192k \
# Define our output type, frametime, constant bitrate, quality setting, keyframe number (needed for twitch to be 2)
# -f flv -framerate $FPS -strict normal -minrate $CBR -maxrate $CBR -bufsize $BUFFER -crf $CRF -force_key_frames "expr:gte(t,n_forced*$KEY_FRAME)" \
# Define log level, and the final output rmtp stream
# $LOGLEVEL_ARG $STREAM_RMTP