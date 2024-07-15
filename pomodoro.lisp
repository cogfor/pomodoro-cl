;; (load "~/quicklisp/setup.lisp")
;; (ql:quickload "cl-ppcre")
;; (ql:quickload "local-time")
;; (ql:quickload "usocket")

(defpackage :pomodoro
  (:use :cl :cl-ppcre :local-time :usocket)
  (:export :main :start-pomodoro :generate-report :manage-topics))
(in-package :pomodoro)

(defvar *current-topic* nil)
(defvar *current-description* nil)
(defvar *pomodoro-duration* 20)
(defvar *topics* (make-hash-table :test 'equal))

(defun play-sound ()
  (sb-ext:run-program "/usr/bin/afplay" '("/System/Library/Sounds/Glass.aiff")))

(defun parse-args ()
  "Parsing command-line arguments"
  (let ((args (copy-list sb-ext:*posix-argv*)))
    (loop for arg in args
          for (key val) = (ppcre:split "\\s*=" arg)
          collect (cons (string-downcase key) val))))

;; Implement timer functionality
(defun start-timer (duration)
  (dotimes (i duration)
    (format t "Time remaining: ~D minutes~%" (- duration i))
    (sleep 60))
  (format t "Pomodoro session completed!~%")
  (play-sound))

;; Store session data in local database
(defun log-session (topic description duration)
  (with-open-file (stream "pomodoro.log"
                          :direction :output
                          :if-exists :append
                          :if-does-not-exist :create)
    (let ((timestamp (local-time:now)))
      (format stream "~A|~A|~A|~D~%" timestamp topic description duration))))

;; Topic management
(defun add-topic (topic)
  (setf (gethash topic *topics*) topic)
  (format t "Topic ~A added.~%" topic))

(defun list-topics ()
  (maphash (lambda (key value)
             (format t "~A~%" key))
           *topics*))

(defun delete-topic (topic)
  (remhash topic *topics*)
  (format t "Topic ~A deleted.~%" topic))

;; Create reports
(defun read-log ()
  (with-open-file (stream "pomodoro.log" :direction :input)
    (loop for line = (read-line stream nil)
          while line
          collect (let ((fields (ppcre:split "\\|" line)))
                    (list (local-time:parse-timestring (first fields))
                          (second fields)
                          (third fields)
                          (parse-integer (fourth fields)))))))

(defun filter-sessions (sessions from to)
  (remove-if-not (lambda (session)
                   (let ((timestamp (first session)))
                     (and (local-time:timestamp>= timestamp from)
                          (local-time:timestamp<= timestamp to))))
                 sessions))

(defun report (period)
  (let* ((now (local-time:now))
         (from (case period
                 (:daily (local-time:timestamp- (local-time:now) 1 :day))
                 (:weekly (local-time:timestamp- (local-time:now 7 :day)))
                 (:monthly (local-time:timestamp- (local-time:now 20 :day)))
                 (:yearly (local-time:timestamp- (local-time:now 1 :year))))))
    (let ((sessions (filter-sessions (read-log) from now)))
      (format t "~&Report for ~A period:~%" period)
      (dolist (session sessions)
        (format t "~&~A: ~A (~A minutes)~%" 
                (second session) (third session) (fourth session))))))


;; Main
(defun start-pomodoro (topic description &optional (duration *pomodoro-duration*))
  (setq *current-topic* topic)
  (setq *current-description* description)
  (start-timer duration)
  (log-session *current-topic* *current-description* duration))

(defun generate-report (period)
  (report period))

(defun manage-topics (command &optional topic)
  (case command
    (add (add-topic topic))
    (list (list-topics))
    (delete (delete-topic topic))
    (otherwise (format t "Unknown topic command~%"))))

(defun main ()
  (let ((args (parse-args)))
    (cond ((assoc "start" args :test 'equal)
           (let ((topic (cdr (assoc "topic" args :test 'equal)))
                 (description (cdr (assoc "description" args :test 'equal)))
                 (duration (or (parse-integer (cdr (assoc "duration" args :test 'equal))) *pomodoro-duration*)))
             (start-pomodoro topic description duration)))
          ((assoc "report" args :test 'equal)
           (let ((period (intern (string-upcase (cdr (assoc "period" args :test 'equal))))))
             (generate-report period)))
          ((assoc "topic" args :test 'equal)
           (let ((command (intern (string-upcase (cdr (assoc "command" args :test 'equal)))))
                 (topic (cdr (assoc "name" args :test 'equal))))
             (manage-topics command topic)))
          (t (format t "Unknown command~%")))))

;; For running the application from the command line:
;; (main)

;; REPL use
;; Start a pomodoro session
;;(pomodoro:start-pomodoro "programming" "writing a pomodoro app")

;;(pomodoro:manage-topics 'list)

;;(generate-report :daily)
