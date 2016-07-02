(in-package #:database-test)

(plan 2)

;;; parse-search test
;; Expected behaviour: parse a query into it's keyword and catagories
(is (parse-search "intel +cpu") '(:search ("intel") :categories ("cpu")))
;; end test

;;; construct-db-search test
;; Expected behaviour: convert search into a valid sql query
(is (construct-db-search "intel +cpu") "select (id, price, name, thumbnail, description) from shop inner join catagories on shop.id = catagories.shop_id where shop.name like '%intel%' and catagories.category in ('cpu')")
(is (construct-db-search "intel + cpu") 'malformed-search)
;; end test
