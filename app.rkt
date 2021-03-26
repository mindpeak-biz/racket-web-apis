#|
File:    app.rkt
Author:  Aki Iskandar
Date:    March 25, 2021
|#


#lang racket


(require json)
(require db) 
(require net/url)
(require net/url-structs)
(require web-server/templates)
(require web-server/http/request-structs)
(require web-server/http/cookie-parse)
(require web-server/servlet
         web-server/servlet-env)


;; This part defines the connection for Postgres. 
;; These credentials are for my local Postgres DB. Change the values for accessing your DB.
;; Store the credentials in environment variables - not in the code as I've done here.
(define pgc
    (postgresql-connect #:user "aki"
                        #:database "vizcaro"
                        #:password "millionaire")) 


;; These are the routes for the web application
(define-values (dispatcher url-generator)
  (dispatch-rules
   [("/") #:method "get" start]
   [("home") #:method "get" home]
   [("sample") #:method "get" sample-template]  
   ;;[("about") #:method "get" about]  
   ;;[("crumb") #:method "get" crumb]
   ;;[("qs") #:method "get" qs]
   ;;[("members") #:method "get" members]
   ;;[("member") #:method "post" create-member]
   ))


(define (start req) ;; this seems to never run
  (response/xexpr
   "This is the splash page")
  (dispatcher req))


(define (home req)
  (response/xexpr
   "This is the home page")
  (dispatcher req))


(define (sample-template req)
  (response/full
   200 #"Okay"
   (current-seconds) TEXT/HTML-MIME-TYPE
   empty
   (list (string->bytes/utf-8 (include-template "sample.html")))))


;; Get all members as JSON
(define (members req)
  (response/xexpr 
   #:code 200
   #:mime-type APPLICATION/JSON-MIME-TYPE  	 
   (query-value pgc "select get_members_as_json_string()")))


;; =======================================================
;; Start Racket's web server on port 8080
(serve/servlet 
 start   
 #:port 8080
 #:servlet-regexp #rx"") 