#!/bin/bash

xhost +local:root; \
docker run -d \
-e DISPLAY=$DISPLAY \
-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
-v $PWD/shared:/mnt/host:rw \
cubemx:latest \
sh -c '/usr/local/STMicroelectronics/STM32Cube/STM32CubeMX/STM32CubeMX'
