(define (state->number state)
  (if (number? state)
    state
    (cond
      ((eq? state 'on)      pkt-on)
      ((eq? state 'off)     pkt-off)
      ((eq? state 'restore) pkt-restore)
      (else (error "unknown LED state")))))

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
