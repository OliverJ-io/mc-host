#!/bin/sh
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
sudo arp -d -a