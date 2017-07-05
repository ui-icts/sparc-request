#!/usr/bin/env bash

#Set up hab user & group
sudo adduser --group hab
sudo useradd -g hab hab

# Install hab
rm -f hab-0.*.*.tar.gz
curl -O -J -L https://api.bintray.com/content/habitat/stable/linux/x86_64/hab-%24latest-x86_64-linux.tar.gz?bt_package=hab-x86_64-linux
tar -xzf hab-0.*.*.tar.gz
sudo mv hab-**/hab /usr/local/bin
sudo chmod a+x /usr/local/bin/hab
