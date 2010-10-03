;; library list.
(libraries
  "repos/dharmalab"
  "repos/lcs/lcs.scm"
  "repos/mpl"
  "repos/smathml/sitelib/smathml"
  "repos/surfage"
  "repos/sxml/sitelib/sxml"
  "repos/xitomatl"
  "repos/xunit/xunit.sls"
  "repos/yuni"
  "repos/racket/collects/tests/r6rs"
  "repos/mosh/lib")

(set dharmalab
     (basedir "repos/dharmalab/tests")
     (tests
       "records.sps"
       "records-typed-fields.sps"))
(set lcs
     (basedir "repos/lcs")
     (tests
       "test.scm"))

(set mpl
     (basedir "repos/mpl")
     (tests "test.sps"))

(set smathml
     (basedir "repos/smathml/tests/smathml")
     (tests "content.scm"))

(set r6rs-test-suite
     (basedir "repos/racket/collects/tests/r6rs")
     (tests
       "run.sps"
       "run-via-eval.sps"))

(set clisp-number-tests
     (basedir "external/clisp-number-tests")
     (tests
       "clisp-number-tests.sps"))

(set trigtest
     (basedir "external/trigtest")
     (tests
       "trigtest.sps"))

(set surfage
     (basedir "repos/surfage/tests")
     (tests
       "and-let.sps"
       "compare-procedures.sps"
       "eager-comprehensions.sps"
       "intermediate-format-strings.sps"
       "lists.sps"
       "multi-dimensional-arrays.sps"
       ;; multi-dimensional-arrays--arlib ??
       "os-environment-variables.sps"
       "print-ascii.sps"
       "random-conftest.sps"
       "random.sps"
       "rec-factorial.sps"
       "records.sps"
       "s26-cut.sps"
       "s78-lightweight-testing.sps"
       "testing.sps"
       "time.sps"
       "vectors.sps"))

(set sxml
     (basedir "repos/sxml/tests/sxml")
     (tests
       "serialize.scm"
       "ssax.scm"))

(set xunit
     (basedir "repos/xunit/tests")
     (tests
       "test.scm"
       "failure.scm"))

(set mosh
     (name "mosh test-suite")
     (basedir "repos/mosh/test")
     (tests
       "misc.scm"
       "testing.scm"
       "mosh-test.scm"
       "io-error.scm"
       "input-output-port.scm"
       ((source "input-port.scm")
        (stdin "input.txt"))
       "output-port.scm"
       ((source "record.scm")
        ;; (add-loadpath "test/mylib")
        ignore)
       "condition.scm"
       "rbtree-test.scm"
       "exception.scm"
       "unicode.scm"
       "srfi8.scm"
       "srfi19.scm"
       "mysql.scm"
       "clos.scm"
       "dbi.scm"
       "srfi-misc.scm"
       "lists.scm"
       "socket.scm"
       "match.scm"
       "print.scm"
       "concurrent.scm"
       "concurrent-crash.scm"
       "number.scm"
       "cgi.scm"
       "memcached.scm"
       "shorten.scm"
       ((source "import_bad_regexp.scm")
        ignore)
       ((source "import_good_regexp.scm")
        ignore)
       ((source "error-with-circular.scm")
        ignore)
       ((source "ffi.scm")
        ignore)
       ((source "shared.scm")
        ignore)
       ((source "shared2.scm")
        ignore)
       ((source "shared3.scm")
        ignore)
       ((source "fasl.scm")
        (count 2))
       "nmosh.scm"
       "nrepl.scm")
     )



