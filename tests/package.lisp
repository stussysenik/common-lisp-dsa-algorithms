(in-package #:cl-user)

(defpackage #:dsa-tests
  (:use #:cl #:dsa)
  (:export #:run-all-tests))

(in-package #:dsa-tests)

(defparameter *tests-passed* 0)
(defparameter *tests-failed* 0)
(defparameter *test-failures* nil)

(defmacro deftest (name &body body)
  `(progn
     (format t "~&  TEST ~A ... " ',name)
     (finish-output)
     (handler-case
         (progn ,@body
                (format t "PASS~%")
                (incf *tests-passed*))
       (error (e)
         (format t "FAIL: ~A~%" e)
         (incf *tests-failed*)
         (push ',name *test-failures*)))))

(defun assert-equal (expected actual &optional (msg ""))
  (unless (equalp expected actual)
    (error "~AExpected ~S but got ~S" msg expected actual)))

(defun assert-true (val &optional (msg ""))
  (unless val
    (error "~AExpected true, got ~S" msg val)))

(defun assert-false (val &optional (msg ""))
  (when val
    (error "~AExpected false, got ~S" msg val)))
