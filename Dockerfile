# setup environment variables (ARG for settings can be changed at buildtime with --build-arg <varname>=<value>
ARG TARGET_ARCH=amd64
ARG FLAVOR=builder
ARG FLAVOR_VERSION=eloquent
ARG DOCKERHUB_USERNAME=ros2cuisine
ARG DOCKERHUB_HOST=https://hub.docker.com
ARG TAG=latest

FROM ${DOCKERHUB_USERNAME}/${FLAVOR}:${FLAVOR_VERSION}-${TARGET_ARCH}-${TAG}

ENV NEWBUILD 0
ENV DEBIAN_FRONTEND noninteractive

RUN groupadd --gid 1000 cuisine \
    && useradd --uid USER_UID --gid 1000 -m cuisine \
    && mkdir -p /home/cuisine/.vscode-server /home/cuisine/.vscode-server-insiders \
    && chown 1000:1000 /home/cuisine/.vscode-server* \
    # Update Packages
    && apt-get update \
    && apt-get upgrade -y -q \
    && echo ${TAG} \
    && echo $TAG \
    && apt-get install -y -q \
        sudo \
        # Robot
        ros-${ROS_DISTRO}-urdf \
        ros-${ROS_DISTRO}-robot-state-publisher \
        # Messages
        ros-${ROS_DISTRO}-gazebo-msgs \
        # Moved from Dev Setup for faster tests
        ros-${ROS_DISTRO}-desktop \
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
        # git
        git-all \
        # Key Handling
        wget \
        curl \
        gnupg2 \
        lsb-release \
        # Install Doxygen
        doxygen \
        # Lint
        exuberant-ctags \
    # Configure sudo
    && echo cuisine ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/cuisine \
    && chmod 0440 /etc/sudoers.d/cuisine \
    # Install keys
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - \
    && wget http://packages.osrfoundation.org/gazebo.key \
    && apt-key add gazebo.key \
    && apt-get update -q \
    && apt-get upgrade -y -q \
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
    # Preparing the docker config folder
    && mkdir -p ~/.docker

COPY eloquent-docker.config.json ~/.docker/config.json

# Setting User
# USER cuisine

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
ONBUILD RUN rm -rf /var/lib/apt/lists/*
