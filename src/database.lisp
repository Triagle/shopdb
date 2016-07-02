(in-package #:database)
(defun category? (string)
  "Returns t if string is a category, nil otherwise"
  (not (null (scan "(?:\\+\\w+)" string)))) ;; check that the string matches the following pattern +[word] where word denotes the catagory
(defun separate (string)
  (split " " string))
(defun string-cdr (string)
  (subseq string 1))
(defun parse-search (search)
  "Parse search into constituents"
  (let* ((tokens (separate search))
         (categories (mapcar #'string-cdr (remove-if-not #'category? tokens)))
         (search-terms (remove-if #'category? tokens)))
    (list :search search-terms :categories categories)))
