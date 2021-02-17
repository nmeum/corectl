LIBUSB ?= libusb-1.0

CFLAGS += $(shell pkg-config --cflags $(LIBUSB))
LDLIBS += $(shell pkg-config --libs $(LIBUSB))

main: main.c
