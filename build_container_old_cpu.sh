# checking if you have nvidia
if [[ $(nvidia-smi | grep Driver) ]] 2>/dev/null; then
	echo "******************************"
	echo """It looks like you have nvidia drivers running. Please make sure your nvidia-docker is setup by following the instructions linked in the README and then run build_container_cuda.sh instead."""
	echo "******************************"
	while true; do
		read -p "Do you still wish to continue?" yn
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

# UI permisions
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

xhost +local:docker

docker pull jahaniam/orbslam3:ubuntu18_melodic_cpu

# Remove existing container
docker rm -f orbslam3 &>/dev/null
[ -d "ORB_SLAM3" ] && sudo rm -rf ORB_SLAM3 && mkdir ORB_SLAM3

# Create a new container
docker run -td --privileged --net=host --ipc=host \
	--name="orbslam3" \
	-e "DISPLAY=$DISPLAY" \
	-e "QT_X11_NO_MITSHM=1" \
	-v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	-e "XAUTHORITY=$XAUTH" \
	-e ROS_IP=127.0.0.1 \
	--cap-add=SYS_PTRACE \
	-v $(pwd)/Datasets:/Datasets \
	-v /etc/group:/etc/group:ro \
	-v $(pwd)/ORB_SLAM3:/ORB_SLAM3 \
	jahaniam/orbslam3:ubuntu18_melodic_cpu bash

# Git pull orbslam and compile
docker exec -it orbslam3 bash -i -c "git clone -b docker_opencv3.2_fix https://github.com/jahaniam/ORB_SLAM3 /ORB_SLAM3 && cd /ORB_SLAM3 && chmod +x build.sh && ./build.sh "
# Compile ORBSLAM3-ROS
docker exec -it orbslam3 bash -i -c "echo 'ROS_PACKAGE_PATH=/opt/ros/melodic/share:/ORB_SLAM3/Examples/ROS'>>~/.bashrc && source ~/.bashrc && cd /ORB_SLAM3 && chmod +x build_ros.sh && ./build_ros.sh"
