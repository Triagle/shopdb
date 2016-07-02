(in-package #:database-test)

(plan 2)

;;; parse-search test
;; Expected behaviour: parse a query into it's keyword and catagories
(is (parse-search "intel +cpu") '(:search ("intel") :categories ("cpu")))
;; end test

;;; construct-db-search test
;; Expected behaviour: Run database search
(is (run-db-search "test" ) '((1 "tes" "test" "test" "test" "test")))

;; end test
