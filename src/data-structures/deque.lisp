(in-package #:dsa)

;; Deque — Double-ended queue backed by doubly-linked-list nodes

(defstruct (dnode (:constructor dnode-make (value &optional prev next)))
  value
  (prev nil :type (or null dnode))
  (next nil :type (or null dnode)))

(defstruct (deque (:constructor deque-make ()))
  (head nil :type (or null dnode))
  (tail nil :type (or null dnode))
  (count 0 :type fixnum))

(defun deque-empty-p (dq)
  (= (deque-count dq) 0))

(defun deque-size (dq)
  (deque-count dq))

(defun deque-push-front (dq value)
  "Push to front. O(1)."
  (let ((node (dnode-make value nil (deque-head dq))))
    (if (deque-empty-p dq)
        (setf (deque-head dq) node
              (deque-tail dq) node)
        (setf (dnode-prev (deque-head dq)) node
              (deque-head dq) node)))
  (incf (deque-count dq))
  dq)

(defun deque-push-back (dq value)
  "Push to back. O(1)."
  (let ((node (dnode-make value (deque-tail dq) nil)))
    (if (deque-empty-p dq)
        (setf (deque-head dq) node
              (deque-tail dq) node)
        (setf (dnode-next (deque-tail dq)) node
              (deque-tail dq) node)))
  (incf (deque-count dq))
  dq)

(defun deque-pop-front (dq)
  "Remove from front. O(1)."
  (when (deque-empty-p dq)
    (error "Pop-front from empty deque"))
  (let ((value (dnode-value (deque-head dq))))
    (setf (deque-head dq) (dnode-next (deque-head dq)))
    (if (null (deque-head dq))
        (setf (deque-tail dq) nil)
        (setf (dnode-prev (deque-head dq)) nil))
    (decf (deque-count dq))
    value))

(defun deque-pop-back (dq)
  "Remove from back. O(1)."
  (when (deque-empty-p dq)
    (error "Pop-back from empty deque"))
  (let ((value (dnode-value (deque-tail dq))))
    (setf (deque-tail dq) (dnode-prev (deque-tail dq)))
    (if (null (deque-tail dq))
        (setf (deque-head dq) nil)
        (setf (dnode-next (deque-tail dq)) nil))
    (decf (deque-count dq))
    value))

(defun deque-peek-front (dq)
  "Return front value. O(1)."
  (when (deque-empty-p dq)
    (error "Peek-front from empty deque"))
  (dnode-value (deque-head dq)))

(defun deque-peek-back (dq)
  "Return back value. O(1)."
  (when (deque-empty-p dq)
    (error "Peek-back from empty deque"))
  (dnode-value (deque-tail dq)))
