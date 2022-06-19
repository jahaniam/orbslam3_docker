#!/usr/bin/env bash
set -ueo pipefail && SCRIPTNAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="${SCRIPT_DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"}"

# default for docker hub if you want to use github container registry add
# ORG="${ORG:-ghcr.io/netdrones}"
ORG="${ORG:-jahaniam}"
IMAGE="${IMAGE:-orbslam3}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
TYPE="${TYPE:-cuda}"
TAG="${TAG:-ubuntu18_melodic}"
PLATFORM="${PLATFORM:-linux/amd64}"
# if you want multiplate dockerhub orgs add the following
#PLATFORM="${PLATFORM:-linux/amd64,linux/arm64}"
OPTIND=1
while getopts "ht:" opt; do
	case "$opt" in
	h)
		cat <<-EOF
			Build a docker image for orbslam3 building
			usage: $SCRIPTNAME [ flags ]
			flags:
				   -h help
			                   -t building for cpu or cuda (default: $TYPE})
		EOF
		exit 0
		;;
	t)
		# invert the flag between cuda and cpu
		TYPE="$OPTARG"
		;;
	*)
		echo "no flag -$opt"
		;;
	esac
done
shift $((OPTIND - 1))

# if cpu then add that to the docker filename
if [[ $TYPE =~ cpu ]]; then
	DOCKERFILE="${DOCKERFILE}_cpu"
fi

DOCKERNAME="$ORG/$IMAGE:${TAG}_$TYPE"
echo "$SCRIPTNAME: build $DOCKERFILE into $DOCKERNAME"

if [[ $OSTYPE =~ darwin ]]; then
	echo "$SCRIPTNAME: OSX using buildx for multiplatform and will push"
	docker buildx build --push --platform "$PLATFORM" \
		-t "$DOCKERNAME" -f "$DOCKERFILE" .
else
	# shellcheck disable=SC2086
	docker build -t "$DOCKERNAME" -f "$DOCKERFILE".
fi
