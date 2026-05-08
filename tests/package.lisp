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
  (if (equalp expected actual)
      (incf *tests-passed*)
      (progn
        (incf *tests-failed*)
        (push (format nil "~AExpected ~S but got ~S" msg expected actual) *test-failures*)
        (warn "~AExpected ~S but got ~S" msg expected actual))))

(defun assert-true (val &optional (msg ""))
  (if val
      (incf *tests-passed*)
      (progn
        (incf *tests-failed*)
        (push (format nil "~AExpected true, got ~S" msg val) *test-failures*)
        (warn "~AExpected true, got ~S" msg val))))

(defun assert-false (val &optional (msg ""))
  (if (null val)
      (incf *tests-passed*)
      (progn
        (incf *tests-failed*)
        (push (format nil "~AExpected false, got ~S" msg val) *test-failures*)
        (warn "~AExpected false, got ~S" msg val))))

(defun run-all-tests ()
  (setf *tests-passed* 0
        *tests-failed* 0
        *test-failures* nil)
  (format t "~2%=== RUNNING ALL DSA TESTS ===~2%")
  (test-dynamic-array)
  (test-linked-list)
  (test-stack-queue)
  (test-heap)
  (test-trees)
  (test-graph)
  (test-sorting)
  (test-algorithms)
  (format t "~2%=== DONE: ~D passed, ~D failed ===~2%" *tests-passed* *tests-failed*)
  (when *test-failures*
    (format t "Failures: ~{~A~^, ~}~%" *test-failures*))
  (values *tests-passed* *tests-failed*))
