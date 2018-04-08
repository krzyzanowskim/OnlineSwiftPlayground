#!/bin/bash
SWIFT_VERSION="4.0.3"
TOOLCHAIN_SWIFT="Toolchains/swift-$SWIFT_VERSION-RELEASE.xctoolchain/usr/bin/swift"

. bootstrap.sh

# Generate Xcode projects
if [ $(program_is_installed xcrun) == 1 ]; then
    $TOOLCHAIN_SWIFT package generate-xcodeproj
fi

# Run
$TOOLCHAIN_SWIFT run -c release --static-swift-stdlib --build-path .build/swift-$SWIFT_VERSION-RELEASE &

if [ $(program_is_installed npm) == 1 ]; then
    $(npm bin)/webpack -w
fi

killall -9 PlaygroundServer

