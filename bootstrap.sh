swift build -c release --package-path ./OnlinePlayground -Xswiftc -Xclang-linker -Xswiftc -fuse-ld=lld
cp -R "$(swift build --package-path ./OnlinePlayground -c release --show-bin-path)"/* ./lib/

./setup_toolchains.sh
