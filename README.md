# Beton

Automated installer script for my Fedora machines

## Preparation

Insert usb stick, then run `./prepare.sh`

## Fedora Installer

Select "Minimal Install", then "Common NetworkManager Submodules"

## Beton Installer

Run these commands, wait for target to reboot, then run it again

    sudo mkdir -p /media/usb
    sudo mount /dev/sda1 /media/usb
    cd /media/usb/beton
    ./run.sh

## Contributions

Bug reports, feature requests and PRs are welcomed!

