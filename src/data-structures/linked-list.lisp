(in-package #:dsa)

;; Singly Linked List — classic pointer-chasing structure

(defstruct (ll-node (:constructor ll-make-node (value &optional next)))
  value
  (next nil :type (or null ll-node)))

(defstruct (linked-list (:constructor ll-make ())
                        (:conc-name ll-))
  (head nil :type (or null ll-node))
  (tail nil :type (or null ll-node))
  (count 0 :type fixnum))

(defun ll-prepend (list value)
  "Prepend to front. O(1)."
  (let ((node (ll-make-node value (ll-head list))))
    (setf (ll-head list) node)
    (when (null (ll-tail list))
      (setf (ll-tail list) node))
    (incf (ll-count list)))
  list)

(defun ll-append (list value)
  "Append to back. O(1)."
  (let ((node (ll-make-node value nil)))
    (if (null (ll-tail list))
        (setf (ll-head list) node
              (ll-tail list) node)
        (setf (ll-node-next (ll-tail list)) node
              (ll-tail list) node))
    (incf (ll-count list)))
  list)

(defun ll-find (list value &key (test #'eql))
  "Find node with VALUE. Returns node or NIL."
  (do ((curr (ll-head list) (ll-node-next curr)))
      ((null curr) nil)
    (when (funcall test (ll-node-value curr) value)
      (return curr))))

(defun ll-delete (list value &key (test #'eql))
  "Delete first occurrence of VALUE. O(n)."
  (let ((prev nil)
        (curr (ll-head list)))
    (loop while curr do
      (if (funcall test (ll-node-value curr) value)
          (progn
            (if prev
                (setf (ll-node-next prev) (ll-node-next curr))
                (setf (ll-head list) (ll-node-next curr)))
            (when (eq curr (ll-tail list))
              (setf (ll-tail list) prev))
            (decf (ll-count list))
            (return t))
          (setf prev curr
                curr (ll-node-next curr))))))

(defun ll-reverse (list)
  "Reverse in-place. O(n)."
  (let ((prev nil)
        (curr (ll-head list))
        (next nil))
    (setf (ll-tail list) (ll-head list))
    (loop while curr do
      (setf next (ll-node-next curr))
      (setf (ll-node-next curr) prev)
      (setf prev curr)
      (setf curr next))
    (setf (ll-head list) prev))
  list)

(defun ll-length (list)
  "Return element count. O(1)."
  (ll-count list))

(defun ll-to-list (list)
  "Convert to a plain Lisp list. O(n)."
  (do ((curr (ll-head list) (ll-node-next curr))
       (acc nil (cons (ll-node-value curr) acc)))
      ((null curr) (nreverse acc))))
