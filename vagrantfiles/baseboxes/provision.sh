#!/usr/bin/env bash

[[ $# < 1 ]] && echo "no arg provided" || echo "arg provided"

# ============================================================================
# Util functions
# ============================================================================

function _configure_apt_cacher_ng {
  #statements
  echo "_configure_apt_cacher_ng"
}

function _configure_devpi {
  echo "_configure_devpi"
}

function _insert_cloud_key {
  echo "_insert_cloud_key"
}

function _setup_dotfiles {
  # Delete if bootstrap_dotfiles alreay present
  [[ -f /tmp/bootstrap_dotfiles ]] && rm /tmp/bootstrap_dotfiles

  # Fetch latest bootstrap_dotfiles and execute
  wget https://raw.githubusercontent.com/rajalokan/dotfiles/master/bootstrap.sh -O /tmp/bootstrap_dotfiles >/dev/null 2>&1 \
    && chmod +x /tmp/bootstrap_dotfiles \
    && /tmp/bootstrap_dotfiles
}

case $1 in
  trusty|xenial|centos)
    _setup_dotfiles
    ;;
  *)
    echo $1
    ;;
esac
