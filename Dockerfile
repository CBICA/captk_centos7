FROM centos:7

LABEL authors="CBICA_UPenn (software@cbica.upenn.edu)"

#update
RUN yum -y update bash

RUN yum update -y

RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum -y install centos-release-scl

#general dependencies
RUN yum install -y \
    sudo \
    devtoolset-6 \
    yum-utils \
    wget \
    cmake \
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
    time

# enable the Developer Toolset 6
RUN scl enable devtoolset-6 bash

# LFS install
RUN yum install -y epel-release git; \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash; \
    yum install -y git-lfs; \
    git lfs install \
    export GIT_LFS_SKIP_SMUDGE=1

RUN yum install -y devtoolset-3-gcc-c++ \
    devtoolset-3-gcc

# RUN time git clone https://github.com/CBICA/CaPTk.git --depth 1;\
#     cd CaPTk; \
#     time git lfs pull --include "binaries/precompiledApps/linux.zip"; \
#     time git lfs pull --include "binaries/precompiledApps/linux.zip"
    
# download relevant files
RUN time wget https://github.com/CBICA/CaPTk/raw/master/binaries/precompiledApps/linux.zip -O binaries_linux.zip

RUN time wget https://github.com/CBICA/CaPTk/raw/master/binaries/qt_5.12.1/linux.zip -O qt.zip

# ensuring azure requirements are met: : https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops&tabs=yaml#linux-based-containers
# # apparently, this messes up azure
# ENTRYPOINT [ "/bin/bash" ]

# nodejs is needed for azure
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash; \
    curl -sL https://rpm.nodesource.com/setup_12.x | sudo -E bash -; \
    yum install -y nodejs
    #curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash; \
    #nvm install -y node; \

# cmake installation
RUN wget https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.tar.gz; \
    tar -xf cmake-3.12.4-Linux-x86_64.tar.gz; \
    export PATH=`pwd`/cmake-3.12.4-Linux-x86_64/bin/:$PATH

# testing cmake
RUN which cmake