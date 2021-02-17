#include <stdio.h>
#include <err.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stddef.h>

#include <libusb.h>

typedef struct {
	uint8_t hdr;
	uint8_t rw;
	uint8_t led[6];
	uint8_t padding[56];
} packet;

/* XXX: This requires C11 */
_Static_assert(sizeof(packet) == 64);

enum {
	VID = 0x1c6c,  /* vendor ID */
	PID = 0xa002,  /* product ID */

	EP_IN  = 0x82, /* endpoint for input */
	EP_OUT = 0x02, /* endpoint for output */

	NUM_IFS = 2,   /* amount of interfaces */
};

int
main(void)
{
	int r;
	size_t i;
	packet pkt;
	libusb_device_handle *dev;

	if ((r = libusb_init(NULL)))
		errx(EXIT_FAILURE, "libusb_init failed: %d", r);

	if (!(dev = libusb_open_device_with_vid_pid(NULL, VID, PID)))
		errx(EXIT_FAILURE, "libusb_open_device_with_vid_pid failed");

	memset(&pkt, 0, sizeof(pkt));
	pkt.hdr = 0x06;
	pkt.rw = 1;
	pkt.led[0] = 0x02;  //restore to original status value
	pkt.led[1] = 0x01;  //force it to turn on
	pkt.led[2] = 0x00;  //force it to turn off
	pkt.led[3] = 0x01;  //force it to turn on
	pkt.led[4] = 0x02;  //restore numlock value
	pkt.led[5] = 0x02;  //restore capslock value

	libusb_set_auto_detach_kernel_driver(dev, 1);
	for (i = 0; i < NUM_IFS; i++) {
		r = libusb_claim_interface(dev, i);
		if (r)
			errx(EXIT_FAILURE, "libusb_claim_interface failed: %d\n", r);
	}

	r = libusb_interrupt_transfer(dev, EP_OUT, (char *)&pkt, sizeof(pkt), NULL, 0);
	printf("libusb_interrupt_transfer returned %d\n", r);

	for (i = 0; i < NUM_IFS; i++)
		libusb_release_interface(dev, 0);

	libusb_close(dev);
	libusb_exit(NULL);

	return EXIT_SUCCESS;
}
