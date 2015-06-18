# Raspi-Streaming

This small script set allows for streaming of twitch through the use of ffmpeg. The install script can be used to install the needed packaged. Currently the system has been tested on Ubuntu 14.04 but the plan is to ensure that the scripts can work on the raspberry pi. The goal is to allow for a simple usb camera to be plugged in, and stream to an external rmtp server.

Check the install script for the needed dependencies. Check the config files located in the `/configs/` folder for documentation on information needed. Logs will be output to the `/logs/` folder for hand inspection. The `/ffmpeg/` folder is where the ffmpeg package is compiled from source to ensure that the latest changes are included.