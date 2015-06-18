#! /bin/bash 

# User help message
echo "Please ensure that the usb camera is connected"
read -r -p "Press enter to continue..." key

# Make sure git is installed
sudo apt-get install git
# Install ffmpeg dependencies
sudo apt-get install x11-utils pulseaudio-utils libfaac-dev libmp3lame-dev libv4l-dev libx264-dev libpulse-dev librtmp-dev libasound2-dev X11proto-xext-dev libxext-dev
# Install the assembler
sudo apt-get install yasm

# We are building ffmpeg from source
# Clone the git repo
git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg

# Go into
cd ffmpeg 

# Configure with needed options enabled
./configure --disable-ffplay --disable-ffprobe --disable-ffserver --enable-libfaac --enable-libmp3lame --enable-libv4l2 --enable-libx264 --enable-x11grab --enable-libpulse --enable-librtmp --enable-gpl --enable-nonfree --disable-yasm  --extra-libs="-lasound" && make

# Make ffmpeg
make

# Install
sudo make install

# Cd out
cd ..

# Show the user avablible video sources
echo "==================================="
echo "=      Avablible video feeds      ="
echo "==================================="

# Print out the current video sources
ls /dev/video*

# Add some padding for easy reading
echo ""
echo ""