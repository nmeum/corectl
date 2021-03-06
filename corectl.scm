(module corectl ()
  (import scheme (chicken base) (chicken condition)
          (chicken module) (chicken foreign)
          (srfi 1) (srfi 4))

  (export num-leds make-led-ctl close-led-ctl
          call-with-led-ctl led-ctl-write)

  (include "lib/util.scm")
  (include "lib/ffi.scm")
  (include "lib/libusb.scm")
  (include "lib/packet.scm")
  (include "lib/corectl.scm"))
