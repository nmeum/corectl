(module corectl ()
  (import scheme (chicken base) (chicken module) (chicken foreign)
          (srfi 4))

  (include "corectl/ffi.scm"))
