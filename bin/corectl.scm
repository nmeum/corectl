(import scheme
        (chicken base)
        (chicken process-context)
        (chicken string)
        corectl)

(define (string->led s)
  (define (led-num x)
    (if (number? x) x
      (let* ((lst1 (string-split x "LED"))
             (lst2 (string-split x "led"))
             (num  (cond
                     ((eq? (length lst1) 1) (car lst1))
                     ((eq? (length lst2) 1) (car lst2))
                     (else #f))))
        (if num (string->number num) #f))))

  (let ((n (led-num s)))
    (if (and n (< n 6))
      n
      (error "unknown LED"))))

(define (string->state s)
  (cond
    ((equal? s "on")      'on)
    ((equal? s "off")     'off)
    ((equal? s "restore") 'restore)
    (else (error "invalid LED state"))))

(define (parse-leds input)
  (map
    (lambda (x)
      (let ((pair (string-split x ":")))
        (if (not (eq? (length pair) 2))
          (error "invalid input pair")
          (cons
            (string->led (car pair))
            (string->state (cadr pair))))))
    input))

(define (main)
  (let* ((leds (parse-leds (command-line-arguments)))
         (ctrl (make-led-ctl)))
    (call-with-led-ctl
      ctrl (lambda (c) (led-ctl-write c leds)))))

(cond-expand
  ((or chicken-script compiling) (main))
  (else #t))
