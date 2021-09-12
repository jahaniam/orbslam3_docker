# orbslam3_docker

This docker is based on ros melodic ubuntu 18.

Steps to run the Orbslam3 on the sample dataset:

- `./download_dataset_sample.sh`
- `docker pull jahaniam/orbslam3`
- `build_container.sh`
- `docker exec -it orbslam3 bash`
- `cd Examples&&./euroc_examples.sh`

