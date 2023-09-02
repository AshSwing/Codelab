#lang sicp

; Exercise 1.11
; f(n) =
;       n                                if n < 3
;       f(n-1) + 2f(n-2) + 3f(n-3)       else
(define (_ex1.11_iter n)
  (cond ((< n 3) n)
        (else (+ (_ex1.11_iter (- n 1))
                 (* 2 (_ex1.11_iter (- n 2)))
                 (* 3 (_ex1.11_iter (- n 3)))))))

(define (_ex1.11_recu n)
  (define (_fn fn-1 fn-2 fn-3) (+ fn-1 (* 2 fn-2) (* 3 fn-3)))
  (define (_recu fn-1 fn-2 fn-3 i)
    (cond ((< n 3) n)
          ((= i n) (_fn fn-1 fn-2 fn-3))
          (else (_recu (_fn fn-1 fn-2 fn-3) fn-1 fn-2 (inc i)))))
  (_recu 2 1 0 3))

; (_ex1.11_iter 7)
; (_ex1.11_recu 7)

(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a) (sum term (next a) next b))))

; Exercise 1.29
(define (simpson-integral f a b n)
  (define h (/ (- b a) n))
  (define (next _n) (+ _n (* 2. h)))
  (define (term _a) (+ (f _a) (* 4 (f (+ _a h))) (f (+ _a (* 2 h)))))
  (* (sum term a next b) (/ h 3)))

(define (cube x) (* x x x))
(simpson-integral cube 0 1 1000)

; Exercise 1.30
(define (sum-iter term a next b)
  (define (iter a result)
    (if (> a b)
        result
        (iter (next a) (+ result (term a)))))
  (iter a 0))
(define (simpson-integral-iter f a b n)
  (define h (/ (- b a) n))
  (define (next _n) (+ _n (* 2. h)))
  (define (term _a) (+ (f _a) (* 4 (f (+ _a h))) (f (+ _a (* 2 h)))))
  (* (sum-iter term a next b) (/ h 3)))
(simpson-integral-iter cube 0 1 1000)

; Exercise 1.32