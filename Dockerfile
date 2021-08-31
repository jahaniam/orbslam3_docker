FROM osrf/ros:melodic-desktop-full

RUN sudo apt update

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# avoid user interaction requests during installation
RUN DEBIAN_FRONTEND=noninteractive
RUN sudo apt update
RUN DEBIAN_FRONTEND=noninteractive apt-get install keyboard-configuration -y

# install nvidia drivers
RUN sudo apt update
RUN sudo apt install software-properties-common -y
RUN sudo add-apt-repository ppa:graphics-drivers 
RUN sudo apt install nvidia-driver-450 -y

# ======== Installing productivity tools ========
RUN apt-get install -y \
    sudo \
    vim \
    terminator \
    dbus \
    dbus-x11 \
    pcmanfm

# ======== Install extra stuff for IDE compatibility ========
RUN apt-get install -y \
    gdb \
    curl \
    rsync \
    zsh \
    unzip

RUN apt-get install -y \
        # Base tools
        cmake \
        build-essential \
        git \
        unzip \
        pkg-config \
        python-dev \
        # OpenCV dependencies
        python-numpy \
        # Pangolin dependencies
        libgl1-mesa-dev \
        libglew-dev \
        libpython2.7-dev \
        libeigen3-dev

# Build OpenCV (3.0 or higher should be fine)
RUN cd /tmp && git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout 4.4.0 && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D BUILD_EXAMPLES=OFF  -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$nproc && make install && \
    cd / && rm -rf /tmp/opencv

# Build Pangolin
RUN cd /tmp && git clone https://github.com/stevenlovegrove/Pangolin && \
    cd Pangolin && git checkout v0.6 && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-std=c++11 .. && \
    make -j$nproc && make install && \
    cd / && rm -rf /tmp/Pangolin

# Build ORB-SLAM3 for ROS
RUN git clone https://github.com/UZ-SLAMLab/ORB_SLAM3 /ORB_SLAM3
RUN . /opt/ros/melodic/setup.sh && \
    export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:/ORB_SLAM3/Examples/ROS && \
    cd /ORB_SLAM3/ && \
    chmod +x build.sh && ./build.sh \
    chmod +x build_ros.sh && ./build_ros.sh

# the user we're applying this too (otherwise it most likely install for root)
USER $USERNAME
# terminal colors with xterm
ENV TERM xterm
WORKDIR /ORB_SLAM3
