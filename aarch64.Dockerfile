# Setup qemu
FROM alpine AS qemu

#QEMU download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

# setup environment variables (ARG for settings can be changed at buildtime with --build-arg <varname>=<value>
ARG TARGET_ARCH=arm64
ARG FLAVOR=builder
ARG FLAVOR_VERSION=eloquent
ARG DOCKERHUB_USERNAME=ros2cuisine
ARG DOCKERHUB_HOST=https://hub.docker.com
ARG USERNAME=cuisine
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG TAG=latest

FROM ${DOCKERHUB_USERNAME}}/${FLAVOR}}:${FLAVOR_VERSION}-${TARGET_ARCH}-${TAG}

COPY --from=qemu qemu-aarch64-static /usr/bin

ENV NEWBUILD 0
ENV DEBIAN_FRONTEND noninteractive

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && mkdir -p /home/$USERNAME/.vscode-server /home/$USERNAME/.vscode-server-insiders \
    && chown ${USER_UID}:${USER_GID} /home/$USERNAME/.vscode-server* \
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
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
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
# USER $USERNAME

COPY eloquent-docker.config.json ~/.docker/config.json

ENTRYPOINT [ "ros2_ws/install/ros_entrypoint.sh" ]
# Setup CMD
CMD ["bash" "-c" "/opt/ros/$ROS_DISTRO/setup.bash"]

LABEL org.label-schema.name="${DOCKERHUB_USERNAME}/vsc-master:${ROS_DISTRO}-${ARCH}" \
      org.label-schema.description="The Minimal build image for cuisine Docker images" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="${DOCKERHUB_HOST}/${DOCKERHUB_USERNAME}/vsc-master" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1" \
      org.label-schema.maintainer="cuisine-dev@ichbestimmtnicht.de" \
      org.label-schema.url="https://github.com/${DOCKERHUB_USERNAME}/vsc-master-release/" \
      org.label-schema.vendor="ichbestimmtnicht" \
      org.label-schema.version=$BUILD_VERSION \
      org.label-schema.docker.cmd="docker run -d ros2cuisine/vsc-master"

# Instructions to a child image build
ONBUILD RUN rm -rf /etc/apt/apt.conf.d/01proxy \
    && rm -rf /var/lib/apt/lists/*