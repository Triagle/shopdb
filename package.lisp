;;;; package.lisp
(defpackage #:resources
  (:use #:cl #:sqlite)
  (:export *db*))
(defpackage :sxql.composer
  (:use :cl)
  (:export :and-where
   :or-where
           :where=
   :from=
           :from+
   :fields=
           :fields+
   :limit=
           :offset=
   :order-by=
           :group-by=
   :order-by+
           :group-by+
   :returning=
           :having=)
  (:documentation "Dynamic SXQL query composition"))
(defpackage #:database
  (:use #:cl #:resources #:sqlite #:sxql #:sxql.composer #:cl-ppcre)
  (:export parse-search run-db-search get-product-for))
(defpackage #:shopdb
  (:use #:cl #:hunchentoot #:cl-who #:database))
