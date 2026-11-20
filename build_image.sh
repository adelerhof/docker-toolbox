#!/bin/bash
# shellcheck enable=all
# Build, scan and push the toolbox image from a fresh clone of the repository.
# Same pattern as technote/build_image.sh: never build from a working copy.
#
#   ./build_image.sh deploy_prd            # builds BRANCH (default master)
#   BRANCH=my-branch ./build_image.sh deploy_prd

set -euo pipefail
# set -x  # uncomment for verbose tracing

###############################################################################
# Config
###############################################################################

REPO_URL='git@github.com:adelerhof/docker-toolbox.git'
BRANCH="${BRANCH:-master}"
# Local scan before push; the push stops on findings at these severities.
TRIVY_IMAGE='aquasec/trivy:0.70.0'
TRIVY_SEVERITY='HIGH,CRITICAL'

# Populated by checkout_code (or inherited from it after the re-exec);
# consumed by build_image / scan_image / push_image.
BUILD_ROOT="${TOOLBOX_BUILD_ROOT:-}"
REPO_DIR=''
TAG=''
IMAGE_TAGS=()

###############################################################################
# Functions
###############################################################################

checkout_code() {
	# Build from a fresh clone: no leftover files, no switched branches in a
	# working copy.
	BUILD_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/toolbox-build.XXXXXX")
	REPO_DIR="${BUILD_ROOT}/docker-toolbox"
	trap _cleanup_build_root EXIT

	echo "${REPO_URL} (${BRANCH}) → ${REPO_DIR}"
	git clone --quiet --depth 1 --branch "${BRANCH}" "${REPO_URL}" "${REPO_DIR}"
	git --no-pager -C "${REPO_DIR}" log -1 --format='Building %h %s'
	echo
}

_cleanup_build_root() {
	[[ -n ${BUILD_ROOT} && -d ${BUILD_ROOT} ]] && rm -rf "${BUILD_ROOT}"
}

_image_tags() {
	# Set IMAGE_TAGS to all registry:tag pairs for the current build.
	IMAGE_TAGS=(
		"ghcr.io/adelerhof/toolbox:${TAG}"
		"ghcr.io/adelerhof/toolbox:latest"
		"harbor.adelerhof.eu/toolbox/toolbox:${TAG}"
		"harbor.adelerhof.eu/toolbox/toolbox:latest"
	)
}

build_image() {
	if [[ -z ${REPO_DIR} ]]; then
		echo "ERROR: REPO_DIR is empty — checkout_code must run first" >&2
		exit 1
	fi

	TAG=$(date +%Y%m%d%H%M%S)

	local -a tag_args=()
	local t
	_image_tags
	for t in "${IMAGE_TAGS[@]}"; do
		tag_args+=(--tag "${t}")
	done

	# --pull  : always fetch the latest base image (catches upstream updates)
	# --no-cache : never reuse the apk upgrade layer from a previous build
	docker build --pull --no-cache \
		"${REPO_DIR}" \
		--file "${REPO_DIR}/Dockerfile" \
		"${tag_args[@]}"
}

scan_image() {
	# Trivy from its container image, reading the local Docker daemon.
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v trivy-cache:/root/.cache \
		"${TRIVY_IMAGE}" image --quiet --exit-code 1 \
		--severity "${TRIVY_SEVERITY}" \
		"ghcr.io/adelerhof/toolbox:${TAG}" || {
		echo "ERROR: ${TRIVY_SEVERITY} findings, not pushing" >&2
		cleanup
		exit 1
	}
}

push_image() {
	local t
	_image_tags
	for t in "${IMAGE_TAGS[@]}"; do
		docker push "${t}"
	done
}

show_image_info() {
	# The registry-assigned digest is only available after push.
	local primary="ghcr.io/adelerhof/toolbox:${TAG}"
	local digest
	digest=$(docker inspect --format='{{index .RepoDigests 0}}' "${primary}" 2>/dev/null ||
		echo "(digest not available — was the image pushed?)")

	echo
	echo "══════════════════════════════════════════════════════"
	echo " Image ready"
	echo "══════════════════════════════════════════════════════"
	echo " Tag    : ${primary}"
	echo " Digest : ${digest}"
	echo "══════════════════════════════════════════════════════"
	echo
}

cleanup() {
	local t
	_image_tags
	for t in "${IMAGE_TAGS[@]}"; do
		docker rmi -f "${t}" || true
	done
}

###############################################################################
# Re-exec: after checkout_code cloned the branch we re-launch the cloned
# script, so every build step runs the committed version. The clone's path is
# passed on in TOOLBOX_BUILD_ROOT, which also stops a second re-exec.
###############################################################################

_checkout_and_reexec() {
	if [[ -n ${BUILD_ROOT} ]]; then
		REPO_DIR="${BUILD_ROOT}/docker-toolbox"
		trap _cleanup_build_root EXIT
		return
	fi
	checkout_code
	echo "Re-executing from the clone: ${REPO_DIR}/build_image.sh"
	export TOOLBOX_BUILD_ROOT="${BUILD_ROOT}" BRANCH
	exec "${REPO_DIR}/build_image.sh" "$@"
}

###############################################################################
# Deploy targets
###############################################################################

deploy_prd() {
	_checkout_and_reexec "deploy_prd"

	build_image
	scan_image
	push_image
	show_image_info
	cleanup
}

###############################################################################
# Entrypoint
###############################################################################

case "${1-}" in
deploy_prd) deploy_prd ;;
*)
	echo "Usage: $0 {deploy_prd}" >&2
	exit 1
	;;
esac
