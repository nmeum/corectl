(define (inc n) (+ n 1))
(define (dec n) (- n 1))

(define (range upto)
  (if (zero? upto)
    '()
    (let ((i (dec upto)))
      (append (range i) (list i)))))
