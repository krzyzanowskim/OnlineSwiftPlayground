#!/bin/bash
SWIFT_VERSION="5.7-RELEASE"
SWIFT="Toolchains/swift-$SWIFT_VERSION.xctoolchain/usr/bin/swift"

. bootstrap.sh

# Run
npx webpack

$SWIFT run -c release --scratch-path .build/swift-$SWIFT_VERSION PlaygroundServer serve --hostname 0.0.0.0 &

npx webpack -w

killall -9 PlaygroundServer
