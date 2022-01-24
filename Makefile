build:
	swift build -c release

test:
	swift test

install: build
	install "$(shell swift build -c release --show-bin-path)/swift-release-notes" /usr/local/bin/
