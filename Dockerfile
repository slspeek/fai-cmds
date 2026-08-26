FROM debian:trixie-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

ENV FAI_VERSION=6.6

# Install FAI build dependencies, git, and required tools
RUN apt-get update && apt-get install -y extrepo && apt-get clean
RUN extrepo enable fai
RUN apt-get update && apt-get install -y \
    fai-client=${FAI_VERSION} \
    fai-server=${FAI_VERSION} \
    reprepro \
    squashfs-tools \
    libgraph-perl \
    xorriso \
    sudo \
    make \
    && apt-get clean

# Set the working directory to the repo so scripts can be called easily
WORKDIR /opt/fai-cmds

# Default command opens a bash shell inside the build environment
CMD ["/bin/bash"]