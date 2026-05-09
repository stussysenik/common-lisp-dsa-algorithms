(in-package #:dsa)

;; Trie (Prefix Tree) — O(k) insert/search/delete where k = key length

(defstruct (trie-node (:constructor %trie-node-make ())
                     (:conc-name tn-))
  (children (ht-make :capacity 26 :test #'eql) :type ht)
  (terminal nil :type boolean))

(defstruct (trie (:constructor trie-make ())
                 (:conc-name tr-))
  (root (%trie-node-make) :type trie-node)
  (word-count 0 :type fixnum))

(defun trie-insert (tr word)
  (loop with node = (tr-root tr)
        for ch across word
        do (let ((child (ht-get (tn-children node) ch)))
             (unless child
               (setf child (%trie-node-make))
               (ht-set (tn-children node) ch child))
             (setf node child))
        finally (unless (tn-terminal node)
                  (setf (tn-terminal node) t)
                  (incf (tr-word-count tr))))
  tr)

(defun trie-search (tr word)
  (loop with node = (tr-root tr)
        for ch across word
        do (setf node (ht-get (tn-children node) ch))
           (unless node (return nil))
        finally (return (tn-terminal node))))

(defun trie-starts-with (tr prefix)
  (loop with node = (tr-root tr)
        for ch across prefix
        do (setf node (ht-get (tn-children node) ch))
           (unless node (return nil))
        finally (return t)))

(defun %trie-delete-rec (node word i)
  (when (= i (length word))
    (setf (tn-terminal node) nil)
    (return-from %trie-delete-rec t))
  (let* ((ch (char word i))
         (child (ht-get (tn-children node) ch)))
    (when (and child (%trie-delete-rec child word (1+ i)))
      (ht-delete (tn-children node) ch)
      (unless (tn-terminal node)
        (return-from %trie-delete-rec t)))
    nil))

(defun trie-delete (tr word)
  (when (trie-search tr word)
    (%trie-delete-rec (tr-root tr) word 0)
    (decf (tr-word-count tr))
    t))

(defun trie-count-words (tr)
  (tr-word-count tr))
