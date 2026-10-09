#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# Install some packages
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

# Enable nullglob for all glob operations to prevent failures on empty matches
shopt -s nullglob

echo "::group:: Install Packages"

dnf5 install -y \
  alacritty \
  kitty \
  atuin

echo "::endgroup::"

echo "::group:: Remove Firefox from Fedora"

dnf5 remove -y firefox

echo "::endgroup::"

# Restore default glob behavior
shopt -u nullglob
