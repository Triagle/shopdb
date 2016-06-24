;;;; shopdb.lisp

(in-package #:shopdb)
(defparameter *hunchentoot-port* 7070)
(defun start-server ()
  (defparameter *hunchentoot-server* (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port *hunchentoot-port*))))
(defun restart-server ()
  (stop-server)
  (start-server))
(defun stop-server ()
  (hunchentoot:stop *hunchentoot-server*))
;;; front end webserver

;; We'll use skeleton.css for the formatting of the webpage
;; You can find that in the res/css and res/images folders



(define-easy-handler (lander :uri "/") ()
  (redirect "/search"))
;; TODO implement a macro that generates handlers for css rules
(define-easy-handler (skeleton-handler :uri ""))
(define-easy-handler (search-handler :uri "/search") ()
  (with-html-output-to-string (s)
    (:html
     (:head
      ;; Some specifics for mobile phones
      (:meta :name "viewport" :content "width=device-width, initial-scale=1")
      ;; The suggested font from Skeleton.css
      (:link :href "https://fonts.googleapis.com/css?family=Raleway:400,300,600" :rel "stylesheet" :type "text/css")
      ;; Actual CSS
      (:link :rel "stylesheet" :href "res/css/normalize.css")
      (:link :rel "stylesheet" :href "res/css/skeleton.css")
      (:link :rel "stylesheet" :href "res/css/custom.css"))
     (:body
      (:div :class "container"
            (:div :class "header"
                  (:h2 :class "title" "Hello World")))))))
