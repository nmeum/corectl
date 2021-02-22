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
  (define (conf-if state)
    (let ((proc (cond
                  ((eq? state 'claim) libusb-claim)
                  ((eq? state 'release) libusb-release)
                  (else (abort "unknown interface state")))))
      (for-each
        (lambda (i)
          (when (not (zero? (proc dev i)))
            (error "interface state change failed"))) ifs)))

  (let ((r (call-with-current-continuation
             (lambda (k)
               (with-exception-handler
                 (lambda (x)
                   (conf-if 'release))
                 (lambda ()
                   (conf-if 'claim)
                   (proc endpoint)))))))
    (if (condition? r)
      (signal r)
      (conf-if 'release))))

;; TODO: Swap arguments
(define (endpoint-transfer data endpoint)
  (let-location ((t int))
    (if (not (zero?
               (libusb-irq-transfer
                 (usb-endpoint-device endpoint)
                 (usb-endpoint-addr endpoint)
                 data
                 (u8vector-length data)
                 (location t)
                 0)))
      (error "libusb-irq-transfer failed")
      t)))
