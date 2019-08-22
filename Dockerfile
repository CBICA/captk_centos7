FROM scratch
ADD centos-7-docker.tar.xz /

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.name="CentOS Base Image" \
    org.label-schema.vendor="CentOS" \
    org.label-schema.license="GPLv2" \
    org.label-schema.build-date="20181204"

CMD ["/bin/bash"]

LABEL authors="CBICA_UPenn (software@cbica.upenn.edu)"

#update
RUN yum update -y

RUN yum install centos-release-scl-rh

#general dependencies
RUN yum install -y \
    devtoolset-6 \
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
    wget

# enable the Developer Toolset 6
RUN scl enable devtoolset-6 bash