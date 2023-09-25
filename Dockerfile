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
    vim

# Install rmf
RUN apt update && sudo apt install -y \
    python3-pip \
    curl \
    python3-colcon-mixin \
    ros-dev-tools
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget https://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
## These pip packages are only used by rmf_demos which are not released as binaries
RUN python3 -m pip install flask-socketio fastapi uvicorn
RUN rosdep update

RUN colcon mixin update default
RUN apt-get update && apt install -y ros-${ROS_DISTRO}-rmf-dev

WORKDIR /root/rmf_ws/

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
