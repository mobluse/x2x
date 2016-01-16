#!/bin/sh

ssh -X pi@$1.local x2x -east -to :0.0
#ssh -XC pi@$1.local x2x -east -to :0.0
