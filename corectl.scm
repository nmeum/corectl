(module corectl ()
  (import scheme (chicken base) (chicken condition) (chicken module) (chicken foreign)
          (srfi 1) (srfi 4))

  (export make-led-control close-led-control write-leds read-leds)

  (include "corectl/util.scm")
  (include "corectl/ffi.scm")
  (include "corectl/libusb.scm")
  (include "corectl/packet.scm")
  (include "corectl/coremech.scm"))
