#!/bin/bash

function program_is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo "$return_"
}

if [ $(program_is_installed xcrun) == 1 ]; then
    xcrun swift build -c debug
    xcrun swift run -c debug &
else
    swift build -c debug
    swift run -c debug &
fi

if [ $(program_is_installed npm) == 1 ]; then
    $(npm bin)/webpack -w
fi

killall -9 PlaygroundServer

