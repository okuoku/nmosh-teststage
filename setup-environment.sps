(import (rnrs)
        (shorten)
        (srfi :48)
        (yuni core)
        (yuni util files)
        (yuni util library-files))

(define repository-file (file->sexp-list "repository.scm"))
(define libraries-setting (assq 'libraries repository-file))

(define library-files '())
(define libraries '())
(define copytargets '())

(define-syntax append!
  (syntax-rules ()
    ((_ target str)
     (set! target (cons str target)))))

(define (append-library-file! s)
  (append! library-files s))

(define-syntax warn
  (syntax-rules ()
    ((_ arg ...)
     (format (current-error-port) arg ...))))

(define-syntax trace
  (syntax-rules ()
    ((_ text arg ...)
     (format (current-error-port) (string-append "---> " text "\n") arg ...))))

(unless libraries-setting
  (assertion-violation 'setup "[libraries] entry was not found"))

(trace "collecting libraries")

;; add all library collection
(for-each
  (^e
    (define (add! pth)
      (let ((ext (path-extension pth)))
        (define-syntax match-ext
          (syntax-rules ()
            ((_ check ...)
             (or (string=? check ext) ...))))
        (when (and ext (match-ext "scm" "ss" "sch" "sls"))
          (append-library-file! pth))))
    (when (string? e)
      (cond
        ((file-directory? e)
         (directory-walk e add!))
        ((file-regular? e)
         (add! e))
        (else
          (warn "entry ~a was ignored" e)))))
  libraries-setting)

(trace "~a file collected" (length library-files))

(trace "parsing libraries")

;; parse library file
(for-each
  (^e
    (let ((bundle (file->library-bundle e)))
      (for-each (^e (append! libraries e)) bundle)))
  library-files)

(trace "finish.")

;; calc desired library path

(define (path-sans-extension^2 x)
  ;; to drop flavor
  (path-sans-extension
    (path-sans-extension x)))

;; set copytargets
(let ((target-candidate 
        (filter (^e 
                  (let ((body-name (path-sans-extension^2 (path-basename (~ e 'path))))
                        (lib-name (symbol->path (car (reverse (~ e 'name))))))
                    (or (string=? body-name lib-name)
                        (begin (trace "drop ~a = ~a" (~ e 'path) (~ e 'name))
                               #f))))
                libraries)))
  (trace "~a target candidates" (length target-candidate))
  (for-all (^e 
             (define (make-path x)
               (string-append
                 (fold-left (^[cur e]
                              (string-append
                                cur
                                "/"
                                (symbol->path e)))
                            "lib"
                            (reverse (cdr (reverse (~ x 'name)))))
                 "/"
                 (path-basename (~ x 'path))))
             (append! copytargets
                      (cons (~ e 'path) (make-path e))))
           target-candidate))

(define (dig-target-dir pth) ;; == mkdir -p
  (define (itr pth)
    (unless (or (string=? "" pth) (file-exists? pth))
      (unless (file-exists? (path-dirname pth))
        (itr (path-dirname pth)))
      (trace "mkdir ~a" pth)
      (create-directory pth)))
  (itr (path-dirname pth)))

(define (copy/add-header c)
  (let ((src (car c))
        (dst (cdr c)))
    (when (file-exists? dst)
      (trace "remove ~a" dst)
      (delete-file dst))
    (with-output-to-file
      dst
      (^[]
        (for-each (^e (put-string (current-output-port) e)
                      (newline (current-output-port)))
                  (cons "#!r6rs" (file->string-list src)))))))

(for-each (^e (dig-target-dir (cdr e))) copytargets)
(for-each copy/add-header copytargets)
