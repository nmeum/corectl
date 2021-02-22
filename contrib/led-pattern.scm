(import scheme (chicken base) (srfi 1) corectl)

(define (range upto)
  (if (zero? upto)
    '()
    (let ((i (- upto 1)))
      (append (range i) (list i)))))

(define (ntimes n proc)
  (define (%ntimes i proc)
    (when (< i n)
      (proc i)
      (%ntimes (+ i 1) proc)))

  (%ntimes 0 proc))

(define (led-list defval)
  (fold (lambda (x y)
          (append y (list (cons x defval))))
        '() (range num-leds)))

(define off-all (led-list 'off))
(define restore-all (led-list 'restore))

(define (led-pattern ctl)
  (ntimes num-leds
          (lambda (i)
            (let ((asc (fold (lambda (x y)
                               (cons
                                 (cons
                                   x
                                   (cond
                                     ((>= i x) 'on)
                                     (else     'off))) y)) '() (range num-leds))))
              (led-ctl-write ctl asc)
              (sleep 2)))))

(define (main)
  (let ((ctrl (make-led-ctl)))
    (call-with-led-ctl
      ctrl
      (lambda (c)
        (led-ctl-write c off-all)
        (sleep 1)
        (led-pattern c)
        (sleep 1)
        (led-ctl-write c restore-all)))))

(cond-expand
  ((or chicken-script compiling) (main))
  (else #t))
