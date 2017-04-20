#!/usr/bin/env bash

sudo apt-get -y install apache2 apache2-utils
sudo a2enmod proxy
sudo a2enmod proxy_http

#sudo mv sparc-apache.conf /etc/apache2/sites-available/sparc.conf
sudo ln -sf /vagrant/script/vagrant/sparc-apache.conf /etc/apache2/sites-enabled/sparc.conf
sudo rm /etc/apache2/sites-enabled/000-default

sudo apache2ctl restart
