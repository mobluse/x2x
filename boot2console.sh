#!/bin/sh

ssh pi@$1.local 'sudo ~/x2x/setboot.sh B2; sudo reboot'
