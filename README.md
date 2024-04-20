# ORB_SLAM3 docker

This docker is based on <b>Ros Noetic Ubuntu 20</b>. If you need melodic with ubuntu 18 checkout #8fde91d

There are two versions available:
- CPU based (Xorg Nouveau display)
- Nvidia Cuda based. 

To check if you are running the nvidia driver, simply run `nvidia-smi` and see if get anything.

Based on which graphic driver you are running, you should choose the proper docker. For cuda version, you need to have [nvidia-docker setup](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) on your machine.

---

## Compilation and Running

Steps to compile the Orbslam3 on the sample dataset:

- `./download_dataset_sample.sh`
- `build_container_cpu.sh` or `build_container_cuda.sh` depending on your machine.

Now you should see ORB_SLAM3 is compiling. 
- Download A sample MH02 EuRoC example and put it in the `Datasets/EuRoC/MH02` folder
```
mkdir -p Datasets/EuRoC 
wget -O Datasets/EuRoC/MH_02_easy.zip http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_02_easy/MH_02_easy.zip
unzip Datasets/EuRoC/MH_02_easy.zip -d Datasets/EuRoC/MH02
```
To run a test example:
- `docker exec -it orbslam3 bash`
- `cd /ORB_SLAM3/Examples && bash ./euroc_examples.sh`
It will take few minutes to initialize. Pleasde Be patient.
---

You can use vscode remote development (recommended) or sublime to change codes.
- `docker exec -it orbslam3 bash`
- `subl /ORB_SLAM3`
