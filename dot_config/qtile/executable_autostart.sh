#!/bin/bash

#Check if already running

function run() {
  if ! pgrep $1 ;
  then $@&
  fi
}

run barrierc --daemon --enable-crypto DESKTOP-2EMC4UT &
run variety &
run picom &
