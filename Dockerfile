FROM ros:humble-perception-jammy

ARG USER_NAME
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd ${USER_NAME} --gid ${USER_ID}\
    && useradd -l -m ${USER_NAME} -u ${USER_ID} -g ${USER_ID} -s /bin/bash

USER root

ARG ROS_DISTRO=humble
RUN apt-get update 
RUN apt-get install -y \
    vim \
    apt-utils

# Install rviz2, rqt
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-rqt

# Install rmf
RUN apt-get update && apt-get install -y \
    python3-pip \
    curl \
    python3-colcon-mixin \
    ros-dev-tools

WORKDIR /
RUN mkdir -p rmf_humble_lib/src
WORKDIR /rmf_humble_lib/
RUN wget https://raw.githubusercontent.com/open-rmf/rmf/main/rmf.repos
RUN vcs import src < rmf.repos 
RUN rosdep update
RUN rosdep install --from-paths src --ignore-src --rosdistro humble -y
RUN apt-get update && apt-get install -y \
    clang \
    clang-tools \
    lldb \
    lld \
    libstdc++-12-dev
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && colcon build  --mixin release lld
## These pip packages are only used by rmf_demos which are not released as binaries
RUN python3 -m pip install flask-socketio fastapi uvicorn

RUN colcon mixin update default
RUN apt-get update && apt install -y \
    ros-${ROS_DISTRO}-ros-ign-bridge

COPY ./src /root/rmf_ws/src
WORKDIR /root/rmf_ws/

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
RUN echo "source /rmf_humble_lib/install/setup.bash" >> ~/.bashrc
RUN echo "export CXX=clang++" >> ~/.bashrc
RUN echo "export CC=clang" >> ~/.bashrc
