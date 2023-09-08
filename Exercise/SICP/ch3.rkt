#lang sicp

; Example
(define balance 100)
(set! balance (- balance 10))
(display balance)
(display "\n")
(begin (set! balance (- balance 10)) balance)

; Example
(define new-withdraw
  (let ((balance 100))
    (lambda (amount)
      (if (>= balance amount)
          (begin (set! balance (- balance amount)) balance)
          "Insufficient funds"))))
(new-withdraw 100)
(new-withdraw 1)

; Exercise 3.1
(define (make-accumulator base)
  (lambda (addon) (begin (set! base (+ base addon)) base)))
(define A (make-accumulator 5))
(A 10)
(A 10)

; Exercise 3.2
(define (make-monitored f)
  (define counter 0)
  (lambda (x)
    (if (eq? x 'how-many-calls?)
        counter
        (begin (set! counter (inc counter)) (f x)))))
(define s (make-monitored sqrt))
(s 100)
(s 128)
(s 'how-many-calls?)

; Exercise 3.12
(define (last-pair x)
  (if (null? (cdr x))
      x
      (last-pair (cdr x))))
(define (append! x y)
  (set-cdr! (last-pair x) y) x)
(define x (list 'a 'b))
(define y (list 'c 'd))
(define z (append x y))
z
(cdr x) ; ('b)
(define w (append! x y))
w ; (a b c d)
(cdr x) ; (b c d)

; Exercise 3.14
(define (mystery x)
  (define (loop x y)
    (if (null? x)
        y
        (let ((temp (cdr x)))
          (set-cdr! x y) ; x 只修改了这一次 (x1 x2 ...) -> (x1)
          (loop temp x))))
  (loop x '()))

(define v (list 'a 'b 'c 'd))
(define v2 (mystery v))
v
v2

; Example Queue
(define (front-ptr queue) (car queue))
(define (rear-ptr queue) (cdr queue))
(define (set-front-ptr! queue item) (set-car! queue item)) ; 修改前端指针
(define (set-rear-ptr! queue item) (set-cdr! queue item)) ; 修改尾端指针

(define (empty-queue? queue) (null? (front-ptr queue))) ; 前端指针为空, 表示空队列
(define (make-queue) (cons '() '())) ; 定义空队列
(define (front-queue queue)
  (if (empty-queue? queue)
      (error "FRONT called with an empty queue" queue)
      (car (front-ptr queue))))
(define (insert-queue! queue item)
  (let ((new-pair (cons item '())))
    (cond ((empty-queue? queue)
           (set-front-ptr! queue new-pair)
           (set-rear-ptr! queue new-pair)
           queue)
          (else
           (set-cdr! (rear-ptr queue) new-pair)
           (set-rear-ptr! queue new-pair)
           queue))))
(define (delete-queue! queue)
  (cond ((empty-queue? queue)
         (error "DELETE! called with an empty queue" queue))
        (else
         (set-front-ptr! queue (cdr (front-ptr queue)))
         queue)))
(define q1 (make-queue))
(insert-queue! q1 'a)
(front-queue q1)
(insert-queue! q1 'b)
(delete-queue! q1)
(delete-queue! q1)

; Exercise 3.23 Deque
; (make-deque)
; (empty-deque? adeq)
; (front-deque adeq)
; (rear-deque adeq)
; (front-insert-deque! adeq)
; (rear-insert-deque! adeq)
; (front-delete-deque! adeq)
; (rear-delete-deque! adeq)

; Example
(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))
(define (stream-ref s n) ; 取流中第 n 个值
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))
; (define (stream-map proc s) ; 流映射, 使用 cons-stream 构造仍然为一个流
;   (if (stream-null? s)
;       the-empty-stream
;       (cons-stream (proc (stream-car s))
;                    (stream-map proc (stream-cdr s)))))
(define (stream-map proc . argstreams)
  (if (stream-null? (car argstreams))
      the-empty-stream
      (cons-stream
       (apply proc (map stream-car argstreams))
       (apply stream-map
              (cons proc (map stream-cdr argstreams))))))
(define (stream-for-each proc s)
  (if (stream-null? s)
      'done
      (begin (proc (stream-car s))
             (stream-for-each proc (stream-cdr s)))))

; (define (display-line x) (newline) (display x))
; (define (display-stream s) (stream-for-each display-line s))

(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))
(define integers (integers-starting-from 1))
(stream-car integers)
(stream-cdr integers)

; Exercise 3.53
; (1 2 4 8 16 ...)

; Exercise 3.54
(define (mul-streams s1 s2)
  (stream-map * s1 s2))
(define factorials (cons-stream 1 (mul-streams integers factorials)))

; Example Display Stream
(define (display-line x) (display " ") (display x))
(define (stream-for-each-head proc s head)
  (if (or (stream-null? s) (= head 0))
      'done
      (begin (proc (stream-car s))
             (stream-for-each-head proc (stream-cdr s) (- head 1)))))
(define (display-stream-head s head)
  (stream-for-each-head display-line s head)
  (newline))

(display-stream-head factorials 5)

; Exercise 3.55
(define (add-streams s1 s2)
  (stream-map + s1 s2))
(define (partial-sums astream)
  (add-streams astream (cons-stream 0 (partial-sums astream))))
(define ex3.55 (partial-sums integers))
(display-stream-head ex3.55 10)

; Exercise 3.56
(define (merge s1 s2)
  (cond ((stream-null? s1) s2)
        ((stream-null? s2) s1)
        (else
         (let ((s1car (stream-car s1))
               (s2car (stream-car s2)))
           (cond ((< s1car s2car)
                  (cons-stream s1car (merge (stream-cdr s1) s2)))
                 ((> s1car s2car)
                  (cons-stream s2car (merge s1 (stream-cdr s2))))
                 (else
                  (cons-stream s1car
                               (merge (stream-cdr s1)
                                      (stream-cdr s2)))))))))

(define (scale-stream s n)
  (cons-stream (* n (stream-car s)) (scale-stream (stream-cdr s) n)))
(define S (cons-stream 1 (merge
                          (scale-stream S 2)
                          (merge (scale-stream S 3) (scale-stream S 5)))))
(display-stream-head S 10)

(quotient 10 7)