# SwiftPlayground.run

[![Platform](https://img.shields.io/badge/Platforms-macOS%20%7C%20Linux-4E4E4E.svg?colorA=28a745)](#installation)
[![Twitter](https://img.shields.io/badge/twitter-@krzyzanowskim-blue.svg?style=flat&colorB=64A5DE&label=Twitter)](http://twitter.com/krzyzanowskim)

Online Swift Playground. Implemented in Swift.

TBA. Checkout http://SwiftPlayground.run

![SwiftPlayground.run](https://swiftplayground.run/assets/screenshot.png)

## Installation

```
$ git clone https://github.com/krzyzanowskim/OnlineSwiftPlayground.git
$ cd swiftplayground
$ npm install
$ swift run -c release
```

## Xcode development

```
$ swift package generate-xcodeproj
```

## Docker

```
$ git clone https://github.com/krzyzanowskim/OnlineSwiftPlayground.git
$ cd swiftplayground
$ docker build -t onlineswiftplayground .
$ docker run --rm -it -p 8080:8080 --name onlineswiftplayground -t onlineswiftplayground
```

Playground is available at http://localhost:8080
If the docker setup uses VirtualBox, the you can get the IP from `docker-machine ip` command.

```
$ open http://$(docker-machine ip):8080
```

## Config

Third party frameworks should be copied to `Frameworks` directory.

See `config/` for GitHub auth. sample config.

## Author

SwiftPlayground.run is owned and maintained by [Marcin Krzyżanowski](http://www.krzyzanowskim.com)

You can follow me on Twitter at [@krzyzanowskim](http://twitter.com/krzyzanowskim) for project updates and releases.

## License

See LICENSE file.
