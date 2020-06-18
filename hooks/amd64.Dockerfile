# setup environment variables (ARG for settings can be changed at buildtime with --build-arg <varname>=<value>
ARG SRC_NAME
ARG SRC_REPO
ARG SRC_TAG

# Pull the image
FROM ${SRC_NAME}/${SRC_REPO}:${SRC_TAG} as bundle

ADD https://github.com/estesp/manifest-tool/releases/download/v1.0.0/manifest-tool-linux-amd64 /bin/manifest-tool

RUN chmod +x /bin/manifest-tool \
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
