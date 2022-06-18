#!/usr/bin/env bash
set -ueo pipefail && SCRIPTNAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="${SCRIPT_DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"}"

# default for docker hub if you want to use github container registry add
# ORG="${ORG:-ghcr.io/netdrones}"
ORG="${ORG:-jahaniam}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
IMAGE="${IMAGE:-orbslam3}"
TYPE="${TYPE:-cuda}"
TAG="${TAG:-ubuntu_18_melodic}"
OPTIND=1
while getopts "ht" opt; do
	case "$opt" in
	h)
		cat <<-EOF
			Build a docker image for orbslam3 building
			usage: $SCRIPTNAME [ flags ]
			flags:
				   -h help
			                   -g building for cpu or cuda (default: $TYPE})
		EOF
		exit 0
		;;
	t)
		# invert the flag between cuda and cpu
		TYPE="$([[ $TYPE =~ cuda ]] && echo cpu || echo cuda)"
		;;
	*)
		echo "no flag -$opt"
		;;
	esac
done
shift $((OPTIND - 1))

DOCKER_NAME="$ORG/$IMAGE:$TAG_$TYPE"
echo "$SCRIPTNAME: building $DOCKER_NAME"

if [[ $OSTYPE =~ darwin ]]; then
	echo "$SCRIPTNAME: OSX using buildx for multiplatform and will push"
	docker buildx build --push --platform linux/amd64,linux/arm64 \
		-t "$DOCKER_NAME"-f "$DOCKERFILE" .
else
	# shellcheck disable=SC2086
	docker build -t "$DOCKER_NAME" -f "$DOCKERFILE".
fi
