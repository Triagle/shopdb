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
(defun build-sql-query (search-term categories)
  (let ((q (select (:id :name :price :description)
             (from :shop)
             (left-join :categories :on (:= :shop.id :categories.shop_id))
              (order-by (:desc :price) (:asc :name))
             (where (:like :shop.name (format nil "%~a%" search-term))))))
    (when categories (and-where q `(:in :categories.category ,categories)))
    q))
(defun run-db-search (string)
  (let ((lexed-search (parse-search string)))
    (multiple-value-bind (query args) (yield (build-sql-query (car (getf lexed-search :search)) (getf lexed-search :categories)))
      (with-open-database (db "/home/jake/repos/cl/shopdb/res/db/shop.db")
        (remove-duplicates (eval `(execute-to-list ,db ,query ,@args)) :key #'car)))))
