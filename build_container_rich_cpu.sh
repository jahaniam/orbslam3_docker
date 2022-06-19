#!/usr/bin/env bash

# checking if you have nvidia gpu
#
# Catch more errors like pipefail
set -ueo pipefail && SCRIPTNAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="${SCRIPT_DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"}"
# do not build the container just exec it by default
BUILD="${BUILD:-true}"
# set remove the build artifacts
REMOVE="${REMOVE:-true}"
# set restart if you want to restart the container
RESTART="${RESTART:-true}"

ORG="${ORG:-jahaniam}"
IMAGE="${IMAGE:-orbslam3}"
echo "$SCRIPTNAME: Using docker org $ORG"

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
	X11_PARMS=(
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
	X11_PARMS=(
		-e "DISPLAY=$DISPLAY"
		-e "XAUTHORITY=$XAUTH"
		-v "$XSOCK:$XSOCK:rw"
	)
fi

echo "$SCRIPTNAME: set environment variable BUILD=true if you want to remove the container"
if $BUILD; then
	echo "Building container"
	docker pull "$ORG/$IMAGE:ubuntu18_melodic_cpu"

fi

echo "$SCRIPTNAME: export REMOVE=true to remove build artifacts"
if $REMOVE; then
	echo "$SCRIPTNAME: Removing build artifacts"
	if [[ -d ORB_SLAM3 ]]; then
		rm -rf ORB_SLAM3
		mkdir -p ORB_SLAM3
	fi
fi

echo "$SCRIPTNAME: export RESTART=true if you want to restart the container"
if $RESTART; then
	echo "Restarting container"
	docker rm -f "$IMAGE" &>/dev/null
fi

# Create a new container
echo "$SCRIPTNAME: start ORB_SLAM3 container"
# shellcheck disable=SC2086
echo $SCRIPTNAME: docker run -td --privileged --net=host --ipc=host \
	--name="$IMAGE" \
	--platform linux/amd64 \
	"${X11_PARMS[@]}" \
	-e "QT_X11_NO_MITSHM=1" \
	-e ROS_IP=127.0.0.1 \
	--cap-add=SYS_PTRACE \
	-v /etc/group:/etc/group:ro \
	-v "$(pwd)/Datasets:/Datasets" \
	-v "$(pwd)/ORB_SLAM3:/ORB_SLAM3" \
	"$ORG/$IMAGE:cpu" bash

# note we need --platform so this will run on M1 Macs
docker run -td --privileged --net=host --ipc=host \
	--platform linux/amd64 \
	--name="$IMAGE" \
	"${X11_PARMS[@]}" \
	-e "QT_X11_NO_MITSHM=1" \
	-e ROS_IP=127.0.0.1 \
	--cap-add=SYS_PTRACE \
	-v /etc/group:/etc/group:ro \
	-v "$(pwd)/Datasets:/Datasets" \
	-v "$(pwd)/ORB_SLAM3:/ORB_SLAM3" \
	"$ORG/$IMAGE:ubuntu18_melodic_cpu" bash

if $BUILD; then
	# Git pull orbslam and compile
	docker exec -it "$IMAGE" bash -i -c "git clone -b docker_opencv3.2_fix https://github.com/jahaniam/ORB_SLAM3 /ORB_SLAM3 && cd /ORB_SLAM3 && chmod +x build.sh && ./build.sh "
	# Compile ORBSLAM3-ROS
	docker exec -it "$IMAGE" bash -i -c "echo 'ROS_PACKAGE_PATH=/opt/ros/melodic/share:/ORB_SLAM3/Examples/ROS'>>~/.bashrc && source ~/.bashrc && cd /ORB_SLAM3 && chmod +x build_ros.sh && ./build_ros.sh"
fi
