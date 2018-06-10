#!/bin/bash
SWIFT_VERSION="4.1.2-RELEASE"
SWIFT="Toolchains/swift-$SWIFT_VERSION.xctoolchain/usr/bin/swift"

. bootstrap.sh

# Generate Xcode projects
if [ $(program_is_installed xcrun) == 1 ]; then
    echo "Generate Xcode project..."
    $SWIFT package generate-xcodeproj
fi

# Run
if [ $(program_is_installed npm) == 1 ]; then
    $(npm bin)/webpack
fi

$SWIFT run -c release --static-swift-stdlib --build-path .build/swift-$SWIFT_VERSION &

if [ $(program_is_installed npm) == 1 ]; then
    $(npm bin)/webpack -w
fi

killall -9 PlaygroundServer

