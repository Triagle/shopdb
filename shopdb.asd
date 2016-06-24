;;;; shopdb.asd

(asdf:defsystem #:shopdb
  :description "Describe shopdb here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:hunchentoot
               #:sxql
               #:sqlite
               #:cl-who
               #:cl-ppcre)
  :serial t
  :components ((:file "package")
               (:file "shopdb")))

