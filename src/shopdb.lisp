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
(defun file-string (file)
  (with-open-file (stream file)
    (format nil "~{~A~^~%~}"
            (loop for line = (read-line stream nil)
                  while line
                  collecting line))))
(defmacro file-handler (handler-name resource-location)
  `(define-easy-handler (,handler-name :uri (format nil "/~a" ,resource-location)) ()
     (file-string ,resource-location)))
(defmacro file-handlers (&rest forms)
  (let ((fm (mapcar (lambda (i) (cons 'file-handler i)) forms)))
    `(progn
       ,@fm)))
(file-handlers
 (skeleton "res/css/skeleton.css")
 (normalize "res/css/normalize.css")
 (custom-css "res/css/custom.css"))
(define-easy-handler (search-handler :uri "/search") (query)
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
                  (:h2 :class "title" "Generic Shop"))
            (:form :action "/search"
             (:div :class "row"
                   (:input :id "searchInput" :class "u-full-width" :placeholder "iPhone +case" :type "text" :name "query")))
            (:div :class "row"
                  (:table :class "u-full-width"
                          (:thead
                           (:tr
                            (:th "Preview")
                            (:th "Name")
                            (:th "Description")
                            (:th "Price")))
                          (:tbody))))))))
