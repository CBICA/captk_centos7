FROM centos:7

LABEL authors="CBICA_UPenn <software@cbica.upenn.edu>"

#update
RUN yum -y update bash

RUN yum update -y

# RUN yum update -y scl-utils

# taken from https://github.com/sclorg/devtoolset-container/blob/master/6-toolchain/Dockerfile
RUN yum install -y centos-release-scl-rh wget && \
    INSTALL_PKGS="devtoolset-6-gcc devtoolset-6-gcc-c++ devtoolset-6-gcc-gfortran devtoolset-6-gdb" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'

# Copy extra files to the image.
# COPY ./root/ /


RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum -y install centos-release-scl

# RUN touch '~/.bashrc'

# cmake installation
RUN wget https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.tar.gz; \
    tar -xf cmake-3.12.4-Linux-x86_64.tar.gz; \
    echo 'export PATH=`pwd`/cmake-3.12.4-Linux-x86_64/bin/:$PATH' >> ~/.bashrc

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/opt/rh/devtoolset-6/root/usr/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:`pwd`/cmake-3.12.4-Linux-x86_64/bin/     

# dev toolset 6
RUN curl http://linuxsoft.cern.ch/cern/scl/slc6-scl.repo > /etc/yum.repos.d/slc6-scl.repo; \
    rpm --import http://ftp.mirrorservice.org/sites/ftp.scientificlinux.org/linux/scientific/obsolete/51/i386/RPM-GPG-KEYs/RPM-GPG-KEY-cern; \
    yum install -y devtoolset-6 \
    devtoolset-6-gcc \
    devtoolset-6-gcc-c++ \
    devtoolset-6-toolchain; \
    scl enable devtoolset-6 bash; \
    gcc --version; \
    g++ --version
    # echo 'scl enable devtoolset-6 bash' >> ~/.bashrc
    # printf "#! /bin/bash\n\nscl enable devtoolset-6 bash\n" > /etc/profile.d/enabldevtoolset-6.sh; \
  	# chmod +x /etc/profile.d/enabldevtoolset-6.sh

#general dependencies
RUN yum install -y \
    sudo \
    #devtoolset-6 \
    #devtoolset-6-gcc* \
    # gcc \
    # gcc-c++ \
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
    time \
    libmpc-devel \
    mpfr-devel \
    gmp-devel

## trying to install using https://gist.github.com/craigminihan/b23c06afd9073ec32e0c
#RUN curl ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.bz2 -O ;\
#    tar xvfj gcc-4.9.2.tar.bz2; \
#    cd gcc-4.9.2; \
#    ./configure --disable-multilib --enable-languages=c,c++; \
#    make -j2; \
#    make install

# LFS install
RUN yum install -y epel-release git; \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash; \
    yum install -y git-lfs; \
    git lfs install
    # echo 'export GIT_LFS_SKIP_SMUDGE=1' >> ~/.bashrc

ENV GIT_LFS_SKIP_SMUDGE=1

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
    curl -sL https://rpm.nodesource.com/setup_12.x | sudo -E bash -; \
    yum install -y nodejs
    #curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash; \
    #nvm install -y node; \

# tests
RUN cmake --version; \
    gcc --version; \
    g++ --version