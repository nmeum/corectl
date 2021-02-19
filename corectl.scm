(module corectl ()
  (import scheme (chicken base) (chicken condition) (chicken module) (chicken foreign)
          (srfi 1) (srfi 4))

  (export libusb-open)

  (export libusb-init libusb-exit)

  (export make-usb-endpoint close-usb-endpoint
          call-with-usb-endpoint endpoint-transfer)

  (include "corectl/ffi.scm")
  (include "corectl/libusb.scm")
  (include "corectl/coremech.scm"))
