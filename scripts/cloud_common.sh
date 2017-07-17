#!/usr/bin/env bash

function _bootstrap_dotfiles {
  wget https://raw.githubusercontent.com/rajalokan/dotfiles/master/bootstrap_dotfiles.sh -O /tmp/bootstrap_dotfiles.sh \
  && chmod +x /tmp/bootstrap_dotfiles.sh \
  && /tmp/bootstrap_dotfiles.sh
}
