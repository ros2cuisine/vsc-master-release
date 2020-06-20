# Set environment variables
ARG SRC_REPO
ARG SRC_TAG
ARG SRC_NAME

# Setup qemu
FROM alpine AS qemu

#QEMU Download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

ARG SRC_NAME
ARG SRC_REPO
ARG SRC_TAG

# Pull the image
FROM ${SRC_NAME}/${SRC_REPO}:${SRC_TAG} as bundle

COPY --from=qemu qemu-arm-static /usr/bin

# Update Package Info
RUN apt-get update \
    && apt-get install -y -q \
        sudo \
        nano \
        # Doxygen Requirments
        bison \
        flex \
        # Releasing
        python3-catkin-pkg \
        # Key Handling
        wget \
        curl \
        gnupg2 \
        lsb-release \
        # Install Doxygen
        doxygen \
        python3-pip \
        # ROS2 
        ros-${ROS_DISTRO}-desktop \
    && rm -rf /var/lib/apt/lists/* \
    # Install Python3 Packages
    && pip3 install -U \
        # Lint
        pylint \
        # Documentation
        # Doxygen
        breathe \
        # Sphinx
        sphinx \
        sphinx-autobuild \
        sphinx_rtd_theme \
        doc8 \
    && rm -rf /var/lib/apt/lists/* \
    # Prepare docker config folder
    && mkdir -p ~/.docker

# Setting User
USER $USERNAME
