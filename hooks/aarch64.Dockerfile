# Set environment variables
ARG ROS_DISTRO
ARG SRC_NAME
ARG SRC_REPO
ARG SRC_TAG

# Setup qemu
FROM alpine AS qemu

#QEMU download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

ARG SRC_NAME
ARG SRC_REPO
ARG SRC_TAG

# Pull the image
FROM ${SRC_NAME}/${SRC_REPO}:${SRC_TAG} as bundle

COPY --from=qemu qemu-aarch64-static /usr/bin

ARG ROS_DISTRO

# These are avaivable in the build image
ENV ROS_DISTRO ${ROS_DISTRO}
ENV DEBIAN_FRONTEND noninteractive

ADD https://github.com/estesp/manifest-tool/releases/download/v1.0.0/manifest-tool-linux-arm64 /bin/manifest-tool

RUN chmod +x /bin/manifest-tool \
    # Add cuisine user
    && groupadd --gid 1000 cuisine \
    && useradd --uid 1000 --gid 1000 -m cuisine \
    && mkdir -p /home/cuisine/.vscode-server /home/cuisine/.vscode-server-insiders \
    && chown 1000:1000 /home/cuisine/.vscode-server* \
    # Update Packages
    && apt-get update \
    && apt-get upgrade -y -q \
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
        exuberant-ctags\
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

# Setting User
USER cuisine

#ADD https://raw.githubusercontent.com/ros2cuisine/vsc-master-release/master/eloquent-docker.config.json ~/.docker/config.json

ENTRYPOINT [ "/ros_entrypoint.sh" ]

# Setup CMD
CMD ["bash" "-c" "/ros_entrypoint.sh"]
