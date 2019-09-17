FROM dockbuild/centos7-devtoolset4-gcc5:latest

LABEL authors="CBICA_UPenn <software@cbica.upenn.edu>"

ARG IMAGE
ENV DEFAULT_DOCKCROSS_IMAGE=${IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ADD qt-installer-noninteractive.qs /usr/src/qt-installer-noninteractive.qs

#update
RUN yum -y update bash

RUN yum update -y

# qt installation
RUN \
  #
  # Qt dependencies:
  #
  # * https://doc.qt.io/qt-5/linux-requirements.html
  # * https://doc.qt.io/qt-5/supported-platforms-and-configurations.html#qt-5-11
  #
  # IMPORTANT:
  #
  # * dependencies of Qt5MultimediaGstTools are not installed. These are
  #   "gstreamer1-plugins-good" and "gstreamer1-plugins-base" along with
  #   all video and image codecs.
  #
  yum install -y \
    flex \
    fontconfig \
    freetype \
    glib2 \
    libICE \
    libX11 \
    libxcb \
    libXext \
    libXi \
    libXrender \
    libSM \
    libXt-devel \
    libGLU-devel \
    mesa-libOSMesa-devel \
    mesa-libGL-devel \
    mesa-libGLU-devel \
    xcb-util-keysyms \
    xcb-util-image \
  && \
  #
  # libQt5WebEngineCore
  # * alsa-lib provides libasound.so.2
  yum install -y \
    alsa-lib \
    libXcomposite \
    libXcursor \
    libXrandr \
    libXtst \
    mesa-libEGL \
  && \
  #
  # libQt5Multimedia
  # * pulseaudio-libs-glib2 provides libpulse-mainloop-glib.so.0
  # * pulseaudio-libs provides libpulse.so.0
  #
  yum install -y \
    pulseaudio-libs \
    pulseaudio-libs-glib2 \
  && \
  #
  # Slicer dependencies
  #
  yum install -y \
    subversion \
  && \
  #
  # SlicerJupyter dependencies
  #
  yum install -y \
    libuuid-devel \
  && \
  #
  # Download and install Qt
  #
  cd /usr/src && \
  curl -LO http://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run && \
  chmod u+x qt-unified-linux-x64-online.run && \
  ./qt-unified-linux-x64-online.run --verbose --platform minimal --script ./qt-installer-noninteractive.qs && \
  rm -f qt-installer-noninteractive.qs qt-unified-linux-x64-online.run && \
  #
  # Cleanup
  #
  find /opt/qt -maxdepth 1 -type f -exec rm -rf "{}" \; && \
  find /opt/qt -type f -name "*.debug" -delete && \
  find /opt/qt/5.11.2/gcc_64/bin -type f -executable -exec strip {} \; && \
  rm -rf \
    /opt/qt/dist \
    /opt/qt/Docs \
    /opt/qt/Examples \
    /opt/qt/Tools \
  && \
  #
  # Cleanup
  #
  yum clean all
  
# # taken from https://github.com/sclorg/devtoolset-container/blob/master/6-toolchain/Dockerfile
# RUN yum install -y centos-release-scl-rh wget && \
#     INSTALL_PKGS="devtoolset-6-gcc devtoolset-6-gcc-c++ devtoolset-6-gcc-gfortran devtoolset-6-gdb devtoolset-6-toolchain" && \
#     yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
#     rpm -V $INSTALL_PKGS && \
#     yum -y clean all --enablerepo='*'

RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum -y install centos-release-scl

# cmake installation
# RUN wget https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.tar.gz; \
#     tar -xf cmake-3.12.4-Linux-x86_64.tar.gz; \

# ENV HOME=/opt/app-root/src \
#     PATH=/opt/app-root/src/bin:/opt/app-root/bin:/opt/rh/devtoolset-4/root/usr/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#general dependencies
RUN yum install -y \
    sudo \
    #devtoolset-4 \
    #devtoolset-4-gcc* \
    # gcc \
    # gcc-c++ \
    make \
    yum-utils \
    wget \
    git-core \
    lapack \
    lapack-devel \
    unzip \
    tcl \
    tcl-devel \
    tk \
    tk-devel \
    fftw \
    fftw-devel \
    mpich \
    mpich-devel \
    mesa-libGL \
    mesa-libGL-devel \
    xorg-x11-server-Xorg \
    xorg-x11-xauth \
    xorg-x11-apps \
    libXt-devel \
    tcl \
    time \
    libmpc-devel \
    mpfr-devel \
    gmp-devel \
    doxygen

# installing CMake
RUN wget https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.sh; \
    mkdir /opt/cmake; \
    sh cmake-3.12.4-Linux-x86_64.sh --prefix=/opt/cmake --skip-license; \
    ln -s /opt/cmake/bin/cmake /usr/bin/cmake

# setting up the build environment
ARG GIT_LFS_SKIP_SMUDGE=1
ARG PKG_FAST_MODE=1
ARG PKG_COPY_QT_LIBS=1
ENV GIT_LFS_SKIP_SMUDGE=$GIT_LFS_SKIP_SMUDGE
ENV PKG_FAST_MODE=$PKG_FAST_MODE
ENV PKG_COPY_QT_LIBS=$PKG_COPY_QT_LIBS

# cloning CaPTk
RUN if [ ! -d "`pwd`/CaPTk" ] ; then git clone "https://github.com/CBICA/CaPTk.git"; fi 
RUN cd CaPTk &&  git pull; \
    git submodule update --init && mkdir bin

RUN cd CaPTk/bin && echo "=== Starting CaPTk Superbuild ===" && \
    if [ ! -d "`pwd`/externalApps" ] ; then wget https://github.com/CBICA/CaPTk/raw/master/binaries/precompiledApps/linux.zip -O binaries_linux.zip; fi ; \
    if [ ! -d "`pwd`/qt" ] ; then wget https://github.com/CBICA/CaPTk/raw/master/binaries/qt_5.12.1/linux.zip -O qt.zip; fi ; \
    cmake -DCMAKE_INSTALL_PREFIX=./install_libs -DQT_DOWNLOAD_FORCE=OFF -Wno-dev .. && make -j2

## trying to install using https://gist.github.com/craigminihan/b23c06afd9073ec32e0c
#RUN curl ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.bz2 -O ;\
#    tar xvfj gcc-4.9.2.tar.bz2; \
#    cd gcc-4.9.2; \
#    ./configure --disable-multilib --enable-languages=c,c++; \
#    make -j2; \
#    make install

# LFS install
# RUN yum install -y epel-release git; \
#     curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash; \
#     yum install -y git-lfs; \
#     git lfs install
    # echo 'export GIT_LFS_SKIP_SMUDGE=1' >> ~/.bashrc

# ENV GIT_LFS_SKIP_SMUDGE=1

# RUN time git clone https://github.com/CBICA/CaPTk.git --depth 1;\
#     cd CaPTk; \
#     time git lfs pull --include "binaries/precompiledApps/linux.zip"; \
#     time git lfs pull --include "binaries/precompiledApps/linux.zip"
    
# download relevant files
# RUN time wget https://github.com/CBICA/CaPTk/raw/master/binaries/precompiledApps/linux.zip -O binaries_linux.zip

# RUN time wget https://github.com/CBICA/CaPTk/raw/master/binaries/qt_5.12.1/linux.zip -O qt.zip

# ensuring azure requirements are met: : https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops&tabs=yaml#linux-based-containers
# # apparently, this messes up azure
# ENTRYPOINT [ "/bin/bash" ]

# nodejs is needed for azure
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash; \
    #curl -sL https://rpm.nodesource.com/setup_12.x | sudo -E bash -; \
    curl -sL https://rpm.nodesource.com/setup | bash -; \
    yum install -y nodejs
    #curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash; \
    #nvm install -y node; \

ENV NVM_DIR="$HOME/.nvm"

# # tests
# RUN cmake --version; \
#     gcc --version; \
#     g++ --version; \
#     node -v; \
#     npm -v