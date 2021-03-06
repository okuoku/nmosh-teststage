(import (rnrs)
        (shorten)
        (srfi :48)
        (yuni core)
        (yuni util files)
        (yuni util library-files))

(define repository-file (file->sexp-list "repository.scm"))
(define libraries-setting (assq 'libraries repository-file))
(define resources-setting (assq 'resources repository-file))

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

(define (makelib fn)
  (guard
    (c (#t (trace "ignore ~a\n" fn)
        #f))
    (file->library-bundle fn)))

(define (dig-target-dir pth) ;; == mkdir -p
  (define (itr pth)
    (unless (or (string=? "" pth) (file-exists? pth))
      (unless (file-exists? (path-dirname pth))
        (itr (path-dirname pth)))
      (trace "mkdir ~a" pth)
      (create-directory pth)))
  (itr (path-dirname pth)))

;; FIXME...
(define (copy-file from to)
  (dig-target-dir to)
  (when (file-exists? to)
    (delete-file to))
  (with-output-to-file
    to
    (^[] (for-each (^e (put-string (current-output-port) e)
                       (newline (current-output-port)))
                   (file->string-list from)))))

(define (proc-resource e)
  (define dirs '())
  (define files '())
  (define target)

  (define (lib->dir l)
    (fold-left (^[cur e] (path-append cur e))
               "lib"
               (map symbol->path l)))

  ;; read settings
  (let loop ((cur e))
    (if (eq? '=> (car cur))
      (set! target (lib->dir (cadr cur)))
      (begin (append! dirs (car cur))
             (loop (cdr cur)))))
  ;; proc
  (for-each (^e (directory-walk e (^f (append! files f))))
            dirs)
  (display target)(newline)
  
  ;; copy
  (for-each (^e (let ((b (path-basename e)))
                  (copy-file e (path-append target
                                            b))))
            files))

(unless libraries-setting
  (assertion-violation 'setup "[libraries] entry was not found"))

(unless resources-setting
  (assertion-violation 'setup "[resources] entry was not found"))

(trace "collecting libraries")

;; remove current library collection
(directory-walk "lib" delete-file)

;; distribute resource file
(for-each
  (^e (proc-resource e))
  (cdr resources-setting))

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
          (warn "entry ~a was ignored\n" e)))))
  libraries-setting)

(trace "~a file collected" (length library-files))

(trace "parsing libraries")

;; parse library file
(for-each
  (^e
    (let ((bundle (makelib e)))
      (when bundle
        (for-each (^e (append! libraries e)) bundle))))
  library-files)


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
                    (string=? body-name lib-name)))
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


(define (copy/add-header c)
  (let ((src (car c))
        (dst (cdr c)))
    (when (file-exists? dst)
      (delete-file dst))
    (with-output-to-file
      dst
      (^[]
        (for-each (^e (put-string (current-output-port) e)
                      (newline (current-output-port)))
                  (cons "#!r6rs" (file->string-list src)))))))

(trace "creating target dirs")
(for-each (^e (dig-target-dir (cdr e))) copytargets)
(trace "copy and injecting #!r6rs")
(for-each copy/add-header copytargets)
(trace "done.")
