#lang racket

;------------Part 1

(define lambsym (string->symbol "\u03BB"))

(define expr-compare (lambda (x y)
	(cond [(equal? x y) x]
	 [(equal? x #t) '%]
	 [(equal? x #f) '(not %)]
	 [(and (not (list? x)) (not (equal? x y))) 
		`(if % ,x ,y)] 
	 [(or (and (list? x) (equal? (car x) 'quote)) 
		(and (list? y) (equal? (car y) 'quote)))
		`(if % ,x ,y)]
	 [(or (and (list? x) (list? y) (equal? (car x) 'if) 
		(not (equal? (car y) 'if)))
		(and (list? x) (list? y) (equal? (car y) 'if) 
		(not (equal? (car x) 'if)))) `(if % ,x ,y)]
	 [(= (length x) (length y)) 
		;check to see if you have lambda
		;and the variable list for lambdas are different
		(if (and  
			(or (equal? (car x) 'lambda) (equal? (car x) lambsym))
			(or (equal? (car y) 'lambda) (equal? (car y) lambsym)))
			;if both start with lambda:
			(let ([varsx (car (cdr x))] [varsy (car (cdr y))])
			  (if (or (not (list? varsx)) (not (list? varsy))) `(if % ,x ,y)  ;add case where both aren't lists
			  (if (equal? (length varsx) (length varsy))
			      (if (equal? varsx varsy)
				  ;variable lists of lambdas are the same
				  (if (or (equal? (car x) lambsym) (equal? (car y) lambsym))
					(cons lambsym
					 (cons varsx 
					   (expr-compare (cdr (cdr x)) (cdr (cdr y)))))
					(cons 'lambda
                                         (cons varsx 
                                           (expr-compare (cdr (cdr x)) (cdr (cdr y))))))
				  ;variable lists of lambdas have same length 
				  ;but different variables, a!b
				(let ([rvars (replace-vars varsx varsy)] [xbodies (car (cdr (cdr x)))] [ybodies (car (cdr (cdr y)))])
				  (if (or (and (list? xbodies) (list? ybodies))
					;if both bodies are lists or both are single symbols 
					(and (not (list? xbodies)) (not (list? ybodies)))) 
				  (if (or (equal? (car x) lambsym) (equal? (car y) lambsym))
					(expr-compare `(,lambsym ,rvars ,(replace-bodies varsx rvars xbodies))
                                  	`(,lambsym ,rvars ,(replace-bodies varsy rvars ybodies)))
					(expr-compare `(lambda ,rvars ,(replace-bodies varsx rvars xbodies)) 
					  `(lambda ,rvars ,(replace-bodies varsy rvars ybodies))))
				  (if (or (equal? (car x) lambsym) (equal? (car y) lambsym))
					`(,lambsym rvars (if % ,xbodies ,ybodies))
					`(lambdarvars (if % ,xbodies ,ybodies))))))
			      `(if % ,x ,y))))

		(cons (expr-compare (car x) (car y)) 
			(expr-compare (cdr x) (cdr y))))]
	 [(not (= (length x) (length y))) `(if % ,x ,y)])))


;x and y are the var lists/elements from lambdas
;compare them and return the matched vars
(define replace-vars (lambda (x y)
	(if (not (list? x))
	  (if (equal? x y) x
	  (string->symbol (string-append (symbol->string x) "!" (symbol->string y))))
	  (if (equal? (length x) 1)
		`(,(replace-vars (car x) (car y)))
		(cons (replace-vars (car x) (car y)) (replace-vars (cdr x) (cdr y)))))))

(define getconvertedsym (lambda (originals converts sym)
	(let ([x (member sym originals)]) 
	  (if (equal? x #f) #f
	    (if (equal? (length x) (length converts))
		(car converts)
		(getconvertedsym originals (cdr converts) sym))))))

(define replace-bodies (lambda (o v b)
   (if (and (list? b) (list? (car b)) (or (equal? 'lambda (car (car b))) (equal? lambsym (car (car b))))) 
      (cons (car b) (replace-bodies o v (cdr b))) 
      (if (not (list? b))
	(let ([y (getconvertedsym o v b)])
	  (if (equal? y #f) b y))
	(if (equal? (length b) 1)
	   (list (replace-bodies o v (car b)))
	   (cons (replace-bodies o v (car b)) (replace-bodies o v (cdr b))))))))



;------------Part 2

(define test-expr-compare (lambda (x y)
	(let ([xeval (eval x)]
	      [yeval (eval y)]
	      [xcompeval (eval (switchsyms (expr-compare x y) '% '#t))]
	      [ycompeval (eval (switchsyms (expr-compare x y) '% '#f))])
	     (if (and (equal? xeval xcompeval) (equal? yeval ycompeval)) #t #f))))

(define switchsyms (lambda (lst a b)
	(if (not (list? lst)) 
	  (if (equal? lst a) b lst)
	  (if (equal?(length lst) 1)
	    (if (list? (car lst)) (list (switchsyms (car lst) a b))
	    (if (equal? (car lst) a) '(a) lst))
	    
	    (if (equal? (car lst) a)
		(cons b (switchsyms (cdr lst) a b))
		(if (list? (car lst)) (cons (switchsyms (car lst) a b) (switchsyms (cdr lst) a b)) 
		  (cons (car lst) (switchsyms (cdr lst) a b))))))))


;------------Part 3

(define test-expr-x '((lambda (y) (* y y)) ((lambda (x) (+ x x)) (* 3 4))))
(define test-expr-y '((λ (a) (* a a)) ((lambda (b) (+ b b)) (* 3 4))))


