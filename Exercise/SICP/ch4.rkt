#lang sicp

; Primitive Backup
(define apply-in-underlying-scheme apply)

; 语法分析
(define (tagged-list? exp tag) ; 判断是否为 tag 开头的语句
  (if (pair? exp) (eq? (car exp) tag) false))

(define (lambda? exp) (tagged-list? exp 'lambda)) ; 判断是否为 Lambda
(define (lambda-parameters exp) (cadr exp))
(define (lambda-body exp) (cddr exp))
(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body)))

(define (compound-procedure? p) ; 是否为复合过程
  (tagged-list? p 'procedure))

(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

(define (make-begin seq) (cons 'begin seq))

(define (make-procedure parameters body env)
  (list 'procedure parameters body env))

(define (self-evaluating? exp) ; 是否为自求值表达式
  (cond ((number? exp) true)   ; 数字
        ((string? exp) true)   ; 字符串
        (else false)))

(define (variable? exp) (symbol? exp)) ; 是否为变量

(define (quoted? exp) (tagged-list? exp 'quote)) ; 是否为 'quote 表达式
(define (text-of-quotation exp) (cadr exp)) ; 取对应的表达式

(define (assignment? exp) (tagged-list? exp 'set!)) ; 是否为赋值
(define (assignment-variable exp) (cadr exp))
(define (assignment-value exp) (caddr exp))

(define (definition? exp) (tagged-list? exp 'define)) ; 是否为声明
(define (definition-variable exp)
  (if (symbol? (cadr exp))
      (cadr exp) ; 取数据绑定
      (caadr exp))) ; 取过程绑定
(define (definition-value exp)
  (if (symbol? (cadr exp))
      (caddr exp) ; 取数据绑定
      (make-lambda (cdadr exp) (cddr exp))))

(define (if? exp) (tagged-list? exp 'if))
(define (if-predicate exp) (cadr exp))
(define (if-consequent exp) (caddr exp))
(define (if-alternative exp)
  (if (not (null? (cdddr exp)))
      (cadddr exp)
      'false))
(define (eval-if exp env)
  (if (true? (eval (if-predicate exp) env))
      (eval (if-consequent exp) env)
      (eval (if-alternative exp) env)))

(define (begin? exp) (tagged-list? exp 'begin))
(define (begin-actions exp) (cdr exp))
(define (last-exp? seq) (null? (cdr seq)))
(define (first-exp seq) (car seq))
(define (rest-exps seq) (cdr seq))

(define (sequence->exp seq)
  (cond ((null? seq) seq)
        ((last-exp? seq) (first-exp seq)) ; 如果是序列最后一项, 就直接表达式
        (else (make-begin seq)))) ; 如果不是最后一项, 就用 begin 包住

(define (application? exp) (pair? exp)) ; 是否应用就看是否为 Pair
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))
(define (no-operands? ops) (null? ops)) ; 判断 operands 是否为空
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))

(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-predicate clause) (car clause))
(define (cond-actions clause) (cdr clause))
(define (cond-else-clause? clause)
  (eq? (cond-predicate clause) 'else))
(define (expand-clauses clauses)
  (if (null? clauses)
      'false
      (let ((first (car clauses))
            (rest (cdr clauses)))
        (if (cond-else-clause? first)
            (if (null? rest)
                (sequence->exp (cond-actions first))
                (error "ELSE clause isn't last -- COND->IF")) ; 如果是 else 句
            (make-if (cond-predicate first)
                     (sequence->exp (cond-actions first))
                     (expand-clauses rest))))))
(define (cond->if exp)
  (expand-clauses (cond-clauses exp)))

(define (procedure-parameters p) (cadr p)) ; ('procedure parameter body env)
(define (procedure-body p) (caddr p))
(define (procedure-environment p) (cadddr p))

; 环境操作
; lookup-variable-value 环境中查找值
; extend-environment 扩充环境
; define-variable! 环境中添加值
; set-variable-value! 环境中修改值
(define (make-frame variables values) (cons variables values))
(define (frame-variables frame) (car frame))
(define (frame-values frame) (cdr frame))

(define (enclosing-environment env) (cdr env)) ; 获取外围环境
(define (first-frame env) (car env)) ; 获取当前 Frame
(define the-empty-environment '()) ; 空环境

(define (add-binding-to-frame! var val frame)
  (set-car! frame (cons var (car frame)))
  (set-cdr! frame (cons val (cdr frame))))

(define (extend-environment vars vals base-env)
  (if (= (length vars) (length vals))
      (cons (make-frame vars vals) base-env)
      (if (< (length vars) (length vals))
          (error "Too many arguments supplied" vars vals)
          (error "Too few arguments supplied" vars vals))))

(define (lookup-variable-value var env) ; 在 env 中找 var 的值
  (define (env-loop env)
    (define (scan vars vals) ; 扫描 {vars: vals} 对
      (cond ((null? vars)
             (env-loop (enclosing-environment env)))
            ((eq? var (car vars))
             (car vals))
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        (error "Unbound variable" var)
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop env))

(define (set-variable-value! var val env) ; 在 env 中找 var 的值
  (define (env-loop env)
    (define (scan vars vals) ; 扫描 {vars: vals} 对
      (cond ((null? vars)
             (env-loop (enclosing-environment env)))
            ((eq? var (car vars))
             (set-car! vals val))
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        (error "Unbound variable -- SET!" var)
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop env))

(define (define-variable! var val env) ; 在 env 中找 var 的值
  (let ((frame (first-frame env)))
    (define (scan vars vals)
      (cond ((null? vals)
             (add-binding-to-frame! var val frame))
            ((eq? var (car vars))
             (set-car! vals val))
            (else (scan (cdr vars) (cdr vals)))))
    (scan (frame-variables frame)
          (frame-values frame))))
; 环境初始化

(define (true? x) (not (eq? x false)))
(define (false? x) (eq? x false))
(define (primitive-procedure? proc)
  (tagged-list? proc 'primitive))
(define (primitive-implementation proc) (cadr proc))
(define primitive-procedures
  (list (list 'car car)
        (list 'cdr cdr)
        (list 'cons cons)
        (list 'null? null?)
        (list 'number? number?)
        (list 'string? string?)
        (list 'true? true?)
        (list 'false? false?)))
(define (primitive-procedure-names)
  (map car primitive-procedures))
(define (primitive-procedure-objects)
  (map (lambda (proc)
         (list 'primitive (cadr proc))) primitive-procedures))

(define (apply-primitive-procedure proc args)
  (apply-in-underlying-scheme
   (primitive-implementation proc) args))

(define (setup-environment)
  (let ((initial-env
         (extend-environment (primitive-procedure-names)
                             (primitive-procedure-objects)
                             the-empty-environment)))
    (define-variable! 'true true initial-env)
    (define-variable! 'false false initial-env)
    initial-env))

; interactive
(define input-prompt ";;; M-Eval input:")
(define output-prompt ";;; M-Eval value:")

(define (prompt-for-input string)
  (newline) (newline) (display string) (newline))
(define (announce-output string)
  (newline) (display string) (newline))
(define (user-print object)
  (if (compound-procedure? object)
      (display (list 'compound-procedure
                     (procedure-parameters object)
                     (procedure-body object)
                     '<procedure-env>))
      (display object)))
(define the-global-environment (setup-environment))

; Meta
(define (eval-assignment exp env)
  (set-variable-value! (assignment-variable exp)
                       (eval (assignment-value exp) env)
                       env)
  'ok)

(define (eval-definition exp env)
  (define-variable! (definition-variable exp)
    (eval (definition-value exp) env)
    env)
  'ok)

(define (eval-sequence exps env)
  (cond ((last-exp? exps) (eval (first-exp exps) env))
        (else (eval (first-exp exps) env)
              (eval-sequence (rest-exps exps) env))))

(define (list-of-values exps env)
  (if (no-operands? exps)
      '()
      (cons (eval (first-operand exps) env)
            (list-of-values (rest-operands exps) env))))

(define (apply* procedure arguments)
  (cond ((primitive-procedure? procedure)
         (apply-primitive-procedure procedure arguments))
        ((compound-procedure? procedure)
         (eval-sequence
          (procedure-body procedure)
          (extend-environment
           (procedure-parameters procedure)
           arguments
           (procedure-environment procedure))))
        (else (error "Unknown procedure type -- APPLY" procedure))))

(define (eval exp env)
  (cond ((self-evaluating? exp) exp) ; 自求值
        ((variable? exp) (lookup-variable-value exp env)) ; 变量
        ((quoted? exp) (text-of-quotation exp)) ; 双引号表达式
        ((assignment? exp) (eval-assignment exp env)) ; 赋值表达式
        ((definition? exp) (eval-definition exp env)) ; 声明表达式
        ((if? exp) (eval-if exp env)) ; 条件表达式
        ((lambda? exp) ; Lambda 表达式
         (make-procedure (lambda-parameters exp)
                         (lambda-body exp)
                         env))
        ((begin? exp) ; Begin 表达式
         (eval-sequence (begin-actions exp) env))
        ((cond? exp) (eval (cond->if exp) env)) ; cond 表达式转 if
        ((application? exp) ; 嵌套调用
         (apply* (eval (operator exp) env)
                 (list-of-values (operands exp) env)))
        (else (error "Unknown expression type --EVAL" exp))))

(define (driver-loop)
  (prompt-for-input input-prompt)
  (let ((input (read)))
    (let ((output (eval input the-global-environment)))
      (announce-output output-prompt)
      (user-print output)))
  (driver-loop))

(driver-loop)