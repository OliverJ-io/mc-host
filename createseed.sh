#!/bin/sh

# build iso image for cloud-init seed data
hdiutil makehybrid -o $PWD/machines/$1/seed.iso $PWD/machines/$1/seed -iso -joliet -default-volume-name cidata