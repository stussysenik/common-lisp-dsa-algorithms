(in-package #:dsa)

;; AVL Tree — self-balancing BST. |balance| <= 1 for all nodes.

(defstruct (avl-node (:constructor avl-node-make (value &optional left right parent height)))
  value
  (left nil :type (or null avl-node))
  (right nil :type (or null avl-node))
  (parent nil :type (or null avl-node))
  (height 1 :type fixnum))

(defstruct (avl (:constructor avl-make (&key (test #'<)))
                (:conc-name avl-))
  (root nil :type (or null avl-node))
  (test test :type function))

(defun %avl-height (node)
  (if node (avl-node-height node) 0))

(defun %avl-balance (node)
  (- (%avl-height (avl-node-left node))
     (%avl-height (avl-node-right node))))

(defun %avl-update-height (node)
  (setf (avl-node-height node)
        (1+ (max (%avl-height (avl-node-left node))
                 (%avl-height (avl-node-right node))))))

(defun %avl-rotate-right (y)
  "Right rotation. Returns new root of subtree."
  (let* ((x (avl-node-left y))
         (t2 (avl-node-right x)))
    (setf (avl-node-right x) y
          (avl-node-left y) t2)
    (when t2 (setf (avl-node-parent t2) y))
    (setf (avl-node-parent x) (avl-node-parent y)
          (avl-node-parent y) x)
    (%avl-update-height y)
    (%avl-update-height x)
    x))

(defun %avl-rotate-left (x)
  "Left rotation. Returns new root of subtree."
  (let* ((y (avl-node-right x))
         (t2 (avl-node-left y)))
    (setf (avl-node-left y) x
          (avl-node-right x) t2)
    (when t2 (setf (avl-node-parent t2) x))
    (setf (avl-node-parent y) (avl-node-parent x)
          (avl-node-parent x) y)
    (%avl-update-height x)
    (%avl-update-height y)
    y))

(defun %avl-rebalance (node)
  "Rebalance subtree rooted at NODE."
  (let ((bal (%avl-balance node)))
    (cond
      ((> bal 1)
       (if (< (%avl-balance (avl-node-left node)) 0)
           (setf (avl-node-left node) (%avl-rotate-left (avl-node-left node))))
       (setf node (%avl-rotate-right node)))
      ((< bal -1)
       (if (> (%avl-balance (avl-node-right node)) 0)
           (setf (avl-node-right node) (%avl-rotate-right (avl-node-right node))))
       (setf node (%avl-rotate-left node))))
    node))

(defun %avl-insert-node (tree node value)
  "Recursive insert helper. Returns possibly new subtree root."
  (let ((test (avl-test tree)))
    (cond
      ((null node) (return-from %avl-insert-node (avl-node-make value)))
      ((funcall test value (avl-node-value node))
       (setf (avl-node-left node) (%avl-insert-node tree (avl-node-left node) value))
       (setf (avl-node-parent (avl-node-left node)) node))
      (t
       (setf (avl-node-right node) (%avl-insert-node tree (avl-node-right node) value))
       (setf (avl-node-parent (avl-node-right node)) node))))
  (%avl-update-height node)
  (%avl-rebalance node))

(defun avl-insert (tree value)
  "Insert VALUE. O(log n), self-balancing."
  (setf (avl-root tree) (%avl-insert-node tree (avl-root tree) value))
  tree)

(defun avl-find (tree value)
  "Find node with VALUE. O(log n)."
  (let ((curr (avl-root tree))
        (test (avl-test tree)))
    (loop while curr do
      (let ((cv (avl-node-value curr)))
        (cond ((funcall test value cv) (setf curr (avl-node-left curr)))
              ((funcall test cv value) (setf curr (avl-node-right curr)))
              (t (return (avl-node-value curr))))))))

(defun %avl-min-node (node)
  (loop while (avl-node-left node) do (setf node (avl-node-left node)))
  node)

(defun %avl-delete-node (tree node value)
  "Recursive delete. Returns possibly new subtree root."
  (when (null node) (return-from %avl-delete-node nil))
  (let ((test (avl-test tree))
        (targetp nil))
    (cond
      ((funcall test value (avl-node-value node))
       (setf (avl-node-left node) (%avl-delete-node tree (avl-node-left node) value))
       (setf targetp t))
      ((funcall test (avl-node-value node) value)
       (setf (avl-node-right node) (%avl-delete-node tree (avl-node-right node) value))
       (setf targetp t))
      (t
       (setf targetp t)
       (setf node
             (cond
               ((null (avl-node-left node)) (avl-node-right node))
               ((null (avl-node-right node)) (avl-node-left node))
               (t
                (let ((succ (%avl-min-node (avl-node-right node))))
                  (setf (avl-node-value node) (avl-node-value succ))
                  (setf (avl-node-right node)
                        (%avl-delete-node tree (avl-node-right node) (avl-node-value succ)))
                  node))))))
    (if (and targetp node)
        (progn
          (%avl-update-height node)
          (%avl-rebalance node))
        node)))

(defun avl-delete (tree value)
  "Delete VALUE. O(log n), self-balancing."
  (setf (avl-root tree) (%avl-delete-node tree (avl-root tree) value))
  tree)

(defun avl-to-list (tree)
  "In-order traversal as list."
  (let ((result nil))
    (labels ((traverse (node)
               (when node
                 (traverse (avl-node-left node))
                 (push (avl-node-value node) result)
                 (traverse (avl-node-right node)))))
      (traverse (avl-root tree)))
    (nreverse result)))
