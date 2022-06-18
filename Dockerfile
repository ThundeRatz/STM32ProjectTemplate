FROM ubuntu:20.04

# Change the default shell to Bash
SHELL [ "/bin/bash" , "-c" ]

# Instalations
RUN apt-get update && apt-get install -y \
    apt-utils \
    git \
    gcc \
    build-essential \
    make \
    wget \
    curl \
    zip \
    unzip \
    libusb-1.0-0-dev

RUN apt-get install openjdk-8-jre-headless -y
# RUN update-alternatives --config java

# RUN apt-get purge openjfx && \
#     apt-get install \
#     openjfx=8u161-b12-1ubuntu2 \
#     libopenjfx-jni=8u161-b12-1ubuntu2 \
#     libopenjfx-java=8u161-b12-1ubuntu2

RUN apt-mark hold openjfx libopenjfx-jni libopenjfx-java

WORKDIR /tmp

# arm_gcc
RUN mkdir arm_gcc && cd arm_gcc && \
    # link ->  https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2?revision=108bd959-44bd-4619-9c19-26187abf5225&la=en&hash=E788CE92E5DFD64B2A8C246BBA91A249CB8E2D2D \
    curl -O https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2 && \
    tar -xf gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2
    # echo  export PATH=$PATH:${pwd}/gcc-arm-none-eabi-9-2019-q4-major/bin'

ENV PATH PATH$:/tmp/arm_gcc/gcc-arm-none-eabi-9-2019-q4-major/bin

# stm 32 mx
RUN cd ~ && mkdir stm_cube_mx && cd stm_cube_mx && \
    curl -O https://sw-center.st.com/packs/resource/library/stm32cube_mx_v650-lin.zip && \
    unzip stm32cube_mx_v650-lin.zip && \
    chmod 777 SetupSTM32CubeMX-6.5.0.linux

RUN ./SetupSTM32CubeMX-6.5.0.linux

ENV CUBE_PATH ~/stm_cube_mx/STM32CubeMX

# stm 32 programmer
RUN cd ~ && mkdir stm_cube_programmer && cd stm_cube_programmer && \
    curl -O https://www.st.com/content/ccc/resource/technical/software/utility/group0/2b/58/90/97/ad/a1/46/10/stm32cubeprg-lin_v2-10-0/files/stm32cubeprg-lin_v2-10-0.zip/jcr:content/translations/en.stm32cubeprg-lin_v2-10-0.zip && \
    unzip stm32cubeprg-lin_v2-10-0.zip

RUN ./SetupSTM32CubeProgrammer-2.10.0.linux && cd STM32CubeProgrammer/Driver/rules && cp *.* /etc/udev/rules.d

ENV PATH PATH$:~/stm_cube_programmer/STM32CubeProgrammer/bin

# RUN unzip en.stm32cubemx.zip && /tmp/SetupSTM32CubeMX-5.3.0.linux auto-install.xml
