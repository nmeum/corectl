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

(define (make-led-control)
  (make-usb-endpoint vid pid out-addr))

(define (close-led-control ctl)
  (close-usb-endpoint ctl))

(define (state->number state)
  (if (number? state)
    state
    (cond
      ((eq? state 'on)      pkt-on)
      ((eq? state 'off)     pkt-off)
      ((eq? state 'restore) pkt-restore)
      (else (error "unknown LED state")))))

(define (range upto)
  (if (zero? upto)
    '()
    (let ((i (- upto 1)))
      (append (range i) (list i)))))

(define (assoc->list asc)
  (fold (lambda (x ys)
          (let ((pair (assoc x asc)))
            (append ys
                    (list (if pair
                            (state->number (cdr pair))
                            pkt-restore)))))
        '() (range num-leds)))

(define (serialize asc)
  (define padding (make-list pkt-pad 0))

  (list->u8vector
    (append
      (list pkt-hdr pkt-rw)
      (assoc->list asc)
      padding)))

(define (write-led ctl asc)
  (if (< num-leds (length asc))
    (error "invalid association list length")
    (call-with-usb-endpoint
      ctl
      (lambda (endpoint)
        (endpoint-transfer
          (serialize asc)
          endpoint)))))
