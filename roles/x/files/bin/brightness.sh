#!/bin/sh

# Requires kernel module i2c-dev
# Alternatively, one may use ddcci-driver-linux-dkmsAUR to expose external monitors in sysfs. Then, after loading the ddcci kernel module, one can use any backlight utility. 

notify-send "Brightness: $@%"

# TODO: add user to group to use without sudo

ddcutil --display 1 setvcp 10 $@
ddcutil --display 2 setvcp 10 $@