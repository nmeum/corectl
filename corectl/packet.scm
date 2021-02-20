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

;; TODO: Return association list
(define (unmarshal data)
  (if (not (eq? (u8vector-length data) data-size))
    (error "invalid data length")
    (let* ((lst (u8vector->list data))
           (pkt (drop-right lst pkt-pad)))
      (if (not (eq? (car lst) pkt-hdr))
        (error "missing packet header")
        (map number->state
             (cddr lst)))))) ;; cddr → skip rw field
