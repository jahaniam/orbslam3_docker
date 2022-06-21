# ORB_SLAM3 docker with OpenCV 3.2 fix

This docker is based on ros melodic ubuntu 18 with ORB_SLAM3 v0.4. It uses
Python 2.17, OpenCV 3.2 and is based on a fork with an [OpenCV
3.2](https://github.com/jahaniam/ORB_SLAM3/tree/docker_opencv3.2_fix) fixes two
OpenCV files a [PR 382](https://github.com/UZ-SLAMLab/ORB_SLAM3/pull/382) that
work for OpenCV 4.x that were never merged into ORB_SLAM3 (as
they use OpenCV 4) so closed it.

There are two versions available:

- CPU based (Xorg Nouveau display)
- Nvidia Cuda based.

To check if you are running the nvidia driver, simply run `nvidia-smi` and see
if get anything.

Based on which graphic driver you are running, you should choose the proper
docker. For cuda version, you need to have [nvidia-docker
setup](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
on your machine.

## Using Docker with ORB_SLAM3 v1.0 and OpenCV 4

The current state of Dockerized ORB_SLAM3 is in the main ORB_SLAM3 repo issue
[#339](https://github.com/UZ-SLAMLab/ORB_SLAM3/issues/339). The current best
solutions for a OpenCV 4.x version is by
[LMWafers](https://github.com/LMWafer/orb-slam-3-ready) which is already ready
for a RealSense cameras

---

## Compilation and Running

Steps to compile the Orbslam3 on the sample dataset and this leaves a running
container which links to out of the container to the local filesystem. The
actual ORB_SLAM3 software (about 1.5GB) lives outside the build image:

Note that the original forked repo used two different images for the base. The
first used Turlucode builds for the cpu, but used it's own custom Melodic
builder for gpu. The Turlucode is a submodule but is not supported well so
switched to our own local build. The pushed docker image works however for the
cpu.

```sh
# download and unzip the test dataset
./download_dataset_sample.sh
# build the image once for the nVidia gpu
./build_image.sh
# build the image once for cpu only build the turlucode image
cd ros_docker_gui
make cpu_ros_melodic
# this will build a local image turlucode/ros_melodice:cpu
# this is because these imaes are not pushed to docker hub
./build_image.sh -t cpu

# then everytime you run
# if you have just a cpu this will download an image and
./build_container_cpu.sh
# if you have nvidia gpu
./build_container_cuda.sh
```

Now you should see ORB_SLAM3 is compiling and it will eventually leave a
detached running container

The container connects to ./ORB_SLAM3 directory in this directory and to
./Datasets directory for the datasets you load. These are kept external to the
container.

This container must be connected via X11 to your host machine, so if you have
issues look at the ./build_container scripts and make sure that X11 works by
ensuring that it works by testing with xeyes:

```sh
docker exec -it orbslam3 bash
apt-get install x11-apps
xeyes
```

To run a test example exec into the running container and run it which will
start ORB_SLAM3 with the example data and then use X11 to display the
interfaceo on your host machine:

```sh
docker exec -it orbslam3 bash
cd /ORB_SLAM3/Examples &&. /euroc_examples.sh
```

## Running on MacOS

If you have a Mac, you will find that this has no X11 connection, so you need
to based on [gist](https://gist.github.com/paul-krohn/e45f96181b1cf5e536325d1bdee6c949):

```sh
brew install xquartz
# go to Xquartz Preferences Security  allow connections from network clients
# restart xquartz
open -a xquartz
xhost +localhost

# to test if this works see if xeyes comes up
xeyes
# now test to see if docker works disable host checking
# try xeyes and exit the app to kill the container
docker run -it --rm -e DISPLAY=host.docker.internal:0 gns3/xeyes
# try firefox
docker run -it --rm -e DISPLAY=host.docker.internal:0 jess/firefox
# now run it with orbslam
docker run -it --rm -e DISPLAY=host.docker.internal:0 orbslam3 bash
cd Examples
./euroc_examples.sh

```

## Using VSCode or Sublime within the container

You can use vscode remote development (recommended) or sublime to change code
from within the docker container since subl is loaded in the container.

- `docker exec -it orbslam3 bash`
- `subl /ORB_SLAM3`

Alternatively, you can leave the container running in a separate terminal
windows and just edit [./ORB_SLAM3](./ORG_SLAM3) and this will be reflected in
the container
