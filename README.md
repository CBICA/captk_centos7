# captk_centos7

<p align="center">
    <a href="https://hub.docker.com/r/cbica/captk_centos7/builds" alt="Automated"><img src="https://dev.azure.com/CBICA/captk_centos7/_apis/build/status/CBICA.captk_centos7?branchName=master" /></a>
</p>

This docker image is used as the base to compile CaPTk on via Azure DevOps. This is being done to work around GLIBC issues.

The image contains the full superbuild required to build CaPTk; for a detailed description of the options and libraries, please see the following file: https://github.com/CBICA/CaPTk/blob/master/cmake_modules/Superbuild.cmake

For more information, please contact <a href="mailto:software@cbica.upenn.edu">CBICA Software</a>.
