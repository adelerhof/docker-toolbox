#!/bin/bash
set -x
#############################################################
# CREDENTIALS_FILE should contain the following variables:  #
# GH_TOKEN= token for github                                #
# HOMEDIR_GIT= locaction where repos will be cloned         #
#############################################################

# Set some variables
# CREDENTIALS_FILE="${HOME}/adelerhof.eu/work/credentials.gpg"

# Evaluate the content of credentials.gpg for usernames, passwords & tokens
# eval "$(gpg -d ${CREDENTIALS_FILE} 2>/dev/null)"
HOMEDIR_GIT=/home/erik/adelerhof.eu

APPF_REPO_LIST='git@github.com:adelerhof/docker-toolbox.git'

function checkout_code {

	[[ -d ${HOMEDIR_GIT} ]] || /bin/mkdir -p "${HOMEDIR_GIT}"
	pushd "${HOMEDIR_GIT}" || exit
	# Loop over the repos of appfactory
	for I in ${APPF_REPO_LIST}; do
		# Determine the directory of the cloned repo
		DIR="${I#*/}"
		DIR="${DIR%.git}"
		echo "${I} ${DIR}"

		# Check or the directory exists and is not a sybolic link
		if [[ -d ${DIR} ]] && [[ ! -L ${DIR} ]]; then
			# Update the contect of the directory
			pushd "${DIR}" || exit
			git checkout "${ENVIRONMENT}"
			git pull
			git submodule sync --recursive
			git submodule foreach git checkout master
			git submodule foreach git pull origin master
			popd || exit
		else
			# Delete the symbolid link (when it's there) and make a fresh clone
			rm -f "${DIR}"
			git clone --recursive "${I}"
		fi
		echo
	done
	popd || exit
}

function build_image {

	TAG=$(date +%Y%m%d%H%M%S)
	# Build the Docker image date
	docker build . --file Dockerfile --tag ghcr.io/adelerhof/toolbox:"${TAG}"
	docker build . --file Dockerfile --tag ghcr.io/adelerhof/toolbox:latest
	docker build . --file Dockerfile --tag harbor.adelerhof.eu/toolbox/toolbox:"${TAG}"
	docker build . --file Dockerfile --tag harbor.adelerhof.eu/toolbox/toolbox:latest
	docker build . --file Dockerfile --tag erikadelerhof922/docker-toolbox:"${TAG}"
	docker build . --file Dockerfile --tag erikadelerhof922/docker-toolbox:latest
}

function push_image {

	# Push the Docker image date
	docker push ghcr.io/adelerhof/toolbox:"${TAG}"
	docker push ghcr.io/adelerhof/toolbox:latest
	docker push harbor.adelerhof.eu/toolbox/toolbox:"${TAG}"
	docker push harbor.adelerhof.eu/toolbox/toolbox:latest
	docker push erikadelerhof922/docker-toolbox:"${TAG}"
	docker push erikadelerhof922/docker-toolbox:latest
}

function cleanup {

	# Remove the Docker images locally
	docker rmi -f ghcr.io/adelerhof/toolbox:"${TAG}"
	docker rmi -f ghcr.io/adelerhof/toolbox:latest
	docker rmi -f harbor.adelerhof.eu/toolbox/toolbox:"${TAG}"
	docker rmi -f harbor.adelerhof.eu/toolbox/toolbox:latest
	docker rmi -f erikadelerhof922/docker-toolbox:"${TAG}"
	docker rmi -f erikadelerhof922/docker-toolbox:latest
}

function deploy_prd {

	ENVIRONMENT=master

	checkout_code
	build_image
	push_image
	cleanup

}

# Script options
case $1 in
deploy_prd)
	$1
	;;
*)
	echo $"Usage : $0 {deploy_acc|deploy_prd}"
	exit 1
	;;
esac
