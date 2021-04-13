#!/bin/sh 

# if [ $(id -u) -eq 0 ]; then
#   echo "Let's create a non-root user.."
#   echo "Username:"
#   read user
#   useradd -m "${user}"
#   exit
# fi
# exit

echo Cloning spark 
git clone https://github.com/simonwjackson/spark.git /opt/spark
cd /opt/spark

echo Installing ansible...
sudo pacman -Syyu ansible

echo "Please specify playbook:"
read playbook

echo Installing ansible galaxy plugins...
ansible-galaxy install -r requirements.yml

echo Running playbook
ansible-playbook --ask-become-pass "${playbook}-playbook.yml"
