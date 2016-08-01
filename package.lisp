;;;; package.lisp
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
  (:use #:cl #:sqlite #:sxql #:sxql.composer #:cl-ppcre)
  (:export parse-search run-db-search get-product-for))
(defpackage #:shopdb
  (:use #:cl #:parenscript #:hunchentoot #:cl-who #:database))
