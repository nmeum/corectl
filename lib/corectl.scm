(define vid #x1c6c)
(define pid #xa002)

(define in-addr  #x81)
(define out-addr #x02)

(define num-leds 6)
(define data-size 64)

(define pkt-hdr #x06)
(define pkt-pad 56)
(define pkt-rw 1)
(define pkt-on 1)
(define pkt-off 0)
(define pkt-restore 2)

;; Poor man's garbage collection
(define num-allocs 0)

(define (make-led-control)
  (when (zero? num-allocs)
    (libusb-init #f)
    (set! num-allocs (inc num-allocs)))
  (make-usb-endpoint vid pid out-addr))

(define (close-led-control ctl)
  (close-usb-endpoint ctl)
  (if (zero? (begin
               (set! num-allocs (dec num-allocs))
               num-allocs))
    (libusb-exit #f)))

(define (write-leds ctl asc)
  (if (< num-leds (length asc))
    (error "invalid association list length")
    (call-with-usb-endpoint
      ctl
      (lambda (endpoint)
        (endpoint-transfer
          (marshal asc)
          endpoint)))))
