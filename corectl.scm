(module corectl ()
  (import scheme (chicken base) (chicken condition)
          (chicken module) (chicken foreign)
          (srfi 1) (srfi 4))

  (export make-led-ctl close-led-ctl led-ctl-write)

  (include "lib/util.scm")
  (include "lib/ffi.scm")
  (include "lib/libusb.scm")
  (include "lib/packet.scm")
  (include "lib/corectl.scm"))
