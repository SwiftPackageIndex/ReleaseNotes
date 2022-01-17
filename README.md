# spi-release-notes

`release-notes` is a Swift script that creates a list of links to release notes for package updates.

Running `release-notes` performs a `swift package update --dry-run` to find package updates and creates release notes URLs for these updates:

```
$ release-notes ~/Projects/SPI/spi-server

(... progress output removed)

Release notes URLs (updating from):
https://github.com/vapor/fluent-kit/releases (1.19.0)
https://github.com/apple/swift-llbuild/releases (main)
https://github.com/vapor/vapor/releases (4.54.0)
https://github.com/apple/swift-package-manager/releases (main)
https://github.com/vapor/async-kit/releases (1.11.0)
https://github.com/apple/swift-nio-ssl/releases (2.17.1)
https://github.com/apple/swift-tools-support-core/releases (main)
https://github.com/apple/swift-nio-transport-services/releases (1.11.3)
https://github.com/apple/swift-driver/releases (main)
https://github.com/apple/swift-nio/releases (2.36.0)
```

##

To install:

- clone this repository
- run `make install` to build and install the executable in `/usr/local/bin`
