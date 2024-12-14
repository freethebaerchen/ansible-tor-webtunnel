#!/bin/sh

cp -r /tmp/.ssh/ ~/.ssh/
chmod -R 600 ~/.ssh

eval $@