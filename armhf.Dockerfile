# setup environment variables (ARG for settings can be changed at buildtime with --build-arg <varname>=<value>
ARG BUILD_ARCH=arm32v7
ARG FLAVOR_VERSION=eloquent
ARG DOCKERHUB_USERNAME=ros2cuisine
ARG DOCKERHUB_HOST="https://hub.docker.com"
ARG BUILD_TAG=staged
ARG BUILD_REPO=builder
# Setup qemu
FROM alpine AS qemu

#QEMU Download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM ${DOCKERHUB_USERNAME}/${BUILD_REPO}:${FLAVOR_VERSION}-${BUILD_ARCH}-${BUILD_TAG}

COPY --from=qemu qemu-arm-static /usr/bin

ENV NEWBUILD 0
ENV DEBIAN_FRONTEND noninteractive

RUN groupadd --gid 1000 cuisine \
    && useradd --uid 1000 --gid 1000 -m cuisine \
    && mkdir -p /home/cuisine/.vscode-server /home/cuisine/.vscode-server-insiders \
    && chown 1000:1000 /home/cuisine/.vscode-server* \
    # Update Packages
    && apt-get update \
    && apt-get upgrade -y -q \
    && echo ${BUILD_TAG} \
    && echo $BUILD_TAG \
    && apt-get install -y -q \
        sudo \
        # Robot
        ros-$ROS_DISTRO-urdf \
        ros-$ROS_DISTRO-robot-state-publisher \
        # Messages
        ros-$ROS_DISTRO-gazebo-msgs \
        # Moved from Dev Setup for faster tests
        ros-$ROS_DISTRO-desktop \
        gazebo9 \
        nano \
        # Doxygen Requirments
        bison \
        flex \
        # Releasing
        python-catkin-pkg \
        python-bloom \
        # ROS Devs
        ros-${ROS_DISTRO}-rosidl-default-generators \
        # Maybe outdated and not used anymoore
        ros-${ROS_DISTRO}-ament-cmake* \
        # Colcon Ros Bundle
        python3-apt \
        # Installing Docker Compose
        docker-compose \
        # Key Handling
        wget \
        curl \
        gnupg2 \
        lsb-release \
        # Install Doxygen
        doxygen \
        # Lint
        exuberant-cBUILD_tags \
    # Configure sudo
    && echo cuisine ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/cuisine \
    && chmod 0440 /etc/sudoers.d/cuisine \
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
        colcon-ros-bundle \
        faas-cli \
    && rm -rf /var/lib/apt/lists/* \
    # Prepare docker config folder
    && mkdir -p ~/.docker

ADD https://raw.githubusercontent.com/ros2cuisine/vsc-master/master/eloquent-docker.config.json ~/.docker/config.json

# Setting User
# USER $USERNAME

ENTRYPOINT [ "/ros_entrypoint.sh" ]

# Setup CMD
CMD ["bash" "-c" "/ros_entrypoint.sh"]
