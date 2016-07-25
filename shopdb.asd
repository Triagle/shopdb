;;;; shopdb.asd

(asdf:defsystem #:shopdb
  :description "Describe shopdb here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:hunchentoot
               #:sxql
               #:sqlite
               #:cl-who
               #:iterate
               #:cl-ppcre)
  :serial t
  :components ((:file "package")
               (:file "src/database")
               (:file "src/shopdb")
               (:file "src/sxql-composer"))
  :in-order-to ((test-op (test-op shop-test))))
(defsystem #:shop-test
  :depends-on (:shopdb
               :prove)
  :defsystem-depends-on (:prove-asdf)
  :components
  ((:file "test-package")
   (:file "src/database")
   (:test-file "test/database"))
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run) :prove) c)))
