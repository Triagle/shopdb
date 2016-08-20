(in-package #:database)
(defparameter *db-path* (concatenate 'string (namestring (car (directory #P".."))) "res/db/shop.db"))
(defmacro with-shop-db (&body body)
  `(with-open-database (db *db-path*)
    (progn
       ,@body)))
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
(defun get-product-for (id)
  (with-shop-db
    (car (or (execute-to-list db  (yield (select :* (from :shop) (where (:= :id id)))) id) '(nil)))))
(defun get-products-for (ids)
  (mapcar #'get-product-for ids))
(defun build-sql-query (search-term categories)
  (let ((q (select (:id :name :price :description)
             (from :shop)
             (left-join :categories :on (:= :shop.id :categories.shop_id))
              (order-by (:desc :price) (:asc :name))
             (where (:like :shop.name (format nil "%~a%" search-term))))))
    (when categories (and-where q `(:in :categories.category ,categories)))
    q))
(defun all-rows (statement rows)
  (loop for i from 0 upto rows
        collect (statement-column-value statement i)))
(defun run-db-search (string)
  (let ((lexed-search (parse-search string)))
    (multiple-value-bind (query args) (yield (build-sql-query (format nil "~{~a~^ ~}"(getf lexed-search :search)) (getf lexed-search :categories)))
      (with-shop-db
        (remove-duplicates
         (loop
          with statement = (prepare-statement db query)
          while (step-statement statement)
            initially (loop for arg in args
                            for i from 1 upto (length args)
                            do (bind-parameter statement i arg))
          collect (all-rows statement 3)
          finally (finalize-statement statement)) :key #'car)))))
