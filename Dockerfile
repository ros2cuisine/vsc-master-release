# Dummy Dockerfile because hooks aren't working with a custom Filename
# Have a look into the hooks folder to see them per arch
# https://gitlab.com/ros2cuisine/templates/vsc-master/tree/master/hooks/

# setup environment variables (ARG for settings can be changed at buildtime with --build-arg <varname>=<value>
ARG SRC_NAME
ARG SRC_REPO
ARG SRC_TAG

# Pull the image
FROM ${SRC_NAME}/${SRC_REPO}:${SRC_TAG} as bundle


ADD https://github.com/estesp/manifest-tool/releases/download/v1.0.0/manifest-tool-linux-amd64 /bin/manifest-tool

RUN chmod +x /bin/manifest-tool \
    # Setting User
    && groupadd --gid 1000 cuisine \
    && useradd --uid 1000 --gid 1000 -m cuisine \
    && mkdir -p /home/cuisine/.vscode-server /home/cuisine/.vscode-server-insiders \
    && chown 1000:1000 /home/cuisine/.vscode-server* \
    # Update Packages
    && apt-get update \
    && apt-get install -y -q \
        sudo \
        nano \
        # Doxygen Requirments
        bison \
        flex \
        # Releasing
        python3-catkin-pkg \
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
        python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    # Prepare docker config folder
    && mkdir -p ~/.docker \
    # Configure sudo
    && echo cuisine ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/cuisine \
    && chmod 0440 /etc/sudoers.d/cuisine \
    # Install keys
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - \
    && wget http://packages.osrfoundation.org/gazebo.key \
    && apt-key add gazebo.key \
    && apt-get upgrade -y -q \
    && apt-get autoremove --purge -y -q \
    && apt-get autoclean -y -q \
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

# Setting User
USER cuisine

# Instructions to a child image build
#ONBUILD RUN rm -rf /var/lib/apt/lists/*
