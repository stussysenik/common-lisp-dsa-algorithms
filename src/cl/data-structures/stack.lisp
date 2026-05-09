(in-package #:dsa)

;; Stack — LIFO backed by a list

(defstruct (stack (:constructor stack-make ()))
  (data nil :type list))

(defun stack-push (s value)
  "Push onto top. O(1)."
  (push value (stack-data s))
  s)

(defun stack-pop (s)
  "Pop from top. O(1)."
  (when (null (stack-data s))
    (error "Pop from empty stack"))
  (pop (stack-data s)))

(defun stack-peek (s)
  "Return top without removing. O(1)."
  (when (null (stack-data s))
    (error "Peek from empty stack"))
  (first (stack-data s)))

(defun stack-empty-p (s)
  (null (stack-data s)))

(defun stack-size (s)
  (length (stack-data s)))
