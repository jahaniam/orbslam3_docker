#!/usr/bin/env bash

# checking if you have nvidia gpu
## this pulls the latest build container
##
#
# Catch more errors like pipefail
set -ueo pipefail && SCRIPTNAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="${SCRIPT_DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"}"

# the four phases of building the artifacts with a running container
# set to pull the latst build image
PULL="${PULL:-false}"
# set remove the build artifacts
REMOVE="${REMOVE:-false}"
# set restart if you want to restart the container
START="${START:-false}"
# do not build the container just exec it by default
COMPILE="${COMPILE:-false}"

PLATFORM="${PLATFORM:-linux/amd64}"
TAG="${TAG:-ubuntu18_melodic_cpu}"
ORG="${ORG:-jahaniam}"
IMAGE="${IMAGE:-orbslam3}"

if command -v nvidia-smi && nvidia-smi | grep -q Driver; then
	echo "******************************"
	echo "It looks like you have nvidia drivers running. Please make sure
        your nvidia-docker is setup by following the instructions linked in the
        README and then run build_container_cuda.sh instead."
	echo "******************************"
	while true; do
		read -rp "Do you still wish to continue?" yn
		case $yn in
		[Yy]*)
			make install
			break
			;;
		[Nn]*) exit ;;
		*) echo "Please answer yes or no." ;;
		esac
	done
fi

# assumes display is imported but set if not
DISPLAY="${DISPLAY:-:0}"

# UI permissions
if [[ $OSTYPE =~ darwin ]]; then
	# Mac OSX use a magic DISPLAY to connect to Linux VM that docker runs
	echo "Make sure to check XQuartz > Preferences > Security > Allow network"
	echo "access and restart XQuartz"
	open -a XQuartz
	xhost +localhost
	# note single quotes to preserve the double quotes
	DOCKER_FLAGS=(
		-e DISPLAY="host.docker.internal:0"
	)
else
	# this does not exist
	#chmod +x ./build_container_ui.sh
	XSOCK=/tmp/.X11-unix
	XAUTH=/tmp/.docker.xauth
	touch "$XAUTH"
	xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
	xhost +local:docker
	# do not quite understand why /etc/group needs to be matched
	DOCKER_FLAGS=(
		-e "DISPLAY=$DISPLAY"
		-e "XAUTHORITY=$XAUTH"
		-v "$XSOCK:$XSOCK:rw"
		-v /etc/group:/etc/group:ro
	)
fi

# echo "$SCRIPTNAME: set environment variable PULL=true if you want to remove the container"
if $PULL; then
	echo "$SCRIPTNAME: Pulling container"
	docker pull "$ORG/$IMAGE:$TAG"

fi

#echo "$SCRIPTNAME: export REMOVE=true to remove build artifacts"
if $REMOVE; then
	echo "$SCRIPTNAME: Removing build artifacts"
	if [[ -d ORB_SLAM3 ]]; then
		# do not rm -rf ORB_SLAM3 because if docker is already running it will lose the
		# volume mount so just delete everything inside
		#rm -rf ORB_SLAM3/
		# this is safer and removes all the .git stuff
		find ORB_SLAM3 -mindepth 1 -delete
	fi
fi

#echo "$SCRIPTNAME: export START=true if you want to restart the container"
if $START; then
	echo "$SCRIPTNAME: Remove running container"
	docker rm -f "$IMAGE" &>/dev/null

	# Create a new container
	echo "$SCRIPTNAME: start a new ORB_SLAM3 container"
	# make sure the directory exists
	mkdir -p ORB_SLAM3
	mkdir -p Datasets
	# note we need --platform so this will run on M1 Macs
	docker run -td --privileged --net=host --ipc=host \
		--platform "$PLATFORM" \
		--name="$IMAGE" \
		"${DOCKER_FLAGS[@]}" \
		-e "QT_X11_NO_MITSHM=1" \
		-e ROS_IP=127.0.0.1 \
		--cap-add=SYS_PTRACE \
		-v "$(pwd)/Datasets:/Datasets" \
		-v "$(pwd)/ORB_SLAM3:/ORB_SLAM3" \
		"$ORG/$IMAGE:$TAG" bash
fi

if $COMPILE; then
	echo "$SCRIPTNAME: Cloning ORB_SLAM3 in $PWD"
	# Git pull orbslam and compile
	mkdir -p ORB_SLAM3
	docker exec -it "$IMAGE" bash -i -c "git clone -b docker_opencv3.2_fix https://github.com/jahaniam/ORB_SLAM3 /ORB_SLAM3 && cd /ORB_SLAM3 && chmod +x build.sh && ./build.sh "
	echo "$SCRIPTNAME: Building artifacts in ORB_SLAM3"
	# Compile ORBSLAM3-ROS
	docker exec -it "$IMAGE" bash -i -c "echo 'ROS_PACKAGE_PATH=/opt/ros/melodic/share:/ORB_SLAM3/Examples/ROS'>>~/.bashrc && source ~/.bashrc && cd /ORB_SLAM3 && chmod +x build_ros.sh && ./build_ros.sh"
fi
