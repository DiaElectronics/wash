#!/bin/bash

git reset --hard
git pull

if [ -f ./firmware.exe ]; then
  echo "copying firmware..."
  cp firmware.exe firmware.exe_
fi

