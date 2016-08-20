(in-package #:database-test)

(plan 7)
;;; category?
(subtest "category? tests"
  ;; Expected behaviour: return true for any word that follows the pattern +word, e.g +hello, but not + hello or hello or simply +
  (diag "Expected behaviour: return true for any word that follows the pattern +word, e.g +hello, but not + hello or hello or simply +")
  (diag "Testing positive case")
  (ok (database::category? "+cpu"))
  (diag "Testing negative easy case")
  (ok (not (database::category? "Hello")))
  (diag "Testing empty category case")
  (ok (not (database::category? "+")))
  (diag "Testing whitespace category case")
  (ok (not (database::category? "+ cpu"))))

;;; separate
;; Expected behaviour: split a word by spaces
(subtest "separate test"
  (diag "Testing only positive case")
  (diag "Expected behaviour: split a word by spaces")
 (is (database::separate "Hello World") '("Hello" "World")))

;;; string-cdr
;; Expected behaviour: behave like cdr, but for strings
(subtest "string-cdr test"
 (diag "Testing only positive case")
 (is (database::string-cdr "Hello") "ello"))

;;; build-sql-query
;; Expected behaviour: build the appropriate sql query for searching the database when the given query specifies categories and when it doesn't
(subtest "build-sql-query tests"
  (diag "Expected behaviour: build the appropriate sql query for searching the database when the given query specifies categories and when it doesn't")
 (diag "Testing case WITH categories")
 (is (yield (database::build-sql-query "intel" '("cpu"))) "SELECT id, name, price, description FROM shop LEFT JOIN categories ON (shop.id = categories.shop_id) WHERE ((shop.name LIKE ?) AND (categories.category IN (?))) ORDER BY price DESC, name ASC")
 (diag "Testing case WITHOUT categories")
 (is (yield (database::build-sql-query "intel" nil)) "SELECT id, name, price, description FROM shop LEFT JOIN categories ON (shop.id = categories.shop_id) WHERE (shop.name LIKE ?) ORDER BY price DESC, name ASC"))

;;; parse-search
;; Expected behaviour: parse a query into it's keyword and categories
(subtest "parse-search tests"
  (diag "Expected behaviour: parse a query into it's keyword and categories")
  (diag "Testing case WITH categories")
  (is (parse-search "intel +cpu") '(:search ("intel") :categories ("cpu")))
  (diag "Testing case WITHOUT categories")
  (is (parse-search "intel") '(:search ("intel") :categories nil)))
;; End test

;;; run-db-search
;; Expected behaviour: Run database search
(subtest "run-db-search tests"
  (diag "Expected behaviour: Run database search")
  (diag "Testing case WITH categories")
  (is (run-db-search "Intel Core i5 +cpu" ) `((2 "Intel Core i5-4690K Devil's Canyon Quad-Core 3.5 GHz LGA 1150 88W BX80646I54690K Desktop Processor Intel HD Graphics 4600" 337.0d0 ,(format nil "Haswell~%Unlocked Multiplier~%Turbo Boost"))))
  (diag "Testing case WITHOUT categories")
  (is (run-db-search "Intel Core i5" ) `((2 "Intel Core i5-4690K Devil's Canyon Quad-Core 3.5 GHz LGA 1150 88W BX80646I54690K Desktop Processor Intel HD Graphics 4600" 337.0d0 ,(format nil "Haswell~%Unlocked Multiplier~%Turbo Boost")))))
;; End test

;;; get-product-for
;; Expected behaviour: retrieve a product from the database matching an id
(subtest "get-product-for tests"
  (diag "Expected behaviour: retrieve a product from the database matching an id")
  (diag "Test case WITH valid id")
  (is (get-product-for 2) `(2 "Intel Core i5-4690K Devil's Canyon Quad-Core 3.5 GHz LGA 1150 88W BX80646I54690K Desktop Processor Intel HD Graphics 4600" 337.0d0 ,(format nil "Haswell~%Unlocked Multiplier~%Turbo Boost")))
  (diag "Test case WITHOUT valid id")
  (is (get-product-for -1) nil))

;;; End all tests
(finalize)
