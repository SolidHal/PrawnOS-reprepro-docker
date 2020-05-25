#!/bin/bash

export CONFIG_FOLDER=~/reprepro-dockerfs/reprepro-config/
export REPO_FOLDER=~/reprepro-dockerfs/repos/

rm -rf $REPO_FOLDER/*
rm -rf $CONFIG_FOLDER/var
rm -rf $CONFIG_FOLDER/etc
