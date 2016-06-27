;;;; package.lisp

(defpackage #:shopdb
  (:use #:cl #:hunchentoot #:cl-who))
(defpackage #:resources
  (:use #:cl #:sqlite))
(defpackage #:database
  (:use #:cl #:resources #:sqlite #:cl-ppcre))
(defpackage #:database-test
  (:use #:cl #:prove  #:database #:sqlite)
  )
