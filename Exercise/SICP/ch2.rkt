#lang sicp

; Exercise 2.17
(define (last-pair alist)
  (if (null? (cdr alist)) (car alist) (last-pair (cdr alist))))
(last-pair (list 23 72 149 34))

; Exercise 2.18
(define (reverse alist)
  (if (null? (cdr alist))
      alist
      (append (reverse (cdr alist))
              (list (car alist)))))
(reverse (list 1 4 9 16 25))

; Exercise 2.21
(define (square-list alist)
  (map (lambda (x) (* x x)) alist))
(square-list (list 1 2 3 4))

; Example
(define (count-leaves x)
  (cond ((null? x) 0)
        ((not (pair? x)) 1)
        (else (+ (count-leaves (car x))
                 (count-leaves (cdr x))))))
(count-leaves (cons (list 1 2) (list 3 4)))

; Exercise 2.25
(define ex2.25_1 (list 1 3 (list 5 7) 9))
(define ex2.25_2 (list (list 7)))
(define ex2.25_3 (list 1 (list 2 (list 3 (list 4 (list 5 (list 6 7)))))))
(car (cdr (car (cdr (cdr ex2.25_1)))))
(car (car ex2.25_2))
(car (cdr (car (cdr (car (cdr (car (cdr (car (cdr (car (cdr ex2.25_3))))))))))))

; Exercise 2.26
(define ex2.26_x (list 1 2 3))
(define ex2.26_y (list 4 5 6))
(append ex2.26_x ex2.26_y) ; (1 2 3 4 5 6)
(cons ex2.26_x ex2.26_y) ; ((1 2 3) 4 5 6)
(list ex2.26_x ex2.26_y) ; ((1 2 3) (4 5 6))

; Exercise 2.27
(define (deep-reverse alist)
  (if (pair? alist)
      (reverse (map deep-reverse alist))
      alist))
(deep-reverse (list (list 1 2) (list 3 4)))

; Exercise 2.28
(define (fringe alist)
  (cond ((null? alist) '())
        ((pair? alist)
         (append (fringe (car alist))
                 (fringe (cdr alist))))
        (else (list alist))))
(fringe (list (list 1 2) (list 3 4)))

; Exercise 2.30
(define (square-tree atree)
  (map (lambda (subtree)
         (if (pair? subtree)
             (square-tree subtree)
             (* subtree subtree)))
       atree))
(square-tree (list 1 (list 2 (list 3 4) 5) (list 6 7)))

; Exercise 2.31
(define (tree-map proc atree)
  (map (lambda (subtree)
         (if (pair? subtree)
             (tree-map proc subtree)
             (proc subtree)))
       atree))
(define (square-tree_ tree) (tree-map (lambda (x) (* x x)) tree))
(square-tree_ (list 1 (list 2 (list 3 4) 5) (list 6 7)))

; Exercise 2.32
(define (subsets s)
  (if (null? s)
      (list nil)
      (let ((rest (subsets (cdr s))))
        (append rest (map
                      (lambda (x) (cons (car s) x))
                      rest)))))
(subsets (list 1 2 3))

; Example
(define (filter predicate sequence)
  (cond ((null? sequence) nil)
        ((predicate (car sequence))
         (cons (car sequence) (filter predicate (cdr sequence))))
        (else (filter predicate (cdr sequence)))))
(filter odd? (list 1 2 3 4 5))

; Example
(define (accumulate op initial sequence)
  (if (null? sequence)
      initial
      (op (car sequence)
          (accumulate op initial (cdr sequence)))))
(accumulate + 0 (list 1 2 3 4 5))
(accumulate cons nil (list 1 2 3 4 5))

; Exercise 2.33
(define (map_ p sequence)
  (accumulate (lambda (x y) (cons (p x) y)) nil sequence))
(map_ (lambda (x) (+ x 2)) (list 1 2 3 4 5))

(define (append_ seq1 seq2) ; wtf
  (accumulate cons seq2 seq1))
(append_ (list 1 2 3) (list 4 5 6))

(define (length sequence)
  (accumulate (lambda (_x _y) (+ 1 _y)) 0 sequence))
(length (list 1 2 3 4 6))

; Exercise 2.35
(define (count-leaves_ t)
  (accumulate + 0
              (map (lambda (node)
                     (if (pair? node) (count-leaves_ node) 1))
                   t)))
(count-leaves_ (list 1 (list 2 (list 3 4) 5) (list 6 7)))

; Exercise 2.36
(define (accumulate-n op init seqs)
  (if (null? (car seqs))
      nil
      (cons (accumulate op init (map
                                 (lambda (x) (car x))
                                 seqs))
            (accumulate-n op init (map
                                   (lambda (x) (cdr x))
                                   seqs)))))
(accumulate-n + 0 (list (list 1 2 3) (list 4 5 6) (list 7 8 9) (list 10 11 12)))

; Exercise 2.37
(define (dot-product v w)
  (accumulate + 0 (map * v w)))
(dot-product (list 1 2 3 4) (list 2 3 4 5))

(define (matrix-*-vector m v)
  (map (lambda (x) (dot-product x v)) m))
(matrix-*-vector (list (list 1 2) (list 2 3)) (list 1 1))

(define (transpose mat)
  (accumulate-n cons nil mat))
(transpose (list (list 1 2 3 4) (list 2 3 4 5)))

(define (matrix-*-matrix m n)
  (let ((cols (transpose n)))
    (map
     (lambda (x) (matrix-*-vector cols x))
     m)))
(matrix-*-matrix (list (list 1 2)
                       (list 3 4))
                 (list (list 1 2)
                       (list 3 4)))

; Exercise 2.42
; (length (queens 8)) == 92
; (length (queens 11)) == 2680

; Example
(define (memq item x)
  (cond ((null? x) false)
        ((eq? item (car x)) x)
        (else (memq item (cdr x)))))
(memq 'apple '(pear banana prune))

; Exercise 2.53
(list 'a 'b 'c) ; (a b c)
(list (list 'george)) ; ((george))
(cdr '((x1 x2) (y1 y2))) ; (y1 y2)
(cadr '((x1 x2) (y1 y2))) ; (car ((y1 y2))) -> (y1 y2)
(pair? (car '(a short list))) ; #f
(memq 'red '((red shoes) (blue socks))) ; #f
(memq 'red '(red shoes blue socks)) ; (red shoes blue socks)

; Exercise 2.54
(define (_equal? a b)
  (if (and (pair? a) (pair? b))
      (and (_equal? (car a) (car b)) (_equal? (cdr a) (cdr b)))
      (eq? a b)))
(_equal? '(1 (2 3) 3) '(1 (2 3) 3))

; Exercise 2.55
(car ''abracadabra)
; (car (quoat 'abracadabra))
; (car (quoat (quoat abracadabra)))

; Example 符号求导
(define (=number? exp num)
  (and (number? exp) (= exp num)))
(define (variable? x) (symbol? x))
(define (same-variable? v1 v2)
  (and (variable? v1) (variable? v2) (eq? v1 v2)))
(define (make-sum a1 a2)
  (cond ((=number? a1 0) a2)
        ((=number? a2 0) a1)
        ((and (number? a1) (number? a2)) (+ a1 a2))
        (else (list '+ a1 a2))))
(define (make-product a1 a2)
  (cond ((or (=number? a1 0) (=number? a2 0)) 0)
        ((=number? a1 1) a2)
        ((=number? a2 1) a1)
        ((and (number? a1) (number? a2)) (* a1 a2))
        (else (list '* a1 a2))))
(define (sum? x)
  (and (pair? x) (eq? (car x) '+)))
(define (addend s) (cadr s))
(define (augend s) (caddr s))
(define (product? x)
  (and (pair? x) (eq? (car x) '*)))
(define (multiplier s) (cadr s))
(define (multiplicand s) (caddr s))

(define (deriv exp var)
  (cond ((number? exp) 0) ; 数字
        ((variable? exp)
         (if (same-variable? exp var) 1 0)) ; 同变量
        ((sum? exp)
         (make-sum (deriv (addend exp) var)
                   (deriv (augend exp) var)))
        ((product? exp)
         (make-sum (make-product (multiplier exp)
                                 (deriv (multiplicand exp) var))
                   (make-product (deriv (multiplier exp) var)
                                 (multiplicand exp))))
        (else (error "unknown expression -- DERIV" exp))))

(deriv '(+ x 3) 'x)

; Example
