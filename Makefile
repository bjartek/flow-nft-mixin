all: mixin

.PHONY: emulator
emulator:
	flow emulator start -v

.PHONY: mixin
mixin:
	go run ./main.go
