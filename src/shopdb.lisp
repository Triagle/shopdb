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
     (file-string (format nil "../~a" ,resource-location))))
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
    (with-open-file (in (format nil "../res/~a/~a.jpeg"
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
(defun format-key-value-to-html (kv-pair)
  (reduce
   (lambda (acc cur)
     (concatenate 'string (with-html-output-to-string (s)
                            (:ul
                             (:li (:b (format nil "~a: " (car cur)) (:p (str (format nil (cond
                                                                                           ((eql (type-of (cdr cur))'double-float) "~,2f")
                                                                                           (t "~a")) (cdr cur)))))))) acc)) kv-pair :initial-value ""))

(defun view-js ()
  (concatenate 'string
               (ps
                 (defun create-cookie (name value days)
                   (if days
                       (let ((date (new (-Date)))
                             (expires ""))
                         (date.set-time (+ (date.get-time) (* days 86400000)))
                         (setq expires (+ "; expires=" (date.to-g-m-t-string))))
                       (var expires ""))
                   (setq document.cookie (+ name "=" value expires "; path=/"))
                   t)
                 (defun read-cookie (name)
                   (let ((name-eq (+ name "="))
                         (ret nil)
                         (ca (document.cookie.split ";")))
                     (loop for i from 0 to (1- (@ ca length))
                           do (progn
                                (var c (aref ca i))
                                (while (= (c.char-at 0) " ") (setq c (c.substring (@ ca length))))
                                (when (= (c.index-of name-eq) 0) (setq ret (c.substring (@ name-eq length) (@ c length)))))))
                   (return ret))
                 (defun erase-cookie (name)
                   (create-cookie name "" -1))

                 )
               "function getURLParameter(name) { return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [null, ''])[1].replace(/\\+/g, '%20')) || null; }"))
(defun split-by-char (string c)
  "Returns a list of substrings of string
divided by ONE space each.
Note: Two consecutive spaces will be seen as
if there were an empty string between them."
  (let ((res (loop for i = 0 then (1+ j)
                   as j = (position c string :start i)
                   collect (subseq string i j)
                   while j)))

    (if (equal res '(nil))
        nil
        res)))
(define-easy-handler (order-success-handler :uri "/successful-order") ()
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
      (:link :rel "stylesheet" :href "res/css/custom.css")
      (:script :type "text/javascript"
               (str (view-js))))
     (:body :onload (ps-inline (erase-cookie "order"))
      (:div :class "header"
            (:h1 "Your Order Was Successful!")
            (:a :href "/" (:h3 "Continue Shopping")))))))
(define-easy-handler (order-handler :uri "/order") (id)
  (let* ((order-list (mapcar #'parse-integer (or (split-by-char id #\,) nil)))
         (orders (if id
                     (get-products-for order-list)
                     nil)))
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
      (:link :rel "stylesheet" :href "res/css/custom.css")
      ;; JS
      (:script :type "text/javascript"
               (str (view-js)))))
      (:body :onload (ps-inline (let ((order-cookie (read-cookie "order"))
                                      (order-component (get-u-r-l-parameter "id")))
                                  (when (or (not order-component) (not (equal order-cookie order-component)))
                                    (chain window location (replace (+ "/order?id=" (encode-u-r-i-component order-cookie)))))))
             (:div :class "header"
                 (:h2 :class "title" "Generic Shop"))
           (:div :class "container"
                 (:br)
                 (:h3 "Your Order")
                 (:form :action "/successful-order"
                        (:table :class "u-full-width"
                                (:thead
                                 (:tr
                                  (:th "Preview")
                                  (:th "Name")
                                  (:th "Price")))
                                (when id
                                  (str (format-rows orders))))
                        (:p (:b "Total: ") (when id
                                             (str (format nil "$~,2f" (reduce #'+ (mapcar #'caddr orders))))
                                             ))
                        (:input
                         :class "u-full-width" :type "submit" :value "Submit Order")))))))
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
        (:link :rel "stylesheet" :href "res/css/custom.css")
        ;; JS
        (:script :type "text/javascript"
                 (str (view-js))))
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
                          (str (format-key-value-to-html (pairlis '("Name" "Price" "Description") (cdr product))))
                          (:button :type :button :onclick (ps-inline (let ((rc (read-cookie "order")))
                                                                        (if rc
                                                                            (create-cookie "order" (+ rc "," (get-u-r-l-parameter "id")) 1)
                                                                            (create-cookie "order" (get-u-r-l-parameter "id") 1))))  "Order")
                          ))))))))
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
