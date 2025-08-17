#!/bin/sh

mkdir -p $PWD/machines/$1
mkdir -p $PWD/machines/$1/seed
cp $PWD/machine-base/seed/* $PWD/machines/$1/seed
cp $PWD/machine-base/ubuntu-arm64.qcow2 $PWD/machines/$1/ubuntu-arm64.qcow2