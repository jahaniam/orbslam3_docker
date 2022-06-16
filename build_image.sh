#!/usr/bin/env bash
set -ueo pipefail && SCRIPTNAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="${SCRIPT_DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"}"

# default for docker hub if you want to use github container registry add
# ORG="${ORG:-ghcr.io/netdrones}"
ORG="${ORG:-jahaniam}"

#shellcheck disable=SC2086
echo $SCRIPTNAME: docker build -t "$ORG/orbslam3" .

if [[ $OSTYPE =~ darwin ]]; then
	echo "$SCRIPTNAME: OSX using buildx for multiplatform and will push"
	docker buildx build --push --platform linux/amd64,linux/arm64 -t "$ORG/orbslam3" .
else
	# shellcheck disable=SC2086
	docker build -t "$ORG/orbslam3" .
fi
