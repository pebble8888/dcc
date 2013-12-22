#!/usr/bin/env bash

RELATIVE_PATH="`dirname \"$0\"`"
ABSOLUTE_PATH="`( cd \"$RELATIVE_PATH\" && pwd )`"

USER_HOME=$(eval echo ~${SUDO_USER})
MY_PATH=$USER_HOME/bin

if [ -d $MY_PATH ]; then
  mkdir -p $MY_PATH
fi

cd $MY_PATH
ln -sf $ABSOLUTE_PATH/dcc.rb dcc.rb
