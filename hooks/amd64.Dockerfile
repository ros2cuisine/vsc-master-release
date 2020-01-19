# setup environment variables (ARG for settings can be changed at buildtime with --build-arg <varname>=<value>
ARG ROS_DISTRO
ARG SRC_NAME
ARG SRC_REPO
ARG SRC_TAG

# Pull the image
FROM ${SRC_NAME}/${SRC_REPO}:${SRC_TAG} as bundle

ARG ROS_DISTRO

ENV ROS_DISTRO ${ROS_DISTRO}
ENV DEBIAN_FRONTEND noninteractive

ADD https://github.com/estesp/manifest-tool/releases/download/v1.0.0/manifest-tool-linux-amd64 /bin/manifest-tool

RUN chmod +x /bin/manifest-tool \
    # Setting User
    && groupadd --gid 1000 cuisine \
    && useradd --uid 1000 --gid 1000 -m cuisine \
    && mkdir -p /home/cuisine/.vscode-server /home/cuisine/.vscode-server-insiders \
    && chown 1000:1000 /home/cuisine/.vscode-server*

# Update Packages
RUN apt-get update \
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
        # for sphinx
        python-pip \
    && rm -rf /var/lib/apt/lists/*
    # Prepare docker config folder
    && mkdir -p ~/.docker

# Configure sudo
RUN echo cuisine ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/cuisine \
    && chmod 0440 /etc/sudoers.d/cuisine \
    # Install keys
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - \
    && wget http://packages.osrfoundation.org/gazebo.key \
    && apt-key add gazebo.key \
    && apt-get update -q \
    && apt-get upgrade -y -q \
    && apt-get autoremove --purge -y -q \
    && apt-get autoclean -y -q \
    && rm -rf /var/lib/apt/lists/*

# Install Python3 Packages
RUN pip3 install -U \
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
    # Sphinx
    && pip install -U \
        doc8 \
        sphinx \
        sphinx-autobuild \
    && rm -rf /var/lib/apt/lists/* \
    # Preparing the docker config folder
    && mkdir -p ~/.docker

# faas cli Setup
RUN cd \
    && curl -sSL https://cli.openfaas.com | sh \
    && sudo mv faas-cli /usr/local/bin/faas

# Setting User
USER cuisine

# Instructions to a child image build
#ONBUILD RUN rm -rf /var/lib/apt/lists/*
