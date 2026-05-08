(in-package #:dsa)

;; Binary Tree — generic tree with left/right children

(defstruct (bt-node (:constructor bt-make-node (value &optional left right)))
  value
  (left nil :type (or null bt-node))
  (right nil :type (or null bt-node)))

(defun bt-insert-left (node child-value)
  "Insert CHILD-VALUE as left child of NODE."
  (setf (bt-node-left node) (bt-make-node child-value))
  node)

(defun bt-insert-right (node child-value)
  "Insert CHILD-VALUE as right child of NODE."
  (setf (bt-node-right node) (bt-make-node child-value))
  node)

(defun bt-preorder (node visit-fn)
  "Depth-first preorder traversal: root, left, right."
  (when node
    (funcall visit-fn (bt-node-value node))
    (bt-preorder (bt-node-left node) visit-fn)
    (bt-preorder (bt-node-right node) visit-fn)))

(defun bt-inorder (node visit-fn)
  "Depth-first inorder traversal: left, root, right."
  (when node
    (bt-inorder (bt-node-left node) visit-fn)
    (funcall visit-fn (bt-node-value node))
    (bt-inorder (bt-node-right node) visit-fn)))

(defun bt-postorder (node visit-fn)
  "Depth-first postorder traversal: left, right, root."
  (when node
    (bt-postorder (bt-node-left node) visit-fn)
    (bt-postorder (bt-node-right node) visit-fn)
    (funcall visit-fn (bt-node-value node))))

(defun bt-level-order (node visit-fn)
  "Breadth-first level-order traversal."
  (when node
    (let ((q (queue-make)))
      (queue-enqueue q node)
      (loop while (not (queue-empty-p q)) do
        (let ((curr (queue-dequeue q)))
          (funcall visit-fn (bt-node-value curr))
          (when (bt-node-left curr)
            (queue-enqueue q (bt-node-left curr)))
          (when (bt-node-right curr)
            (queue-enqueue q (bt-node-right curr))))))))

(defun bt-height (node)
  "Return tree height (0-indexed: leaf has height 0)."
  (if (null node)
      -1
      (1+ (max (bt-height (bt-node-left node))
               (bt-height (bt-node-right node))))))

(defun bt-size (node)
  "Return number of nodes."
  (if (null node)
      0
      (1+ (+ (bt-size (bt-node-left node))
             (bt-size (bt-node-right node))))))
