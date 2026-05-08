(in-package #:dsa)

;; LRU Cache — O(1) get/put via hash table + doubly-linked list

(defstruct (lru-node (:constructor lru-node-make (key value &optional prev next)))
  key value
  (prev nil :type (or null lru-node))
  (next nil :type (or null lru-node)))

(defstruct (lru-cache (:constructor lru-make (capacity))
                      (:conc-name lru-))
  (capacity capacity :type fixnum)
  (ht (ht-make :capacity capacity) :type ht)
  ;; Sentinel head/tail simplifies edge cases
  (head (lru-node-make nil nil) :type lru-node)
  (tail (lru-node-make nil nil) :type lru-node))

(defun %lru-remove (cache node)
  "Unlink NODE from the doubly-linked list."
  (let ((prev (lru-node-prev node))
        (next (lru-node-next node)))
    (setf (lru-node-next prev) next)
    (setf (lru-node-prev next) prev)))

(defun %lru-add-to-front (cache node)
  "Add NODE to the front (most recently used)."
  (let ((head (lru-head cache)))
    (setf (lru-node-next node) (lru-node-next head))
    (setf (lru-node-prev node) head)
    (when (lru-node-next head)
      (setf (lru-node-prev (lru-node-next head)) node))
    (setf (lru-node-next head) node)
    ;; Initialise tail sentinel's prev
    (when (null (lru-node-prev (lru-tail cache)))
      (setf (lru-node-prev (lru-tail cache)) node)
      (setf (lru-node-next node) (lru-tail cache)))))

(defun %lru-evict (cache)
  "Evict least recently used (node before tail sentinel)."
  (let ((lru (lru-node-prev (lru-tail cache))))
    (when lru
      (%lru-remove cache lru)
      (ht-delete (lru-ht cache) (lru-node-key lru)))))

(defun lru-get (cache key &optional default)
  "Return value for KEY, moving it to front. O(1)."
  (let ((node (ht-get (lru-ht cache) key)))
    (if node
        (progn
          (%lru-remove cache node)
          (%lru-add-to-front cache node)
          (lru-node-value node))
        default)))

(defun lru-put (cache key value)
  "Insert or update KEY/VALUE. O(1)."
  (let ((node (ht-get (lru-ht cache) key)))
    (if node
        (progn
          (setf (lru-node-value node) value)
          (%lru-remove cache node)
          (%lru-add-to-front cache node))
        (progn
          (when (>= (ht-size (lru-ht cache)) (lru-capacity cache))
            (%lru-evict cache))
          (let ((new-node (lru-node-make key value)))
            (ht-set (lru-ht cache) key new-node)
            (%lru-add-to-front cache new-node)))))
  cache)

(defun lru-size (cache)
  (ht-size (lru-ht cache)))
