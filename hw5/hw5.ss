; Return #t if obj is an empty listdiff, #f otherwise
(define (null-ld? obj) (if (or (null? obj) (not (pair? obj)))
		#f
		(eq? (car obj) (cdr obj))
	)
)

; Return #t if obj is a listdiff, #f otherwise
(define (listdiff? obj) (if (null-ld? obj)
		#t 
		(if (or (null? obj) (not (pair? obj)) (not (pair? (car obj))))
			#f
			(listdiff? (cons (cdr (car obj)) (cdr obj)))
		)
	)
)	

; Return a listdiff whose first element is obj and whose remaining elements are listdiff
; Unlike cons, the last argument cannot be an arbitrary object; it must be a listdiff
(define (cons-ld obj listdiff) (if (not (listdiff? listdiff))
		(error "The provided listdiff is invalid")
		(cons (cons obj (car listdiff)) (cdr listdiff))
	)
)

; Return the first element of listdiff
; It is an error if listdiff has no elements
(define (car-ld listdiff) (if (or (not (listdiff? listdiff)) (null-ld? listdiff))
		(error "The provided listdiff is invalid or has no elements")
		(car (car listdiff))
	)
)

; Return a listdiff containing all but the first element of listdiff
; It is an error if listdiff has no elements
(define (cdr-ld listdiff) (if (or (not (listdiff? listdiff)) (null-ld? listdiff))
		(error "The provided listdiff is invalid or has no elements")
		(cons (cdr (car listdiff)) (cdr listdiff))
	)
)

; Return a newly allocated listdiff of its arguments
(define (listdiff obj . args) (cons (cons obj args) '()))

; Return the length of listdiff
(define (length-ld listdiff) (define (length-ld-tail listdiff l) (if (not (listdiff? listdiff))
			(error "The provided listdiff is invalid")
			(if (null-ld? listdiff)
				l
				(length-ld-tail (cdr-ld listdiff) (+ l 1))
			)
		)
	)
	(length-ld-tail listdiff 0)
)

; Return a listdiff consisting of the elements of the first listdiff followed by the elements of the other listdiffs
; The resulting listdiff is always newly allocated, except that it shares structure with the last argument
; Unlike append, the last argument cannot be an arbitrary object; it must be a listdiff
(define (append-ld listdiff . args) (if (not (listdiff? listdiff))
		(error "A provided listdiff is invalid")
		(if (= (length args) 0)
			listdiff
			(apply append-ld (cons (append (take (car listdiff) (length-ld listdiff)) (car (car args))) (cdr (car args))) (cdr args))
		)
	)
)

; Find the first pair in alistdiff whose car field is eq? to obj, and return that pair
; If there is no such pair, return #f
; alistdiff must be a listdiff whose members are all pairs
(define (assq-ld obj alistdiff) (if (not (listdiff? alistdiff))
		(error "The provided listdiff is invalid")
		(if (or (null-ld? alistdiff) (not (pair? (car alistdiff))))
			#f
			(if (eq? (car (car (car alistdiff))) obj)
				(car (car alistdiff))
				(assq-ld obj (cons (cdr (car alistdiff)) (cdr alistdiff)))
			)
		)
	)
)

; Return a listdiff that represents the same elements as the provided list
(define (list->listdiff list) (apply listdiff list))

; Return a list that represents the same elements as listdiff
(define (listdiff->list listdiff) (take (car listdiff) (length-ld listdiff)))

; Return a Scheme expression that, when evaluated, will return a copy of listdiff, that is, a listdiff that has the same top-level data structure as listdiff
; Assume that the argument listdiff contains only booleans, characters, numbers, and symbols
(define (expr-returning listdiff) `(cons ',(listdiff->list listdiff) (quote ())))
