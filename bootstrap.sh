#!/usr/bin/env bash

is_sclib_imported 2> /dev/null ||
  SCLIB_PATH="/tmp/sclib.sh"
  SCLIB_GIT_RAW_URL="https://raw.githubusercontent.com/rajalokan/cloud-installer/master/scripts/sclib.sh"
  if [[ ! -f ${SCLIB_PATH} ]]; then
      wget ${SCLIB_GIT_RAW_URL} -O ${SCLIB_PATH}
  fi
  source ${SCLIB_PATH}

if [[ $# < 1 ]]; then
  _error "You must provide instance type to bootstap."
  exit 0
fi

_INSTANCE=${1:-}

function _ensure_sourcecode {
  BOOTSTRAP_DIR="/opt/bootstrap"
  CLOUD_INSTALLER_DIR="${BOOTSTRAP_DIR}/cloud-installer"

  sudo mkdir -p ${BOOTSTRAP_DIR}
  sudo chown -R ${USER}:${USER} ${BOOTSTRAP_DIR}

  # # Install git
  is_package_installed git || install_package git

  # clone dotfiles if not present
  if [ ! -d ${CLOUD_INSTALLER_DIR} ]; then
    git clone https://github.com/rajalokan/cloud-installer.git ${CLOUD_INSTALLER_DIR}
  fi

  cd ${CLOUD_INSTALLER_DIR}
}

case "${_INSTANCE}" in
  stegen | gutsdev | psocata | psnewton | psmitaka )
    _ensure_sourcecode
    eval $(printf "%q\n" "scripts/provision/${_INSTANCE}.sh")
    ;;
  local)
    _log "Inside local provisioning"
    ;;
  *box )
    _log "Inside vagrant provisioning"
    ;;
  *)
    _error "Invalid option"
    ;;
esac
