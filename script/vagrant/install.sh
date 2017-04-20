#!/usr/bin/env bash

sudo adduser --group capistrano
sudo useradd -g capistrano capistrano

sudo apt-get update
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get install -y vim curl python-software-properties git
sudo apt-get update

