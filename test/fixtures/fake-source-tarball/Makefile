include config.mk

all: out/fake-bin

out/fake-bin: VERSION
	mkdir -p out
	printf '#!/bin/sh\necho %s\n' "$$(cat VERSION)" > out/fake-bin
	chmod +x out/fake-bin

install: all
	mkdir -p "$(PREFIX)/bin"
	cp out/fake-bin "$(PREFIX)/bin/node"
	cp out/fake-bin "$(PREFIX)/bin/iojs"

.PHONY: all install
