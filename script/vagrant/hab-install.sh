#!/usr/bin/env bash

#Set up hab user & group
# sudo adduser --group hab
# sudo useradd -g hab hab

# Install hab
curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash -v 0.79.1
# tar -xzf hab-0.*.*.tar.gz
# sudo mv hab-**/hab /usr/local/bin
# sudo chmod a+x /usr/local/bin/hab


