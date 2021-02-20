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

(define-record-type <led-control>
  (%make-led-control in out)
  led-control?

  (in  led-control-in)
  (out led-control-out))

(define (make-led-control)
  (%make-led-control
    (make-usb-endpoint vid pid in-addr)
    (make-usb-endpoint vid pid out-addr)))

(define (close-led-control ctl)
  (close-usb-endpoint (led-control-in ctl))
  (close-usb-endpoint (led-control-out ctl)))

(define (state->number state)
  (if (number? state)
    state
    (cond
      ((eq? state 'on)      pkt-on)
      ((eq? state 'off)     pkt-off)
      ((eq? state 'restore) pkt-restore)
      (else (error "unknown LED state")))))

(define (number->state number)
  (cond
    ((eq? number pkt-on)      'on)
    ((eq? number pkt-off)     'off)
    ((eq? number pkt-restore) 'restore)
    (else (error "unknown LED state"))))

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

(define (marshal asc)
  (define padding (make-list pkt-pad 0))

  (list->u8vector
    (append
      (list pkt-hdr pkt-rw)
      (assoc->list asc)
      padding)))

(define (unmarshal data)
  (if (not (eq? (u8vector-length data) data-size))
    (error "invalid data length")
    (let* ((lst (u8vector->list data))
           (pkt (drop-right lst pkt-pad)))
      (if (not (eq? (car lst) pkt-hdr))
        (error "missing packet header")
        (map number->state
             (cddr lst)))))) ;; cddr → skip rw field

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
