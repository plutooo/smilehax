#!/bin/bash
wd=$(pwd)
make clean && HTTP_BASE=http://192.168.1.102:8000 make && cd build/ && python2 -m SimpleHTTPServer
cd $wd
