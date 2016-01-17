# X2x Tools using Raspbian on Raspberry Pi
You can set what the remote Raspberry Pi computer boots to, and start x2x. X2x is similar to a KVM-switch,
but with several screens and copy and paste between screens. You select active computer by moving the 
mouse-pointer to its screen.

## Install
These scripts assume the left computer has the mouse and keyboard connected. But this can be changed in 
the scripts on the computer with keyboard by changing east to west, north, or south.  
On both computers do:  
cd  
git clone https://github.com/mobluse/x2x.git  

The computers must be connected via network with port 22 for SSH open.

## Boot to X-Windows on remote Raspberry Pi and start x2x
~/x2x/boot2x2x.sh raspberrypi2

## Start x2x if X-Windows already runs on remote computer
~/x2x/startx2x.sh raspberrypi2

## Boot to Linux Console on remote Raspberry Pi
~/x2x/boot2console raspberrypi2
