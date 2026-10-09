#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# Replace GNOME with the Niri desktop
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

shopt -s nullglob

echo "::group:: Install Niri Desktop with DMS"

# Install Niri and DMS and recommended extras.
copr_install_isolated "avengemedia/dms" \
  dms niri

copr_install_isolated "avengemedia/danklinux" \
  dms-cli \
  dgop \
  danksearch \
  dms-greeter \
  matugen \
  quickshell-git

dnf5 install -y \
  libwayland-server \
  libdisplay-info \
  libseat \
  xwayland-satellite \
  power-profiles-daemon \
  cups-pk-helper \
  fira-code-fonts \
  kf5-kimageformats \
  kf6-kimageformats \
  rsms-inter-fonts \
  rsms-inter-vf-fonts \
  xdg-desktop-portal-gnome \
  xdg-desktop-portal-gtk

echo "Niri desktop installed successfully"
echo "::endgroup::"

echo "::group:: Enable DMS user service for all users"

# Ensure user unit wants directories exist and enable DMS globally
install -d /etc/systemd/user/default.target.wants /etc/systemd/user/niri.service.wants
systemctl --global enable dms.service
systemctl --global add-wants niri.service dms.service

# Set graphical target as default
systemctl set-default graphical.target

echo "DMS user service enabled for all users"
echo "::endgroup::"

echo "::group:: Configure greetd with dms-greeter"

dnf5 install -y greetd

install -d /etc/greetd
cat >/etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
user = "greeter"
command = "dms-greeter --command niri"
EOF

# greeter service user
tee /usr/lib/sysusers.d/greeter.conf <<'EOF'
g greeter -
u greeter - "Greetd greeter" /var/cache/dms-greeter
EOF

systemctl disable gdm.service lightdm.service sddm.service || true
systemctl enable greetd.service

echo "greetd configured for dms-greeter"
echo "::endgroup::"

echo "Niri desktop installation complete!"
