(in-package #:dsa)

;; Priority Queue — wraps a heap. Supports both min and max extraction.

(defstruct (priority-queue (:constructor pq-make (&key (kind :max)))
                           (:conc-name pq-))
  (heap (if (eq kind :max)
            (heap-make :test #'>)
            (heap-make :test #'<))
   :type heap)
  (kind kind :type (member :min :max)))

(defun pq-insert (pq value)
  (heap-insert (pq-heap pq) value)
  pq)

(defun pq-extract-max (pq)
  (when (eq (pq-kind pq) :min)
    (error "Cannot extract-max from min priority-queue"))
  (heap-extract (pq-heap pq)))

(defun pq-extract-min (pq)
  (when (eq (pq-kind pq) :max)
    (error "Cannot extract-min from max priority-queue"))
  (heap-extract (pq-heap pq)))

(defun pq-peek (pq)
  (heap-peek (pq-heap pq)))

(defun pq-empty-p (pq)
  (heap-empty-p (pq-heap pq)))

(defun pq-size (pq)
  (heap-size (pq-heap pq)))
