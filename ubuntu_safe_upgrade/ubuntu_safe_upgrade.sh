#!/bin/sh

sudo apt-get update
sudo apt-get upgrade

sudo dpkg --set-selections < ubuntu-8.04-packages
sudo apt-get dselect-upgrade

# === EOF ==
