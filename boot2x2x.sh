#!/bin/sh

ssh pi@$1.local 'sudo ~/x2x/setboot.sh B4; sudo reboot'
echo "Wait until X has started on $1.local."
sleep 60
ssh -X pi@$1.local x2x -east -to :0.0
#ssh -XC pi@$1.local x2x -east -to :0.0
