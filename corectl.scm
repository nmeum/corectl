(module corectl ()
  (import scheme (chicken base) (chicken module) (chicken foreign)
          (srfi 4))

  (export libusb-open)

  (export libusb-init libusb-exit)

  (export make-usb-endpoint close-usb-endpoint
          call-with-usb-endpoint endpoint-transfer)

  (include "corectl/ffi.scm")
  (include "corectl/libusb.scm"))
