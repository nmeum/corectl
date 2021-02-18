(foreign-declare "#include <libusb.h>")

(define-foreign-type vid short)
(define-foreign-type pid short)

(define-foreign-type libusb-ctx (c-pointer "libusb_context"))
(define-foreign-type libusb-handle (c-pointer "libusb_device_handle"))

(define libusb-init
  (foreign-lambda void "libusb_init" (c-pointer libusb-ctx)))
(define libusb-open
  (foreign-lambda libusb-handle "libusb_open_device_with_vid_pid" libusb-ctx vid pid))
(define libusb-auto-detach
  (foreign-lambda void "libusb_set_auto_detach_kernel_driver" libusb-handle int))

(define libusb-claim
  (foreign-lambda int "libusb_claim_interface" libusb-handle int))
(define libusb-release
  (foreign-lambda int "libusb_release_interface" libusb-handle int))

(define libusb-irq-transfer
  (foreign-lambda
    int
    "libusb_interrupt_transfer"
    libusb-handle
    unsigned-byte
    nonnull-u8vector
    int
    (c-pointer int)
    unsigned-int))

(define libusb-close
  (foreign-lambda void "libusb_close" libusb-handle))
(define libusb-exit
  (foreign-lambda void "libusb_exit" libusb-ctx))
