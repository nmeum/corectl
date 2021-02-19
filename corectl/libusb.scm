(define nullptr #f)
(define ifs '(0 1)) ;; TODO

(define-record-type <usb-endpoint>
  (%make-usb-endpoint usb-device addr)
  usb-endpoint?

  (usb-device usb-endpoint-device)
  (addr usb-endpoint-addr))

(define (make-usb-endpoint vid pid addr)
  (define (make-usb-device vid pid)
    (libusb-open nullptr vid pid))

  (let ((device (make-usb-device vid pid)))
    (if (not device)
      (error "make-usb-device failed")
      (begin
        (libusb-auto-detach device 1)
        (%make-usb-endpoint device addr)))))

(define (close-usb-endpoint endpoint)
  (libusb-close (usb-endpoint-device endpoint)))

(define (call-with-usb-endpoint endpoint proc)
  (define dev (usb-endpoint-device endpoint))
  (define (unclaim-and-close endpoint)
    (for-each
      (lambda (i)
        (libusb-release dev i)) ifs)
    (close-usb-endpoint endpoint))

  (with-exception-handler
    (lambda (x)
      (unclaim-and-close endpoint))
    (lambda ()
      (for-each
        (lambda (i)
          (let ((r (libusb-claim dev i)))
            (when (not (zero? r))
              (error "libusb-claim failed")))) ifs)

      (let ((r (proc endpoint)))
        (unclaim-and-close endpoint)
        r))))

(define (endpoint-transfer data endpoint)
  ;; TODO: Check return value
  ;; TODO: Check amount of transfered bytes

  (libusb-irq-transfer
    (usb-endpoint-device endpoint)
    (usb-endpoint-addr endpoint)
    data
    (u8vector-length data)
    nullptr
    0))
