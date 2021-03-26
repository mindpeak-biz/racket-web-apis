#|
File:    app.rkt
Author:  Aki Iskandar
Date:    March 25, 2021

Discalimer:
-----------
I have less than 20 hours experience with Racket. I've written this file (app.rkt) as an  
experiment to see just how productive I can be in only a very short time with the language.
In fact, I volunteered to give a short talk on a topic I find usefull (since most developers 
also at least tinker with web development) to show other novices to Racket that the initial 
learning curve is quite gentle.

Witin the first day of using Racket, I enjoyed the language so much that I decided to seriously evaluate it 
as the platform for writting the web APIS for a commercial poject I have.

I hope you find this code, however brief and limited, as incentive to explore web development with Racket.

Use at your own risk:
---------------------
You are free to use any or all of this code, for whatever purpose, for the rest of time, and without consent. 
This code was written by a complete novice to Racket, and is being shared for collaborative learning and 
experimentation. Consequently, if you use any of this code, you agree to use it at your own risk, 
and to never seek any form of compensation from the author for any damages or financial losses which may  
result from using this code, be it directely or indirectly.  
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