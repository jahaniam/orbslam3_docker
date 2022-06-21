#!/usr/bin/env bash
##
## Download sample dataset
#
set -ueo pipefail && SCRIPTNAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR=${SCRIPT_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}

echo "$SCRIPTNAME: Downloading sample dataset"
wget "http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_01_easy/MH_01_easy.zip" -O Datasets/EuRoC/MH01.zip
unzip Datasets/EuRoC/MH01.zip -d Datasets/EuRoC/MH01

# leave the zip file
#rm Datasets/EuRoC/MH01.zip
