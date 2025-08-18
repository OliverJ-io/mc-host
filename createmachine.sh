#!/bin/sh

mkdir -p $PWD/machines/$1
mkdir -p $PWD/machines/$1/seed
cp $PWD/base-machine/seed/* $PWD/machines/$1/seed
cp $PWD/base-machine/ubuntu-arm64.qcow2 $PWD/machines/$1/ubuntu-arm64.qcow2
cp $PWD/firmware/edk2-aarch64-vars.fd $PWD/machines/$1