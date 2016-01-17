# X2x Tools using Raspbian on Raspberry Pi
You can set what the remote Raspberry Pi computer boots to, and start x2x. X2x is similar to a KVM-switch,
but with several screens and copy and paste between screens.

## Install
On both computers do:  
cd  
git clone https://github.com/mobluse/x2x.git  

The computers must be connected via TCP/IP network.

## Boot to X Windows on remote Raspberry Pi and x2x
~/x2x/boot2x2x.sh raspberrypi2

## Start x2x if X Windows already runs on remote computer
~/x2x/startx2x.sh raspberrypi2

## Boot to Linux Console in remote Raspberry Pi
~/x2x/boot2console raspberrypi2
