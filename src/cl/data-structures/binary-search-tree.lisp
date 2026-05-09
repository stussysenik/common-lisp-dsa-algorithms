(in-package #:dsa)

;; Binary Search Tree — no balancing, classic insert/delete/find

(defstruct (bst-node (:constructor bst-node-make (value &optional left right parent)))
  value
  (left nil :type (or null bst-node))
  (right nil :type (or null bst-node))
  (parent nil :type (or null bst-node)))

(defstruct (bst (:constructor bst-make (&key (test #'<)))
                (:conc-name bst-))
  (root nil :type (or null bst-node))
  (test test :type function)
  (count 0 :type fixnum))

(defun bst-empty-p (tree)
  (null (bst-root tree)))

(defun bst-insert (tree value)
  "Insert VALUE. Returns the new node."
  (let ((node (bst-node-make value))
        (root (bst-root tree))
        (test (bst-test tree)))
    (if (null root)
        (setf (bst-root tree) node)
        (loop
          (if (funcall test value (bst-node-value root))
              (if (bst-node-left root)
                  (setf root (bst-node-left root))
                  (progn
                    (setf (bst-node-left root) node
                          (bst-node-parent node) root)
                    (return)))
              (if (bst-node-right root)
                  (setf root (bst-node-right root))
                  (progn
                    (setf (bst-node-right root) node
                          (bst-node-parent node) root)
                    (return))))))
    (incf (bst-count tree))
    node))

(defun bst-find (tree value)
  "Find VALUE. Returns the node or NIL."
  (let ((curr (bst-root tree))
        (test (bst-test tree)))
    (loop while curr do
      (cond
        ((funcall test value (bst-node-value curr))
         (setf curr (bst-node-left curr)))
        ((funcall test (bst-node-value curr) value)
         (setf curr (bst-node-right curr)))
        (t (return curr))))))

(defun bst-min (tree-or-node)
  "Find minimum value node."
  (let ((node (if (bst-p tree-or-node) (bst-root tree-or-node) tree-or-node)))
    (loop while (bst-node-left node) do
      (setf node (bst-node-left node)))
    node))

(defun bst-max (tree-or-node)
  "Find maximum value node."
  (let ((node (if (bst-p tree-or-node) (bst-root tree-or-node) tree-or-node)))
    (loop while (bst-node-right node) do
      (setf node (bst-node-right node)))
    node))

(defun bst-successor (node)
  "In-order successor of NODE."
  (when (bst-node-right node)
    (return-from bst-successor (bst-min (bst-node-right node))))
  (let ((parent (bst-node-parent node)))
    (loop while (and parent (eq node (bst-node-right parent))) do
      (setf node parent
            parent (bst-node-parent parent)))
    parent))

(defun bst-predecessor (node)
  "In-order predecessor of NODE."
  (when (bst-node-left node)
    (return-from bst-predecessor (bst-max (bst-node-left node))))
  (let ((parent (bst-node-parent node)))
    (loop while (and parent (eq node (bst-node-left parent))) do
      (setf node parent
            parent (bst-node-parent parent)))
    parent))

(defun %bst-transplant (tree old new)
  "Replace OLD subtree with NEW."
  (if (null (bst-node-parent old))
      (setf (bst-root tree) new)
      (if (eq old (bst-node-left (bst-node-parent old)))
          (setf (bst-node-left (bst-node-parent old)) new)
          (setf (bst-node-right (bst-node-parent old)) new)))
  (when new
    (setf (bst-node-parent new) (bst-node-parent old))))

(defun bst-delete (tree node)
  "Delete NODE from TREE."
  (cond
    ((null (bst-node-left node))
     (%bst-transplant tree node (bst-node-right node)))
    ((null (bst-node-right node))
     (%bst-transplant tree node (bst-node-left node)))
    (t
     (let* ((succ (bst-min (bst-node-right node)))
            (succ-right (bst-node-right succ)))
       (unless (eq (bst-node-parent succ) node)
         (%bst-transplant tree succ succ-right)
         (setf (bst-node-right succ) (bst-node-right node))
         (setf (bst-node-parent (bst-node-right succ)) succ))
       (%bst-transplant tree node succ)
       (setf (bst-node-left succ) (bst-node-left node))
       (setf (bst-node-parent (bst-node-left succ)) succ))))
  (decf (bst-count tree))
  tree)

(defun bst-to-list (tree)
  "Return inorder traversal as a list."
  (let ((result nil))
    (labels ((inorder (node)
               (when node
                 (inorder (bst-node-left node))
                 (push (bst-node-value node) result)
                 (inorder (bst-node-right node)))))
      (inorder (bst-root tree)))
    (nreverse result)))
