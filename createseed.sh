#!/bin/sh

# build iso image for cloud-init seed data
hdiutil makehybrid -o seed-$1.iso seed-$1 -iso -joliet -default-volume-name cidata