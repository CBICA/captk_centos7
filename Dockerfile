FROM centos:7

LABEL authors="CBICA_UPenn (software@cbica.upenn.edu)"

#update
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
    xorg-x11-apps 

# enable the Developer Toolset 6
RUN scl enable devtoolset-6 bash

# LFS install
RUN yum install -y epel-release git; \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash; \
    yum install git-lfs; \
    git lfs install \
    export GIT_LFS_SKIP_SMUDGE=1

# clone CaPTk and LFS files
RUN git clone https://github.com/CBICA/CaPTk.git \
    git lfs pull --include "binaries/precompiledApps/linux.zip" \
    git lfs pull --include "binaries/qt_5.12.1/linux.zip"

ENTRYPOINT [ "/bin/bash" ]