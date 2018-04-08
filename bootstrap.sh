#!/bin/bash

# Bootstrap Swift environment for Playground

function program_is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo "$return_"
}

function install_toolchain {
    SWIFT_VERSION=$1
    SWIFT_TARGET=$2
    if [ ! -d "Toolchains/swift-$SWIFT_VERSION-RELEASE.xctoolchain" ]; then
        case "$SWIFT_TARGET" in
        *osx)
            mkdir -p Toolchains/swift-$SWIFT_VERSION-RELEASE.xctoolchain
            # download
            curl -O https://swift.org/builds/swift-$SWIFT_VERSION-release/xcode/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-$SWIFT_TARGET.pkg
            # extract
            xar -xf swift-$SWIFT_VERSION-RELEASE-$SWIFT_TARGET.pkg -C Toolchains/
            tar -xzf Toolchains/swift-$SWIFT_VERSION-RELEASE-$SWIFT_TARGET-package.pkg/Payload -C Toolchains/swift-$SWIFT_VERSION-RELEASE.xctoolchain
            # cleanup
            rm Toolchains/Distribution
            rm -r Toolchains/swift-$SWIFT_VERSION-RELEASE-$SWIFT_TARGET-package.pkg
            rm -r swift-$SWIFT_VERSION-RELEASE-$SWIFT_TARGET.pkg
            ;;
        ubuntu*)
            mkdir -p Toolchains/swift-$SWIFT_VERSION-RELEASE.xctoolchain
            # download
            curl -O https://swift.org/builds/swift-$SWIFT_VERSION-release/ubuntu1404/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-$SWIFT_TARGET.tar.gz
            # extract
            tar -xvzf swift-$SWIFT_VERSION-RELEASE-$SWIFT_TARGET.tar.gz -C Toolchains/swift-$SWIFT_VERSION-RELEASE.xctoolchain --strip-components=1
            # cleanup
            rm -rf swift-$SWIFT_VERSION-RELEASE-$SWIFT_TARGET.tar.gz
            ;;
        esac
    fi
}

function build_onlineplayground {
    SWIFT_VERSION="$1-RELEASE"

    ONLINE_PLAYGROUND_DIR="OnlinePlayground/OnlinePlayground-$SWIFT_VERSION"
    Toolchains/swift-$SWIFT_VERSION.xctoolchain/usr/bin/swift build --package-path $ONLINE_PLAYGROUND_DIR --static-swift-stdlib --build-path $ONLINE_PLAYGROUND_DIR/.build -c release
    Toolchains/swift-$SWIFT_VERSION.xctoolchain/usr/bin/swift build --package-path $ONLINE_PLAYGROUND_DIR --static-swift-stdlib --build-path $ONLINE_PLAYGROUND_DIR/.build -c debug -Xswiftc -DDEBUG
}

if [ $(program_is_installed npm) == 1 ]; then
    npm install
fi

if [ $(program_is_installed xcrun) == 1 ]; then
    # Install Toolchains
    install_toolchain "4.1" "osx"
    install_toolchain "4.0.3" "osx"
else
    # Install Toolchains
    install_toolchain "4.1" "ubuntu14.04"
    install_toolchain "4.0.3" "ubuntu14.04"
fi

# Build OnlinePlayground
build_onlineplayground "4.0.3"
build_onlineplayground "4.1"