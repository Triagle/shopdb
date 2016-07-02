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
 (skeleton "res/css/skeleton.css" )
 (normalize "res/css/normalize.css" )
 (custom-css "res/css/custom.css" ))

(define-easy-handler (img-handler :uri "/get-thumb") (id full-res)
  (setf (content-type*) "image/jpeg")
  (let ((out (send-headers)))
    (with-open-file (in (format nil "res/~a/~a.jpeg"
                                (if (equal full-res "1")
                                    "img"
                                    "thumb")
                                id)
                        :element-type '(unsigned-byte 8))
      (loop for byte = (read-byte in nil)
            while byte
            do (write-byte byte out)))))
(defun format-rows (db-rows)
  (reduce (lambda (acc cur) (concatenate 'string acc (with-html-output-to-string (s) (:tr (:td
                                                                                      (:img :src (format nil "/get-thumb?id=~a" (car cur)) :alt (format nil "Image of ~a" (cadr cur))))
                                                                                     (:td
                                                                                      (:a :href (format nil "/view?id=~a" (car cur)) (str (cadr cur))))
                                                                                     (:td
                                                                                      (str (format nil "$~,2f" (caddr cur))))))))
          db-rows :initial-value ""))
(define-easy-handler (view-handler :uri "/view") (id)
  (let ((product (get-product-for id)))
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
        (:div :class "header"
              (:h2 :class "title" "Generic Shop"))
        (:div :class "container"
              (:br)
              (:br)
              (:div :class "row"
                    (:div :class "six columns"
                          (:img :src (format nil "/get-thumb?id=~a&full-res=1" (car product)) :alt (format nil "Image of ~a" (cadr product))))
                    (:div :class "six columns"
                          (:ul
                           (:li (:b "Name: ") (:p (str (cadr product)))))))))))))
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
                   (:input :id "searchInput" :class "u-full-width" :value query :placeholder "iPhone +case" :type "text" :name "query")))
            (:div :class "row"
                  (:table :class "u-full-width"
                          (:thead
                           (:tr
                            (:th "Preview")
                            (:th "Name")
                            (:th "Price")))
                          (when query
                            (str (format-rows (run-db-search query)))))))))))
(format-query-results
 (run-db-search "test"))
