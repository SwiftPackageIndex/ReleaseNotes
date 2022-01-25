# swift-release-notes

`swift-release-notes` is a Swift script that creates a list of links to release notes for package updates.

Running `swift release-notes` performs a `swift package update --dry-run` to find package updates and creates release notes URLs for these updates:

(Note that executables named with a `swift-` prefix can be called via `swift ...`, making them appear like `swift` subcommands.)

```
$ swift release-notes ~/Projects/SPI/spi-server

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

## Installation
### Using [Mint](https://github.com/yonaskolb/mint)

```
$ mint install SwiftPackageIndex/ReleaseNotes
```

### Installing from source

You can also build and install from source by cloning this project and running
`make install` (macOS 11 or later | Linux).

Manually
Run the following commands to build and install manually:

```
$ git clone https://github.com/SwiftPackageIndex/ReleaseNotes.git
$ cd ReleaseNotes
$ make install
```
