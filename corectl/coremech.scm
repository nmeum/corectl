(define vid #x1c6c)
(define pid #xa002)

(define in-addr  #x82)
(define out-addr #x002)

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

(define-record-type <led-control>
  (%make-led-control in out)
  led-control?

  (in  led-control-in)
  (out led-control-out))

(define (make-led-control)
  (when (zero? num-allocs)
    (libusb-init #f)
    (set! num-allocs (inc num-allocs)))

  ;; TODO: If the second make-usb-endpoint fails, free the first
  (%make-led-control
    (make-usb-endpoint vid pid in-addr)
    (make-usb-endpoint vid pid out-addr)))

(define (close-led-control ctl)
  (begin
    (close-usb-endpoint (led-control-in ctl))
    (close-usb-endpoint (led-control-out ctl)))

  (if (zero? (begin
               (set! num-allocs (dec num-allocs))
               num-allocs))
    (libusb-exit #f)))

(define (write-leds ctl asc)
  (if (< num-leds (length asc))
    (error "invalid association list length")
    (call-with-usb-endpoint
      (led-control-out ctl)
      (lambda (endpoint)
        (endpoint-transfer
          (marshal asc)
          endpoint)))))

(define (read-leds ctl)
  (call-with-usb-endpoint
    (led-control-in ctl)
    (lambda (endpoint)
      (let ((data (make-u8vector num-leds)))
        (endpoint-transfer data endpoint)
        (unmarshal data)))))
