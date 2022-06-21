FROM nvidia/opengl:1.2-glvnd-runtime-ubuntu18.04
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

# use xeyes from x11-apps for debugging
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gnupg2=2.2.4-1ubuntu1.4 \
        curl=7.58.0-2ubuntu3.16 \
        lsb-core=9.20170808ubuntu1 \
        vim=2:8.0.1453-1ubuntu1.4 \
        python-pip=9.0.1-2 \
        libpng16-16=1.6.34-1 \
        libjpeg-turbo8=1.5.2-0ubuntu5 \
        libtiff5=4.0.9-5 \
        x11-apps \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Installing ROS-melodic
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > "/etc/apt/sources.list.d/ros-latest.list" && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key "C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654" && \
    curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | apt-key add - && \
    apt-get update && apt-get install -y --no-install-recommends \
        melodic-desktop \
        python-rosdep && \
    rosdep init && \
    rosdep update && \
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc && \
    apt-get install -y --no-install-recommends \
        python-rosinstall python-rosinstall-generator python-wstool build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Installing python-catkin
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' && \
    curl -sSL "http://packages.ros.org/ros.key" | apt-key add - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python-catkin-tools \
        software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bash_profile

# OpenCV dependencies
# Pangolin dependencies
RUN apt-get install -y --no-install-recommends \
        # Base tools
        cmake \
        build-essential \
        git \
        unzip \
        pkg-config \
        python-dev \
        python-numpy \
        libgl1-mesa-dev \
        libglew-dev \
        libpython2.7-dev \
        libeigen3-dev \
        apt-transport-https \
        ca-certificates\
        software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add - && \
    add-apt-repository "deb https://download.sublimetext.com/ apt/stable/" && \
    apt-get update && \
    apt-get install -y --no-install-recommends sublime-text && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Build OpenCV (3.0 or higher should be fine)
RUN apt-get install -y --no-install-recommends \
        python3-dev python3-numpy \
        python-dev python-numpy \
        libavcodec-dev libavformat-dev libswscale-dev \
        libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev \
        libgtk-3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone -b 3.2.0 https://github.com/opencv/opencv.git
WORKDIR /tmp/opencv/build
RUN cmake -D CMAKE_BUILD_TYPE=Release -D BUILD_EXAMPLES=OFF  -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
    make "-j$(nproc)" && make install
WORKDIR /tmp
RUN    rm -rf opencv

# # Build Pangolin
WORKDIR /tmp
RUN git clone -b 0.6 https://github.com/stevenlovegrove/Pangolin
WORKDIR /tmp/Pangolin/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-std=c++11 .. && \
    make "-j$(nproc)" && make install
WORKDIR /tmp
RUN   rm -rf Pangolin

COPY ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod +x  /ros_entrypoint.sh
ENV ROS_DISTRO melodic
ENV LANG en_US.UTF-8

ENTRYPOINT ["/ros_entrypoint.sh"]

USER $USERNAME
# terminal colors with xterm
ENV TERM xterm
RUN mkdir /ORB_SLAM3
WORKDIR /ORB_SLAM3
CMD ["bash"]
