#!/usr/bin/env bash

function _okan {
  _log "okan"
}

function _update_and_upgrade {
    _log "Update & Upgrade"
    is_ubuntu \
        && { \
            sudo apt-get update; \
            sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade; \
        } \
        || { \
            sudo yum update -y
        }
}

function _bootstrap_dotfiles {

  wget https://raw.githubusercontent.com/rajalokan/dotfiles/master/bootstrap_dotfiles.sh -O /tmp/bootstrap_dotfiles.sh \
  && chmod +x /tmp/bootstrap_dotfiles.sh \
  && /tmp/bootstrap_dotfiles.sh
}
