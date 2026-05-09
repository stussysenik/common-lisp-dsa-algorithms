(in-package #:dsa)

;; Red-Black Tree — self-balancing BST with color invariant.
;; Invariants: (1) Root is black, (2) No red node has a red child,
;; (3) All paths from root to nil have same # of black nodes.

(defconstant +rb-red+ 'red)
(defconstant +rb-black+ 'black)

(defstruct (rb-node (:constructor rb-node-make (value color &optional left right parent)))
  value
  (color +rb-red+ :type (member red black))
  (left nil :type (or null rb-node))
  (right nil :type (or null rb-node))
  (parent nil :type (or null rb-node)))

(defstruct (rb-tree (:constructor rb-make (&key (test #'<)))
                    (:conc-name rb-))
  (root nil :type (or null rb-node))
  (test test :type function))

(defun %rb-grandparent (node)
  (when (rb-node-parent node)
    (rb-node-parent (rb-node-parent node))))

(defun %rb-uncle (node)
  (let ((gp (%rb-grandparent node)))
    (when gp
      (if (eq (rb-node-parent node) (rb-node-left gp))
          (rb-node-right gp)
          (rb-node-left gp)))))

(defun %rb-sibling (node)
  (let ((p (rb-node-parent node)))
    (when p
      (if (eq node (rb-node-left p))
          (rb-node-right p)
          (rb-node-left p)))))

(defun %rb-rotate-left (tree x)
  (let* ((y (rb-node-right x))
         (parent (rb-node-parent x)))
    (setf (rb-node-right x) (rb-node-left y))
    (when (rb-node-left y)
      (setf (rb-node-parent (rb-node-left y)) x))
    (setf (rb-node-parent y) parent)
    (cond ((null parent) (setf (rb-root tree) y))
          ((eq x (rb-node-left parent)) (setf (rb-node-left parent) y))
          (t (setf (rb-node-right parent) y)))
    (setf (rb-node-left y) x)
    (setf (rb-node-parent x) y)))

(defun %rb-rotate-right (tree y)
  (let* ((x (rb-node-left y))
         (parent (rb-node-parent y)))
    (setf (rb-node-left y) (rb-node-right x))
    (when (rb-node-right x)
      (setf (rb-node-parent (rb-node-right x)) y))
    (setf (rb-node-parent x) parent)
    (cond ((null parent) (setf (rb-root tree) x))
          ((eq y (rb-node-left parent)) (setf (rb-node-left parent) x))
          (t (setf (rb-node-right parent) x)))
    (setf (rb-node-right x) y)
    (setf (rb-node-parent y) x)))

(defun %rb-insert-fixup (tree node)
  "Fix red-black tree invariants after insertion."
  (loop while (and (rb-node-parent node)
                   (eq (rb-node-color (rb-node-parent node)) +rb-red+)) do
    (let ((parent (rb-node-parent node))
          (gp (%rb-grandparent node))
          (uncle (%rb-uncle node)))
      (if (and uncle (eq (rb-node-color uncle) +rb-red+))
          ;; Case 1: uncle is red — recolor
          (progn
            (setf (rb-node-color parent) +rb-black+
                  (rb-node-color uncle) +rb-black+
                  (rb-node-color gp) +rb-red+)
            (setf node gp))
          ;; Uncle is black — rotate
          (progn
            (when (eq parent (rb-node-right gp))
              (if (eq node (rb-node-left parent))
                  ;; Right-Left case
                  (progn
                    (setf node parent)
                    (%rb-rotate-right tree node))
                  ;; Right-Right case
                  (progn
                    (setf (rb-node-color parent) +rb-black+)
                    (setf (rb-node-color gp) +rb-red+)
                    (%rb-rotate-left tree gp)
                    (setf node parent)))
              (return))
            (when (eq parent (rb-node-left gp))
              (if (eq node (rb-node-right parent))
                  ;; Left-Right case
                  (progn
                    (setf node parent)
                    (%rb-rotate-left tree node))
                  ;; Left-Left case
                  (progn
                    (setf (rb-node-color parent) +rb-black+)
                    (setf (rb-node-color gp) +rb-red+)
                    (%rb-rotate-right tree gp)
                    (setf node parent)))
              (return))))))
  (setf (rb-node-color (rb-root tree)) +rb-black+))

(defun rb-insert (tree value)
  "Insert VALUE. O(log n), self-balancing."
  (let ((node (rb-node-make value +rb-red+))
        (parent nil)
        (curr (rb-root tree))
        (test (rb-test tree)))
    (loop while curr do
      (setf parent curr)
      (if (funcall test value (rb-node-value curr))
          (setf curr (rb-node-left curr))
          (setf curr (rb-node-right curr))))
    (setf (rb-node-parent node) parent)
    (cond ((null parent) (setf (rb-root tree) node))
          ((funcall test value (rb-node-value parent))
           (setf (rb-node-left parent) node))
          (t (setf (rb-node-right parent) node)))
    (%rb-insert-fixup tree node))
  tree)

(defun rb-find (tree value)
  "Find VALUE. O(log n)."
  (let ((curr (rb-root tree))
        (test (rb-test tree)))
    (loop while curr do
      (let ((cv (rb-node-value curr)))
        (cond ((funcall test value cv) (setf curr (rb-node-left curr)))
              ((funcall test cv value) (setf curr (rb-node-right curr)))
              (t (return cv)))))))

(defun rb-to-list (tree)
  "In-order as list."
  (let ((result nil))
    (labels ((traverse (node)
               (when node
                 (traverse (rb-node-left node))
                 (push (rb-node-value node) result)
                 (traverse (rb-node-right node)))))
      (traverse (rb-root tree)))
    (nreverse result)))
