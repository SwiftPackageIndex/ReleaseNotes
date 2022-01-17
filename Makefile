build:
	swift build -c release

test:
	swift test

install: build
	install "$(shell swift build -c release --show-bin-path)/release-notes" /usr/local/bin/
